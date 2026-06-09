# Experiencia de Carrito y Checkout - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define las **guidelines funcionales y UX** para el carrito y el
checkout del storefront B2B de LvlUp WholeSale. Describe comportamiento esperado,
no implementación técnica ni layout visual final.

Sirve como base para:

- Diseño de la experiencia de compra.
- Configuración de Experience Builder.
- Evaluación de las capacidades estándar de Salesforce B2B Commerce.
- Decisiones futuras de Flow, Apex o LWC custom.
- Testing funcional.
- Evaluaciones de agentes de IA.
- Validación de pricing, stock, visibilidad, aprobación y crédito.

Se alinea con `docs/ux/ux-principles.md`, `docs/ux/storefront-journey.md`,
`docs/ux/plp-pdp-guidelines.md` y los documentos de `docs/business/`, y aplica el
principio rector del proyecto: *Configuration first, customization only when
justified*.

---

## 2. Principios Generales

- El carrito debe ser **claro, editable y confiable**.
- El checkout debe **minimizar la fricción**.
- El buyer debe poder **revisar productos, cantidades, precios e importes** antes
  de confirmar.
- **No debe haber sorpresas de precio** en el checkout.
- El pricing, el stock y la visibilidad deben **revalidarse antes de confirmar**.
- El sistema debe **diferenciar pedido confirmado de solicitud pendiente**.
- Los mensajes de **aprobación, crédito y stock** deben ser claros y accionables.
- **Mobile-first** y responsive.
- Priorizar el **estándar de Salesforce B2B Commerce** antes que la customización.

---

## 3. Objetivo del Carrito

El carrito permite al comprador **revisar y ajustar su intención de compra** antes
de iniciar el checkout.

Debe permitir:

- Ver los productos agregados.
- Ver las cantidades.
- Ver los precios aplicables.
- Ver los subtotales.
- Modificar cantidades.
- Eliminar productos.
- Continuar comprando.
- Avanzar a checkout.
- Detectar restricciones funcionales.

---

## 4. Información Mínima en Carrito

**Por línea de carrito:**

- Imagen o placeholder.
- Nombre del producto.
- SKU si resulta útil.
- Cantidad.
- Precio unitario aplicable.
- Subtotal.
- Disponibilidad funcional si aplica.
- Mensajes de restricción si existen.
- Acción para modificar la cantidad.
- Acción para eliminar el producto.

**A nivel total:**

- Subtotal funcional.
- Total funcional.
- Mensaje si podría requerir aprobación por importe.
- Mensaje si existen productos con restricciones.
- Acción para continuar a checkout.

---

## 5. Acciones del Carrito

| Acción | Resultado esperado | Riesgo UX | Consideración mobile-first |
| --- | --- | --- | --- |
| Modificar cantidad | Recalcular subtotal y revalidar stock/pricing | No reflejar el cambio de inmediato | Selector de cantidad táctil y simple |
| Eliminar producto | Quitar la línea y actualizar el total | Eliminación accidental sin confirmación | Botón claro, con deshacer si es posible |
| Vaciar carrito (si aplica) | Carrito vacío con estado claro | Vaciado accidental | Confirmar antes de vaciar |
| Continuar comprando | Volver al catálogo manteniendo el carrito | Perder el contexto del carrito | Acceso visible sin perder el carrito |
| Ir a checkout | Avanzar tras revalidar el carrito | Avanzar con restricciones sin avisar | Botón de checkout siempre visible |
| Resolver productos con problemas | Guiar a ajustar cantidad, eliminar o sustituir | No indicar cómo resolver | Mensaje accionable junto a la línea |
| Revisar mensajes de stock/pricing/visibilidad | Comprender restricciones antes de avanzar | Mensajes poco claros o técnicos | Mensajes legibles sin saturar |

---

## 6. Validaciones Funcionales en Carrito

- El producto **sigue visible** para el buyer.
- El producto **sigue activo / comprable**.
- La **cantidad es válida**.
- Hay **stock suficiente** si aplica.
- El **pricing aplicable** está disponible.
- El **precio es consistente** con PLP/PDP.
- El producto está **permitido** para la cuenta o el Buyer Group.
- El producto **proveniente de reorder** sigue siendo válido.

