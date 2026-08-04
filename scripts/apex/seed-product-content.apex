/*
 * Seed/sync product content for the product information enrichment initiative
 * (phases 1-3, ADR-0008 / decisions D1-D4) — BATCH 1 of 2.
 *
 * The curated content is split across two idempotent script files because an
 * anonymous Apex block has a hard size limit (~32 KB) and the full 9-category
 * catalogue exceeds it. Run BOTH files (order does not matter, each is idempotent):
 *   1. scripts/apex/seed-product-content.apex    -> Portátiles, SmartPhones, Consolas, Videojuegos
 *   2. scripts/apex/seed-product-content-2.apex   -> Monitores, Periféricos, Networking, Accesorios, Bundles enterprise
 *
 * These are DATA (records), not metadata (see adr/0003-commerce-data-vs-metadata-strategy.md).
 *
 * What it does, idempotently (only touches records whose values differ):
 *   1. Product2.Family for every ACTIVE INTERNAL product, mapped from its category
 *      in the official 9-category taxonomy (docs/business/product-catalog-strategy.md
 *      §4; SmartPhones added 2026-07-27). External (Platzi) products are out of scope
 *      (phase 4) and never touched. Internal products in categories outside the
 *      taxonomy are reported, not updated.
 *   2. Curated content per product via a per-type content class implementing the
 *      ProductContent interface: LaptopContent for Portátiles (LVL-LAP-001..007),
 *      PhoneContent for the SmartPhones EPhone (LVL-CEL-001), and the generic
 *      SpecContent (ordered spec list) for the phase-3 categories — each category
 *      picks type-appropriate attributes, no forced schema. Each sets Brand__c,
 *      Warranty_Months__c, EAN__c and a Description built from a type-specific HTML
 *      template (short B2B pitch + <ul> spec list + purchase rules rendered from the
 *      standard PurchaseQuantityRule via the ProductQuantityRule junction, ADR-0009
 *      — the single source of truth the Quick Buy also reads). Spanish content per
 *      D4. The PDP heading only fits 3 field mappings, so MOQ and order increment
 *      live in the Description HTML instead (user decision, 2026-07-16).
 *
 * Keys: StockKeepingUnit (products) and Name (catalog/categories). No hardcoded org IDs.
 *
 * Run: sf apex run --file scripts/apex/seed-product-content.apex --target-org commerce-b2b-dev
 * MANUAL FOLLOW-UP: single search index rebuild at the end of the phase
 * (scripts/apex/rebuild-search-index.apex, REGLA-026).
 */

// Per-type product content: each category implements this so the spec set is
// appropriate for the product type (no forced laptop schema — runbook §4 Paso 2).
interface ProductContent {
  String getBrand();
  Integer getWarrantyMonths();
  String getEan();
  String toDescriptionHtml(Decimal minQuantity, Decimal orderIncrement);
}

class LaptopContent implements ProductContent {
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

  LaptopContent(
    String brand,
    Integer warrantyMonths,
    String ean,
    String pitch,
    String cpu,
    String ram,
    String storage,
    String display,
    String gpu,
    String os,
    String weight
  ) {
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
  // Purchase rules (MOQ / order increment) are rendered from the standard
  // PurchaseQuantityRule associated to the product (ADR-0009), so the HTML stays
  // in sync with the single source of truth the Quick Buy also enforces.
  public String toDescriptionHtml(Decimal minQuantity, Decimal orderIncrement) {
    return '<p>' +
      pitch +
      '</p>' +
      '<ul>' +
      '<li><strong>Procesador:</strong> ' +
      cpu +
      '</li>' +
      '<li><strong>RAM:</strong> ' +
      ram +
      '</li>' +
      '<li><strong>Almacenamiento:</strong> ' +
      storage +
      '</li>' +
      '<li><strong>Pantalla:</strong> ' +
      display +
      '</li>' +
      '<li><strong>GPU:</strong> ' +
      gpu +
      '</li>' +
      '<li><strong>Sistema operativo:</strong> ' +
      os +
      '</li>' +
      '<li><strong>Peso:</strong> ' +
      weight +
      '</li>' +
      '<li><strong>Cantidad mínima:</strong> ' +
      formatUnits(minQuantity) +
      '</li>' +
      '<li><strong>Múltiplo de venta:</strong> ' +
      formatUnits(orderIncrement) +
      '</li>' +
      '</ul>';
  }

  String formatUnits(Decimal quantity) {
    Integer units = quantity == null ? 1 : quantity.intValue();
    return units == 1 ? '1 ud' : units + ' uds';
  }

  public String getBrand() {
    return brand;
  }
  public Integer getWarrantyMonths() {
    return warrantyMonths;
  }
  public String getEan() {
    return ean;
  }
}

// Smartphone content: phone-appropriate attributes (screen, camera, battery,
// available colours) — deliberately omits laptop-only specs like GPU/weight.
class PhoneContent implements ProductContent {
  String brand;
  Integer warrantyMonths;
  String ean;
  String pitch;
  String display;
  String chip;
  String ram;
  String storage;
  String camera;
  String battery;
  String os;
  String connectivity;
  String colors;

