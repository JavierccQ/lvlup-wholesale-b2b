# Guidelines PLP y PDP - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define las **guidelines funcionales y UX** para la Product Listing
Page (PLP) y la Product Detail Page (PDP) del storefront B2B de LvlUp WholeSale.
Describe comportamiento esperado, no implementación técnica ni layout visual final.

Sirve como base para:

- Diseño de la experiencia de catálogo.
- Configuración de Experience Builder.
- Evaluación de componentes estándar.
- Decisiones futuras de LWC custom.
- Testing funcional.
- Evaluaciones de agentes de IA.
- Validación de pricing, visibilidad y stock.

Se alinea con `docs/ux/ux-principles.md`, `docs/ux/storefront-journey.md`,
`docs/business/product-catalog-strategy.md` y
`docs/business/pricing-and-visibility-strategy.md`, y aplica el principio rector
del proyecto: *Configuration first, customization only when justified*.

---

## 2. Principios Generales para PLP y PDP

- Mostrar solo los **productos visibles** para el buyer autenticado.
- Mantener el **pricing consistente** entre PLP, PDP, carrito y checkout.
- Priorizar la **claridad y la velocidad** de decisión.
- Evitar un enfoque **excesivamente B2C**.
- Mostrar información **accionable**.
- Respetar **mobile-first**.
- Usar **estándar de Salesforce B2B Commerce y Experience Builder** antes que
  customización.
- **Documentar las limitaciones** del estándar antes de justificar LWC custom.

---

## 3. Product Listing Page / PLP

### 3.1 Objetivo de la PLP

La PLP permite al comprador **explorar los productos visibles**, comparar opciones
y avanzar rápidamente hacia la PDP o el carrito. Su prioridad es la decisión
rápida, no la exploración prolongada.

### 3.2 Información Mínima por Producto

- Imagen o placeholder.
- Nombre del producto.
- SKU si resulta útil.
- Categoría o familia.
- Precio aplicable.
- Disponibilidad funcional cuando aplique.
- Indicador de restricción si es necesario.
- Acción hacia la PDP.
- Acción de agregar al carrito si el estándar lo permite.

### 3.3 Comportamiento de Visibilidad

- Los productos **no visibles** para la cuenta o el Buyer Group **no deben
  aparecer**.
- Los productos **restringidos** no deben aparecer en búsqueda ni categorías.
- Los productos **inactivos** no deben aparecer.
- La PLP debe reflejar el **catálogo permitido** para el buyer.
- **Evitar mensajes técnicos** sobre las reglas internas de visibilidad
  (coherente con `PV-001`, `PV-006`).

### 3.4 Comportamiento de Pricing

- El precio mostrado debe ser el **aplicable al buyer**.
- No debe existir **contradicción** entre PLP, PDP, carrito y checkout.
- Si el **pricing específico no está disponible**, debe evitarse mostrar
  información ambigua.
- El **pricing por volumen** queda como consideración futura.
- Las **promociones complejas** quedan fuera del MVP (coherente con `PR-002`,
  `PR-003`, `PR-004`).

### 3.5 Comportamiento de Stock

- Si hay **disponibilidad funcional**, debe indicarse de forma clara.
- Si **no hay stock suficiente**, debe informarse **sin bloquear la navegación**.
- **Evitar ocultar** los problemas de stock hasta el checkout.
- El **stock real vía ERP** queda fuera del MVP.
- El **stock simulado vía REST / Postman Mock Server** queda como fase futura
  (coherente con `BR-STOCK-001`, `BR-STOCK-003`).

### 3.6 Navegación, Filtros y Búsqueda

- Navegación por **categorías clara**.
- **Filtros básicos** si el estándar lo permite.
- **Búsqueda visible** y fácil de usar.
- Resultados **ordenados de forma útil** para la compra B2B.
- **Evitar filtros excesivos** en el MVP.
- Priorizar las **categorías principales** definidas en
  `docs/business/product-catalog-strategy.md`.

