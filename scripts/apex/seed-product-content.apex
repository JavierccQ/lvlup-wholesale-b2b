/*
 * Seed/sync product content for the product information enrichment initiative
 * (phase 1, ADR-0008 / decisions D1-D4).
 *
 * These are DATA (records), not metadata (see adr/0003-commerce-data-vs-metadata-strategy.md).
 *
 * What it does, idempotently (only touches records whose values differ):
 *   1. Product2.Family for every ACTIVE INTERNAL product, mapped from its category
 *      in the official 8-category taxonomy (docs/business/product-catalog-strategy.md §4).
 *      External (Platzi) products are out of scope (phase 4) and never touched.
 *      Internal products in categories outside the taxonomy are reported, not updated.
 *   2. Full content for the Portátiles vertical slice (LVL-LAP-001..007):
 *      Brand__c, Warranty_Months__c, EAN__c and a Description built from a fixed
 *      HTML template (short B2B pitch + <ul> spec list + purchase rules rendered
 *      from the record's MOQ/increment fields). Spanish content per D4. The PDP
 *      heading only fits 3 field mappings, so MOQ and order increment live in
 *      the Description HTML instead (user decision, 2026-07-16).
 *
 * Keys: StockKeepingUnit (products) and Name (catalog/categories). No hardcoded org IDs.
 *
 * Run: sf apex run --file scripts/apex/seed-product-content.apex --target-org commerce-b2b-dev
 * MANUAL FOLLOW-UP: single search index rebuild at the end of the phase
 * (scripts/apex/rebuild-search-index.apex, REGLA-026).
 */

class LaptopContent {
    String brand;
    Integer warrantyMonths;
    String ean;
    String pitch;
    String cpu;
    String ram;
    String storage;
    String display;
    String gpu;
    String os;
    String weight;

    LaptopContent(String brand, Integer warrantyMonths, String ean, String pitch,
                  String cpu, String ram, String storage, String display,
                  String gpu, String os, String weight) {
        this.brand = brand;
        this.warrantyMonths = warrantyMonths;
        this.ean = ean;
        this.pitch = pitch;
        this.cpu = cpu;
        this.ram = ram;
        this.storage = storage;
        this.display = display;
        this.gpu = gpu;
        this.os = os;
        this.weight = weight;
    }

    // Fixed template: short B2B pitch paragraph + spec list (D1). Order is part of the recipe.
    // Purchase rules (MOQ / order increment) are rendered from the record's own
    // Min_Order_Quantity__c / Order_Increment__c so re-running the seed keeps the
    // HTML in sync with the fields the Quick Buy enforces (no duplicated source).
    String toDescriptionHtml(Decimal minQuantity, Decimal orderIncrement) {
        return '<p>' + pitch + '</p>'
            + '<ul>'
            + '<li><strong>Procesador:</strong> ' + cpu + '</li>'
            + '<li><strong>RAM:</strong> ' + ram + '</li>'
            + '<li><strong>Almacenamiento:</strong> ' + storage + '</li>'
            + '<li><strong>Pantalla:</strong> ' + display + '</li>'
            + '<li><strong>GPU:</strong> ' + gpu + '</li>'
            + '<li><strong>Sistema operativo:</strong> ' + os + '</li>'
            + '<li><strong>Peso:</strong> ' + weight + '</li>'
            + '<li><strong>Cantidad mínima:</strong> ' + formatUnits(minQuantity) + '</li>'
            + '<li><strong>Múltiplo de venta:</strong> ' + formatUnits(orderIncrement) + '</li>'
            + '</ul>';
    }

    String formatUnits(Decimal quantity) {
        Integer units = quantity == null ? 1 : quantity.intValue();
        return units == 1 ? '1 ud' : units + ' uds';
    }
}

// ---- Wiring (resolved by Name; no hardcoded org IDs) --------------------------
Id catalogId = [SELECT Id FROM ProductCatalog WHERE Name = 'LevelUp Wholesale Catalog' LIMIT 1].Id;

