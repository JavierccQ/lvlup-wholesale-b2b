# Capacidades Estándar de Salesforce B2B Commerce - LvlUp WholeSale

## 1. Propósito del Documento

Este documento identifica y organiza las **capacidades estándar de Salesforce B2B
Commerce** relevantes para el proyecto `LvlUp-Wholesale-B2B`, para evaluarlas y
priorizarlas antes de considerar cualquier customización.

Sirve como base para:

- Validar qué ofrece el estándar.
- Evitar la customización prematura.
- Guiar la configuración.
- Identificar gaps funcionales.
- Evaluar cuándo usar Experience Builder, Flow, LWC, Apex o integración.
- Alimentar las decisiones arquitectónicas y los ADRs.
- Guiar a los agentes de IA especializados.

Este documento **no reemplaza la documentación oficial de Salesforce** ni confirma
la configuración disponible **hasta validarla en la org**. Aplica el principio
rector: *Configuration first, customization only when justified*.

> **Nota de honestidad:** a la fecha de este documento **no se ha validado ninguna
> capacidad directamente en la org**. Por ello, las capacidades funcionales se
> marcan como *Pendiente de validación* o *Supuesto*, no como *Validado*.

---

## 2. Principio de Uso del Estándar

> **Configuration first, customization only when justified.**

Para cada necesidad funcional se evalúa en este orden:

1. **Capacidad estándar** de Salesforce B2B Commerce.
2. **Configuración en Experience Builder**.
3. **Configuración de datos**: catálogo, productos, precios, Buyer Groups,
   visibilidad.
4. **Flow** si es mantenible.
5. **LWC** si existe una necesidad UX no cubierta.
6. **Apex** si hay lógica compleja, integración o transaccionalidad.
7. **Integración externa** si el dato/proceso vive fuera de Salesforce.

---

## 3. Mapa de Capacidades Estándar Relevantes

Estados: Validado / Pendiente de validación / Supuesto / Futuro / Fuera del MVP.

| Capacidad | Propósito funcional | Relevancia MVP | Estado de validación | Documento relacionado |
| --- | --- | --- | --- | --- |
| Webstore / Storefront | Tienda B2B y punto de acceso | Alta | Supuesto (Site activo por contexto) | `solution-architecture.md` |
| Experience Cloud | Capa de experiencia del portal | Alta | Supuesto | `solution-architecture.md` |
| Experience Builder | Configuración de páginas y layout | Alta | Pendiente de validación | `ux-principles.md` |
| Product Catalog | Catálogo de productos | Alta | Pendiente de validación | `product-catalog-strategy.md` |
| Product Categories | Categorías del catálogo | Alta | Pendiente de validación | `product-catalog-strategy.md` |
| Product2 | Registros de producto | Alta | Pendiente de validación | `product-catalog-strategy.md` |
| Price Books / pricing | Precios por cuenta/Buyer Group | Alta | Pendiente de validación | `pricing-and-visibility-strategy.md` |
| Buyer Accounts | Cuentas compradoras | Alta | Pendiente de validación | `buyer-personas.md` |
| Buyer Groups | Agrupación para pricing/visibilidad | Alta | Pendiente de validación | `pricing-and-visibility-strategy.md` |
| Entitlements / product visibility | Qué productos ve cada buyer | Alta | Pendiente de validación | `pricing-and-visibility-strategy.md` |
| Search | Búsqueda de productos | Alta | Pendiente de validación | `plp-pdp-guidelines.md` |
| PLP | Listado de productos | Alta | Pendiente de validación | `plp-pdp-guidelines.md` |
| PDP | Detalle de producto | Alta | Pendiente de validación | `plp-pdp-guidelines.md` |
| Cart | Carrito de compra | Alta | Pendiente de validación | `cart-checkout-experience.md` |
| Checkout | Confirmación del pedido | Alta | Pendiente de validación | `cart-checkout-experience.md` |
| Orders / order history | Pedidos e historial | Alta | Pendiente de validación | `b2b-commerce-flows.md` |
| Reorder | Repetir compras anteriores | Alta | Pendiente de validación | `b2b-commerce-flows.md` |
| Permission Sets / Permission Set Groups | Control de acceso | Media | Pendiente de validación | `security-architecture.md` |
| Commerce APIs | Extensiones programáticas | Baja | Futuro | `standard-vs-custom-framework.md` |
| Flows relacionados | Automatización declarativa | Media | Pendiente de validación | `standard-vs-custom-framework.md` |
| Integration setup / Named Credentials | Callouts externos | Baja | Futuro | `integration-architecture.md` |