### 3.7 Estados de PLP

| Estado | Qué ve el comprador | Mensaje UX recomendado | Acción siguiente | Riesgo UX |
| --- | --- | --- | --- | --- |
| Con productos visibles | Listado con precio y disponibilidad | — | Entrar a PDP o añadir al carrito | Saturación visual |
| Sin productos visibles | Estado vacío explicado | "No hay productos disponibles en esta categoría para tu cuenta." | Explorar otras categorías | Parecer un error y no un estado vacío |
| Búsqueda sin resultados | Estado vacío de búsqueda | "No encontramos productos para tu búsqueda." | Revisar términos o ver categorías | Dejar al comprador sin salida |
| Filtros sin resultados | Estado vacío de filtros | "Ningún producto coincide con los filtros aplicados." | Ajustar o limpiar filtros | No ofrecer limpiar filtros |
| Error al cargar | Mensaje de error | "No pudimos cargar los productos. Inténtalo de nuevo." | Reintentar | Mensaje técnico |
| Loading | Indicador de carga | "Cargando productos…" | Esperar | Pantalla congelada sin feedback |
| Productos con stock insuficiente | Producto con aviso de disponibilidad | "Stock insuficiente para la cantidad habitual." | Ajustar cantidad o ver alternativas | Ocultar el problema |
| Productos no comprables | Producto visible sin acción de compra | "Producto no disponible para compra en este momento." | Volver al catálogo | Permitir añadir algo no comprable |

### 3.8 Mobile-First en PLP

- **Cards legibles**.
- **Botones táctiles** claros.
- **Precio visible** sin exceso de scroll.
- **Imagen útil** pero no dominante.
- **Filtros simplificados**.
- **Evitar tablas complejas**.
- Priorizar **búsqueda y categorías**.

---

## 4. Product Detail Page / PDP

### 4.1 Objetivo de la PDP

La PDP permite **validar la información detallada** del producto y tomar la
decisión de **agregar al carrito**.

### 4.2 Información Mínima Esperada

- Nombre del producto.
- SKU.
- Imagen o placeholder.
- Categoría.
- Descripción corta.
- Descripción funcional o técnica.
- Precio aplicable.
- Disponibilidad funcional.
- Cantidad.
- Unidad de venta si aplica.
- Acción de agregar al carrito.
- Mensajes de restricción, stock o pricing si aplican.

### 4.3 Información B2B Relevante

Información especialmente útil para compradores B2B:

- SKU.
- Unidad de venta.
- Cantidad mínima si aplica.
- Compatibilidad o especificaciones relevantes.
- Disponibilidad.
- Estado comercial del producto.
- Bundles relacionados si aplica.
- Recomendaciones de compra recurrente como consideración futura.

La PDP **no debe convertirse en una página promocional B2C**.

### 4.4 Comportamiento de Visibilidad

- La PDP solo debe ser **accesible para productos visibles** al buyer.
- Si el producto **deja de estar visible**, el buyer debe recibir feedback claro.
- **No deben exponerse** productos restringidos mediante navegación directa.
- El **reorder** debe validar si la PDP/producto sigue siendo accesible
  (coherente con `PV-007`).

### 4.5 Comportamiento de Pricing

- El precio debe ser el **aplicable a la cuenta o Buyer Group**.
- El precio debe **coincidir** con PLP, carrito y checkout.
- Los **cambios de pricing** deben reflejarse antes de confirmar la compra.
- **Evitar** mostrar precios genéricos contradictorios.
- El **pricing avanzado** queda como futuro.

### 4.6 Comportamiento de Stock

- Producto con **stock suficiente**.
- Producto con **stock insuficiente**.
- Producto **no disponible temporalmente**.
- Producto **pendiente de reposición** como posible futuro.
- Producto **sin stock pero con alternativa** como posible futuro.
- **Backorder** como decisión pendiente.

