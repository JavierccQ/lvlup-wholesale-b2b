# Arquitectura de Seguridad - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define la **arquitectura conceptual de seguridad** del portal B2B
Commerce de LvlUp WholeSale: acceso al storefront, autenticación, autorización,
visibilidad de catálogo, pricing, datos de cuenta, historial, permisos,
integración futura y riesgos de exposición de información. Describe criterios, no
configuración técnica final.

Sirve como base para:

- Control de acceso.
- Autenticación y autorización.
- Visibilidad de productos.
- Pricing por cuenta o Buyer Group.
- Protección de datos de cuenta.
- Seguridad en carrito, checkout, historial y reorder.
- Seguridad de integraciones futuras.
- Testing de permisos y visibilidad.
- ADRs relacionados con seguridad.

Este documento **no define la configuración técnica final ni reemplaza la
validación real en Salesforce**. Aplica el principio rector del proyecto:
*Configuration first, customization only when justified*.

---

## 2. Principios de Seguridad

- **Seguridad por defecto**.
- **Mínimo privilegio**.
- Cada buyer debe acceder **solo a la información de su cuenta**.
- Los productos restringidos **no deben exponerse** en PLP, búsqueda, PDP, carrito
  ni reorder.
- El **pricing específico no debe exponerse** a clientes no autorizados.
- **No confiar solo en la UI** para proteger datos.
- Priorizar los **mecanismos estándar** de Salesforce antes que la customización.
- Cualquier **excepción** debe documentarse mediante **ADR**.
- **No exponer errores técnicos** al buyer.
- **Separar** seguridad funcional, seguridad de plataforma y seguridad de
  integración.

---

## 3. Actores y Acceso

| Actor | Tipo de acceso | Qué puede ver | Qué puede hacer | Estado MVP | Consideraciones |
| --- | --- | --- | --- | --- | --- |
| Buyer operativo | Autenticado (storefront) | Su catálogo, su pricing, su historial | Navegar, comprar, reorder, checkout | MVP | Único usuario por cuenta |
| Buyer User | Autenticado | Su catálogo y pricing | Comprar y reorder | Futuro | Rol base |
| Buyer Approver | Autenticado | Pedidos pendientes de su cuenta | Aprobar/rechazar | Futuro | Separación de funciones |
| Buyer Admin | Autenticado | Usuarios y configuración de su cuenta | Gestionar usuarios de la cuenta | Futuro | Administración de cuenta |
| Administrador Salesforce | Interno privilegiado | Configuración y datos de la org | Configurar la plataforma | Activo | Mínimo privilegio |
| Seller / equipo interno | Interno | Datos comerciales | Gestión comercial | Futuro | Alcance por definir |
| Agente IA | Soporte documental | Documentación y contexto | Recomendar, no ejecutar en producción | Soporte | Sin acceso productivo directo |
| ERP simulado | Externo simulado | Datos vía contrato | Responder consultas (mock) | Futuro | Sin datos reales |

---

## 4. Autenticación

- El buyer debe **autenticarse** para acceder a la experiencia B2B completa
  (`BR-ACCESS-001`).
- El buyer debe iniciar sesión para **ver pricing específico** (`BR-ACCESS-002`).
- El buyer debe iniciar sesión para **agregar productos al carrito**
  (`BR-ACCESS-003`).
- El buyer debe iniciar sesión para **consultar historial y reorder**
  (`BR-ACCESS-004`).
- Las **sesiones expiradas** se manejan con mensajes claros (ver
  `empty-error-loading-states.md` §5).
- El MVP **no define todavía** políticas avanzadas de autenticación.
- Cualquier decisión de **autenticación avanzada** debe documentarse en ADR.

No se inventa configuración concreta de login o identidad.

---

## 5. Autorización

- El acceso debe basarse en **cuenta, usuario, Buyer Group** o las capacidades
  estándar disponibles.
- Un buyer **no debe acceder a datos de otra cuenta**.
- Un buyer **no debe ver productos no autorizados**.
- Un buyer **no debe ver pricing de otro segmento**.
- Las acciones de **carrito, checkout, historial y reorder** deben respetar los
  permisos.
- La futura jerarquía de roles debe **diferenciar** las acciones de compra,
  aprobación y administración.

No se definen Permission Sets concretos sin validarlos en la org.

---

## 6. Seguridad de Catálogo y Visibilidad

- Los productos no visibles **no deben aparecer en PLP**.
- Los productos no visibles **no deben aparecer en búsqueda**.
- Los productos no visibles **no deben ser accesibles por PDP directa**.
- Los productos no visibles **no deben poder agregarse al carrito**.
- El **reorder** debe revalidar la visibilidad actual (`PV-007`).
- El **catálogo restringido** debe ser consistente en todo el journey.
- La visibilidad debe apoyarse en el **estándar de Salesforce B2B Commerce** cuando
  sea posible.