  PhoneContent(
    String brand,
    Integer warrantyMonths,
    String ean,
    String pitch,
    String display,
    String chip,
    String ram,
    String storage,
    String camera,
    String battery,
    String os,
    String connectivity,
    String colors
  ) {
    this.brand = brand;
    this.warrantyMonths = warrantyMonths;
    this.ean = ean;
    this.pitch = pitch;
    this.display = display;
    this.chip = chip;
    this.ram = ram;
    this.storage = storage;
    this.camera = camera;
    this.battery = battery;
    this.os = os;
    this.connectivity = connectivity;
    this.colors = colors;
  }

  public String toDescriptionHtml(Decimal minQuantity, Decimal orderIncrement) {
    return '<p>' +
      pitch +
      '</p>' +
      '<ul>' +
      '<li><strong>Pantalla:</strong> ' +
      display +
      '</li>' +
      '<li><strong>Procesador:</strong> ' +
      chip +
      '</li>' +
      '<li><strong>RAM:</strong> ' +
      ram +
      '</li>' +
      '<li><strong>Almacenamiento:</strong> ' +
      storage +
      '</li>' +
      '<li><strong>Cámara:</strong> ' +
      camera +
      '</li>' +
      '<li><strong>Batería:</strong> ' +
      battery +
      '</li>' +
      '<li><strong>Sistema operativo:</strong> ' +
      os +
      '</li>' +
      '<li><strong>Conectividad:</strong> ' +
      connectivity +
      '</li>' +
      '<li><strong>Colores disponibles:</strong> ' +
      colors +
      '</li>' +
      '<li><strong>Cantidad mínima:</strong> ' +
      formatUnits(minQuantity) +
      '</li>' +
      '<li><strong>Múltiplo de venta:</strong> ' +
      formatUnits(orderIncrement) +
      '</li>' +
      '</ul>';
  }

  String formatUnits(Decimal quantity) {
    Integer units = quantity == null ? 1 : quantity.intValue();
    return units == 1 ? '1 ud' : units + ' uds';
  }

  public String getBrand() {
    return brand;
  }
  public Integer getWarrantyMonths() {
    return warrantyMonths;
  }
  public String getEan() {
    return ean;
  }
}

// One ordered spec (label -> value) rendered as a <li> in the Description.
class Spec {
  String label;
  String value;
  Spec(String label, String value) {
    this.label = label;
    this.value = value;
  }
}

// Generic per-product content driven by an ordered spec list. Used by the phase-3
// categories (consoles, videogames, monitors, peripherals, networking, accessories,
// bundles): heterogeneous categories (a keyboard and a webcam are both "Periféricos")
// can't share a rigid field schema, so each product supplies only the specs that
// apply to it — no forced schema (runbook §4 Paso 2). warrantyMonths may be null
// (e.g. a digital videogame has no hardware warranty -> heading left blank).
class SpecContent implements ProductContent {
  String brand;
  Integer warrantyMonths;
  String ean;
  String pitch;
  List<Spec> specs;

  SpecContent(
    String brand,
    Integer warrantyMonths,
    String ean,
    String pitch,
    List<Spec> specs
  ) {
    this.brand = brand;
    this.warrantyMonths = warrantyMonths;
    this.ean = ean;
    this.pitch = pitch;
    this.specs = specs;
  }

