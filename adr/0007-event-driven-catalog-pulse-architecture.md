# ADR-0007 - Arquitectura Event-Driven para Buyer Group Catalog Pulse

## Estado

Proposed

## Fecha

2026-07-07

## Contexto

- Se quiere ofrecer a los compradores un **feed de novedades de catálogo**
  (productos nuevos, reposiciones, actualizaciones) **segmentado por Buyer Group /
  contexto comercial**, mostrado en un **carrusel** dentro del storefront B2B LWR
  (feature conceptual _Buyer Group Catalog Pulse_).
- El feature es, además, un **vehículo de práctica** de Change Data Capture (CDC),
  Platform Events y arquitectura **event-driven** en Salesforce, y debe dejar una
  **base consultable** para una futura acción de Agentforce.
- B2B Commerce estándar **no** provee un "feed de novedades curado y segmentado".
  La alternativa trivial (un LWC que consulte `Product2 ORDER BY CreatedDate`) no
  cubre la **curación** del tipo de cambio, la **segmentación**, la **persistencia
  consultable** para IA, ni el objetivo de aprendizaje event-driven.
- Restricciones vigentes: `standard-first` (ADR-0002), separación **data vs
  metadata** (ADR-0003) y **pricing/visibility estándar** con entitlements como
  frontera de seguridad (ADR-0004). La visibilidad real de un producto la da el
  `CommerceEntitlementProduct`, no la UI (REGLA-003/004).
- El storefront **no** debe depender de que el browser escuche eventos efímeros
  (CDC/Platform Events); debe consultar **datos persistidos**.

## Decisión

Adoptar una arquitectura **event-driven de backend** con cinco capas de
responsabilidad única, manteniendo estándar lo que ya resuelve el estándar
(visibilidad = entitlements; precio = price books):

1. **Detección**: **Change Data Capture sobre `Product2`**. Un trigger Apex fino
   (`LvlupProduct2ChangeEventTrigger`) se suscribe al `Product2ChangeEvent`.
2. **Curación**: `LvlupCatalogPulseCuration` traduce el cambio crudo en un **evento
   de negocio** (decide `changeType`, `title`, `priority`) y publica un **Platform
   Event** `Catalog_Pulse_Event__e` (Publish After Commit). El evento **no** es una
   copia cruda del CDC.
3. **Persistencia**: un trigger Apex sobre el Platform Event
   (`LvlupCatalogPulseEventTrigger` → `LvlupCatalogPulseSubscriber`) **upserta** de
   forma idempotente (`Pulse_Key__c`) registros **`Catalog_Pulse_Item__c`** (el feed
   consultable, con vigencia y estado).
4. **Servicio**: `LvlupCatalogPulseController` (`without sharing`,
   `@AuraEnabled(cacheable=true)`) resuelve el contexto del comprador y devuelve solo
   novedades **activas, vigentes, del segmento y ENTITLED** (join contra
   `CommerceEntitlementProduct`).
5. **UI**: LWC `lvlupCatalogPulseCarousel` (LWR, mobile-first, branding, estados
   loading/empty/error) que consulta el servicio cacheable.

El objeto `Catalog_Pulse_Item__c` es **metadata**; sus **registros son datos** de
runtime (ADR-0003). La **frontera de seguridad es el entitlement**, no el
`Segment_Key__c` ni la UI (ADR-0004). No se hardcodean IDs de Buyer Groups: el
segmento se resuelve por nombre de grupo a query time.

## Alternativas Consideradas

- **Alternativa A — Flow-first**: CDC → Record-Triggered Flow persiste el feed;
  Apex mínimo solo para la query segura. Declarativa y buena para practicar Flow+CDC,
  pero la curación/dedupe/vigencia y la re-validación de entitlement quedan torpes o
  inseguras en Flow; la query cacheable segura igualmente exige Apex. **Descartada**.
- **Alternativa B — Apex sin CDC**: publicar el Platform Event directamente desde el
  pipeline Platzi y un trigger sobre `Product2`. Menos piezas y sin dependencia de
  Setup, pero **no practica CDC** (objetivo declarado) y no captura cambios de admin
  fuera del pipeline salvo trigger extra. **Descartada**.
- **Alternativa C — Híbrida (elegida)**: CDC → curación Apex → Platform Event de
  negocio → subscriber Apex → objeto persistente → controller cacheable
  entitlement-aware → LWC. Cumple **todos** los objetivos (CDC + Platform Events +
  event-driven + base Agentforce) manteniendo estándar visibilidad y precio.
  **Aceptada** como decisión propuesta.

## Consecuencias

### Positivas

