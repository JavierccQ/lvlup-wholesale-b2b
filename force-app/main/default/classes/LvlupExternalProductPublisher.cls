/**
 * ============================================================================
 *  LvlupExternalProductPublisher  (capa de PUBLICACIÓN staging -> Product2)
 * ============================================================================
 *  Responsabilidad ÚNICA: sincronizar los registros staging `External_Product__c`
 *  (origen Platzi, en estado Imported) con productos reales `Product2`:
 *    - si el staging aún NO tiene Product2 asociado  -> CREA el Product2
 *      (con SKU, inventario simulado y reglas de pedido) y lo enlaza,
 *    - si YA tiene Product2 asociado                 -> ACTUALIZA los campos que
 *      provienen de Platzi (Name, Description).
 *  En ambos casos marca la trazabilidad del staging (Published / Error).
 *
 *  El importador resetea a "Imported" cada fila reimportada, así que esta clase
 *  procesa tanto altas nuevas como actualizaciones del run diario. El inventario,
 *  el SKU y las reglas de pedido se fijan SOLO al crear: son datos propios y no
 *  se sobrescriben en cada sync (Platzi no los provee).
 *
 *  Diseño bulk-friendly: una sola SOQL, mapeo en memoria, DML parcial fuera de
 *  loops y correlación de resultados por índice.
 * ============================================================================
 */
