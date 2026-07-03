/**
 * ============================================================================
 *  LvlupExternalProductEntitlementPublisher  (ENTITLEMENTS de Commerce)
 * ============================================================================
 *  Responsabilidad ÚNICA: dar visibilidad/compra de los Product2 externos a los
 *  buyers, creando `CommerceEntitlementProduct` que los asocia a la(s) política(s)
 *  de entitlement de la store.
 *
 *  Por qué hace falta: esta store usa entitlement PRODUCT-SPECIFIC (lista producto
 *  por producto). Sin un CommerceEntitlementProduct, el comprador NO ve ni puede
 *  comprar el producto, por más que esté categorizado, con precio e imagen.
 *
 *  La(s) política(s) se descubren dinámicamente desde CommerceEntitlementBuyerGroup
 *  (las que entitlan a los buyer groups), sin hardcodear nombres ni Ids.
 *  Idempotente, puro DML -> se puede ejecutar dentro del pipeline.
 * ============================================================================
 */
public with sharing class LvlupExternalProductEntitlementPublisher {
    /** Resumen del resultado del entitlement. */
    public class EntitlementResult {
        public Integer totalProducts = 0;
        public Integer entitlementsCreated = 0;
        public Integer alreadyEntitled = 0;
        public Integer errorCount = 0;
    }

    /**
     * Entrada principal: descubre las políticas ligadas a los buyer groups y
     * entitla a ellas los productos externos.
     */
    public static EntitlementResult addEntitlements() {
        Set<Id> policyIds = new Set<Id>();
        for (CommerceEntitlementBuyerGroup ebg : [
            SELECT PolicyId FROM CommerceEntitlementBuyerGroup
        ]) {
            policyIds.add(ebg.PolicyId);
        }
        return addEntitlements(policyIds);
    }

    /**
     * Core testeable: entitla los Product2 externos a las políticas dadas.
     *
     * @param policyIds políticas destino (si viene vacío, no hace nada).
     * @return resumen con totales y errores.
     */
    @TestVisible
    private static EntitlementResult addEntitlements(Set<Id> policyIds) {
        EntitlementResult result = new EntitlementResult();

        List<Id> productIds = new List<Id>();
        for (Product2 product : [SELECT Id FROM Product2 WHERE Is_External_Product__c = true]) {
            productIds.add(product.Id);
        }
        result.totalProducts = productIds.size();
        if (productIds.isEmpty() || policyIds == null || policyIds.isEmpty()) {
            return result;
        }

        // Entitlements ya existentes (idempotencia): key = productId|policyId.
        Set<String> existing = new Set<String>();
        for (CommerceEntitlementProduct ep : [
            SELECT ProductId, PolicyId
            FROM CommerceEntitlementProduct
            WHERE ProductId IN :productIds AND PolicyId IN :policyIds
        ]) {
            existing.add(ep.ProductId + '|' + ep.PolicyId);
        }

        // Crear los que falten (un registro por producto y política).
        List<CommerceEntitlementProduct> toInsert = new List<CommerceEntitlementProduct>();
        for (Id productId : productIds) {
            for (Id policyId : policyIds) {
                if (existing.contains(productId + '|' + policyId)) {
                    result.alreadyEntitled++;
                } else {
                    toInsert.add(new CommerceEntitlementProduct(
                        ProductId = productId,
                        PolicyId = policyId
                    ));
                }
            }
        }
        if (!toInsert.isEmpty()) {
            for (Database.SaveResult sr : Database.insert(toInsert, false)) {
                if (sr.isSuccess()) {
                    result.entitlementsCreated++;
                } else {
                    result.errorCount++;
                }
            }
        }
        return result;
    }
}
