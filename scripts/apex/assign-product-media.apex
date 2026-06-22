/*
 * Link each product to its URL-based CMS image via ProductMedia (List + Detail groups).
 *
 * Images are sfdc_cms__image content whose source is an external GitHub raw URL
 * (0 File Storage). They are titled by SKU, so ManagedContent.Name == Product2.
 * StockKeepingUnit (ASCII match, no accent/normalization issues).
 *
 * Idempotent: skips a (product, group) pair that already has a ProductMedia, so
 * LVL-CON-001 (created/linked manually first) is left untouched and re-runs are safe.
 *
 * Run: sf apex run --file scripts/apex/assign-product-media.apex --target-org commerce-b2b-dev
 * After: publish the CMS content + rebuild the search index (Settings | Search | Update).
 */
Id listingGrp = '2mggK000006SAsGQAW'; // Product List Image (PLP)
Id detailGrp  = '2mggK000006SAsFQAW'; // Product Detail Images (PDP)
Id spaceId    = '0ZugK000005b2T0SAI'; // LevelUp Wholesale Managed Content Space

Map<String, Id> mcBySku = new Map<String, Id>();
for (ManagedContent mc : [
    SELECT Id, Name FROM ManagedContent
    WHERE AuthoredManagedContentSpaceId = :spaceId
      AND ContentTypeFullyQualifiedName = 'sfdc_cms__image'
      AND Name LIKE 'LVL-%'
]) {
    mcBySku.put(mc.Name, mc.Id);
}

Map<String, Id> prodBySku = new Map<String, Id>();
for (Product2 p : [SELECT Id, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit LIKE 'LVL-%']) {
    prodBySku.put(p.StockKeepingUnit, p.Id);
}

Set<Id> pids = new Set<Id>(prodBySku.values());
Set<String> have = new Set<String>();
for (ProductMedia pm : [SELECT ProductId, ElectronicMediaGroupId FROM ProductMedia WHERE ProductId IN :pids]) {
    have.add(pm.ProductId + '|' + pm.ElectronicMediaGroupId);
}

List<ProductMedia> toIns = new List<ProductMedia>();
List<String> missing = new List<String>();
for (String sku : prodBySku.keySet()) {
    Id mid = mcBySku.get(sku);
    if (mid == null) { missing.add(sku); continue; }
    Id pid = prodBySku.get(sku);
    if (!have.contains(pid + '|' + listingGrp)) toIns.add(new ProductMedia(ProductId=pid, ElectronicMediaId=mid, ElectronicMediaGroupId=listingGrp, SortOrder=0));
    if (!have.contains(pid + '|' + detailGrp))  toIns.add(new ProductMedia(ProductId=pid, ElectronicMediaId=mid, ElectronicMediaGroupId=detailGrp,  SortOrder=0));
}
if (!toIns.isEmpty()) insert toIns;

System.debug('ProductMedia insertados: ' + toIns.size());
System.debug('Productos totales: ' + prodBySku.size() + ' | con imagen: ' + (prodBySku.size() - missing.size()));
System.debug('Productos SIN imagen CMS: ' + (missing.isEmpty() ? 'ninguno' : String.valueOf(missing)));
