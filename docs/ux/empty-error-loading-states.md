# Estados Empty, Error y Loading - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define cómo deben comportarse los **estados transversales** del
storefront B2B de LvlUp WholeSale: empty, error, loading, pending, restricted,
unavailable y validation. Describe comportamiento y microcopy esperados, no
implementación técnica ni componentes concretos.

Sirve como base para:

- UX del storefront.
- PLP, PDP, Carrito, Checkout.
- Historial y Reorder.
- Solicitud de aprobación.
- Mensajes funcionales.
- Testing funcional.
- Evaluaciones de agentes de IA.
- Futuras decisiones de configuración o customización.

Se alinea con el resto de `docs/ux/` y con los documentos de `docs/business/`, y
aplica el principio rector del proyecto: *Configuration first, customization only
when justified*.

---

## 2. Principios Generales de Estados UX

- Todo estado debe **explicar qué ocurre**.
- Todo estado debe **ofrecer una acción siguiente** cuando sea posible.
- **Evitar mensajes técnicos**.
- **No culpar al usuario**.
- Mantener un **tono profesional y claro**.
- **Diferenciar** error, vacío, pendiente, restringido y no disponible.
- **No ocultar** problemas de pricing, stock, visibilidad, crédito o aprobación.
- **Mobile-first** y responsive.
- Priorizar **componentes estándar** antes que UI custom.

---

## 3. Tipos de Estados

### Loading

- **Definición.** El sistema está cargando o procesando información.
- **Cuándo usarlo.** Mientras se obtienen datos o se procesa una acción.
- **Cuándo no usarlo.** Para esconder un error o un estado vacío.
- **Riesgo UX.** Pantallas congeladas sin feedback.

### Empty

- **Definición.** No hay contenido que mostrar.
- **Cuándo usarlo.** Catálogo, búsqueda, historial o carrito sin elementos.
- **Cuándo no usarlo.** Cuando en realidad ha ocurrido un error.
- **Riesgo UX.** Confundir vacío con error.

### Error

- **Definición.** Algo ha fallado.
- **Cuándo usarlo.** Fallos de carga o de proceso.
- **Cuándo no usarlo.** Para condiciones funcionales esperadas (stock, crédito).
- **Riesgo UX.** Mensajes técnicos o sin acción.

### Pending

- **Definición.** Una acción quedó pendiente de aprobación, cotización o
  validación.
- **Cuándo usarlo.** Pedido pendiente de aprobación; cotización enviada.
- **Cuándo no usarlo.** Para indicar éxito final.
- **Riesgo UX.** Confundir pendiente con confirmado.

### Restricted

- **Definición.** El buyer no tiene acceso a un producto, categoría o información.
- **Cuándo usarlo.** Acceso directo a algo no permitido para su cuenta.
- **Cuándo no usarlo.** Para productos que simplemente no deben mostrarse (no se
  listan, no se "explica" la restricción).
- **Riesgo UX.** Exponer la existencia de lo restringido.

### Unavailable

- **Definición.** Algo existe pero no está disponible para compra o uso.
- **Cuándo usarlo.** Producto inactivo o temporalmente no comprable.
- **Cuándo no usarlo.** Cuando el producto sí es comprable pero falta stock (eso es
  un estado de stock).
- **Riesgo UX.** Permitir acciones sobre algo no disponible.

### Validation

- **Definición.** Una acción no puede continuar por una condición funcional.
- **Cuándo usarlo.** Cantidad inválida; carrito con líneas no válidas.
- **Cuándo no usarlo.** Para errores de sistema.
- **Riesgo UX.** No indicar cómo corregir.

---

## 4. Guidelines de Mensajes

Principios para los mensajes:

- **Claros**, **breves** y **accionables**.
- **Sin lenguaje técnico interno** ni exposición de configuración o reglas
  internas.
- **Adaptados al contexto B2B**.
- **Consistentes** entre pantallas.
- **Diferenciando causa y acción** recomendada.

**Estructura recomendada:**

1. Qué ocurrió.
2. Por qué importa.
3. Qué puede hacer el comprador.

**Ejemplo.** "Este producto no tiene stock suficiente para la cantidad solicitada.
Ajusta la cantidad o revisa productos alternativos."

---

## 5. Estados en Login y Acceso

