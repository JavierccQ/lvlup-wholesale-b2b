# Flujos B2B Commerce - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define los **flujos funcionales** principales del portal B2B
Commerce de LvlUp WholeSale. Sirve como base para el diseño de UX, la
arquitectura, el testing, los agentes de IA y las futuras historias de usuario.

Los flujos describen el **comportamiento funcional esperado**, no la
configuración técnica detallada. Se alinean con `docs/business/ecommerce-strategy.md`,
`docs/business/buyer-personas.md` y `docs/business/business-rules.md`, y aplican
el principio rector del proyecto: *Configuration first, customization only when
justified*. Cada flujo referencia las reglas de negocio relacionadas mediante sus
identificadores `BR-<CATEGORÍA>-NNN`.

---

## 2. Principios de Diseño de Flujos

- **Self-service B2B**: cada flujo debe permitir al comprador operar de forma
  autónoma, sin depender del representante de ventas.
- **Baja fricción en la recurrencia**: los flujos de compra repetida (reorder,
  checkout) deben minimizar pasos.
- **Claridad transversal**: pricing, stock, aprobación y crédito deben mostrarse de
  forma comprensible en todo momento.
- **Confirmado vs pendiente**: los flujos deben distinguir con claridad un pedido
  confirmado de una solicitud pendiente (aprobación, crédito, cotización).
- **Estándar primero**: se priorizan las capacidades estándar de Salesforce B2B
  Commerce antes que la customización.
- **Supuestos explícitos**: cuando una automatización no está definida, se
  documenta el comportamiento esperado y se marca como supuesto o decisión
  pendiente.

---

## 3. Mapa General de Flujos

| Flujo | Actor principal | Objetivo | Prioridad MVP | Dependencias funcionales | Estado |
| --- | --- | --- | --- | --- | --- |
| Login B2B | Comprador (Buyer User) | Acceder de forma autenticada a la experiencia B2B | Alta | Usuario buyer activo | Definido |
| Navegación de catálogo | Comprador | Explorar productos por categorías | Alta | Login, catálogo asignado | Definido |
| Búsqueda de productos | Comprador | Localizar productos rápidamente | Alta | Login, catálogo visible | Definido |
| Visualización de PLP | Comprador | Ver listado con precio y disponibilidad | Alta | Catálogo, pricing, stock | Definido |
| Visualización de PDP | Comprador | Ver detalle de producto | Alta | PLP, pricing, stock | Definido |
| Compra estándar | Comprador | Completar un pedido sin restricciones | Alta | Login, catálogo, pricing, stock, carrito, checkout | Definido |
| Compra con aprobación por importe | Comprador | Tramitar pedido que supera un umbral | Alta | Checkout, regla de aprobación | Definido (umbral pendiente) |
| Compra con stock insuficiente | Comprador | Gestionar falta de disponibilidad | Alta | Stock, carrito | Supuesto |
| Reorder | Comprador | Repetir una compra anterior | Alta | Historial, pricing, stock, visibilidad | Definido |
| Solicitud de cotización | Comprador | Pedir condiciones especiales | Media | Catálogo, login | Pendiente de decisión |
| Validación de límite de crédito | Comprador | Validar crédito antes de confirmar | Media | Checkout, dato de crédito | Pendiente de decisión |
| Catálogo restringido | Comprador | Ver solo productos permitidos | Alta | Login, Buyer Group | Definido |
| Pricing personalizado | Comprador | Ver precios negociados consistentes | Alta | Login, cuenta/Buyer Group | Definido (reglas pendientes) |
| Historial y detalle de pedidos | Comprador | Consultar pedidos y su detalle | Alta | Login, pedidos previos | Definido |

---

## 4. Flujo 1: Login B2B

**Objetivo.** Permitir que el comprador acceda de forma autenticada a la
experiencia B2B completa.

**Actor principal.** Comprador (Buyer User; único usuario operativo de la cuenta
en el MVP).

**Precondiciones.**
- Existe un usuario buyer activo asociado a una cuenta.
- La cuenta tiene catálogo y pricing asignados.

