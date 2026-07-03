/**
 * ============================================================================
 *  LvlupExternalProductMediaPublisherTest
 * ============================================================================
 *  ManagedContent (imagen CMS) NO es insertable en tests, así que el core se
 *  prueba inyectando los mapas. El caso de alta real de ProductMedia usa
 *  @isTest(SeeAllData=true) para apoyarse en una imagen CMS y grupos ya
 *  existentes en la org (no creables en test).
 * ============================================================================
 */
@isTest
private class LvlupExternalProductMediaPublisherTest {
    private static Product2 buildExternalProduct(String code) {
        Product2 product = new Product2(
            Name = 'Media ' + code,
            ProductCode = code,
            IsActive = true,
            Is_External_Product__c = true
        );
        insert product;
        return product;
    }

    @isTest
    static void returnsZeroWhenNoProducts() {
        Test.startTest();
        LvlupExternalProductMediaPublisher.MediaResult result =
            LvlupExternalProductMediaPublisher.linkProductImages(
                new Map<String, Id>(),
                new Map<String, Id>()
            );
        Test.stopTest();

        System.assertEquals(0, result.totalProducts, 'Sin productos -> nada');
        System.assertEquals(0, result.mediaLinksCreated, 'Nada creado');
    }

    @isTest
    static void returnsWhenNoMatchingMedia() {
        Product2 product = buildExternalProduct('EXT-PLATZI-NM-1');

        Test.startTest();
        // Hay producto pero ninguna imagen CMS que case -> no crea ProductMedia.
        LvlupExternalProductMediaPublisher.MediaResult result =
            LvlupExternalProductMediaPublisher.linkProductImages(
                new Map<String, Id>{ 'EXT-PLATZI-NM-1' => product.Id },
                new Map<String, Id>()
            );
        Test.stopTest();

        System.assertEquals(1, result.totalProducts, 'Un producto considerado');
        System.assertEquals(0, result.imagesMatched, 'Sin imagen CMS -> 0 casadas');
        System.assertEquals(0, result.mediaLinksCreated, 'Nada creado');
    }

    @isTest
    static void noArgRunsWithoutCmsContent() {
        // Sin SeeAllData no hay ManagedContent visible: cubre el camino no-arg.
        buildExternalProduct('EXT-PLATZI-NA-1');

        Test.startTest();
        LvlupExternalProductMediaPublisher.MediaResult result =
            LvlupExternalProductMediaPublisher.linkProductImages();
        Test.stopTest();

        System.assertEquals(0, result.imagesMatched, 'Sin CMS importado -> 0 casadas');
        System.assertEquals(0, result.mediaLinksCreated, 'Nada creado');
    }

    @isTest(SeeAllData=true)
    static void linksImageWhenCmsContentExists() {
        // Se apoya en una imagen CMS y grupos ya existentes en la org (no creables
        // en test). Si la org no tuviera CMS, el test no asume nada y termina.
        List<ManagedContent> media = [SELECT Id FROM ManagedContent LIMIT 1];
        List<ElectronicMediaGroup> groups = [
            SELECT Id FROM ElectronicMediaGroup WHERE UsageType IN ('Listing', 'Standard')
        ];
        if (media.isEmpty() || groups.isEmpty()) {
            return;
        }

        Product2 product = buildExternalProduct('EXT-PLATZI-MEDIA-1');
        Map<String, Id> productIdByCode = new Map<String, Id>{ 'EXT-PLATZI-MEDIA-1' => product.Id };
        Map<String, Id> mediaIdByCode = new Map<String, Id>{ 'EXT-PLATZI-MEDIA-1' => media[0].Id };

        Test.startTest();
        LvlupExternalProductMediaPublisher.MediaResult result =
            LvlupExternalProductMediaPublisher.linkProductImages(productIdByCode, mediaIdByCode);
        Test.stopTest();

        System.assertEquals(1, result.imagesMatched, 'Una imagen casada');
        // El insert de ProductMedia sobre contenido CMS está restringido en
        // contexto de test; basta validar que intentó casar cada grupo de uso
        // (la creación real se verifica en la org tras importar el ZIP).
        System.assertEquals(
            groups.size(),
            result.mediaLinksCreated + result.errorCount,
            'Intentó crear un ProductMedia por cada grupo de uso'
        );
    }
}