- Practica CDC, Platform Events y arquitectura event-driven con separación limpia.
- El storefront consulta **datos persistidos**, no streaming efímero.
- **Idempotencia** por `Pulse_Key__c`; **bulk-safe** y testeable (núcleos inyectables).
- Seguridad correcta: entitlement como frontera, `without sharing` justificado.
- Deja **contrato reutilizable** para Agentforce (`getCatalogPulseForBuyer`).
- Mantiene estándar el pricing y la visibility (no duplica capacidades).

### Negativas / Trade-offs

- Más piezas que una solución mínima (objeto + evento + 2 triggers + 3 clases + LWC).
- **Depende de habilitar CDC para `Product2` en Setup** (paso manual, no metadata).
- CDC de `Product2` no puede detectar `PRICE_DROP` (el precio vive en
  `PricebookEntry`); ese `changeType` queda soportado en el modelo para una futura
  CDC de `PricebookEntry` o publicación desde el pipeline.
- El `Segment_Key__c` publicado desde CDC es global (null); el afinado por segmento
  concreto es una extensión futura (enriquecimiento o publicación desde el pipeline).

## Impacto en el Proyecto

- **MVP**: es una extensión más allá del MVP base; no altera catálogo/carrito/checkout.
- **Salesforce B2B Commerce**: consume entitlements y catálogo estándar; no los sustituye.
- **Seguridad**: la visibilidad se re-valida server-side contra
  `CommerceEntitlementProduct`; nunca se expone un producto no entitled.
- **Pricing / Visibility**: sin custom pricing; se respeta ADR-0004. El feed no decide
  precio ni visibilidad, solo "novedad".
- **Checkout**: sin impacto.
- **Datos / Metadata**: objeto y evento = metadata; novedades = datos de runtime
  (ADR-0003). Sin IDs hardcodeados.
- **Integración**: reutiliza el patrón de capas (REGLA-017); no crea integración externa.
- **Testing**: tests Apex de curación (unit + end-to-end CDC), subscriber (idempotencia)
  y controller (gate de entitlement); Jest para el LWC; validación como Buyer real.
- **Documentación**: nuevo runbook `manual-catalog-pulse-cdc-runbook.md`; se actualiza
  el índice. Pendiente alinear `security-model.md`/`data-model.md` si se acepta.

## Agentes Relevantes

- `salesforce-architect-agent.md`: valida la arquitectura event-driven y la seguridad.
- `b2b-commerce-specialist-agent.md`: valida entitlements, Buyer Groups y reindexación.
- `salesforce-developer-agent.md`: implementa CDC/Platform Event/Apex/LWC con gap validado.
- `ux-specialist-agent.md`: valida branding, estados y mobile-first del carrusel.
- `qa-specialist-agent.md`: define pruebas del pipeline de eventos y de visibilidad.
- `documentation-agent.md`: valida que este ADR y el runbook no duplican documentación.
- `orchestrator-agent.md`: coordina el alcance incremental (backend + LWC).

## Documentos Relacionados

- `PROJECT_CONTEXT.md`
- `CLAUDE.md`
- `MEMORY.md` (REGLA-003, REGLA-004, REGLA-007, REGLA-011, REGLA-017)
- `docs/DOCUMENTATION_INDEX.md`
- `docs/salesforce/manual-catalog-pulse-cdc-runbook.md`
- `docs/salesforce/data-model.md`
- `docs/salesforce/security-model.md`
- `docs/architecture/solution-architecture.md`
- `docs/architecture/security-architecture.md`
- `docs/development/apex-guidelines.md`
- `docs/development/lwc-guidelines.md`

## Validaciones Pendientes

- ~~Confirmar que CDC está disponible para `Product2`~~ **Verificado (2026-07-07):** el
  trigger Apex sobre `Product2ChangeEvent` auto-suscribe la captura; el pipeline genera
  `Catalog_Pulse_Item__c` sin tocar Setup (prueba de humo con alta de Product2 → item NEW).
- Confirmar los Buyer Groups reales y su nombre como `Segment_Key__c`.
- Validar el pipeline de eventos end-to-end como **Buyer real** (REGLA-001).
- Validar que el LWC requiere **Publish del site** para verse (REGLA-007).
- Validar límites de Platform Events/CDC en Developer Edition.
- Decidir si `PRICE_DROP` se implementa vía CDC de `PricebookEntry` o desde el pipeline.

## ADRs Relacionados

- `adr/0002-standard-first-b2b-commerce-approach.md`
- `adr/0003-commerce-data-vs-metadata-strategy.md`
- `adr/0004-pricing-and-visibility-strategy.md`
- `adr/0006-future-rest-mock-integration-strategy.md`
