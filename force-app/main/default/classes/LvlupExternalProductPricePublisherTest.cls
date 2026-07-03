/**
 * ============================================================================
 *  LvlupExternalProductPricePublisherTest
 * ============================================================================
 *  Cubre: creación en Standard + price book de venta, idempotencia, criterio de
 *  selección (solo Published/enlazado/con precio) y la entrada no-arg (descubre
 *  el price book de la store; en test no hay WebStorePricebook -> solo estándar).
 *
 *  El price book de venta se simula con un Pricebook2 custom inyectado al método
 *  core, de modo que no dependemos de objetos de setup de Commerce en pruebas.
 * ============================================================================
 */
@isTest
private class LvlupExternalProductPricePublisherTest {
    /** Crea un Product2 externo y su staging Published+enlazado con precio. */
    private static Product2 buildPublishedExternal(String externalId, Decimal price) {
        Product2 product = new Product2(
            Name = 'Ext ' + externalId,
            ProductCode = 'EXT-PLATZI-' + externalId,
            IsActive = true,
            Is_External_Product__c = true,
            External_Source__c = 'Platzi',
            External_Product_Id__c = externalId
        );
        insert product;

        External_Product__c ext = new External_Product__c(
            External_Id__c = externalId,
            External_Source__c = 'Platzi',
            External_Title__c = 'Ext ' + externalId,
            External_Price__c = price,
            Sync_Status__c = 'Published',
            Salesforce_Product__c = product.Id
        );
        insert ext;
        return product;
    }

    private static Pricebook2 buildStorePricebook() {
        Pricebook2 storePb = new Pricebook2(Name = 'Test Store Price Book', IsActive = true);
        insert storePb;
        return storePb;
    }

