/*
 * Seed example products for the LevelUp Wholesale B2B store (~50 products).
 *
 * These are DATA (records), not metadata (see adr/0003-commerce-data-vs-metadata-strategy.md).
 * Names/SKUs follow docs/business/product-catalog-strategy.md (§6), expanded to ~50.
 *
 * Builds the full "sellable product" chain per product:
 *   1. Product2                                  (the product)
 *   2. PricebookEntry in Standard Price Book      (required base price = list price)
 *   3. PricebookEntry in LevelUp Wholesale PB      (price the buyer pays = sale price)
 *   4. PricebookEntry in Strikethrough PB          (crossed-out list price)
 *   5. ProductCategoryProduct                      (puts the product in its category)
 *
 * Visibility (CommerceEntitlementPolicy "All Access") already covers all products,
 * so no per-product entitlement records are created.
 *
 * Idempotent: keyed by SKU (StockKeepingUnit) and by (pricebook, product) /
 * (category, product) uniqueness, so re-running only fills what is missing.
 * Atomic: anonymous Apex runs in one transaction; any failure rolls everything back.
 *
 * Run: sf apex run --file scripts/apex/seed-products.apex --target-org commerce-b2b-dev
 * MANUAL FOLLOW-UP: rebuild the store search index (Commerce app > store > Search > Rebuild Index).
 */

// ---- Wiring (verified in org) -------------------------------------------------
Id catalogId   = '0ZSgK0000004Pe9WAE'; // LevelUp Wholesale Catalog
Id stdPbId     = '01sgK000007644wQAA'; // Standard Price Book (IsStandard = true)
Id sellPbId    = '01sgK000007E9diQAC'; // LevelUp Wholesale Price Book (Buyer Group price)
Id strikePbId  = '01sgK000007E9dhQAC'; // LevelUp Wholesale Strikethrough Price Book

// ---- Category name -> Id ------------------------------------------------------
Map<String, Id> catByName = new Map<String, Id>();
for (ProductCategory pc : [SELECT Id, Name FROM ProductCategory WHERE CatalogId = :catalogId]) {
    catByName.put(pc.Name, pc.Id);
}

