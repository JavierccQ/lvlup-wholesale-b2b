# Modelo de Seguridad Salesforce - LvlUp WholeSale

## 1. Propósito del Documento

Este documento describe el **modelo de seguridad Salesforce-relevante** para el
storefront B2B de LvlUp WholeSale: acceso de buyers, cuentas, usuarios, Buyer
Groups, permisos, visibilidad de catálogo, pricing, carrito, checkout, historial,
reorder y validaciones de seguridad. Baja al nivel de plataforma la visión
conceptual de `docs/architecture/security-architecture.md`.

Sirve como base para:

- Validar el acceso de buyers.
- Controlar la visibilidad de catálogo.
- Controlar el pricing por cuenta o Buyer Group.
- Proteger historial y reorder.
- Definir pruebas de seguridad.
- Evitar la exposición de datos entre cuentas.
- Guiar futuras decisiones de Permission Sets, Permission Set Groups, sharing y
  acceso.
- Alimentar ADRs si se requiere customización o excepciones.

Este documento **no define la configuración final hasta validarla en la org**.
Aplica el principio rector: *Configuration first, customization only when
justified*.

> **Nota de honestidad:** no se inventan Permission Sets, Permission Set Groups,
> Profiles, roles ni sharing rules. Lo que dependa de la org se marca como
> *pendiente de validación*.

---

## 2. Principios de Seguridad Salesforce

- **Mínimo privilegio**.
- **Seguridad por defecto**.
- **No confiar únicamente en la UI**.
- Priorizar los **mecanismos estándar** de Salesforce y B2B Commerce.
- Un buyer solo debe acceder a **datos de su buyer account**.
- Un buyer solo debe ver **productos permitidos**.
- Un buyer solo debe ver **pricing aplicable**.
- El **reorder no debe saltarse** las reglas actuales.
- El **checkout debe revalidar** acceso, pricing y visibilidad.
- Los **errores técnicos no deben exponerse** al buyer.
- Toda **excepción relevante** debe documentarse mediante ADR.

---

## 3. Alcance del Modelo de Seguridad

### Incluido en este documento

- Acceso buyer, buyer account y buyer user.
- Buyer Groups.
- Visibilidad de catálogo y pricing.
- PLP/PDP, carrito, checkout, historial y reorder.
- Seguridad de datos funcionales.
- Validaciones y pruebas de acceso.

### Fuera de este documento

- Configuración definitiva de Permission Sets.
- Configuración final de sharing.
- Políticas avanzadas de identidad.
- SSO.
- MFA.
- Integración real con ERP.
- Seguridad productiva avanzada.
- Hardening completo de producción.

---

## 4. Actores de Seguridad

| Actor | Rol funcional | Acceso esperado | Estado MVP | Consideraciones Salesforce |
| --- | --- | --- | --- | --- |
| Buyer operativo | Compra del día a día | Solo su cuenta (catálogo, pricing, carrito, historial) | MVP | Usuario externo del storefront; pendiente de validación |
| Buyer User | Rol base futuro | Comprar y reorder | Futuro | Pendiente de validación |
| Buyer Approver | Aprobar pedidos | Pedidos pendientes de su cuenta | Futuro | Pendiente de validación |
| Buyer Admin | Administrar la cuenta | Usuarios/config de su cuenta | Futuro | Pendiente de validación |
| Administrador Salesforce | Configurar la org | Configuración y datos | Activo | Mínimo privilegio; interno |
| Usuario interno seller | Gestión comercial | Datos comerciales | Futuro | Alcance por definir |
| Agente IA | Soporte documental | Documentación/contexto | Soporte | Sin acceso productivo directo |
| ERP simulado | Externo simulado | Datos vía contrato (mock) | Futuro | Sin datos reales |

---

## 5. Buyer Account

- La buyer account representa la **entidad compradora**.
- Es el **límite funcional principal** de acceso.
- El buyer **no debe ver datos de otra cuenta**.
- El buyer **no debe ver historial de otra cuenta**.
- El buyer **no debe acceder a pricing de otra cuenta**.
- **Relación con Buyer User**: la cuenta agrupa a su usuario operativo.
- **Relación con Buyer Group**: base de pricing/visibilidad.
- **Relación con catálogo, pricing y visibilidad**: determinan lo que el buyer ve.
- **A validar en Salesforce**: cómo se materializa el aislamiento por cuenta en el
  storefront.

No se inventan campos ni configuración concreta.

---

## 6. Buyer User

- Usuario autenticado que **opera en nombre de una buyer account**.
- Para el MVP, **un único usuario operativo** por buyer account (`BR-ACCESS-005`).
- Debe poder **navegar, consultar productos permitidos, agregar al carrito, iniciar
  checkout, consultar historial y hacer reorder** si está disponible.
