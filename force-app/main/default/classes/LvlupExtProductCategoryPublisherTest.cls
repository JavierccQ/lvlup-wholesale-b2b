/**
 * ============================================================================
 *  LvlupExtProductCategoryPublisherTest
 *  (test de LvlupExternalProductCategoryPublisher; nombre abreviado por el
 *   límite de 40 caracteres de los identificadores Apex)
 * ============================================================================
 *  Cubre: creación de asignaciones, idempotencia, criterio de selección y la
 *  entrada no-arg (resuelve la categoría por nombre; y el caso sin categoría).
 * ============================================================================
 */
@isTest
private class LvlupExtProductCategoryPublisherTest {
    /** Crea un Product2 externo + su staging Published/enlazado y devuelve el Id del producto. */
    private static Id buildPublishedExternalProduct(String externalId) {
        Product2 product = new Product2(
            Name = 'Ext ' + externalId,
            ProductCode = 'EXT-PLATZI-' + externalId,
            IsActive = true,
            Is_External_Product__c = true,
            External_Source__c = 'Platzi',
            External_Product_Id__c = externalId
        );
        insert product;

        External_Product__c ext = new External_Product__c(
            External_Id__c = externalId,
            External_Source__c = 'Platzi',
            External_Title__c = 'Ext ' + externalId,
            External_Price__c = 10,
            Sync_Status__c = 'Published',
            Salesforce_Product__c = product.Id
        );
        insert ext;
        return product.Id;
    }

    private static ProductCategory buildCategory(String name) {
        ProductCatalog catalog = new ProductCatalog(Name = 'Test Catalog ' + name);
        insert catalog;
        ProductCategory category = new ProductCategory(Name = name, CatalogId = catalog.Id);
        insert category;
        return category;
    }

    @isTest
    static void createsAssignments() {
        Id productId1 = buildPublishedExternalProduct('801');
        Id productId2 = buildPublishedExternalProduct('802');
        ProductCategory category = buildCategory('Platzi Cat A');

        Test.startTest();
        LvlupExternalProductCategoryPublisher.CategoryResult result =
            LvlupExternalProductCategoryPublisher.assignProductsToCategory(category.Id);
        Test.stopTest();

        System.assertEquals(2, result.totalProducts, 'Dos productos elegibles');
        System.assertEquals(2, result.assignmentsCreated, 'Dos asignaciones creadas');
        System.assertEquals(0, result.alreadyAssigned, 'Ninguna previa');
        System.assertEquals(0, result.errorCount, 'Sin errores');

        Set<Id> assignedProducts = new Set<Id>();
        for (ProductCategoryProduct pcp : [
            SELECT ProductId FROM ProductCategoryProduct WHERE ProductCategoryId = :category.Id
        ]) {
            assignedProducts.add(pcp.ProductId);
        }
        System.assertEquals(2, assignedProducts.size(), 'Deben existir 2 junctions');
        System.assert(assignedProducts.contains(productId1), 'Producto 801 asignado');
        System.assert(assignedProducts.contains(productId2), 'Producto 802 asignado');
    }

    @isTest
    static void isIdempotentOnReRun() {
        buildPublishedExternalProduct('803');
        ProductCategory category = buildCategory('Platzi Cat B');

        Test.startTest();
        LvlupExternalProductCategoryPublisher.assignProductsToCategory(category.Id); // crea
        LvlupExternalProductCategoryPublisher.CategoryResult second =
            LvlupExternalProductCategoryPublisher.assignProductsToCategory(category.Id); // no duplica
        Test.stopTest();

        System.assertEquals(1, second.totalProducts, 'Sigue habiendo 1 producto elegible');
        System.assertEquals(0, second.assignmentsCreated, 'No recrea la asignación');
        System.assertEquals(1, second.alreadyAssigned, 'Detecta la asignación previa');
        System.assertEquals(
            1,
            [SELECT COUNT() FROM ProductCategoryProduct WHERE ProductCategoryId = :category.Id],
            'Solo una asignación, sin duplicar'
        );
    }

    @isTest
    static void skipsIneligibleStaging() {
        ProductCategory category = buildCategory('Platzi Cat C');

        // Importado (no publicado) -> no elegible.
        Product2 product = new Product2(Name = 'Imported', IsActive = true);
        insert product;
        External_Product__c imported = new External_Product__c(
            External_Id__c = '901',
            External_Source__c = 'Platzi',
            External_Title__c = 'Imported',
            Sync_Status__c = 'Imported',
            Salesforce_Product__c = product.Id
        );
        insert imported;

        Test.startTest();
        LvlupExternalProductCategoryPublisher.CategoryResult result =
            LvlupExternalProductCategoryPublisher.assignProductsToCategory(category.Id);
        Test.stopTest();

        System.assertEquals(0, result.totalProducts, 'Ninguno elegible');
        System.assertEquals(
            0,
            [SELECT COUNT() FROM ProductCategoryProduct WHERE ProductCategoryId = :category.Id],
            'No se crean asignaciones'
        );
    }

    @isTest
    static void noArgResolvesCategoryByName() {
        Id productId = buildPublishedExternalProduct('1001');
        ProductCategory category = buildCategory('Productos de Platzi'); // coincide con CATEGORY_NAME

        Test.startTest();
        LvlupExternalProductCategoryPublisher.CategoryResult result =
            LvlupExternalProductCategoryPublisher.assignProductsToCategory();
        Test.stopTest();

        System.assertEquals(1, result.totalProducts, 'Un producto elegible');
        System.assertEquals(1, result.assignmentsCreated, 'Asignación creada vía resolución por nombre');
        System.assertEquals(
            1,
            [SELECT COUNT() FROM ProductCategoryProduct WHERE ProductCategoryId = :category.Id],
            'Asignado a la categoría resuelta'
        );
    }

    @isTest
    static void noArgReturnsZeroWhenCategoryMissing() {
        // No se crea ninguna categoría 'Productos de Platzi' -> resolución = null.
        buildPublishedExternalProduct('1002');

        Test.startTest();
        LvlupExternalProductCategoryPublisher.CategoryResult result =
            LvlupExternalProductCategoryPublisher.assignProductsToCategory();
        Test.stopTest();

        System.assertEquals(0, result.totalProducts, 'Sin categoría no se procesa nada');
        System.assertEquals(0, result.assignmentsCreated, 'Nada creado');
    }
}
