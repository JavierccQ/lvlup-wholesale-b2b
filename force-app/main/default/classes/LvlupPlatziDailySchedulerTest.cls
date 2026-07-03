/**
 * ============================================================================
 *  LvlupPlatziDailySchedulerTest
 * ============================================================================
 *  Verifica que el Scheduler encola el pipeline (su execute dispara el Queueable,
 *  que corre en Test.stopTest) y que puede programarse con System.schedule.
 * ============================================================================
 */
@isTest
private class LvlupPlatziDailySchedulerTest {
    private class PlatziMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            response.setBody(
                '[{"id":41,"title":"S1","price":15.00,"description":"d",' +
                '"images":["https://example.com/s1.jpg"],' +
                '"category":{"id":5,"name":"Cat","image":"https://example.com/c.jpg"}}]'
            );
            return response;
        }
    }

    @isTest
    static void executeEnqueuesPipeline() {
        ProductCatalog catalog = new ProductCatalog(Name = 'Test Catalog S');
        insert catalog;
        insert new ProductCategory(Name = 'Productos de Platzi', CatalogId = catalog.Id);

        Test.setMock(HttpCalloutMock.class, new PlatziMock());

        Test.startTest();
        new LvlupPlatziDailyScheduler().execute(null); // encola el Queueable
        Test.stopTest(); // ejecuta el Queueable encolado

        System.assertEquals(
            1,
            [SELECT COUNT() FROM Product2 WHERE Is_External_Product__c = true],
            'El Scheduler disparó el pipeline vía el Queueable'
        );
    }

    @isTest
    static void canBeScheduledWithCron() {
        Test.setMock(HttpCalloutMock.class, new PlatziMock());

        Test.startTest();
        String jobId = System.schedule(
            'LvlUp Platzi Daily Import TEST',
            '0 0 3 * * ?',
            new LvlupPlatziDailyScheduler()
        );
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Se programó el job');
        System.assertEquals(
            1,
            [SELECT COUNT() FROM CronTrigger WHERE Id = :jobId],
            'Existe el CronTrigger programado'
        );
    }
}