| Estado | Qué ve el comprador | Mensaje recomendado | Acción siguiente | Riesgo UX | Prioridad MVP |
| --- | --- | --- | --- | --- | --- |
| Cargando login | Formulario en proceso | "Verificando tus credenciales…" | Esperar | Pantalla congelada | Alta |
| Credenciales incorrectas | Error en el formulario | "Email o contraseña incorrectos." | Reintentar o recuperar contraseña | Revelar qué campo falla | Alta |
| Sesión expirada | Aviso y vuelta a login | "Tu sesión ha caducado. Inicia sesión de nuevo." | Volver a iniciar sesión | Perder trabajo sin avisar | Alta |
| Usuario sin acceso | Mensaje de no acceso | "Tu usuario no tiene acceso a este portal." | Contactar con tu contacto comercial | Culpar al usuario | Media |
| Error inesperado | Error accionable | "No pudimos iniciar sesión. Inténtalo de nuevo." | Reintentar | "Ha ocurrido un error" sin acción | Alta |
| Acceso correcto | Redirección a Home | — | Continuar | — | Alta |

---

## 6. Estados en Home

| Estado | Qué ve el comprador | Mensaje recomendado | Acción siguiente | Riesgo UX | Prioridad MVP |
| --- | --- | --- | --- | --- | --- |
| Home cargando | Indicador de carga | "Cargando…" | Esperar | Pantalla en blanco | Alta |
| Sin categorías destacadas | Navegación básica | "Explora nuestro catálogo." | Ir al catálogo | Parecer rota | Media |
| Error al cargar contenido | Error accionable | "No pudimos cargar el contenido. Inténtalo de nuevo." | Reintentar | Mensaje técnico | Media |
| Autenticado sin datos personalizados | Home funcional genérica | "Bienvenido. Explora tu catálogo." | Ir al catálogo o buscar | Confusión por falta de contexto | Baja |
| Navegación principal correcta | Accesos visibles | — | Navegar | — | Alta |

---

## 7. Estados en Catálogo / PLP

| Estado | Qué ve el comprador | Mensaje recomendado | Acción siguiente | Riesgo UX | Prioridad MVP |
| --- | --- | --- | --- | --- | --- |
| Cargando productos | Indicador de carga | "Cargando productos…" | Esperar | Pantalla congelada | Alta |
| Con productos visibles | Listado con precio y stock | — | Entrar a PDP | Saturación visual | Alta |
| Sin productos visibles | Estado vacío | "No hay productos disponibles en esta categoría para tu cuenta." | Explorar otras categorías | Parecer error | Alta |
| Sin resultados de búsqueda | Estado vacío | "No encontramos productos para tu búsqueda." | Revisar términos o ver categorías | Dejar sin salida | Alta |
| Filtros sin resultados | Estado vacío de filtros | "Ningún producto coincide con los filtros aplicados." | Ajustar o limpiar filtros | No ofrecer limpiar | Media |
| Error al cargar catálogo | Error accionable | "No pudimos cargar los productos. Inténtalo de nuevo." | Reintentar | Mensaje técnico | Alta |
| Productos restringidos | No aparecen | — | — | Exponer su existencia | Alta |
| Producto con stock insuficiente | Aviso de disponibilidad | "Stock insuficiente para la cantidad habitual." | Ajustar cantidad | Ocultar el problema | Media |
| Producto no comprable | Producto sin acción de compra | "Producto no disponible para compra en este momento." | Volver al catálogo | Permitir añadirlo | Media |

---

## 8. Estados en PDP

| Estado | Qué ve el comprador | Mensaje recomendado | Acción siguiente | Riesgo UX | Prioridad MVP |
| --- | --- | --- | --- | --- | --- |
| Cargando producto | Indicador de carga | "Cargando producto…" | Esperar | Pantalla congelada | Alta |
| Producto disponible | Detalle y acción de compra | — | Añadir al carrito | — | Alta |
| Stock insuficiente | Detalle con aviso | "Stock insuficiente para la cantidad solicitada." | Ajustar cantidad o ver alternativas | Ocultar hasta el carrito | Alta |
| No visible para la cuenta | Mensaje de no disponibilidad | "Este producto no está disponible para tu cuenta." | Volver al catálogo | Exponer un producto restringido | Media |
| Inactivo / no comprable | Detalle sin compra | "Producto no disponible actualmente." | Ver alternativas o volver | Permitir compra inactiva | Media |
| Precio no disponible | Detalle sin precio firme | "El precio no está disponible en este momento." | Reintentar o volver más tarde | Mostrar precio genérico erróneo | Media |
| Error al cargar PDP | Error accionable | "No pudimos cargar el producto. Inténtalo de nuevo." | Reintentar | Mensaje técnico | Alta |
| Cantidad inválida | Aviso en el selector | "Introduce una cantidad válida." | Corregir la cantidad | Permitir continuar | Alta |
| Producto agregado al carrito | Confirmación | "Producto añadido al carrito." | Ver carrito o seguir comprando | Confirmación poco visible | Alta |

