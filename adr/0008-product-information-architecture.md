# ADR-0008 - Arquitectura de Información de Producto (PDP + Product Cards)

## Estado

Accepted

## Fecha

2026-07-16

## Contexto

La PDP y las product cards del storefront mostraban información mínima (nombre,
SKU, precio, imagen): sin marca, sin familia, sin garantía, sin especificaciones
y sin disponibilidad de stock en la PDP. Los compradores B2B (resellers) toman
decisiones con datos técnicos y comerciales que el catálogo ya no cubría, y los
facets de búsqueda se limitaban al de categoría.

Se necesitaba decidir **dónde vive la información de producto** (campos, HTML,
attribute sets, componentes custom) y **cómo se muestra** (field mappings
estándar, LWC, contenido CMS), respetando el principio _Configuration first,
customization only when justified_ (ADR-0002) y la separación data vs metadata
(ADR-0003).

## Decisión

Adoptar la **Arquitectura A: campos transversales en `Product2` + Description
con HTML estructurado + mapeos estándar**, ejecutada como _vertical slice_ sobre
la categoría Portátiles (7 productos `LVL-LAP-001..007`) con receta replicable
(ver runbook):

1. **Campos transversales nuevos en `Product2`**: `Brand__c` (picklist
   restringido, label "Marca"), `Warranty_Months__c` (Number 3,0), `EAN__c`
   (Text 14). `Family` (estándar) se puebla con la taxonomía oficial de 8
   categorías (el Name de la categoría es el valor del picklist).
2. **Description con HTML estructurado** generado por plantilla fija (párrafo
   comercial B2B + `<ul>` de especificaciones: procesador, RAM, almacenamiento,
   pantalla, GPU, SO, peso + reglas de compra). Contenido en español. Se
   renderiza en el acordeón "Especificaciones" de la PDP (HTML Editor estándar
   ya bindeado a `{!Product.Details.fields.Description}`).
3. **Mapeos estándar**: el heading de la PDP mapea Marca/Familia/Garantía
   (límite de 3 mappings del componente; el mapping de Product Code se elimina
   por redundante con el SKU del propio heading). Las cards de categoría y
   búsqueda mapean `Brand__c` sin label.
4. **MOQ y múltiplo de venta** se muestran dentro del HTML de Description,
   renderizados en seed-time **desde** `Min_Order_Quantity__c` /
   `Order_Increment__c` (una sola fuente de verdad con el Quick Buy). Decisión
   forzada por el límite de 3 mappings del heading.
5. **Disponibilidad en la PDP** con un único LWC nuevo: `lvlupProductAvailability`
   (contenedor fino que reutiliza el Apex cacheable
   `LvlupQuickBuyController.getProductPurchaseInfo` y el panel presentacional
   `lvlupStockAvailabilityPanel`). Sin Apex nuevo.
6. **FLS por permission sets**: `LvlUp_Product_Content_Admin` (edición, admin) y
   `LvlUp_Product_Content_Buyer` (lectura, buyer) — el canal commerce exige FLS
   de lectura en campos custom (validación V6).
7. **Search**: facets de Familia y Marca, sort rules por precio (con _Price Book
   for Sorting_ = LevelUp Wholesale Price Book), _Partial SKU Search_ activado y
   un **único reindex** al final de la fase (REGLA-026).
8. **Datos como registros** (ADR-0003): seed idempotente
   `scripts/apex/seed-product-content.apex`, clave por SKU, sin IDs hardcodeados.

Restricciones de plataforma **validadas durante la ejecución** (condicionan la
receta):

- El componente _Product Detail Headings_ admite **máximo 3 field mappings**.
- Los **facets solo aceptan tipos enumerables** (picklist, multi-select,
  checkbox, number); un Text no es facetable → `Brand__c` debe ser picklist.
- La conversión **Text→Picklist no está soportada** en esta org (ni Metadata API
  ni Setup UI): hubo que eliminar y recrear el campo (mismo API name, los
  mappings del Builder sobreviven porque referencian por nombre).
- El **canal commerce aplica FLS** a campos custom de `Product2` tanto en el
  field mapping de la PDP como en los campos de card de search; los facets (agregaciones
  del índice) no la exigen.
- El **label del facet es el label del campo** (no configurable por facet).

## Alternativas Consideradas

- **Product Attribute Sets**: descartado; están orientados a variaciones de
  producto, no a ficha técnica, y añaden complejidad sin beneficio en fase 1.
