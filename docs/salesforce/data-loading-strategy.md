# Estrategia de Carga de Datos - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define la **estrategia conceptual de carga de datos** para el MVP de
`LvlUp-Wholesale-B2B`: qué datos se necesitan, cómo se diferencian de la metadata,
sus dependencias, el orden de carga, las validaciones posteriores y los riesgos.

Sirve como base para:

- Preparar los datos mínimos del MVP.
- Diferenciar metadata de registros.
- Definir dependencias entre entidades.
- Evitar cargas desordenadas.
- Facilitar el testing funcional.
- Validar catálogo, pricing, visibilidad, carrito, checkout, historial y reorder.
- Preparar una futura estrategia de scripts o herramientas de carga.
- Evitar la creación de custom data innecesaria.

Este documento **no incluye scripts, comandos ni cargas reales**. Aplica el
principio rector: *Configuration first, customization only when justified*.

> **Nota de honestidad:** no se inventan objetos, campos ni APIs. Lo que dependa de
> la org se marca como *pendiente de validación*; los nombres de cuentas, usuarios
> y productos son **conceptuales** (sin IDs reales).

---

## 2. Principios de Carga de Datos

- Cargar datos **pequeños, representativos y controlados**.
- Priorizar datos que **habiliten escenarios funcionales**.
- **Separar metadata de data**.
- **Validar objetos y relaciones** en la org antes de diseñar la carga definitiva.
- Mantener los datos **trazables y reutilizables**.
- **Evitar datos dummy** sin propósito funcional.
- Crear datos que permitan probar **casos positivos y negativos**.
- **No crear campos u objetos custom** solo para facilitar datos de prueba.
- **Documentar dependencias y orden** de carga.

---

## 3. Metadata vs Datos

### Metadata (desplegable)

- Apex classes.
- LWC.
- Flows.
- Experience pages.
- Permission Sets.
- Permission Set Groups.
- Custom metadata (si se justifica).
- Configuración desplegable según aplique.

### Datos / Registros (no metadata)

- Accounts buyer.
- Buyer users.
- Buyer Groups.
- Products.
- Product Catalog.
- Product Categories.
- Pricing / Price Book data.
- Visibility / entitlement records.
- Orders o datos de historial si aplica.
- Datos funcionales simulados para stock, crédito o approval si se documentan.

**Riesgo de mezclarlos.** Mezclar el deploy de metadata con la migración de
registros genera despliegues frágiles, entornos inconsistentes y dificultad de
reproducción. La regla es **gestionarlos por separado**.

---

## 4. Objetivos de Datos del MVP

La carga de datos debe habilitar:

- Login buyer.
- Catálogo visible.
- Categorías navegables.
- PLP con productos.
- PDP con información suficiente.
- Pricing visible y consistente.
- Diferencias de visibilidad por buyer/segmento.
- Carrito con productos válidos.
- Checkout básico.
- Casos de stock funcional.
- Casos de aprobación por importe.
- Casos de crédito funcional (si se documenta).
- Historial/reorder (si las capacidades estándar lo permiten).

---

## 5. Set de Datos MVP Recomendado

| Tipo de dato | Cantidad sugerida | Propósito funcional | Prioridad MVP | Estado de validación |
| --- | --- | --- | --- | --- |
| Buyer Accounts | 3–4 | Cubrir los segmentos | Alta | Pendiente de validación |
| Buyer Users | 1 por cuenta | Acceso y operación | Alta | Pendiente de validación |
| Buyer Groups / segmentos | 3–4 | Pricing y visibilidad | Alta | Pendiente de validación |
| Categorías | 8 | Navegación del catálogo | Alta | Confirmada (negocio) |
| Productos | 15–25 | PLP/PDP y casos de prueba | Alta | Confirmada (negocio) |
| Pricing | Diferenciado por segmento/cuenta | Pricing personalizado | Alta | Pendiente de validación |
| Productos visibles para todos | Algunos | Catálogo base | Alta | Pendiente de validación |
| Productos restringidos | Algunos | Catálogo restringido | Alta | Pendiente de validación |
| Productos para stock insuficiente | Algunos | Escenario de stock | Media | Pendiente de validación |
| Pedidos de ejemplo | Algunos | Historial/reorder | Media | Pendiente de validación |
| Datos funcionales approval/credit | Mínimos | Escenarios documentados | Media | Pendiente de validación |

