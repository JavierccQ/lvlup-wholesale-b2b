# ADR-0003 - Commerce Data vs Metadata Strategy

## Estado

Accepted

## Fecha

2026-06-16

## Contexto

- En Salesforce B2B Commerce, el storefront funcional depende de una **combinación de
  metadata, configuración y datos**.
- No basta con tener componentes o configuración desplegada si **faltan datos
  Commerce**.
- Catálogo, categorías, productos, precios, Buyer Groups y visibility son esenciales
  para que PLP, PDP, cart, checkout y reorder funcionen correctamente.
- Muchos problemas **aparentan ser técnicos**, pero pueden deberse a *data/configuration
  issues*.
- En una Developer Org, parte de la configuración puede requerir **validación manual**
  o carga de datos.
- El proyecto necesita una **estrategia clara** para separar qué se documenta, qué se
  configura, qué se carga como datos y qué se despliega como metadata.
- Esta separación es necesaria para evitar customización innecesaria, errores de
  testing y decisiones equivocadas de deployment.

---

## Decisión

El proyecto adopta una estrategia **explícita de separación** entre:

1. **Metadata Salesforce.**
2. **Configuración Salesforce/B2B Commerce.**
3. **Datos Commerce.**
4. **Datos funcionales de testing.**
5. **Validaciones manuales en org.**

En consecuencia:

- **No** se debe asumir que todo comportamiento Commerce puede resolverse con metadata.
- **No** se debe asumir que un problema del storefront requiere código hasta revisar
  datos y configuración.
- Los **datos Commerce son parte esencial del MVP**.
- **No** se deben hardcodear IDs de registros.
- Toda **dependencia de datos** debe documentarse.
- Toda validación pendiente en la Developer Org debe marcarse como **`pendiente de
  validación en org`**.
- Los documentos `data-model.md`, `data-loading-strategy.md`,
  `configuration-decisions.md` y `org-validation-checklist.md` deben mantenerse
  **alineados** con esta decisión.

---

## Alternativas Consideradas

### Alternativa 1 - Separar metadata, configuración y datos Commerce

Descripción:

- Diferenciar claramente qué se despliega, qué se configura y qué se carga como datos.
- Documentar dependencias de datos.
- Evitar hardcoded IDs.
- Validar la org antes de asumir comportamiento.
- Tratar los datos Commerce como parte del MVP.

Resultado: **alternativa aceptada**.

### Alternativa 2 - Tratar todo como metadata deployable

Descripción:

- Asumir que toda configuración y comportamiento Commerce se puede versionar y
  desplegar como metadata.

Resultado: **rechazada** porque Salesforce B2B Commerce depende fuertemente de datos y
configuración que pueden no ser completamente metadata deployable o requerir validación
manual.

### Alternativa 3 - Configurar todo manualmente sin estrategia de datos

Descripción:

- Crear catálogo, productos, Buyer Groups y pricing manualmente en la org sin una
  estrategia reproducible.

Resultado: **rechazada** porque reduce la trazabilidad, dificulta el testing, genera
dependencia de datos accidentales y complica la reconstrucción del MVP.

### Alternativa 4 - Resolver faltantes de datos con Apex/LWC

Descripción:

- Crear código custom para compensar datos incompletos o configuración faltante.

Resultado: **rechazada** porque contradice el enfoque standard-first y aumenta la
complejidad innecesaria.

---

## Consecuencias

### Positivas

- Mejor claridad entre configuración, datos y código.
- Menos riesgo de customización prematura.
- Mejor diagnóstico de errores del storefront.
- Mejor reproducibilidad del MVP.
- Mejor testing funcional y de seguridad.
- Mejor trazabilidad de Buyer Groups, pricing y visibility.
- Menos hardcoded IDs.
- Mejor preparación para el deployment.
- Mejor alineación con Salesforce B2B Commerce real.
- Mejor disciplina para los agentes IA.

### Negativas / Trade-offs

- Requiere mantener documentación de datos.
- Requiere validar qué es metadata, data o configuración manual.
- Puede requerir carga manual o semi-manual de datos en fases iniciales.
- Algunos comportamientos dependerán de datos correctos antes de poder probarse.
- La Developer Org puede tener limitaciones o diferencias respecto a una org
  productiva.
- QA debe preparar datos mínimos antes de validar flujos.

---

## Impacto en el Proyecto

### MVP

El MVP debe incluir no solo documentación y metadata, sino también **datos Commerce
mínimos** para validar storefront, catálogo, pricing, visibility, cart, checkout y
reorder.

