# Runbook: Enriquecimiento de Contenido de Producto por Categoría - LvlUp WholeSale

## 1. Propósito del Documento

Este runbook documenta la **receta replicable** para enriquecer la información de
producto (PDP + product cards) de una categoría interna del catálogo, tal como se
ejecutó en la fase 1 sobre **Portátiles** (`LVL-LAP-001..007`). La arquitectura
está decidida en `adr/0008-product-information-architecture.md` (Accepted): no se
re-diseña; se replica.

> **Estado (2026-07-27, fase 3):** la receta se ha replicado en las **7 categorías
> internas restantes** (Consolas de gaming, Videojuegos, Monitores, Periféricos,
> Networking, Accesorios, Bundles enterprise). Los **51 productos internos activos**
> tienen ya Brand/Warranty/EAN/Description; el único fuera de taxonomía es
> `Shipping Charge Product`. Ver §9 (modelo de marca) y §10 (lote y límite de Apex
> anónimo).

La clave de la receta: la configuración de plataforma (campos, mappings del
Builder, facets, sort, FLS) es **transversal y ya está hecha** (sección 3). Para
cada categoría nueva solo hay que **curar datos y reindexar** (sección 4).

Aplica el principio rector: _Configuration first, customization only when
justified_, y la separación data vs metadata de
`adr/0003-commerce-data-vs-metadata-strategy.md`.

---

## 2. Piezas de Referencia

| Pieza                 | Nombre / ruta                                                                                                                                                  | Rol                                                                     |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Campos de contenido   | `Product2.Brand__c` (picklist "Marca"), `Warranty_Months__c`, `EAN__c`, `Family`                                                                               | Datos estructurados de la ficha                                         |
| Plantilla de specs    | interfaz `ProductContent` + clases por tipo: `LaptopContent`, `PhoneContent` y la genérica `SpecContent` (lista ordenada de specs, para las categorías fase 3) | HTML estructurado de la Description, con atributos propios de cada tipo |
| Seed de contenido     | `scripts/apex/seed-product-content.apex` (lote 1) + `scripts/apex/seed-product-content-2.apex` (lote 2) — ver §10                                              | Family (todos los internos) + contenido por SKU                         |
| LWC de disponibilidad | `lvlupProductAvailability` → `lvlupStockAvailabilityPanel`                                                                                                     | Stock en la PDP (ya colocado)                                           |
| LWC de card meta      | `lvlupProductPrice` + `LvlupProductPriceController`                                                                                                            | SKU + badge, marca y precio en la card del Grid (ver §7)                |
| Permission sets       | `LvlUp_Product_Content_Admin` (edición) / `LvlUp_Product_Content_Buyer` (lectura)                                                                              | FLS de los campos de contenido                                          |
| Reindex               | `scripts/apex/rebuild-search-index.apex`                                                                                                                       | Único reindex al final (REGLA-026)                                      |

---

## 3. Configuración Transversal (YA Realizada en Fase 1 — no repetir)

Se documenta para trazabilidad y para reconstruirla en otra org:

1. **Campos**: `Brand__c` (picklist restringido; ver §6 por qué picklist),
   `Warranty_Months__c` (Number 3,0), `EAN__c` (Text 14) +
   `Product2Family` standard value set con las **9** categorías internas
   (las 8 originales + **SmartPhones**, añadida 2026-07-27). Para adoptar una
   categoría nueva en la taxonomía: añadir su valor a `Product2Family`
   (`force-app/main/default/standardValueSets/Product2Family.standardValueSet-meta.xml`)
   **y** al `Set` `taxonomy` del seed, antes de curar.
2. **FLS**: permission sets `LvlUp_Product_Content_Admin` (asignado al admin) y
   `LvlUp_Product_Content_Buyer` (asignado a los buyers). Sin la de lectura, el
   canal commerce **no muestra** los campos custom al buyer (validación V6).
3. **Search (app Commerce → Store → Search)**: Marca en _Searchable Fields_;
   facets **Product Family** y **Marca** en _Results Filters_; _Sort Rules_ de
   precio asc/desc; _Additional Settings_: **Price Book for Sorting** = LevelUp
   Wholesale Price Book y **Partial SKU Search** activado.