Las validaciones exactas dependerán de las capacidades estándar o de decisiones
técnicas futuras (coherente con `BR-CART-005`, `PV-*`, `PR-003`).

---

## 7. Estados del Carrito

| Estado | Qué ve el comprador | Mensaje UX recomendado | Acción siguiente | Riesgo UX |
| --- | --- | --- | --- | --- |
| Carrito vacío | Estado vacío explicado | "Tu carrito está vacío." | Ir al catálogo | Parecer un error |
| Con productos válidos | Líneas, importes y total claros | — | Avanzar a checkout | Sobrecarga visual |
| Producto sin stock suficiente | Línea con aviso de disponibilidad | "Stock insuficiente para la cantidad solicitada." | Ajustar cantidad o ver alternativas | Ocultar el problema hasta checkout |
| Producto no visible / no permitido | Línea marcada como no disponible | "Este producto ya no está disponible para tu cuenta." | Eliminar la línea | Permitir avanzar con la línea inválida |
| Pricing actualizado | Aviso de cambio de precio | "El precio de algunos productos se ha actualizado." | Revisar antes de confirmar | Sorpresa de precio en checkout |
| Cantidad inválida | Aviso en el selector de cantidad | "Introduce una cantidad válida." | Corregir la cantidad | Permitir continuar con cantidad inválida |
| Posible aprobación por importe | Aviso a nivel total | "Este pedido podría requerir aprobación por su importe." | Continuar a checkout sabiendo que no es confirmación final | Creer que ya está confirmado |
| Error al cargar | Mensaje de error | "No pudimos cargar tu carrito. Inténtalo de nuevo." | Reintentar | Mensaje técnico |
| Loading | Indicador de carga | "Cargando tu carrito…" | Esperar | Pantalla congelada |

---

## 8. Carrito Mobile-First

- **Líneas de carrito legibles**.
- **Botones táctiles** claros.
- **Edición de cantidad** sencilla.
- **Precio y subtotal** visibles.
- Mensajes de restricción **no invasivos pero claros**.
- **Evitar tablas complejas** en mobile.
- Acción de **checkout visible**.
- **Reducir scroll** innecesario.

---

## 9. Objetivo del Checkout

El checkout permite **revisar y completar la intención de compra**, generando un
**pedido confirmado** o una **solicitud pendiente** según las reglas funcionales.

Debe permitir:

- Revisar productos.
- Revisar cantidades.
- Revisar importes.
- Validar restricciones.
- Confirmar el pedido cuando aplique.
- Derivar a aprobación cuando aplique.
- Informar el bloqueo por crédito cuando aplique.
- Informar el stock insuficiente cuando aplique.

---

## 10. Información Mínima en Checkout

- Resumen del pedido.
- Productos y cantidades.
- Precios aplicables.
- Subtotales.
- Total funcional.
- Estado de las validaciones funcionales.
- Mensaje si requiere aprobación.
- Mensaje si el crédito impide continuar.
- Mensaje si hay stock insuficiente.
- Acción de confirmar o enviar solicitud.
- Acción de volver al carrito.

Los **pagos reales, el tax real y el shipping real están fuera del MVP**
(coherente con `BR-CHECKOUT-004`).

---

## 11. Validaciones Funcionales en Checkout

- Carrito válido.
- Productos visibles.
- Productos activos / comprables.
- Pricing vigente.
- Stock suficiente si aplica.
- Límite o estado de crédito.
- Umbral de aprobación por importe.
- Consistencia del total funcional.

El checkout debe ser la **última barrera funcional** antes de confirmar o generar
un estado pendiente.

---

## 12. Resultado del Checkout

### Pedido Confirmado

- El pedido cumple las condiciones funcionales.
- El comprador recibe una **confirmación clara**.
- El pedido debe poder **consultarse en el historial** (`BR-HISTORY-001`).

### Solicitud Pendiente de Aprobación

