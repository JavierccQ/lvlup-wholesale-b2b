// Adds every catalog product to the store's entitlement policy so buyers can
// see them. The seed scripts created products + prices + categories but never
// entitled them (only the manually-created LVL-CEL-001 was). Idempotent.

final Id POLICY_ID = '1CegK00000047MHSAY';          // All Access for LevelUp Wholesale
final Id STORE_PRICEBOOK_ID = '01sgK000007E9diQAC'; // LevelUp Wholesale Price Book

// Products already entitled
Set<Id> alreadyEntitled = new Set<Id>();
for (CommerceEntitlementProduct cep : [
    SELECT ProductId FROM CommerceEntitlementProduct WHERE PolicyId = :POLICY_ID
]) {
    alreadyEntitled.add(cep.ProductId);
}

// Catalog products = those priced in the store's price book
Set<Id> catalogProductIds = new Set<Id>();
for (PricebookEntry pbe : [
    SELECT Product2Id FROM PricebookEntry
    WHERE Pricebook2Id = :STORE_PRICEBOOK_ID AND IsActive = true
]) {
    catalogProductIds.add(pbe.Product2Id);
}

List<CommerceEntitlementProduct> toInsert = new List<CommerceEntitlementProduct>();
for (Id productId : catalogProductIds) {
    if (!alreadyEntitled.contains(productId)) {
        toInsert.add(new CommerceEntitlementProduct(
            PolicyId = POLICY_ID,
            ProductId = productId
        ));
    }
}
insert toInsert;

System.debug('Catalog products: ' + catalogProductIds.size());
System.debug('Newly entitled: ' + toInsert.size());