4. **Experience Builder** (página Product): heading con mappings
   `Marca / Familia / Garantía (meses)` (máximo 3; Product Code eliminado),
   acordeón retitulado a **"Especificaciones"**, y `lvlupProductAvailability`
   bajo _Product Pricing Details_. Cards de categoría y búsqueda con `Brand__c`
   mapeado sin label.
5. **Card del Grid de Category** (fase 1.1, ver §7 y la adenda del ADR-0008):
   `lvlupProductPrice` colocado en el item del repeater con
   `productId={!Item.id}`, `sku={!Item.fields.StockKeepingUnit.value}` y
   `brand={!Item.fields.Brand__c.value}`; el card estándar se conserva solo por
   el nombre y el wishlist, con su SKU/marca ocultos vía CSS scoped en el head
   markup de `mainAppPage`; el Grid con `isFixedRowHeight: false`. Es
   **transversal**: aplica a todas las categorías sin repetir.

---

## 4. Receta por Categoría (p. ej. Monitores)

### Paso 1 - Preparar los valores de Marca

Si la categoría introduce marcas nuevas, añadirlas **antes** al picklist
restringido `Brand__c` (metadata: `force-app/main/default/objects/Product2/fields/Brand__c.field-meta.xml`
→ deploy). Sin el valor en el picklist, el seed fallará al asignarlo.

### Paso 2 - Curar el contenido en el seed

En `scripts/apex/seed-product-content.apex`:

1. Añadir al mapa `contentBySku` una entrada por SKU de la categoría
   (`LVL-MON-001..006` en Monitores) con: marca, garantía (meses), EAN-13 válido
   y un conjunto de specs **coherente con el TIPO de producto** — **no** forzar el
   esquema de 7 campos del portátil. Elegir solo los atributos que tengan sentido
   para la categoría y **omitir** los que no apliquen (p. ej. un monitor lleva
   panel/resolución/tasa de refresco/tiempo de respuesta/conectividad, no "GPU"
   ni "colores disponibles"; un smartphone sí lleva pantalla/cámara/batería/
   colores disponibles; un videojuego lleva plataforma/género/PEGI/edición). Es
   trabajo de curación producto a producto, con el mismo cuidado que en Portátiles:
   adaptar la plantilla (campos y etiquetas) por categoría, manteniendo el orden
   párrafo comercial + `<ul>`.
2. Reglas del contenido (D4): **español**, ficticio pero verosímil, coherente con
   el `Name` de cada producto. Los productos Platzi **no se tocan** (fase 4).
3. MOQ y múltiplo **no se escriben a mano**: la plantilla los renderiza desde la
   `PurchaseQuantityRule` estándar asociada al producto (ADR-0009), no desde los
   campos deprecados de `Product2`.

> `Family` no requiere trabajo por categoría: el seed ya lo mapea para **todos**
> los internos activos desde su categoría oficial.

### Paso 3 - Ejecutar el seed (idempotente)

El contenido está repartido en **dos ficheros** por el límite de tamaño del Apex
anónimo (~32 KB, ver §10). Ejecutar **ambos** (el orden es indiferente; cada uno es
idempotente):

```bash
sf apex run --file scripts/apex/seed-product-content.apex --target-org commerce-b2b-dev
```

```bash
sf apex run --file scripts/apex/seed-product-content-2.apex --target-org commerce-b2b-dev
```

Verificar en el log de cada lote: contadores de actualizados/ya-correctos (una
re-ejecución debe dar `updated: 0`), los `CONTENT ...` de verificación y —en el
lote 1— el `WARN outside taxonomy` esperado (solo **Shipping Charge Product**, el
producto estándar de envío; `LVL-CEL-001` ya está en la taxonomía como
`SmartPhones`). Añadir una categoría nueva a un lote existente (o crear un lote
`-3` si se acerca al límite) según el volumen.

### Paso 4 - Reindexar (una sola vez, al final)

```bash
sf apex run --file scripts/apex/rebuild-search-index.apex --target-org commerce-b2b-dev
```

Esperar a `indexStatus=Completed` (tarda ~4 min). Sin reindex, cards y facets
siguen sirviendo los datos viejos del índice (REGLA-026). No hace falta Publish
si no se tocó código LWC ni páginas del Builder (REGLA-007).