**Flujo principal.**
1. El comprador accede al storefront.
2. Introduce sus credenciales en el login.
3. El sistema valida la autenticación.
4. El comprador accede al Home con su contexto de cuenta cargado.

**Variantes o excepciones.**
- Credenciales inválidas: el sistema informa el error sin revelar detalles
  sensibles.
- Recuperación de contraseña: flujo estándar de reset.
- Usuario inactivo o sin cuenta válida: acceso denegado.

**Resultado esperado.** El comprador queda autenticado y ve la experiencia
personalizada para su cuenta (catálogo, pricing y visibilidad).

**Reglas relacionadas.** BR-ACCESS-001, BR-ACCESS-002, BR-ACCESS-003,
BR-ACCESS-004, BR-ACCESS-005, BR-ACCESS-006.

**Consideraciones UX.** Login claro, mensajes de error accionables, soporte
mobile-first y recuperación de contraseña visible.

**Consideraciones Salesforce B2B Commerce.** Se apoya en la autenticación estándar
del storefront de Experience Cloud y en la asociación del usuario a su cuenta y
Buyer Group, sin customización específica de autenticación.

**Estado MVP.** Definido.

---

## 5. Flujo 2: Navegación de Catálogo

**Objetivo.** Permitir al comprador explorar el catálogo por categorías.

**Actor principal.** Comprador.

**Precondiciones.**
- Comprador autenticado.
- Catálogo y categorías asignados a su cuenta/Buyer Group.

**Flujo principal.**
1. El comprador accede al catálogo desde el Home o el menú.
2. Visualiza las categorías de tecnología y gaming.
3. Selecciona una categoría.
4. El sistema muestra los productos visibles de esa categoría (PLP).

**Variantes o excepciones.**
- Categoría sin productos visibles: se muestra un estado vacío claro.
- Cuenta con catálogo restringido: solo se muestran las categorías y productos
  permitidos.

**Resultado esperado.** El comprador llega a una PLP con los productos visibles
para su cuenta.

**Reglas relacionadas.** BR-CATALOG-001, BR-CATALOG-002, BR-CATALOG-003,
BR-CATALOG-004, BR-CATALOG-005, BR-PRICING-001.

**Consideraciones UX.** Jerarquía de categorías clara, navegación rápida y
coherente en desktop y mobile.

**Consideraciones Salesforce B2B Commerce.** Se apoya en el Product Catalog,
ProductCategory y la visibilidad por Buyer Group estándar, sin entrar en
configuración concreta.

**Estado MVP.** Definido.

---

## 6. Flujo 3: Búsqueda de Productos

**Objetivo.** Permitir localizar productos rápidamente mediante búsqueda.

**Actor principal.** Comprador.

**Precondiciones.**
- Comprador autenticado.
- Catálogo visible para su cuenta.

**Flujo principal.**
1. El comprador introduce un término en el buscador.
2. El sistema devuelve resultados dentro del catálogo visible para su cuenta.
3. El comprador accede a la PLP de resultados o directamente a una PDP.

**Variantes o excepciones.**
- Sin resultados: estado vacío claro con sugerencia de reformular la búsqueda.
- Productos no visibles para la cuenta: no aparecen en los resultados.

**Resultado esperado.** El comprador encuentra productos relevantes y visibles
para su cuenta.

**Reglas relacionadas.** BR-CATALOG-003, BR-CATALOG-004, BR-UX-004, BR-UX-005.

**Consideraciones UX.** Búsqueda accesible y rápida, resultados claros y estados
loading/empty/error contemplados.

**Consideraciones Salesforce B2B Commerce.** Se apoya en la búsqueda estándar del
storefront respetando la visibilidad por Buyer Group.

**Estado MVP.** Definido.

---

## 7. Flujo 4: Visualización de PLP

**Objetivo.** Mostrar el listado de productos de una categoría o búsqueda con
precio y disponibilidad.

**Actor principal.** Comprador.

**Precondiciones.**
- Comprador autenticado.
- Pricing y stock resolubles para los productos listados.