### 4.7 Agregar al Carrito desde PDP

**Validaciones funcionales:**

- Producto visible.
- Producto activo / comprable.
- Cantidad válida.
- Pricing aplicable.
- Stock suficiente si aplica.
- Restricciones funcionales cumplidas.

**Estados esperados:**

- Producto agregado correctamente.
- Cantidad inválida.
- Stock insuficiente.
- Producto ya no visible.
- Error funcional.
- Loading.

### 4.8 Estados de PDP

| Estado | Qué ve el comprador | Mensaje UX recomendado | Acción siguiente | Riesgo UX |
| --- | --- | --- | --- | --- |
| Producto disponible | Detalle completo y acción de compra | — | Ajustar cantidad y añadir al carrito | — |
| Stock insuficiente | Detalle con aviso de disponibilidad | "Stock insuficiente para la cantidad solicitada." | Ajustar cantidad o ver alternativas | Ocultar el problema hasta el carrito |
| No visible / no permitido | Mensaje de no disponibilidad | "Este producto no está disponible para tu cuenta." | Volver al catálogo | Exponer detalles de un producto restringido |
| Producto inactivo | Detalle sin acción de compra | "Producto no disponible actualmente." | Ver alternativas o volver | Permitir compra de algo inactivo |
| Error al cargar | Mensaje de error | "No pudimos cargar el producto. Inténtalo de nuevo." | Reintentar | Mensaje técnico |
| Loading | Indicador de carga | "Cargando producto…" | Esperar | Pantalla congelada |
| Precio no disponible | Detalle sin precio firme | "El precio no está disponible en este momento." | Reintentar o volver más tarde | Mostrar un precio genérico erróneo |
| Producto agregado al carrito | Confirmación de añadido | "Producto añadido al carrito." | Ver carrito o seguir comprando | Confirmación poco visible |
| Cantidad inválida | Aviso en el selector de cantidad | "Introduce una cantidad válida." | Corregir la cantidad | Permitir continuar con cantidad inválida |

### 4.9 Mobile-First en PDP

- **Información crítica visible temprano**.
- **Botón de agregar al carrito** fácil de usar.
- **Precio y disponibilidad** visibles.
- **Cantidad fácil de editar**.
- **Descripción no excesivamente larga**.
- **Secciones colapsables** si aplica.
- **Evitar scroll innecesario** para completar la compra.

---

## 5. Consistencia entre PLP, PDP, Carrito y Checkout

- El producto **visible en PLP** debe ser **accesible en PDP**.
- El **precio mostrado en PLP** debe **coincidir** con PDP, carrito y checkout.
- El **stock mostrado** debe ser **coherente**.
- Si cambia el pricing, el stock o la visibilidad, **debe informarse**.
- El **carrito debe revalidar** antes del checkout.
- El **checkout** debe ser la **última validación** antes de la confirmación o la
  aprobación.

---

## 6. Relación con Reorder

- El reorder puede traer productos que **ya no están visibles**.
- El reorder puede traer productos con **precio actualizado**.
- El reorder puede traer productos **sin stock suficiente**.
- La UX debe **informar los cambios** claramente.
- El buyer debe poder **continuar con los productos válidos**.
- La PLP/PDP deben servir como **camino alternativo** para reemplazar productos no
  disponibles (coherente con `BR-REORDER-003`, `BR-REORDER-004`).

---

## 7. Mensajes UX Recomendados

Mensajes claros, no técnicos y orientados a la acción. Prioridad MVP: Alta /
Media / Baja.