    @isTest
    static void createsStandardAndStoreEntries() {
        Id standardPricebookId = Test.getStandardPricebookId();
        Pricebook2 storePb = buildStorePricebook();
        Product2 product = buildPublishedExternal('501', 199.99);

        Test.startTest();
        LvlupExternalProductPricePublisher.PriceResult result =
            LvlupExternalProductPricePublisher.publishPrices(storePb.Id);
        Test.stopTest();

        System.assertEquals(1, result.totalProducts, 'Un producto elegible');
        System.assertEquals(1, result.standardEntriesCreated, 'Una entrada estándar');
        System.assertEquals(1, result.storeEntriesCreated, 'Una entrada en la store');
        System.assertEquals(0, result.errorCount, 'Sin errores');

        Map<Id, PricebookEntry> byPricebook = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : [
            SELECT Pricebook2Id, UnitPrice, IsActive
            FROM PricebookEntry
            WHERE Product2Id = :product.Id
        ]) {
            byPricebook.put(pbe.Pricebook2Id, pbe);
        }
        System.assertEquals(2, byPricebook.size(), 'Estándar + store');
        System.assertEquals(199.99, byPricebook.get(standardPricebookId).UnitPrice, 'Precio estándar');
        System.assertEquals(199.99, byPricebook.get(storePb.Id).UnitPrice, 'Precio de venta');
        System.assertEquals(true, byPricebook.get(storePb.Id).IsActive, 'Entrada de venta activa');
    }

    @isTest
    static void isIdempotentOnReRun() {
        Pricebook2 storePb = buildStorePricebook();
        Product2 product = buildPublishedExternal('502', 49.50);

        Test.startTest();
        LvlupExternalProductPricePublisher.publishPrices(storePb.Id); // primera pasada: crea
        LvlupExternalProductPricePublisher.PriceResult second =
            LvlupExternalProductPricePublisher.publishPrices(storePb.Id); // segunda: no debe duplicar
        Test.stopTest();

        System.assertEquals(1, second.totalProducts, 'Sigue habiendo un producto elegible');
        System.assertEquals(0, second.standardEntriesCreated, 'No recrea la estándar');
        System.assertEquals(0, second.storeEntriesCreated, 'No recrea la de venta');
        System.assertEquals(
            2,
            [SELECT COUNT() FROM PricebookEntry WHERE Product2Id = :product.Id],
            'Solo deben existir 2 entradas (estándar + venta)'
        );
    }

    @isTest
    static void updatesPriceWhenChanged() {
        Pricebook2 storePb = buildStorePricebook();
        Product2 product = buildPublishedExternal('505', 50.00);

        Test.startTest();
        LvlupExternalProductPricePublisher.publishPrices(storePb.Id); // crea a 50

        // Cambia el precio en el staging (simula cambio en Platzi) y re-sincroniza.
        External_Product__c ext = [
            SELECT Id FROM External_Product__c WHERE Salesforce_Product__c = :product.Id LIMIT 1
        ];
        ext.External_Price__c = 75.00;
        update ext;

        LvlupExternalProductPricePublisher.PriceResult second =
            LvlupExternalProductPricePublisher.publishPrices(storePb.Id);
        Test.stopTest();

        System.assertEquals(0, second.standardEntriesCreated, 'No crea, ya existían');
        System.assertEquals(0, second.storeEntriesCreated, 'No crea, ya existían');
        System.assertEquals(2, second.pricesUpdated, 'Actualiza estándar + venta');
        System.assertEquals(0, second.errorCount, 'Sin errores');

        for (PricebookEntry pbe : [SELECT UnitPrice FROM PricebookEntry WHERE Product2Id = :product.Id]) {
            System.assertEquals(75.00, pbe.UnitPrice, 'Precio actualizado a 75');
        }
    }

    @isTest
    static void skipsIneligibleStaging() {
        Pricebook2 storePb = buildStorePricebook();

        // Publicado y enlazado pero SIN precio.
        Product2 noPriceProduct = new Product2(Name = 'No Price', IsActive = true);
        insert noPriceProduct;
        External_Product__c noPrice = new External_Product__c(
            External_Id__c = '601',
            External_Source__c = 'Platzi',
            External_Title__c = 'No Price',
            Sync_Status__c = 'Published',
            Salesforce_Product__c = noPriceProduct.Id
        );
        // Importado (aún no publicado), con precio.
        Product2 importedProduct = new Product2(Name = 'Imported', IsActive = true);
        insert importedProduct;
        External_Product__c imported = new External_Product__c(
            External_Id__c = '602',
            External_Source__c = 'Platzi',
            External_Title__c = 'Imported',
            External_Price__c = 10,
            Sync_Status__c = 'Imported',
            Salesforce_Product__c = importedProduct.Id
        );
        insert new List<External_Product__c>{ noPrice, imported };

        Test.startTest();
        LvlupExternalProductPricePublisher.PriceResult result =
            LvlupExternalProductPricePublisher.publishPrices(storePb.Id);
        Test.stopTest();

        System.assertEquals(0, result.totalProducts, 'Ninguno elegible');
        System.assertEquals(0, [SELECT COUNT() FROM PricebookEntry], 'No se crean entradas');
    }

    @isTest
    static void noArgResolvesStoreAndCreatesStandard() {
        // En test no hay WebStorePricebook -> resolveStorePricebookId() = null,
        // así que solo se crea la entrada estándar.
        Product2 product = buildPublishedExternal('701', 12.34);

        Test.startTest();
        LvlupExternalProductPricePublisher.PriceResult result =
            LvlupExternalProductPricePublisher.publishPrices();
        Test.stopTest();

        System.assertEquals(1, result.totalProducts, 'Un producto elegible');
        System.assertEquals(1, result.standardEntriesCreated, 'Crea la estándar');
        System.assertEquals(0, result.storeEntriesCreated, 'Sin WebStorePricebook -> sin entrada de venta');
        System.assertEquals(0, result.errorCount, 'Sin errores');
        System.assertEquals(
            1,
            [SELECT COUNT() FROM PricebookEntry WHERE Product2Id = :product.Id],
            'Solo la entrada estándar'
        );
    }
}
