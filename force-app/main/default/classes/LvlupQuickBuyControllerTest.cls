/**
 * ============================================================================
 *  LvlupQuickBuyControllerTest  (clase de PRUEBAS del controller)
 * ============================================================================
 *  Salesforce OBLIGA a escribir tests para subir Apex a producción: exige al
 *  menos 75% de líneas cubiertas por tests. Este test cubre el controller al 100%.
 *
 *  - `@isTest` sobre la clase → marca toda la clase como código de prueba (no
 *    cuenta para los límites de almacenamiento de código de la org).
 *  - `private` → las clases de test suelen ser privadas (no las usa nadie más).
 *  - Importante: los tests NO ven los datos reales de la org por defecto; cada
 *    test crea SUS PROPIOS datos (aislamiento). Al terminar, esos datos se borran.
 * ============================================================================
 */
@isTest
private class LvlupQuickBuyControllerTest {
    // `@isTest` sobre un método → es un caso de prueba. `static void` siempre.
    @isTest
    static void getProductPurchaseInfoReturnsFieldsAndPrice() {
        // ── ARRANGE (preparar datos de prueba) ──────────────────────────────
        // Creamos un producto en memoria y luego `insert` lo guarda en la BD de test.
        Product2 product = new Product2(
            Name = 'Test Quick Buy Product',
            StockKeepingUnit = 'LVL-TEST-001',
            IsActive = true,
            Inventory_Quantity__c = 120,  // stock
            Min_Order_Quantity__c = 5,    // MOQ
            Order_Increment__c = 5,       // múltiplo
            Max_Order_Quantity__c = 500   // máximo
        );
        insert product;

        // El precio necesita un PricebookEntry. En tests no se puede usar el
        // price book estándar real directamente: se obtiene su Id con
        // Test.getStandardPricebookId().
        PricebookEntry entry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = 419,
            IsActive = true
        );
        insert entry;

        // ── ACT (ejecutar lo que se prueba) ─────────────────────────────────
        // Test.startTest()/stopTest() delimitan el código bajo prueba y resetean
        // los límites de la plataforma (governor limits) para medirlo en limpio.
        Test.startTest();
        LvlupQuickBuyController.ProductPurchaseInfo info =
            LvlupQuickBuyController.getProductPurchaseInfo(product.Id);
        Test.stopTest();

        // ── ASSERT (verificar el resultado) ─────────────────────────────────
        // System.assertEquals(esperado, real, mensajeSiFalla). Si no coinciden,
        // el test falla y muestra el mensaje.
        System.assertEquals(product.Id, info.productId, 'productId should match');
        System.assertEquals('LVL-TEST-001', info.sku, 'sku should match');
        System.assertEquals(120, info.stock, 'stock comes from the inventory field');
        System.assertEquals(5, info.minQuantity, 'MOQ comes from the rule field');
        System.assertEquals(5, info.increment, 'increment comes from the rule field');
        System.assertEquals(500, info.maxQuantity, 'max comes from the rule field');
        System.assertEquals(419, info.unitPrice, 'price comes from the pricebook entry');
    }
}
