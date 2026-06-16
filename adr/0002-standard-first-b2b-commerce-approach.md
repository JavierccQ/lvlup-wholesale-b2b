# ADR-0002 - Standard-First B2B Commerce Approach

## Estado

Accepted

## Fecha

2026-06-16

## Contexto

- `LvlUp-Wholesale-B2B` simula una **implementación B2B Commerce real**.
- Salesforce B2B Commerce ofrece **capacidades estándar** que deben evaluarse antes de
  construir custom.
- En proyectos Salesforce existe el riesgo de **saltar prematuramente** a Apex, LWC,
  Flow o integración por comodidad o por desconocimiento del estándar.
- En un MVP controlado, **customizar demasiado pronto** genera sobre-ingeniería, más
  testing, más mantenimiento y más riesgo.
- El proyecto busca practicar **arquitectura Salesforce realista**, por lo que debe
  priorizar configuración, datos y capacidades estándar.
- El storefront debe ser **funcional**, pero sin reemplazar innecesariamente
  componentes estándar.
- Este ADR formaliza el **orden de decisión** para resolver las necesidades del
  proyecto. Profundiza la dirección de alcance fijada en
  `adr/0001-project-scope-and-mvp-boundaries.md`.

---

## Decisión

El proyecto adopta oficialmente un enfoque **`standard-first`** para Salesforce B2B
Commerce.

El **orden de evaluación obligatorio** será:

1. **Salesforce B2B Commerce estándar.**
2. **Experience Builder.**
3. **Configuración** Salesforce/B2B Commerce.
4. **Datos Commerce.**
5. **Flow**, solo si la lógica es declarativa, simple y mantenible.
6. **LWC**, solo si existe gap UX real y validado.
7. **Apex**, solo si se requiere control técnico, transaccionalidad, integración,
   validación server-side o lógica compleja.
8. **Integración externa**, solo si el dato o proceso vive fuera de Salesforce y está
   dentro del alcance aprobado.

Ninguna solución custom debe proponerse como **primera respuesta** ante un
requerimiento funcional.

Si una capacidad no está confirmada en la Developer Org, debe marcarse como
**`pendiente de validación en org`**.

---

## Alternativas Consideradas

### Alternativa 1 - Standard-first con customización justificada

Descripción:

- Validar estándar, Experience Builder, configuración y datos antes de custom.
- Usar Flow, LWC, Apex o integración solo cuando exista gap real.
- Documentar las decisiones relevantes mediante ADR.

Resultado: **alternativa aceptada**.

### Alternativa 2 - Desarrollo custom desde el inicio

Descripción:

- Crear Apex, LWC y lógica propia para cubrir catálogo, pricing, checkout o reorder
  sin validar estándar.

Resultado: **rechazada** porque aumenta complejidad, mantenimiento, testing y riesgo,
y contradice el objetivo de practicar B2B Commerce realista.

### Alternativa 3 - Solo configuración, sin permitir customización

Descripción:

- Usar exclusivamente configuración estándar aunque existan gaps reales.

Resultado: **rechazada** porque el proyecto también busca practicar arquitectura,
desarrollo e integración cuando estén justificados.

### Alternativa 4 - Integración externa como solución por defecto

Descripción:

- Resolver stock, pricing, crédito, pedidos o facturas mediante servicios externos
  desde el inicio.

Resultado: **rechazada** porque ERP real e integración productiva están fuera del MVP;
solo se contempla integración REST simulada futura.

---

## Consecuencias

### Positivas

- Menos sobre-ingeniería.
- Mejor alineación con las prácticas Salesforce.
- Mayor aprovechamiento de B2B Commerce estándar.
- Menor complejidad inicial.
- Menos deuda técnica.
- Mejor mantenibilidad.
- Menor superficie de testing técnico custom.
- Mejor separación entre configuración, datos y código.
- Mejor trazabilidad para las decisiones custom.
- Mejor disciplina para los agentes IA.
- Mejor control del MVP.

### Negativas / Trade-offs

- Algunas soluciones custom se retrasarán hasta validar el estándar.
- Algunas capacidades dependerán de validación en la Developer Org.
- Puede requerir más análisis funcional/configurativo antes de desarrollar.
- Algunas limitaciones estándar podrían obligar a aceptar comportamientos no ideales.
- La documentación debe registrar claramente **cuándo el estándar no alcanza**.
- El equipo/agentes deben evitar **asumir que una capacidad existe** sin validarla.

---

## Impacto en el Proyecto

### MVP