**Flujo principal.**
1. El comprador accede a una PLP por navegación o búsqueda.
2. El sistema muestra los productos visibles con su precio aplicable y su
   disponibilidad.
3. El comprador puede filtrar u ordenar (según capacidades estándar disponibles).
4. El comprador selecciona un producto para ver su PDP.

**Variantes o excepciones.**
- Producto sin precio específico: se aplica la regla de pricing (no mostrar precio
  genérico si existe uno específico aplicable).
- Producto sin stock: se indica la disponibilidad insuficiente en la propia PLP.

**Resultado esperado.** El comprador comprende qué productos puede comprar, a qué
precio y con qué disponibilidad.

**Reglas relacionadas.** BR-CATALOG-003, BR-PRICING-001, BR-PRICING-003,
BR-STOCK-001, BR-UX-004.

**Consideraciones UX.** Información de precio y stock visible por ítem, carga
rápida y diseño responsive.

**Consideraciones Salesforce B2B Commerce.** Se apoya en los componentes estándar
de listado del storefront, con pricing por cuenta/Buyer Group y disponibilidad.

**Estado MVP.** Definido.

---

## 8. Flujo 5: Visualización de PDP

**Objetivo.** Mostrar el detalle de un producto con precio y disponibilidad.

**Actor principal.** Comprador.

**Precondiciones.**
- Comprador autenticado.
- Producto visible para su cuenta.

**Flujo principal.**
1. El comprador accede a la PDP desde PLP o búsqueda.
2. El sistema muestra la información del producto, su precio aplicable y su
   disponibilidad.
3. El comprador selecciona cantidad.
4. El comprador agrega el producto al carrito.

**Variantes o excepciones.**
- Stock insuficiente para la cantidad pedida: se informa y se condiciona el añadir
  al carrito (ver Flujo 8).
- Producto no visible: no es accesible (deriva en error o no aparece).

**Resultado esperado.** El comprador dispone de la información necesaria para
decidir y, si procede, añade el producto al carrito.

**Reglas relacionadas.** BR-PRICING-001, BR-PRICING-003, BR-STOCK-001,
BR-CART-001, BR-UX-004.

**Consideraciones UX.** Precio y stock claramente visibles, selección de cantidad
sencilla y llamada a la acción evidente.

**Consideraciones Salesforce B2B Commerce.** Se apoya en el componente estándar de
detalle de producto del storefront, respetando pricing y visibilidad.

**Estado MVP.** Definido.

---

## 9. Flujo 6: Compra Estándar

**Objetivo.** Permitir completar un pedido sin restricciones de aprobación,
crédito ni stock.

**Actor principal.** Comprador.

**Precondiciones.**
- Comprador autenticado.
- Productos visibles, con precio aplicable y stock suficiente.

**Flujo principal.**
1. El comprador inicia sesión.
2. Navega o busca productos.
3. Accede a PLP.
4. Accede a PDP.
5. Visualiza precio y disponibilidad.
6. Agrega productos al carrito.
7. Revisa el carrito.
8. Inicia el checkout.
9. Revisa los datos del pedido.
10. Confirma el pedido.
11. Visualiza la confirmación.
12. Puede consultar el pedido en el historial.

**Variantes o excepciones.**
- El importe supera el umbral: deriva al Flujo 7 (aprobación).
- Stock insuficiente: deriva al Flujo 8.
- Crédito insuficiente: deriva al Flujo 11.

**Resultado esperado.** Pedido confirmado y registrado, visible en el historial.

**Reglas relacionadas.** BR-ACCESS-001, BR-PRICING-001, BR-STOCK-001, BR-STOCK-002,
BR-CART-002, BR-CART-005, BR-CHECKOUT-001, BR-CHECKOUT-002, BR-CHECKOUT-003,
BR-CHECKOUT-005, BR-HISTORY-001.

**Consideraciones UX.** Flujo fluido y sin fricción innecesaria, resumen claro
antes de confirmar y confirmación inequívoca.

