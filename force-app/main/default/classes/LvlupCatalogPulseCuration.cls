/**
 * ============================================================================
 *  LvlupCatalogPulseCuration  (capa de CURACIÓN: CDC crudo -> evento de negocio)
 * ============================================================================
 *  Responsabilidad ÚNICA: traducir un cambio capturado por Change Data Capture
 *  sobre Product2 en un evento de NEGOCIO `Catalog_Pulse_Event__e` con
 *  significado funcional (changeType, title, message, priority). El evento NO es
 *  una copia cruda del ChangeEvent: aquí decidimos si el cambio es una novedad
 *  relevante y cómo se le habla al comprador.
 *
 *  ── POR QUÉ DOS SALTOS (CDC -> Platform Event) ─────────────────────────────
 *  CDC detecta *qué* cambió (a bajo nivel, efímero). El Platform Event expresa
 *  *qué significa* para el negocio y desacopla al que persiste (subscriber) de
 *  la mecánica del ChangeEvent. Es el patrón event-driven que se quiere practicar.
 *
 *  ── TESTABILIDAD (REGLA-011) ───────────────────────────────────────────────
 *  El núcleo `buildEvents(List<ProductChange>)` es lógica pura sobre un wrapper
 *  simple y se testea sin objetos CDC. El trigger mapea Product2ChangeEvent ->
 *  ProductChange y llama al núcleo; el mapeo se cubre con Test.enableChangeDataCapture.
 *
 *  Limitación honesta: el precio de un Product2 vive en PricebookEntry, no en
 *  Product2, así que la CDC de Product2 no puede detectar PRICE_DROP. Ese
 *  changeType queda soportado en el modelo para una futura CDC de PricebookEntry
 *  o para publicación desde el pipeline; aquí producimos NEW / RESTOCK / UPDATED.
 * ============================================================================
 */
