# Wireframes Textuales - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define una **primera aproximación textual a los wireframes** del
storefront B2B de LvlUp WholeSale. Representa la estructura funcional de cada
pantalla del MVP, no su diseño visual final ni su implementación técnica.

Sirve como base para:

- Diseño UX.
- Configuración en Experience Builder.
- Validación de las pantallas del MVP.
- Discusión funcional.
- Testing UX.
- Evaluación de necesidades futuras de LWC custom.
- Alineación entre negocio, UX, arquitectura y agentes de IA.

Estos wireframes son **conceptuales**. Se alinean con el resto de `docs/ux/` y con
los documentos de `docs/business/`, y aplican el principio rector del proyecto:
*Configuration first, customization only when justified*.

---

## 2. Principios de Wireframing

- **Mobile-first**.
- **Claridad antes que decoración**.
- Priorizar las **acciones de compra B2B**.
- Mantener la **navegación simple**.
- Mostrar **pricing, stock y estados** de forma clara.
- Evitar elementos **puramente promocionales B2C**.
- Aprovechar **componentes estándar** de Salesforce B2B Commerce y Experience
  Builder.
- **No proponer UI custom** sin una necesidad funcional justificada.

---

## 3. Convención de Wireframes Textuales

Los wireframes usan **bloques funcionales** etiquetados. Cada bloque representa una
zona o componente, no un diseño visual definitivo. Convención:

- `[Header]` — cabecera global (logo, búsqueda, carrito, cuenta).
- `[Navigation]` — navegación por categorías y accesos.
- `[Search]` — búsqueda de productos.
- `[Content Area]` — zona de contenido principal de la pantalla.
- `[Product Card]` — tarjeta de producto en listados.
- `[Action Button]` — acción primaria o secundaria.
- `[Message State]` — estado empty, error, loading, pending o restricción.
- `[Footer]` — pie con soporte/ayuda.

El **orden vertical** de los bloques refleja la lectura mobile-first; en desktop
algunos bloques pueden disponerse en columnas (ver sección 17).

---

## 4. Wireframe Global: Estructura Base del Storefront

```text
[Header]
  - Logo LvlUp WholeSale
  - Search
  - Cart
  - My Account

[Navigation]
  - Categorías principales
  - Acceso a Historial / Reorder

[Main Content]
  - Contenido variable según pantalla

[Footer]
  - Información básica
  - Links de soporte o ayuda
```

**Notas funcionales.** El `[Header]` y el `[Footer]` son persistentes en todas las
pantallas autenticadas. La `[Navigation]` expone las categorías de
`docs/business/product-catalog-strategy.md` y el acceso directo a Historial/Reorder
(patrón de compra recurrente). El `[Main Content]` cambia por pantalla en las
secciones siguientes.

---

## 5. Login

```text
[Header]
  - Logo LvlUp WholeSale

[Content Area]
  - Título: Acceso al portal
  - [Field] Email
  - [Field] Contraseña
  - [Action Button] Iniciar sesión
  - [Link] ¿Olvidaste tu contraseña?
  - [Message State] "Email o contraseña incorrectos." / "Tu sesión ha caducado…"

[Footer]
  - Links de soporte / ayuda
```

**Notas funcionales.** Sin login no hay experiencia B2B (`BR-ACCESS-001`). Estados:
cargando, credenciales incorrectas, sesión expirada, usuario sin acceso (ver
`empty-error-loading-states.md` §5). Mobile: formulario simple y botón táctil.

---

## 6. Home

```text
[Header] Logo · Search · Cart · My Account
[Navigation] Categorías principales · Historial / Reorder

[Content Area]
  - [Search] Buscar productos
  - [Section] Categorías destacadas
      - Consolas · Videojuegos · Portátiles · Monitores · Periféricos · Networking · Accesorios · Bundles
  - [Section] Compra recurrente
      - [Action Button] Reordenar último pedido
      - [Action Button] Ver historial
  - [Message State] (loading / error de contenido)

[Footer]
```

**Notas funcionales.** Orientada a la **compra recurrente**, no promocional B2C
(`ux-principles.md` §5). Accesos clave visibles sin scroll excesivo en mobile.

---

## 7. Catálogo / PLP

```text
[Header]
[Navigation] Categoría actual · Breadcrumb

[Content Area]
  - [Search] + [Filtros básicos] (si el estándar lo permite)
  - [Product Card] (repetido)
      - Imagen o placeholder
      - Nombre del producto
      - SKU (si resulta útil)
      - Precio aplicable
      - Disponibilidad funcional
      - [Action Button] Ver detalle  ·  [Action Button] Añadir al carrito (si aplica)
  - [Message State]
      - "No hay productos disponibles en esta categoría para tu cuenta."
      - "No encontramos productos para tu búsqueda."
      - Loading / Error

[Footer]
```