**Consideraciones Salesforce B2B Commerce.** Se apoya en el carrito y el checkout
estándar del storefront; pagos, tax y shipping reales quedan fuera del MVP.

**Estado MVP.** Definido.

---

## 10. Flujo 7: Compra con Aprobación por Importe

**Objetivo.** Gestionar pedidos cuyo importe supera un umbral y requieren
aprobación.

**Actor principal.** Comprador (rol aprobador como consideración futura).

**Precondiciones.**
- Comprador autenticado con un carrito completado.
- Existe una regla de aprobación por importe.

**Flujo principal.**
1. El comprador completa un carrito.
2. El importe supera un umbral de aprobación.
3. El sistema identifica que el pedido requiere aprobación.
4. El comprador visualiza un mensaje claro.
5. El pedido o solicitud queda en estado pendiente.
6. La confirmación final queda condicionada a la aprobación.

**Variantes o excepciones.**
- Importe por debajo del umbral: continúa como compra estándar (Flujo 6).
- Rechazo de la aprobación: el pedido no se confirma y se informa al comprador.

**Resultado esperado.** El pedido queda en estado pendiente de aprobación y solo se
confirma tras ser aprobado.

**Reglas relacionadas.** BR-APPROVAL-001, BR-APPROVAL-002, BR-APPROVAL-003,
BR-APPROVAL-004, BR-APPROVAL-005, BR-APPROVAL-006, BR-CHECKOUT-003.

**Consideraciones UX.** Mensaje claro de "pendiente de aprobación", estado del
pedido visible y distinción evidente respecto a un pedido confirmado.

**Consideraciones Salesforce B2B Commerce.** El comportamiento se documenta a nivel
funcional; la automatización podrá apoyarse en capacidades declarativas estándar
cuando se defina, sin detallar configuración aquí.

**Decisiones pendientes.**
- Umbral exacto de importe.
- Responsable aprobador (rol y asignación).
- Nivel de automatización del flujo.

**Estado MVP.** Definido a nivel funcional; automatización pendiente de decisión.

---

## 11. Flujo 8: Compra con Stock Insuficiente

**Objetivo.** Gestionar el escenario en el que un producto no tiene stock
suficiente.

**Actor principal.** Comprador.

**Precondiciones.**
- Comprador autenticado visualizando un producto o el carrito.

**Flujo principal.**
1. El comprador visualiza un producto.
2. El producto no tiene stock suficiente para la cantidad deseada.
3. El sistema informa la disponibilidad insuficiente de forma clara.
4. El comprador puede ajustar la cantidad, buscar una alternativa o abandonar la
   compra.

**Variantes o excepciones.**
- Stock parcial: se informa la cantidad disponible.
- Stock que cambia durante la sesión: se revalida antes de confirmar.

**Resultado esperado.** El comprador entiende la situación y no puede confirmar una
cantidad no satisfacible.

**Reglas relacionadas.** BR-STOCK-001, BR-STOCK-003, BR-STOCK-004, BR-STOCK-005,
BR-STOCK-006, BR-CART-005.

**Consideraciones UX.** Mensaje claro y accionable, opciones evidentes (ajustar
cantidad o buscar alternativa) y estados coherentes en PLP, PDP y carrito.

**Consideraciones Salesforce B2B Commerce.** El dato de stock se gestiona con
capacidades estándar hasta habilitar la simulación por REST / Postman Mock Server;
la integración real con ERP queda fuera del MVP.

**Decisiones pendientes.**
- Si se permitirá backorder.
- Si se ofrecerán productos alternativos.
- Si se mostrará una fecha estimada de entrega.

**Estado MVP.** Supuesto (comportamiento exacto por confirmar).

---

## 12. Flujo 9: Reorder

**Objetivo.** Permitir repetir una compra anterior reduciendo pasos.

**Actor principal.** Comprador.

**Precondiciones.**
- Comprador autenticado.
- Existe al menos un pedido anterior.