public with sharing class LvlupExternalProductPublisher {
    // Valores fijos del proceso (sin hardcodear en el cuerpo).
    private static final String SOURCE_PLATZI = 'Platzi';
    private static final String STATUS_IMPORTED = 'Imported';
    private static final String STATUS_PUBLISHED = 'Published';
    private static final String STATUS_ERROR = 'Error';
    private static final String PRODUCT_CODE_PREFIX = 'EXT-PLATZI-';
    // Inventario simulado y reglas de pedido por defecto (Platzi no da stock).
    private static final Decimal DEFAULT_INVENTORY = 100;
    private static final Decimal DEFAULT_MIN_ORDER = 1;
    private static final Decimal DEFAULT_ORDER_INCREMENT = 1;
    private static final Decimal DEFAULT_MAX_ORDER = 1000;

    /** Resumen del resultado de una sincronización. */
    public class PublishResult {
        public Integer totalProcessed = 0;
        public Integer createdCount = 0;
        public Integer updatedCount = 0;
        public Integer errorCount = 0;
    }

    /**
     * Sincroniza los staging "Imported" de Platzi con Product2 (crea o actualiza).
     *
     * @return resumen con totales (procesados / creados / actualizados / con error).
     */
    public static PublishResult publishImportedProducts() {
        PublishResult result = new PublishResult();

        // 1) Staging elegible: Imported y de Platzi (con y sin Product2 asociado).
        List<External_Product__c> externals = [
            SELECT Id, External_Id__c, External_Title__c, External_Description__c,
                   External_Source__c, Salesforce_Product__c
            FROM External_Product__c
            WHERE Sync_Status__c = :STATUS_IMPORTED
              AND External_Source__c = :SOURCE_PLATZI
        ];
        if (externals.isEmpty()) {
            return result;
        }
        result.totalProcessed = externals.size();

        // 2) Particionar: altas (sin enlace) vs actualizaciones (con enlace).
        //    Se mantienen listas paralelas para correlacionar por índice.
        List<External_Product__c> toCreateStaging = new List<External_Product__c>();
        List<Product2> productsToInsert = new List<Product2>();
        List<External_Product__c> toUpdateStaging = new List<External_Product__c>();
        List<Product2> productsToUpdate = new List<Product2>();

        for (External_Product__c ext : externals) {
            if (ext.Salesforce_Product__c == null) {
                toCreateStaging.add(ext);
                productsToInsert.add(buildNewProduct(ext));
            } else {
                toUpdateStaging.add(ext);
                productsToUpdate.add(buildProductUpdate(ext));
            }
        }

        // 3) Altas: insert PARCIAL. Enlazar y marcar trazabilidad en memoria.
        if (!productsToInsert.isEmpty()) {
            List<Database.SaveResult> insertResults = Database.insert(productsToInsert, false);
            for (Integer i = 0; i < insertResults.size(); i++) {
                External_Product__c ext = toCreateStaging[i];
                Database.SaveResult sr = insertResults[i];
                ext.Last_Sync_Date__c = System.now();
                if (sr.isSuccess()) {
                    ext.Salesforce_Product__c = productsToInsert[i].Id;
                    ext.Sync_Status__c = STATUS_PUBLISHED;
                    ext.Last_Error__c = null;
                    result.createdCount++;
                } else {
                    ext.Sync_Status__c = STATUS_ERROR;
                    ext.Last_Error__c = formatErrors(sr.getErrors());
                    result.errorCount++;
                }
            }
        }

        // 4) Actualizaciones: update PARCIAL de los Product2 ya enlazados.
        if (!productsToUpdate.isEmpty()) {
            List<Database.SaveResult> updateResults = Database.update(productsToUpdate, false);
            for (Integer i = 0; i < updateResults.size(); i++) {
                External_Product__c ext = toUpdateStaging[i];
                Database.SaveResult sr = updateResults[i];
                ext.Last_Sync_Date__c = System.now();
                if (sr.isSuccess()) {
                    ext.Sync_Status__c = STATUS_PUBLISHED;
                    ext.Last_Error__c = null;
                    result.updatedCount++;
                } else {
                    ext.Sync_Status__c = STATUS_ERROR;
                    ext.Last_Error__c = formatErrors(sr.getErrors());
                    result.errorCount++;
                }
            }
        }

        // 5) Persistir la trazabilidad del staging (update parcial).
        List<External_Product__c> allStaging = new List<External_Product__c>();
        allStaging.addAll(toCreateStaging);
        allStaging.addAll(toUpdateStaging);
        Database.update(allStaging, false);

        return result;
    }

    /**
     * Construye un Product2 NUEVO desde el staging. Aquí se fijan, además de los
     * campos de Platzi, el SKU, el inventario simulado y las reglas de pedido
     * (datos propios que solo se establecen al crear).
     */
    @TestVisible
    private static Product2 buildNewProduct(External_Product__c ext) {
        String code = PRODUCT_CODE_PREFIX + ext.External_Id__c;
        return new Product2(
            Name = ext.External_Title__c,
            Description = ext.External_Description__c,
            ProductCode = code,
            StockKeepingUnit = code,
            External_Product_Id__c = ext.External_Id__c,
            External_Source__c = ext.External_Source__c,
            Is_External_Product__c = true,
            IsActive = true,
            Inventory_Quantity__c = DEFAULT_INVENTORY,
            Min_Order_Quantity__c = DEFAULT_MIN_ORDER,
            Order_Increment__c = DEFAULT_ORDER_INCREMENT,
            Max_Order_Quantity__c = DEFAULT_MAX_ORDER
        );
    }

    /**
     * Construye el "delta" de actualización de un Product2 ya existente: solo los
     * campos que provienen de Platzi (Name, Description). No toca SKU, inventario,
     * reglas ni IsActive para no pisar datos propios/decisiones de admin.
     */
    @TestVisible
    private static Product2 buildProductUpdate(External_Product__c ext) {
        return new Product2(
            Id = ext.Salesforce_Product__c,
            Name = ext.External_Title__c,
            Description = ext.External_Description__c
        );
    }

    /** Concatena los mensajes de error de un SaveResult fallido para el log. */
    private static String formatErrors(List<Database.Error> errors) {
        List<String> messages = new List<String>();
        for (Database.Error err : errors) {
            messages.add(err.getStatusCode() + ': ' + err.getMessage());
        }
        return String.join(messages, ' | ');
    }
}
