/**
 * ============================================================================
 *  LvlupPlatziPipelineQueueableTest
 * ============================================================================
 *  Verifica que el Queueable, al ejecutarse, dispara el pipeline completo
 *  (incluido el callout, mockeado). El job encolado corre en Test.stopTest().
 * ============================================================================
 */
@isTest
private class LvlupPlatziPipelineQueueableTest {
    private class PlatziMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            response.setBody(
                '[{"id":31,"title":"Q1","price":9.99,"description":"d",' +
                '"images":["https://example.com/q1.jpg"],' +
                '"category":{"id":5,"name":"Cat","image":"https://example.com/c.jpg"}}]'
            );
            return response;
        }
    }

    @isTest
    static void enqueueRunsPipeline() {
        ProductCatalog catalog = new ProductCatalog(Name = 'Test Catalog Q');
        insert catalog;
        insert new ProductCategory(Name = 'Productos de Platzi', CatalogId = catalog.Id);

        Test.setMock(HttpCalloutMock.class, new PlatziMock());

        Test.startTest();
        System.enqueueJob(new LvlupPlatziPipelineQueueable());
        Test.stopTest(); // ejecuta el Queueable encolado

        System.assertEquals(
            1,
            [SELECT COUNT() FROM Product2 WHERE Is_External_Product__c = true],
            'El Queueable creó el producto vía el pipeline'
        );
    }
}