**Flujo principal.**
1. El comprador accede al historial de pedidos.
2. Selecciona un pedido anterior.
3. Elige repetir la compra.
4. El sistema valida disponibilidad, pricing y visibilidad actuales.
5. Los productos válidos se agregan al carrito.
6. Los productos no disponibles o no visibles se informan claramente.
7. El comprador continúa al checkout.

**Variantes o excepciones.**
- Cambios de precio respecto al pedido original: se aplica el pricing actual.
- Producto descatalogado o no visible: se excluye y se informa.

**Resultado esperado.** Se genera un nuevo carrito a partir de un pedido previo,
con precios y disponibilidad actualizados.

**Reglas relacionadas.** BR-REORDER-001, BR-REORDER-002, BR-REORDER-003,
BR-REORDER-004, BR-REORDER-005, BR-HISTORY-003, BR-CART-001.

**Consideraciones UX.** Reorder accesible desde el historial, resumen claro de qué
se añade y qué se excluye, y mínima fricción.

**Consideraciones Salesforce B2B Commerce.** Se apoya en el historial de pedidos y
en la recreación de carrito con revalidación de pricing y stock estándar.

**Estado MVP.** Definido.

---

## 13. Flujo 10: Solicitud de Cotización

**Objetivo.** Permitir solicitar condiciones especiales mediante una cotización.

**Actor principal.** Comprador (seller como rol que responde, futuro).

**Precondiciones.**
- Comprador autenticado.

**Flujo principal.**
1. El comprador identifica una necesidad especial.
2. El comprador solicita una cotización.
3. El sistema registra la solicitud.
4. La solicitud queda diferenciada de un pedido confirmado.
5. El comprador recibe feedback claro.

**Variantes o excepciones.**
- Solicitud incompleta: se informa de los datos necesarios.
- Conversión futura de cotización a pedido: consideración posterior.

**Resultado esperado.** Se registra una solicitud de cotización, claramente
distinta de un checkout confirmado.

**Reglas relacionadas.** BR-QUOTE-001, BR-QUOTE-002, BR-QUOTE-003, BR-QUOTE-004.

**Consideraciones UX.** El comprador entiende cuándo procede una cotización y la
diferencia de un pedido; feedback claro tras enviarla.

**Consideraciones Salesforce B2B Commerce.** Podrá apoyarse en capacidades estándar
relacionadas con quoting cuando se defina el alcance; no se detalla configuración.

**Decisiones pendientes.**
- Nivel de automatización.
- Campos requeridos de la solicitud.
- Si se implementa en el MVP o en una fase posterior.

**Estado MVP.** Pendiente de decisión.

---

## 14. Flujo 11: Validación de Límite de Crédito

**Objetivo.** Validar el estado de crédito del cliente antes de confirmar un
pedido.

**Actor principal.** Comprador (regla de negocio del seller).

**Precondiciones.**
- Comprador autenticado con un pedido en proceso de confirmación.

**Flujo principal.**
1. El comprador intenta confirmar un pedido.
2. El sistema valida el estado de crédito.
3. Si el crédito es válido, continúa el flujo.
4. Si el crédito está bloqueado o excedido, el sistema informa el motivo.
5. El pedido queda impedido o condicionado según la regla futura.

**Variantes o excepciones.**
- Crédito parcial: el pedido podría condicionarse o requerir revisión.
- Dato de crédito no disponible: comportamiento por definir.

**Resultado esperado.** Un pedido que supera el crédito disponible no se confirma
sin más; el comprador comprende el motivo.

**Reglas relacionadas.** BR-CREDIT-001, BR-CREDIT-002, BR-CREDIT-003, BR-CREDIT-004,
BR-CREDIT-005, BR-CHECKOUT-003.

**Consideraciones UX.** Mensaje claro del motivo del bloqueo y de los siguientes
pasos posibles.

**Consideraciones Salesforce B2B Commerce.** El estado de crédito podrá provenir de
una integración simulada futura (REST / Postman Mock Server); no se detalla
configuración.

**Decisiones pendientes.**
- Fuente del dato de crédito.
- Regla exacta de bloqueo o condición.
- Mensaje funcional al comprador.

