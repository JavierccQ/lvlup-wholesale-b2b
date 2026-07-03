/**
 * ============================================================================
 *  LvlupProductImageControllerTest
 * ============================================================================
 */
@isTest
private class LvlupProductImageControllerTest {
    private static Product2 buildExternalProduct(String sku) {
        Product2 product = new Product2(
            Name = 'Ext ' + sku,
            ProductCode = sku,
            StockKeepingUnit = sku,
            IsActive = true,
            Is_External_Product__c = true
        );
        insert product;
        return product;
    }

    @isTest
    static void returnsImageUrlBySku() {
        Product2 product = buildExternalProduct('EXT-PLATZI-999');
        insert new External_Product__c(
            External_Id__c = '999',
            External_Source__c = 'Platzi',
            External_Title__c = 'Ext',
            External_Image_URL__c = 'https://i.imgur.com/test.jpeg',
            Sync_Status__c = 'Published',
            Salesforce_Product__c = product.Id
        );

        Test.startTest();
        Map<String, String> result = LvlupProductImageController.getExternalImageUrls();
        Test.stopTest();

        System.assertEquals(
            'https://i.imgur.com/test.jpeg',
            result.get('EXT-PLATZI-999'),
            'Devuelve la URL externa indexada por SKU'
        );
    }

    @isTest
    static void ignoresIneligibleStaging() {
        Product2 product = buildExternalProduct('EXT-PLATZI-998');
        // Importado (no publicado) y sin imagen -> no debe aparecer.
        insert new External_Product__c(
            External_Id__c = '998',
            External_Source__c = 'Platzi',
            External_Title__c = 'Ext2',
            Sync_Status__c = 'Imported',
            Salesforce_Product__c = product.Id
        );

        Test.startTest();
        Map<String, String> result = LvlupProductImageController.getExternalImageUrls();
        Test.stopTest();

        System.assertEquals(false, result.containsKey('EXT-PLATZI-998'), 'No publicado/sin imagen -> excluido');
    }
}
