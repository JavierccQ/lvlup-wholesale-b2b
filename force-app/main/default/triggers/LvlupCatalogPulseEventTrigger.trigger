/**
 * ============================================================================
 *  LvlupCatalogPulseEventTrigger  (SUBSCRIBER del Platform Event de negocio)
 * ============================================================================
 *  Se dispara cuando se publica un `Catalog_Pulse_Event__e`. Delega en el
 *  subscriber, que persiste/actualiza el feed consultable Catalog_Pulse_Item__c.
 *  Los platform events solo admiten "after insert". El trigger es fino a
 *  propósito: la lógica testeable vive en LvlupCatalogPulseSubscriber.
 * ============================================================================
 */
trigger LvlupCatalogPulseEventTrigger on Catalog_Pulse_Event__e(after insert) {
  LvlupCatalogPulseSubscriber.handle(Trigger.new);
}