---

## 6. Buyer Accounts de Prueba

Cuentas buyer **conceptuales** (sin IDs reales).

| Cuenta (conceptual) | Tipo de cliente | Segmento | Caso que habilita | Buyer Group (posible) | Pricing esperado | Visibilidad esperada | Estado |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Gaming Store Madrid | Tienda gaming local | Gaming local | Compra recurrente de gaming | Gaming Local Buyers | Precio base negociado | Catálogo gaming | Pendiente de validación |
| Tech Reseller Iberia | Reseller tecnológico | Reseller | Pricing de reventa y catálogo amplio | Tech Resellers | Precio preferente reseller | Catálogo amplio | Pendiente de validación |
| IT Solutions SMB | Empresa compradora interna | Empresa IT | Aprobación y crédito | Corporate IT Buyers | Precio corporativo | Catálogo tecnológico | Pendiente de validación |
| Enterprise Gaming Procurement | Cliente enterprise | Enterprise | Pricing personalizado y bundles | Enterprise Buyers | Precio enterprise (negociado) | Catálogo personalizado/restringido | Pendiente de validación |

---

## 7. Buyer Users de Prueba

- **Un usuario operativo por buyer account** en el MVP.
- Cada usuario debe permitir probar acceso, catálogo, pricing, carrito, checkout,
  historial y reorder.
- **No se definen emails reales** ni **licencias concretas** no validadas.
- Buyer Approver y Buyer Admin quedan **futuros**.

| Usuario conceptual | Buyer account | Rol funcional | Casos de prueba | Estado MVP |
| --- | --- | --- | --- | --- |
| Comprador Gaming Madrid | Gaming Store Madrid | Buyer operativo | Catálogo gaming, reorder | Pendiente de validación |
| Comprador Reseller Iberia | Tech Reseller Iberia | Buyer operativo | Pricing reseller, catálogo amplio | Pendiente de validación |
| Comprador IT SMB | IT Solutions SMB | Buyer operativo | Aprobación por importe, crédito | Pendiente de validación |
| Comprador Enterprise | Enterprise Gaming Procurement | Buyer operativo | Pricing personalizado, bundles, restricción | Pendiente de validación |

---

## 8. Buyer Groups / Segmentos

| Segmento | Propósito | Cuentas asociadas (conceptual) | Pricing posible | Visibilidad posible | Escenarios de prueba | Validación requerida |
| --- | --- | --- | --- | --- | --- | --- |
| Tienda gaming local | Gaming recurrente | Gaming Store Madrid | Precio base | Catálogo gaming | Reorder, stock | Org |
| Reseller tecnológico | Reventa | Tech Reseller Iberia | Preferente reseller | Catálogo amplio | Pricing diferenciado | Org |
| Empresa IT | Equipamiento interno | IT Solutions SMB | Corporativo | Catálogo tecnológico | Aprobación, crédito | Org |
| Cliente enterprise | Acuerdos específicos | Enterprise Gaming Procurement | Enterprise | Personalizado/restringido | Restricción, bundles | Org |

---

## 9. Categorías del Catálogo

| Categoría | Propósito | Ejemplos de productos | Prioridad MVP | Riesgo si falta | Relación con PLP |
| --- | --- | --- | --- | --- | --- |
| Consolas de gaming | Ancla de gaming | Consola Pro X, Console Go | Alta | Sin gaming | PLP de gaming |
| Videojuegos | Alta rotación | Galaxy Raiders | Alta | Sin rotación | PLP de juegos |
| Portátiles | Alto valor transversal | Gaming Laptop 15, Business Laptop 14 | Alta | Sin alto valor | PLP de portátiles |
| Monitores | Complemento | 27'' Gaming, 34'' Curved | Media | Sin venta cruzada | PLP de monitores |
| Periféricos | Recurrencia | Teclado, ratón, headset | Media | Sin recurrencia | PLP de periféricos |
| Networking | Reseller/empresa | Router, switch | Media | Sin infraestructura | PLP de networking |
| Accesorios | Ticket bajo | Cables, soportes | Baja | Sin complementos | PLP de accesorios |
| Bundles enterprise | Upselling | Reseller Bundle, Office Kit | Media | Sin bundles | PLP de bundles |

---

## 10. Productos MVP

