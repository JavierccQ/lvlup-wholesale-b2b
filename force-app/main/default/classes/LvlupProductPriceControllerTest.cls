/**
 * Tests for LvlupProductPriceController. The core overload receives the resolved
 * price book ids by parameter (REGLA-011), so the tests do not depend on
 * WebStore or BuyerGroup records, which are org configuration.
 */
@IsTest
private class LvlupProductPriceControllerTest {
  static final Decimal LIST_PRICE = 1499;
  static final Decimal SALE_PRICE = 1349;

  static Id createProductWithPrices(
    Id sellingPricebookId,
    Id strikethroughPricebookId,
    Decimal salePrice,
    Decimal listPrice
  ) {
    Product2 product = new Product2(
      Name = 'Test Laptop',
      StockKeepingUnit = 'TST-LAP-001',
      IsActive = true
    );
    insert product;

    insert new PricebookEntry(
      Pricebook2Id = Test.getStandardPricebookId(),
      Product2Id = product.Id,
      UnitPrice = listPrice,
      IsActive = true
    );
    List<PricebookEntry> entries = new List<PricebookEntry>();
    if (salePrice != null) {
      entries.add(
        new PricebookEntry(
          Pricebook2Id = sellingPricebookId,
          Product2Id = product.Id,
          UnitPrice = salePrice,
          UseStandardPrice = false,
          IsActive = true
        )
      );
    }
    if (listPrice != null) {
      entries.add(
        new PricebookEntry(
          Pricebook2Id = strikethroughPricebookId,
          Product2Id = product.Id,
          UnitPrice = listPrice,
          UseStandardPrice = false,
          IsActive = true
        )
      );
    }
    insert entries;
    return product.Id;
  }

  static Id insertPricebook(String name) {
    Pricebook2 pricebook = new Pricebook2(Name = name, IsActive = true);
    insert pricebook;
    return pricebook.Id;
  }

  @IsTest
  static void returnsNegotiatedAndStrikethroughPrices() {
    Id sellingId = insertPricebook('Selling PB');
    Id strikeId = insertPricebook('Strike PB');
    Id productId = createProductWithPrices(
      sellingId,
      strikeId,
      SALE_PRICE,
      LIST_PRICE
    );

    Test.startTest();
    LvlupProductPriceController.ProductPriceInfo info = LvlupProductPriceController.getProductPrice(
      productId,
      sellingId,
      strikeId
    );
    Test.stopTest();

    System.assertEquals(
      SALE_PRICE,
      info.unitPrice,
      'Unit price must come from the selling price book'
    );
    System.assertEquals(
      LIST_PRICE,
      info.listPrice,
      'List price must come from the strikethrough price book'
    );
    System.assertNotEquals(
      null,
      info.currencyIsoCode,
      'Currency must be populated'
    );
  }

  @IsTest
  static void suppressesStrikethroughWhenNotHigherThanUnitPrice() {
    Id sellingId = insertPricebook('Selling PB');
    Id strikeId = insertPricebook('Strike PB');
    Id productId = createProductWithPrices(
      sellingId,
      strikeId,
      LIST_PRICE,
      LIST_PRICE
    );

    Test.startTest();
    LvlupProductPriceController.ProductPriceInfo info = LvlupProductPriceController.getProductPrice(
      productId,
      sellingId,
      strikeId
    );
    Test.stopTest();

    System.assertEquals(
      LIST_PRICE,
      info.unitPrice,
      'Unit price must be returned'
    );
    System.assertEquals(
      null,
      info.listPrice,
      'Equal strikethrough price must be suppressed'
    );
  }

  @IsTest
  static void returnsEmptyPricesWhenNoEntriesMatch() {
    Id sellingId = insertPricebook('Selling PB');
    Id strikeId = insertPricebook('Strike PB');
    Product2 product = new Product2(
      Name = 'No Price',
      StockKeepingUnit = 'TST-NOP-001',
      IsActive = true
    );
    insert product;

    Test.startTest();
    LvlupProductPriceController.ProductPriceInfo info = LvlupProductPriceController.getProductPrice(
      product.Id,
      sellingId,
      strikeId
    );
    Test.stopTest();

    System.assertEquals(
      null,
      info.unitPrice,
      'No unit price expected without entries'
    );
    System.assertEquals(
      null,
      info.listPrice,
      'No list price expected without entries'
    );
  }

  @IsTest
  static void cacheableEntryPointResolvesWithoutBuyerContext() {
    Id sellingId = insertPricebook('Selling PB');
    Id strikeId = insertPricebook('Strike PB');
    Id productId = createProductWithPrices(
      sellingId,
      strikeId,
      SALE_PRICE,
      LIST_PRICE
    );

    Test.startTest();
    // Running user is an internal test user: no buyer account and (usually) no
    // WebStore in the test context, so both ids resolve to null and the info
    // comes back empty instead of throwing.
    LvlupProductPriceController.ProductPriceInfo info = LvlupProductPriceController.getProductPrice(
      productId
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      info,
      'The cacheable entry point must not throw'
    );
  }
}
