/**
 * ============================================================================
 *  LvlupProductImageController  (back-end del LWC lvlupProductImage)
 * ============================================================================
 *  Devuelve, para los productos de integración (externos), la URL REAL de su
 *  imagen tal como vino del sistema de origen (Platzi), guardada en
 *  External_Product__c.External_Image_URL__c.
 *
 *  Por qué existe: el storefront NO expone esa URL por el índice de búsqueda
 *  (`{!Item.defaultImage.url}` llega vacío), así que el LWC la pide aquí por SKU
 *  y la usa per-producto. Internos NO aparecen en este map -> el LWC usa su
 *  fallback de siempre (GitHub por SKU). Así cada producto referencia su imagen
 *  desde SU fuente, sin copiar nada.
 *
 *  ── SHARING ────────────────────────────────────────────────────────────────
 *  `without sharing`: el comprador del storefront no necesariamente comparte los
 *  registros staging External_Product__c. Las URLs de imagen son públicas, así
 *  que leerlas en modo sistema es seguro. (El acceso a la CLASE se concede al
 *  perfil del buyer vía el permission set LvlUp_Quick_Buy_Buyer.)
 * ============================================================================
 */
public without sharing class LvlupProductImageController {
    private static final String SOURCE_PLATZI = 'Platzi';
    private static final String STATUS_PUBLISHED = 'Published';

    /**
     * @return Map de SKU (Product2.StockKeepingUnit) -> URL externa de la imagen,
     *         para los productos externos publicados y con imagen. Cacheable: una
     *         sola llamada se comparte (y cachea) entre todas las tarjetas de la grilla.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getExternalImageUrls() {
        Map<String, String> urlsBySku = new Map<String, String>();
        for (External_Product__c ext : [
            SELECT Salesforce_Product__r.StockKeepingUnit, External_Image_URL__c
            FROM External_Product__c
            WHERE Sync_Status__c = :STATUS_PUBLISHED
              AND External_Source__c = :SOURCE_PLATZI
              AND External_Image_URL__c != null
              AND Salesforce_Product__c != null
              AND Salesforce_Product__r.StockKeepingUnit != null
        ]) {
            urlsBySku.put(ext.Salesforce_Product__r.StockKeepingUnit, ext.External_Image_URL__c);
        }
        return urlsBySku;
    }
}
