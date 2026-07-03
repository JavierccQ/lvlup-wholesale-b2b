/**
 * ============================================================================
 *  LvlupPlatziProductService  (capa de SERVICIO HTTP / cliente de API externa)
 * ============================================================================
 *  Responsabilidad ÚNICA: consumir productos desde la "Platzi Fake Store API"
 *  y devolverlos como objetos Apex tipados (wrappers / DTOs).
 *
 *  Esta clase NO crea Product2, NI PricebookEntry, NI categorías, NI staging,
 *  NI publica nada en Commerce. Solo habla HTTP y deserializa. Mantener este
 *  alcance acotado es lo que permite reutilizarla luego desde un importador.
 *
 *  ── NAMED CREDENTIAL ───────────────────────────────────────────────────────
 *  Nunca hardcodeamos la URL completa. Usamos el Named Credential configurado
 *  en la org: `Platzi_Fake_Store_API` (URL base https://api.escuelajs.co/api/v1).
 *  Apex resuelve `callout:Platzi_Fake_Store_API/...` en tiempo de ejecución y
 *  añade la base + cualquier autenticación. Si mañana cambia el host, solo se
 *  toca el Named Credential, no este código.
 *
 *  ── SHARING ────────────────────────────────────────────────────────────────
 *  `with sharing`: esta clase no consulta registros sensibles de la org; solo
 *  hace una llamada saliente. Usamos `with sharing` como buena práctica por
 *  defecto (respeta la visibilidad del usuario que la ejecute).
 * ============================================================================
 */
public with sharing class LvlupPlatziProductService {
    // Path relativo del endpoint. La base la pone el Named Credential.
    // Resultado efectivo: https://api.escuelajs.co/api/v1/products?offset=0&limit=10
    private static final String NAMED_CREDENTIAL = 'callout:Platzi_Fake_Store_API';
    private static final String PRODUCTS_PATH = '/products?offset=0&limit=10';
    private static final Integer TIMEOUT_MS = 10000; // 10 segundos

    /**
     * Trae los primeros 10 productos de Platzi (offset=0, limit=10).
     *
     * @return Lista de productos tipados (`PlatziProduct`). Puede venir vacía si
     *         la API responde 200 con un array vacío, pero nunca null.
     * @throws PlatziCalloutException si la respuesta HTTP no es 200.
     */
    public static List<PlatziProduct> getFirstTenProducts() {
        // ── 1) Construir la petición ────────────────────────────────────────
        HttpRequest request = new HttpRequest();
        request.setEndpoint(NAMED_CREDENTIAL + PRODUCTS_PATH);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');
        request.setTimeout(TIMEOUT_MS);

        // ── 2) Ejecutar la llamada saliente ─────────────────────────────────
        HttpResponse response = new Http().send(request);

        // ── 3) Validar el código de estado ──────────────────────────────────
        // Si no es 200, lanzamos una excepción CONTROLADA que incluye el status
        // y el body, para que quien llame (Anonymous Apex, importador, test)
        // pueda diagnosticar qué devolvió la API.
        if (response.getStatusCode() != 200) {
            throw new PlatziCalloutException(
                'Platzi API devolvió un estado inesperado. Status: ' +
                response.getStatusCode() +
                ' | Body: ' +
                response.getBody()
            );
        }

        // ── 4) Deserializar ─────────────────────────────────────────────────
        // La API devuelve un ARRAY directo de productos (no un objeto contenedor),
        // por eso deserializamos hacia List<PlatziProduct>.
        // Usamos JSON.deserialize (no la versión "Strict"): ignora cualquier campo
        // extra que mande Platzi (creationAt, slug, etc.) y solo mapea los nuestros.
        List<PlatziProduct> products = (List<PlatziProduct>) JSON.deserialize(
            response.getBody(),
            List<PlatziProduct>.class
        );

        // Nunca devolver null: simplifica el consumo aguas abajo.
        return products == null ? new List<PlatziProduct>() : products;
    }

    /**
     * Excepción controlada de esta capa de servicio. Que tenga su propio tipo
     * permite al importador (paso futuro) capturar SOLO los errores de callout
     * de Platzi y tratarlos distinto de otros errores.
     */
    public class PlatziCalloutException extends Exception {
    }

    /**
     * Wrapper / DTO de un producto de Platzi. Solo transporta datos; sin lógica.
     * Los nombres de los campos COINCIDEN con el JSON de la API para que la
     * deserialización sea automática (sin mapeos manuales).
     */
    public class PlatziProduct {
        public Integer id;
        public String title;
        public Decimal price;
        public String description;
        public List<String> images;
        public PlatziCategory category;
    }

    /**
     * Wrapper / DTO de la categoría anidada dentro de cada producto de Platzi.
     */
    public class PlatziCategory {
        public Integer id;
        public String name;
        public String image;
    }
}