// Official taxonomy: category Name doubles as the Product2.Family picklist value.
Set<String> taxonomy = new Set<String>{
    'Consolas de gaming', 'Videojuegos', 'Portátiles', 'Monitores',
    'Periféricos', 'Networking', 'Accesorios', 'Bundles enterprise'
};

// ---- Portátiles vertical slice content (D3/D4) --------------------------------
Map<String, LaptopContent> contentBySku = new Map<String, LaptopContent>{
    'LVL-LAP-001' => new LaptopContent('LvlUp', 24, '8437011000019',
        'Portátil gaming de 15,6" con la mejor relación rendimiento/precio de la gama: el modelo de mayor rotación para tiendas que venden al jugador mainstream.',
        'Intel Core i7-13700H (14 núcleos)', '16 GB DDR5 4800 MHz', 'SSD NVMe 512 GB',
        '15,6" FHD IPS 144 Hz', 'NVIDIA GeForce RTX 4060 8 GB', 'Windows 11 Home', '2,3 kg'),
    'LVL-LAP-002' => new LaptopContent('LvlUp', 36, '8437011000026',
        'Portátil profesional de 14" ligero y con autonomía para toda la jornada, pensado para flotas de empresa y renovación de parque ofimático.',
        'Intel Core i5-1340P (12 núcleos)', '16 GB DDR5 4800 MHz', 'SSD NVMe 512 GB',
        '14" WUXGA IPS antirreflejos', 'Intel Iris Xe integrada', 'Windows 11 Pro', '1,4 kg'),
    'LVL-LAP-003' => new LaptopContent('LvlUp', 36, '8437011000033',
        'Workstation móvil de 17,3" para cargas de CAD, render y análisis de datos: el equipo para clientes de ingeniería y estudios creativos.',
        'Intel Core i9-13950HX (24 núcleos)', '64 GB DDR5 5600 MHz', 'SSD NVMe 2 TB',
        '17,3" UHD 4K IPS 100% sRGB', 'NVIDIA RTX A3000 12 GB', 'Windows 11 Pro', '3,1 kg'),
    'LVL-LAP-004' => new LaptopContent('LvlUp', 24, '8437011000040',
        'Buque insignia gaming de 17,3" con gráfica RTX de gama alta: margen premium para campañas de lanzamiento y clientes entusiastas.',
        'AMD Ryzen 9 7945HX (16 núcleos)', '32 GB DDR5 5200 MHz', 'SSD NVMe 1 TB',
        '17,3" QHD IPS 240 Hz', 'NVIDIA GeForce RTX 4080 12 GB', 'Windows 11 Home', '2,9 kg'),
    'LVL-LAP-005' => new LaptopContent('LvlUp', 24, '8437011000057',
        'Ultrabook de 13,3" con panel OLED y solo 1,1 kg: la opción de movilidad ejecutiva para clientes corporate y consultoras.',
        'Intel Core i7-1355U (10 núcleos)', '16 GB LPDDR5 5200 MHz', 'SSD NVMe 512 GB',
        '13,3" 2.8K OLED 90 Hz', 'Intel Iris Xe integrada', 'Windows 11 Home', '1,1 kg'),
    'LVL-LAP-006' => new LaptopContent('LvlUp', 24, '8437011000064',
        'Evolución Pro del gaming de 15,6": panel QHD a 165 Hz y RTX 4070 para el comprador entusiasta que exige más que la gama de entrada.',
        'Intel Core i9-13900H (14 núcleos)', '32 GB DDR5 5200 MHz', 'SSD NVMe 1 TB',
        '15,6" QHD IPS 165 Hz', 'NVIDIA GeForce RTX 4070 8 GB', 'Windows 11 Pro', '2,4 kg'),
    'LVL-LAP-007' => new LaptopContent('LvlUp', 36, '8437011000071',
        'Portátil business de 16" con pantalla táctil WQXGA: productividad y colaboración para equipos comerciales y de dirección.',
        'Intel Core i7-1360P (12 núcleos)', '32 GB DDR5 4800 MHz', 'SSD NVMe 1 TB',
        '16" WQXGA IPS táctil', 'Intel Iris Xe integrada', 'Windows 11 Pro', '1,8 kg')
};