---

## 9. Estados en Carrito

| Estado | Qué ve el comprador | Mensaje recomendado | Acción siguiente | Riesgo UX | Prioridad MVP |
| --- | --- | --- | --- | --- | --- |
| Cargando carrito | Indicador de carga | "Cargando tu carrito…" | Esperar | Pantalla congelada | Alta |
| Carrito vacío | Estado vacío | "Tu carrito está vacío." | Ir al catálogo | Parecer error | Alta |
| Productos válidos | Líneas e importes claros | — | Avanzar a checkout | Saturación | Alta |
| Stock insuficiente | Línea con aviso | "Stock insuficiente para la cantidad solicitada." | Ajustar cantidad o ver alternativas | Ocultar hasta checkout | Alta |
| Producto ya no visible | Línea no disponible | "Este producto ya no está disponible para tu cuenta." | Eliminar la línea | Avanzar con línea inválida | Media |
| Producto ya no disponible | Línea no disponible | "Este producto ya no está disponible." | Eliminar o buscar alternativa | Avanzar con línea inválida | Alta |
| Precio actualizado | Aviso de cambio | "El precio de algunos productos se ha actualizado." | Revisar antes de confirmar | Sorpresa de precio | Media |
| Cantidad inválida | Aviso en el selector | "Introduce una cantidad válida." | Corregir la cantidad | Continuar con cantidad inválida | Alta |
| Posible aprobación por importe | Aviso a nivel total | "Este pedido podría requerir aprobación por su importe." | Continuar a checkout | Creer que está confirmado | Media |
| Error al cargar carrito | Error accionable | "No pudimos cargar tu carrito. Inténtalo de nuevo." | Reintentar | Mensaje técnico | Alta |

---

## 10. Estados en Checkout

Los **pagos reales, el tax real y el shipping real están fuera del MVP**.

| Estado | Qué ve el comprador | Mensaje recomendado | Acción siguiente | Riesgo UX | Prioridad MVP |
| --- | --- | --- | --- | --- | --- |
| Cargando checkout | Indicador de carga | "Preparando tu pedido…" | Esperar | Pantalla congelada | Alta |
| Listo para confirmar | Resumen del pedido | — | Confirmar pedido | — | Alta |
| Pedido confirmado | Confirmación clara | "Pedido confirmado." | Ver pedido o volver al catálogo | — | Alta |
| Requiere aprobación | Aviso de aprobación | "Este pedido supera el importe permitido y requiere aprobación." | Enviar solicitud | Creer que está confirmado | Alta |
| Solicitud pendiente | Confirmación de envío | "Solicitud enviada. Tu pedido queda pendiente de aprobación." | Consultar estado en el historial | Confundir con confirmado | Alta |
| Crédito bloqueado o excedido | Aviso funcional | "No es posible confirmar el pedido por el estado de crédito de tu cuenta." | Revisar con tu contacto comercial | Mensaje técnico | Media |
| Stock insuficiente | Aviso funcional | "Algunos productos no tienen stock suficiente para la cantidad solicitada." | Ajustar cantidad o volver al carrito | Ocultar el problema | Alta |
| Producto no válido | Aviso por línea | "Algunos productos ya no son válidos para este pedido." | Volver al carrito | Confirmar con líneas inválidas | Alta |
| Error funcional | Error accionable | "Ocurrió un problema al procesar tu pedido. Inténtalo de nuevo." | Reintentar o volver al carrito | Mensaje técnico | Alta |
| Error inesperado | Error accionable | "Algo no funcionó. Inténtalo de nuevo en unos minutos." | Reintentar | "Error" sin acción | Media |

