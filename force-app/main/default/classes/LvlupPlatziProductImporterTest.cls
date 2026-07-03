/**
 * ============================================================================
 *  LvlupPlatziProductImporterTest  (pruebas del importador a staging)
 * ============================================================================
 *  Cubre tres frentes:
 *   1) Flujo completo (callout simulado → upsert) con HttpCalloutMock.
 *   2) Mapeo PURO en memoria, incluyendo null-safety (sin imágenes/categoría).
 *   3) Idempotencia: reimportar el mismo External Id ACTUALIZA, no duplica.
 *
 *  Nunca toca la API real: los productos se simulan con un mock o se construyen
 *  a mano en memoria.
 * ============================================================================
 */
@isTest
private class LvlupPlatziProductImporterTest {
    /**
     * Mock HTTP reutilizable: devuelve el status y body que le indiquemos.
     * Permite probar `importFirstTenProducts()` (que internamente hace callout)
     * sin depender de Platzi.
     */
    private class PlatziHttpMock implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        private PlatziHttpMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(this.statusCode);
            response.setBody(this.body);
            return response;
        }
    }

    /** Array directo con 2 productos, imitando la forma real de Platzi. */
    private static String buildSuccessBody() {
        return '[' +
            '{' +
                '"id":101,' +
                '"title":"Silla Gamer Pro",' +
                '"price":299.99,' +
                '"description":"Silla ergonomica para largas sesiones",' +
                '"images":["https://example.com/silla-a.jpg","https://example.com/silla-b.jpg"],' +
                '"category":{"id":5,"name":"Furniture","image":"https://example.com/cat.jpg"}' +
            '},' +
            '{' +
                '"id":102,' +
                '"title":"Silla Gamer Elite",' +
                '"price":399.50,' +
                '"description":"Silla premium con soporte lumbar",' +
                '"images":["https://example.com/silla-c.jpg"],' +
                '"category":{"id":5,"name":"Furniture","image":"https://example.com/cat.jpg"}' +
            '}' +
        ']';
    }

    /** Helper para construir un PlatziProduct en memoria (sin callout). */
    private static LvlupPlatziProductService.PlatziProduct buildProduct(
        Integer id,
        String title,
        Decimal price,
        List<String> images,
        String categoryName
    ) {
        LvlupPlatziProductService.PlatziProduct product =
            new LvlupPlatziProductService.PlatziProduct();
        product.id = id;
        product.title = title;
        product.description = 'Descripcion de ' + title;
        product.price = price;
        product.images = images;
        if (categoryName != null) {
            LvlupPlatziProductService.PlatziCategory category =
                new LvlupPlatziProductService.PlatziCategory();
            category.id = 5;
            category.name = categoryName;
            category.image = 'https://example.com/cat.jpg';
            product.category = category;
        }
        return product;
    }

    @isTest
    static void importFirstTenProductsUpsertsFromCallout() {
        // ── ARRANGE ─────────────────────────────────────────────────────────
        Test.setMock(HttpCalloutMock.class, new PlatziHttpMock(200, buildSuccessBody()));

        // ── ACT ─────────────────────────────────────────────────────────────
        Test.startTest();
        LvlupPlatziProductImporter.ImportResult result =
            LvlupPlatziProductImporter.importFirstTenProducts();
        Test.stopTest();

        // ── ASSERT: resumen ─────────────────────────────────────────────────
        System.assertEquals(2, result.totalProcessed, 'Deben procesarse 2 productos');
        System.assertEquals(2, result.createdCount, 'Ambos son nuevos -> creados');
        System.assertEquals(0, result.updatedCount, 'Ninguno deberia actualizarse');

        // ── ASSERT: persistencia y mapeo ────────────────────────────────────
        Map<String, External_Product__c> byExternalId = new Map<String, External_Product__c>();
        for (External_Product__c record : [
            SELECT External_Id__c, External_Source__c, External_Title__c,
                   External_Description__c, External_Price__c, External_Image_URL__c,
                   External_Category_Name__c, Sync_Status__c, Last_Sync_Date__c
            FROM External_Product__c
        ]) {
            byExternalId.put(record.External_Id__c, record);
        }

        System.assertEquals(2, byExternalId.size(), 'Deben existir 2 registros en staging');

        External_Product__c first = byExternalId.get('101');
        System.assertNotEquals(null, first, 'El producto 101 debe haberse creado');
        System.assertEquals('Platzi', first.External_Source__c, 'Source fijo = Platzi');
        System.assertEquals('Silla Gamer Pro', first.External_Title__c, 'title -> External_Title__c');
        System.assertEquals(299.99, first.External_Price__c, 'price -> External_Price__c');
        System.assertEquals(
            'https://example.com/silla-a.jpg',
            first.External_Image_URL__c,
            'images[0] -> External_Image_URL__c'
        );
        System.assertEquals('Furniture', first.External_Category_Name__c, 'category.name -> campo');
        System.assertEquals('Imported', first.Sync_Status__c, 'Sync Status fijo = Imported');
        System.assertNotEquals(null, first.Last_Sync_Date__c, 'Last Sync Date debe setearse');
    }

    @isTest
    static void mapsFieldsAndIsNullSafe() {
        // Producto SIN imágenes y SIN categoría: el mapeo no debe romper.
        LvlupPlatziProductService.PlatziProduct noImageNoCategory =
            buildProduct(201, 'Producto sin extras', 10.00, null, null);

        // Producto normal con imágenes y categoría.
        LvlupPlatziProductService.PlatziProduct full = buildProduct(
            202,
            'Producto completo',
            25.50,
            new List<String>{ 'https://example.com/x.jpg' },
            'Electronics'
        );

        Test.startTest();
        LvlupPlatziProductImporter.ImportResult result =
            LvlupPlatziProductImporter.importProducts(
                new List<LvlupPlatziProductService.PlatziProduct>{ noImageNoCategory, full }
            );
        Test.stopTest();

        System.assertEquals(2, result.createdCount, 'Ambos productos creados');

        External_Product__c sinExtras = [
            SELECT External_Image_URL__c, External_Category_Name__c, Sync_Status__c
            FROM External_Product__c
            WHERE External_Id__c = '201'
            LIMIT 1
        ];
        System.assertEquals(null, sinExtras.External_Image_URL__c, 'Sin imagenes -> URL null');
        System.assertEquals(null, sinExtras.External_Category_Name__c, 'Sin categoria -> null');
        System.assertEquals('Imported', sinExtras.Sync_Status__c, 'Estado por defecto Imported');
    }

    @isTest
    static void reimportUpdatesInsteadOfDuplicating() {
        List<LvlupPlatziProductService.PlatziProduct> products =
            new List<LvlupPlatziProductService.PlatziProduct>{
                buildProduct(301, 'Titulo original', 50.00,
                    new List<String>{ 'https://example.com/o.jpg' }, 'Furniture')
            };

        Test.startTest();
        // Primera importación: crea.
        LvlupPlatziProductImporter.ImportResult firstRun =
            LvlupPlatziProductImporter.importProducts(products);

        // Cambiamos el título y reimportamos el MISMO External Id: debe actualizar.
        products[0].title = 'Titulo actualizado';
        LvlupPlatziProductImporter.ImportResult secondRun =
            LvlupPlatziProductImporter.importProducts(products);
        Test.stopTest();

        System.assertEquals(1, firstRun.createdCount, 'Primera pasada crea 1');
        System.assertEquals(0, secondRun.createdCount, 'Segunda pasada no crea');
        System.assertEquals(1, secondRun.updatedCount, 'Segunda pasada actualiza 1');

        List<External_Product__c> records = [
            SELECT External_Title__c FROM External_Product__c WHERE External_Id__c = '301'
        ];
        System.assertEquals(1, records.size(), 'No debe haber duplicados por External Id');
        System.assertEquals(
            'Titulo actualizado',
            records[0].External_Title__c,
            'El registro debe reflejar el valor actualizado'
        );
    }

    @isTest
    static void handlesEmptyListAndOversizedValues() {
        // Lista vacía: no hace DML y devuelve un resumen en cero.
        LvlupPlatziProductImporter.ImportResult empty =
            LvlupPlatziProductImporter.importProducts(
                new List<LvlupPlatziProductService.PlatziProduct>()
            );
        System.assertEquals(0, empty.totalProcessed, 'Lista vacia -> nada que procesar');

        // Título de 300 chars (> 255) y URL de 300 chars (> 255): el primero se
        // recorta a 255; la URL demasiado larga se descarta (queda null).
        String longTitle = 'T'.repeat(300);
        String longUrl = 'https://example.com/' + 'a'.repeat(300);
        LvlupPlatziProductService.PlatziProduct oversized = buildProduct(
            401,
            longTitle,
            5.00,
            new List<String>{ longUrl },
            null
        );

        Test.startTest();
        LvlupPlatziProductImporter.importProducts(
            new List<LvlupPlatziProductService.PlatziProduct>{ oversized }
        );
        Test.stopTest();

        External_Product__c stored = [
            SELECT External_Title__c, External_Image_URL__c
            FROM External_Product__c
            WHERE External_Id__c = '401'
            LIMIT 1
        ];
        System.assertEquals(255, stored.External_Title__c.length(), 'El titulo se recorta a 255');
        System.assertEquals(null, stored.External_Image_URL__c, 'URL > 255 se descarta');
    }
}
