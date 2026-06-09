# Principios UX - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define los **principios UX** que guiarán la experiencia del
storefront B2B de LvlUp WholeSale. Describe criterios de experiencia, no diseño
visual final.

Sirve como base para:

- Diseño de navegación.
- PLP.
- PDP.
- Carrito.
- Checkout.
- Historial.
- Reorder.
- Estados loading, empty y error.
- Decisiones de configuración en Experience Builder.
- Futuras decisiones de LWC custom.

Este documento **no define el diseño visual final ni los wireframes detallados**;
esos vivirán en documentos posteriores de `docs/ux/`. Se alinea con los documentos
de `docs/business/` y aplica el principio rector del proyecto: *Configuration
first, customization only when justified*.

---

## 2. Principios UX Generales

- **Claridad antes que decoración**.
- **Velocidad de compra** antes que exploración excesiva.
- Experiencia **B2B, no B2C**.
- Información **accionable**.
- **Consistencia** entre PLP, PDP, carrito y checkout.
- **Mobile-first** y responsive.
- Reducir la **dependencia del representante de ventas**.
- Priorizar la **configuración estándar** antes que la UI custom.
- Evitar **fricción innecesaria** en las compras recurrentes.

---

## 3. Perfil UX del Comprador B2B

El comprador B2B de LvlUp WholeSale (un responsable de compras / purchasing
manager) piensa y actúa de forma distinta a un consumidor final:

- Compra con un **objetivo concreto**, no para explorar.
- Valora la **rapidez y la claridad**.
- Necesita un **pricing correcto** y aplicable a su cuenta.
- Necesita **visibilidad de stock**.
- Suele **repetir pedidos** (reorder como patrón central).
- Puede comprar **altos volúmenes**.
- Necesita **trazabilidad** de sus pedidos.
- No quiere **ambigüedad** en los estados de pedido, aprobación o crédito.

Estos rasgos se corresponden con las buyer personas ya documentadas en
`docs/business/buyer-personas.md` (tienda gaming local, reseller tecnológico,
empresa compradora de equipamiento interno y cliente enterprise recurrente). La
UX debe servir a todas ellas priorizando la eficiencia y la recurrencia.

---

## 4. Principios de Navegación

- Navegación **simple por categorías**.
- Acceso **rápido a la búsqueda**.
- Acceso **visible al carrito**.
- Acceso **visible a historial y reorder**.
- Evitar **menús excesivamente profundos**.
- Mantener **rutas claras** hacia PLP, PDP y checkout.
- Diseñar la navegación con enfoque **mobile-first**.

---

## 5. Principios para Home

- Dar **acceso rápido al catálogo**.
- Mostrar las **categorías clave** de tecnología y gaming.
- Orientar a la **compra recurrente**.
- Evitar un enfoque **puramente promocional B2C**.
- Considerar productos destacados o accesos rápidos como **consideración futura**.
- Priorizar la **claridad** sobre el contenido decorativo.

---

## 6. Principios para PLP

- Mostrar solo los **productos visibles** para el buyer.
- Mostrar información **suficiente para decidir rápido**.
- Mostrar **nombre, imagen, precio aplicable y disponibilidad** cuando corresponda.
- Evitar la **saturación visual**.
- Permitir **búsqueda y filtros** si el estándar lo permite.
- Mantener **consistencia** con PDP, carrito y checkout.
- Contemplar el **estado sin resultados** (empty).
- Diseño **mobile-first**.

---

## 7. Principios para PDP

- Mostrar información **clara y suficiente** del producto.
- Mostrar el **pricing aplicable**.
- Mostrar la **disponibilidad funcional**.
- Permitir **agregar al carrito** cuando corresponda.
- **Comunicar restricciones** si existen.
- Evitar contenido **excesivamente B2C**.
- Priorizar datos útiles para la compra B2B: **SKU, categoría, cantidad,
  disponibilidad, unidad de venta y descripción clara**.
- Considerar productos relacionados o alternativas como **consideración futura**.

---

## 8. Principios para Carrito

- Mostrar **productos, cantidades, precios y subtotales** de forma clara.
- Permitir **modificar cantidades**.
- Permitir **eliminar productos**.
- **Informar restricciones** de stock, pricing o visibilidad.
- **Preparar al comprador** para el checkout.
- Evitar **sorpresas de precio**.
- Mantener una UX **simple en mobile**.
- **Diferenciar claramente** los productos válidos de los productos con problemas.

---

## 9. Principios para Checkout

- Checkout **básico y claro** para el MVP.
- Permitir **revisar el pedido** antes de confirmar.
- Indicar si el pedido queda **confirmado** o **pendiente de aprobación**.
- **No generar expectativas** de pagos, tax o shipping reales (fuera del MVP).
- **Minimizar la fricción**.
- Mostrar **mensajes claros** cuando aplique aprobación, crédito o stock
  insuficiente.

---

## 10. Principios para Historial y Reorder

- Historial orientado a la **trazabilidad**.
- Acceso **claro al detalle** de pedido.
- Reorder como **flujo clave** para las compras recurrentes.
- **Validar** que los productos anteriores sigan visibles, disponibles y con
  pricing actual.
