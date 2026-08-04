/**
 * ============================================================================
 *  LvlupQuickBuyController  (clase Apex = código de BACK-END / servidor)
 * ============================================================================
 *  Qué hace: dado el Id de un producto, devuelve al modal todo lo que necesita
 *  mostrar: nombre, SKU, imagen, precio, stock y reglas de compra (MOQ, múltiplo
 *  y máximo).
 *
 *  "Apex" es el lenguaje de servidor de Salesforce (parecido a Java). Corre en
 *  la nube y es el único que puede hablar directamente con la base de datos.
 *  Los componentes de UI (LWC) le piden datos llamando a sus métodos.
 *
 *  ── FUENTE DE LAS REGLAS DE CANTIDAD (ADR-0009) ─────────────────────────────
 *  El MOQ / múltiplo / máximo YA NO viven en campos custom de Product2: la fuente
 *  de verdad es el objeto ESTÁNDAR de Commerce `PurchaseQuantityRule`, asociado a
 *  cada producto por el junction estándar `ProductQuantityRule`. El STOCK sí sigue
 *  en el campo custom `Inventory_Quantity__c` (inventario simulado, no es una
 *  regla de cantidad; ver manual-inventory-setup-runbook.md). El DTO que devuelve
 *  este método NO cambió, así que el LWC del Quick Buy funciona igual que antes.
 *
 *  ── SHARING (MUY IMPORTANTE) ────────────────────────────────────────────────
 *  Toda clase Apex declara si respeta o no la "visibilidad de registros" del
 *  usuario que la ejecuta:
 *    - `with sharing`    → respeta las reglas de quién puede ver qué registro.
 *    - `without sharing` → ignora esas reglas (corre en modo "sistema").
 *  Aquí usamos `without sharing` a propósito: en B2B Commerce, los registros
 *  Product2 (y sus reglas asociadas) NO se comparten al comprador por las reglas
 *  normales; su visibilidad la da el "entitlement" de comercio. Con `with sharing`
 *  las consultas devolverían 0 filas para el comprador. El producto ya está
 *  entitled, así que leer sus datos de display sin sharing es seguro.
 * ============================================================================
 */
public without sharing class LvlupQuickBuyController {
  // @AuraEnabled        → hace que este método se pueda llamar desde un LWC (JS).
  // (cacheable=true)    → el resultado se cachea en el cliente; solo para LECTURA.
  // static              → no hace falta crear una instancia de la clase para llamarlo.
  // Recibe un Id (tipo nativo de Salesforce, 18 chars) y devuelve un wrapper.
  @AuraEnabled(cacheable=true)
  public static ProductPurchaseInfo getProductPurchaseInfo(Id productId) {
    // ── 1) Traer el producto (display + stock) ──────────────────────────
    // Esto es SOQL (el "SQL de Salesforce"). Selecciona campos estándar
    // (Name, StockKeepingUnit, DisplayUrl) y el stock simulado
    // (Inventory_Quantity__c). ":productId" es un "bind variable": inyecta de
    // forma segura la variable de Apex en la consulta (evita inyección).
    Product2 product = [
      SELECT Id, Name, StockKeepingUnit, DisplayUrl, Inventory_Quantity__c
      FROM Product2
      WHERE Id = :productId
      LIMIT 1
    ];

    // ── 2) Traer la REGLA DE CANTIDAD (estándar) ────────────────────────
    // La regla (mínimo / múltiplo / máximo) vive en `PurchaseQuantityRule`,
    // asociada al producto por el junction `ProductQuantityRule`. Recorremos
    // la consulta con un for (patrón seguro: si el producto no tuviera regla,
    // el bucle no entra y quedan los defaults). Los defaults COINCIDEN con los
    // del lvlupQuantitySelector (min 1, múltiplo 1, sin máximo) → un producto
    // sin regla no rompe el modal.
    Decimal minQuantity = 1;
    Decimal increment = 1;
    Decimal maxQuantity = null;
    for (ProductQuantityRule link : [
      SELECT
        PurchaseQuantityRule.Minimum,
        PurchaseQuantityRule.Increment,
        PurchaseQuantityRule.Maximum
      FROM ProductQuantityRule
      WHERE ProductId = :productId
      ORDER BY CreatedDate DESC
      LIMIT 1
    ]) {
      if (link.PurchaseQuantityRule.Minimum != null) {
        minQuantity = link.PurchaseQuantityRule.Minimum;
      }
      if (link.PurchaseQuantityRule.Increment != null) {
        increment = link.PurchaseQuantityRule.Increment;
      }
      maxQuantity = link.PurchaseQuantityRule.Maximum; // null = sin tope
    }

    // ── 3) Traer el precio ──────────────────────────────────────────────
    // El precio NO está en Product2; vive en "PricebookEntry" (precio de un
    // producto dentro de una lista de precios / price book).
    // ORDER BY ... IsStandard DESC LIMIT 1 → toma 1 precio (preferimos el estándar).
    Decimal unitPrice = null;
    for (PricebookEntry entry : [
      SELECT UnitPrice
      FROM PricebookEntry
      WHERE Product2Id = :productId AND IsActive = TRUE
      ORDER BY Pricebook2.IsStandard DESC
      LIMIT 1
    ]) {
      unitPrice = entry.UnitPrice;
    }

    // ── 4) Armar la respuesta ───────────────────────────────────────────
    // El DTO es el MISMO que antes (mismos campos), así que el LWC lo recibe
    // exactamente igual: info.stock, info.minQuantity, info.increment, ...
    ProductPurchaseInfo info = new ProductPurchaseInfo();
    info.productId = product.Id;
    info.name = product.Name;
    info.sku = product.StockKeepingUnit;
    info.imageUrl = product.DisplayUrl;
    info.unitPrice = unitPrice;
    info.stock = product.Inventory_Quantity__c; // unidades en stock (campo custom)
    info.minQuantity = minQuantity; // cantidad mínima (MOQ) — regla estándar
    info.increment = increment; // múltiplo / case pack — regla estándar
    info.maxQuantity = maxQuantity; // máximo por pedido — regla estándar
    return info;
  }

  /**
   * Clase interna "wrapper" (también llamada DTO: Data Transfer Object).
   * Solo transporta datos; no tiene lógica. Cada campo lleva @AuraEnabled para
   * que sea VISIBLE en el LWC: sin ese decorador, el campo no viajaría al JS.
   */
  public class ProductPurchaseInfo {
    @AuraEnabled
    public Id productId;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String sku;
    @AuraEnabled
    public String imageUrl;
    @AuraEnabled
    public Decimal unitPrice;
    @AuraEnabled
    public Decimal stock;
    @AuraEnabled
    public Decimal minQuantity;
    @AuraEnabled
    public Decimal increment;
    @AuraEnabled
    public Decimal maxQuantity;
  }
}
