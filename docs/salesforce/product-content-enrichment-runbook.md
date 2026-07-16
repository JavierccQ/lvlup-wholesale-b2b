# Runbook: Enriquecimiento de Contenido de Producto por Categoría - LvlUp WholeSale

## 1. Propósito del Documento

Este runbook documenta la **receta replicable** para enriquecer la información de
producto (PDP + product cards) de una categoría interna del catálogo, tal como se
ejecutó en la fase 1 sobre **Portátiles** (`LVL-LAP-001..007`). La arquitectura
está decidida en `adr/0008-product-information-architecture.md` (Accepted): no se
re-diseña; se replica.

La clave de la receta: la configuración de plataforma (campos, mappings del
Builder, facets, sort, FLS) es **transversal y ya está hecha** (sección 3). Para
cada categoría nueva solo hay que **curar datos y reindexar** (sección 4).

Aplica el principio rector: _Configuration first, customization only when
justified_, y la separación data vs metadata de
`adr/0003-commerce-data-vs-metadata-strategy.md`.

---

## 2. Piezas de Referencia

| Pieza                 | Nombre / ruta                                                                      | Rol                                             |
| --------------------- | ---------------------------------------------------------------------------------- | ----------------------------------------------- |
| Campos de contenido   | `Product2.Brand__c` (picklist "Marca"), `Warranty_Months__c`, `EAN__c`, `Family`   | Datos estructurados de la ficha                 |
| Plantilla de specs    | `scripts/apex/seed-product-content.apex` (clase `LaptopContent.toDescriptionHtml`) | HTML estructurado de la Description             |
| Seed de contenido     | `scripts/apex/seed-product-content.apex`                                           | Family (todos los internos) + contenido por SKU |
| LWC de disponibilidad | `lvlupProductAvailability` → `lvlupStockAvailabilityPanel`                         | Stock en la PDP (ya colocado)                   |
| Permission sets       | `LvlUp_Product_Content_Admin` (edición) / `LvlUp_Product_Content_Buyer` (lectura)  | FLS de los campos de contenido                  |
| Reindex               | `scripts/apex/rebuild-search-index.apex`                                           | Único reindex al final (REGLA-026)              |

---

## 3. Configuración Transversal (YA Realizada en Fase 1 — no repetir)

Se documenta para trazabilidad y para reconstruirla en otra org:

1. **Campos**: `Brand__c` (picklist restringido; ver §6 por qué picklist),
   `Warranty_Months__c` (Number 3,0), `EAN__c` (Text 14) +
   `Product2Family` standard value set con las 8 categorías internas.
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
   y los 7 campos de la plantilla (procesador/panel, RAM/resolución, etc. —
   adaptar las etiquetas de la plantilla si la categoría lo requiere, manteniendo
   el orden párrafo comercial + `<ul>`).
2. Reglas del contenido (D4): **español**, ficticio pero verosímil, coherente con
   el `Name` del producto. Los productos Platzi **no se tocan** (fase 4).
3. MOQ y múltiplo **no se escriben a mano**: la plantilla los renderiza desde
   `Min_Order_Quantity__c` / `Order_Increment__c` del registro.

> `Family` no requiere trabajo por categoría: el seed ya lo mapea para **todos**
> los internos activos desde su categoría oficial.

### Paso 3 - Ejecutar el seed (idempotente)

```bash
sf apex run --file scripts/apex/seed-product-content.apex --target-org commerce-b2b-dev
```

Verificar en el log: contadores de actualizados, los `LAPTOP/...` de
verificación y los `WARN outside taxonomy` esperados (Shipping Charge Product,
LVL-CEL-001).

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

---

## 7. Relación con Otros Documentos

- `adr/0008-product-information-architecture.md` — decisión y restricciones.
- `docs/salesforce/manual-add-product-runbook.md` — alta de producto (previo a
  enriquecer).
- `docs/salesforce/manual-inventory-setup-runbook.md` — campos de inventario y
  reglas de compra que alimentan disponibilidad y MOQ.
- `docs/salesforce/data-loading-strategy.md` — orden general de carga de datos.
- `docs/ux/plp-pdp-guidelines.md` — comportamiento esperado de PLP/PDP.
- `docs/salesforce/org-validation-checklist.md` — registro de validaciones.