Coherente con las reglas `PV-*` de `docs/business/pricing-and-visibility-strategy.md`.

---

## 7. Seguridad de Pricing

- El buyer debe ver **solo el precio aplicable** a su cuenta o Buyer Group.
- El pricing debe ser **consistente** en PLP, PDP, carrito y checkout (`PR-003`).
- **No deben exponerse** precios de otros segmentos.
- El **reorder** debe validar el pricing actual.
- Los **cambios de pricing** se comunican funcionalmente sin exponer lógica
  interna.
- Las **promociones complejas** y la **multi-divisa** quedan fuera del MVP.

---

## 8. Seguridad en PLP y PDP

- La **PLP** debe filtrar los productos según el acceso.
- La **PDP** debe validar que el producto sea **visible para el buyer**.
- La **UI no debe ser la única barrera**.
- Los **estados restringidos** deben ser claros y no técnicos.
- **No deben mostrarse** detalles internos de las reglas de visibilidad.
- Un producto inactivo/no permitido debe **manejarse de forma segura**.

---

## 9. Seguridad en Carrito

- Solo productos **visibles y permitidos** deben poder estar en el carrito.
- El carrito debe **revalidar** visibilidad, pricing y disponibilidad
  (`BR-CART-005`).
- Si un producto deja de estar permitido, debe **informarse y bloquearse** su
  compra.
- El buyer **no debe poder manipular** cantidades o precios fuera de las reglas
  funcionales.
- El carrito debe **evitar inconsistencias** antes del checkout.

---

## 10. Seguridad en Checkout

- El checkout debe **revalidar** productos, pricing, visibilidad y condiciones
  funcionales.
- **Pedido confirmado** y **solicitud pendiente** deben diferenciarse
  (`BR-APPROVAL-004`).
- El **crédito bloqueado o excedido** debe impedir o condicionar según la regla
  futura (`BR-CREDIT-002`).
- **No se procesan pagos reales** en el MVP.
- El **tax** y el **shipping** reales están fuera del MVP.
- Ninguna **validación crítica** debe depender solo del front.

---

## 11. Seguridad en Historial y Reorder

- El buyer debe ver **solo pedidos de su cuenta**.
- El detalle de pedido **no debe exponer** datos de otra cuenta.
- El **reorder** debe revalidar los permisos actuales.
- Los productos de pedidos anteriores **pueden ya no ser visibles**.
- El reorder **no debe saltarse** las reglas actuales de catálogo, pricing o stock
  (`BR-REORDER-003`).

---

## 12. Seguridad de Datos

| Tipo de dato | Riesgo | Sensibilidad funcional | Consideraciones MVP | Consideraciones futuras |
| --- | --- | --- | --- | --- |
| Datos de cuenta buyer | Exposición cruzada entre cuentas | Media-alta | Aislar estrictamente por cuenta | Roles y administración de cuenta |
| Datos de usuario buyer | Exposición de datos personales | Media | Mínimo dato necesario | Gestión de múltiples usuarios |
| Pricing | Exponer precios negociados | Alta | Solo el segmento del buyer | Pricing por volumen |
| Historial de pedidos | Ver pedidos ajenos | Alta | Solo la cuenta del buyer | Roles diferenciados |
| Información de crédito | Dato financiero sensible | Alta | Documentado; no exponer detalles | Integración segura |
| Información de stock | Dato comercial | Media | Funcional; sin exponer fuentes | Simulación / integración |
| Datos de integración futura | Secretos/credenciales | Alta | No aplica (sin callouts en MVP) | Named Credentials, sin secretos en código |
| Logs técnicos futuros | Filtración de detalles internos | Media | No exponer al buyer | Logging controlado |

---

## 13. Seguridad de Integraciones Futuras

- El **ERP real está fuera del MVP**.
- **Postman Mock Server** será la simulación futura.
- Los **Named Credentials** deben usarse cuando haya callouts desde Salesforce.
- **No hardcodear** URLs, tokens o secretos.
- **No exponer** errores técnicos de integración al buyer.
- Los datos de **crédito, stock, pricing y facturas** deben tratarse con cuidado.
- La autenticación del **mock** puede ser simple inicialmente, pero debe
  documentarse.
- Cualquier **integración real** debe requerir ADR.

Coherente con `docs/architecture/integration-architecture.md`.

---

## 14. Seguridad de Logs y Trazabilidad

- Los **errores técnicos** deben registrarse de forma controlada.
- **No almacenar** datos sensibles innecesarios.
- **No exponer** stack traces ni detalles internos al buyer.
- Registrar **correlación funcional** cuando aplique: cuenta, pedido, carrito,
  integración.
- El **logging detallado** queda para documentos técnicos posteriores.
- La trazabilidad debe **apoyar soporte, testing y debugging**.

---

## 15. Permission Sets y Permission Set Groups

A nivel conceptual:

- Los permisos deben gestionarse preferentemente con **capacidades estándar** de
  Salesforce.