### Salesforce B2B Commerce

B2B Commerce requiere **datos y configuración coherentes** para funcionar
correctamente.

### Seguridad

Buyer account isolation, product visibility, pricing visibility y order access
dependen de **configuración y datos correctos**, no solo de UI.

### Pricing / Visibility

Pricing y visibility dependen de **Buyer Groups, Price Books, Price Book Entries,
Product Catalog** y la configuración relacionada.

### Checkout

El checkout puede fallar o comportarse incorrectamente si faltan productos, precios,
visibility, buyer access o datos funcionales.

### Datos / Metadata

Este ADR es la **fuente de verdad** para separar metadata, configuración y datos
Commerce.

### Integración

La integración REST simulada futura deberá **respetar esta separación** y no reemplazar
los datos Commerce internos salvo decisión explícita.

### Testing

QA debe validar los **datos mínimos** antes de ejecutar pruebas funcionales, de
seguridad o de regresión.

### Documentación

`data-model.md`, `data-loading-strategy.md`, `configuration-decisions.md` y
`org-validation-checklist.md` deben reflejar esta estrategia.

---

## Clasificación de Elementos del Proyecto

| Elemento | Tipo principal | Ejemplos | Consideraciones |
| --- | --- | --- | --- |
| Metadata Salesforce | Metadata deployable | Apex classes, LWC components, Flows, Permission Sets, Custom Metadata, Experience metadata (si aplica y se valida) | Versionable; revisar `deployment-guidelines.md`; puede requerir datos relacionados |
| Configuración Salesforce/B2B Commerce | Configuración (metadata, manual o mixta) | Storefront settings, Experience Builder layout/configuration, Commerce setup, checkout settings (si aplican), feature enablement, buyer access configuration | Validar si es metadata, manual o mixta; registrar en `configuration-decisions.md`; validar en org |
| Datos Commerce | Data (registros) | Accounts, Buyer Users, Buyer Groups, Products, Product Catalog, Categories, Price Books, Price Book Entries, visibility/entitlements, orders de prueba (si aplican) | Requieren estrategia de carga; **no hardcoded IDs**; deben ser reproducibles; deben soportar testing |
| Datos Funcionales de Testing | Data (registros) | Buyer con catálogo completo, buyer con catálogo restringido, buyer enterprise, buyer reseller, producto con precio, producto sin precio, producto restringido, producto con stock insuficiente funcional, cliente con crédito bloqueado funcional | Deben cubrir happy path y negative scenarios; deben alinearse con QA; no depender de datos accidentales |
| Validaciones Manuales en Org | Validación manual | Confirmar capacidades estándar disponibles, comportamiento de Experience Builder, comportamiento de reorder, configuración de checkout, disponibilidad de componentes estándar | Marcar como **pendiente** hasta validarse; registrar en `org-validation-checklist.md` |

---

## Reglas de Datos Commerce

- **No** hardcodear IDs.
- Usar nombres/identificadores funcionales claros cuando aplique.
- Documentar las dependencias entre objetos.
- Cargar primero los datos base y luego los dependientes.
- **No** probar flujos críticos sin datos mínimos.
- **No** asumir que un buyer tiene acceso correcto sin validar Buyer Group/visibility.
- **No** asumir pricing correcto sin validar Price Book/Price Book Entry.
- **No** asumir visibility correcta solo porque el producto existe.
- **No** asumir checkout válido solo porque el cart funciona.
- **No** asumir reorder válido sin revalidar pricing, visibility y stock funcional.
- Mantener los datos alineados con `data-loading-strategy.md`.

---

## Dependencias de Datos por Flujo

### Login y Buyer Access

- Account.
- Buyer User.
- Buyer access.
- Permission/access configuration.
- Buyer Group (si aplica).

### Catálogo / PLP / PDP

- Product Catalog.
- Categories.
- Products.
- Product-category associations.
- Visibility.
- Pricing.
- Buyer context.

### Pricing

- Price Book.
- Price Book Entry.
- Buyer Group / segment.
- Account relationship (si aplica).
- Pricing strategy.

### Visibility

- Buyer Group.
- Product visibility.
- Catalog access.
- Entitlements (si aplican).
- Storefront context.

### Cart

- Buyer user.
- Product.
- Pricing.
- Visibility.
- Quantity.
- Cart configuration.

### Checkout

- Cart válido.
- Pricing válido.
- Visibility válida.
- Buyer account.
- Approval threshold funcional.
- Credit status funcional.
- Stock status funcional.

### Orders y Reorder