- **LWC custom de especificaciones**: descartado; el HTML en Description +
  acordeón estándar cubre la necesidad sin código (standard-first).
- **Plan B — todo en Description HTML** (sin campos transversales): descartado
  al pasar la validación V4 (los mappings estándar aceptan campos custom); solo
  MOQ/múltiplo acabaron en la Description por el límite de 3 mappings.
- **Migrar MOQ a `PurchaseQuantityRule` estándar ahora**: pospuesto a fase 2 con
  ADR propio y garantía de compatibilidad con el Quick Buy (D2).

## Consecuencias

### Positivas

- Ficha de producto B2B completa con configuración estándar y un único LWC
  contenedor (cero Apex nuevo).
- Datos consultables y facetables (marca, familia) en lugar de texto plano.
- Receta replicable por categoría: solo datos + reindex (la configuración de
  Builder/Search es transversal y ya está hecha).
- Idempotencia: re-ejecutar el seed re-sincroniza contenido y reglas de compra.

### Negativas / Trade-offs

- MOQ/múltiplo duplicados visualmente en la Description (mitigado: se generan
  desde los campos en cada ejecución del seed).
- Brand como picklist restringido exige gobernanza (añadir valor antes de curar
  una marca nueva).
- Labels de facets atados al label del campo (Family se muestra "Product
  Family"; idioma de labels estándar sigue en backlog).
- El contenido HTML vive en un script Apex (no en CMS); cambios de copy
  requieren editar y re-ejecutar el seed.

## Impacto en el Proyecto

- **MVP**: completa la PDP/PLP con información B2B; sin cambio de alcance.
- **Salesforce B2B Commerce**: field mappings, facets, sort rules y partial SKU
  search validados como capacidades estándar reales de la org.
- **Seguridad**: FLS explícita por permission sets (admin edita, buyer lee);
  mínimo privilegio.
- **Pricing / Visibility**: sin cambios (fuera de alcance de la fase).
- **Checkout**: sin cambios; Quick Buy verificado sin regresión.
- **Datos / Metadata**: campos y permission sets = metadata; contenido = datos
  (seed idempotente), per ADR-0003.
- **Integración**: sin cambios; los productos Platzi quedan fuera (fase 4).
- **Testing**: QA como Buyer real (REGLA-001) con checklist de 7 puntos; Jest
  para el LWC nuevo.
- **Documentación**: runbook de la receta + actualizaciones de data-model,
  data-loading-strategy, configuration-decisions, org-validation-checklist,
  plp-pdp-guidelines y limitations-and-assumptions.

## Agentes Relevantes

- `b2b-commerce-specialist-agent` (capacidades estándar de search/mappings).
- `salesforce-architect-agent` (modelo de campos, FLS, standard-first).
- `salesforce-developer-agent` (seed idempotente, LWC contenedor).
- `ux-specialist-agent` (contenido de PDP/cards, acordeón).
- `qa-specialist-agent` (QA como buyer, regresión Quick Buy).
- `documentation-agent` (runbook e índice).

## Documentos Relacionados

- `docs/salesforce/product-content-enrichment-runbook.md` (receta replicable)
- `docs/salesforce/data-model.md` (§ campos de contenido de Product2)
- `docs/salesforce/data-loading-strategy.md` (orden de carga)
- `docs/salesforce/configuration-decisions.md` (CFG-PRD/CFG-PLP/CFG-SEC nuevos)
- `docs/salesforce/org-validation-checklist.md` (resultados V4/V5/V6)
- `docs/ux/plp-pdp-guidelines.md` (§10 decisiones resueltas)
- `docs/architecture/limitations-and-assumptions.md` (RISK-016)

## Validaciones Pendientes

- Fase 2: migración de MOQ a `PurchaseQuantityRule` (ADR propio; compatibilidad
  Quick Buy).
- Fase 3: replicar la receta en Monitores y resto de categorías internas.
- Fase 4: contenido/Family de productos Platzi.
- Revisar el riesgo _Skip Entitlement Checks During Search = ON_ si se introduce
  catálogo restringido (RISK-016).

## ADRs Relacionados

- ADR-0002 (standard-first): esta decisión lo aplica.
- ADR-0003 (data vs metadata): el contenido es dato; los campos, metadata.
- ADR-0007 (Catalog Pulse): sin interacción directa; comparte el patrón de
  permission sets por feature.