---

## 4. Webstore / Storefront

- **Propósito funcional.** Es la tienda B2B y el punto de acceso del comprador.
- **Rol en el proyecto.** Núcleo del MVP; aloja Home, catálogo, carrito y checkout.
- **Relación con Experience Cloud.** El storefront se sirve como sitio de
  Experience Cloud (LWR).
- **Relación con el Site activo.** El contexto indica un Site/storefront ya activo;
  su configuración concreta está **pendiente de validación**.
- **Relevancia.** Soporta Home, catálogo, carrito y checkout.
- **A validar en la org.** Configuración del WebStore, asociación de catálogo,
  pricing y Buyer Groups.
- **Riesgos.** Customizar el storefront antes de conocer sus capacidades estándar.
- **Relación con el MVP.** Imprescindible.

---

## 5. Experience Cloud y Experience Builder

- **Rol.** Capa de experiencia del portal.
- **Uso prioritario.** Layout, páginas, navegación y configuración visual.
- **Relación con pantallas.** Home, PLP, PDP, carrito, checkout, historial y Mi
  Cuenta.
- **Qué resolver primero con Builder.** Disposición de componentes estándar,
  navegación y contenido.
- **Cuándo podría ser insuficiente.** Interacción o visualización no disponible en
  los componentes estándar.
- **Cuándo considerar LWC custom.** Solo tras confirmar que Builder no cubre la
  necesidad (ver `standard-vs-custom-framework.md` §5).
- **A validar en la org.** Componentes estándar disponibles por pantalla y su nivel
  de configuración.

---

## 6. Product Catalog y Product Categories

- **Propósito funcional.** Organizar el catálogo y sus categorías.
- **Relación con la estrategia.** Categorías de `product-catalog-strategy.md`
  (consolas, videojuegos, portátiles, monitores, periféricos, networking,
  accesorios, bundles).
- **Relación con PLP/PDP.** Alimentan el listado y el detalle.
- **Relación con la navegación.** Definen las rutas de exploración.
- **Relación con datos/registros.** El catálogo y las categorías son **datos**, no
  metadata.
- **A validar en la org.** Estructura de catálogo, categorías y su asociación al
  WebStore.
- **Riesgos.** Mezclar el deploy de metadata con la carga de registros.

---

## 7. Product2 y Datos de Producto

- **Rol.** Los productos del catálogo.
- **Información funcional esperada.** SKU, nombre, descripción, categoría, imagen o
  placeholder, estado activo y datos útiles para PLP/PDP.
- **Relación con la carga de datos.** Los productos se cargan como registros
  (estrategia de datos pendiente).
- **Relación con el testing.** Base de los datos de prueba del MVP.
- **A validar en la org.** Campos disponibles/necesarios y su uso en el storefront.
- **Nota.** No se define el modelo físico definitivo todavía.

---

## 8. Pricing / Price Books

- **Rol funcional.** Precios negociados en un contexto B2B.
- **Comportamiento esperado.** Pricing por cuenta o Buyer Group (`PR-001`,
  `PR-002`).
- **Consistencia.** El precio debe coincidir en PLP, PDP, carrito y checkout
  (`PR-003`).
- **Relación con Price Books.** Se apoyará en Price Books / capacidades estándar
  disponibles.
