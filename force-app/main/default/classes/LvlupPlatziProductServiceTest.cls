/**
 * ============================================================================
 *  LvlupPlatziProductServiceTest  (pruebas de la capa de servicio HTTP)
 * ============================================================================
 *  Los tests Apex NO pueden hacer llamadas HTTP reales (Salesforce lo prohíbe).
 *  Por eso usamos un "mock": una clase que IMPLEMENTA HttpCalloutMock y devuelve
 *  una respuesta inventada. Así probamos nuestra lógica (deserialización, manejo
 *  de errores) SIN depender nunca de la API real de Platzi.
 *
 *  Se registra con Test.setMock(HttpCalloutMock.class, miMock) antes de la
 *  llamada bajo prueba.
 * ============================================================================
 */
@isTest
private class LvlupPlatziProductServiceTest {
    /**
     * Mock configurable: le pasamos el status code y el body que queremos que
     * "devuelva la API", y los reproduce. Un solo mock sirve para el caso de
     * éxito (200) y el de error (500).
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

    /**
     * Body de ejemplo: un ARRAY directo con 2 productos, imitando la forma real
     * de Platzi (incluye campos extra como creationAt/slug para verificar que
     * JSON.deserialize los ignora sin romper).
     */
    private static String buildSuccessBody() {
        return '[' +
            '{' +
                '"id":1,' +
                '"title":"Silla Gamer Pro",' +
                '"price":299.99,' +
                '"description":"Silla ergonomica para largas sesiones",' +
                '"images":["https://placeimg.com/640/480/any?1","https://placeimg.com/640/480/any?2"],' +
                '"category":{"id":5,"name":"Furniture","image":"https://placeimg.com/640/480/furniture"},' +
                '"slug":"silla-gamer-pro",' +
                '"creationAt":"2024-01-01T00:00:00.000Z"' +
            '},' +
            '{' +
                '"id":2,' +
                '"title":"Silla Gamer Elite",' +
                '"price":399.50,' +
                '"description":"Silla premium con soporte lumbar",' +
                '"images":["https://placeimg.com/640/480/any?3"],' +
                '"category":{"id":5,"name":"Furniture","image":"https://placeimg.com/640/480/furniture"}' +
            '}' +
        ']';
    }

    @isTest
    static void getFirstTenProductsReturnsTypedProductsOn200() {
        // ── ARRANGE ─────────────────────────────────────────────────────────
        Test.setMock(HttpCalloutMock.class, new PlatziHttpMock(200, buildSuccessBody()));

        // ── ACT ─────────────────────────────────────────────────────────────
        Test.startTest();
        List<LvlupPlatziProductService.PlatziProduct> products =
            LvlupPlatziProductService.getFirstTenProducts();
        Test.stopTest();

        // ── ASSERT ──────────────────────────────────────────────────────────
        System.assertNotEquals(null, products, 'La lista nunca debe ser null');
        System.assertEquals(2, products.size(), 'Deben deserializarse 2 productos');

        LvlupPlatziProductService.PlatziProduct first = products[0];
        System.assertEquals(1, first.id, 'El id debe mapearse');
        System.assertEquals('Silla Gamer Pro', first.title, 'El title debe mapearse');
        System.assertEquals(299.99, first.price, 'El price debe mapearse');
        System.assertEquals(2, first.images.size(), 'Las imagenes deben deserializarse como lista');

        // La categoría es un objeto anidado: debe convertirse en PlatziCategory.
        System.assertNotEquals(null, first.category, 'La categoria anidada debe mapearse');
        System.assertEquals(5, first.category.id, 'El id de categoria debe mapearse');
        System.assertEquals('Furniture', first.category.name, 'El nombre de categoria debe mapearse');

        System.assertEquals('Silla Gamer Elite', products[1].title, 'El segundo producto debe mapearse');
    }

    @isTest
    static void getFirstTenProductsThrowsOnNon200() {
        // ── ARRANGE: simulamos un fallo del servidor (500) ──────────────────
        Test.setMock(
            HttpCalloutMock.class,
            new PlatziHttpMock(500, '{"message":"Internal Server Error"}')
        );

        // ── ACT + ASSERT ────────────────────────────────────────────────────
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            LvlupPlatziProductService.getFirstTenProducts();
            System.assert(false, 'Se esperaba PlatziCalloutException y no se lanzo');
        } catch (LvlupPlatziProductService.PlatziCalloutException e) {
            exceptionThrown = true;
            // El mensaje debe incluir el status code y el body para diagnostico.
            System.assert(
                e.getMessage().contains('500'),
                'El mensaje debe incluir el status code: ' + e.getMessage()
            );
            System.assert(
                e.getMessage().contains('Internal Server Error'),
                'El mensaje debe incluir el body: ' + e.getMessage()
            );
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Ante un estado != 200 debe lanzarse la excepcion');
    }
}
