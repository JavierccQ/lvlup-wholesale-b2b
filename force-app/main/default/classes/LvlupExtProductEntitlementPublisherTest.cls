/**
 * ============================================================================
 *  LvlupExtProductEntitlementPublisherTest
 *  (test de LvlupExternalProductEntitlementPublisher; nombre abreviado por el
 *   límite de 40 caracteres de los identificadores Apex)
 * ============================================================================
 *  CommerceEntitlementPolicy y CommerceEntitlementProduct son insertables, así
 *  que el camino real se prueba con datos aislados. El core recibe las políticas
 *  por parámetro; la entrada no-arg descubre las del buyer group.
 * ============================================================================
 */
@isTest
private class LvlupExtProductEntitlementPublisherTest {
    private static Product2 buildExternalProduct(String code) {
        Product2 product = new Product2(
            Name = 'Ent ' + code,
            ProductCode = code,
            IsActive = true,
            Is_External_Product__c = true
        );
        insert product;
        return product;
    }

    private static CommerceEntitlementPolicy buildPolicy(String name) {
        CommerceEntitlementPolicy policy = new CommerceEntitlementPolicy(
            Name = name,
            CanViewProduct = true,
            CanViewPrice = true,
            IsActive = true
        );
        insert policy;
        return policy;
    }

    @isTest
    static void createsEntitlementsForExternalProducts() {
        Product2 product = buildExternalProduct('EXT-PLATZI-ENT-1');
        CommerceEntitlementPolicy policy = buildPolicy('Test Policy A');

        Test.startTest();
        LvlupExternalProductEntitlementPublisher.EntitlementResult result =
            LvlupExternalProductEntitlementPublisher.addEntitlements(new Set<Id>{ policy.Id });
        Test.stopTest();

        System.assertEquals(1, result.totalProducts, 'Un producto externo');
        System.assertEquals(1, result.entitlementsCreated, 'Un entitlement creado');
        System.assertEquals(0, result.alreadyEntitled, 'Ninguno previo');
        System.assertEquals(0, result.errorCount, 'Sin errores');

        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM CommerceEntitlementProduct
                WHERE ProductId = :product.Id AND PolicyId = :policy.Id
            ],
            'Debe existir el CommerceEntitlementProduct'
        );
    }

    @isTest
    static void isIdempotentOnReRun() {
        buildExternalProduct('EXT-PLATZI-ENT-2');
        CommerceEntitlementPolicy policy = buildPolicy('Test Policy B');
        Set<Id> policyIds = new Set<Id>{ policy.Id };

        Test.startTest();
        LvlupExternalProductEntitlementPublisher.addEntitlements(policyIds); // crea
        LvlupExternalProductEntitlementPublisher.EntitlementResult second =
            LvlupExternalProductEntitlementPublisher.addEntitlements(policyIds); // no duplica
        Test.stopTest();

        System.assertEquals(0, second.entitlementsCreated, 'No recrea');
        System.assertEquals(1, second.alreadyEntitled, 'Detecta el previo');
    }

    @isTest
    static void returnsZeroWhenNoPolicies() {
        buildExternalProduct('EXT-PLATZI-ENT-3');

        Test.startTest();
        LvlupExternalProductEntitlementPublisher.EntitlementResult result =
            LvlupExternalProductEntitlementPublisher.addEntitlements(new Set<Id>());
        Test.stopTest();

        System.assertEquals(1, result.totalProducts, 'Hay un producto');
        System.assertEquals(0, result.entitlementsCreated, 'Sin políticas no entitla');
    }

    @isTest
    static void noArgRunsDiscovery() {
        // Sin CommerceEntitlementBuyerGroup en test, descubre 0 políticas.
        buildExternalProduct('EXT-PLATZI-ENT-4');

        Test.startTest();
        LvlupExternalProductEntitlementPublisher.EntitlementResult result =
            LvlupExternalProductEntitlementPublisher.addEntitlements();
        Test.stopTest();

        System.assertEquals(0, result.entitlementsCreated, 'Sin políticas descubiertas -> 0');
    }
}