Lista **conceptual** de productos representativos (coherente con los `LVL-*` de
`product-catalog-strategy.md`), sin asumir campos concretos.

| Producto conceptual | Categoría | Propósito funcional | Segmento objetivo | Caso de prueba | Prioridad MVP |
| --- | --- | --- | --- | --- | --- |
| Consola gaming profesional | Consolas | Ancla | Gaming local | Visible para todos | Alta |
| Consola portátil | Consolas | Variante | Gaming local | Stock insuficiente | Media |
| Videojuego licencia digital | Videojuegos | Rotación | Gaming local | Reorder | Media |
| Laptop gaming | Portátiles | Alto valor | Reseller | Pricing reseller | Alta |
| Laptop business | Portátiles | Corporativo | Empresa IT | Aprobación por importe | Alta |
| Workstation | Portátiles | Alto rendimiento | Enterprise | Pricing enterprise | Media |
| Monitor 27 pulgadas | Monitores | Complemento | Gaming/Reseller | Venta cruzada | Media |
| Monitor ultrawide | Monitores | Gama alta | Enterprise | Restringido enterprise | Baja |
| Teclado mecánico | Periféricos | Recurrencia | Gaming local | Reorder | Media |
| Mouse gaming | Periféricos | Recurrencia | Gaming local | Carrito | Media |
| Headset profesional | Periféricos | Transversal | Reseller | Visible para todos | Media |
| Router empresarial | Networking | Infraestructura | Empresa IT | Visible empresa | Media |
| Switch de red | Networking | Infraestructura | Enterprise | Restringido | Media |
| Cableado/accesorios | Accesorios | Consumible | Todos | Ticket bajo | Baja |
| Bundle tienda gaming | Bundles | Reventa | Reseller | Restringido reseller | Media |
| Bundle empresa IT | Bundles | Renovación | Empresa IT | Restringido empresa | Media |
| Bundle eventos enterprise | Bundles | Eventos | Enterprise | Restringido enterprise | Baja |

---

## 11. Pricing de Prueba

- El pricing debe permitir validar **diferencias por cuenta o Buyer Group**.
- El pricing debe ser **consistente** entre PLP, PDP, carrito y checkout.
- **No se cierra el modelo físico** hasta validar el estándar.
- **Sin** promociones complejas, multi-divisa ni motor externo real.

Los valores se expresan de forma **relativa** (no se inventan cifras).

| Escenario | Buyer/segmento | Resultado esperado | Pantallas afectadas | Estado de validación |
| --- | --- | --- | --- | --- |
| Precio base | Gaming local | Precio estándar negociado | PLP, PDP, carrito, checkout | Pendiente de validación |
| Precio preferente reseller | Reseller | Precio menor que base | PLP, PDP, carrito, checkout | Pendiente de validación |
| Precio corporativo | Empresa IT | Precio corporativo | PLP, PDP, carrito, checkout | Pendiente de validación |
| Precio enterprise | Enterprise | Precio negociado/estable | PLP, PDP, carrito, checkout | Pendiente de validación |
| Pricing no disponible | Cualquiera | Mensaje funcional (caso negativo) | PDP, carrito | Pendiente de validación |

---

## 12. Visibilidad / Entitlements de Prueba

- Algunos productos **visibles para todos** los buyers.
- Algunos productos **visibles solo para reseller**.
- Algunos productos **visibles solo para enterprise**.
- Algunos **bundles restringidos**.
- PLP/search/PDP/cart/checkout/reorder deben **respetar la visibilidad**.
- **No crear lógica custom** si el estándar puede cubrirlo.

| Producto/categoría (conceptual) | Visible para | No visible para | Escenario de prueba | Estado de validación |
| --- | --- | --- | --- | --- |
| Catálogo base (consolas, periféricos) | Todos | — | Catálogo común | Pendiente de validación |
| Bundle tienda gaming | Reseller | Gaming local, empresa IT | Restricción reseller | Pendiente de validación |
| Switch de red / ultrawide | Enterprise | Gaming local | Restricción enterprise | Pendiente de validación |
| Bundle empresa IT | Empresa IT | Gaming local | Restricción empresa | Pendiente de validación |
| Bundle eventos enterprise | Enterprise | Resto | Restricción + PDP por URL | Pendiente de validación |

---

## 13. Datos para Stock Funcional

