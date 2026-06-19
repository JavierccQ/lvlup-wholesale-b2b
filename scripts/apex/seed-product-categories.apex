/*
 * Seed/sync top-level ProductCategory records for the LevelUp Wholesale catalog.
 *
 * These are DATA (records), not metadata (see adr/0003-commerce-data-vs-metadata-strategy.md).
 * Mirrors the 8-category taxonomy from docs/business/product-catalog-strategy.md (§4).
 *
 * Idempotent upsert keyed by Name under the root category: existing categories are
 * updated (Description, SortOrder, IsNavigational) and missing ones are inserted, so
 * the script can be re-run safely as the source of truth for the navigable taxonomy.
 *
 * Run: sf apex run --file scripts/apex/seed-product-categories.apex --target-org commerce-b2b-dev
 */
Id catalogId = '0ZSgK0000004Pe9WAE';      // LevelUp Wholesale Catalog
Id rootCategoryId = '0ZGgK00000059dlWAA'; // Catalog root category

// The data-source-driven navigation menu ("Storefront Categories") renders the root
// category as the top-level menu item and its children as the dropdown. The menu label
// is the root category Name, so we name the root "Categorías" to drive the header label.
String rootLabel = 'Categorías';
ProductCategory root = [SELECT Id, Name FROM ProductCategory WHERE Id = :rootCategoryId LIMIT 1];
if (root.Name != rootLabel) {
    root.Name = rootLabel;
    update root;
    System.debug('Renamed root category to: ' + rootLabel);
}

// Ordered taxonomy; index drives SortOrder so navigation order is deterministic.
List<Map<String, String>> taxonomy = new List<Map<String, String>>{
    new Map<String, String>{ 'name' => 'Consolas de gaming', 'desc' => 'Consolas de videojuegos y packs asociados.' },
    new Map<String, String>{ 'name' => 'Videojuegos',        'desc' => 'Títulos físicos y digitales, preventas y bundles.' },
    new Map<String, String>{ 'name' => 'Portátiles',         'desc' => 'Portátiles gaming, business y workstation.' },
    new Map<String, String>{ 'name' => 'Monitores',          'desc' => 'Monitores gaming y profesionales.' },
    new Map<String, String>{ 'name' => 'Periféricos',        'desc' => 'Teclados, ratones, auriculares, mandos y webcams.' },
    new Map<String, String>{ 'name' => 'Networking',         'desc' => 'Routers, switches, access points y cableado.' },
    new Map<String, String>{ 'name' => 'Accesorios',         'desc' => 'Cables, soportes, cargadores y adaptadores.' },
    new Map<String, String>{ 'name' => 'Bundles enterprise', 'desc' => 'Kits preconfigurados para tiendas, oficinas, eventos y renovación tecnológica.' }
};

Map<String, ProductCategory> existingByName = new Map<String, ProductCategory>();
for (ProductCategory pc : [
    SELECT Id, Name, Description, SortOrder, IsNavigational
    FROM ProductCategory
    WHERE CatalogId = :catalogId AND ParentCategoryId = :rootCategoryId
]) {
    existingByName.put(pc.Name, pc);
}

List<ProductCategory> toUpsert = new List<ProductCategory>();
for (Integer i = 0; i < taxonomy.size(); i++) {
    String name = taxonomy[i].get('name');
    ProductCategory pc = existingByName.get(name);
    if (pc == null) {
        pc = new ProductCategory(
            Name = name,
            CatalogId = catalogId,
            ParentCategoryId = rootCategoryId
        );
    }
    pc.Description = taxonomy[i].get('desc');
    pc.SortOrder = i + 1;
    pc.IsNavigational = true;
    toUpsert.add(pc);
}

upsert toUpsert;
System.debug('Upserted ' + toUpsert.size() + ' categories.');

for (ProductCategory pc : [
    SELECT Id, Name, SortOrder, IsNavigational FROM ProductCategory
    WHERE CatalogId = :catalogId AND ParentCategoryId = :rootCategoryId
    ORDER BY SortOrder
]) {
    System.debug('CATEGORY ' + pc.SortOrder + ' | ' + pc.Name + ' | ' + pc.Id + ' | navigational=' + pc.IsNavigational);
}
