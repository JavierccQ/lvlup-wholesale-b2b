# ADR-0004 - Pricing and Visibility Strategy

## Estado

Accepted

## Fecha

2026-06-16

## Contexto

- En un storefront B2B, pricing y visibility son componentes **centrales** de la
  experiencia y de la **seguridad comercial**.
- Diferentes buyers pueden pertenecer a distintos **segmentos** o Buyer Groups.
- Cada buyer debe ver únicamente los **productos autorizados** y el **precio
  correspondiente** a su contexto.
- El catálogo de `LvlUp WholeSale` incluye tecnología y gaming, con posibles
  diferencias entre tiendas pequeñas, revendedores, empresas grandes y compradores
  recurrentes.
- El MVP incluye pricing por cuenta o segmento, catálogo restringido y producto
  visible/no visible según buyer context.
- Pricing y visibility deben mantenerse **consistentes** en PLP, PDP, cart, checkout,
  order history y reorder.
- Resolver pricing o visibility con custom code antes de validar el estándar puede
  generar inconsistencias, riesgos de seguridad y deuda técnica.
- Este ADR formaliza la estrategia para pricing y visibility en el MVP, sobre la base
  del alcance (`0001`), el enfoque standard-first (`0002`) y la estrategia de
  data/metadata (`0003`).

---

## Decisión

El proyecto gestionará pricing y product visibility siguiendo un enfoque
**standard-first**.

La estrategia será:

1. Usar **capacidades estándar** de Salesforce B2B Commerce cuando estén disponibles.
2. Modelar segmentos mediante **Buyer Groups** o mecanismo estándar equivalente
   validado en la org.
3. Usar **Price Books** y **Price Book Entries** para representar pricing.
4. Usar **Product Catalog, Categories** y configuración estándar para organizar
   productos.
5. Usar configuración estándar de **visibility/entitlements** si está disponible y
   validada.
6. Validar pricing y visibility en **PLP, PDP, cart, checkout y reorder**.
7. Tratar los problemas de pricing/visibility **primero como posibles issues de
   datos/configuración**.
8. Evitar custom pricing, Apex, LWC o Flow hasta validar un **gap real**.
9. Escalar cualquier customización de pricing/visibility al **Salesforce Architect
   Agent**.
10. Requerir functional testing, security testing y regression testing para cualquier
    cambio en pricing/visibility.

El **custom pricing engine** queda **fuera del MVP**.

Ocultar productos o precios **solo desde UI/CSS/LWC** está **prohibido** como
estrategia de seguridad.

---

## Alternativas Consideradas

### Alternativa 1 - Pricing y visibility estándar con Buyer Groups, Price Books y datos Commerce

Descripción:

- Usar configuración y datos estándar de B2B Commerce.
- Separar buyers por segmentos.
- Configurar pricing y visibility mediante capacidades estándar.
- Validar el comportamiento en el storefront.

Resultado: **alternativa aceptada**.

### Alternativa 2 - Custom pricing engine desde el inicio

Descripción:

- Crear lógica Apex o integración externa para calcular precios personalizados.

Resultado: **rechazada** porque está fuera del MVP, aumenta la complejidad, genera más
testing y puede duplicar capacidades estándar.

### Alternativa 3 - Ocultar productos/precios desde LWC o CSS

Descripción:

- Mostrar todos los datos al cliente y ocultarlos visualmente según condiciones de UI.

Resultado: **rechazada** por riesgo de seguridad. Visibility y pricing **no** deben
depender solo del front.

### Alternativa 4 - Un único precio y catálogo para todos los buyers

Descripción:

- Simplificar el MVP con un solo catálogo y un solo precio para todos.

Resultado: **rechazada parcialmente** porque el objetivo B2B del proyecto incluye
practicar pricing/visibility por buyer context. Puede usarse como **escenario base**,
pero no como estrategia completa del MVP.

### Alternativa 5 - Pricing y visibility mediante ERP real

Descripción:

- Consultar precios y visibilidad en un ERP real.

Resultado: **rechazada** porque el ERP real está fuera del MVP. La integración REST
simulada queda como **futura** y no reemplaza la estrategia estándar inicial.

---

## Consecuencias

### Positivas

- Mejor alineación con B2B Commerce estándar.
- Menor customización prematura.
- Mejor seguridad comercial.
- Mejor consistencia entre PLP, PDP, cart, checkout y reorder.
- Mejor trazabilidad de datos Commerce.
- Mejor testing funcional y de seguridad.
- Mejor control del MVP.
- Menor riesgo de exponer pricing indebido.
- Menor riesgo de mostrar productos restringidos.
- Mejor base para futuras integraciones simuladas.

### Negativas / Trade-offs

- Requiere configurar correctamente Buyer Groups, Price Books y visibility.
- Requiere datos Commerce consistentes.
- Requiere más validación en la Developer Org.
- Algunas capacidades estándar pueden tener limitaciones.
- Puede ser necesario aceptar restricciones del estándar en el MVP.
- El custom pricing queda aplazado salvo gap validado.
- QA debe preparar escenarios de buyers y segmentos diferentes.