El MVP se construirá priorizando **estándar/configuración/datos antes que custom**.

### Salesforce B2B Commerce

B2B Commerce estándar será la **primera opción** para:

- Product Catalog.
- Categories.
- Products.
- Buyer access.
- Buyer Groups.
- Pricing.
- Product visibility.
- PLP.
- PDP.
- Cart.
- Checkout.
- Order history.
- Reorder.

### Seguridad

La seguridad **no** puede resolverse solo con UI. Buyer account isolation, pricing
visibility, product visibility y order access deben validarse desde
estándar/configuración/server-side.

### Pricing / Visibility

Pricing y visibility deben resolverse primero mediante capacidades estándar,
configuración y datos Commerce. Cualquier **custom pricing** o **custom visibility**
requiere análisis arquitectónico y ADR.

### Checkout

El checkout debe usar estándar/configuración primero. Cualquier lógica custom que
afecte confirmed/pending, approval, credit, stock o validaciones críticas debe
escalarse y probablemente requerir ADR.

### Datos / Metadata

Muchos comportamientos de B2B Commerce dependen de **datos Commerce**. No se debe
confundir falta de datos/configuración con necesidad de código.

### Integración

La integración real queda **fuera del MVP**. La integración REST simulada futura solo
debe proponerse si está alineada con el ADR correspondiente.

### Testing

Cada decisión custom aumenta la necesidad de functional testing, security testing,
regression testing y technical testing.

### Documentación

Cuando una decisión estándar vs custom sea relevante, debe reflejarse en la
documentación existente o en un ADR.

---

## Orden de Decisión Standard-First

### 1. Salesforce B2B Commerce estándar

- ¿La capacidad existe de forma estándar?
- ¿Está disponible en la Developer Org?
- ¿Está documentada en `b2b-commerce-standard-capabilities.md`?
- ¿Está validada en `org-validation-checklist.md`?

### 2. Experience Builder

- ¿Puede resolverse con layout, componentes estándar o configuración visual?
- ¿La necesidad es realmente funcional o solo estética?
- ¿El comportamiento se mantiene mobile-first?

### 3. Configuración Salesforce/B2B Commerce

- ¿Puede resolverse con configuración?
- ¿Afecta Buyer Groups?
- ¿Afecta Price Books?
- ¿Afecta visibility?
- ¿Afecta checkout?
- ¿Afecta el security model?

### 4. Datos Commerce

- ¿Faltan productos, categorías, prices, Buyer Groups o visibility records?
- ¿El problema es reproducible con datos correctos?
- ¿Está contemplado en `data-loading-strategy.md`?

### 5. Flow

- ¿La lógica es simple, declarativa y mantenible?
- ¿Tiene fault paths?
- ¿Impacta el checkout?
- ¿Requiere ADR si se vuelve lógica central?

### 6. LWC

- ¿Existe un gap UX real?
- ¿Experience Builder no cubre el caso?
- ¿Se validó mobile-first?
- ¿No se está usando LWC para seguridad?
- ¿Se requiere Architect/Developer/QA?

### 7. Apex

- ¿Se requiere control server-side?
- ¿Hay integración, transaccionalidad o lógica compleja?
- ¿Flow no es suficiente?
- ¿Hay testing y mocks?
- ¿Se requiere ADR?

### 8. Integración externa

- ¿El dato/proceso vive fuera de Salesforce?
- ¿Está dentro del MVP?
- ¿Es mock o integración real?
- ¿Requiere Named Credential?
- ¿Requiere ADR?

---

## Criterios para Permitir Customización

Se puede permitir customización **solo si**:

- Existe un gap real.
- El estándar fue evaluado.
- La configuración fue evaluada.
- Los datos fueron evaluados.
- El impacto en seguridad fue revisado.
- El impacto en pricing/visibility fue revisado si aplica.
- El impacto en cart/checkout fue revisado si aplica.
- El impacto en testing fue definido.
- El `Salesforce Architect Agent` lo valida si es relevante.
- El `Documentation Agent` valida si requiere ADR o actualización documental.

---

## Criterios para Rechazar Customización

Debe **rechazarse o aplazarse** la customización si:

- Se propone Apex por comodidad.
- Se propone LWC por estética.
- Se propone Flow para lógica excesivamente compleja.
- Se propone integración real fuera del MVP.
- El problema es de datos.
- El problema es de configuración.
- No se validó el estándar.
- No hay acceptance criteria claros.
- No hay testing definido.
- La solución aumenta mucho la complejidad sin valor real.
- Resuelve seguridad solo desde UI.
- Duplica capacidades estándar.

