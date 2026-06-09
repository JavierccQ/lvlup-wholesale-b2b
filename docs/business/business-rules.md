# Reglas de Negocio - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define las **reglas de negocio iniciales** del proyecto
`LvlUp-Wholesale-B2B`. Su objetivo es guiar la configuración, el diseño
funcional, la UX, la arquitectura, el testing y las futuras decisiones técnicas,
ofreciendo un conjunto de reglas identificables y referenciables.

Las reglas se alinean con `docs/business/ecommerce-strategy.md` y
`docs/business/buyer-personas.md`, y aplican el principio rector del proyecto:
*Configuration first, customization only when justified*. Por ello, salvo
indicación contraria, cada regla debe resolverse primero con capacidades
estándar de Salesforce B2B Commerce.

Las reglas pueden **evolucionar** a medida que avance el MVP. Cada regla tiene un
identificador estable (`BR-<CATEGORÍA>-NNN`) y un estado funcional. Las reglas no
confirmadas se marcan explícitamente como supuesto, pendiente de decisión o
futuro, y se consolidan en las secciones 16, 17 y 18.

---

## 2. Principios Funcionales

Principios generales que enmarcan el resto de reglas:

- El portal debe priorizar el **self-service B2B**, reduciendo la intervención del
  representante de ventas.
- El comprador debe ver información **clara, consistente y accionable** en cada
  paso.
- El sistema debe **reducir la dependencia** de pedidos por email o teléfono.
- El sistema debe **soportar compras recurrentes** como patrón central.
- El sistema debe **distinguir la experiencia B2B de la B2C** (acceso autenticado,
  precios negociados, visibilidad por cuenta).
- La **configuración estándar** de Salesforce B2B Commerce debe priorizarse antes
  que cualquier customización.

---

## 3. Reglas de Acceso y Login

- **BR-ACCESS-001** — Solo los usuarios autenticados pueden acceder a la
  experiencia B2B completa (catálogo con precios, carrito, checkout e historial).
- **BR-ACCESS-002** — El comprador debe iniciar sesión para ver precios negociados
  o específicos de su cuenta.
- **BR-ACCESS-003** — El comprador debe iniciar sesión para agregar productos al
  carrito.
- **BR-ACCESS-004** — El comprador debe iniciar sesión para consultar el historial
  de pedidos.
- **BR-ACCESS-005** — Para el MVP, cada cuenta buyer tendrá un **único usuario
  operativo** que concentra todas las acciones de compra.
- **BR-ACCESS-006** — La jerarquía Buyer User / Buyer Approver / Buyer Admin queda
  como **consideración futura**, salvo que una configuración estándar de B2B
  Commerce la requiera. *(Futuro)*

---

## 4. Reglas de Catálogo y Visibilidad

- **BR-CATALOG-001** — Los productos visibles para un comprador pueden depender de
  su cuenta o de su Buyer Group. *(Criterios exactos: pendiente de decisión)*
- **BR-CATALOG-002** — Algunos clientes pueden tener un **catálogo restringido** a
  un subconjunto de productos o categorías.
- **BR-CATALOG-003** — Un producto no visible para el comprador **no debe aparecer**
  en PLP, búsqueda ni PDP.
- **BR-CATALOG-004** — Las categorías deben agrupar productos de forma clara y
  orientada a la compra B2B.
- **BR-CATALOG-005** — El MVP debe evitar lógica compleja de marketplace o de
  multi-catálogo regional.

---

## 5. Reglas de Pricing

- **BR-PRICING-001** — El comprador debe ver precios negociados o específicos para
  su cuenta o segmento cuando apliquen.
- **BR-PRICING-002** — El pricing puede basarse en la cuenta o en el Buyer Group.
  *(Reglas exactas de asignación: pendiente de decisión)*
- **BR-PRICING-003** — El sistema debe evitar mostrar precios genéricos si existe
  un precio específico aplicable al comprador.
- **BR-PRICING-004** — El pricing por volumen puede considerarse en el futuro, pero
  **no forma parte obligatoria** del MVP. *(Futuro)*
