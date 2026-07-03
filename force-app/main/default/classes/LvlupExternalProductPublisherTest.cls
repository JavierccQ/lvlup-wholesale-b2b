/**
 * ============================================================================
 *  LvlupExternalProductPublisherTest
 * ============================================================================
 *  Cubre el modo upsert: creación (con SKU + inventario + reglas), actualización
 *  de productos ya enlazados, criterio de selección (Published/Error se omiten),
 *  manejo de error por DML parcial y el caso "no hay nada que publicar".
 * ============================================================================
 */
@isTest
private class LvlupExternalProductPublisherTest {
    /** Helper: staging de Platzi en estado Imported (sin Product2 asociado). */
    private static External_Product__c buildImported(String externalId, String title) {
        return new External_Product__c(
            External_Id__c = externalId,
            External_Source__c = 'Platzi',
            External_Title__c = title,
            External_Description__c = 'Desc ' + externalId,
            Sync_Status__c = 'Imported'
        );
    }

    @isTest
    static void createsNewProductsWithSkuAndInventory() {
        insert new List<External_Product__c>{
            buildImported('101', 'Silla Gamer Pro'),
            buildImported('102', 'Silla Gamer Elite')
        };

        Test.startTest();
        LvlupExternalProductPublisher.PublishResult result =
            LvlupExternalProductPublisher.publishImportedProducts();
        Test.stopTest();

        System.assertEquals(2, result.totalProcessed, 'Dos staging procesados');
        System.assertEquals(2, result.createdCount, 'Dos Product2 creados');
        System.assertEquals(0, result.updatedCount, 'Ninguna actualización');
        System.assertEquals(0, result.errorCount, 'Sin errores');

        Map<String, Product2> byCode = new Map<String, Product2>();
        for (Product2 p : [
            SELECT Name, ProductCode, StockKeepingUnit, IsActive, Is_External_Product__c,
                   External_Source__c, External_Product_Id__c, Inventory_Quantity__c,
                   Min_Order_Quantity__c, Order_Increment__c, Max_Order_Quantity__c
            FROM Product2
        ]) {
            byCode.put(p.ProductCode, p);
        }
        System.assertEquals(2, byCode.size(), 'Deben existir 2 productos');

        Product2 first = byCode.get('EXT-PLATZI-101');
        System.assertNotEquals(null, first, 'ProductCode esperado EXT-PLATZI-101');
        System.assertEquals('Silla Gamer Pro', first.Name, 'Name <- External_Title__c');
        System.assertEquals('EXT-PLATZI-101', first.StockKeepingUnit, 'SKU = ProductCode');
        System.assertEquals(true, first.IsActive, 'IsActive = true');
        System.assertEquals(true, first.Is_External_Product__c, 'Is_External_Product__c = true');
        System.assertEquals('Platzi', first.External_Source__c, 'External_Source__c = Platzi');
        System.assertEquals('101', first.External_Product_Id__c, 'External_Product_Id__c <- External_Id__c');
        System.assertEquals(100, first.Inventory_Quantity__c, 'Inventario simulado por defecto');
        System.assertEquals(1, first.Min_Order_Quantity__c, 'MOQ por defecto');
        System.assertEquals(1, first.Order_Increment__c, 'Incremento por defecto');
        System.assertEquals(1000, first.Max_Order_Quantity__c, 'Máximo por defecto');

        for (External_Product__c ext : [
            SELECT Sync_Status__c, Salesforce_Product__c, Last_Error__c FROM External_Product__c
        ]) {
            System.assertEquals('Published', ext.Sync_Status__c, 'Staging queda Published');
            System.assertNotEquals(null, ext.Salesforce_Product__c, 'Lookup informado');
            System.assertEquals(null, ext.Last_Error__c, 'Sin error');
        }
    }