- **A validar en la org.** Estructura de Price Books, asignación a Buyer Groups y
  resolución de precio en el storefront.
- **Fuera de alcance.** Promociones complejas, multi-divisa, pricing dinámico
  avanzado y motor externo real de pricing.

No se inventa configuración exacta.

---

## 9. Buyer Accounts y Buyer Groups

- **Rol funcional.** Las cuentas compradoras y su agrupación.
- **MVP.** Cada buyer account tiene **un único usuario operativo** (`BR-ACCESS-005`).
- **Buyer Groups.** Agrupación funcional para catálogo, pricing y visibilidad.
- **Relación con segmentos.** Tienda gaming local, reseller tecnológico, empresa IT
  y cliente enterprise (`pricing-and-visibility-strategy.md`).
- **A validar en la org.** Modelo de Buyer Accounts/Buyer Groups y su efecto en
  catálogo/pricing.
- **Decisiones pendientes.** Buyer Groups definitivos (`DEC-005`).

---

## 10. Entitlements / Product Visibility

- **Propósito funcional.** Controlar qué productos ve cada buyer.
- **Relación con catálogo restringido.** Soporta la visibilidad diferenciada.
- **Relación con Buyer Groups/cuenta.** La visibilidad depende de la cuenta o el
  Buyer Group (`PV-001`, `PV-006`).
- **Consistencia esperada.** PLP, búsqueda, PDP, carrito, checkout y reorder.
- **A validar en la org.** Mecanismo de entitlements y su consistencia en el
  journey.
- **Riesgos de seguridad.** Una mala configuración puede **exponer productos
  restringidos** (`security-architecture.md`).

---

## 11. Search, PLP y PDP

### Search

- **Propósito.** Localizar productos rápidamente.
- **Relación con el catálogo visible.** Solo resultados visibles para la cuenta.
- **Estado sin resultados.** Mensaje claro (empty).
- **Restricciones funcionales.** No mostrar productos no visibles.
- **A validar en la org.** Capacidades y configuración de la búsqueda estándar.

### PLP

- **Propósito.** Comparar y decidir entre productos visibles.
- **Información esperada.** Nombre, imagen, precio aplicable, disponibilidad.
- **Pricing y stock funcional.** Visibles por ítem cuando aplique.
- **Mobile-first.** Cards legibles, precio visible.
- **Relación con componentes estándar.** Listado estándar del storefront.
- **A validar en la org.** Nivel de configuración/customización de la PLP.

### PDP

- **Propósito.** Validar el producto y añadir al carrito.
- **Información esperada.** Nombre, SKU, descripción, precio, disponibilidad,
  cantidad.
- **Agregar al carrito.** Acción primaria.
- **Estados.** Stock, pricing y visibilidad.
- **A validar en la org.** Nivel de configuración/customización de la PDP.

---

## 12. Cart

- **Propósito funcional.** Revisar y ajustar la compra antes del checkout.
- **Relación con productos visibles.** Solo productos visibles y permitidos.
- **Relación con pricing.** Precio consistente con PLP/PDP.
- **Relación con stock funcional.** Reflejar disponibilidad.
- **Relación con reorder.** El reorder genera/actualiza el carrito.
- **Validaciones esperadas.** Visibilidad, pricing y disponibilidad (`BR-CART-005`).
- **A validar en la org.** Capacidades del carrito estándar antes de customizar.

---

## 13. Checkout

- **Propósito funcional.** Confirmar la compra.
- **MVP.** Checkout básico, sin pago/tax/shipping reales.
- **Confirmación vs solicitud pendiente.** Diferenciar pedido confirmado de
  aprobación pendiente (`BR-CHECKOUT-003`).
- **Relación con aprobación por importe.** Puede derivar a aprobación
  (`BR-APPROVAL-*`).