- **BR-PRICING-005** — Las promociones complejas quedan **fuera del MVP**.

---

## 6. Reglas de Stock

- **BR-STOCK-001** — El comprador debe poder identificar si hay stock disponible
  para un producto.
- **BR-STOCK-002** — Si hay stock suficiente, el comprador puede continuar el flujo
  de compra estándar.
- **BR-STOCK-003** — Si no hay stock suficiente, el sistema debe informar la
  situación de forma clara y no permitir confirmar una cantidad no satisfacible.
  *(Comportamiento exacto —bloqueo, ajuste o aviso—: supuesto)*
- **BR-STOCK-004** — El stock podrá ser **simulado** en fases futuras mediante
  REST / Postman Mock Server. *(Futuro)*
- **BR-STOCK-005** — Una integración real con ERP queda **fuera del MVP**.
- **BR-STOCK-006** — El MVP debe documentar el comportamiento esperado ante stock
  suficiente e insuficiente aunque la integración no esté implementada todavía.

---

## 7. Reglas de Carrito

- **BR-CART-001** — El comprador puede agregar al carrito productos visibles y
  disponibles para su cuenta.
- **BR-CART-002** — El carrito debe mostrar, por línea, producto, cantidad, precio y
  subtotal.
- **BR-CART-003** — El comprador debe poder modificar las cantidades de cada línea.
- **BR-CART-004** — El comprador debe poder eliminar productos del carrito.
- **BR-CART-005** — El carrito debe reflejar las restricciones de stock, pricing o
  visibilidad cuando apliquen.
- **BR-CART-006** — El carrito debe ser claro y usable tanto en desktop como en
  mobile.

---

## 8. Reglas de Checkout

- **BR-CHECKOUT-001** — El checkout debe ser **básico y claro** para el MVP.
- **BR-CHECKOUT-002** — El comprador debe poder revisar productos, cantidades e
  importes antes de confirmar.
- **BR-CHECKOUT-003** — El checkout puede derivar en **confirmación directa** o en
  **solicitud de aprobación**, según las reglas aplicables.
- **BR-CHECKOUT-004** — Los pagos reales, el cálculo real de impuestos (tax) y el
  cálculo real de envíos (shipping) quedan **fuera del MVP**.
- **BR-CHECKOUT-005** — El checkout debe evitar fricción innecesaria para las
  compras recurrentes.

---

## 9. Reglas de Aprobación por Importe

- **BR-APPROVAL-001** — Los pedidos por encima de un umbral pueden requerir
  aprobación antes de confirmarse.
- **BR-APPROVAL-002** — El umbral exacto de importe queda **pendiente de
  definición**. *(Pendiente de decisión)*
- **BR-APPROVAL-003** — Cuando un pedido requiere aprobación, el comprador debe
  entender que **no queda confirmado automáticamente**.
- **BR-APPROVAL-004** — El estado funcional esperado debe distinguir claramente
  entre **pedido confirmado** y **solicitud pendiente de aprobación**.
- **BR-APPROVAL-005** — La jerarquía de aprobadores (Buyer Approver) queda como
  **consideración futura**. *(Futuro)*
- **BR-APPROVAL-006** — Para el MVP puede documentarse el flujo de aprobación
  aunque su automatización completa se implemente en una fase posterior.

---

## 10. Reglas de Crédito

- **BR-CREDIT-001** — El sistema puede validar el estado de crédito del cliente
  antes de confirmar un pedido.
- **BR-CREDIT-002** — Si el cliente tiene el crédito bloqueado o insuficiente, el
  sistema debe **impedir o condicionar** la confirmación del pedido.
- **BR-CREDIT-003** — El estado de crédito podrá provenir de una **integración
  simulada futura** (REST / Postman Mock Server). *(Futuro)*
- **BR-CREDIT-004** — Las reglas exactas de crédito (cálculo, valores, acción ante
  superación) quedan **pendientes de definición**. *(Pendiente de decisión)*