- El **stock real queda fuera del MVP**.
- El **stock funcional** puede simularse documentalmente o con datos simples si la
  org lo permite.
- **Futuro:** Postman Mock Server. **No** se crea integración todavía.

| Producto conceptual | Estado de stock funcional | Impacto esperado | Pantalla/proceso | Estado MVP |
| --- | --- | --- | --- | --- |
| Consola gaming profesional | Stock suficiente | Compra normal | PLP/PDP/checkout | Pendiente de validación |
| Consola portátil | Stock insuficiente | Aviso y ajuste de cantidad | PDP/carrito | Pendiente de validación |
| Monitor ultrawide | Stock no disponible | Buscar alternativa | PLP/PDP | Pendiente de validación |
| Switch de red | Stock pendiente de integración | Comportamiento documentado | Checkout | Futuro |

---

## 14. Datos para Approval por Importe

- Approval inicia como **comportamiento funcional documentado**.
- El **umbral está pendiente de definición** (`DEC-008`); los importes se expresan
  **relativos al umbral**, no con cifras inventadas.
- **No** se crea automatización ni objeto custom por defecto.

| Escenario | Importe funcional | Resultado esperado | Estado de implementación | Decisión pendiente |
| --- | --- | --- | --- | --- |
| Pedido bajo umbral | Por debajo del umbral | Confirmación directa | Documentado | Umbral exacto |
| Pedido sobre umbral | Por encima del umbral | Solicitud pendiente de aprobación | Documentado | Umbral, aprobador, automatización |
| Solicitud pendiente | Por encima del umbral | Estado pendiente diferenciado | Documentado | Estado funcional exacto |

---

## 15. Datos para Credit Validation

- El crédito inicia como **comportamiento funcional documentado**.
- **Fuente futura posible:** ERP simulado.
- **No** se crea integración todavía ni modelo físico definitivo.

Escenarios a representar:

- **Crédito válido**: el pedido continúa.
- **Crédito bloqueado**: el pedido se impide con mensaje funcional.
- **Crédito excedido**: el importe supera el disponible; impedir/condicionar.
- **Crédito no disponible**: comportamiento documentado (sin dato real).

---

## 16. Datos para Historial y Reorder

- El historial y el reorder dependen de las **capacidades estándar disponibles**.
- Si se requieren datos, deben permitir:
  - Buyer con pedidos anteriores.
  - Buyer sin pedidos.
  - Pedido con productos todavía válidos.
  - Pedido con un producto ya no visible.
  - Pedido con pricing actualizado.
- El reorder debe **revalidar catálogo, pricing y stock** (`BR-REORDER-003`).

---

## 17. Orden Conceptual de Carga

Orden sujeto a **validación real** en la org.

| Paso | Tipo de dato | Depende de | Habilita | Validación requerida |
| --- | --- | --- | --- | --- |
| 1 | Configuración base de storefront/webstore | — | Todo el storefront | Org |
| 2 | Buyer accounts | Configuración base | Buyer users, pricing | Org |
| 3 | Buyer users | Buyer accounts | Login y operación | Org |
| 4 | Buyer Groups / segmentos | Buyer accounts | Pricing y visibilidad | Org |
| 5 | Product Catalog | Configuración base | Categorías y productos | Org |
| 6 | Product Categories | Product Catalog | Navegación/PLP | Org |
| 7 | Products | Categorías | PLP/PDP | Org |
| 8 | Asociación productos–categorías/catálogo | Productos, categorías | Catálogo navegable | Org |
| 9 | Pricing | Productos, Buyer Groups | Pricing personalizado | Org |
| 10 | Visibilidad / entitlements | Productos, Buyer Groups | Catálogo restringido | Org |
| 11 | Datos de carrito/checkout (si aplican) | Productos, pricing, visibilidad | Pruebas de compra | Org |
| 12 | Orders/historial (si aplican) | Checkout | Historial/reorder | Org |
| 13 | Datos funcionales de stock/credit/approval (si se representan) | Productos, cuentas | Escenarios funcionales | Org |

---

## 18. Dependencias Críticas

