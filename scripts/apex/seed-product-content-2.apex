/*
 * Seed/sync product content — BATCH 2 of 2 (product information enrichment, phase 3).
 *
 * The curated content is split across two idempotent script files because an
 * anonymous Apex block has a hard size limit (~32 KB) and the full 9-category
 * catalogue exceeds it. Run BOTH files (order does not matter, each is idempotent):
 *   1. scripts/apex/seed-product-content.apex    -> Portátiles, SmartPhones, Consolas, Videojuegos
 *   2. scripts/apex/seed-product-content-2.apex   -> Monitores, Periféricos, Networking, Accesorios, Bundles enterprise
 *
 * These are DATA (records), not metadata (see adr/0003-commerce-data-vs-metadata-strategy.md).
 * Same recipe as batch 1: sets Brand__c / Warranty_Months__c / EAN__c and a
 * Description built from a type-appropriate <ul> of specs (SpecContent), with MOQ /
 * order increment rendered from the standard PurchaseQuantityRule (ADR-0009). Family
 * is mapped from the official taxonomy for every active internal product. Spanish
 * content (D4). Keys: StockKeepingUnit / Name. No hardcoded org IDs.
 *
 * Run: sf apex run --file scripts/apex/seed-product-content-2.apex --target-org commerce-b2b-dev
 * MANUAL FOLLOW-UP: single search index rebuild after BOTH batches
 * (scripts/apex/rebuild-search-index.apex, REGLA-026).
 */

// Per-type product content: each category implements this so the spec set is
// appropriate for the product type (no forced schema — runbook §4 Paso 2).
interface ProductContent {
  String getBrand();
  Integer getWarrantyMonths();
  String getEan();
  String toDescriptionHtml(Decimal minQuantity, Decimal orderIncrement);
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

// Generic per-product content driven by an ordered spec list: heterogeneous
// categories (a keyboard and a webcam are both "Periféricos") can't share a rigid
// field schema, so each product supplies only the specs that apply to it — no forced
// schema. warrantyMonths may be null (e.g. a digital videogame has no warranty).
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