**Notas funcionales.** Solo productos **visibles** para la cuenta/Buyer Group
(`PV-001`, `PV-006`); pricing aplicable (`PR-002`). Estados en
`plp-pdp-guidelines.md` §3.7. Mobile: cards legibles, precio visible, filtros
simplificados.

---

## 8. PDP

```text
[Header]
[Navigation] Breadcrumb

[Content Area]
  - [Product Image] o placeholder
  - Nombre del producto
  - SKU · Categoría · Unidad de venta
  - Precio aplicable
  - Disponibilidad funcional
  - [Field] Cantidad
  - [Action Button] Añadir al carrito
  - [Section] Descripción / especificaciones (colapsable en mobile)
  - [Message State]
      - "Stock insuficiente para la cantidad solicitada."
      - "Este producto no está disponible para tu cuenta."
      - "El precio no está disponible en este momento."
      - "Producto añadido al carrito."

[Footer]
```

**Notas funcionales.** Información **B2B** (SKU, unidad de venta, cantidad), no B2C
(`product-catalog-strategy.md` §12). Precio consistente con PLP (`PR-003`). Estados
en `plp-pdp-guidelines.md` §4.8.

---

## 9. Carrito

```text
[Header]

[Content Area]
  - Título: Tu carrito
  - [Cart Line] (repetido)
      - Imagen · Nombre · SKU
      - [Field] Cantidad        · [Action Button] Eliminar
      - Precio unitario · Subtotal
      - [Message State] restricción por línea (stock / visibilidad / precio)
  - [Summary]
      - Subtotal funcional
      - Total funcional
      - [Message State] "Este pedido podría requerir aprobación por su importe."
  - [Action Button] Ir a checkout
  - [Action Button] Continuar comprando
  - [Message State] "Tu carrito está vacío." / Loading / Error

[Footer]
```

**Notas funcionales.** El carrito **revalida** stock, pricing y visibilidad
(`BR-CART-005`). Diferenciar líneas válidas de las que tienen problemas. Estados en
`cart-checkout-experience.md` §7. Mobile: evitar tablas complejas.

---

## 10. Checkout

```text
[Header]

[Content Area]
  - Título: Revisar y confirmar
  - [Section] Resumen del pedido (productos · cantidades · precios)
  - [Section] Totales (subtotal · total funcional)
  - [Message State]
      - "Este pedido supera el importe permitido y requiere aprobación."
      - "No es posible confirmar el pedido por el estado de crédito de tu cuenta."
      - "Algunos productos no tienen stock suficiente…"
  - [Action Button] Confirmar pedido   (o)   Enviar solicitud de aprobación
  - [Action Button] Volver al carrito
  - Nota: sin pago, impuestos ni envío reales (fuera del MVP)

[Footer]
```

**Notas funcionales.** Última barrera de validación antes de confirmar o derivar
(`cart-checkout-experience.md` §11). Pagos/tax/shipping reales fuera del MVP
(`BR-CHECKOUT-004`).

---

## 11. Confirmación / Estado Pendiente

```text
[Header]

[Content Area]  (variante A: pedido confirmado)
  - [Message State] "Pedido confirmado."
  - Referencia del pedido
  - [Action Button] Ver pedido · [Action Button] Volver al catálogo

[Content Area]  (variante B: solicitud pendiente)
  - [Message State] "Solicitud enviada. Tu pedido queda pendiente de aprobación."
  - Estado: Pendiente de aprobación
  - [Action Button] Consultar estado en el historial

[Footer]
```

**Notas funcionales.** **Distinguir** inequívocamente pedido confirmado de
solicitud pendiente (`BR-APPROVAL-003`, `BR-APPROVAL-004`). Mismo patrón para la
cotización pendiente.

---

## 12. Historial de Pedidos

```text
[Header]
[Navigation]

[Content Area]
  - Título: Mis pedidos
  - [Order Row] (repetido)
      - Nº de pedido · Fecha · Estado (Confirmado / Pendiente) · Importe
      - [Action Button] Ver detalle
  - [Message State] "Todavía no tienes pedidos." / Loading / Error

[Footer]
```

**Notas funcionales.** Trazabilidad (`BR-HISTORY-001`). Estados de pedido visibles
y comprensibles. Punto de entrada al reorder.

---