- Los **Permission Sets / Permission Set Groups** pueden ser relevantes para el
  acceso interno, buyer o de configuración.
- **No se definen nombres definitivos** sin validarlos en la org.
- Cualquier **nuevo permiso** debe evaluarse contra el **mínimo privilegio**.
- Los permisos deben **probarse con usuarios representativos**.

---

## 16. Roles B2B Actuales y Futuros

### MVP

- **Un único usuario operativo** por buyer account (`BR-ACCESS-005`).

### Futuro

#### Buyer User
- **Podría:** navegar, comprar, reorder, consultar su historial.
- **No debería:** aprobar pedidos ni administrar usuarios.
- **Aprobación:** no aplica.
- **Administración:** no aplica.
- **Estado:** Futuro.

#### Buyer Approver
- **Podría:** revisar y aprobar/rechazar pedidos de su cuenta.
- **No debería:** administrar usuarios.
- **Aprobación:** rol central del flujo de aprobación.
- **Administración:** no aplica.
- **Estado:** Futuro.

#### Buyer Admin
- **Podría:** gestionar los usuarios y la configuración de su cuenta.
- **No debería:** exceder el ámbito de su cuenta.
- **Aprobación:** puede configurar quién aprueba (según diseño futuro).
- **Administración:** rol central de administración de cuenta.
- **Estado:** Futuro.

---

## 17. Riesgos de Seguridad

- **Exponer productos restringidos**.
- **Exponer pricing** de otro cliente.
- Permitir **checkout con productos no autorizados**.
- Permitir **reorder saltándose** la visibilidad actual.
- **Mostrar pedidos** de otra cuenta.
- **Confiar solo en controles visuales**.
- **Hardcodear credenciales**.
- **Exponer errores técnicos**.
- **No probar permisos**.
- **Customizar** sin respetar la seguridad estándar.
- **Mezclar datos de prueba** con datos sensibles.

---

## 18. Testing de Seguridad

Escenarios de prueba:

- Un buyer autenticado ve **solo su catálogo**.
- Un buyer **no ve productos restringidos**.
- Un buyer **no puede acceder por URL directa** a un producto restringido.
- Un buyer **ve el pricing correcto**.
- Un buyer **no ve pricing de otro segmento**.
- Un buyer **solo ve su historial**.
- El **reorder valida** los productos actuales.
- El **checkout bloquea** un producto no permitido.
- Una **sesión expirada** redirige o informa correctamente.
- Un **error técnico no expone** detalles internos.

Los casos detallados deberán evolucionar en `docs/testing/`.

---

## 19. ADRs Relacionados con Seguridad

Crear un ADR si:

- Se **cambia el modelo de acceso**.
- Se introduce **lógica custom de visibilidad**.
- Se introduce **LWC custom que maneja datos sensibles**.
- Se introduce **Apex que accede a datos sensibles**.
- Se implementa **integración externa**.
- Se decide **cómo manejar el crédito**.
- Se decide **cómo manejar roles buyer avanzados**.
- Se decide una **excepción al estándar** de Salesforce.

---

## 20. Supuestos Actuales

- Cada buyer account tiene **un único usuario operativo** en el MVP.
- La org tiene **B2B Commerce y un Site activo**.
- Se priorizan las **capacidades estándar** de seguridad de Salesforce.
- El **Buyer Group o la cuenta** podrán influir en visibilidad/pricing.
- El **ERP real está fuera** del MVP.
- Las **integraciones futuras** deberán usar mecanismos seguros.
- Algunas **configuraciones reales deben validarse** en la org.

---

## 21. Decisiones Pendientes

- Modelo exacto de acceso del buyer.
- Buyer Groups definitivos.
- Permission Sets definitivos.
- Permission Set Groups definitivos.
- Reglas exactas de visibilidad.
- Reglas exactas de pricing.
- Gestión final de roles Buyer User / Buyer Approver / Buyer Admin.
- Seguridad del Postman Mock Server.
- Estrategia de logging.
- Estrategia de testing de seguridad.
- Si alguna validación requiere Apex.

---

## 22. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general** del proyecto.
- `docs/business/` define **negocio, reglas, pricing y visibilidad**.
- `docs/ux/` define la **experiencia y los mensajes**.
- `docs/architecture/standard-vs-custom-framework.md` define **cuándo justificar la
  customización**.
- `docs/architecture/solution-architecture.md` define la **arquitectura general**.
- `docs/architecture/integration-architecture.md` define la **integración futura**.
- Este documento define la **arquitectura conceptual de seguridad**.
- `docs/salesforce/security-model.md` deberá documentar la **configuración concreta**
  de Salesforce cuando se valide.
- `docs/testing/` deberá definir las **pruebas de seguridad**.
- `adr/` registrará las **decisiones relevantes**.
- `agents/` deberá **respetar estos principios** al recomendar soluciones.
