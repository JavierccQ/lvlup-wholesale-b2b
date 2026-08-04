# ADR-0009 - Migración de las Reglas de Cantidad de Compra a `PurchaseQuantityRule` (estándar)

## Estado

Accepted

## Fecha

2026-07-22

## Contexto

La fase 1 (ADR-0008) dejó las reglas de cantidad de compra (MOQ / múltiplo de
venta / máximo) en **campos custom de `Product2`** (`Min_Order_Quantity__c`,
`Order_Increment__c`, `Max_Order_Quantity__c`), leídos por
`LvlupQuickBuyController.getProductPurchaseInfo` y renderizados en la Description
de la PDP por `scripts/apex/seed-product-content.apex`. La decisión D2 de
ADR-0008 pospuso explícitamente a fase 2, **con ADR propio y garantía de
compatibilidad con el Contextual Quick Buy**, la migración de esas reglas al
objeto estándar de Commerce.

El objetivo de esta fase es tener una **fuente de verdad única y estándar** para
MOQ / múltiplo / máximo, sin romper el Quick Buy ni la PDP.

> Nota de alcance: el **stock** (`Inventory_Quantity__c`) **no es** una regla de
> cantidad de compra; es inventario simulado (ver
> `docs/salesforce/manual-inventory-setup-runbook.md`) y **permanece** en
> `Product2`. Esta migración afecta **solo a 3** de los 4 campos custom.

## Hallazgos del análisis (FASE A, read-only, 2026-07-22)

Validado contra la org `commerce-b2b-dev` (API 67.0):

1. **V1 — el objeto estándar existe y sirve.** `PurchaseQuantityRule` es objeto
   **estándar** (`custom: false`, label "Quantity Rule"), creable/actualizable/
   consultable, con los campos exactos que necesitamos: `Name` (requerido),
   `Minimum`, `Maximum`, `Increment` (double, nillable).
2. **La asociación a producto es vía junction, no lookup directo.** `Product2`
   **NO** tiene `PurchaseQuantityRuleId` (la hipótesis inicial era incorrecta:
   `No such column`). La asociación es el objeto junction estándar
   **`ProductQuantityRule`** (`custom: false`), con `ProductId` → `Product2` y
   `PurchaseQuantityRuleId` → `PurchaseQuantityRule` (ambos requeridos).
3. **Punto de partida limpio.** 0 registros `PurchaseQuantityRule` y 0
   `ProductQuantityRule` en la org.
4. **Sin dimensión de Buyer Group / entitlement.** `PurchaseQuantityRule` no
   tiene relación con `CommerceEntitlementPolicy` ni con Buyer Group: la regla es
   **global por producto** (a diferencia del pricing, que sí es por Buyer Group,
   REGLA-033). Correcto para MOQ.
5. **V2 — la PDP estándar ya está cableada a la regla.** La vista `detail_01t`
   contiene el selector de cantidad estándar con `minimumValueGuideText` /
   `maximumValueGuideText` / `incrementValueGuideText` y una región
   `combinedPurchaseQuantityRuleInfo` bindeada a
   `{!Product.Details.purchaseQuantityRule.minimum/maximum/increment}`. Es decir:
   **asociar la regla activa el enforcement y el display estándar de la PDP** sin
   configuración adicional (hoy inertes porque hay 0 reglas). El enforcement
   server-side real del add-to-cart debe **verificarse como buyer** (V2, live).
6. **Distribución de datos** (productos activos):
   - Internos (52): `1/1/500` ×39, `5/5/500` ×13.
   - Externos (63): `1/1/1000` ×63 (default de `LvlupExternalProductPublisher`).
   - → **3 reglas distintas** cubren los 115 productos activos.
7. **Los productos externos también usan el Quick Buy** y hoy tienen `max=1000`.
   Si el controller pasa a leer solo la regla estándar y no se les crea regla,
   su comportamiento cambiaría (perderían el tope). Esto condiciona el alcance
   del seed (ver Decisión, punto D-Alcance).

## Decisión (propuesta)

### D1 — Fuente de verdad = `PurchaseQuantityRule` + `ProductQuantityRule` (DATA)

Las reglas son **datos** (ADR-0003), no metadata. Un seed idempotente
(`scripts/apex/seed-purchase-quantity-rules.apex`) crea **una
`PurchaseQuantityRule` por combinación distinta** de min/inc/máx (nombre
funcional determinista, p. ej. `MOQ 1 / Inc 1 / Max 500`, resoluble por sus
valores, **sin IDs hardcodeados**) y **un `ProductQuantityRule`** por producto,
casando cada producto con la regla de su combo actual. Re-ejecutar el seed
reconcilia sin duplicar (idempotente por combo y por `ProductId`).

### D2 — El Quick Buy lee la regla vía Apex, con el MISMO contrato