- Orders de prueba.
- Order items.
- Buyer account.
- Product current state.
- Pricing current state.
- Visibility current state.
- Stock functional state.

---

## Diagnóstico Antes de Customizar

Antes de proponer Apex, LWC, Flow o integración, validar:

- [ ] ¿Existe el Product?
- [ ] ¿Está en el Product Catalog correcto?
- [ ] ¿Está asociado a la Category correcta?
- [ ] ¿El buyer tiene el Buyer Group correcto?
- [ ] ¿El producto tiene Price Book Entry?
- [ ] ¿El producto es visible para ese buyer?
- [ ] ¿El storefront está usando el contexto correcto?
- [ ] ¿La configuración Commerce está activa?
- [ ] ¿La capacidad estándar fue validada en org?
- [ ] ¿El error se reproduce con datos correctos?
- [ ] ¿El problema está documentado en `org-validation-checklist.md`?

---

## Reglas de Deployment y Data Loading

- Metadata y datos deben tratarse como **responsabilidades diferentes**.
- Un deployment exitoso **no garantiza** un storefront funcional si faltan datos.
- La carga de datos debe tener un **orden lógico**.
- Los datos dependientes **no** deben cargarse antes que sus padres.
- La estrategia de datos debe ser **idempotente** cuando sea posible.
- **No** deben usarse IDs hardcodeados.
- Los datos de prueba deben poder **reconstruirse**.
- La *post-deployment validation* debe incluir **datos y comportamiento**, no solo
  metadata.

---

## Agentes Relevantes

- `orchestrator-agent.md`: debe detectar si una solicitud es de **datos, configuración
  o desarrollo**.
- `b2b-commerce-specialist-agent.md`: debe validar estándar, configuración y datos
  Commerce.
- `salesforce-architect-agent.md`: debe validar la estrategia de datos vs metadata.
- `salesforce-developer-agent.md`: debe **evitar código** para resolver datos
  faltantes.
- `qa-specialist-agent.md`: debe exigir datos de prueba reproducibles.
- `documentation-agent.md`: debe mantener alineados los documentos de datos,
  configuración y el índice.

---

## Documentos Relacionados

- `PROJECT_CONTEXT.md`
- `CLAUDE.md`
- `docs/DOCUMENTATION_INDEX.md`
- `adr/README.md`
- `adr/0001-project-scope-and-mvp-boundaries.md`
- `adr/0002-standard-first-b2b-commerce-approach.md`
- `docs/business/product-catalog-strategy.md`
- `docs/business/pricing-and-visibility-strategy.md`
- `docs/architecture/standard-vs-custom-framework.md`
- `docs/architecture/solution-architecture.md`
- `docs/architecture/limitations-and-assumptions.md`
- `docs/salesforce/b2b-commerce-standard-capabilities.md`
- `docs/salesforce/data-model.md`
- `docs/salesforce/configuration-decisions.md`
- `docs/salesforce/data-loading-strategy.md`
- `docs/salesforce/org-validation-checklist.md`
- `docs/development/deployment-guidelines.md`
- `docs/testing/test-strategy.md`
- `docs/testing/functional-test-cases.md`
- `docs/testing/security-test-cases.md`
- `docs/testing/regression-checklist.md`

---

## Validaciones Pendientes

- Validar qué elementos B2B Commerce son metadata deployable.
- Validar qué configuraciones requieren intervención manual.
- Validar la estructura real de Product Catalog y Categories en la org.
- Validar la configuración real de Buyer Groups.
- Validar la estrategia real de Price Books y Price Book Entries.
- Validar el product visibility en la org.
- Validar los datos mínimos necesarios para cart y checkout.
- Validar los datos necesarios para order history y reorder.
- Validar cómo reconstruir datos de prueba de forma reproducible.
- Validar si se requiere una herramienta específica de data loading más adelante.

---

## ADRs Relacionados

- `adr/README.md`
- `adr/0001-project-scope-and-mvp-boundaries.md`
- `adr/0002-standard-first-b2b-commerce-approach.md`
- `adr/0004-pricing-and-visibility-strategy.md` (ADR futuro relacionado).
- `adr/0005-checkout-approval-credit-and-stock-strategy.md` (ADR futuro relacionado).
- `adr/0006-future-rest-mock-integration-strategy.md` (ADR futuro relacionado).

---

## Notas Finales

Este ADR debe considerarse la **fuente de verdad** para distinguir metadata,
configuración y datos Commerce. Antes de proponer desarrollo custom, los agentes deben
validar si el problema se origina en **datos o configuración incompleta**.