- **No debe administrar** otros buyers en el MVP.
- **No debe aprobar** pedidos en el MVP, salvo que se defina después.
- **A validar:**
  - Tipo/licencia de usuario.
  - Acceso al storefront.
  - Permisos mínimos.
  - Relación con la cuenta.

No se inventan licencias ni Permission Sets concretos.

---

## 7. Buyer Groups

- Agrupación funcional para **segmentar catálogo, pricing o visibilidad**.
- **Segmentos esperados**: tienda gaming local, reseller tecnológico, empresa IT,
  cliente enterprise.
- **Relación con pricing**: precio por grupo/cuenta (`PR-001`).
- **Relación con visibilidad**: catálogo permitido (`PV-001`, `PV-006`).
- **Relación con catálogo**: alcance del surtido por grupo.
- **Riesgo**: una asignación incorrecta expone catálogo o pricing indebidos.
- **A validar en la org**: modelo de Buyer Groups y su efecto real.

---

## 8. Permission Sets y Permission Set Groups

A nivel Salesforce-relevante pero **no definitivo**:

- Se usarán si son necesarios para **conceder permisos de forma controlada**.
- Deben seguir el **mínimo privilegio**.
- Deben **probarse con usuarios representativos**.
- **No se definen nombres finales** hasta validar en la org.
- **Evitar permisos excesivos** para resolver problemas rápidos.
- **Separar** permisos buyer de permisos admin/internos.
- **Registrar decisiones** si se crean permisos custom o excepciones.

| Área | Permiso esperado conceptualmente | Riesgo si falta | Riesgo si sobra | Estado de validación |
| --- | --- | --- | --- | --- |
| Login/storefront | Acceso autenticado al storefront | No puede entrar | Acceso indebido | Pendiente de validación |
| Catálogo | Ver el catálogo permitido | No ve productos | Ve catálogo no permitido | Pendiente de validación |
| Producto | Ver productos visibles | PDP inaccesible | Expone productos restringidos | Pendiente de validación |
| Pricing | Ver el precio aplicable | No ve precio | Ve pricing de otro segmento | Pendiente de validación |
| Carrito | Gestionar su carrito | No puede comprar | Manipula datos indebidos | Pendiente de validación |
| Checkout | Confirmar/enviar su pedido | No completa pedido | Confirma sin validación | Pendiente de validación |
| Orders/historial | Ver sus pedidos | Sin trazabilidad | Ve pedidos ajenos | Pendiente de validación |
| Reorder | Reordenar desde sus pedidos | Sin reorder | Reorder sin revalidar | Pendiente de validación |
| Administración interna | Gestión interna (no buyer) | No se opera la org | Buyer con permisos admin | Pendiente de validación |

---

## 9. Visibilidad de Catálogo

- Los productos no autorizados **no deben aparecer en PLP**.
- Los productos no autorizados **no deben aparecer en search**.
- Los productos no autorizados **no deberían ser accesibles por URL directa**.
- Los productos no autorizados **no deben poder agregarse al carrito**.
- El **reorder debe revalidar** la visibilidad.
- La visibilidad debe resolverse **primero con capacidades estándar**.

| Punto del journey | Regla de visibilidad esperada | Riesgo | Validación requerida |
| --- | --- | --- | --- |
| PLP | Solo productos permitidos | Exponer restringidos | Validar entitlements en PLP |
| Search | Solo resultados permitidos | Filtrado fuga | Validar búsqueda |
| PDP directa | Bloquear acceso a no permitido | Acceso por URL | Validar control de acceso |
| Carrito | Solo productos permitidos | Compra indebida | Validar revalidación |
| Reorder | Revalidar visibilidad actual | Reorder no permitido | Validar revalidación |

---

## 10. Seguridad de Pricing

- El buyer solo debe ver el **pricing aplicable**.
- El pricing debe ser **consistente** en PLP, PDP, carrito y checkout (`PR-003`).
- **No deben exponerse** precios de otros segmentos.
- Si el pricing cambia, el buyer debe recibir un **mensaje funcional claro**.
- El **reorder debe revalidar** el pricing vigente.

| Pantalla/proceso | Comportamiento esperado | Riesgo | Validación requerida |
| --- | --- | --- | --- |
| PLP | Precio aplicable por ítem | Exponer otro pricing | Validar resolución de precio |
| PDP | Precio coincide con PLP | Inconsistencia | Validar consistencia |
| Carrito | Precio consistente | Sorpresa de precio | Validar recálculo |
| Checkout | Precio vigente confirmado | Confirmar precio erróneo | Validar revalidación |
| Reorder | Pricing actual | Precio obsoleto | Validar revalidación |

