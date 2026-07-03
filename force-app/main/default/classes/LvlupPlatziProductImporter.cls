/**
 * ============================================================================
 *  LvlupPlatziProductImporter  (capa de IMPORTACIÓN a staging)
 * ============================================================================
 *  Responsabilidad ÚNICA: tomar los productos que devuelve la capa de servicio
 *  (`LvlupPlatziProductService`) y volcarlos en el objeto staging
 *  `External_Product__c` mediante UPSERT por `External_Id__c`.
 *
 *  Esta clase NO crea Product2, NI PricebookEntry, NI categorías de Commerce,
 *  NI publica nada en la Store. Solo llena la "bandeja de entrada". La
 *  publicación a Commerce será un paso posterior que leerá de aquí.
 *
 *  ── POR QUÉ UPSERT (y no insert) ────────────────────────────────────────────
 *  `External_Id__c` está marcado como External ID + Unique. Al hacer
 *  `Database.upsert(records, External_Product__c.External_Id__c)`:
 *    - si ya existe un registro con ese External Id → lo ACTUALIZA,
 *    - si no existe → lo CREA.
 *  Así, reimportar Platzi N veces NO genera duplicados: el catálogo staging
 *  queda idempotente respecto del id de origen.
 *
 *  ── SHARING ────────────────────────────────────────────────────────────────
 *  `with sharing`, igual que el servicio. Quien ejecute el importador necesita
 *  acceso CRUD a External_Product__c (lo concede el permission set
 *  `Lvlup_External_Product_Admin`).
 * ============================================================================
 */
public with sharing class LvlupPlatziProductImporter {
    // Valores fijos del mapeo (ver tabla de mapeo de la tarea).
    private static final String SOURCE_PLATZI = 'Platzi';
    private static final String STATUS_IMPORTED = 'Imported';
    // Los campos de texto/URL del objeto topan en estas longitudes; recortamos o
    // descartamos para que datos externos imprevisibles no rompan el upsert.
    private static final Integer MAX_TEXT_LENGTH = 255;
    private static final Integer MAX_URL_LENGTH = 255;

    /**
     * Pequeño resumen del resultado de una importación. Útil para reportar desde
     * Anonymous Apex, un futuro botón/Flow o los tests, sin tener que reconsultar.
     */
    public class ImportResult {
        public Integer totalProcessed = 0;
        public Integer createdCount = 0;
        public Integer updatedCount = 0;
    }

    /**
     * Orquesta el flujo completo: trae los primeros 10 productos de Platzi vía la
     * capa de servicio y los vuelca en staging.
     *
     * Pensado para llamarse desde Anonymous Apex:
     *   LvlupPlatziProductImporter.ImportResult r =
     *       LvlupPlatziProductImporter.importFirstTenProducts();
     *
     * @return resumen con totales (procesados / creados / actualizados).
     */
    public static ImportResult importFirstTenProducts() {
        List<LvlupPlatziProductService.PlatziProduct> products =
            LvlupPlatziProductService.getFirstTenProducts();
        return importProducts(products);
    }

    /**
     * Mapea y hace UPSERT de una lista de productos ya obtenida. Se mantiene
     * separada de `importFirstTenProducts()` para poder reutilizarla (otro
     * origen, otro offset) y para poder testearla sin callout.
     *
     * @param products productos tipados a importar (puede venir null/vacía).
     * @return resumen de la operación.
     */
    public static ImportResult importProducts(
        List<LvlupPlatziProductService.PlatziProduct> products
    ) {
        ImportResult result = new ImportResult();
        if (products == null || products.isEmpty()) {
            return result;
        }

        // 1) Mapear cada producto externo a un registro de staging.
        List<External_Product__c> records = new List<External_Product__c>();
        for (LvlupPlatziProductService.PlatziProduct product : products) {
            records.add(mapToExternalProduct(product));
        }

        // 2) UPSERT por External Id (allOrNone = true: si algo falla, revierte
        //    todo y lanza DmlException para no dejar el staging a medias).
        List<Database.UpsertResult> upsertResults = Database.upsert(
            records,
            External_Product__c.External_Id__c,
            true
        );

        // 3) Contabilizar creados vs actualizados para el resumen.
        result.totalProcessed = upsertResults.size();
        for (Database.UpsertResult ur : upsertResults) {
            if (ur.isCreated()) {
                result.createdCount++;
            } else {
                result.updatedCount++;
            }
        }
        return result;
    }

    /**
     * Mapeo PURO de un producto de Platzi a un registro de staging. Sin DML ni
     * SOQL: solo traduce campos, por eso es trivial de testear de forma aislada.
     *
     * Mapeo (según la tarea):
     *   id            → External_Id__c        (Integer → Text)
     *   'Platzi'      → External_Source__c
     *   title         → External_Title__c
     *   description   → External_Description__c
     *   price         → External_Price__c
     *   images[0]     → External_Image_URL__c
     *   category.name → External_Category_Name__c
     *   'Imported'    → Sync_Status__c
     *   System.now()  → Last_Sync_Date__c
     */
    @TestVisible
    private static External_Product__c mapToExternalProduct(
        LvlupPlatziProductService.PlatziProduct product
    ) {
        External_Product__c record = new External_Product__c();
        // El id de Platzi es numérico; el campo staging es Text → convertir.
        record.External_Id__c = product.id != null ? String.valueOf(product.id) : null;
        record.External_Source__c = SOURCE_PLATZI;
        record.External_Title__c = truncate(product.title, MAX_TEXT_LENGTH);
        record.External_Description__c = product.description; // Long Text Area, sin recorte
        record.External_Price__c = product.price;
        record.External_Image_URL__c = firstImageUrl(product.images);
        record.External_Category_Name__c = product.category != null
            ? truncate(product.category.name, MAX_TEXT_LENGTH)
            : null;
        record.Sync_Status__c = STATUS_IMPORTED;
        record.Last_Sync_Date__c = System.now();
        return record;
    }

    /**
     * Devuelve la primera URL de imagen utilizable. Null-safe: si no hay imágenes
     * o la URL excede el máximo del campo URL (255), devuelve null en lugar de
     * romper el upsert con un valor inválido o demasiado largo.
     */
    private static String firstImageUrl(List<String> images) {
        if (images == null || images.isEmpty()) {
            return null;
        }
        String url = images[0];
        if (String.isBlank(url) || url.length() > MAX_URL_LENGTH) {
            return null;
        }
        return url;
    }

    /**
     * Recorta un texto a una longitud máxima para no exceder el tamaño del campo.
     * Null-safe.
     */
    private static String truncate(String value, Integer maxLength) {
        if (String.isBlank(value)) {
            return value;
        }
        return value.length() > maxLength ? value.left(maxLength) : value;
    }
}
