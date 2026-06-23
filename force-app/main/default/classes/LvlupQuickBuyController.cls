/**
 * ============================================================================
 *  LvlupQuickBuyController  (clase Apex = código de BACK-END / servidor)
 * ============================================================================
 *  Qué hace: dado el Id de un producto, devuelve al modal todo lo que necesita
 *  mostrar: nombre, SKU, imagen, precio, stock y reglas de compra (MOQ, etc.).
 *
 *  "Apex" es el lenguaje de servidor de Salesforce (parecido a Java). Corre en
 *  la nube y es el único que puede hablar directamente con la base de datos.
 *  Los componentes de UI (LWC) le piden datos llamando a sus métodos.
 *
 *  ── SHARING (MUY IMPORTANTE) ────────────────────────────────────────────────
 *  Toda clase Apex declara si respeta o no la "visibilidad de registros" del
 *  usuario que la ejecuta:
 *    - `with sharing`    → respeta las reglas de quién puede ver qué registro.
 *    - `without sharing` → ignora esas reglas (corre en modo "sistema").
 *  Aquí usamos `without sharing` a propósito: en B2B Commerce, los registros
 *  Product2 NO se comparten al comprador por las reglas normales (su visibilidad
 *  la da el "entitlement" de comercio). Con `with sharing`, la consulta de abajo
 *  devolvería 0 filas para el comprador (¡aunque pueda ver el producto en la
 *  tienda!) y reventaría. El producto ya está entitled, así que leer sus campos
 *  de display sin sharing es seguro.
 * ============================================================================
 */
public without sharing class LvlupQuickBuyController {
    // @AuraEnabled        → hace que este método se pueda llamar desde un LWC (JS).
    // (cacheable=true)    → el resultado se cachea en el cliente; solo para LECTURA.
    // static              → no hace falta crear una instancia de la clase para llamarlo.
    // Recibe un Id (tipo nativo de Salesforce, 18 chars) y devuelve un wrapper.
    @AuraEnabled(cacheable=true)
    public static ProductPurchaseInfo getProductPurchaseInfo(Id productId) {
        // ── 1) Traer el producto ────────────────────────────────────────────
        // Esto es SOQL (el "SQL de Salesforce"). Va entre corchetes [].
        // Selecciona campos estándar (Name, StockKeepingUnit, DisplayUrl) y
        // nuestros 4 campos custom (terminan en __c).
        // ":productId" es un "bind variable": inyecta de forma segura la variable
        // de Apex dentro de la consulta (como un parámetro preparado; evita
        // inyección de código).
        // Si no hay filas, asignar a un solo Product2 lanza QueryException
        // ("List has no rows...") — justo el error que evitamos con without sharing.
        Product2 product = [
            SELECT Id, Name, StockKeepingUnit, DisplayUrl,
                   Inventory_Quantity__c, Min_Order_Quantity__c,
                   Order_Increment__c, Max_Order_Quantity__c
            FROM Product2
            WHERE Id = :productId
            LIMIT 1
        ];

        // ── 2) Traer el precio ──────────────────────────────────────────────
        // El precio NO está en Product2; vive en "PricebookEntry" (precio de un
        // producto dentro de una lista de precios / price book).
        // Recorremos la consulta con un for (patrón seguro): si NO hay precio,
        // el bucle no entra y "unitPrice" se queda en null, sin lanzar excepción.
        // ORDER BY ... IsStandard DESC LIMIT 1 → toma 1 precio (preferimos el estándar).
        Decimal unitPrice = null;
        for (PricebookEntry entry : [
            SELECT UnitPrice
            FROM PricebookEntry
            WHERE Product2Id = :productId AND IsActive = true
            ORDER BY Pricebook2.IsStandard DESC
            LIMIT 1
        ]) {
            unitPrice = entry.UnitPrice;
        }

        // ── 3) Armar la respuesta ───────────────────────────────────────────
        // Creamos el objeto wrapper y lo rellenamos. El LWC lo recibe como un
        // objeto JS normal (p. ej. info.stock, info.minQuantity, ...).
        ProductPurchaseInfo info = new ProductPurchaseInfo();
        info.productId = product.Id;
        info.name = product.Name;
        info.sku = product.StockKeepingUnit;
        info.imageUrl = product.DisplayUrl;
        info.unitPrice = unitPrice;
        info.stock = product.Inventory_Quantity__c;       // unidades en stock
        info.minQuantity = product.Min_Order_Quantity__c; // cantidad mínima (MOQ)
        info.increment = product.Order_Increment__c;      // múltiplo / case pack
        info.maxQuantity = product.Max_Order_Quantity__c; // máximo por pedido
        return info;
    }

    /**
     * Clase interna "wrapper" (también llamada DTO: Data Transfer Object).
     * Solo transporta datos; no tiene lógica. Cada campo lleva @AuraEnabled para
     * que sea VISIBLE en el LWC: sin ese decorador, el campo no viajaría al JS.
     */
    public class ProductPurchaseInfo {
        @AuraEnabled public Id productId;
        @AuraEnabled public String name;
        @AuraEnabled public String sku;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public Decimal unitPrice;
        @AuraEnabled public Decimal stock;
        @AuraEnabled public Decimal minQuantity;
        @AuraEnabled public Decimal increment;
        @AuraEnabled public Decimal maxQuantity;
    }
}