---

## 11. Estados en Historial de Pedidos

| Estado | Qué ve el comprador | Mensaje recomendado | Acción siguiente | Riesgo UX | Prioridad MVP |
| --- | --- | --- | --- | --- | --- |
| Cargando historial | Indicador de carga | "Cargando tus pedidos…" | Esperar | Pantalla congelada | Alta |
| Con pedidos | Listado con estado e importe | — | Ver detalle | — | Alta |
| Sin pedidos anteriores | Estado vacío | "Todavía no tienes pedidos." | Ir al catálogo | Parecer error | Media |
| Error al cargar | Error accionable | "No pudimos cargar tu historial. Inténtalo de nuevo." | Reintentar | Mensaje técnico | Media |
| Pedido no disponible | Mensaje de no disponibilidad | "Este pedido no está disponible." | Volver al historial | Mensaje técnico | Baja |
| Pedido pendiente | Estado "Pendiente" | "Pendiente de aprobación." | Ver detalle | Confundir con confirmado | Alta |
| Pedido confirmado | Estado "Confirmado" | "Confirmado." | Ver detalle o reorder | — | Alta |

---

## 12. Estados en Reorder

| Estado | Qué ve el comprador | Mensaje recomendado | Acción siguiente | Riesgo UX | Prioridad MVP |
| --- | --- | --- | --- | --- | --- |
| Cargando reorder | Indicador de carga | "Preparando tu pedido…" | Esperar | Pantalla congelada | Media |
| Reorder completo | Productos en el carrito | "Hemos añadido los productos de tu pedido anterior." | Revisar el carrito | — | Alta |
| Reorder parcial | Algunos excluidos | "Algunos productos no se pudieron añadir." | Revisar y continuar | No explicar cuáles | Alta |
| Producto ya no visible | Excluido | "Algunos productos ya no están disponibles para tu cuenta." | Buscar alternativa | Ocultar el cambio | Media |
| Producto sin stock | Aviso | "Algunos productos no tienen stock suficiente." | Ajustar cantidad | Ocultar el cambio | Media |
| Pricing actualizado | Aviso | "El precio de algunos productos se ha actualizado." | Revisar antes de confirmar | Sorpresa de precio | Media |
| Producto inactivo | Excluido | "Algunos productos ya no están disponibles." | Buscar alternativa | — | Media |
| Error al iniciar reorder | Error accionable | "No pudimos preparar el reorder. Inténtalo de nuevo." | Reintentar | Mensaje técnico | Media |

---

## 13. Estados en Solicitud de Aprobación

| Estado | Qué ve el comprador | Mensaje recomendado | Acción siguiente | Riesgo UX | Prioridad / Estado |
| --- | --- | --- | --- | --- | --- |
| Solicitud preparada | Resumen antes de enviar | "Este pedido requiere aprobación antes de confirmarse." | Enviar solicitud | Creer que está confirmado | MVP - Alta |
| Solicitud enviada | Confirmación de envío | "Solicitud enviada. Tu pedido queda pendiente de aprobación." | Consultar estado | — | MVP - Alta |
| Solicitud pendiente | Estado pendiente | "Pendiente de aprobación." | Esperar o consultar | Confundir con confirmado | MVP - Alta |
| Solicitud aprobada | Estado aprobado | "Tu pedido ha sido aprobado." | Ver pedido | — | Futuro |
| Solicitud rechazada | Estado rechazado | "Tu pedido no ha sido aprobado." | Revisar o contactar | — | Futuro |
| Error al enviar | Error accionable | "No pudimos enviar tu solicitud. Inténtalo de nuevo." | Reintentar | Mensaje técnico | MVP - Alta |
| Umbral no definido | (interno, no visible) | — | — | Inconsistencia funcional | Pendiente de decisión |

---

## 14. Estados en Solicitud de Cotización

