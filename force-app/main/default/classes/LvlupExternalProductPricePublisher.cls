/**
 * ============================================================================
 *  LvlupExternalProductPricePublisher  (capa de PRICING staging -> PricebookEntry)
 * ============================================================================
 *  Responsabilidad ÚNICA: dar/actualizar precio a los Product2 publicados desde
 *  Platzi, gestionando sus PricebookEntry. El precio sale de
 *  External_Product__c.External_Price__c.
 *
 *  Gestiona DOS price books, igual que los productos internos:
 *    1) Standard Price Book  -> prerequisito OBLIGATORIO de la plataforma.
 *    2) Price book de venta de la WebStore (descubierto vía WebStorePricebook).
 *
 *  Sincronización completa (idempotente):
 *    - crea la PricebookEntry que falte, y
 *    - ACTUALIZA el UnitPrice cuando el precio de Platzi cambió.
 *  Re-ejecutar no duplica (PricebookEntry es única por Product2 + Pricebook2).
 * ============================================================================
 */
public with sharing class LvlupExternalProductPricePublisher {
    private static final String SOURCE_PLATZI = 'Platzi';
    private static final String STATUS_PUBLISHED = 'Published';

    /** Resumen del resultado del pricing. */
    public class PriceResult {
        public Integer totalProducts = 0;
        public Integer standardEntriesCreated = 0;
        public Integer storeEntriesCreated = 0;
        public Integer pricesUpdated = 0;
        public Integer errorCount = 0;
    }

    /**
     * Entrada principal: descubre el price book de venta de la WebStore y
     * crea/actualiza las PricebookEntry de los productos externos publicados.
     */
    public static PriceResult publishPrices() {
        return publishPrices(resolveStorePricebookId());
    }

    /**
     * Core testeable: gestiona las entradas en el Standard Price Book y, si se
     * indica, en el price book de venta `storePricebookId`.
     *
     * @param storePricebookId price book de venta (null -> solo estándar).
     * @return resumen con totales por price book, actualizaciones y errores.
     */
    public static PriceResult publishPrices(Id storePricebookId) {
        PriceResult result = new PriceResult();

        // 1) Precio por producto desde el staging publicado y enlazado.
        Map<Id, Decimal> priceByProductId = new Map<Id, Decimal>();
        for (External_Product__c ext : [
            SELECT Salesforce_Product__c, External_Price__c
            FROM External_Product__c
            WHERE Sync_Status__c = :STATUS_PUBLISHED
              AND External_Source__c = :SOURCE_PLATZI
              AND Salesforce_Product__c != null
              AND External_Price__c != null
        ]) {
            priceByProductId.put(ext.Salesforce_Product__c, ext.External_Price__c);
        }
        if (priceByProductId.isEmpty()) {
            return result;
        }
        result.totalProducts = priceByProductId.size();

        Id standardPricebookId = getStandardPricebookId();

        // 2) PBE ya existentes (con Id y precio actual) para decidir insert/update.
        Set<Id> targetPricebookIds = new Set<Id>{ standardPricebookId };
        if (storePricebookId != null) {
            targetPricebookIds.add(storePricebookId);
        }
        Set<Id> productsWithStandard = new Set<Id>();
        Map<String, PricebookEntry> existingByKey = new Map<String, PricebookEntry>();
        for (PricebookEntry pbe : [
            SELECT Id, Product2Id, Pricebook2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id IN :priceByProductId.keySet()
              AND Pricebook2Id IN :targetPricebookIds
        ]) {
            existingByKey.put(keyOf(pbe.Product2Id, pbe.Pricebook2Id), pbe);
            if (pbe.Pricebook2Id == standardPricebookId) {
                productsWithStandard.add(pbe.Product2Id);
            }
        }

        // Acumulador de actualizaciones de precio (estándar + venta).
        List<PricebookEntry> toUpdate = new List<PricebookEntry>();

        // 3) Standard primero: crear la que falte o actualizar si cambió el precio.
        List<PricebookEntry> standardToInsert = new List<PricebookEntry>();
        List<Id> standardOrder = new List<Id>();
        for (Id productId : priceByProductId.keySet()) {
            Decimal price = priceByProductId.get(productId);
            PricebookEntry existing = existingByKey.get(keyOf(productId, standardPricebookId));
            if (existing == null) {
                standardToInsert.add(buildEntry(standardPricebookId, productId, price));
                standardOrder.add(productId);
            } else if (existing.UnitPrice != price) {
                toUpdate.add(new PricebookEntry(Id = existing.Id, UnitPrice = price));
            }
        }
        if (!standardToInsert.isEmpty()) {
            List<Database.SaveResult> saveResults = Database.insert(standardToInsert, false);
            for (Integer i = 0; i < saveResults.size(); i++) {
                if (saveResults[i].isSuccess()) {
                    productsWithStandard.add(standardOrder[i]);
                    result.standardEntriesCreated++;
                } else {
                    result.errorCount++;
                }
            }
        }

        // 4) Price book de la store: crear/actualizar para productos con estándar.
        if (storePricebookId != null && storePricebookId != standardPricebookId) {
            List<PricebookEntry> storeToInsert = new List<PricebookEntry>();
            for (Id productId : priceByProductId.keySet()) {
                if (!productsWithStandard.contains(productId)) {
                    continue; // sin estándar no puede tener entrada de venta
                }
                Decimal price = priceByProductId.get(productId);
                PricebookEntry existing = existingByKey.get(keyOf(productId, storePricebookId));
                if (existing == null) {
                    storeToInsert.add(buildEntry(storePricebookId, productId, price));
                } else if (existing.UnitPrice != price) {
                    toUpdate.add(new PricebookEntry(Id = existing.Id, UnitPrice = price));
                }
            }
            if (!storeToInsert.isEmpty()) {
                List<Database.SaveResult> saveResults = Database.insert(storeToInsert, false);
                for (Database.SaveResult sr : saveResults) {
                    if (sr.isSuccess()) {
                        result.storeEntriesCreated++;
                    } else {
                        result.errorCount++;
                    }
                }
            }
        }

        // 5) Aplicar las actualizaciones de precio (update parcial).
        if (!toUpdate.isEmpty()) {
            List<Database.SaveResult> updateResults = Database.update(toUpdate, false);
            for (Database.SaveResult sr : updateResults) {
                if (sr.isSuccess()) {
                    result.pricesUpdated++;
                } else {
                    result.errorCount++;
                }
            }
        }

        return result;
    }

    private static PricebookEntry buildEntry(Id pricebookId, Id productId, Decimal price) {
        return new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productId,
            UnitPrice = price,
            IsActive = true
        );
    }

    private static String keyOf(Id productId, Id pricebookId) {
        return productId + '|' + pricebookId;
    }

    /**
     * Id del Standard Price Book. En tests se usa Test.getStandardPricebookId()
     * (la plataforma no permite insertar PBE estándar de otra forma en pruebas).
     */
    private static Id getStandardPricebookId() {
        if (Test.isRunningTest()) {
            return Test.getStandardPricebookId();
        }
        for (Pricebook2 pb : [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1]) {
            return pb.Id;
        }
        return null;
    }

    /** Price book de venta asociado a la WebStore activa (descubrimiento dinámico). */
    private static Id resolveStorePricebookId() {
        for (WebStorePricebook wsp : [
            SELECT Pricebook2Id
            FROM WebStorePricebook
            WHERE IsActive = true
            LIMIT 1
        ]) {
            return wsp.Pricebook2Id;
        }
        return null;
    }
}