---

## Ejemplos de Aplicación

### Producto no aparece en PLP

Primero revisar: Product Catalog; category association; Buyer Group; Price Book;
product visibility; storefront configuration. **No** proponer LWC/Apex inicialmente.

### Buyer ve precio incorrecto

Primero revisar: Buyer Group; Price Book; Price Book Entry; pricing strategy;
consistencia PLP/PDP/cart/checkout. **No** proponer custom pricing inicialmente.

### Checkout requiere aprobación

Primero revisar: regla de negocio; umbral; capacidad estándar/configuración; Flow si
es simple; Apex solo si hay complejidad real; ADR si afecta la lógica central de
checkout.

### Reorder parcial

Primero revisar: capacidad estándar; order history; product visibility actual; pricing
actual; stock funcional; UX del mensaje; LWC solo si hay gap UX real.

### Stock o crédito externo

Primero revisar: MVP scope; dato funcional/mock; integración real fuera del MVP;
integración simulada futura solo con el ADR correspondiente.

---

## Agentes Relevantes

- `orchestrator-agent.md`: debe **frenar la customización prematura**.
- `business-analyst-agent.md`: debe definir requerimiento y acceptance criteria antes
  de la solución.
- `b2b-commerce-specialist-agent.md`: debe validar estándar/configuración/datos.
- `salesforce-architect-agent.md`: debe validar la customización relevante.
- `ux-specialist-agent.md`: debe validar si hay gap UX real antes de LWC.
- `salesforce-developer-agent.md`: debe proponer Flow/LWC/Apex/integration solo con gap
  validado.
- `qa-specialist-agent.md`: debe definir testing y regression.
- `documentation-agent.md`: debe validar si la decisión requiere ADR o actualización
  documental.

---

## Documentos Relacionados

- `PROJECT_CONTEXT.md`
- `CLAUDE.md`
- `docs/DOCUMENTATION_INDEX.md`
- `adr/README.md`
- `adr/0001-project-scope-and-mvp-boundaries.md`
- `docs/business/mvp-scope.md`
- `docs/business/product-catalog-strategy.md`
- `docs/business/pricing-and-visibility-strategy.md`
- `docs/architecture/standard-vs-custom-framework.md`
- `docs/architecture/solution-architecture.md`
- `docs/architecture/security-architecture.md`
- `docs/architecture/limitations-and-assumptions.md`
- `docs/salesforce/b2b-commerce-standard-capabilities.md`
- `docs/salesforce/configuration-decisions.md`
- `docs/salesforce/data-model.md`
- `docs/salesforce/security-model.md`
- `docs/salesforce/data-loading-strategy.md`
- `docs/salesforce/org-validation-checklist.md`
- `docs/development/apex-guidelines.md`
- `docs/development/lwc-guidelines.md`
- `docs/development/flow-guidelines.md`
- `docs/development/integration-guidelines.md`
- `docs/testing/test-strategy.md`
- `docs/testing/regression-checklist.md`

---

## Validaciones Pendientes

- Validar las capacidades estándar reales disponibles en la Developer Org.
- Validar qué componentes estándar de B2B Commerce están disponibles en Experience
  Builder.
- Validar el comportamiento estándar de cart y checkout.
- Validar el comportamiento estándar de order history y reorder.
- Validar cómo se configuran los Buyer Groups en la org.
- Validar cómo se resuelve el pricing por cuenta o segmento.
- Validar el product visibility.
- Validar qué parte de la configuración Commerce es metadata, data o configuración
  manual.
- Validar cuándo Flow/LWC/Apex será realmente necesario.

---

## ADRs Relacionados

- `adr/README.md`
- `adr/0001-project-scope-and-mvp-boundaries.md`
- `adr/0003-commerce-data-vs-metadata-strategy.md` (ADR futuro relacionado).
- `adr/0004-pricing-and-visibility-strategy.md` (ADR futuro relacionado).
- `adr/0005-checkout-approval-credit-and-stock-strategy.md` (ADR futuro relacionado).
- `adr/0006-future-rest-mock-integration-strategy.md` (ADR futuro relacionado).

---

## Notas Finales

Este ADR debe considerarse la **fuente de verdad** para decidir si una necesidad debe
resolverse con estándar, configuración, datos o customización. Cualquier propuesta de
Flow, LWC, Apex o integración debe poder **justificar claramente** por qué las opciones
anteriores no son suficientes.