| Estado | Qué ve el comprador | Mensaje recomendado | Acción siguiente | Riesgo UX | Prioridad / Estado |
| --- | --- | --- | --- | --- | --- |
| Cotización iniciada | Formulario de solicitud | "Solicita una cotización para condiciones especiales." | Completar y enviar | Confundir con pedido | MVP opcional - Media |
| Cotización enviada | Confirmación | "Hemos recibido tu solicitud de cotización." | Consultar estado | — | MVP opcional - Media |
| Cotización pendiente | Estado pendiente | "Cotización pendiente de respuesta." | Esperar | Confundir con pedido | MVP opcional - Media |
| Cotización aprobada | Estado listo | "Tu cotización está lista." | Revisar | — | Futuro |
| Cotización rechazada | Estado no completado | "Tu cotización no pudo completarse." | Contactar | — | Futuro |
| Error al enviar | Error accionable | "No pudimos enviar tu solicitud. Inténtalo de nuevo." | Reintentar | Mensaje técnico | MVP opcional - Media |

---

## 15. Estados de Crédito

| Estado | Qué ve el comprador | Mensaje recomendado | Acción siguiente | Riesgo UX | Prioridad / Estado |
| --- | --- | --- | --- | --- | --- |
| Crédito válido | Sin fricción | — | Continuar | — | MVP - Media |
| Crédito bloqueado | Aviso funcional | "No es posible confirmar el pedido por el estado de crédito de tu cuenta." | Contactar con tu contacto comercial | Mensaje técnico | MVP - Media |
| Crédito excedido | Aviso funcional | "El importe del pedido supera el crédito disponible de tu cuenta." | Ajustar el pedido o contactar | Mensaje técnico | MVP - Media |
| Pendiente de validación | Indicador de proceso | "Estamos validando el crédito de tu cuenta…" | Esperar | Pantalla congelada | MVP - Media |
| Error al validar crédito | Error accionable | "No pudimos validar el crédito. Inténtalo de nuevo." | Reintentar | Mensaje técnico | MVP - Media |
| No disponible (integración futura) | Comportamiento documentado | "La validación de crédito no está disponible por ahora." | Continuar según regla | Prometer algo no implementado | Futuro |

---

## 16. Estados de Stock

| Estado | Qué ve el comprador | Mensaje recomendado | Acción siguiente | Riesgo UX | Prioridad / Estado |
| --- | --- | --- | --- | --- | --- |
| Stock suficiente | Indicador disponible | — | Continuar | — | MVP - Alta |
| Stock insuficiente | Aviso de disponibilidad | "Stock insuficiente para la cantidad solicitada." | Ajustar cantidad | Ocultar el problema | MVP - Alta |
| Stock no disponible | Aviso de no disponibilidad | "Este producto no tiene stock disponible." | Buscar alternativa | Ocultar el problema | MVP - Media |
| Pendiente de integración simulada | Comportamiento documentado | — | — | Mostrar un dato no fiable | Futuro |
| Backorder | Disponible bajo pedido | "Disponible bajo pedido." | — | Prometer algo fuera del MVP | Futuro |
| ETA no disponible | Sin fecha estimada | — | — | Prometer una ETA | Futuro |
| Error al validar stock | Error accionable | "No pudimos comprobar la disponibilidad. Inténtalo de nuevo." | Reintentar | Mensaje técnico | MVP - Media |

---

## 17. Mensajes Recomendados por Categoría

Resumen consolidado de los mensajes clave (no exhaustivo; el detalle por estado
está en las secciones 5–16).

| Categoría | Escenario | Mensaje recomendado | Acción siguiente | Prioridad MVP |
| --- | --- | --- | --- | --- |
| Login | Credenciales incorrectas | "Email o contraseña incorrectos." | Reintentar o recuperar contraseña | Alta |
| Home | Error al cargar | "No pudimos cargar el contenido. Inténtalo de nuevo." | Reintentar | Media |
| PLP | Sin productos visibles | "No hay productos disponibles en esta categoría para tu cuenta." | Explorar otras categorías | Alta |
| PDP | Precio no disponible | "El precio no está disponible en este momento." | Reintentar o volver más tarde | Media |
| Carrito | Carrito vacío | "Tu carrito está vacío." | Ir al catálogo | Alta |
| Checkout | Pedido confirmado | "Pedido confirmado." | Ver pedido o volver al catálogo | Alta |
| Historial | Sin pedidos | "Todavía no tienes pedidos." | Ir al catálogo | Media |
| Reorder | Reorder parcial | "Algunos productos no se pudieron añadir." | Revisar y continuar | Alta |
| Aprobación | Solicitud pendiente | "Solicitud enviada. Tu pedido queda pendiente de aprobación." | Consultar estado | Alta |
| Cotización | Cotización enviada | "Hemos recibido tu solicitud de cotización." | Consultar estado | Media |
| Crédito | Crédito bloqueado | "No es posible confirmar el pedido por el estado de crédito de tu cuenta." | Contactar con tu contacto comercial | Media |
| Stock | Stock insuficiente | "Stock insuficiente para la cantidad solicitada." | Ajustar cantidad o ver alternativas | Alta |