`LvlupQuickBuyController.getProductPurchaseInfo` deja de leer los 3 campos custom
y pasa a resolver la regla por SOQL sobre `ProductQuantityRule` →
`PurchaseQuantityRule` (`Minimum`/`Increment`/`Maximum`). El DTO
`ProductPurchaseInfo` **no cambia** (`minQuantity`/`increment`/`maxQuantity`),
por lo que **el LWC no se toca** y el comportamiento visible es idéntico. `stock`
sigue viniendo de `Inventory_Quantity__c`. Si un producto no tuviera regla, se
aplican defaults seguros (min=1, inc=1, máx=null) que coinciden con los defaults
del `lvlupQuantitySelector` → ningún producto se rompe.

Esto respeta ADR-0002: **no se añade Apex nuevo**; el Quick Buy ya es un
componente custom justificado, y solo se cambia su **fuente de datos** a la
estándar. Se descarta reescribirlo para consumir la API estándar de
purchase-info porque no existe un camino cacheable más simple que el SOQL al
junction, y reescribir el modal añadiría riesgo sin beneficio.

### D3 — La Description toma MOQ/múltiplo de la regla estándar

`seed-product-content.apex` deja de leer `Min_Order_Quantity__c` /
`Order_Increment__c` y renderiza el MOQ/múltiplo **desde la
`PurchaseQuantityRule`** asociada (misma fuente única). El texto visible de la
PDP no cambia. La región estándar `combinedPurchaseQuantityRuleInfo` (hallazgo
V2) quedó **oculta** para no duplicar el dato en la PDP (ver Decisiones
confirmadas #4).

### D-Alcance — asociar regla a TODOS los productos activos (CONFIRMADO)

Para cumplir el criterio "el Quick Buy funciona **exactamente igual**" también en
productos externos (que usan el Quick Buy y hoy tienen `max=1000`), el seed
asocia regla a los **115 productos activos** (internos + externos). Asociar una
regla de cantidad es **mecánico** (no es enriquecer contenido/Family/media, que
sigue siendo Fase 4): no expande el alcance de contenido, solo preserva el
comportamiento y logra una fuente única real, sin fallback dual.

### D-Campos — deprecar los 3 campos custom en modo read-only (CONFIRMADO)

`Min_Order_Quantity__c`, `Order_Increment__c`, `Max_Order_Quantity__c` se marcan
como **deprecados** (descripción "DEPRECATED — usar PurchaseQuantityRule
(ADR-0009)") y se retiran de todos los **caminos de lectura del storefront**
(controller del Quick Buy, seed de contenido de la PDP). Se conservan (no se
eliminan) por reversibilidad y para no tocar metadata destructivamente
(ADR-0002). `Inventory_Quantity__c` queda intacto. La FLS de los campos en los
permission sets se deja como está (no molesta; los campos existen).

### D-Publisher / REGLA-009 — limpieza DIFERIDA (decisión del usuario, 2026-07-22)

`LvlupExternalProductPublisher` está en la cadena de dependencias del job
programado activo **"LvlUp Platzi Daily Import"**
(`LvlupPlatziDailyScheduler` → `LvlupPlatziPipelineQueueable` → … → publisher);
recompilarlo fallaría con "jobs pending" (REGLA-009) y obligaría a abortar y
reprogramar una integración viva. Se decide **NO tocar el publisher en esta
fase** (bloque manual con riesgo, REGLA-016). Consecuencias:

- El publisher sigue escribiendo los 3 campos deprecados. Es **inofensivo**: el
  storefront (Quick Buy + Description) ya no los lee; solo lee la regla estándar.
- Los campos quedan demotados a **input recuperable del seed de reglas**: tras
  cada importación Platzi, re-ejecutar `seed-purchase-quantity-rules.apex`
  asocia la regla a los externos nuevos desde sus valores de campo → **no hay
  hueco** para productos externos futuros.
- **Follow-up (opcional)**: cuando convenga, retirar la escritura de los 3 campos
  del publisher desplegándolo con el patrón REGLA-009 (abortar → deploy →
  reprogramar con cron `0 0 3 * * ?`).

## Alternativas Consideradas

- **Leer la regla vía API estándar de purchase-info en un componente estándar**
  (sustituir el Quick Buy por el add-to-cart/quantity selector estándar):
  descartado — el Quick Buy custom es un feature ya entregado y validado; el
  objetivo es migrar la **fuente de datos**, no rehacer la UX. El componente
  estándar sí se aprovechará en la PDP (V2).
- **Mantener los campos custom como fuente y solo "espejar" a la regla**:
  descartado — no logra fuente de verdad única estándar (dos fuentes que pueden
  divergir).
- **Alcance solo-internos con fallback dual en el controller** (rule-first, luego
  campo custom): descartado como opción por defecto — preserva externos pero
  mantiene los campos custom vivos como fuente, contradiciendo "fuente única".
  Queda como plan B si se decide no tocar externos.
- **Reglas por Buyer Group**: no aplica — el modelo `ProductQuantityRule` es
  producto-global; no hay dimensión de Buyer Group en el estándar.

## Consecuencias

### Positivas

- Fuente de verdad **única y estándar** para MOQ/múltiplo/máximo.
- Se activa el **enforcement y display estándar** de la regla en la PDP (V2) sin
  código nuevo.
- Quick Buy sin cambio de comportamiento ni de contrato (LWC intacto).
- Seed idempotente, sin IDs hardcodeados (ADR-0003); receta replicable.
- Prepara el terreno para que cart/checkout estándar respeten la regla.

### Negativas / Trade-offs

- Si se deprecan (no se eliminan) los campos, quedan 3 columnas muertas (mitigado:
  descripción DEPRECATED + retiradas de todo camino de lectura/escritura).
- Añade un objeto/junction más al modelo de datos y al seed.
- V2 (enforcement server-side del add-to-cart) depende de comportamiento de la
  org/store y debe verificarse en vivo como buyer (REGLA-001/016); si el
  `addItemToCart` no lo enforce server-side, el Quick Buy lo sigue enforce
  client-side igual que hoy (comportamiento preservado).
- Insertabilidad de `PurchaseQuantityRule`/`ProductQuantityRule` en tests Apex por
  confirmar (REGLA-011); si no fueran insertables, el controller se refactoriza a
  un método core inyectable.

## Validaciones

- **V1** — `PurchaseQuantityRule` disponible y asociable a `Product2` en la org.
  **Resultado: OK** (análisis FASE A).
- **V2** — el add-to-cart estándar enforce la regla server-side (buyer real: pedir
  < MOQ y romper el múltiplo). **Pendiente (live, Fase B).**
- **V3** — el Quick Buy migrado se comporta idéntico al actual (MOQ inicial,
  incremento, máximo, mensajes, add-to-cart). **Pendiente (Fase B).**
- **Regresión completa** del Quick Buy como Buyer real en el sitio publicado
  (REGLA-001), nunca solo en Builder Preview.

## Impacto en el Proyecto

- **MVP**: sin cambio de alcance; consolida la información de producto.
- **B2B Commerce**: valida `PurchaseQuantityRule`/`ProductQuantityRule` como
  capacidad estándar real de la org.
- **Seguridad**: la regla la lee Apex `without sharing` (REGLA-004); la FLS de los
  campos deprecados se retira de los caminos de lectura del buyer.
- **Datos / Metadata**: reglas y junctions = datos (seed idempotente); los campos
  custom siguen siendo metadata (deprecada), per ADR-0003.
- **Testing**: QA como Buyer real (REGLA-001); tests Apex del controller migrado;
  Jest del Quick Buy sin cambios (contrato intacto).
- **Documentación**: este ADR (→ Accepted), `manual-inventory-setup-runbook.md`,
  `contextual-quick-buy-code-walkthrough.md`, `data-model.md`,
  `DOCUMENTATION_INDEX.md` y la nota de MOQ en ADR-0008.

## Agentes Relevantes

- `b2b-commerce-specialist-agent` (capacidad estándar de quantity rules).
- `salesforce-architect-agent` (modelo junction, standard-first, fuente única).
- `salesforce-developer-agent` (seed idempotente, migración del controller/tests).
- `qa-specialist-agent` (V2/V3 como buyer, regresión Quick Buy).
- `documentation-agent` (ADR, runbooks, índice).

## ADRs Relacionados

- ADR-0002 (standard-first): esta decisión lo aplica llevando la regla al estándar.
- ADR-0003 (data vs metadata): reglas y junctions = datos; campos = metadata.
- ADR-0008 (información de producto, D2 y adenda): esta fase ejecuta lo pospuesto.

## Documentos Relacionados

- `docs/salesforce/manual-inventory-setup-runbook.md`
- `docs/development/contextual-quick-buy-code-walkthrough.md`
- `docs/salesforce/data-model.md`
- `docs/salesforce/product-content-enrichment-runbook.md`

## Decisiones confirmadas (2026-07-22)

1. **Alcance de la asociación**: **todos los productos activos (115)**, internos
   - externos (aprobado por el usuario).
2. **Campos custom**: **deprecar read-only** (aprobado por el usuario).
3. **Publisher de externos**: **limpieza diferida** (aprobado por el usuario) por
   el riesgo REGLA-009 sobre el job Platzi vivo; el publisher sigue escribiendo
   los campos deprecados de forma inofensiva (ver D-Publisher).
4. **Región `combinedPurchaseQuantityRuleInfo` de la PDP**: **ocultarla**
   (aprobado por el usuario con captura, REGLA-016). Al asociarse la regla, el
   componente estándar de la PDP pobló esa región mostrando la regla en **inglés**
   (`Minimum Quantity is 5 • …`), duplicando lo que la Description ya muestra en
   español. Se **vació la región** en la vista `detail_01t` (se retiró el
   `dxp_base:textBlock`) y se republicó el sitio. Resultado: la PDP muestra
   MOQ/múltiplo solo vía la Description (español), como antes de la migración. El
   selector de cantidad estándar sigue enforçando la regla (V2).