---

## 11. Seguridad en PLP y Search

- PLP y search deben **respetar la visibilidad** del buyer.
- **No deben mostrar** productos restringidos.
- **No deben filtrar solo de forma visual** si el backend/estándar no lo garantiza.
- El **estado sin resultados** debe ser claro (empty).
- **A validar en la org**: que la visibilidad se aplique en datos, no solo en UI.

---

## 12. Seguridad en PDP

- La PDP debe **validar el acceso** al producto.
- El acceso directo por **URL a un producto no permitido** debe manejarse de forma
  segura.
- Un producto no visible debe mostrar un **estado restringido o no disponible**, sin
  exponer lógica interna.
- El **precio** solo si el buyer tiene acceso.
- El **botón de agregar al carrito** solo si corresponde.
- **A validar en estándar**: control de acceso a PDP por URL directa (`DEC` de
  manejo de URL).

---

## 13. Seguridad en Carrito

- El carrito debe contener **solo productos válidos** para el buyer.
- Si un producto deja de estar visible, debe **bloquearse o removerse** según el
  comportamiento definido.
- Si el pricing cambia, debe **actualizarse o informarse**.
- Las **cantidades deben validarse**.
- El buyer **no debe poder manipular precios** desde la UI.
- **A validar en Salesforce**: que la revalidación ocurra en backend (`BR-CART-005`).

---

## 14. Seguridad en Checkout

El checkout debe **revalidar**:

- Usuario autenticado.
- Cuenta.
- Productos visibles.
- Productos activos/comprables.
- Pricing vigente.
- Reglas funcionales de crédito/aprobación si aplican.

Además:

- Un **pedido confirmado no debe generarse** si hay un producto no autorizado.
- La **solicitud pendiente** debe diferenciarse del pedido confirmado
  (`BR-CHECKOUT-003`, `BR-APPROVAL-004`).
- **Pagos, tax y shipping reales** están fuera del MVP.
- **A validar en Salesforce**: que las validaciones críticas no dependan solo del
  front.

---

## 15. Seguridad en Orders, Historial y Reorder

- El buyer solo debe ver **pedidos de su cuenta**.
- El **detalle de pedido** debe respetar la cuenta.
- El **reorder debe revalidar** los productos actuales (`BR-REORDER-003`).
- Un producto comprado antes **puede ya no estar disponible**.
- El reorder **no debe saltarse** visibilidad, pricing ni stock.
- **A validar en estándar**: acceso a order history acotado por cuenta.

---

## 16. Seguridad de Datos Funcionales

| Dato | Riesgo | Protección esperada | Estado MVP | Validación requerida |
| --- | --- | --- | --- | --- |
| Datos de cuenta | Exposición cruzada | Aislamiento por cuenta | Pendiente | Validar acceso por cuenta |
| Datos de buyer user | Datos personales | Mínimo necesario | Pendiente | Validar visibilidad |
| Pricing | Exponer precios negociados | Solo segmento propio | Pendiente | Validar resolución |
| Catálogo restringido | Exponer lo no permitido | Entitlements estándar | Pendiente | Validar visibilidad |
| Carrito | Manipulación | Revalidación backend | Pendiente | Validar reglas |
| Pedido | Acceso indebido | Acotado por cuenta | Pendiente | Validar acceso |
| Historial | Pedidos ajenos | Acotado por cuenta | Pendiente | Validar acceso |
| Crédito funcional | Dato financiero | No exponer detalle | Funcional/futuro | Validar tratamiento |
| Stock funcional | Dato comercial | Sin exponer fuente | Funcional/futuro | Validar tratamiento |
| Facturas futuras | Dato sensible | Acceso controlado | Futuro | Definir en integración |
| Logs técnicos futuros | Filtración interna | No exponer al buyer | Futuro | Definir logging |

---

## 17. Seguridad de Integraciones Futuras

- El **ERP real está fuera** del MVP.
- El **Postman Mock Server** futuro **no debe tratarse como producción**.
- **Named Credentials** si Salesforce realiza callouts.
- **No hardcodear** URLs ni secretos.
- **No exponer** errores técnicos al buyer.
- Los datos de **crédito, stock, pricing y facturas** requieren cuidado adicional.
- Una **integración real** debe tener ADR.

Coherente con `docs/architecture/integration-architecture.md`.

---

## 18. Matriz de Pruebas de Seguridad

