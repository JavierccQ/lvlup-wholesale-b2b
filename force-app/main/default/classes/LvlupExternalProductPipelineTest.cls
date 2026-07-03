/**
 * ============================================================================
 *  LvlupExternalProductPipelineTest
 * ============================================================================
 *  Verifica el encadenamiento completo (import con callout simulado -> publish
 *  -> categoría -> precios) en una sola transacción. Crea la categoría destino
 *  y mockea la respuesta de Platzi; no depende de la API real.
 * ============================================================================
 */
@isTest
private class LvlupExternalProductPipelineTest {
    private class PlatziMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            response.setBody(
                '[' +
                    '{"id":11,"title":"Producto Uno","price":10.00,"description":"d1",' +
                    '"images":["https://example.com/1.jpg"],' +
                    '"category":{"id":5,"name":"Cat","image":"https://example.com/c.jpg"}},' +
                    '{"id":12,"title":"Producto Dos","price":20.00,"description":"d2",' +
                    '"images":["https://example.com/2.jpg"],' +
                    '"category":{"id":5,"name":"Cat","image":"https://example.com/c.jpg"}}' +
                ']'
            );
            return response;
        }
    }

    @isTest
    static void runsFullPipelineEndToEnd() {
        // Categoría destino para el paso de asignación.
        ProductCatalog catalog = new ProductCatalog(Name = 'Test Catalog Pipeline');
        insert catalog;
        insert new ProductCategory(Name = 'Productos de Platzi', CatalogId = catalog.Id);

        Test.setMock(HttpCalloutMock.class, new PlatziMock());

        Test.startTest();
        LvlupExternalProductPipeline.PipelineResult result =
            LvlupExternalProductPipeline.runFullPipeline();
        Test.stopTest();

        // Cada paso reporta su resultado.
        System.assertEquals(2, result.importResult.totalProcessed, 'Import: 2 staging');
        System.assertEquals(2, result.publishResult.createdCount, 'Publish: 2 Product2 creados');
        System.assertEquals(2, result.categoryResult.assignmentsCreated, 'Categoría: 2 asignados');
        System.assertEquals(2, result.priceResult.standardEntriesCreated, 'Precios: 2 estándar');
        // Sin imágenes importadas en CMS en el test, el paso 5 corre pero no casa nada.
        System.assertEquals(0, result.mediaResult.imagesMatched, 'Media: 0 casadas sin CMS');
        // Sin CommerceEntitlementBuyerGroup en el test, el paso 6 corre pero no entitla.
        System.assertEquals(0, result.entitlementResult.entitlementsCreated, 'Entitlement: 0 sin políticas');

        // Efectos persistidos.
        System.assertEquals(
            2,
            [SELECT COUNT() FROM Product2 WHERE Is_External_Product__c = true],
            'Deben existir 2 productos externos'
        );
        System.assertEquals(
            2,
            [SELECT COUNT() FROM External_Product__c WHERE Sync_Status__c = 'Published'],
            'Los 2 staging quedan Published'
        );
    }
}