### Paso 5 - QA como Buyer real (REGLA-001)

En el site **publicado**, con un **Buyer User real** (nunca Builder Preview):

- [ ] PDP: Marca/Familia/Garantía en el heading; disponibilidad bajo el precio;
      acordeón "Especificaciones" con párrafo + lista (incl. MOQ/múltiplo).
- [ ] Cards de la categoría y de búsqueda con la línea de marca.
- [ ] Facet de Marca con los valores nuevos; facet de Familia filtra la categoría.
- [ ] Sort por precio asc/desc coherente.
- [ ] Búsqueda por SKU parcial (p. ej. `MON-003`).
- [ ] Regresión Quick Buy (modal, MOQ, añadir al carrito).

---

## 5. Validaciones Ejecutadas en Fase 1 (V4/V5/V6)

| ID  | Validación                                                                                                           | Resultado                                                                                              |
| --- | -------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| V4  | `productDetailSummaryFieldMapping` y `cardContentMapping` aceptan campos custom de los Searchable/Results Fields     | **Pasada** — el plan B (todo en Description) no fue necesario                                          |
| V5  | Reutilización de `getProductPurchaseInfo` + `lvlupStockAvailabilityPanel` en la PDP vía contenedor con `{!recordId}` | **Pasada** — stock visible para el buyer sin Apex nuevo                                                |
| V6  | ¿El canal commerce exige FLS de lectura al buyer en campos custom?                                                   | **Sí** — Family (estándar) renderizaba y Brand/Warranty no; resuelto con `LvlUp_Product_Content_Buyer` |

---

## 6. Lecciones y Errores Comunes (validados en fase 1)

- **Máximo 3 field mappings** en _Product Detail Headings_: elegir bien los 3
  (Marca/Familia/Garantía); el SKU ya lo pinta el heading; MOQ/múltiplo van en la
  Description.
- **Los facets solo aceptan tipos enumerables**: un campo Text no aparece en
  _Manage Filters_. Por eso `Brand__c` es picklist restringido.
