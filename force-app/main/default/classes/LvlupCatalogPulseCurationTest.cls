/**
 * ============================================================================
 *  LvlupCatalogPulseCurationTest
 * ============================================================================
 *  Cubre la clasificación de negocio (núcleo puro buildEvents) y el camino real
 *  de Change Data Capture de extremo a extremo con Test.enableChangeDataCapture:
 *  insertar un Product2 genera un Product2ChangeEvent -> curación publica
 *  Catalog_Pulse_Event__e -> subscriber persiste Catalog_Pulse_Item__c.
 * ============================================================================
 */
@isTest
private class LvlupCatalogPulseCurationTest {
  @TestSetup
  static void setup() {
    insert new Product2(
      Name = 'Curation Base',
      ProductCode = 'LVL-CUR-001',
      StockKeepingUnit = 'LVL-CUR-001',
      IsActive = true,
      Is_External_Product__c = false
    );
  }

  private static Id baseProductId() {
    return [SELECT Id FROM Product2 WHERE ProductCode = 'LVL-CUR-001' LIMIT 1]
    .Id;
  }

  private static LvlupCatalogPulseCuration.ProductChange change(
    String operation
  ) {
    LvlupCatalogPulseCuration.ProductChange c = new LvlupCatalogPulseCuration.ProductChange();
    c.productId = baseProductId();
    c.productCode = 'LVL-CUR-001';
    c.productName = 'Curation Base';
    c.changeOperation = operation;
    c.isActive = true;
    return c;
  }

  @isTest
  static void createProducesNewHighPriority() {
    List<Catalog_Pulse_Event__e> events = LvlupCatalogPulseCuration.buildEvents(
      new List<LvlupCatalogPulseCuration.ProductChange>{ change('CREATE') }
    );
    System.assertEquals(1, events.size(), 'Un evento por un cambio válido');
    System.assertEquals('NEW', events[0].Change_Type__c, 'CREATE -> NEW');
    System.assertEquals('HIGH', events[0].Priority__c, 'NEW es HIGH');
    System.assertEquals(
      'Product2',
      events[0].Source_Object__c,
      'Origen Product2'
    );
    System.assertEquals(
      null,
      events[0].Segment_Key__c,
      'Global: el entitlement es la frontera'
    );
  }

  @isTest
  static void inventoryUpdateProducesRestock() {
    LvlupCatalogPulseCuration.ProductChange c = change('UPDATE');
    c.changedFields = new Set<String>{ 'Inventory_Quantity__c' };
    c.inventory = 25;

    List<Catalog_Pulse_Event__e> events = LvlupCatalogPulseCuration.buildEvents(
      new List<LvlupCatalogPulseCuration.ProductChange>{ c }
    );
    System.assertEquals(
      'RESTOCK',
      events[0].Change_Type__c,
      'Inventario > 0 -> RESTOCK'
    );
    System.assertEquals('NORMAL', events[0].Priority__c, 'RESTOCK es NORMAL');
  }

  @isTest
  static void otherUpdateProducesUpdated() {
    LvlupCatalogPulseCuration.ProductChange c = change('UPDATE');
    c.changedFields = new Set<String>{ 'Name' };

    List<Catalog_Pulse_Event__e> events = LvlupCatalogPulseCuration.buildEvents(
      new List<LvlupCatalogPulseCuration.ProductChange>{ c }
    );
    System.assertEquals(
      'UPDATED',
      events[0].Change_Type__c,
      'Otro campo -> UPDATED'
    );
    System.assertEquals('LOW', events[0].Priority__c, 'UPDATED es LOW');
  }

  @isTest
  static void inactiveAndDeleteAreSkipped() {
    LvlupCatalogPulseCuration.ProductChange inactive = change('CREATE');
    inactive.isActive = false;
    LvlupCatalogPulseCuration.ProductChange deleted = change('DELETE');

    List<Catalog_Pulse_Event__e> events = LvlupCatalogPulseCuration.buildEvents(
      new List<LvlupCatalogPulseCuration.ProductChange>{ inactive, deleted }
    );
    System.assertEquals(
      0,
      events.size(),
      'Inactivo y DELETE no generan novedad'
    );
  }

  @isTest
  static void endToEndThroughChangeDataCapture() {
    Test.enableChangeDataCapture();

    Test.startTest();
    Product2 fresh = new Product2(
      Name = 'CDC New Product',
      ProductCode = 'LVL-CDC-001',
      StockKeepingUnit = 'LVL-CDC-001',
      IsActive = true,
      Is_External_Product__c = false
    );
    insert fresh;
    // 1er deliver: Product2ChangeEvent -> curación publica Catalog_Pulse_Event__e.
    Test.getEventBus().deliver();
    // 2º deliver: Catalog_Pulse_Event__e -> subscriber inserta Catalog_Pulse_Item__c.
    Test.getEventBus().deliver();
    Test.stopTest();

    List<Catalog_Pulse_Item__c> items = [
      SELECT Id, Change_Type__c, Product__c
      FROM Catalog_Pulse_Item__c
      WHERE Product__c = :fresh.Id
    ];
    System.assertEquals(
      1,
      items.size(),
      'El alta debe materializar una novedad NEW vía CDC'
    );
    System.assertEquals(
      'NEW',
      items[0].Change_Type__c,
      'Un alta se clasifica NEW'
    );
  }

  @isTest
  static void updateWithInheritedFalseIsActiveIsNotSkipped() {
    // Reproduce el bug real: en un change event UPDATE que solo tocó Description,
    // los booleanos NO cambiados (IsActive) llegan como su default (false), no null.
    // La curación NO debe descartar el evento por ese "false" heredado.
    Id productId = baseProductId();

    Product2ChangeEvent evt = new Product2ChangeEvent();
    evt.IsActive = false; // valor por defecto heredado, NO significa inactivo
    EventBus.ChangeEventHeader header = new EventBus.ChangeEventHeader();
    header.changeType = 'UPDATE';
    header.recordIds = new List<String>{ productId };
    header.changedFields = new List<String>{ 'Description' };
    evt.ChangeEventHeader = header;

    List<LvlupCatalogPulseCuration.ProductChange> changes = LvlupCatalogPulseCuration.mapChangeEvents(
      new List<Product2ChangeEvent>{ evt }
    );
    List<Catalog_Pulse_Event__e> events = LvlupCatalogPulseCuration.buildEvents(
      changes
    );

    System.assertEquals(
      1,
      events.size(),
      'UPDATE con IsActive=false heredado (no cambiado) no debe descartarse'
    );
    System.assertEquals(
      'UPDATED',
      events[0].Change_Type__c,
      'Cambio de un campo no-inventario -> UPDATED'
    );
  }
}