| Escenario | Mensaje sugerido | Acción recomendada | Prioridad MVP |
| --- | --- | --- | --- |
| Sin productos visibles | "No hay productos disponibles en esta categoría para tu cuenta." | Explorar otras categorías | Alta |
| Sin resultados de búsqueda | "No encontramos productos para tu búsqueda." | Revisar términos o ver categorías | Alta |
| Producto sin stock suficiente | "Stock insuficiente para la cantidad solicitada." | Ajustar cantidad o ver alternativas | Alta |
| Producto no disponible para tu cuenta | "Este producto no está disponible para tu cuenta." | Volver al catálogo | Media |
| Precio no disponible | "El precio no está disponible en este momento." | Reintentar o volver más tarde | Media |
| Producto agregado al carrito | "Producto añadido al carrito." | Ver carrito o seguir comprando | Alta |
| Cantidad inválida | "Introduce una cantidad válida." | Corregir la cantidad | Alta |
| Error al cargar productos | "No pudimos cargar los productos. Inténtalo de nuevo." | Reintentar | Alta |
| Producto eliminado o no visible durante reorder | "Algunos productos de tu pedido anterior ya no están disponibles." | Continuar con los válidos o buscar alternativa | Alta |
| Pricing actualizado | "El precio de algunos productos se ha actualizado." | Revisar antes de confirmar | Media |

---

## 8. Riesgos UX en PLP/PDP

- Mostrar productos que el buyer **no debería ver**.
- Mostrar **precios inconsistentes**.
- **Ocultar el stock insuficiente**.
- **Saturar la PLP** con información irrelevante.
- Diseñar una **PDP demasiado promocional / B2C**.
- Forzar **demasiados clicks** para compras recurrentes.
- **No contemplar** los estados empty, error y loading.
- Crear **LWC custom antes de validar** el estándar de Salesforce.

---

## 9. Supuestos Actuales

- El buyer está **autenticado** para ver el pricing aplicable.
- La **visibilidad** depende de la cuenta o el Buyer Group.
- El **pricing** depende de la cuenta o el Buyer Group.
- El **stock real** queda fuera del MVP.
- La experiencia debe funcionar en **desktop y mobile**.
- Se usarán **componentes estándar** siempre que sea posible.
- Los **productos del MVP** serán pocos y representativos.

---

## 10. Decisiones Pendientes

- Nivel de filtros en PLP.
- Ordenamiento por defecto.
- Campos definitivos visibles en PLP.
- Campos definitivos visibles en PDP.
- Mensajes UX finales.
- Si se permitirá agregar al carrito desde PLP.
- Si habrá productos relacionados.
- Si habrá productos alternativos ante stock insuficiente.
- Si se mostrarán cantidades mínimas.
- Necesidad real de LWC custom.

---

## 11. Criterios de Validación UX

- [ ] El buyer entiende qué productos puede comprar.
- [ ] El buyer ve precios claros.
- [ ] El buyer distingue productos disponibles y no disponibles.
- [ ] PLP y PDP son consistentes.
- [ ] Mobile es usable.
- [ ] Los mensajes no son técnicos.
- [ ] Los estados empty, error y loading están contemplados.
- [ ] No se propone customización sin justificación.

---

## 12. Relación con Otros Documentos

- `docs/ux/ux-principles.md` define los **principios UX generales**.
- `docs/ux/storefront-journey.md` define el **journey completo**.
- Este documento **profundiza en PLP y PDP**.
- `docs/business/product-catalog-strategy.md` define **categorías y productos**.
- `docs/business/pricing-and-visibility-strategy.md` define el **comportamiento
  funcional de pricing y visibilidad**.
- `docs/business/business-rules.md` define las **reglas de negocio**.
- `docs/business/b2b-commerce-flows.md` define los **flujos funcionales**.
- `docs/ux/cart-checkout-experience.md` **profundizará en carrito y checkout**.
- `docs/ux/empty-error-loading-states.md` **profundizará en estados transversales**.
- `docs/architecture/` documentará las **decisiones técnicas**.
- `docs/salesforce/` documentará la **configuración y las capacidades estándar**.
- `evals/` podrá **evaluar** si los agentes respetan estas guidelines.
