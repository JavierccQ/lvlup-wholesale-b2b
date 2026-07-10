/**
 * ============================================================================
 *  LvlupCatalogPulseSubscriberTest
 * ============================================================================
 *  Verifica que publicar Catalog_Pulse_Event__e persiste el feed, que el upsert
 *  por Pulse_Key__c es idempotente, y que el núcleo buildItems deduplica y filtra
 *  eventos inválidos. No depende de CDC: publica el evento de negocio directamente.
 * ============================================================================
 */
@isTest
private class LvlupCatalogPulseSubscriberTest {
  private static Product2 buildProduct(String code) {
    Product2 product = new Product2(
      Name = 'Sub ' + code,
      ProductCode = code,
      StockKeepingUnit = code,
      IsActive = true,
      Is_External_Product__c = false
    );
    insert product;
    return product;
  }

  private static Catalog_Pulse_Event__e event(Id productId, String changeType) {
    return new Catalog_Pulse_Event__e(
      Product_Id__c = productId,
      Product_Code__c = 'LVL-SUB-001',
      Change_Type__c = changeType,
      Source_Object__c = 'Product2',
      Segment_Key__c = null,
      Effective_Date__c = System.now(),
      Priority__c = 'HIGH',
      Title__c = 'Nuevo',
      Message__c = 'Mensaje'
    );
  }

  @isTest
  static void publishingEventPersistsActiveItem() {
    Product2 product = buildProduct('LVL-SUB-001');

    Test.startTest();
    EventBus.publish(event(product.Id, 'NEW'));
    Test.stopTest(); // flush del bus -> dispara el trigger del platform event.

    List<Catalog_Pulse_Item__c> items = [
      SELECT Id, Status__c, Product__c, Pulse_Key__c, Expiration_Date__c
      FROM Catalog_Pulse_Item__c
    ];
    System.assertEquals(1, items.size(), 'Un evento -> un item');
    System.assertEquals('ACTIVE', items[0].Status__c, 'El item nace ACTIVE');
    System.assertEquals(
      product.Id,
      items[0].Product__c,
      'Lookup al producto resuelto'
    );
    System.assertNotEquals(
      null,
      items[0].Expiration_Date__c,
      'Debe fijar vigencia'
    );
  }

  @isTest
  static void handleIsIdempotentByPulseKey() {
    Product2 product = buildProduct('LVL-SUB-002');
    List<Catalog_Pulse_Event__e> batch = new List<Catalog_Pulse_Event__e>{
      event(product.Id, 'NEW')
    };

    Test.startTest();
    LvlupCatalogPulseSubscriber.handle(batch);
    LvlupCatalogPulseSubscriber.handle(batch); // misma clave -> actualiza, no duplica.
    Test.stopTest();

    System.assertEquals(
      1,
      [
        SELECT COUNT()
        FROM Catalog_Pulse_Item__c
        WHERE Product__c = :product.Id
      ],
      'El upsert por Pulse_Key__c no debe duplicar'
    );
  }

  @isTest
  static void buildItemsDedupesAndSkipsInvalid() {
    Product2 product = buildProduct('LVL-SUB-003');
    Catalog_Pulse_Event__e valid1 = event(product.Id, 'NEW');
    Catalog_Pulse_Event__e valid2 = event(product.Id, 'NEW'); // misma clave -> dedupe
    Catalog_Pulse_Event__e blank = event(null, 'NEW'); // sin producto -> se descarta

    List<Catalog_Pulse_Item__c> items = LvlupCatalogPulseSubscriber.buildItems(
      new List<Catalog_Pulse_Event__e>{ valid1, valid2, blank }
    );
    System.assertEquals(
      1,
      items.size(),
      'Dedupe por clave y descarte de inválidos'
    );
  }
}
