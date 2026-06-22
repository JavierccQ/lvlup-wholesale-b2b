// Seed initial simulated inventory + B2B purchase rules on active products.
// Idempotent: re-running overwrites the same deterministic values.
// Values are varied on purpose to exercise the Contextual Quick Buy UI states
// (out of stock / low stock / in stock) and the MOQ + order-increment rules.

List<Product2> products = [
    SELECT Id, StockKeepingUnit
    FROM Product2
    WHERE IsActive = true
    ORDER BY StockKeepingUnit
];

Integer index = 0;
for (Product2 p : products) {
    Integer stockBucket = Math.mod(index, 10);
    if (stockBucket == 0) {
        p.Inventory_Quantity__c = 0;        // out of stock
    } else if (stockBucket == 1) {
        p.Inventory_Quantity__c = 8;        // low stock
    } else if (stockBucket < 5) {
        p.Inventory_Quantity__c = 75;       // medium stock
    } else {
        p.Inventory_Quantity__c = 300;      // healthy stock
    }

    // One in four products is sold in packs of 5 (MOQ + multiple); the rest unitary.
    if (Math.mod(index, 4) == 0) {
        p.Min_Order_Quantity__c = 5;
        p.Order_Increment__c = 5;
    } else {
        p.Min_Order_Quantity__c = 1;
        p.Order_Increment__c = 1;
    }

    p.Max_Order_Quantity__c = 500;
    index++;
}

update products;
System.debug('Seeded inventory + purchase rules on ' + products.size() + ' active products.');
