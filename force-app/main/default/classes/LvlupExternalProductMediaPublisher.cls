/**
 * ============================================================================
 *  LvlupExternalProductMediaPublisher  (CASADO de imágenes CMS -> Product2)
 * ============================================================================
 *  Responsabilidad ÚNICA: enlazar las imágenes ya presentes en el CMS de la
 *  store con sus Product2, creando registros `ProductMedia` en los grupos de
 *  uso "Listing" (card) y "Standard" (detalle).
 *
 *  Cómo casa: la imagen CMS (`ManagedContent`) se importa con `Name` = código de
 *  producto (p. ej. "EXT-PLATZI-23"). Aquí se empareja ManagedContent.Name con
 *  Product2.ProductCode. NO descarga imágenes ni crea contenido CMS (eso es el
 *  paso manual de importar el ZIP al CMS); solo crea los ProductMedia, que es
 *  puro DML y por eso SÍ puede ir dentro del pipeline.
 *
 *  Idempotente: no duplica ProductMedia ya existentes. Solo casa lo que ya esté
 *  importado en CMS; los productos sin imagen importada se omiten sin error.
 * ============================================================================
 */
public with sharing class LvlupExternalProductMediaPublisher {
    // Grupos de uso de Commerce donde la imagen se muestra en card y PDP.
    private static final Set<String> TARGET_USAGE_TYPES = new Set<String>{ 'Listing', 'Standard' };

    /** Resumen del resultado del casado. */
    public class MediaResult {
        public Integer totalProducts = 0;      // productos externos considerados
        public Integer imagesMatched = 0;      // productos con imagen CMS encontrada
        public Integer mediaLinksCreated = 0;  // ProductMedia creados
        public Integer alreadyLinked = 0;      // ProductMedia ya existentes
        public Integer errorCount = 0;
    }

    /**
     * Entrada principal: descubre productos externos e imágenes CMS por nombre y
     * crea los ProductMedia que falten.
     */
    public static MediaResult linkProductImages() {
        // Producto externo por código.
        Map<String, Id> productIdByCode = new Map<String, Id>();
        for (Product2 product : [
            SELECT Id, ProductCode
            FROM Product2
            WHERE Is_External_Product__c = true AND ProductCode != null
        ]) {
            productIdByCode.put(product.ProductCode, product.Id);
        }

        // Imagen CMS cuyo Name coincide con un código de producto.
        Map<String, Id> mediaIdByCode = new Map<String, Id>();
        if (!productIdByCode.isEmpty()) {
            for (ManagedContent content : [
                SELECT Id, Name FROM ManagedContent WHERE Name IN :productIdByCode.keySet()
            ]) {
                mediaIdByCode.put(content.Name, content.Id);
            }
        }

        return linkProductImages(productIdByCode, mediaIdByCode);
    }

    /**
     * Core testeable: recibe los mapas (código -> ProductId / código -> mediaId)
     * y crea los ProductMedia en los grupos Listing y Standard. Separar la
     * resolución por SOQL del DML permite testear sin depender de ManagedContent
     * (que no es insertable en tests).
     */
    @TestVisible
    private static MediaResult linkProductImages(
        Map<String, Id> productIdByCode,
        Map<String, Id> mediaIdByCode
    ) {
        MediaResult result = new MediaResult();
        if (productIdByCode == null || productIdByCode.isEmpty()) {
            return result;
        }
        result.totalProducts = productIdByCode.size();
        if (mediaIdByCode == null || mediaIdByCode.isEmpty()) {
            return result;
        }

        // Grupos destino (Listing + Standard), descubiertos dinámicamente.
        List<ElectronicMediaGroup> groups = [
            SELECT Id FROM ElectronicMediaGroup WHERE UsageType IN :TARGET_USAGE_TYPES
        ];
        if (groups.isEmpty()) {
            return result;
        }

        // ProductMedia ya existentes (idempotencia): key = productId|groupId.
        Set<Id> productIds = new Set<Id>(productIdByCode.values());
        Set<String> existing = new Set<String>();
        for (ProductMedia pm : [
            SELECT ProductId, ElectronicMediaGroupId
            FROM ProductMedia
            WHERE ProductId IN :productIds
        ]) {
            existing.add(pm.ProductId + '|' + pm.ElectronicMediaGroupId);
        }

        // Construir los ProductMedia que faltan (un grupo por uso).
        List<ProductMedia> toInsert = new List<ProductMedia>();
        for (String code : mediaIdByCode.keySet()) {
            if (!productIdByCode.containsKey(code)) {
                continue;
            }
            Id productId = productIdByCode.get(code);
            Id mediaId = mediaIdByCode.get(code);
            result.imagesMatched++;
            for (ElectronicMediaGroup grp : groups) {
                if (existing.contains(productId + '|' + grp.Id)) {
                    result.alreadyLinked++;
                } else {
                    toInsert.add(new ProductMedia(
                        ProductId = productId,
                        ElectronicMediaId = mediaId,
                        ElectronicMediaGroupId = grp.Id,
                        SortOrder = 0
                    ));
                }
            }
        }

        if (!toInsert.isEmpty()) {
            for (Database.SaveResult sr : Database.insert(toInsert, false)) {
                if (sr.isSuccess()) {
                    result.mediaLinksCreated++;
                } else {
                    result.errorCount++;
                }
            }
        }
        return result;
    }
}