| Caso | Actor | Dato/proceso | Resultado esperado | Prioridad MVP | Estado |
| --- | --- | --- | --- | --- | --- |
| Acceso al storefront | Buyer autenticado | Login | Accede a su experiencia | Alta | Pendiente |
| Ver solo productos permitidos | Buyer | Catálogo | Solo su catálogo | Alta | Pendiente |
| No ver restringidos en PLP | Buyer | PLP | No aparecen | Alta | Pendiente |
| No encontrar restringidos en search | Buyer | Search | No aparecen | Alta | Pendiente |
| No acceder a PDP restringido por URL | Buyer | PDP | Acceso bloqueado/seguro | Alta | Pendiente |
| Ver pricing correcto | Buyer | Pricing | Su precio aplicable | Alta | Pendiente |
| No ver pricing de otro segmento | Buyer | Pricing | No expuesto | Alta | Pendiente |
| Agregar producto permitido | Buyer | Carrito | Se añade | Alta | Pendiente |
| No comprar producto no permitido | Buyer | Carrito/checkout | Bloqueado | Alta | Pendiente |
| Checkout bloquea no autorizado | Buyer | Checkout | No confirma | Alta | Pendiente |
| Ver solo su historial | Buyer | Historial | Solo su cuenta | Alta | Pendiente |
| Reorder revalida visibilidad | Buyer | Reorder | Revalida y avisa | Alta | Pendiente |
| Sesión expirada | Buyer | Sesión | Manejo correcto | Media | Pendiente |
| Error técnico no expone detalles | Buyer | Errores | Mensaje no técnico | Media | Pendiente |

---

## 19. Indicadores de Gap de Seguridad

Señales de alerta:

- Necesidad de **ocultar datos solo con CSS/JS**.
- El buyer puede **acceder por URL directa** a un producto restringido.
- El **pricing difiere** entre PLP/PDP/carrito.
- El buyer puede **ver pedidos de otra cuenta**.
- El **reorder permite comprar** un producto ya no autorizado.
- Se requieren **permisos excesivos** para que algo funcione.
- Se usa **Apex sin revisar** seguridad de registro/campo.
- Se **exponen errores técnicos** al buyer.

---

## 20. Criterios para Customización Relacionada con Seguridad

Cualquier customización de seguridad debe justificar:

- Necesidad funcional.
- Capacidad estándar evaluada.
- Limitación comprobada.
- Impacto en seguridad.
- Impacto en testing.
- Riesgo de mantenimiento.
- Necesidad de ADR.
- Validación con un usuario buyer de prueba.

---

## 21. ADRs Relacionados

Crear un ADR si:

- Se crea **lógica custom de visibilidad**.
- Se usa **Apex para controlar acceso**.
- Se crea un **LWC que maneja datos sensibles**.
- Se decide un **modelo de permisos no estándar**.
- Se introduce **integración externa**.
- Se definen **roles avanzados buyer**.
- Se decide **cómo manejar crédito o aprobación**.
- Se permite una **excepción de seguridad**.

---

## 22. Supuestos Actuales

- Cada buyer account tendrá **un único usuario operativo** en el MVP.
- Los buyers estarán **autenticados** para comprar.
- El **Buyer Group o la cuenta** influirán en pricing/visibilidad.
- Las **capacidades estándar deben validarse**.
- Se priorizarán los **mecanismos estándar** de Salesforce.
- El **ERP real está fuera** del MVP.
- La **seguridad productiva avanzada** queda fuera de esta fase documental.

---

## 23. Decisiones Pendientes

- Tipo/licencia exacta de usuario buyer.
- Permission Sets definitivos.
- Permission Set Groups definitivos.
- Modelo exacto de Buyer Groups.
- Reglas exactas de visibilidad.
- Reglas exactas de pricing.
- Acceso exacto a order history.
- Soporte real de reorder estándar.
- Manejo de URL directa a PDP restringido.
- Seguridad del Postman Mock Server futuro.
- Necesidad de Apex/LWC por gaps de seguridad.

---

## 24. Relación con Otros Documentos

- `docs/architecture/security-architecture.md` define la **arquitectura conceptual
  de seguridad**.
- Este documento **baja esa visión** al modelo Salesforce-relevante.
- `docs/salesforce/b2b-commerce-standard-capabilities.md` define las **capacidades
  estándar** a validar.
- `docs/salesforce/data-model.md` define las **entidades y relaciones**.
- `docs/business/pricing-and-visibility-strategy.md` define la **intención funcional**
  de pricing/visibilidad.
- `docs/ux/empty-error-loading-states.md` define los **mensajes de error/restricción**.
- `docs/testing/` deberá definir las **pruebas detalladas**.
- `adr/` registrará las **decisiones de seguridad relevantes**.