**Estado MVP.** Pendiente de decisión.

---

## 15. Flujo 12: Catálogo Restringido

**Objetivo.** Mostrar a cada comprador solo los productos permitidos para su
cuenta o Buyer Group.

**Actor principal.** Comprador de una cuenta con catálogo restringido.

**Precondiciones.**
- Comprador autenticado.
- La cuenta/Buyer Group tiene definido un catálogo o conjunto de productos
  visibles.

**Flujo principal.**
1. El comprador inicia sesión.
2. El sistema determina el catálogo o los productos visibles para su cuenta/Buyer
   Group.
3. El comprador visualiza solo los productos permitidos.
4. Los productos restringidos no aparecen en PLP, búsqueda ni PDP.

**Variantes o excepciones.**
- Cambios en la asignación de catálogo: se reflejan en la visibilidad del
  comprador.
- Acceso directo a un producto restringido: no es accesible.

**Resultado esperado.** El comprador solo ve y compra productos permitidos para su
cuenta.

**Reglas relacionadas.** BR-ACCESS-001, BR-CATALOG-001, BR-CATALOG-002,
BR-CATALOG-003.

**Consideraciones UX.** Experiencia coherente: el comprador no percibe productos
que no le corresponden ni recibe errores confusos.

**Consideraciones Salesforce B2B Commerce.** Se apoya en la visibilidad por Buyer
Group y en los entitlements estándar de B2B Commerce, sin detallar configuración.

**Estado MVP.** Definido.

---

## 16. Flujo 13: Pricing Personalizado

**Objetivo.** Mostrar al comprador precios negociados consistentes en todo el
journey.

**Actor principal.** Comprador de una cuenta con pricing personalizado.

**Precondiciones.**
- Comprador autenticado.
- La cuenta/Buyer Group tiene pricing aplicable.

**Flujo principal.**
1. El comprador inicia sesión.
2. El sistema identifica su cuenta o Buyer Group.
3. El comprador visualiza el pricing aplicable.
4. El pricing se mantiene consistente en PLP, PDP, carrito y checkout.

**Variantes o excepciones.**
- Producto sin precio específico: se aplica la regla de pricing correspondiente.
- Diferencias de pricing por segmento: se resuelven según la asignación de la
  cuenta.

**Resultado esperado.** El comprador ve y compra a sus precios negociados, sin
inconsistencias entre vistas.

**Reglas relacionadas.** BR-PRICING-001, BR-PRICING-002, BR-PRICING-003,
BR-PRICING-004.

**Consideraciones UX.** Precio coherente y visible en todas las etapas; sin saltos
de precio entre PLP, PDP, carrito y checkout.

**Consideraciones Salesforce B2B Commerce.** Se apoya en el pricing por
cuenta/Buyer Group y en los Price Books estándar; la configuración concreta se
documentará en arquitectura.

**Decisiones pendientes.**
- Reglas exactas de pricing.
- Segmentos de clientes.
- Pricing por volumen (futuro).

**Estado MVP.** Definido a nivel funcional; reglas exactas pendientes.

---

## 17. Flujo 14: Historial y Detalle de Pedidos

**Objetivo.** Permitir consultar los pedidos anteriores y su detalle.

**Actor principal.** Comprador.

**Precondiciones.**
- Comprador autenticado.
- Existen pedidos previos asociados a la cuenta.

**Flujo principal.**
1. El comprador inicia sesión.
2. Accede al historial de pedidos.
3. Visualiza el listado de pedidos anteriores.
4. Accede al detalle de un pedido.
5. Puede usar el pedido como base para un reorder.

**Variantes o excepciones.**
- Sin pedidos previos: estado vacío claro.
- Pedido en estado pendiente (aprobación/crédito): se refleja su estado.

**Resultado esperado.** El comprador consulta sus pedidos y su detalle, y puede
iniciar un reorder desde ahí.

**Reglas relacionadas.** BR-HISTORY-001, BR-HISTORY-002, BR-HISTORY-003,
BR-HISTORY-004, BR-HISTORY-005, BR-REORDER-001.