- El importe supera el umbral o la regla aplicable.
- El comprador entiende que **no es una confirmación final**.
- El **estado pendiente** debe ser claro.
- El **umbral exacto** queda pendiente de definición.

### Bloqueo o Condicionamiento por Crédito

- El crédito bloqueado/excedido **impide o condiciona** la compra.
- El mensaje debe ser **funcional y accionable**.
- Las **reglas exactas** quedan pendientes.

### Stock Insuficiente

- El pedido **no puede confirmarse** tal como está.
- El comprador puede **ajustar la cantidad, volver al carrito o buscar una
  alternativa** si aplica.

### Error Funcional

- El sistema informa el problema **sin lenguaje técnico**.
- Se ofrece una **acción siguiente**.

---

## 13. Checkout con Aprobación por Importe

- **Cuándo se activa.** Cuando el importe del pedido supera el umbral aplicable.
- **Qué debe entender el comprador.** Que el pedido **no queda confirmado** y pasa
  a aprobación.
- **Diferencia clave.** Enviar una **solicitud** no es lo mismo que **confirmar un
  pedido**.
- **Mensaje esperado.** "Este pedido supera el importe permitido y requiere
  aprobación."
- **Estado esperado.** Solicitud pendiente, diferenciada del pedido confirmado.
- **Acciones siguientes.** Enviar solicitud; consultar estado; volver al carrito.
- **Decisiones pendientes.** Umbral exacto; aprobador; nivel de automatización;
  estado funcional exacto (coherente con `BR-APPROVAL-001…006`).

---

## 14. Checkout con Validación de Crédito

- **Cuándo se valida.** Al intentar confirmar el pedido.
- **Si el crédito es válido.** El flujo continúa con normalidad.
- **Si el crédito está bloqueado o excedido.** El pedido se impide o se condiciona.
- **Mensaje esperado.** "No es posible confirmar el pedido por el estado de crédito
  de tu cuenta."
- **Acciones siguientes.** Revisar con el contacto comercial; volver al carrito.
- **Decisiones pendientes.** Fuente del dato de crédito; regla exacta; si bloquea o
  condiciona; integración simulada futura (coherente con `BR-CREDIT-001…005`).

---

## 15. Checkout con Stock Insuficiente

- **Cuándo se detecta.** Al revalidar el stock antes de confirmar.
- **Mensaje a mostrar.** "Algunos productos no tienen stock suficiente para la
  cantidad solicitada."
- **Acciones del comprador.** Ajustar la cantidad; volver al carrito; buscar una
  alternativa si aplica.
- **Decisiones pendientes.** Permitir backorder; mostrar ETA; sugerir alternativas;
  permitir pedido parcial (coherente con `BR-STOCK-003`).

---

## 16. Relación con Reorder

- El reorder puede **poblar el carrito** con productos anteriores.
- El carrito debe **revalidar** los productos provenientes de reorder.
- El checkout debe **validar pricing, stock y visibilidad actuales**.
- Los productos **no válidos** deben informarse antes de confirmar.
- El buyer debe poder **continuar con los productos válidos** si aplica
  (coherente con `BR-REORDER-003`, `BR-REORDER-004`).

---

## 17. Mensajes UX Recomendados

Mensajes claros, no técnicos y orientados a la acción. Prioridad MVP: Alta /
Media / Baja.