---

## 18. Buenas Prácticas de Microcopy B2B

- Usar **lenguaje directo**.
- **Evitar tecnicismos internos**.
- Evitar mensajes genéricos como "Ha ocurrido un error" **sin acción**.
- **Explicar si el proceso está pendiente**.
- Usar **verbos de acción**.
- Mantener **consistencia**.
- **No prometer acciones fuera del MVP** (pagos, ETA, backorder).
- **No mencionar detalles técnicos** de Salesforce.

**Ejemplos buenos.**

- "Stock insuficiente para la cantidad solicitada. Ajusta la cantidad o revisa
  productos alternativos."
- "Tu pedido queda pendiente de aprobación. Puedes consultar su estado en tu
  historial."

**Ejemplos malos.**

- "Error 500." → técnico y sin acción.
- "Operación fallida." → genérico, sin causa ni acción.
- "El producto no cumple la entitlement policy del Buyer Group." → expone reglas
  internas y configuración.

---

## 19. Riesgos UX Transversales

- **No diferenciar** error de estado vacío.
- **No diferenciar** pendiente de confirmado.
- Mostrar **mensajes técnicos**.
- **Ocultar restricciones de stock**.
- **Ocultar problemas de crédito**.
- **Mostrar productos restringidos**.
- **No ofrecer acción siguiente**.
- **Bloquear al comprador sin explicación**.
- Crear **LWC custom solo para mensajes** sin validar el estándar.
- **No considerar mobile**.

---

## 20. Criterios de Validación UX

- [ ] Cada estado explica qué ocurre.
- [ ] Cada estado ofrece una acción siguiente cuando aplica.
- [ ] Los mensajes son claros y no técnicos.
- [ ] Pending y confirmed están claramente diferenciados.
- [ ] Empty y error no se confunden.
- [ ] Stock, crédito, aprobación y visibilidad tienen mensajes claros.
- [ ] Mobile es usable.
- [ ] No se propone customización sin justificación.
- [ ] Los estados están alineados con las reglas de negocio y los flujos.

---

## 21. Supuestos Actuales

- El comprador está **autenticado** para la mayoría de estados del MVP.
- El MVP puede **documentar estados antes de implementarlos** por completo.
- El **stock real** y la **integración ERP** están fuera del MVP.
- El **crédito** puede simularse o documentarse antes de automatizarse.
- La **aprobación** puede documentarse antes de automatizarse por completo.
- Se priorizarán las **capacidades estándar** de Salesforce y Experience Builder.

---

## 22. Decisiones Pendientes

- Mensajes finales.
- Qué estados soporta el estándar de Salesforce B2B Commerce sin customización.
- Qué estados requieren configuración adicional.
- Qué estados podrían requerir Flow, Apex o LWC.
- Umbral de aprobación.
- Reglas exactas de crédito.
- Comportamiento final ante stock insuficiente.
- Si se permitirá backorder.
- Si se mostrará ETA.
- Si se permitirá pedido parcial.

---

## 23. Relación con Otros Documentos

- `docs/ux/ux-principles.md` define los **principios UX generales**.
- `docs/ux/storefront-journey.md` define el **journey completo**.
- `docs/ux/plp-pdp-guidelines.md` **profundiza en PLP/PDP**.
- `docs/ux/cart-checkout-experience.md` **profundiza en carrito/checkout**.
- Este documento **profundiza en estados empty, error, loading y relacionados**.
- `docs/business/business-rules.md` define las **reglas de negocio**.
- `docs/business/b2b-commerce-flows.md` define los **flujos funcionales**.
- `docs/business/pricing-and-visibility-strategy.md` define el **pricing y la
  visibilidad**.
- `docs/architecture/` documentará las **decisiones técnicas**.
- `docs/salesforce/` documentará las **capacidades y la configuración** de
  Salesforce.
- `evals/` podrá **evaluar** si los agentes respetan estos estados y mensajes.