  // pitch paragraph + <ul> of type-specific specs, then MOQ / order increment from
  // the standard PurchaseQuantityRule (ADR-0009), never from deprecated Product2 fields.
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

// ---- Curated content per SKU (batch 2: Monitores, Periféricos, Networking,
//      Accesorios, Bundles enterprise) ------------------------------------------
Map<String, ProductContent> contentBySku = new Map<String, ProductContent>{
  // ---- Monitores (LVL-MON-001..006) ------------------------------------------
  'LVL-MON-001' => new SpecContent(
    'LvlUp',
    24,
    '8437011000248',
    'Monitor gaming de 27" a 165 Hz: complemento de alta rotación para el jugador y la tienda gaming.',
    new List<Spec>{
      new Spec('Tamaño', '27"'),
      new Spec('Panel', 'IPS'),
      new Spec('Resolución', 'QHD 2560×1440'),
      new Spec('Tasa de refresco', '165 Hz'),
      new Spec('Tiempo de respuesta', '1 ms (MPRT)'),
      new Spec(
        'Conectividad',
        '2× HDMI 2.0, DisplayPort 1.4, salida de auriculares'
      )
    }
  ),
  'LVL-MON-002' => new SpecContent(
    'LvlUp',
    36,
    '8437011000255',
    'Monitor profesional de 24" para puesto de oficina: fiable y económico para renovación de parque.',
    new List<Spec>{
      new Spec('Tamaño', '24"'),
      new Spec('Panel', 'IPS'),
      new Spec('Resolución', 'Full HD 1920×1080'),
      new Spec('Tasa de refresco', '75 Hz'),
      new Spec('Tiempo de respuesta', '5 ms'),
      new Spec('Conectividad', 'HDMI, DisplayPort, VGA')
    }
  ),
  'LVL-MON-003' => new SpecContent(
    'LvlUp',
    36,
    '8437011000262',
    'Monitor curvo de 34" 4K para productividad y multitarea: gama alta con buen margen.',
    new List<Spec>{
      new Spec('Tamaño', '34" ultrapanorámico'),
      new Spec('Panel', 'VA'),
      new Spec('Resolución', '4K UHD 3840×2160'),
      new Spec('Tasa de refresco', '100 Hz'),
      new Spec('Tiempo de respuesta', '4 ms'),
      new Spec('Curvatura', '1500R'),
      new Spec('Conectividad', '2× HDMI 2.1, DisplayPort 1.4, USB-C')
    }
  ),
  'LVL-MON-004' => new SpecContent(
    'LvlUp',
    36,
    '8437011000279',
    'Monitor 4K de 32" para creadores de contenido: color calibrado de fábrica y conectividad USB-C con carga.',
    new List<Spec>{
      new Spec('Tamaño', '32"'),
      new Spec('Panel', 'IPS'),
      new Spec('Resolución', '4K UHD 3840×2160'),
      new Spec('Tasa de refresco', '60 Hz'),
      new Spec('Tiempo de respuesta', '5 ms'),
      new Spec('Cobertura de color', '99% Adobe RGB'),
      new Spec('Conectividad', 'HDMI 2.1, DisplayPort 1.4, USB-C 90W')
    }
  ),
  'LVL-MON-005' => new SpecContent(
    'LvlUp',
    24,
    '8437011000286',
    'Monitor 27" QHD IPS equilibrado para trabajo y ocio: la opción polivalente del catálogo.',
    new List<Spec>{
      new Spec('Tamaño', '27"'),
      new Spec('Panel', 'IPS'),
      new Spec('Resolución', 'QHD 2560×1440'),
      new Spec('Tasa de refresco', '100 Hz'),
      new Spec('Tiempo de respuesta', '4 ms'),
      new Spec('Conectividad', 'HDMI, DisplayPort')
    }
  ),
  'LVL-MON-006' => new SpecContent(
    'LvlUp',
    36,
    '8437011000293',
    'Superpanorámico de 49" 32:9 para trading y multitarea intensiva: sustituye a dos monitores en un solo panel.',
    new List<Spec>{
      new Spec('Tamaño', '49" superpanorámico (32:9)'),
      new Spec('Panel', 'VA'),
      new Spec('Resolución', 'DQHD 5120×1440'),
      new Spec('Tasa de refresco', '120 Hz'),
      new Spec('Tiempo de respuesta', '4 ms'),
      new Spec('Curvatura', '1800R'),
      new Spec('Conectividad', '2× HDMI 2.0, DisplayPort 1.4, USB-C')
    }
  ),
  // ---- Periféricos (LVL-PER-001..008) — heterogéneos -------------------------
  'LVL-PER-001' => new SpecContent(
    'LvlUp',
    24,
    '8437011000309',
    'Teclado mecánico full-size para gaming y productividad: accesorio de alta recurrencia y reposición.',
    new List<Spec>{
      new Spec('Tipo', 'Mecánico full-size'),
      new Spec('Switches', 'Lineales rojos (hot-swap)'),
      new Spec('Conexión', 'USB-C con cable trenzado'),
      new Spec('Iluminación', 'RGB por tecla'),
      new Spec('Layout', 'Español (ISO)')
    }
  ),
  'LVL-PER-002' => new SpecContent(
    'LvlUp',
    24,
    '8437011000316',
    'Ratón gaming inalámbrico ligero de alto rendimiento: sensor de precisión para el jugador competitivo.',
    new List<Spec>{
      new Spec('Sensor', 'Óptico 26.000 DPI'),
      new Spec('Conexión', 'Inalámbrico 2.4 GHz + USB-C'),
      new Spec('Botones', '6 programables'),
      new Spec('Peso', '63 g'),
      new Spec('Iluminación', 'RGB')
    }
  ),
  'LVL-PER-003' => new SpecContent(
    'LvlUp',
    24,
    '8437011000323',
    'Auriculares gaming inalámbricos con micrófono desmontable: comodidad y autonomía para sesiones largas.',
    new List<Spec>{
      new Spec('Tipo', 'Over-ear cerrados'),
      new Spec('Conexión', 'Inalámbrico 2.4 GHz (dongle USB) + Bluetooth'),
      new Spec('Drivers', '50 mm'),
      new Spec('Micrófono', 'Desmontable con cancelación de ruido'),
      new Spec('Autonomía', 'Hasta 30 h')
    }
  ),
  'LVL-PER-004' => new SpecContent(
    'LvlUp',
    24,
    '8437011000330',
    'Mando inalámbrico multiplataforma con gatillos hápticos: compatible con consola, PC y móvil.',
    new List<Spec>{
      new Spec('Conexión', 'Inalámbrico 2.4 GHz + Bluetooth'),
      new Spec('Compatibilidad', 'LvlUp Console Pro X, PC y móvil'),
      new Spec('Autonomía', 'Hasta 20 h'),
      new Spec('Vibración', 'Gatillos hápticos y motores duales')
    }
  ),
  'LVL-PER-005' => new SpecContent(
    'LvlUp',
    24,
    '8437011000347',
    'Alfombrilla XL con iluminación RGB perimetral: superficie amplia para setups gaming completos.',
    new List<Spec>{
      new Spec('Tamaño', 'XL 900×400 mm'),
      new Spec('Superficie', 'Tela microtejida'),
      new Spec('Base', 'Goma antideslizante'),
      new Spec('Iluminación', 'RGB perimetral (14 efectos)')
    }
  ),
  'LVL-PER-006' => new SpecContent(
    'LvlUp',
    24,
    '8437011000354',
    'Webcam 4K para streaming y videollamadas profesionales: imagen nítida con autofocus.',
    new List<Spec>{
      new Spec('Resolución', '4K UHD a 30 FPS / 1080p a 60 FPS'),
      new Spec('Enfoque', 'Autofocus'),
      new Spec('Micrófono', 'Estéreo con reducción de ruido'),
      new Spec('Campo de visión', '90°'),
      new Spec('Conexión', 'USB-C plug-and-play')
    }
  ),
  'LVL-PER-007' => new SpecContent(
    'LvlUp',
    24,
    '8437011000361',
    'Micrófono USB de condensador para streaming y podcast: calidad de estudio sin interfaz externa.',
    new List<Spec>{
      new Spec('Patrón polar', 'Cardioide / omnidireccional / bidireccional'),
      new Spec('Conexión', 'USB-C plug-and-play'),
      new Spec('Muestreo', '24-bit / 96 kHz'),
      new Spec('Montaje', 'Trípode de sobremesa + rosca para brazo')
    }
  ),
  'LVL-PER-008' => new SpecContent(
    'LvlUp',
    24,
    '8437011000378',
    'Teclado mecánico de perfil bajo para oficina y espacios compactos: escritura silenciosa y conexión inalámbrica.',
    new List<Spec>{
      new Spec('Tipo', 'Mecánico low-profile TKL'),
      new Spec('Switches', 'Táctiles marrones'),
      new Spec('Conexión', 'Bluetooth + USB-C'),
      new Spec('Iluminación', 'Retroiluminación blanca'),
      new Spec('Layout', 'Español (ISO)')
    }
  ),
  // ---- Networking (LVL-NET-001..005) -----------------------------------------
  'LVL-NET-001' => new SpecContent(
    'LvlUp',
    24,
    '8437011000385',
    'Router Wi-Fi 6 de doble banda para oficina y reventa: gestión sencilla desde app y buena cobertura.',
    new List<Spec>{
      new Spec('Estándar Wi-Fi', 'Wi-Fi 6 (802.11ax)'),
      new Spec('Velocidad', 'AX3000 (2402 + 574 Mbps)'),
      new Spec('Bandas', 'Doble banda 2,4 + 5 GHz'),
      new Spec('Puertos', '4× Gigabit LAN + 1× WAN'),
      new Spec('Cobertura', 'Hasta 200 m²'),
      new Spec('Gestión', 'App móvil y panel web')
    }
  ),
  'LVL-NET-002' => new SpecContent(
    'LvlUp',
    36,
    '8437011000392',
    'Switch Gigabit de 8 puertos plug-and-play: amplía la red cableada sin configuración.',
    new List<Spec>{
      new Spec('Puertos', '8× Gigabit RJ45'),
      new Spec('Velocidad', '1 Gbps por puerto'),
      new Spec('Capacidad de conmutación', '16 Gbps'),
      new Spec('Gestión', 'No gestionado (plug-and-play)'),
      new Spec('Formato', 'Sobremesa / montaje en pared')
    }
  ),
  'LVL-NET-003' => new SpecContent(
    'LvlUp',
    24,
    '8437011000408',
    'Sistema mesh Wi-Fi 6 de 3 nodos para cobertura total sin zonas muertas: ideal para casas y locales grandes.',
    new List<Spec>{
      new Spec('Estándar Wi-Fi', 'Wi-Fi 6 (802.11ax)'),
      new Spec('Velocidad', 'AX1800 por nodo'),
      new Spec('Nodos', '3 (pack)'),
      new Spec('Cobertura', 'Hasta 550 m²'),
      new Spec('Puertos', '2× Gigabit por nodo'),
      new Spec('Gestión', 'App móvil')
    }
  ),
  'LVL-NET-004' => new SpecContent(
    'LvlUp',
    36,
    '8437011000415',
    'Punto de acceso Wi-Fi 6 con alimentación PoE para instalaciones profesionales: despliegue limpio en techo o pared.',
    new List<Spec>{
      new Spec('Estándar Wi-Fi', 'Wi-Fi 6 (802.11ax)'),
      new Spec('Velocidad', 'AX3000'),
      new Spec('Alimentación', 'PoE+ (802.3at)'),
      new Spec('Montaje', 'Techo o pared'),
      new Spec('Clientes', 'Hasta 256 simultáneos'),
      new Spec('Gestión', 'Controladora cloud')
    }
  ),
  'LVL-NET-005' => new SpecContent(
    'LvlUp',
    36,
    '8437011000422',
    'Switch gestionado de 24 puertos en formato rack para armario de comunicaciones: base de red para empresa.',
    new List<Spec>{
      new Spec('Puertos', '24× Gigabit RJ45 + 4× SFP'),
      new Spec('Velocidad', '1 Gbps + uplinks SFP'),
      new Spec('Capacidad de conmutación', '56 Gbps'),
      new Spec('Gestión', 'Gestionado L2+ (VLAN, QoS)'),
      new Spec('Formato', 'Rack 1U 19"')
    }
  ),
  // ---- Accesorios (LVL-ACC-001..006) — heterogéneos --------------------------
  'LVL-ACC-001' => new SpecContent(
    'LvlUp',
    24,
    '8437011000439',
    'Cable USB-C de 2 m para carga y datos: consumible de reposición y ticket complementario.',
    new List<Spec>{
      new Spec('Longitud', '2 m'),
      new Spec('Estándar', 'USB 3.2 Gen 2'),
      new Spec('Velocidad de datos', '10 Gbps'),
      new Spec('Potencia', 'Hasta 100 W (USB Power Delivery)'),
      new Spec('Conectores', 'USB-C a USB-C, malla trenzada')
    }
  ),
  'LVL-ACC-002' => new SpecContent(
    'LvlUp',
    24,
    '8437011000446',
    'Soporte de monitor con gestión de cables para puesto de oficina: mejora ergonomía y orden del escritorio.',
    new List<Spec>{
      new Spec('Compatibilidad', 'VESA 75×75 / 100×100'),
      new Spec('Nº de pantallas', '1 (hasta 32")'),
      new Spec('Ajuste', 'Altura, inclinación y giro'),
      new Spec('Carga máx.', '9 kg'),
      new Spec('Material', 'Aluminio')
    }
  ),
  'LVL-ACC-003' => new SpecContent(
    'LvlUp',
    24,
    '8437011000453',
    'Cargador USB-C de 65 W con tecnología GaN: compacto y potente para portátiles y móviles.',
    new List<Spec>{
      new Spec('Potencia', '65 W'),
      new Spec('Tecnología', 'GaN + USB Power Delivery 3.0'),
      new Spec('Puertos', '2× USB-C + 1× USB-A'),
      new Spec('Compatibilidad', 'Portátiles, tablets y móviles USB-C')
    }
  ),
  'LVL-ACC-004' => new SpecContent(
    'LvlUp',
    24,
    '8437011000460',
    'Mochila para portátil con protección y organización profesional: pensada para el uso diario y el desplazamiento.',
    new List<Spec>{
      new Spec('Capacidad', '22 L'),
      new Spec('Tamaño de portátil', 'Hasta 16"'),
      new Spec('Material', 'Poliéster resistente al agua'),
      new Spec(
        'Compartimentos',
        'Acolchado para portátil y tablet + puerto USB externo'
      )
    }
  ),
  'LVL-ACC-005' => new SpecContent(
    'LvlUp',
    24,
    '8437011000477',
    'Cable HDMI 2.1 de 3 m para 4K/8K y alta tasa de refresco: conecta consolas y PC gaming sin pérdidas.',
    new List<Spec>{
      new Spec('Longitud', '3 m'),
      new Spec('Estándar', 'HDMI 2.1'),
      new Spec('Ancho de banda', '48 Gbps'),
      new Spec('Resolución máx.', '8K a 60 Hz / 4K a 120 Hz'),
      new Spec('Conectores', 'Chapados en oro, malla trenzada')
    }
  ),
  'LVL-ACC-006' => new SpecContent(
    'LvlUp',
    24,
    '8437011000484',
    'Hub USB-C 7 en 1 para ampliar la conectividad de portátiles: vídeo, datos y carga en un solo accesorio.',
    new List<Spec>{
      new Spec(
        'Puertos',
        'HDMI 4K, 2× USB-A 3.0, USB-C datos, USB-C PD, SD, microSD'
      ),
      new Spec('Conexión', 'USB-C'),
      new Spec('Vídeo', 'HDMI 4K a 30 Hz'),
      new Spec('Power Delivery', 'Hasta 100 W passthrough')
    }
  ),
  // ---- Bundles enterprise (LVL-BND-001..003) ---------------------------------
  'LVL-BND-001' => new SpecContent(
    'LvlUp',
    24,
    '8437011000491',
    'Kit de inicio para tiendas gaming que arrancan surtido: consola, mandos, juegos y monitor en un solo pedido.',
    new List<Spec>{
      new Spec(
        'Contenido del kit',
        '1 Console Pro X + 2 mandos + 3 juegos + 1 monitor 27"'
      ),
      new Spec('Nº de componentes', '7 unidades'),
      new Spec('Segmento objetivo', 'Reseller / tienda gaming')
    }
  ),
  'LVL-BND-002' => new SpecContent(
    'LvlUp',
    24,
    '8437011000507',
    'Kit de puesto de oficina completo para renovación tecnológica: todo lo necesario para equipar un puesto de trabajo.',
    new List<Spec>{
      new Spec(
        'Contenido del kit',
        '1 portátil business + 1 monitor 24" + teclado + ratón + hub USB-C'
      ),
      new Spec('Nº de componentes', '5 unidades'),
      new Spec('Segmento objetivo', 'Empresa / IT')
    }
  ),
  'LVL-BND-003' => new SpecContent(
    'LvlUp',
    24,
    '8437011000514',
    'Kit para eventos y activaciones gaming, listo para montar: varias estaciones de juego en un único pack.',
    new List<Spec>{
      new Spec(
        'Contenido del kit',
        '2 Console Pro X + 4 mandos + 2 monitores 27" + auriculares'
      ),
      new Spec('Nº de componentes', '9 unidades'),
      new Spec('Segmento objetivo', 'Eventos / activaciones')
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