---

## Impacto en el Proyecto

### MVP

Pricing y visibility forman parte **central** del MVP y deben validarse con escenarios
reales de buyers.

### Salesforce B2B Commerce

El proyecto prioriza las **capacidades estándar** de B2B Commerce para pricing y
visibility.

### Seguridad

Pricing visibility y product visibility son **controles de seguridad/comercial**, no
solo decisiones visuales.

### Pricing / Visibility

Este ADR es la **fuente de verdad principal** para esta área.

### Checkout

El checkout debe **revalidar o reflejar** el pricing y la visibility actuales. Un
producto no autorizado o sin precio válido **no** debe confirmarse sin control.

### Datos / Metadata

Pricing y visibility dependen fuertemente de **datos Commerce**: Buyer Groups, Price
Books, Price Book Entries, Products, Catalogs y visibility configuration.

### Integración

La integración externa para pricing/visibility queda **fuera del MVP**. Cualquier
integración futura debe documentarse en un ADR específico.

### Testing

Todo cambio de pricing/visibility requiere functional testing, security testing y
regression testing.

### Documentación

`pricing-and-visibility-strategy.md`, `configuration-decisions.md`,
`data-loading-strategy.md` y los test docs deben mantenerse alineados con este ADR.

---

## Estrategia de Segmentación

Segmentación conceptual del MVP. Posibles segmentos/buyer personas:

- Tienda pequeña de gaming.
- Revendedor de tecnología.
- Empresa grande / enterprise buyer.
- Comprador recurrente.
- Buyer con catálogo restringido.
- Buyer con pricing personalizado.

Cada segmento debe poder **mapearse**, si la org lo permite, a **Buyer Groups** o a un
mecanismo estándar equivalente.

Si los Buyer Groups **no** cubren un caso específico, debe marcarse como **`pendiente
de validación en org`** y escalarse antes de customizar.

---

## Estrategia de Pricing

- Pricing debe resolverse primero con **Price Books** y **Price Book Entries**.
- El precio visible debe ser **consistente** en PLP, PDP, cart y checkout.
- Si existe diferencia por segmento, debe estar **respaldada por
  configuración/datos**.
- Si un producto **no tiene precio válido** para un buyer, debe tratarse como un
  escenario funcional a validar.
- **No** se debe inventar precio en UI.
- **No** se debe calcular pricing custom en LWC.
- **No** se debe crear Apex pricing sin ADR y gap validado.
- Reorder debe **revalidar el pricing actual**, no asumir el pricing histórico como
  definitivo.

---

## Estrategia de Product Visibility

- Product visibility debe resolverse mediante capacidades
  **estándar/configuración/datos**.
- Un producto restringido **no** debe aparecer en PLP.
- Un producto restringido **no** debe aparecer en search.
- Un producto restringido **no** debe ser accesible por **URL directa** sin control.
- Un producto restringido **no** debe agregarse al cart.
- Un producto restringido **no** debe confirmarse en checkout.
- Reorder debe **revalidar la visibility actual**.
- Los restricted states deben mostrar **mensajes seguros** y no revelar reglas
  internas.

---

## Reglas de Seguridad

- **No** enviar al front pricing no autorizado.
- **No** enviar al front productos no autorizados como mecanismo normal.
- **No** ocultar productos/precios solo con CSS.
- **No** confiar en LWC como única capa de seguridad.
- **No** revelar el Buyer Group interno en mensajes para el buyer.
- **No** revelar pricing de otro segmento.
- **No** permitir checkout con producto no autorizado.
- **No** permitir reorder de un producto que ya no es visible sin revalidación.
- Probar **URL directa** a PDP restringido.
- Probar cart y checkout con datos restringidos.

---

## Consistencia por Flujo

### PLP

- Productos visibles correctos.
- Precio correcto.
- Producto restringido no visible.
- Producto sin precio manejado.

### PDP

- Precio correcto.
- Acceso permitido.
- URL directa restringida controlada.
- Mensaje seguro si no está disponible.

### Cart

- Producto autorizado.
- Precio vigente.
- Cantidad.
- Producto restringido removido/bloqueado.
- Mensaje funcional.

### Checkout

- Pricing final.
- Producto autorizado.
- Producto con precio válido.
- Producto restringido bloqueado.
- Pedido **no** confirmado si hay inconsistencia crítica.

### Order History

- Buyer ve solo sus pedidos.
- Pricing mostrado de forma coherente.
- No exposición de otra cuenta.

### Reorder

- Pricing actual.
- Visibility actual.
- Producto no disponible.
- Producto restringido.
- Reorder parcial si aplica.
- Mensaje claro.

---

## Diagnóstico Antes de Customizar Pricing o Visibility

Antes de proponer Apex, LWC, Flow o integración para pricing/visibility, validar:

- [ ] ¿El buyer account es correcto?
- [ ] ¿El buyer user es correcto?
- [ ] ¿El Buyer Group es correcto?
- [ ] ¿El Product Catalog es correcto?
- [ ] ¿La Category es correcta?
- [ ] ¿El Product está activo/disponible?
- [ ] ¿Existe Price Book?
- [ ] ¿Existe Price Book Entry?
- [ ] ¿La visibility está configurada?
- [ ] ¿El producto aparece correctamente para otro buyer?
- [ ] ¿El problema ocurre en PLP, PDP, cart y checkout o solo en una pantalla?
- [ ] ¿La org tiene la capacidad estándar requerida?
- [ ] ¿Está registrado en `org-validation-checklist.md`?

---

## Criterios para Permitir Customización

Una customización de pricing/visibility solo puede considerarse si:

- El estándar fue validado.
- Configuración y datos fueron revisados.
- El gap está documentado.
- El impacto en seguridad fue evaluado.
- El impacto en PLP/PDP/cart/checkout/reorder fue evaluado.
- QA definió pruebas funcionales, de seguridad y regresión.
- El `Salesforce Architect Agent` validó la decisión.
- El `Documentation Agent` validó si requiere ADR nuevo o actualización de este ADR.
- El cambio **no contradice** el MVP.

---

## Criterios para Rechazar Customización

Debe rechazarse si:

- Se propone por comodidad.
- Se propone para compensar datos incompletos.
- Se propone para ocultar datos en UI.
- Se propone sin validar Price Books/Buyer Groups.
- Se propone sin testing.
- Se propone como motor custom de pricing dentro del MVP.
- Se propone integración real con ERP para pricing dentro del MVP.
- Se propone sin revisar el impacto en checkout y reorder.

---

## Agentes Relevantes

- `orchestrator-agent.md`: debe detectar riesgos de pricing/visibility y **enrutar
  correctamente**.
- `business-analyst-agent.md`: debe definir las reglas funcionales y los segmentos.
- `b2b-commerce-specialist-agent.md`: debe validar estándar, configuración y datos
  Commerce.
- `salesforce-architect-agent.md`: debe validar los riesgos y cualquier customización.
- `ux-specialist-agent.md`: debe revisar mensajes, restricted states y mobile.
- `salesforce-developer-agent.md`: solo interviene con **gap técnico validado**.
- `qa-specialist-agent.md`: debe definir pruebas de pricing, visibility, seguridad y
  regresión.
- `documentation-agent.md`: debe mantener la documentación alineada.

---

## Documentos Relacionados

- `PROJECT_CONTEXT.md`
- `CLAUDE.md`
- `docs/DOCUMENTATION_INDEX.md`
- `adr/README.md`
- `adr/0001-project-scope-and-mvp-boundaries.md`
- `adr/0002-standard-first-b2b-commerce-approach.md`
- `adr/0003-commerce-data-vs-metadata-strategy.md`
- `docs/business/buyer-personas.md`
- `docs/business/business-rules.md`
- `docs/business/product-catalog-strategy.md`
- `docs/business/pricing-and-visibility-strategy.md`
- `docs/ux/plp-pdp-guidelines.md`
- `docs/ux/cart-checkout-experience.md`
- `docs/architecture/standard-vs-custom-framework.md`
- `docs/architecture/security-architecture.md`
- `docs/salesforce/b2b-commerce-standard-capabilities.md`
- `docs/salesforce/data-model.md`
- `docs/salesforce/security-model.md`
- `docs/salesforce/configuration-decisions.md`
- `docs/salesforce/data-loading-strategy.md`
- `docs/salesforce/org-validation-checklist.md`
- `docs/testing/functional-test-cases.md`
- `docs/testing/security-test-cases.md`
- `docs/testing/regression-checklist.md`

---

## Validaciones Pendientes

- Validar los Buyer Groups reales en la Developer Org.
- Validar la estrategia real de Price Books.
- Validar los Price Book Entries por segmento.
- Validar el Product Catalog y la category visibility.
- Validar el product visibility estándar.
- Validar el comportamiento de productos restringidos en PLP.
- Validar el comportamiento de productos restringidos en search.
- Validar el comportamiento de URL directa a PDP restringido.
- Validar el comportamiento de productos restringidos en cart.
- Validar el comportamiento de productos restringidos en checkout.
- Validar el pricing en PLP, PDP, cart y checkout.
- Validar reorder con pricing actualizado.
- Validar reorder con producto restringido o no disponible.

---

## ADRs Relacionados

- `adr/README.md`
- `adr/0001-project-scope-and-mvp-boundaries.md`
- `adr/0002-standard-first-b2b-commerce-approach.md`
- `adr/0003-commerce-data-vs-metadata-strategy.md`
- `adr/0005-checkout-approval-credit-and-stock-strategy.md` (ADR futuro relacionado).
- `adr/0006-future-rest-mock-integration-strategy.md` (ADR futuro relacionado).

---

## Notas Finales

Este ADR debe considerarse la **fuente de verdad para pricing y visibility en el MVP**.
Cualquier propuesta de custom pricing, custom visibility, LWC para ocultar información
o Apex para calcular precios debe **justificarse contra este ADR** antes de avanzar.
