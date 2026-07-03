// Entitla los productos externos a la(s) politica(s) de la store (los hace
// visibles/comprables para el buyer). Idempotente.
LvlupExternalProductEntitlementPublisher.EntitlementResult r =
    LvlupExternalProductEntitlementPublisher.addEntitlements();
System.debug('Productos externos: ' + r.totalProducts);
System.debug('Entitlements creados: ' + r.entitlementsCreated);
System.debug('Ya entitled: ' + r.alreadyEntitled);
System.debug('Errores: ' + r.errorCount);