- **Relación con crédito.** Puede impedir o condicionar (`BR-CREDIT-*`).
- **Fuera del MVP.** Pagos, tax y shipping reales.
- **A validar en la org.** Capacidades del checkout estándar.
- **Cuándo considerar Flow/LWC/Apex.** Solo si el estándar no cubre una validación
  o experiencia crítica.

---

## 14. Orders, Historial y Reorder

- **Rol funcional.** Trazabilidad de pedidos.
- **Relación con trazabilidad.** Reduce la dependencia del representante
  (`BR-HISTORY-004`).
- **Reorder.** Capacidad clave para compras recurrentes.
- **Revalidación.** El reorder revalida pricing, visibilidad y stock
  (`BR-REORDER-003`).
- **A validar en la org.** Historial, detalle de pedido y soporte de reorder
  estándar.
- **Posible futuro.** Casos de reorder no cubiertos por el estándar.

---

## 15. Permission Sets / Permission Set Groups

- **Relevancia.** Control de acceso a funcionalidades.
- **Relación con roles.** Compradores, administradores y futuras jerarquías.
- **Mínimo privilegio.** Criterio rector.
- **Sin nombres finales.** No se definen sin validación.
- **A validar en la org.** Permisos necesarios por actor.
- **Relación.** `security-architecture.md` y `docs/salesforce/security-model.md`.

---

## 16. Commerce APIs

- **Relevancia potencial.** Extensiones futuras del storefront.
- **Uso.** Solo si hay una necesidad funcional/técnica justificada.
- **No usar** si el estándar/configuración cubre el caso.
- **Relación.** LWC/Apex/integraciones futuras.
- **Estado.** Futuro / pendiente de validación.

No se diseñan llamadas ni contratos todavía.

---

## 17. Capacidades Fuera del MVP

| Capacidad | Motivo de exclusión | Posible fase futura | Riesgo si se adelanta |
| --- | --- | --- | --- |
| Pagos reales | Fuera del foco del MVP | Futuro posible | Complejidad y cumplimiento |
| Tax real | Complejidad fiscal | Futuro posible | Esfuerzo desviado |
| Shipping real | Complejidad logística | Futuro posible | Esfuerzo desviado |
| OMS avanzado | Historial básico suficiente | Futuro posible | Sobre-ingeniería |
| ERP real | Dependencia externa | Tras simulación | Acoplamiento prematuro |
| Promociones complejas | No aporta a la base B2B | Futuro posible | Complejidad de pricing |
| Multi-idioma | Opera en España | Futuro (expansión) | Esfuerzo desviado |
| Multi-divisa | Un solo mercado | Futuro (expansión) | Complejidad de pricing |
| Marketplace | Modelo distinto | No incluido | Cambio de modelo |
| Motor externo real de pricing | No justificado | Futuro si se justifica | Acoplamiento externo |
| Integración real de facturas | Fuera del MVP | Futuro | Acoplamiento prematuro |

---

## 18. Matriz Necesidad Funcional vs Capacidad Estándar