    @isTest
    static void updatesExistingLinkedProducts() {
        // Producto ya existente con inventario/SKU propios.
        Product2 existing = new Product2(
            Name = 'Titulo viejo',
            Description = 'Desc vieja',
            ProductCode = 'EXT-PLATZI-201',
            StockKeepingUnit = 'EXT-PLATZI-201',
            IsActive = true,
            Is_External_Product__c = true,
            External_Source__c = 'Platzi',
            External_Product_Id__c = '201',
            Inventory_Quantity__c = 55
        );
        insert existing;

        // Staging Imported, YA enlazado, con título/descr nuevos (cambio en Platzi).
        External_Product__c ext = buildImported('201', 'Titulo nuevo');
        ext.External_Description__c = 'Desc nueva';
        ext.Salesforce_Product__c = existing.Id;
        insert ext;

        Test.startTest();
        LvlupExternalProductPublisher.PublishResult result =
            LvlupExternalProductPublisher.publishImportedProducts();
        Test.stopTest();

        System.assertEquals(1, result.totalProcessed, 'Un staging procesado');
        System.assertEquals(0, result.createdCount, 'Nada creado');
        System.assertEquals(1, result.updatedCount, 'Un producto actualizado');
        System.assertEquals(0, result.errorCount, 'Sin errores');

        Product2 updated = [
            SELECT Name, Description, StockKeepingUnit, Inventory_Quantity__c
            FROM Product2 WHERE Id = :existing.Id
        ];
        System.assertEquals('Titulo nuevo', updated.Name, 'Name actualizado desde Platzi');
        System.assertEquals('Desc nueva', updated.Description, 'Description actualizada');
        System.assertEquals('EXT-PLATZI-201', updated.StockKeepingUnit, 'SKU se preserva');
        System.assertEquals(55, updated.Inventory_Quantity__c, 'Inventario propio se preserva');

        External_Product__c reloaded = [SELECT Sync_Status__c FROM External_Product__c WHERE Id = :ext.Id];
        System.assertEquals('Published', reloaded.Sync_Status__c, 'Staging vuelve a Published');
    }

    @isTest
    static void skipsPublishedAndErrorStaging() {
        External_Product__c importable = buildImported('301', 'Procesable');

        External_Product__c published = buildImported('302', 'Ya publicado');
        published.Sync_Status__c = 'Published';

        External_Product__c errored = buildImported('303', 'Con error previo');
        errored.Sync_Status__c = 'Error';

        insert new List<External_Product__c>{ importable, published, errored };

        Test.startTest();
        LvlupExternalProductPublisher.PublishResult result =
            LvlupExternalProductPublisher.publishImportedProducts();
        Test.stopTest();

        System.assertEquals(1, result.totalProcessed, 'Solo el Imported es elegible');
        System.assertEquals(1, result.createdCount, 'Solo 1 creado');
        System.assertEquals(
            1,
            [SELECT COUNT() FROM Product2 WHERE ProductCode = 'EXT-PLATZI-301'],
            'Solo el producto del Imported'
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Product2 WHERE ProductCode IN ('EXT-PLATZI-302', 'EXT-PLATZI-303')],
            'Published/Error no se procesan'
        );
    }

    @isTest
    static void marksErrorWhenProductInsertFails() {
        External_Product__c valid = buildImported('401', 'Producto valido');
        External_Product__c invalid = buildImported('402', null); // Name nulo -> Product2 inválido
        insert new List<External_Product__c>{ valid, invalid };

        Test.startTest();
        LvlupExternalProductPublisher.PublishResult result =
            LvlupExternalProductPublisher.publishImportedProducts();
        Test.stopTest();

        System.assertEquals(2, result.totalProcessed, 'Ambos se procesan');
        System.assertEquals(1, result.createdCount, 'Solo el válido se crea');
        System.assertEquals(1, result.errorCount, 'El inválido cuenta como error');

        External_Product__c errored = [
            SELECT Sync_Status__c, Salesforce_Product__c, Last_Error__c
            FROM External_Product__c WHERE External_Id__c = '402' LIMIT 1
        ];
        System.assertEquals('Error', errored.Sync_Status__c, 'El fallido queda en Error');
        System.assertEquals(null, errored.Salesforce_Product__c, 'Sin Product2 asociado');
        System.assertNotEquals(null, errored.Last_Error__c, 'Registra el mensaje de error');
    }

    @isTest
    static void returnsZeroWhenNothingToPublish() {
        Test.startTest();
        LvlupExternalProductPublisher.PublishResult result =
            LvlupExternalProductPublisher.publishImportedProducts();
        Test.stopTest();

        System.assertEquals(0, result.totalProcessed, 'Nada que procesar');
        System.assertEquals(0, result.createdCount, 'Nada creado');
        System.assertEquals(0, result.updatedCount, 'Nada actualizado');
    }
}
