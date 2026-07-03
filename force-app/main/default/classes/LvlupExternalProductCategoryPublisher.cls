/**
 * ============================================================================
 *  LvlupExternalProductCategoryPublisher  (asignación a categoría de Commerce)
 * ============================================================================
 *  Responsabilidad ÚNICA: asignar los Product2 ya publicados desde Platzi a una
 *  categoría de Commerce (`ProductCategory`) creando registros del junction
 *  `ProductCategoryProduct` (Product2 <-> ProductCategory dentro de un catálogo).
 *
 *  Por defecto apunta a la categoría "Productos de Platzi". Ese nombre es el
 *  ÚNICO dato de negocio acoplado: es el requisito explícito y no existe otra
 *  forma de "descubrir la categoría de Platzi" (no hay relación de metadata que
 *  lo indique). Si la categoría se renombra, se ajusta la constante CATEGORY_NAME
 *  o se llama al método core pasando el Id directamente.
 *
 *  Idempotente: consulta las asignaciones existentes y solo crea las que faltan,
 *  así re-ejecutar no duplica. NO crea PricebookEntry, CMS, inventario ni publica
 *  nada más; solo ProductCategoryProduct.
 * ============================================================================
 */
public with sharing class LvlupExternalProductCategoryPublisher {
    private static final String SOURCE_PLATZI = 'Platzi';
    private static final String STATUS_PUBLISHED = 'Published';
    private static final String CATEGORY_NAME = 'Productos de Platzi';

    /** Resumen del resultado de la asignación. */
    public class CategoryResult {
        public Integer totalProducts = 0;
        public Integer assignmentsCreated = 0;
        public Integer alreadyAssigned = 0;
        public Integer errorCount = 0;
    }

    /**
     * Entrada principal: resuelve la categoría "Productos de Platzi" por nombre
     * y asigna los productos externos publicados.
     */
    public static CategoryResult assignProductsToCategory() {
        return assignProductsToCategory(resolveCategoryId());
    }

    /**
     * Core testeable: asigna los Product2 externos publicados a la categoría dada.
     *
     * @param categoryId categoría destino (si es null o no existe, no hace nada).
     * @return resumen con totales y errores.
     */
    public static CategoryResult assignProductsToCategory(Id categoryId) {
        CategoryResult result = new CategoryResult();
        if (categoryId == null) {
            return result;
        }

        // Confirmar que la categoría existe. El CatalogId del junction NO se
        // escribe: la plataforma lo deriva automáticamente de la categoría.
        Boolean categoryExists = false;
        for (ProductCategory category : [
            SELECT Id FROM ProductCategory WHERE Id = :categoryId LIMIT 1
        ]) {
            categoryExists = true;
        }
        if (!categoryExists) {
            return result; // la categoría no existe
        }

        // 1) Product2 de los staging publicados y enlazados.
        Set<Id> productIds = new Set<Id>();
        for (External_Product__c ext : [
            SELECT Salesforce_Product__c
            FROM External_Product__c
            WHERE Sync_Status__c = :STATUS_PUBLISHED
              AND External_Source__c = :SOURCE_PLATZI
              AND Salesforce_Product__c != null
        ]) {
            productIds.add(ext.Salesforce_Product__c);
        }
        if (productIds.isEmpty()) {
            return result;
        }
        result.totalProducts = productIds.size();

        // 2) Idempotencia: qué productos ya están en ESTA categoría.
        Set<Id> alreadyAssigned = new Set<Id>();
        for (ProductCategoryProduct pcp : [
            SELECT ProductId
            FROM ProductCategoryProduct
            WHERE ProductCategoryId = :categoryId
              AND ProductId IN :productIds
        ]) {
            alreadyAssigned.add(pcp.ProductId);
        }
        result.alreadyAssigned = alreadyAssigned.size();

        // 3) Crear las asignaciones que faltan (insert parcial).
        List<ProductCategoryProduct> toInsert = new List<ProductCategoryProduct>();
        for (Id productId : productIds) {
            if (!alreadyAssigned.contains(productId)) {
                toInsert.add(new ProductCategoryProduct(
                    ProductCategoryId = categoryId,
                    ProductId = productId
                ));
            }
        }
        if (!toInsert.isEmpty()) {
            List<Database.SaveResult> saveResults = Database.insert(toInsert, false);
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    result.assignmentsCreated++;
                } else {
                    result.errorCount++;
                }
            }
        }
        return result;
    }

    /** Resuelve el Id de la categoría destino por nombre. */
    private static Id resolveCategoryId() {
        for (ProductCategory category : [
            SELECT Id FROM ProductCategory WHERE Name = :CATEGORY_NAME LIMIT 1
        ]) {
            return category.Id;
        }
        return null;
    }
}