// ---- Product specs: "SKU|Name|Category|listPrice|salePrice" -------------------
List<String> specs = new List<String>{
    // Consolas de gaming (7)
    'LVL-CON-001|LvlUp Console Pro X|Consolas de gaming|549|499',
    'LVL-CON-002|LvlUp Console Go (Portátil)|Consolas de gaming|399|369',
    'LVL-CON-003|LvlUp Console Pro X Starter Pack|Consolas de gaming|629|579',
    'LVL-CON-004|LvlUp Console Pro X Digital|Consolas de gaming|449|419',
    'LVL-CON-005|RetroStation Mini|Consolas de gaming|129|109',
    'LVL-CON-006|LvlUp Console Pro X + 2 Mandos|Consolas de gaming|599|549',
    'LVL-CON-007|CloudPlay Streaming Box|Consolas de gaming|199|179',
    // Videojuegos (8)
    'LVL-VGM-001|Galaxy Raiders (Físico)|Videojuegos|69|59',
    'LVL-VGM-002|Galaxy Raiders (Digital)|Videojuegos|69|55',
    'LVL-VGM-003|Speed Legends Bundle|Videojuegos|89|69',
    'LVL-VGM-004|Dungeon Quest VII|Videojuegos|59|49',
    'LVL-VGM-005|Pixel Warriors Arena|Videojuegos|49|39',
    'LVL-VGM-006|Galaxy Raiders Deluxe (Preventa)|Videojuegos|79|74',
    'LVL-VGM-007|Farm Tycoon Simulator|Videojuegos|39|29',
    'LVL-VGM-008|Shadow Strike Collection|Videojuegos|99|79',
    // Portátiles (7)
    'LVL-LAP-001|LvlUp Gaming Laptop 15|Portátiles|1499|1349',
    'LVL-LAP-002|LvlUp Business Laptop 14|Portátiles|1099|999',
    'LVL-LAP-003|LvlUp Workstation 17|Portátiles|2199|1999',
    'LVL-LAP-004|LvlUp Gaming Laptop 17 RTX|Portátiles|1899|1699',
    'LVL-LAP-005|LvlUp Ultrabook 13|Portátiles|999|899',
    'LVL-LAP-006|LvlUp Gaming Laptop 15 Pro|Portátiles|1699|1549',
    'LVL-LAP-007|LvlUp Business Laptop 16 Touch|Portátiles|1299|1179',
    // Monitores (6)
    'LVL-MON-001|LvlUp 27" Gaming Monitor 165Hz|Monitores|329|289',
    'LVL-MON-002|LvlUp 24" Pro Monitor|Monitores|199|169',
    'LVL-MON-003|LvlUp 34" Curved 4K|Monitores|699|629',
    'LVL-MON-004|LvlUp 32" 4K Creator|Monitores|549|499',
    'LVL-MON-005|LvlUp 27" QHD IPS|Monitores|279|249',
    'LVL-MON-006|LvlUp 49" SuperWide|Monitores|999|899',
    // Periféricos (8)
    'LVL-PER-001|LvlUp Mechanical Keyboard|Periféricos|119|99',
    'LVL-PER-002|LvlUp Pro Gaming Mouse|Periféricos|69|59',
    'LVL-PER-003|LvlUp Wireless Headset|Periféricos|99|85',
    'LVL-PER-004|LvlUp Wireless Controller|Periféricos|59|49',
    'LVL-PER-005|LvlUp RGB Mousepad XL|Periféricos|29|24',
    'LVL-PER-006|LvlUp Streaming Webcam 4K|Periféricos|89|75',
    'LVL-PER-007|LvlUp USB Microphone Studio|Periféricos|109|94',
    'LVL-PER-008|LvlUp Low-Profile Keyboard|Periféricos|99|84',
    // Networking (5)
    'LVL-NET-001|LvlUp WiFi 6 Router|Networking|159|139',
    'LVL-NET-002|LvlUp 8-Port Gigabit Switch|Networking|79|69',
    'LVL-NET-003|LvlUp Mesh WiFi 6 (3-pack)|Networking|279|249',
    'LVL-NET-004|LvlUp PoE Access Point|Networking|129|109',
    'LVL-NET-005|LvlUp 24-Port Rack Switch|Networking|349|309',
    // Accesorios (6)
    'LVL-ACC-001|LvlUp USB-C Cable 2m|Accesorios|19|14',
    'LVL-ACC-002|LvlUp Monitor Stand|Accesorios|49|39',
    'LVL-ACC-003|LvlUp 65W USB-C Charger|Accesorios|39|31',
    'LVL-ACC-004|LvlUp Laptop Backpack Pro|Accesorios|59|49',
    'LVL-ACC-005|LvlUp HDMI 2.1 Cable 3m|Accesorios|24|18',
    'LVL-ACC-006|LvlUp USB-C Hub 7-in-1|Accesorios|69|55',
    // Bundles enterprise (3)
    'LVL-BND-001|LvlUp Reseller Starter Bundle|Bundles enterprise|1299|1149',
    'LVL-BND-002|LvlUp Office Setup Kit|Bundles enterprise|2499|2249',
    'LVL-BND-003|LvlUp Event Gaming Kit|Bundles enterprise|3999|3599'
};

// ---- 1) Product2 -------------------------------------------------------------
Set<String> skus = new Set<String>();
for (String s : specs) { skus.add(s.split('\\|')[0]); }

Map<String, Product2> prodBySku = new Map<String, Product2>();
for (Product2 p : [SELECT Id, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN :skus]) {
    prodBySku.put(p.StockKeepingUnit, p);
}