// ---- 1) Family target per product, from the official taxonomy -----------------
Map<Id, String> categoryNameById = new Map<Id, String>();
for (ProductCategory pc : [
    SELECT Id, Name FROM ProductCategory
    WHERE CatalogId = :catalogId AND Name IN :taxonomy
]) {
    categoryNameById.put(pc.Id, pc.Name);
}

Map<Id, String> familyByProductId = new Map<Id, String>();
for (ProductCategoryProduct pcp : [
    SELECT ProductId, ProductCategoryId FROM ProductCategoryProduct
    WHERE ProductCategoryId IN :categoryNameById.keySet()
]) {
    familyByProductId.put(pcp.ProductId, categoryNameById.get(pcp.ProductCategoryId));
}

// ---- 2) Single pass: apply Family + laptop content where values differ ---------
List<Product2> updates = new List<Product2>();
Integer familyChanged = 0;
Integer familyCurrent = 0;
Integer laptopChanged = 0;
Integer laptopCurrent = 0;

for (Product2 p : [
    SELECT Id, StockKeepingUnit, Family, Brand__c, Warranty_Months__c, EAN__c,
           Description, Is_External_Product__c,
           Min_Order_Quantity__c, Order_Increment__c
    FROM Product2
    WHERE IsActive = true
      AND Is_External_Product__c = false
      AND (Id IN :familyByProductId.keySet() OR StockKeepingUnit IN :contentBySku.keySet())
]) {
    Boolean dirty = false;

    String targetFamily = familyByProductId.get(p.Id);
    if (targetFamily != null) {
        if (p.Family != targetFamily) {
            p.Family = targetFamily;
            dirty = true;
            familyChanged++;
        } else {
            familyCurrent++;
        }
    }

    LaptopContent c = contentBySku.get(p.StockKeepingUnit);
    if (c != null) {
        String html = c.toDescriptionHtml(p.Min_Order_Quantity__c, p.Order_Increment__c);
        if (p.Brand__c != c.brand || p.Warranty_Months__c != c.warrantyMonths
            || p.EAN__c != c.ean || p.Description != html) {
            p.Brand__c = c.brand;
            p.Warranty_Months__c = c.warrantyMonths;
            p.EAN__c = c.ean;
            p.Description = html;
            dirty = true;
            laptopChanged++;
        } else {
            laptopCurrent++;
        }
    }

    if (dirty) {
        updates.add(p);
    }
}

if (!updates.isEmpty()) {
    update updates;
}

// ---- 3) Report -----------------------------------------------------------------
System.debug('Family updated: ' + familyChanged + ' | already current: ' + familyCurrent);
System.debug('Laptop content updated: ' + laptopChanged + ' | already current: ' + laptopCurrent);
System.debug('Total records written: ' + updates.size());

// Internal active products with no category in the official taxonomy (Family left as-is).
for (Product2 p : [
    SELECT StockKeepingUnit, Name FROM Product2
    WHERE IsActive = true AND Is_External_Product__c = false
      AND Id NOT IN :familyByProductId.keySet()
]) {
    System.debug('WARN outside taxonomy, Family not set: ' + p.StockKeepingUnit + ' | ' + p.Name);
}

// Verification: the 7 laptops as persisted.
for (Product2 p : [
    SELECT StockKeepingUnit, Brand__c, Warranty_Months__c, EAN__c, Description
    FROM Product2 WHERE StockKeepingUnit IN :contentBySku.keySet()
    ORDER BY StockKeepingUnit
]) {
    System.debug('LAPTOP ' + p.StockKeepingUnit + ' | ' + p.Brand__c + ' | '
        + p.Warranty_Months__c + 'm | ' + p.EAN__c + ' | desc ' + p.Description.length() + ' chars');
}

// Verification: Family distribution over active internal products.
for (AggregateResult ar : [
    SELECT Family fam, COUNT(Id) total FROM Product2
    WHERE IsActive = true AND Is_External_Product__c = false
    GROUP BY Family ORDER BY Family
]) {
    System.debug('FAMILY ' + ar.get('fam') + ' = ' + ar.get('total'));
}
