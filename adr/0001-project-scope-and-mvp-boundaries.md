# ADR-0001 - Project Scope and MVP Boundaries

## Estado

Accepted

## Fecha

2026-06-16

## Contexto

- `LvlUp-Wholesale-B2B` es un proyecto personal de **práctica avanzada**.
- Simula una **implementación empresarial real** de Salesforce B2B Commerce.
- La empresa ficticia es `LvlUp WholeSale`.
- El negocio representa una **distribuidora mayorista local de tecnología y gaming en
  España** (consolas, videojuegos, laptops, monitores, periféricos, networking,
  accesorios y bundles empresariales).
- El proyecto busca practicar **arquitectura Salesforce, B2B Commerce, documentación
  técnica, agentes IA, decisiones de arquitectura, testing y buenas prácticas de
  delivery**.
- Se desarrolla sobre una **Developer Org** con Salesforce B2B Commerce y
  Site/storefront activo.
- El alcance necesita estar **claramente limitado** para evitar scope creep.

Sin una frontera clara de MVP, el proyecto puede crecer demasiado hacia **pagos
reales, ERP real, OMS avanzado, marketplace, multi-currency o customizaciones
prematuras**, desviando el foco de aprendizaje y comprometiendo la mantenibilidad.

---

## Decisión

El proyecto adopta un **MVP controlado** centrado en Salesforce B2B Commerce
estándar, configuración, Experience Builder, datos Commerce y storefront funcional.

El MVP debe priorizar:

- Catálogo B2B.
- Categorías.
- Productos.
- Búsqueda.
- PLP.
- PDP.
- Buyer access.
- Login B2B.
- Product visibility.
- Buyer Groups.
- Pricing por cuenta o segmento.
- Cart.
- Checkout básico.
- Order history.
- Order detail.
- Reorder.
- Approval por importe.
- Credit validation funcional.
- Stock insufficient scenario funcional.
- Quote request.
- Datos Commerce reproducibles.
- Testing funcional, seguridad y regresión.
- Integración REST simulada futura, **no** integración real.

Cualquier solicitud fuera de este alcance debe tratarse como `Future / Out of MVP`
salvo decisión explícita documentada (actualizar este ADR o crear uno nuevo).

---

## Alternativas Consideradas

### Alternativa 1 - MVP controlado con estándar Salesforce primero

Descripción:

- Mantener el foco en B2B Commerce estándar.
- Configuración y datos antes que código.
- Integraciones simuladas futuras.
- Customización solo con gap real.

Resultado: **alternativa aceptada**.

### Alternativa 2 - Proyecto enterprise completo desde el inicio

Descripción:

- Incluir pagos reales, tax real, shipping real, ERP real, OMS avanzado, marketplace,
  multi-currency y promociones complejas.

Resultado: **rechazada** por ser demasiado amplia para una Developer Org y para el
objetivo de práctica controlada.

### Alternativa 3 - Proyecto puramente técnico basado en Apex/LWC

Descripción:

- Construir componentes y lógica custom desde el inicio, usando B2B Commerce solo como
  base parcial.

Resultado: **rechazada** porque contradice `Configuration first, customization only
when justified`.

### Alternativa 4 - Proyecto solo documental sin storefront funcional

Descripción:

- Documentar arquitectura y agentes sin validar comportamiento real en Salesforce.

Resultado: **rechazada** porque el objetivo incluye storefront funcional y MVP
técnico.

---

## Consecuencias

### Positivas

- Alcance claro.
- Menos riesgo de scope creep.
- Mejor foco de aprendizaje.
- Mejor alineación entre documentación, agentes y desarrollo.
- Menos sobre-ingeniería.
- Menos sobre-documentación.
- Mayor trazabilidad.
- Mejor validación del estándar Salesforce B2B Commerce.
- Mejor base para portfolio técnico.
- Mejor base para entrevistas técnicas.

### Negativas / Trade-offs

- Algunas capacidades enterprise quedan fuera inicialmente.
- No se validan pagos reales.
- No se valida ERP real.
- No se valida shipping/tax real.
- Algunas integraciones serán simuladas.
- Algunas decisiones deberán marcarse como futuras.
- El proyecto puede parecer menos completo que una implementación productiva real.
- Algunas capacidades dependerán de validación en la Developer Org.

---

## Impacto en el Proyecto

### MVP

Este ADR define la **frontera principal del MVP** y es su fuente de verdad de alcance.

### Salesforce B2B Commerce

B2B Commerce estándar debe ser la **primera opción** para catálogo, pricing,
visibility, cart, checkout, order history y reorder.

### Seguridad

Buyer account isolation, product visibility, pricing visibility y order access son
**obligatorios** dentro del MVP.

### Pricing / Visibility

Pricing y visibility forman parte **central** del MVP, usando una estrategia
estándar/configurable primero.

### Checkout

El checkout básico entra en el MVP, incluyendo escenarios funcionales de **approval,
crédito y stock**, pero **no** pagos reales, tax real ni shipping real.

### Datos / Metadata

El MVP requiere **distinguir** metadata/configuración de datos Commerce (no mezclar el
deploy de metadata con la carga de registros).

### Integración

ERP real queda **fuera** del MVP. Solo se contempla **integración REST simulada
futura**.

### Testing

El MVP requiere **functional testing, security testing y regression testing** sobre
los flujos críticos.

### Documentación

La documentación debe **servir al MVP**, no crecer sin una decisión real.

---