**Consideraciones UX.** Listado claro con estados de pedido visibles, detalle
legible y acceso directo al reorder.

**Consideraciones Salesforce B2B Commerce.** Se apoya en el historial y el detalle
de pedidos estándar del storefront; no requiere un OMS avanzado en el MVP.

**Estado MVP.** Definido.

---

## 18. Matriz de Dependencias entre Flujos

| Flujo | Depende de | Habilita | Riesgo funcional |
| --- | --- | --- | --- |
| Login B2B | Usuario buyer activo | Catálogo personalizado, pricing, carrito, historial | Sin login no hay experiencia B2B personalizada |
| Navegación de catálogo | Login, catálogo asignado | PLP, búsqueda | Catálogo mal asignado expone u oculta productos indebidamente |
| Búsqueda de productos | Login, catálogo visible | PLP, PDP | Resultados que no respetan visibilidad |
| Visualización de PLP | Catálogo, pricing, stock | PDP, añadir al carrito | Precio o stock incorrecto induce a error de compra |
| Visualización de PDP | PLP, pricing, stock | Añadir al carrito | Inconsistencia de precio/stock frente a PLP |
| Compra estándar | Login, catálogo, pricing, stock, carrito, checkout | Pedido, historial | Fricción o error en checkout reduce conversión |
| Compra con aprobación por importe | Checkout, regla de aprobación | Pedido aprobado | Umbral no definido genera ambigüedad |
| Compra con stock insuficiente | Stock, carrito | Ajuste de cantidad, alternativas | Comportamiento no definido frustra al comprador |
| Reorder | Historial, pricing, stock, visibilidad | Compra recurrente rápida | Reorder con datos obsoletos genera errores |
| Solicitud de cotización | Catálogo, login | Negociación de condiciones | Confundir cotización con pedido confirmado |
| Validación de límite de crédito | Checkout, dato de crédito | Confirmación condicionada | Regla o fuente de crédito no definida bloquea ventas |
| Catálogo restringido | Login, Buyer Group | Visibilidad correcta por cuenta | Fugas de visibilidad exponen productos no permitidos |
| Pricing personalizado | Login, cuenta/Buyer Group | PLP, PDP, carrito y checkout consistentes | Inconsistencia de precio entre vistas |
| Historial y detalle de pedidos | Login, pedidos previos | Reorder, trazabilidad | Falta de detalle reduce autonomía del comprador |

---

## 19. Supuestos Actuales

- Cada buyer account tiene un **único usuario operativo** en el MVP.
- El **umbral de aprobación** por importe no está definido.
- Las **reglas exactas de crédito** no están definidas.
- El **stock** puede ser simulado en una fase futura (REST / Postman Mock Server).
- El **ERP real** está fuera del MVP.
- El **quote request** puede documentarse antes de automatizarse.
- Las **capacidades estándar** de Salesforce B2B Commerce deben priorizarse antes
  que la customización.

---

## 20. Decisiones Pendientes

- **Umbral de aprobación** por importe.
- **Regla exacta de crédito** y su fuente de datos.
- **Segmentos o Buyer Groups** concretos.
- **Reglas de pricing** y su asignación.
- **Comportamiento ante stock insuficiente**.
- Si habrá **backorder**.
- **Nivel de automatización del quote request**.
- **Nivel de automatización del approval flow**.

---

## 21. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general** del proyecto y del negocio.
- `docs/business/ecommerce-strategy.md` define la **estrategia de e-commerce B2B**.
- `docs/business/buyer-personas.md` define los **perfiles de comprador**.
- `docs/business/business-rules.md` define las **reglas de negocio**.
- Este documento define los **flujos funcionales** del portal.
- Las **historias de usuario** y los **criterios de aceptación** deberán derivarse
  de estos flujos.
- Los **casos de prueba** deberán derivarse de estos flujos y de las reglas de
  negocio asociadas.
- Las **decisiones técnicas** deberán documentarse en `docs/architecture/`.
