/**
 * ============================================================================
 *  LvlupCatalogPulseSubscriber  (SUBSCRIBER del Platform Event -> persistencia)
 * ============================================================================
 *  Responsabilidad ÚNICA: consumir `Catalog_Pulse_Event__e` y materializarlo en
 *  registros consultables `Catalog_Pulse_Item__c` (el feed que alimenta el
 *  carrusel). Es la capa que convierte el evento efímero en dato persistido, de
 *  modo que el storefront NO dependa de escuchar el bus.
 *
 *  ── IDEMPOTENCIA ────────────────────────────────────────────────────────────
 *  Cada item lleva `Pulse_Key__c` = productId|changeType|segmentKey. El upsert
 *  por esa external id evita duplicados: reprocesar el mismo evento actualiza el
 *  item existente en vez de crear otro. Además se deduplican claves repetidas
 *  dentro del mismo batch (el upsert falla si la lista trae la misma clave dos veces).
 *
 *  ── POR QUÉ APEX Y NO FLOW ──────────────────────────────────────────────────
 *  Necesitamos upsert por external id, dedupe en memoria, cálculo de vigencia y
 *  bulk-safety con DML parcial; en Apex es directo y testeable. El núcleo
 *  `buildItems` es lógica pura testeable (REGLA-011); el trigger solo delega.
 * ============================================================================
 */
public with sharing class LvlupCatalogPulseSubscriber {
  private static final Integer DEFAULT_EXPIRY_DAYS = 14;
  private static final String STATUS_ACTIVE = 'ACTIVE';
  private static final String SEGMENT_GLOBAL = 'GLOBAL';

  /**
   * Entrada real desde el trigger del Platform Event. Construye los items y los
   * upserta por Pulse_Key__c (DML parcial: un item con error no tumba al resto).
   */
  public static void handle(List<Catalog_Pulse_Event__e> events) {
    List<Catalog_Pulse_Item__c> items = buildItems(events);
    if (!items.isEmpty()) {
      Database.upsert(items, Catalog_Pulse_Item__c.Pulse_Key__c, false);
    }
  }

  /**
   * Núcleo testeable: mapea eventos -> items, calcula clave y vigencia y
   * deduplica por clave dentro del batch.
   */
  @TestVisible
  private static List<Catalog_Pulse_Item__c> buildItems(
    List<Catalog_Pulse_Event__e> events
  ) {
    Map<String, Catalog_Pulse_Item__c> byKey = new Map<String, Catalog_Pulse_Item__c>();
    if (events == null) {
      return byKey.values();
    }
    for (Catalog_Pulse_Event__e e : events) {
      if (String.isBlank(e.Product_Id__c) || String.isBlank(e.Change_Type__c)) {
        continue;
      }
      String segment = String.isBlank(e.Segment_Key__c)
        ? SEGMENT_GLOBAL
        : e.Segment_Key__c;
      String key = e.Product_Id__c + '|' + e.Change_Type__c + '|' + segment;
      Datetime effective = e.Effective_Date__c != null
        ? e.Effective_Date__c
        : System.now();

      Catalog_Pulse_Item__c item = new Catalog_Pulse_Item__c(
        Pulse_Key__c = key,
        Product_Code__c = e.Product_Code__c,
        Change_Type__c = e.Change_Type__c,
        Segment_Key__c = e.Segment_Key__c,
        Title__c = e.Title__c,
        Message__c = e.Message__c,
        Priority__c = e.Priority__c,
        Effective_Date__c = effective,
        Expiration_Date__c = effective.addDays(DEFAULT_EXPIRY_DAYS),
        Status__c = STATUS_ACTIVE,
        Source_Object__c = e.Source_Object__c
      );
      Id productId = safeId(e.Product_Id__c);
      if (productId != null) {
        item.Product__c = productId;
      }
      byKey.put(key, item);
    }
    return byKey.values();
  }

  /** Convierte a Id validando; devuelve null si no es un Id válido (nunca lanza). */
  private static Id safeId(String value) {
    try {
      return Id.valueOf(value);
    } catch (Exception ex) {
      return null;
    }
  }
}