- **BR-CREDIT-005** — El comprador debe recibir un mensaje claro si su situación de
  crédito impide continuar.

---

## 11. Reglas de Reorder

- **BR-REORDER-001** — El comprador debe poder repetir compras anteriores.
- **BR-REORDER-002** — El reorder debe reducir los pasos necesarios para las
  compras frecuentes.
- **BR-REORDER-003** — Antes de confirmar un reorder, el sistema debe validar la
  disponibilidad, el pricing y la visibilidad **actuales** de cada producto.
- **BR-REORDER-004** — Si un producto de un pedido anterior ya no está disponible o
  visible, debe informarse claramente al comprador.
- **BR-REORDER-005** — El reorder debe ser especialmente relevante y accesible para
  resellers y clientes enterprise.

---

## 12. Reglas de Solicitud de Cotización

- **BR-QUOTE-001** — La solicitud de cotización (quote request) puede aplicar cuando
  el comprador necesita condiciones especiales.
- **BR-QUOTE-002** — El quote request puede considerarse dentro del MVP funcional,
  pero su automatización completa puede quedar para una fase posterior.
  *(Alcance en el MVP: pendiente de decisión)*
- **BR-QUOTE-003** — El comprador debe poder entender cuándo corresponde solicitar
  una cotización en lugar de comprar directamente.
- **BR-QUOTE-004** — Una cotización **no debe confundirse** con un checkout
  confirmado.

---

## 13. Reglas de Historial y Trazabilidad

- **BR-HISTORY-001** — El comprador debe poder consultar sus pedidos anteriores.
- **BR-HISTORY-002** — El comprador debe poder ver el detalle de cada pedido.
- **BR-HISTORY-003** — El historial debe facilitar el reorder.
- **BR-HISTORY-004** — La trazabilidad debe reducir la dependencia del
  representante de ventas.
- **BR-HISTORY-005** — El MVP no requiere un OMS avanzado para cubrir el historial y
  la trazabilidad básicos.

---

## 14. Reglas UX Transversales

- **BR-UX-001** — La experiencia debe ser **mobile-first** y responsive.
- **BR-UX-002** — Los mensajes de error deben ser claros y accionables.
- **BR-UX-003** — Los estados de stock, aprobación, crédito y carrito deben ser
  comprensibles para el comprador.
- **BR-UX-004** — Las páginas PLP, PDP, carrito y checkout deben priorizar la
  claridad y la velocidad.
- **BR-UX-005** — Se deben contemplar los estados **loading**, **empty** y
  **error** en las vistas relevantes.

---

## 15. Reglas de Fuera de Alcance

- **BR-OOS-001** — El MVP no procesa pagos reales.
- **BR-OOS-002** — El MVP no calcula impuestos reales (tax).
- **BR-OOS-003** — El MVP no calcula envíos reales (shipping).
- **BR-OOS-004** — El MVP no implementa un OMS avanzado.
- **BR-OOS-005** — El MVP no integra un ERP real.
- **BR-OOS-006** — El MVP no implementa un modelo de marketplace.
- **BR-OOS-007** — El MVP no implementa multi-idioma ni multi-divisa.

---

## 16. Matriz Resumen de Reglas

Selección de las reglas más relevantes. Prioridad MVP: Alta / Media / Baja.
Estado: Definida / Supuesto / Pendiente de decisión / Futuro.