public with sharing class LvlupCatalogPulseCuration {
  // Tipos de cambio de negocio (deben coincidir con la picklist de Catalog_Pulse_Item__c).
  @TestVisible
  private static final String TYPE_NEW = 'NEW';
  @TestVisible
  private static final String TYPE_RESTOCK = 'RESTOCK';
  @TestVisible
  private static final String TYPE_UPDATED = 'UPDATED';

  private static final String SOURCE_PRODUCT2 = 'Product2';
  private static final String INVENTORY_FIELD = 'Inventory_Quantity__c';

  private static final String PRIORITY_HIGH = 'HIGH';
  private static final String PRIORITY_NORMAL = 'NORMAL';
  private static final String PRIORITY_LOW = 'LOW';

  /**
   * Wrapper de entrada testeable: representa un cambio de un único producto ya
   * normalizado desde el ChangeEvent (o construido a mano en un test).
   */
  public class ProductChange {
    public Id productId;
    public String productCode;
    public String productName;
    public String changeOperation; // CREATE | UPDATE | UNDELETE | ...
    public Set<String> changedFields;
    public Decimal inventory;
    public Boolean isActive;

    public ProductChange() {
      this.changedFields = new Set<String>();
      this.isActive = true;
    }
  }

  /**
   * Entrada real desde el trigger de CDC. Normaliza los Product2ChangeEvent a
   * ProductChange, construye los eventos de negocio y los publica en el bus.
   *
   * @param events change events entregados por la plataforma (Trigger.new).
   */
  public static void publishFromChangeEvents(List<Product2ChangeEvent> events) {
    if (events == null || events.isEmpty()) {
      return;
    }
    List<ProductChange> changes = mapChangeEvents(events);
    List<Catalog_Pulse_Event__e> businessEvents = buildEvents(changes);
    if (!businessEvents.isEmpty()) {
      EventBus.publish(businessEvents);
    }
  }

  /**
   * Normaliza los Product2ChangeEvent a ProductChange. Un ChangeEvent puede
   * agrupar varios record Ids con los mismos valores de campo; se expande a un
   * ProductChange por producto.
   */
  @TestVisible
  private static List<ProductChange> mapChangeEvents(
    List<Product2ChangeEvent> events
  ) {
    List<ProductChange> changes = new List<ProductChange>();
    for (Product2ChangeEvent evt : events) {
      EventBus.ChangeEventHeader header = evt.ChangeEventHeader;
      if (header == null) {
        continue;
      }
      String operation = header.getChangeType();
      Set<String> changed = new Set<String>();
      if (header.getChangedFields() != null) {
        changed.addAll(header.getChangedFields());
      }
      for (String recordId : header.getRecordIds()) {
        ProductChange change = new ProductChange();
        change.productId = recordId;
        change.productCode = evt.StockKeepingUnit != null
          ? evt.StockKeepingUnit
          : evt.ProductCode;
        change.productName = evt.Name;
        change.changeOperation = operation;
        change.changedFields = changed;
        change.inventory = evt.Inventory_Quantity__c;
        // En eventos UPDATE, los campos booleanos NO cambiados llegan con su valor
        // por defecto (false), no como null. Por eso IsActive solo es fiable en
        // altas/restauraciones o cuando IsActive está realmente entre los campos
        // cambiados; en el resto asumimos activo (un "false" heredado del default
        // NO significa que el producto esté inactivo).
        Boolean isActiveReliable =
          operation == 'CREATE' ||
          operation == 'UNDELETE' ||
          changed.contains('IsActive');
        change.isActive = isActiveReliable
          ? (evt.IsActive == null ? true : evt.IsActive)
          : true;
        changes.add(change);
      }
    }
    return changes;
  }

  /**
   * Núcleo de curación (lógica pura, testeable sin CDC). Clasifica cada cambio
   * y construye el evento de negocio. Devuelve solo los cambios que son una
   * novedad relevante para el comprador.
   */
  @TestVisible
  private static List<Catalog_Pulse_Event__e> buildEvents(
    List<ProductChange> changes
  ) {
    List<Catalog_Pulse_Event__e> events = new List<Catalog_Pulse_Event__e>();
    if (changes == null) {
      return events;
    }
    Datetime now = System.now();
    for (ProductChange change : changes) {
      if (change.productId == null || change.isActive == false) {
        // No anunciamos productos inactivos ni cambios sin producto.
        continue;
      }
      String businessType = classify(change);
      if (businessType == null) {
        continue; // DELETE, GAP u otros no generan novedad.
      }
      events.add(
        new Catalog_Pulse_Event__e(
          Product_Id__c = change.productId,
          Product_Code__c = change.productCode,
          Change_Type__c = businessType,
          Source_Object__c = SOURCE_PRODUCT2,
          Segment_Key__c = null, // global: el entitlement del buyer es la frontera real.
          Effective_Date__c = now,
          Priority__c = priorityFor(businessType),
          Title__c = titleFor(businessType),
          Message__c = messageFor(businessType, change)
        )
      );
    }
    return events;
  }

  /** Decide el changeType de negocio a partir de la operación CDC y los campos cambiados. */
  private static String classify(ProductChange change) {
    String op = change.changeOperation;
    if (op == 'CREATE' || op == 'UNDELETE') {
      return TYPE_NEW;
    }
    if (op == 'UPDATE') {
      Boolean inventoryChanged =
        change.changedFields != null &&
        change.changedFields.contains(INVENTORY_FIELD);
      if (
        inventoryChanged &&
        change.inventory != null &&
        change.inventory > 0
      ) {
        return TYPE_RESTOCK;
      }
      return TYPE_UPDATED;
    }
    return null;
  }

  private static String priorityFor(String businessType) {
    if (businessType == TYPE_NEW) {
      return PRIORITY_HIGH;
    }
    if (businessType == TYPE_RESTOCK) {
      return PRIORITY_NORMAL;
    }
    return PRIORITY_LOW;
  }

  private static String titleFor(String businessType) {
    if (businessType == TYPE_NEW) {
      return 'Nuevo producto disponible';
    }
    if (businessType == TYPE_RESTOCK) {
      return 'Producto de nuevo en stock';
    }
    return 'Producto actualizado';
  }

  private static String messageFor(String businessType, ProductChange change) {
    String label = String.isNotBlank(change.productName)
      ? change.productName
      : change.productCode;
    if (label == null) {
      label = 'un producto de tu catálogo';
    }
    if (businessType == TYPE_NEW) {
      return 'Se ha añadido ' + label + ' a tu catálogo.';
    }
    if (businessType == TYPE_RESTOCK) {
      return label + ' vuelve a estar disponible para pedir.';
    }
    return 'Se ha actualizado ' + label + '.';
  }
}