## Alcance Incluido en el MVP

### Storefront y Acceso

- Site/storefront activo.
- Login B2B.
- Buyer access.
- Home.
- Navegación.
- Mi cuenta (si aplica).

### Catálogo

- Product Catalog.
- Categorías.
- Productos.
- PLP.
- PDP.
- Search.
- Bundles empresariales (si se modelan con capacidades disponibles).

### Pricing y Visibility

- Pricing por cuenta o Buyer Group.
- Product visibility.
- Catálogo restringido.
- Validación de pricing visible.
- Validación de producto restringido.

### Cart y Checkout

- Add to cart.
- Update quantity.
- Remove product.
- Checkout básico.
- Confirmed vs pending.
- Approval por importe.
- Credit validation funcional.
- Stock insufficient scenario funcional.

### Orders y Reorder

- Order history.
- Order detail.
- Reorder.
- Revalidación funcional de pricing, visibility y stock.

### UX

- Mobile-first.
- Estados empty/error/loading/pending/restricted.
- Mensajes funcionales y seguros para el buyer.

### Calidad

- Functional test cases.
- Security test cases.
- Regression checklist.
- QA sign-off conceptual.

### Agentes IA

- Orchestrator Agent.
- Business Analyst Agent.
- B2B Commerce Specialist Agent.
- Salesforce Architect Agent.
- UX Specialist Agent.
- Salesforce Developer Agent.
- QA Specialist Agent.
- Documentation Agent.
- Evals para validar el comportamiento de los agentes.

---

## Fuera del MVP

- Pagos reales.
- Tax real.
- Shipping real.
- ERP real.
- OMS avanzado.
- Marketplace.
- Promociones complejas.
- Multi-idioma.
- Multi-moneda.
- Integración productiva real.
- Motor custom de pricing.
- Framework de logging complejo.
- Automatización CI/CD enterprise.
- Observabilidad avanzada.
- Arquitectura de microservicios.
- Personalización LWC extensa sin gap.
- Apex como primera opción.
- Documentación excesiva sin uso práctico.

---

## Reglas para Controlar Scope Creep

- Toda solicitud nueva debe **compararse contra este ADR**.
- Si está **dentro** del MVP, se puede analizar con el agente correspondiente.
- Si está **fuera** del MVP, debe marcarse como `Future / Out of MVP`.
- Si el usuario decide incluir algo fuera del MVP, debe **actualizarse este ADR o
  crear un ADR nuevo**.
- Si una solicitud requiere customización relevante, debe revisarse con el **Salesforce
  Architect Agent**.
- Si una solicitud requiere documentación nueva, debe revisarse con el **Documentation
  Agent**.
- Si una solicitud afecta checkout, pricing, visibility o seguridad, debe revisarse
  como **decisión crítica**.
- Si una solicitud depende de la org real, debe marcarse como **"pendiente de
  validación en org"**.

---

## Agentes Relevantes

- `orchestrator-agent.md`: clasifica solicitudes y **protege el alcance**.
- `business-analyst-agent.md`: refina reglas y criterios de aceptación.
- `b2b-commerce-specialist-agent.md`: valida las capacidades estándar de B2B Commerce.
- `salesforce-architect-agent.md`: valida las decisiones arquitectónicas.
- `ux-specialist-agent.md`: valida la experiencia del storefront.
- `salesforce-developer-agent.md`: interviene **solo si hay gap técnico**.
- `qa-specialist-agent.md`: valida pruebas y regresión.
- `documentation-agent.md`: evita duplicidad y sobre-documentación.

---

## Documentos Relacionados

- `PROJECT_CONTEXT.md`
- `CLAUDE.md`
- `docs/DOCUMENTATION_INDEX.md`
- `docs/business/mvp-scope.md`
- `docs/business/ecommerce-strategy.md`
- `docs/business/b2b-commerce-flows.md`
- `docs/business/business-rules.md`
- `docs/architecture/standard-vs-custom-framework.md`
- `docs/architecture/solution-architecture.md`
- `docs/architecture/limitations-and-assumptions.md`
- `docs/salesforce/b2b-commerce-standard-capabilities.md`
- `docs/testing/test-strategy.md`
- `docs/testing/regression-checklist.md`
- `adr/README.md`

---

## Validaciones Pendientes

- Validar las capacidades reales disponibles en la Developer Org.
- Validar el comportamiento estándar de B2B Commerce para reorder.
- Validar la configuración real de Buyer Groups.
- Validar el pricing por cuenta o segmento.
- Validar el product visibility.
- Validar el checkout básico.
- Validar el order history y el order detail.
- Validar qué configuraciones son metadata, data o configuración manual.
- Validar la integración REST simulada cuando llegue esa fase.

---

## ADRs Relacionados

- `adr/README.md`
- `adr/0002-standard-first-b2b-commerce-approach.md` (ADR futuro relacionado).
- `adr/0003-commerce-data-vs-metadata-strategy.md` (ADR futuro relacionado).
- `adr/0004-pricing-and-visibility-strategy.md` (ADR futuro relacionado).
- `adr/0005-checkout-approval-credit-and-stock-strategy.md` (ADR futuro relacionado).
- `adr/0006-future-rest-mock-integration-strategy.md` (ADR futuro relacionado).

---

## Notas Finales

Este ADR debe considerarse la **fuente de verdad para el alcance inicial del MVP**. Si
una solicitud contradice este ADR, debe tratarse como un **cambio de alcance** y no
como una tarea normal.