| Dato | Depende de | Riesgo si falta | Validación funcional afectada |
| --- | --- | --- | --- |
| Product | Catálogo/categoría | Producto sin clasificar | PLP/PDP |
| Pricing | Producto y buyer/segmento | Sin precio aplicable | Pricing/checkout |
| Visibility | Producto y buyer/segmento | Exposición indebida | Catálogo restringido |
| Buyer user | Buyer account | Sin acceso correcto | Login/operación |
| Reorder | Historial/orders | Sin reorder | Compra recurrente |
| Checkout | Pricing/carrito/productos válidos | Checkout inconsistente | Confirmación de pedido |

---

## 19. Validaciones Posteriores a la Carga

- [ ] El buyer puede iniciar sesión.
- [ ] El buyer ve solo su catálogo.
- [ ] Las categorías aparecen correctamente.
- [ ] La PLP muestra los productos esperados.
- [ ] La PDP muestra información suficiente.
- [ ] El pricing es correcto por buyer/segmento.
- [ ] Un producto restringido no aparece.
- [ ] Un producto restringido no es accesible por URL directa (si el estándar lo
      permite).
- [ ] Un producto permitido se agrega al carrito.
- [ ] Un producto no permitido no puede comprarse.
- [ ] El checkout usa precios vigentes.
- [ ] El buyer ve solo su historial.
- [ ] El reorder revalida los productos.

---

## 20. Riesgos de Carga de Datos

- Cargar datos **sin propósito funcional**.
- **No respetar dependencias**.
- **Pricing inconsistente**.
- **Visibilidad mal configurada**.
- **Productos sin categoría**.
- **Buyer users sin la cuenta correcta**.
- **Buyer Groups mal asignados**.
- **Reorder con datos inválidos**.
- **Confundir metadata con datos**.
- **No poder reproducir** los datos en otra org.
- **Depender de IDs hardcodeados**.
- **Crear custom fields innecesarios**.

---

## 21. Estrategia de Reproducibilidad

A nivel conceptual:

- Los datos deben poder **reconstruirse**.
- **Evitar la dependencia de IDs manuales**.
- Mantener **nombres funcionales claros**.
- **Documentar las relaciones**.
- Mantener el set **pequeño y mantenible**.
- En fase futura, **evaluar** CSV, Data Loader, scripts o la herramienta adecuada.
- **No se define la herramienta final todavía** (`DEC` de herramienta de carga).

---

## 22. Estrategia de Datos para Testing

- Cada dato debe **habilitar un caso de prueba**.
- Crear buyers para **escenarios positivos y negativos**.
- Crear productos **visibles/restringidos**.
- Crear **pricing diferenciado**.
- Crear **estados de stock funcional**.
- Crear escenarios de checkout **bajo/sobre umbral**.
- Crear **pedidos** si se valida historial/reorder.
- Relacionar los datos con `docs/testing/`.

---

## 23. Gaps Pendientes

- Objetos reales disponibles para B2B Commerce en la org.
- Relación exacta entre webstore, catálogo y productos.
- Modelo exacto de Buyer Groups.
- Modelo exacto de pricing.
- Modelo exacto de visibilidad.
- Cómo crear buyer users correctamente.
- Si historial/reorder requiere datos específicos.
- Si aprobación/crédito/stock se representarán como datos, configuración o
  integración futura.
- Herramienta final de carga de datos.

---

## 24. Decisiones Pendientes

- Set final de buyer accounts.
- Set final de buyer users.
- Segmentos definitivos.
- Productos definitivos.
- Categorías definitivas.
- Pricing definitivo.
- Reglas definitivas de visibilidad.
- Estrategia de carga definitiva.
- Uso futuro de CSV, Data Loader, scripts, SFDMU u otra herramienta.
- Datos necesarios para historial/reorder.
- Datos necesarios para approval/credit/stock.

---

## 25. Relación con Otros Documentos

- `docs/salesforce/data-model.md` define las **entidades y relaciones**.
- Este documento define la **estrategia de carga de datos**.
- `docs/salesforce/configuration-decisions.md` registra las **decisiones**
  relacionadas (`DEC-015`, gaps de carga).
- `docs/business/product-catalog-strategy.md` define **categorías y catálogo**.
- `docs/business/pricing-and-visibility-strategy.md` define **pricing/visibilidad**.
- `docs/architecture/limitations-and-assumptions.md` consolida **supuestos y
  riesgos**.
- `docs/testing/` deberá usar estos datos para los **casos de prueba**.
- `adr/` registrará la decisión si se adopta una **herramienta o estrategia**
  relevante.
