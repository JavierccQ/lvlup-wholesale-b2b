/**
 * ============================================================================
 *  LvlupQuickBuyControllerTest  (clase de PRUEBAS del controller)
 * ============================================================================
 *  Salesforce OBLIGA a escribir tests para subir Apex a producción: exige al
 *  menos 75% de líneas cubiertas por tests. Estos tests cubren el controller al
 *  100%: el caso con regla estándar (PurchaseQuantityRule, ADR-0009) y el caso
 *  sin regla (defaults seguros).
 *
 *  - `@isTest` sobre la clase → marca toda la clase como código de prueba.
 *  - Importante: los tests NO ven los datos reales de la org por defecto; cada
 *    test crea SUS PROPIOS datos (aislamiento). Al terminar, esos datos se borran.
 * ============================================================================
 */
@isTest
private class LvlupQuickBuyControllerTest {
  // Caso principal: el MOQ / múltiplo / máximo vienen de la regla ESTÁNDAR
  // asociada por el junction; el stock sigue viniendo del campo custom.
  @isTest
  static void getProductPurchaseInfoReturnsFieldsPriceAndRule() {
    // ── ARRANGE ─────────────────────────────────────────────────────────
    // El producto solo lleva el stock (campo custom). Las reglas de cantidad
    // YA NO están en Product2: vienen de PurchaseQuantityRule.
    Product2 product = new Product2(
      Name = 'Test Quick Buy Product',
      StockKeepingUnit = 'LVL-TEST-001',
      IsActive = true,
      Inventory_Quantity__c = 120 // stock
    );
    insert product;

    // Regla de cantidad estándar + junction que la asocia al producto (ADR-0009).
    PurchaseQuantityRule rule = new PurchaseQuantityRule(
      Name = 'Test MOQ 5 / Inc 5 / Max 500',
      Minimum = 5,
      Increment = 5,
      Maximum = 500
    );
    insert rule;
    insert new ProductQuantityRule(
      ProductId = product.Id,
      PurchaseQuantityRuleId = rule.Id
    );

    // El precio necesita un PricebookEntry. En tests el Id del price book
    // estándar se obtiene con Test.getStandardPricebookId().
    PricebookEntry entry = new PricebookEntry(
      Pricebook2Id = Test.getStandardPricebookId(),
      Product2Id = product.Id,
      UnitPrice = 419,
      IsActive = true
    );
    insert entry;

    // ── ACT ─────────────────────────────────────────────────────────────
    Test.startTest();
    LvlupQuickBuyController.ProductPurchaseInfo info = LvlupQuickBuyController.getProductPurchaseInfo(
      product.Id
    );
    Test.stopTest();

    // ── ASSERT ──────────────────────────────────────────────────────────
    System.assertEquals(product.Id, info.productId, 'productId should match');
    System.assertEquals('LVL-TEST-001', info.sku, 'sku should match');
    System.assertEquals(
      120,
      info.stock,
      'stock comes from the inventory field'
    );
    System.assertEquals(
      5,
      info.minQuantity,
      'MOQ comes from the standard rule'
    );
    System.assertEquals(
      5,
      info.increment,
      'increment comes from the standard rule'
    );
    System.assertEquals(
      500,
      info.maxQuantity,
      'max comes from the standard rule'
    );
    System.assertEquals(
      419,
      info.unitPrice,
      'price comes from the pricebook entry'
    );
  }

  // Caso sin regla: un producto sin PurchaseQuantityRule asociada cae a los
  // defaults seguros (min 1, múltiplo 1, sin máximo), iguales a los del
  // lvlupQuantitySelector → el modal no se rompe.
  @isTest
  static void getProductPurchaseInfoDefaultsWhenNoRule() {
    Product2 product = new Product2(
      Name = 'No Rule Product',
      StockKeepingUnit = 'LVL-TEST-002',
      IsActive = true,
      Inventory_Quantity__c = 10
    );
    insert product;

    Test.startTest();
    LvlupQuickBuyController.ProductPurchaseInfo info = LvlupQuickBuyController.getProductPurchaseInfo(
      product.Id
    );
    Test.stopTest();

    System.assertEquals(
      1,
      info.minQuantity,
      'defaults to min 1 without a rule'
    );
    System.assertEquals(
      1,
      info.increment,
      'defaults to increment 1 without a rule'
    );
    System.assertEquals(null, info.maxQuantity, 'no max without a rule');
    System.assertEquals(
      10,
      info.stock,
      'stock still comes from the inventory field'
    );
  }
}