- **Text→Picklist no es convertible** en esta org (ni API ni Setup: "Unsupported
  custom field type conversion"). Si un campo nace mal tipado: quitarlo de
  _Searchable Fields_, **eliminar y recrear** con el mismo API name (los
  mappings del Builder sobreviven), redesplegar FLS y re-ejecutar el seed.
- **FLS del buyer**: los campos custom no se muestran en PDP/cards sin lectura
  explícita; los facets sí funcionan (agregación del índice) — no usar el facet
  como prueba de que la FLS está bien.
- **El label del facet es el label del campo** (no editable por facet): por eso
  `Brand__c` se etiqueta "Marca". "Product Family" queda en inglés (backlog de
  idioma de labels estándar).
- **Un solo reindex por tanda** de curación; el índice tarda minutos y hay
  límite diario de rebuilds manuales.
- Cambios de **FLS y Apex aplican al instante**; cambios de **código LWC o
  Builder** requieren Publish (REGLA-007).
- **El card estándar del Grid no pinta el precio en runtime** (sí en la PDP y en
  la búsqueda; en el Builder sí por el mock de design-time). Aunque la llamada de
  pricing devuelve `listPrice`/`unitPrice`, dentro del patrón Grid + `{!Item}` el
  `commerce_builder:productCard` es fiable solo para nombre, SKU, marca y
  wishlist — igual que ya pasaba con imágenes (REGLA-006) y paginación
  (REGLA-027). El precio se resuelve con LWC propio (ver §7).

---

## 7. La Card del Grid: Precio y Layout (fase 1.1)

Contexto y decisiones completas en la **adenda del `adr/0008`**. Resumen operativo
para replicar/mantener:

- **Precio**: `lvlupProductPrice` (LWC presentacional) + `LvlupProductPriceController`
  (Apex cacheable `without sharing`). El price book de venta se resuelve por la
  cadena estándar Account → `BuyerGroupMember` → `BuyerGroupPricebook`, y el tachado
  desde `WebStore.StrikethroughPricebookId` — **sin nombres de price book
  hardcodeados**. El buyer necesita **acceso a la clase** (`LvlUp_Quick_Buy_Buyer`,
  REGLA-004).
- **Layout híbrido de la card**: el card estándar se conserva solo por el **nombre
  y el wishlist**; `lvlupProductPrice` asume **SKU, marca y precio** (SKU + badge
  de descuento ovalado en una fila de 2 columnas). Los `sku`/`brand` se bindean a
  `{!Item.fields.StockKeepingUnit.value}` / `{!Item.fields.Brand__c.value}`.
- **CSS scoped** en el head markup de `mainAppPage`, acotado con
  `:has(+ c-lvlup-product-price)` para tocar **solo** la card del Grid de Category:
  oculta SKU/marca estándar, compacta el cuerpo, alinea a un único borde izquierdo
  (`cardInfoPadding` horizontal a 0 + reset del padding del rich-text del nombre) y
  colapsa el `card-actions-area` vacío. El Grid con `isFixedRowHeight: false`.
- **Todo esto es transversal**: no se repite por categoría.
- **Deuda técnica anotada**: `LvlupQuickBuyController.getProductPurchaseInfo` resuelve
  el precio con `ORDER BY IsStandard DESC` → el modal del Quick Buy podría mostrar el
  precio de lista, no el negociado. `LvlupProductPriceController` deja lista la
  resolución correcta si se decide alinear el modal (fase futura).

---

## 8. Relación con Otros Documentos

- `adr/0008-product-information-architecture.md` — decisión y restricciones.
- `docs/salesforce/manual-add-product-runbook.md` — alta de producto (previo a
  enriquecer).
- `docs/salesforce/manual-inventory-setup-runbook.md` — campos de inventario y
  reglas de compra que alimentan disponibilidad y MOQ.
- `docs/salesforce/data-loading-strategy.md` — orden general de carga de datos.
- `docs/ux/plp-pdp-guidelines.md` — comportamiento esperado de PLP/PDP.
- `docs/salesforce/org-validation-checklist.md` — registro de validaciones.

---

## 9. Modelo de Marca (fase 3)

El facet **Marca** (`Brand__c`, picklist restringido, REGLA-030) solo es útil si hay
variedad. El modelo adoptado es **multi-marca acotado**, coherente con los `Name` de
producto y con el negocio (LvlUp es un **distribuidor**, no solo fabricante):

- **`LvlUp`** — marca propia (house brand) de todo el hardware nombrado "LvlUp …":
  Portátiles, Consolas (salvo 2), Monitores, Periféricos, Networking, Accesorios,
  Bundles y el SmartPhone. Es la marca dominante del catálogo.
- **`RetroStation`** / **`CloudPlay`** — sub-marcas de las 2 consolas que el `Name` no
  prefija con LvlUp (`RetroStation Mini`, `CloudPlay Streaming Box`).
- **Editoras de videojuegos** — en videojuegos la "marca" es la **editora/estudio**;
  se usaron 5 editoras ficticias: `Nova Interactive` (saga Galaxy Raiders, 3 títulos),
  `Blackout Games` (2), `Redline Studios`, `Mythdale Games`, `Greenfield Interactive`.

Regla operativa: **añadir el valor al picklist `Brand__c` ANTES de curar** (si falta,
el seed falla al asignarlo). Los videojuegos **digitales** llevan `Warranty_Months__c`
vacío (un digital no tiene garantía de hardware → el heading no muestra garantía).

## 10. Lote del Seed y Límite del Apex Anónimo

El Apex anónimo tiene un **límite de tamaño (~32 KB)**; el catálogo completo de las 9
categorías (51 productos) lo supera. Por eso el contenido se reparte en **dos ficheros
idempotentes**:

| Fichero                                    | Categorías                                                         |
| ------------------------------------------ | ------------------------------------------------------------------ |
| `scripts/apex/seed-product-content.apex`   | Portátiles, SmartPhones, Consolas de gaming, Videojuegos           |
| `scripts/apex/seed-product-content-2.apex` | Monitores, Periféricos, Networking, Accesorios, Bundles enterprise |

Cada fichero replica el mismo framework (interface `ProductContent` + `SpecContent`)
y la misma lógica de Family/regla/loop/report, y solo difiere en su `contentBySku`.
Ambos son idempotentes por SKU (re-run = 0 cambios). Al añadir productos, vigilar el
tamaño (`wc -c`) y crear un lote adicional (`-3`) si un fichero se acerca al límite.