| Necesidad funcional | Capacidad estándar a evaluar primero | Alternativa si no alcanza | Estado | Documento relacionado |
| --- | --- | --- | --- | --- |
| Login buyer | Autenticación de Experience Cloud | — | Pendiente de validación | `security-architecture.md` |
| Catálogo | Product Catalog | Configuración de datos | Pendiente de validación | `product-catalog-strategy.md` |
| Categorías | Product Categories | Configuración de datos | Pendiente de validación | `product-catalog-strategy.md` |
| PLP | PLP estándar / Experience Builder | LWC | Pendiente de validación | `plp-pdp-guidelines.md` |
| PDP | PDP estándar / Experience Builder | LWC | Pendiente de validación | `plp-pdp-guidelines.md` |
| Pricing personalizado | Price Books + Buyer Groups | Flow / Apex | Pendiente de validación | `pricing-and-visibility-strategy.md` |
| Catálogo restringido | Entitlements / Buyer Groups | Configuración | Pendiente de validación | `pricing-and-visibility-strategy.md` |
| Carrito | Cart estándar | LWC / Flow | Pendiente de validación | `cart-checkout-experience.md` |
| Checkout básico | Checkout estándar | Flow / Apex | Pendiente de validación | `cart-checkout-experience.md` |
| Historial | Orders / order history | LWC | Pendiente de validación | `b2b-commerce-flows.md` |
| Reorder | Reorder estándar | LWC / Apex | Pendiente de validación | `b2b-commerce-flows.md` |
| Aprobación por importe | Estándar / Flow | Apex | Pendiente de validación | `business-rules.md` |
| Validación de crédito | Flow / configuración | Apex + integración simulada | Pendiente de validación | `business-rules.md` |
| Stock insuficiente | Disponibilidad estándar | Integración simulada | Pendiente de validación | `b2b-commerce-flows.md` |
| Quote request | Estándar / Flow | Apex | Futuro / pendiente | `b2b-commerce-flows.md` |
| Estados empty/error/loading | Estándar / Experience Builder | LWC | Pendiente de validación | `empty-error-loading-states.md` |

---

## 19. Gaps Potenciales

Posibles gaps a validar:

- Nivel real de customización de la **PLP**.
- Nivel real de customización de la **PDP**.
- Capacidades reales del **carrito/checkout** estándar.
- Cómo resolver la **aprobación por importe**.
- Cómo **representar el crédito**.
- Cómo **representar el stock funcional** sin ERP real.
- Cómo manejar el **quote request**.
- Cómo soportar el **reorder** si el estándar no cubre todos los casos.
- Cómo **documentar datos vs metadata**.

---

## 20. Criterios para Declarar que el Estándar no Alcanza

Antes de declarar insuficiente el estándar debe existir:

- Una **necesidad funcional clara**.
- **Validación real en la org**.
- **Evidencia de la limitación**.
- **Alternativas evaluadas**.
- **Impacto UX/negocio documentado**.
- **Revisión** contra `standard-vs-custom-framework.md`.
- **ADR** si implica una customización relevante.

---

## 21. Supuestos Actuales

- La org tiene **B2B Commerce y un Site activo**.
- Las **capacidades estándar deben validarse** en la org.
- El MVP puede construirse **incrementalmente**.
- El catálogo, los productos, el pricing y los Buyer Groups **requerirán datos**.
- **Experience Builder** será la primera opción para la UI.
- **Flow, LWC y Apex** solo se evaluarán si el estándar no alcanza.
- Algunas capacidades pueden depender de **licencias/features disponibles**.

---

## 22. Decisiones Pendientes

- Capacidades estándar disponibles realmente.
- Componentes estándar disponibles por pantalla.
- Estructura final del catálogo.
- Buyer Groups definitivos.
- Pricing definitivo.
- Visibilidad definitiva.
- Estrategia de carga de datos.
- Nivel de configuración del checkout.
- Si la aprobación requiere Flow o configuración estándar.
- Si el crédito queda documentado, simulado o automatizado.
- Si el reorder estándar cubre el caso.
- Si algún gap requiere ADR.

---

## 23. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general**.
- `docs/business/` define **negocio, reglas y alcance**.
- `docs/ux/` define la **experiencia esperada**.
- `docs/architecture/standard-vs-custom-framework.md` define el **criterio estándar
  vs custom**.
- `docs/architecture/solution-architecture.md` define la **arquitectura general**.
- Este documento documenta las **capacidades estándar de B2B Commerce** a evaluar.
- `docs/salesforce/data-model.md` deberá profundizar en **entidades y relaciones**.
- `docs/salesforce/security-model.md` deberá profundizar en **seguridad/configuración
  real**.
- `docs/salesforce/configuration-decisions.md` deberá registrar las **decisiones de
  configuración**.
- `adr/` registrará las **decisiones arquitectónicas relevantes**.
- `agents/` deberá usar este documento para **recomendar estándar primero**.