| ID | Categoría | Regla | Prioridad MVP | Estado |
| --- | --- | --- | --- | --- |
| BR-ACCESS-001 | Acceso | Solo usuarios autenticados acceden a la experiencia B2B completa | Alta | Definida |
| BR-ACCESS-002 | Acceso | Login requerido para ver precios negociados | Alta | Definida |
| BR-ACCESS-005 | Acceso | Un único usuario operativo por cuenta en el MVP | Alta | Definida |
| BR-ACCESS-006 | Acceso | Jerarquía Buyer User/Approver/Admin | Baja | Futuro |
| BR-CATALOG-001 | Catálogo | Visibilidad de productos por cuenta o Buyer Group | Alta | Pendiente de decisión |
| BR-CATALOG-002 | Catálogo | Catálogo restringido para algunos clientes | Media | Definida |
| BR-CATALOG-003 | Catálogo | Producto no visible no aparece en PLP, búsqueda ni PDP | Alta | Definida |
| BR-PRICING-001 | Pricing | Precios negociados/específicos visibles cuando apliquen | Alta | Definida |
| BR-PRICING-002 | Pricing | Pricing por cuenta o Buyer Group | Alta | Pendiente de decisión |
| BR-PRICING-004 | Pricing | Pricing por volumen | Baja | Futuro |
| BR-STOCK-001 | Stock | Comprador identifica disponibilidad de stock | Alta | Definida |
| BR-STOCK-003 | Stock | Aviso y bloqueo ante stock insuficiente | Alta | Supuesto |
| BR-STOCK-004 | Stock | Stock simulado vía REST / Postman Mock Server | Media | Futuro |
| BR-CART-002 | Carrito | Carrito muestra producto, cantidad, precio y subtotal | Alta | Definida |
| BR-CHECKOUT-001 | Checkout | Checkout básico y claro | Alta | Definida |
| BR-CHECKOUT-003 | Checkout | Checkout deriva en confirmación o solicitud de aprobación | Alta | Definida |
| BR-APPROVAL-001 | Aprobación | Aprobación por importe sobre un umbral | Alta | Definida |
| BR-APPROVAL-002 | Aprobación | Umbral exacto de aprobación | Alta | Pendiente de decisión |
| BR-CREDIT-002 | Crédito | Bloqueo/condición ante crédito insuficiente | Media | Definida |
| BR-CREDIT-004 | Crédito | Reglas exactas de crédito | Media | Pendiente de decisión |
| BR-REORDER-001 | Reorder | Repetir compras anteriores | Alta | Definida |
| BR-REORDER-003 | Reorder | Revalidar disponibilidad, pricing y visibilidad en el reorder | Alta | Definida |
| BR-QUOTE-002 | Cotización | Alcance del quote request en el MVP | Media | Pendiente de decisión |
| BR-HISTORY-001 | Historial | Consulta de pedidos anteriores | Alta | Definida |
| BR-UX-001 | UX | Experiencia mobile-first y responsive | Alta | Definida |
| BR-OOS-005 | Fuera de alcance | Sin integración real con ERP | Alta | Definida |

---

## 17. Supuestos Actuales

- Cada buyer account tiene un **único usuario operativo** en el MVP.
- El **umbral exacto de aprobación** por importe todavía no está definido.
- Las **reglas exactas de crédito** todavía no están definidas.
- El **stock** puede simularse en fases futuras (REST / Postman Mock Server).
- El **ERP real** está fuera del MVP.
- El **pricing específico** se modelará inicialmente con capacidades estándar de
  Salesforce B2B Commerce cuando sea posible.
- El **comportamiento exacto ante stock insuficiente** está por confirmar.
- El **alcance del quote request** en el MVP está por confirmar.

---

## 18. Decisiones Pendientes

- **Umbral de aprobación** por importe.
- **Segmentos o Buyer Groups** concretos y sus criterios.
- **Reglas exactas de pricing** y su asignación a cuentas o segmentos.
- **Reglas exactas de stock** y comportamiento ante insuficiencia.
- **Reglas exactas de crédito** (cálculo, valores y acciones).
- **Nivel de automatización del quote request**.
- **Nivel de automatización del approval flow**.

---

## 19. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general** del proyecto y del negocio.
- `docs/business/ecommerce-strategy.md` define la **estrategia de e-commerce B2B**.
- `docs/business/buyer-personas.md` define los **perfiles de comprador**.
- Este documento define las **reglas de negocio iniciales** y sus identificadores.
- Los **flujos detallados** deberán evolucionar en
  `docs/business/b2b-commerce-flows.md`.
- Las **decisiones técnicas** deberán documentarse en `docs/architecture/`.
- Los **casos de prueba** deberán derivarse luego en `docs/testing/` o `evals/`.