| Escenario | Mensaje sugerido | Acción recomendada | Prioridad MVP |
| --- | --- | --- | --- |
| Carrito vacío | "Tu carrito está vacío." | Ir al catálogo | Alta |
| Producto agregado correctamente | "Producto añadido al carrito." | Ver carrito o seguir comprando | Alta |
| Cantidad inválida | "Introduce una cantidad válida." | Corregir la cantidad | Alta |
| Producto sin stock suficiente | "Stock insuficiente para la cantidad solicitada." | Ajustar cantidad o ver alternativas | Alta |
| Producto ya no disponible | "Este producto ya no está disponible." | Eliminar del carrito o buscar alternativa | Alta |
| Producto ya no visible para tu cuenta | "Este producto ya no está disponible para tu cuenta." | Eliminar del carrito | Media |
| Precio actualizado | "El precio de algunos productos se ha actualizado." | Revisar antes de confirmar | Media |
| Pedido requiere aprobación | "Este pedido supera el importe permitido y requiere aprobación." | Enviar solicitud de aprobación | Alta |
| Crédito bloqueado o excedido | "No es posible confirmar el pedido por el estado de crédito de tu cuenta." | Revisar con tu contacto comercial | Media |
| Pedido confirmado | "Pedido confirmado." | Ver pedido o volver al catálogo | Alta |
| Solicitud pendiente | "Solicitud enviada. Tu pedido queda pendiente de aprobación." | Consultar estado en el historial | Alta |
| Error al cargar carrito | "No pudimos cargar tu carrito. Inténtalo de nuevo." | Reintentar | Alta |
| Error durante checkout | "Ocurrió un problema al procesar tu pedido. Inténtalo de nuevo." | Reintentar o volver al carrito | Alta |

---

## 18. Riesgos UX en Carrito y Checkout

- Mostrar **precios inconsistentes**.
- **No avisar restricciones** hasta demasiado tarde.
- **Confundir** pedido confirmado con solicitud pendiente.
- **Ocultar problemas de crédito**.
- **Ocultar stock insuficiente**.
- Hacer el **checkout mobile** difícil de usar.
- **Sobrecargar el checkout** con pasos innecesarios.
- Intentar implementar **pagos/tax/shipping reales** dentro del MVP.
- **Customizar antes de validar** el estándar de Salesforce.

---

## 19. Supuestos Actuales

- El buyer está **autenticado**.
- El carrito opera sobre **productos visibles y permitidos**.
- El **pricing** depende de la cuenta o el Buyer Group.
- El **stock real** queda fuera del MVP.
- La **validación de crédito** puede documentarse antes de automatizarse por
  completo.
- La **aprobación por importe** puede documentarse antes de automatizarse por
  completo.
- El **checkout del MVP** no incluye pagos, tax ni shipping reales.
- Se usarán **componentes estándar** siempre que sea posible.

---

## 20. Decisiones Pendientes

- Umbral de aprobación.
- Estado funcional exacto de la solicitud pendiente.
- Reglas exactas de crédito.
- Comportamiento ante stock insuficiente.
- Si se permitirá backorder.
- Si se permitirá pedido parcial.
- Si se mostrará ETA.
- Mensajes UX finales.
- Necesidad real de LWC custom.
- Nivel de automatización con Flow/Apex.

---

## 21. Criterios de Validación UX

- [ ] El buyer entiende qué productos está comprando.
- [ ] El buyer puede modificar cantidades fácilmente.
- [ ] El buyer ve precios claros y consistentes.
- [ ] El buyer entiende las restricciones de stock.
- [ ] El buyer entiende si requiere aprobación.
- [ ] El buyer distingue pedido confirmado de solicitud pendiente.
- [ ] El buyer entiende los problemas de crédito.
- [ ] El checkout es usable en mobile.
- [ ] Los mensajes son claros y no técnicos.
- [ ] No se propone customización sin justificación.

---

## 22. Relación con Otros Documentos

- `docs/ux/ux-principles.md` define los **principios UX generales**.
- `docs/ux/storefront-journey.md` define el **journey completo**.
- `docs/ux/plp-pdp-guidelines.md` **profundiza en PLP/PDP**.
- Este documento **profundiza en carrito y checkout**.
- `docs/ux/empty-error-loading-states.md` **profundizará en estados transversales**.
- `docs/business/business-rules.md` define las **reglas de negocio**.
- `docs/business/b2b-commerce-flows.md` define los **flujos funcionales**.
- `docs/business/pricing-and-visibility-strategy.md` define el **pricing y la
  visibilidad**.
- `docs/business/mvp-scope.md` delimita el **MVP**.
- `docs/architecture/` documentará las **decisiones técnicas**.
- `docs/salesforce/` documentará las **capacidades y la configuración** de
  Salesforce.
- `evals/` podrá **evaluar** si los agentes respetan estas guidelines.
