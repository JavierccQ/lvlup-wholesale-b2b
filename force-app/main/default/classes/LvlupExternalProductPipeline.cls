/**
 * ============================================================================
 *  LvlupExternalProductPipeline  (ORQUESTADOR end-to-end)
 * ============================================================================
 *  Encadena, en orden, todos los pasos de la integración Platzi para que se
 *  ejecuten como un único flujo sin intervención de admin:
 *
 *    1) Importar (CALLOUT) Platzi -> External_Product__c
 *    2) Publicar staging        -> Product2 (crear/actualizar, SKU, inventario)
 *    3) Asignar categoría       -> ProductCategoryProduct
 *    4) Precios                 -> PricebookEntry (Standard + price book de venta)
 *    5) Casar imágenes          -> ProductMedia (Listing + Standard)
 *    6) Entitlements            -> CommerceEntitlementProduct (visibilidad buyer)
 *
 *  Orden importante: el CALLOUT (paso 1) va PRIMERO porque Apex no permite hacer
 *  callouts después de DML en la misma transacción. Los pasos 2-6 son solo DML.
 *
 *  Pasos MANUALES (fuera de esta clase): (a) generar e importar al CMS el ZIP
 *  de imágenes de Platzi —el paso 5 solo casa imágenes ya presentes en CMS—, y
 *  (b) la REINDEXACIÓN del search index de Commerce.
 * ============================================================================
 */
public with sharing class LvlupExternalProductPipeline {
    /** Resumen agregado de toda la corrida (un sub-resultado por paso). */
    public class PipelineResult {
        public LvlupPlatziProductImporter.ImportResult importResult;
        public LvlupExternalProductPublisher.PublishResult publishResult;
        public LvlupExternalProductCategoryPublisher.CategoryResult categoryResult;
        public LvlupExternalProductPricePublisher.PriceResult priceResult;
        public LvlupExternalProductMediaPublisher.MediaResult mediaResult;
        public LvlupExternalProductEntitlementPublisher.EntitlementResult entitlementResult;
    }

    /**
     * Ejecuta el pipeline completo. Pensado para llamarse desde el Queueable
     * programado o desde Anonymous Apex.
     */
    public static PipelineResult runFullPipeline() {
        PipelineResult result = new PipelineResult();

        // 1) Import (callout) -> staging. DEBE ir antes de cualquier DML.
        result.importResult = LvlupPlatziProductImporter.importFirstTenProducts();

        // 2) Publicar staging -> Product2 (crea/actualiza, SKU, inventario, reglas).
        result.publishResult = LvlupExternalProductPublisher.publishImportedProducts();

        // 3) Asignar a la categoría "Productos de Platzi".
        result.categoryResult = LvlupExternalProductCategoryPublisher.assignProductsToCategory();

        // 4) Crear/actualizar precios en Standard + price book de venta.
        result.priceResult = LvlupExternalProductPricePublisher.publishPrices();

        // 5) Casar imágenes ya importadas en CMS (crea ProductMedia). Solo DML.
        result.mediaResult = LvlupExternalProductMediaPublisher.linkProductImages();

        // 6) Entitlements para visibilidad del buyer (CommerceEntitlementProduct).
        result.entitlementResult = LvlupExternalProductEntitlementPublisher.addEntitlements();

        return result;
    }
}
