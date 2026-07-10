/**
 * ============================================================================
 *  LvlupProduct2ChangeEventTrigger  (SUSCRIPTOR de Change Data Capture)
 * ============================================================================
 *  Se dispara cuando Change Data Capture emite un Product2ChangeEvent (alta,
 *  edición o restauración de un Product2, ya sea por el pipeline Platzi o por
 *  edición manual de un admin). Delega TODA la lógica en la capa de curación,
 *  que decide si el cambio es una novedad y publica el evento de negocio.
 *
 *  Requiere que Change Data Capture esté habilitado para Product2 (Setup ->
 *  Change Data Capture). Definir este trigger sobre el canal de ChangeEvent es
 *  la forma soportada de suscribirse desde Apex. El trigger es fino a propósito
 *  (una sola línea): la lógica testeable vive en LvlupCatalogPulseCuration.
 * ============================================================================
 */
trigger LvlupProduct2ChangeEventTrigger on Product2ChangeEvent(after insert) {
  LvlupCatalogPulseCuration.publishFromChangeEvents(Trigger.new);
}