- **Informar los cambios** claramente.
- **Reducir los pasos** para repetir compras.

---

## 11. Principios para Solicitud de Aprobación

- El comprador debe **entender cuándo** un pedido requiere aprobación.
- El **estado pendiente** debe diferenciarse del pedido confirmado.
- El mensaje debe ser **claro y accionable**.
- El **umbral exacto** queda pendiente de definición.
- La **jerarquía de aprobadores** puede ser futura.
- Evitar que el comprador **crea que la compra fue confirmada** si está pendiente.

---

## 12. Principios para Crédito y Stock Insuficiente

### Crédito

- Mensajes **claros** cuando el crédito esté bloqueado o excedido.
- **Evitar mensajes técnicos**.
- Explicar si el pedido **no puede continuar** o **queda condicionado**.
- Las **reglas exactas** quedan pendientes.

### Stock insuficiente

- **Indicar la disponibilidad insuficiente**.
- Permitir **ajustar la cantidad, buscar una alternativa o continuar con los
  productos válidos** si aplica.
- La **fecha estimada de entrega** o el **backorder** quedan como decisiones
  futuras.
- **No ocultar el problema** hasta el checkout.

---

## 13. Estados UX Transversales

### Loading

- Mostrar que el sistema **está procesando**.
- Evitar **pantallas congeladas**.
- Usar **mensajes breves y claros**.

### Empty

- Explicar **por qué no hay contenido**.
- Dar una **acción siguiente**.
- Ejemplos: sin productos visibles, sin resultados de búsqueda, sin pedidos
  anteriores.

### Error

- Explicar **qué ocurrió**.
- **Evitar mensajes técnicos**.
- **Sugerir una acción** siguiente.
- Mantener un **tono profesional**.

### Pending

- Usar para **aprobaciones, cotizaciones o procesos no confirmados**.
- **Diferenciar** del éxito final.

---

## 14. Principios de Mobile-First

- Priorizar la **lectura rápida**.
- **Botones claros y accesibles**.
- **Formularios simples**.
- **Carrito usable** en pantalla pequeña.
- **Checkout sin pasos innecesarios**.
- **Navegación por categorías simplificada**.
- Evitar **tablas complejas** en mobile cuando sea posible.

---

## 15. Principios de Accesibilidad

- **Contraste suficiente**.
- **Textos claros**.
- **Botones con etiquetas comprensibles**.
- **No depender solo del color** para comunicar estados.
- **Mensajes de error visibles**.
- **Jerarquía visual clara**.
- **Navegación consistente**.

No se entra todavía en el detalle técnico exhaustivo de accesibilidad; se
establecen los principios generales.

---

## 16. Relación con Salesforce B2B Commerce y Experience Builder

- La UX debe **aprovechar los componentes y capacidades estándar** cuando sea
  posible.
- **Experience Builder** debe ser la **primera opción** para el layout y la
  configuración.
- El **LWC custom** debe considerarse **solo si hay una necesidad funcional clara**.
- Las decisiones de **UI custom** deben justificarse contra el principio
  *Configuration first, customization only when justified*.
- Las **limitaciones del estándar** deben documentarse antes de proponer
  customización.

---

## 17. Riesgos UX

- Diseñar una experiencia **demasiado B2C**.
- **Sobrecargar la Home** con contenido decorativo.
- **Ocultar el pricing o el stock**.
- **No diferenciar** aprobado, pendiente y rechazado.
- Crear **flujos mobile** difíciles de usar.
- **Customizar antes de validar** las capacidades estándar.
- **No contemplar** los estados empty, error y loading.
- Hacer **reorder sin validar** pricing, stock y visibilidad actuales.

---

## 18. Supuestos Actuales

- El comprador **prioriza la rapidez y la claridad**.
- El portal se usará tanto en **desktop como en mobile**.
- El MVP usará **componentes estándar** siempre que sea posible.
- La **UX visual final** puede evolucionar después.
- Los **wireframes detallados** se documentarán en archivos posteriores.
- Las **reglas exactas** de aprobación, crédito y stock todavía pueden evolucionar.

---

## 19. Decisiones Pendientes

- Diseño final de la **Home**.
- **Componentes estándar** disponibles para cada pantalla.
- **Necesidad real de LWC custom**.
- **Nivel de filtros** en PLP.
- **Mensajes exactos** de error, stock, crédito y aprobación.
- **Comportamiento exacto** ante productos no disponibles en el reorder.
- **Nivel de detalle visual** de los wireframes.

---

## 20. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general** del proyecto.
- `docs/business/` define **negocio, reglas, flujos, catálogo, pricing y
  visibilidad**.
- Este documento define los **principios UX**.
- `docs/ux/storefront-journey.md` deberá definir el **journey visual y funcional**
  del storefront.
- `docs/ux/plp-pdp-guidelines.md` deberá **profundizar en PLP/PDP**.
- `docs/ux/cart-checkout-experience.md` deberá **profundizar en carrito/checkout**.
- `docs/architecture/` deberá **justificar** cualquier decisión técnica o custom.
- `docs/salesforce/` deberá **documentar** la configuración y las capacidades
  estándar.
- `evals/` podrá usar estos principios para **evaluar** las respuestas de los
  agentes UX.