List<Product2> newProducts = new List<Product2>();
for (String s : specs) {
    List<String> f = s.split('\\|');
    String sku = f[0];
    if (!prodBySku.containsKey(sku)) {
        newProducts.add(new Product2(
            Name = f[1],
            StockKeepingUnit = sku,
            ProductCode = sku,
            Description = f[1] + ' — distribución mayorista B2B.',
            IsActive = true
        ));
    }
}
if (!newProducts.isEmpty()) { insert newProducts; }

// Refresh SKU -> product Id (now includes inserted ones)
prodBySku.clear();
for (Product2 p : [SELECT Id, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN :skus]) {
    prodBySku.put(p.StockKeepingUnit, p);
}

// ---- 2) Standard PricebookEntry (list price) ---------------------------------
Set<Id> prodIds = new Set<Id>();
for (Product2 p : prodBySku.values()) { prodIds.add(p.Id); }

Map<Id, Set<Id>> existingPbeByPb = new Map<Id, Set<Id>>{
    stdPbId => new Set<Id>(), sellPbId => new Set<Id>(), strikePbId => new Set<Id>()
};
for (PricebookEntry pbe : [
    SELECT Product2Id, Pricebook2Id FROM PricebookEntry
    WHERE Product2Id IN :prodIds AND Pricebook2Id IN :existingPbeByPb.keySet()
]) {
    existingPbeByPb.get(pbe.Pricebook2Id).add(pbe.Product2Id);
}

List<PricebookEntry> stdEntries = new List<PricebookEntry>();
for (String s : specs) {
    List<String> f = s.split('\\|');
    Id pid = prodBySku.get(f[0]).Id;
    if (!existingPbeByPb.get(stdPbId).contains(pid)) {
        stdEntries.add(new PricebookEntry(
            Pricebook2Id = stdPbId, Product2Id = pid,
            UnitPrice = Decimal.valueOf(f[3]), IsActive = true
        ));
    }
}
if (!stdEntries.isEmpty()) { insert stdEntries; }

// ---- 3 & 4) Selling + Strikethrough PricebookEntry ---------------------------
List<PricebookEntry> custEntries = new List<PricebookEntry>();
for (String s : specs) {
    List<String> f = s.split('\\|');
    Id pid = prodBySku.get(f[0]).Id;
    Decimal listPrice = Decimal.valueOf(f[3]);
    Decimal salePrice = Decimal.valueOf(f[4]);
    if (!existingPbeByPb.get(sellPbId).contains(pid)) {
        custEntries.add(new PricebookEntry(
            Pricebook2Id = sellPbId, Product2Id = pid,
            UnitPrice = salePrice, UseStandardPrice = false, IsActive = true
        ));
    }
    if (!existingPbeByPb.get(strikePbId).contains(pid)) {
        custEntries.add(new PricebookEntry(
            Pricebook2Id = strikePbId, Product2Id = pid,
            UnitPrice = listPrice, UseStandardPrice = false, IsActive = true
        ));
    }
}
if (!custEntries.isEmpty()) { insert custEntries; }

// ---- 5) ProductCategoryProduct (assign to category) --------------------------
Set<Id> alreadyLinked = new Set<Id>();
for (ProductCategoryProduct pcp : [
    SELECT ProductId FROM ProductCategoryProduct WHERE ProductId IN :prodIds
]) {
    alreadyLinked.add(pcp.ProductId);
}

List<ProductCategoryProduct> links = new List<ProductCategoryProduct>();
for (String s : specs) {
    List<String> f = s.split('\\|');
    Id pid = prodBySku.get(f[0]).Id;
    Id catId = catByName.get(f[2]);
    if (catId != null && !alreadyLinked.contains(pid)) {
        links.add(new ProductCategoryProduct(ProductCategoryId = catId, ProductId = pid));
    }
}
if (!links.isEmpty()) { insert links; }

System.debug('Products in specs: ' + specs.size());
System.debug('New Product2 inserted: ' + newProducts.size());
System.debug('Standard PBE inserted: ' + stdEntries.size());
System.debug('Selling+Strikethrough PBE inserted: ' + custEntries.size());
System.debug('Category links inserted: ' + links.size());