## 13. Detalle de Pedido

```text
[Header]

[Content Area]
  - Título: Pedido #...
  - Estado · Fecha · Total funcional
  - [Order Line] (repetido): producto · cantidad · precio
  - [Action Button] Reordenar
  - [Action Button] Volver al historial
  - [Message State] Pendiente / No disponible

[Footer]
```

**Notas funcionales.** Base del reorder (`BR-HISTORY-002`, `BR-REORDER-001`).

---

## 14. Reorder

```text
(Acceso: Detalle de Pedido → [Action Button] Reordenar)

[Content Area]
  - [Message State] "Hemos añadido los productos de tu pedido anterior."
  - [Section] Productos añadidos (válidos)
  - [Section] Productos excluidos
      - Motivo: no visible / sin stock / inactivo
  - [Message State] "El precio de algunos productos se ha actualizado."
  - [Action Button] Revisar carrito
```

**Notas funcionales.** Revalida **visibilidad, pricing y stock actuales**
(`BR-REORDER-003`, `PV-007`). Soporta reorder **parcial** informando los excluidos
(`empty-error-loading-states.md` §12).

---

## 15. Solicitud de Aprobación

```text
(Acceso: Checkout cuando el importe supera el umbral)

[Content Area]
  - [Message State] "Este pedido requiere aprobación antes de confirmarse."
  - [Section] Resumen del pedido + importe total
  - [Action Button] Enviar solicitud
  - [Message State] "Solicitud enviada. Tu pedido queda pendiente de aprobación."
  - [Action Button] Consultar estado en el historial
```

**Notas funcionales.** Umbral exacto y aprobador **pendientes** (`BR-APPROVAL-002`,
`BR-APPROVAL-005`). Enviar solicitud **no** es confirmar el pedido.

---

## 16. Mi Cuenta

```text
[Header]
[Navigation]

[Content Area]
  - Título: Mi cuenta
  - [Section] Datos del usuario y de la cuenta
  - [Section] Accesos: Historial · Reorder
  - [Section] Contacto comercial
  - [Action Button] Cerrar sesión

[Footer]
```

**Notas funcionales.** En el MVP, **un único usuario operativo por cuenta**
(`BR-ACCESS-005`); la jerarquía Buyer User / Approver / Admin es futura
(`BR-ACCESS-006`). Mantener la pantalla simple.

---

## 17. Variantes Mobile vs Desktop

- **Mobile (referencia base).** Bloques apilados en vertical en el orden mostrado;
  `[Navigation]` y filtros colapsables; acciones primarias siempre visibles.
- **Desktop.** Posibles disposiciones en columnas:
  - PLP: filtros/categorías en columna lateral + grid de `[Product Card]`.
  - PDP: imagen a la izquierda + datos y acción de compra a la derecha.
  - Carrito/Checkout: líneas a la izquierda + `[Summary]` fijo a la derecha.
- En ambos casos se priorizan los **componentes estándar** de Experience Builder;
  cualquier disposición custom debe justificarse.

---

## 18. Supuestos y Decisiones Pendientes

**Supuestos.**

- Los wireframes son conceptuales y evolucionarán.
- Se priorizan los componentes estándar de Salesforce B2B Commerce.
- El comprador está autenticado en la mayoría de pantallas.
- El catálogo del MVP es pequeño y representativo.

**Decisiones pendientes.**

- Disposición visual final de cada pantalla.
- Componentes estándar disponibles por pantalla y sus límites.
- Nivel de filtros en PLP y de detalle en PDP.
- Si se permite añadir al carrito desde PLP.
- Necesidad real de LWC custom.
- Diseño final de Home y de Mi Cuenta.

---

## 19. Relación con Otros Documentos

- `docs/ux/ux-principles.md` define los **principios UX generales**.
- `docs/ux/storefront-journey.md` define el **journey completo**.
- `docs/ux/plp-pdp-guidelines.md` **profundiza en PLP/PDP**.
- `docs/ux/cart-checkout-experience.md` **profundiza en carrito/checkout**.
- `docs/ux/empty-error-loading-states.md` define los **estados transversales** que
  aparecen como `[Message State]` en estos wireframes.
- Este documento aporta los **wireframes textuales** de las pantallas del MVP.
- `docs/business/` define negocio, reglas, flujos, catálogo, pricing y visibilidad.
- `docs/architecture/` documentará las **decisiones técnicas**.
- `docs/salesforce/` documentará las **capacidades y la configuración** de
  Salesforce.
- `evals/` podrá **evaluar** si los agentes respetan estos wireframes y estados.