  // Same template order as LaptopContent/PhoneContent: pitch paragraph + <ul> of
  // type-specific specs, then MOQ / order increment rendered from the standard
  // PurchaseQuantityRule (ADR-0009), never from the deprecated Product2 fields.
  public String toDescriptionHtml(Decimal minQuantity, Decimal orderIncrement) {
    String html = '<p>' + pitch + '</p>' + '<ul>';
    for (Spec s : specs) {
      html += '<li><strong>' + s.label + ':</strong> ' + s.value + '</li>';
    }
    html +=
      '<li><strong>Cantidad mínima:</strong> ' +
      formatUnits(minQuantity) +
      '</li>' +
      '<li><strong>Múltiplo de venta:</strong> ' +
      formatUnits(orderIncrement) +
      '</li>' +
      '</ul>';
    return html;
  }

  String formatUnits(Decimal quantity) {
    Integer units = quantity == null ? 1 : quantity.intValue();
    return units == 1 ? '1 ud' : units + ' uds';
  }

  public String getBrand() {
    return brand;
  }
  public Integer getWarrantyMonths() {
    return warrantyMonths;
  }
  public String getEan() {
    return ean;
  }
}

// ---- Wiring (resolved by Name; no hardcoded org IDs) --------------------------
Id catalogId = [
  SELECT Id
  FROM ProductCatalog
  WHERE Name = 'LevelUp Wholesale Catalog'
  LIMIT 1
]
.Id;

// Official taxonomy: category Name doubles as the Product2.Family picklist value.
Set<String> taxonomy = new Set<String>{
  'Consolas de gaming',
  'Videojuegos',
  'Portátiles',
  'Monitores',
  'Periféricos',
  'Networking',
  'Accesorios',
  'Bundles enterprise',
  'SmartPhones'
};

// ---- Curated content per SKU (per-type ProductContent, D3/D4) ------------------
Map<String, ProductContent> contentBySku = new Map<String, ProductContent>{
  'LVL-LAP-001' => new LaptopContent(
    'LvlUp',
    24,
    '8437011000019',
    'Portátil gaming de 15,6" con la mejor relación rendimiento/precio de la gama: el modelo de mayor rotación para tiendas que venden al jugador mainstream.',
    'Intel Core i7-13700H (14 núcleos)',
    '16 GB DDR5 4800 MHz',
    'SSD NVMe 512 GB',
    '15,6" FHD IPS 144 Hz',
    'NVIDIA GeForce RTX 4060 8 GB',
    'Windows 11 Home',
    '2,3 kg'
  ),
  'LVL-LAP-002' => new LaptopContent(
    'LvlUp',
    36,
    '8437011000026',
    'Portátil profesional de 14" ligero y con autonomía para toda la jornada, pensado para flotas de empresa y renovación de parque ofimático.',
    'Intel Core i5-1340P (12 núcleos)',
    '16 GB DDR5 4800 MHz',
    'SSD NVMe 512 GB',
    '14" WUXGA IPS antirreflejos',
    'Intel Iris Xe integrada',
    'Windows 11 Pro',
    '1,4 kg'
  ),
  'LVL-LAP-003' => new LaptopContent(
    'LvlUp',
    36,
    '8437011000033',
    'Workstation móvil de 17,3" para cargas de CAD, render y análisis de datos: el equipo para clientes de ingeniería y estudios creativos.',
    'Intel Core i9-13950HX (24 núcleos)',
    '64 GB DDR5 5600 MHz',
    'SSD NVMe 2 TB',
    '17,3" UHD 4K IPS 100% sRGB',
    'NVIDIA RTX A3000 12 GB',
    'Windows 11 Pro',
    '3,1 kg'
  ),
  'LVL-LAP-004' => new LaptopContent(
    'LvlUp',
    24,
    '8437011000040',
    'Buque insignia gaming de 17,3" con gráfica RTX de gama alta: margen premium para campañas de lanzamiento y clientes entusiastas.',
    'AMD Ryzen 9 7945HX (16 núcleos)',
    '32 GB DDR5 5200 MHz',
    'SSD NVMe 1 TB',
    '17,3" QHD IPS 240 Hz',
    'NVIDIA GeForce RTX 4080 12 GB',
    'Windows 11 Home',
    '2,9 kg'
  ),
  'LVL-LAP-005' => new LaptopContent(
    'LvlUp',
    24,
    '8437011000057',
    'Ultrabook de 13,3" con panel OLED y solo 1,1 kg: la opción de movilidad ejecutiva para clientes corporate y consultoras.',
    'Intel Core i7-1355U (10 núcleos)',
    '16 GB LPDDR5 5200 MHz',
    'SSD NVMe 512 GB',
    '13,3" 2.8K OLED 90 Hz',
    'Intel Iris Xe integrada',
    'Windows 11 Home',
    '1,1 kg'
  ),
  'LVL-LAP-006' => new LaptopContent(
    'LvlUp',
    24,
    '8437011000064',
    'Evolución Pro del gaming de 15,6": panel QHD a 165 Hz y RTX 4070 para el comprador entusiasta que exige más que la gama de entrada.',
    'Intel Core i9-13900H (14 núcleos)',
    '32 GB DDR5 5200 MHz',
    'SSD NVMe 1 TB',
    '15,6" QHD IPS 165 Hz',
    'NVIDIA GeForce RTX 4070 8 GB',
    'Windows 11 Pro',
    '2,4 kg'
  ),
  'LVL-LAP-007' => new LaptopContent(
    'LvlUp',
    36,
    '8437011000071',
    'Portátil business de 16" con pantalla táctil WQXGA: productividad y colaboración para equipos comerciales y de dirección.',
    'Intel Core i7-1360P (12 núcleos)',
    '32 GB DDR5 4800 MHz',
    'SSD NVMe 1 TB',
    '16" WQXGA IPS táctil',
    'Intel Iris Xe integrada',
    'Windows 11 Pro',
    '1,8 kg'
  ),
  // SmartPhones (9th category) — EPhone flagship, phone-appropriate attributes.
  'LVL-CEL-001' => new PhoneContent(
    'LvlUp',
    24,
    '8437011000088',
    'Smartphone flagship de 6,8" para el canal reseller: el tope de gama con mayor margen y demanda, ideal para renovación corporativa y clientes premium.',
    '6,8" AMOLED LTPO 120 Hz, 2600 nits',
    'Snapdragon 8 Gen 3 (octa-core)',
    '12 GB LPDDR5X',
    '512 GB UFS 4.0',
    'Triple: 200 MP principal + 50 MP ultra gran angular + 12 MP teleobjetivo 5x',
    '5000 mAh, carga rápida 45W',
    'Android 14',
    '5G, Wi-Fi 6E, Bluetooth 5.3, NFC',
    'Negro Titanio, Gris Grafito, Azul Medianoche'
  ),
  // ---- Consolas de gaming (LVL-CON-001..007) ---------------------------------
  'LVL-CON-001' => new SpecContent(
    'LvlUp',
    24,
    '8437011000095',
    'Consola de sobremesa tope de gama y producto ancla del canal gaming: la mayor demanda en lanzamientos y campañas de temporada.',
    new List<Spec>{
      new Spec('Almacenamiento', 'SSD NVMe 1 TB'),
      new Spec('Resolución / FPS', '4K a 120 FPS (compatible 8K)'),
      new Spec('Mando incluido', '1 mando inalámbrico'),
      new Spec('Edición', 'Física (lector Ultra HD Blu-ray)'),
      new Spec(
        'Conectividad',
        'HDMI 2.1, Wi-Fi 6, Bluetooth 5.1, 3× USB, Ethernet Gigabit'
      )
    }
  ),
  'LVL-CON-002' => new SpecContent(
    'LvlUp',
    24,
    '8437011000101',
    'Consola portátil para jugar en movilidad con opción de salida a TV mediante dock: complemento natural del catálogo gaming.',
    new List<Spec>{
      new Spec('Pantalla', '7" OLED 1080p táctil'),
      new Spec('Almacenamiento', '256 GB (ampliable vía microSD)'),
      new Spec('Resolución / FPS', '1080p en portátil / 4K en dock TV'),
      new Spec('Mando', 'Controles integrados + dock TV incluido'),
      new Spec('Autonomía', 'Hasta 6 h de juego'),
      new Spec('Conectividad', 'Wi-Fi 6, Bluetooth 5.2, USB-C')
    }
  ),
  'LVL-CON-003' => new SpecContent(
    'LvlUp',
    24,
    '8437011000118',
    'Pack de inicio listo para vender: consola Pro X con mando y un juego incluido, pensado para el arranque de surtido en tienda.',
    new List<Spec>{
      new Spec(
        'Contenido del pack',
        'Console Pro X + 1 mando + juego Galaxy Raiders'
      ),
      new Spec('Almacenamiento', 'SSD NVMe 1 TB'),
      new Spec('Resolución / FPS', '4K a 120 FPS'),
      new Spec('Mandos incluidos', '1 mando inalámbrico'),
      new Spec('Edición', 'Física')
    }
  ),
  'LVL-CON-004' => new SpecContent(
    'LvlUp',
    24,
    '8437011000125',
    'Versión digital de la Pro X, sin lector de discos y con precio más ajustado: ideal para el comprador de catálogo 100% descargable.',
    new List<Spec>{
      new Spec('Almacenamiento', 'SSD NVMe 1 TB'),
      new Spec('Resolución / FPS', '4K a 120 FPS'),
      new Spec('Mando incluido', '1 mando inalámbrico'),
      new Spec('Edición', 'Digital (sin lector de discos)'),
      new Spec('Conectividad', 'HDMI 2.1, Wi-Fi 6, Bluetooth 5.1')
    }
  ),
  'LVL-CON-005' => new SpecContent(
    'RetroStation',
    24,
    '8437011000132',
    'Mini consola retro con juegos clásicos preinstalados: producto de nostalgia, alta rotación y ticket contenido para impulso en caja.',
    new List<Spec>{
      new Spec('Juegos preinstalados', '120 títulos clásicos'),
      new Spec('Salida de vídeo', 'HDMI 720p'),
      new Spec('Mandos incluidos', '2 mandos con cable'),
      new Spec('Conectividad', 'HDMI, USB (alimentación)')
    }
  ),
  'LVL-CON-006' => new SpecContent(
    'LvlUp',
    24,
    '8437011000149',
    'Pack multijugador local con dos mandos incluidos: configuración de mayor margen para campañas de reventa.',
    new List<Spec>{
      new Spec('Contenido del pack', 'Console Pro X + 2 mandos inalámbricos'),
      new Spec('Almacenamiento', 'SSD NVMe 1 TB'),
      new Spec('Resolución / FPS', '4K a 120 FPS'),
      new Spec('Mandos incluidos', '2 mandos inalámbricos'),
      new Spec('Edición', 'Física')
    }
  ),
  'LVL-CON-007' => new SpecContent(
    'CloudPlay',
    24,
    '8437011000156',
    'Dispositivo de cloud gaming: juega en streaming sin consola dedicada, con catálogo en la nube por suscripción.',
    new List<Spec>{
      new Spec(
        'Servicio',
        'Cloud gaming por suscripción (catálogo en la nube)'
      ),
      new Spec('Resolución máx.', '4K HDR a 60 FPS'),
      new Spec('Mando incluido', '1 mando inalámbrico'),
      new Spec('Conectividad', 'HDMI 2.1, Wi-Fi 6, Ethernet, Bluetooth 5.1')
    }
  ),
  // ---- Videojuegos (LVL-VGM-001..008) — marca = editora ----------------------
  'LVL-VGM-001' => new SpecContent(
    'Nova Interactive',
    24,
    '8437011000163',
    'Shooter espacial superventas en edición física: lanzamiento de altísima demanda y rotación en el canal gaming.',
    new List<Spec>{
      new Spec('Plataforma', 'LvlUp Console Pro X'),
      new Spec('Género', 'Acción / Shooter espacial'),
      new Spec('Clasificación PEGI', 'PEGI 16'),
      new Spec('Edición', 'Física'),
      new Spec('Nº de jugadores', '1-4 local (online hasta 16)'),
      new Spec('Idiomas', 'Español, inglés, francés, alemán')
    }
  ),
  'LVL-VGM-002' => new SpecContent(
    'Nova Interactive',
    null,
    '8437011000170',
    'Versión digital descargable del superventas espacial: sin logística de stock físico, entrega por código.',
    new List<Spec>{
      new Spec('Plataforma', 'LvlUp Console Pro X'),
      new Spec('Género', 'Acción / Shooter espacial'),
      new Spec('Clasificación PEGI', 'PEGI 16'),
      new Spec('Edición', 'Digital (código de descarga)'),
      new Spec('Nº de jugadores', '1-4 local (online hasta 16)'),
      new Spec('Idiomas', 'Multi-idioma')
    }
  ),
  'LVL-VGM-003' => new SpecContent(
    'Redline Studios',
    24,
    '8437011000187',
    'Recopilación de conducción arcade con varios títulos: ticket bajo, público amplio y rotación rápida.',
    new List<Spec>{
      new Spec('Plataforma', 'LvlUp Console Pro X'),
      new Spec('Género', 'Carreras / Arcade'),
      new Spec('Clasificación PEGI', 'PEGI 3'),
      new Spec('Edición', 'Física (bundle de 3 juegos)'),
      new Spec('Nº de jugadores', '1-2 local (online hasta 8)'),
      new Spec('Idiomas', 'Español, inglés, italiano')
    }
  ),
  'LVL-VGM-004' => new SpecContent(
    'Mythdale Games',
    24,
    '8437011000194',
    'RPG de fantasía de la saga Dungeon Quest: título de catálogo estable con base de jugadores fiel.',
    new List<Spec>{
      new Spec('Plataforma', 'LvlUp Console Pro X'),
      new Spec('Género', 'RPG / Fantasía'),
      new Spec('Clasificación PEGI', 'PEGI 12'),
      new Spec('Edición', 'Física'),
      new Spec('Nº de jugadores', '1 (cooperativo online 1-4)'),
      new Spec('Idiomas', 'Español, inglés, alemán, japonés')
    }
  ),
  'LVL-VGM-005' => new SpecContent(
    'Blackout Games',
    24,
    '8437011000200',
    'Brawler de arena para partidas rápidas locales y online: perfecto para eventos y activaciones.',
    new List<Spec>{
      new Spec('Plataforma', 'LvlUp Console Pro X'),
      new Spec('Género', 'Lucha / Arena'),
      new Spec('Clasificación PEGI', 'PEGI 7'),
      new Spec('Edición', 'Física'),
      new Spec('Nº de jugadores', '1-4 local (online hasta 8)'),
      new Spec('Idiomas', 'Español, inglés')
    }
  ),
  'LVL-VGM-006' => new SpecContent(
    'Nova Interactive',
    24,
    '8437011000217',
    'Edición Deluxe en preventa con contenido adicional y season pass: reserva de alto interés previa al lanzamiento.',
    new List<Spec>{
      new Spec('Plataforma', 'LvlUp Console Pro X'),
      new Spec('Género', 'Acción / Shooter espacial'),
      new Spec('Clasificación PEGI', 'PEGI 16'),
      new Spec('Edición', 'Física Deluxe (preventa, season pass incluido)'),
      new Spec('Nº de jugadores', '1-4 local (online hasta 16)'),
      new Spec('Idiomas', 'Multi-idioma')
    }
  ),
  'LVL-VGM-007' => new SpecContent(
    'Greenfield Interactive',
    24,
    '8437011000224',
    'Simulador de gestión agrícola de público familiar: catálogo longevo y ventas sostenidas todo el año.',
    new List<Spec>{
      new Spec('Plataforma', 'LvlUp Console Pro X'),
      new Spec('Género', 'Simulación / Gestión'),
      new Spec('Clasificación PEGI', 'PEGI 3'),
      new Spec('Edición', 'Física'),
      new Spec('Nº de jugadores', '1 (cooperativo online 1-4)'),
      new Spec('Idiomas', 'Español, inglés, francés')
    }
  ),
  'LVL-VGM-008' => new SpecContent(
    'Blackout Games',
    24,
    '8437011000231',
    'Recopilación remasterizada de la saga de sigilo y acción Shadow Strike: colección para el jugador veterano.',
    new List<Spec>{
      new Spec('Plataforma', 'LvlUp Console Pro X'),
      new Spec('Género', 'Acción / Sigilo'),
      new Spec('Clasificación PEGI', 'PEGI 18'),
      new Spec('Edición', 'Física (colección de 3 juegos remasterizados)'),
      new Spec('Nº de jugadores', '1'),
      new Spec('Idiomas', 'Español, inglés, italiano')
    }
  )
};

// ---- 1) Family target per product, from the official taxonomy -----------------
Map<Id, String> categoryNameById = new Map<Id, String>();
for (ProductCategory pc : [
  SELECT Id, Name
  FROM ProductCategory
  WHERE CatalogId = :catalogId AND Name IN :taxonomy
]) {
  categoryNameById.put(pc.Id, pc.Name);
}

Map<Id, String> familyByProductId = new Map<Id, String>();
for (ProductCategoryProduct pcp : [
  SELECT ProductId, ProductCategoryId
  FROM ProductCategoryProduct
  WHERE ProductCategoryId IN :categoryNameById.keySet()
]) {
  familyByProductId.put(
    pcp.ProductId,
    categoryNameById.get(pcp.ProductCategoryId)
  );
}

// ---- 1b) Purchase quantity rule per curated product (standard source, ADR-0009) --
// MOQ / increment for the Description now come from the standard PurchaseQuantityRule
// associated via the ProductQuantityRule junction, not from the deprecated Product2
// custom fields.
Map<Id, PurchaseQuantityRule> ruleByProductId = new Map<Id, PurchaseQuantityRule>();
for (ProductQuantityRule link : [
  SELECT ProductId, PurchaseQuantityRule.Minimum, PurchaseQuantityRule.Increment
  FROM ProductQuantityRule
  WHERE Product.StockKeepingUnit IN :contentBySku.keySet()
]) {
  ruleByProductId.put(link.ProductId, link.PurchaseQuantityRule);
}

// ---- 2) Single pass: apply Family + curated content where values differ --------
List<Product2> updates = new List<Product2>();
Integer familyChanged = 0;
Integer familyCurrent = 0;
Integer contentChanged = 0;
Integer contentCurrent = 0;

for (Product2 p : [
  SELECT
    Id,
    StockKeepingUnit,
    Family,
    Brand__c,
    Warranty_Months__c,
    EAN__c,
    Description,
    Is_External_Product__c
  FROM Product2
  WHERE
    IsActive = TRUE
    AND Is_External_Product__c = FALSE
    AND (Id IN :familyByProductId.keySet()
    OR StockKeepingUnit IN :contentBySku.keySet())
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

  ProductContent c = contentBySku.get(p.StockKeepingUnit);
  if (c != null) {
    // MOQ / increment from the standard rule (ADR-0009); defaults 1/1 if unassociated.
    PurchaseQuantityRule rule = ruleByProductId.get(p.Id);
    Decimal ruleMin = (rule != null && rule.Minimum != null) ? rule.Minimum : 1;
    Decimal ruleInc = (rule != null &&
      rule.Increment != null)
      ? rule.Increment
      : 1;
    String html = c.toDescriptionHtml(ruleMin, ruleInc);
    if (
      p.Brand__c != c.getBrand() ||
      p.Warranty_Months__c != c.getWarrantyMonths() ||
      p.EAN__c != c.getEan() ||
      p.Description != html
    ) {
      p.Brand__c = c.getBrand();
      p.Warranty_Months__c = c.getWarrantyMonths();
      p.EAN__c = c.getEan();
      p.Description = html;
      dirty = true;
      contentChanged++;
    } else {
      contentCurrent++;
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
System.debug(
  'Family updated: ' + familyChanged + ' | already current: ' + familyCurrent
);
System.debug(
  'Curated content updated: ' +
    contentChanged +
    ' | already current: ' +
    contentCurrent
);
System.debug('Total records written: ' + updates.size());

// Internal active products with no category in the official taxonomy (Family left as-is).
for (Product2 p : [
  SELECT StockKeepingUnit, Name
  FROM Product2
  WHERE
    IsActive = TRUE
    AND Is_External_Product__c = FALSE
    AND Id NOT IN :familyByProductId.keySet()
]) {
  System.debug(
    'WARN outside taxonomy, Family not set: ' +
      p.StockKeepingUnit +
      ' | ' +
      p.Name
  );
}

// Verification: curated products as persisted.
for (Product2 p : [
  SELECT StockKeepingUnit, Brand__c, Warranty_Months__c, EAN__c, Description
  FROM Product2
  WHERE StockKeepingUnit IN :contentBySku.keySet()
  ORDER BY StockKeepingUnit
]) {
  System.debug(
    'CONTENT ' +
      p.StockKeepingUnit +
      ' | ' +
      p.Brand__c +
      ' | ' +
      p.Warranty_Months__c +
      'm | ' +
      p.EAN__c +
      ' | desc ' +
      p.Description.length() +
      ' chars'
  );
}

// Verification: Family distribution over active internal products.
for (AggregateResult ar : [
  SELECT Family fam, COUNT(Id) total
  FROM Product2
  WHERE IsActive = TRUE AND Is_External_Product__c = FALSE
  GROUP BY Family
  ORDER BY Family
]) {
  System.debug('FAMILY ' + ar.get('fam') + ' = ' + ar.get('total'));
}
