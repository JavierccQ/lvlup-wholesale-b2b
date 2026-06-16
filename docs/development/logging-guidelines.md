# Guidelines de Logging y Trazabilidad - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define los **criterios para registrar, trazar y analizar** eventos
relevantes del proyecto `LvlUp-Wholesale-B2B`, de forma transversal: Apex, LWC,
Flow, integraciones futuras, manejo de errores, seguridad, debugging y soporte.

Sirve como base para: debugging, soporte, Apex, LWC, Flow, integraciones futuras,
manejo de errores, seguridad, testing, code review y ADRs.

Este documento **no define una implementación concreta ni un framework de logging
definitivo**, y **no crea objetos custom de log por defecto**. La prosa va en
español; los códigos, clases, métodos, DTOs y comentarios en inglés.

---

## 2. Principios Generales de Logging

- **Registrar solo lo necesario**; evitar ruido.
- **No registrar datos sensibles** innecesarios.
- **No exponer logs** al buyer.
- **Separar** mensajes técnicos de mensajes funcionales.
- El logging debe ayudar a **entender qué ocurrió**.
- El logging debe permitir **correlacionar** eventos relevantes.
- **No usar logging** para ocultar errores mal manejados.
- **No crear objetos custom** de log sin justificación.
- **No crear framework persistente** dentro del MVP salvo necesidad real.
- El **logging persistente** relevante **requiere ADR**.

---

## 3. Qué es Logging en este Proyecto

Logging es el **registro controlado** de información técnica o funcional útil para
entender eventos, errores, integraciones o procesos. Se distingue:

- **Debugging temporal.** Información para desarrollo o troubleshooting puntual; no
  permanente.
- **Logging funcional.** Registro de eventos relevantes de negocio o proceso.
- **Logging técnico.** Registro de errores técnicos, excepciones o problemas de
  integración.
- **Trazabilidad.** Capacidad de relacionar un evento con buyer account, cart,
  order, request o proceso.
- **Auditoría.** Registro formal y persistente de acciones relevantes; normalmente
  **fuera del MVP** salvo decisión futura.

---

## 4. Qué Debe Registrarse

| Evento | Motivo | Nivel recomendado | Persistente | Estado MVP |
| --- | --- | --- | --- | --- |
| Error técnico inesperado | Diagnóstico | ERROR/FATAL | No (MVP) | MVP |
| Error funcional crítico | Entender bloqueo | WARN/ERROR | No | MVP |
| Checkout bloqueado | Soporte/diagnóstico | WARN | No | MVP |
| Producto no autorizado en cart/checkout | Seguridad | WARN/ERROR | No (revisar) | MVP |
| Pricing no disponible | Datos/diagnóstico | WARN | No | MVP |
| Crédito bloqueado | Soporte | INFO/WARN | No | MVP |
| Stock insuficiente | Diagnóstico | INFO | No | MVP |
| Timeout de integración (futuro) | Resiliencia | ERROR | Futuro | Futuro |
| Response inválida (futuro) | Integración | ERROR | Futuro | Futuro |
| Error de permisos | Seguridad | WARN/ERROR | No (revisar) | MVP |
| Error de datos críticos | Diagnóstico | WARN/ERROR | No | MVP |
| Fallo de configuración relevante | Soporte | WARN | No | MVP |
| Reorder parcial por productos inválidos | Diagnóstico | INFO | No | MVP |

---

## 5. Qué No Debe Registrarse

- Passwords.
- Tokens.
- Session IDs.
- Secrets.
- Datos personales innecesarios.
- Información completa de tarjetas o pagos.
- Datos sensibles de otra cuenta.
- Responses externas completas con información sensible.
- Stack traces visibles al buyer.
- Información de debug excesiva en producción.
- IDs hardcodeados como dependencia.
- Logs redundantes sin valor.

> Los **pagos reales están fuera del MVP**, pero la regla de no registrar datos de
> pago queda documentada como buena práctica.

---

## 6. Niveles Conceptuales de Logging

| Nivel | Definición | Cuándo usar | Cuándo evitar | Ejemplo conceptual |
| --- | --- | --- | --- | --- |
| `DEBUG` | Detalle fino de desarrollo | Troubleshooting puntual | En producción de forma permanente | "DEBUG building stock request for skus" |
| `INFO` | Evento relevante de proceso | Hitos de negocio/proceso | Para ruido sin valor | "INFO order submitted for approval" |
| `WARN` | Situación anómala no crítica | Avisos que conviene vigilar | Para errores graves | "WARN price updated during checkout" |
| `ERROR` | Error que impide una operación | Fallos técnicos/funcionales críticos | Para condiciones esperadas triviales | "ERROR INT_TIMEOUT calling stock service" |
| `FATAL` | Fallo grave del proceso/sistema | Errores irrecuperables | Para errores recuperables | "FATAL unexpected error in checkout" |

*(Niveles conceptuales; no implican una implementación específica.)*

---

## 7. Contexto Mínimo Recomendado

Contexto útil **solo cuando sea seguro**: `errorCode`, `errorType`,
`operationName`, `buyerAccountId`, `buyerUserId`, `cartId`, `orderId`,
`productId`, `sku`, `endpointName`, `httpStatusCode`, `correlationId`,
`timestamp`, `source`, `message`, `safeDetails`.

- **No** todos aplican siempre.
- **No** registrar más de lo necesario.
- **Evitar** datos sensibles.
- Usar identificadores solo cuando sea **seguro y útil**.

Coherente con el contexto definido en `error-handling-guidelines.md` §5.

---

## 8. Correlation ID

- **Qué es.** Un `correlationId` permite **relacionar** los registros de un mismo
  flujo/operación.
- **Para qué sirve.** Seguir un proceso a través de capas (UI → Apex → integración)
  en debugging/soporte.
- **Cuándo podría ser útil.** Integración futura, checkout, errores de cart,
  callouts y soporte.
- **Estado MVP.** Conceptual / futuro.
- **No implementar** si no hay necesidad real.
- Si se vuelve un **patrón central**, **requiere ADR**.

---

## 9. Logging en Apex

- **No** usar `System.debug` como estrategia definitiva (sí temporalmente en
  desarrollo).
- **No** dejar debug innecesario.
- **Manejar** la excepción antes de loguear.
- **No** loguear `Exception.getStackTraceString()` de forma indiscriminada.
- **No** devolver logs técnicos al buyer.
- **Registrar contexto útil** cuando sea seguro.
- El **logging persistente** se justifica con **ADR**.
- Los **tests** cubren los errores relevantes, no los logs internos (salvo que haya
  lógica de logging real).

**Ejemplo a evitar:**

```apex
// Avoid: leftover debug, dumps full record, leaks stack trace
System.debug(buyerAccount);
System.debug(e.getStackTraceString());
```

**Ejemplo recomendado (conceptual):**

```apex
// Conceptual: safe, classified message with minimal context
Logger.error('INT_TIMEOUT', new Map<String, Object>{
    'operationName' => 'fetchStockAvailability',
    'buyerAccountId' => buyerAccountId
}); // conceptual; not a definitive framework
```

---

## 10. Logging en LWC

- **No** usar `console.log` como estrategia definitiva.
- **Evitar** logs innecesarios.
- **No** loguear datos sensibles en el browser.
- **No** loguear pricing sensible ni datos de otra cuenta.
- Mostrar al buyer **mensajes funcionales**, no logs técnicos.
- Si se necesita **enviar un error al backend**, debe justificarse y diseñarse de
  forma segura.
- Manejar estados visibles: **loading, error, empty, pending, restricted**.

---

## 11. Logging en Flow

- Flow **no debe esconder** errores.
- Usar **fault paths** cuando aplique.
- **Documentar** qué ocurre ante fallos.
- **Evitar** registros de log custom sin justificación.
- Si un Flow maneja un **proceso crítico**, documentar su trazabilidad.
- Si un Flow **bloquea checkout** o altera pricing/visibilidad, revisar si requiere
  **ADR**.
- El **logging persistente desde Flow** debe ser excepcional y justificado.

---

## 12. Logging en Integraciones Futuras

- Registrar **errores de callout** de forma segura.
- Registrar el **endpoint lógico** (`endpointName`), no necesariamente la URL
  completa sensible.
- Registrar **HTTP status code** y **timeouts**.
- Registrar **errores de parsing** y **responses inválidas** de forma controlada.
- **No** registrar tokens.
- **No** registrar payloads completos con datos sensibles.
- Registrar request/response **resumidos o sanitizados** si se justifica.
- Usar `correlationId` futuro si aplica.

**Casos futuros:** stock availability, credit status, final pricing, ETA, order
status, invoices.

---

## 13. Logging de Seguridad

Eventos relevantes:

- Intento de acceder a un **producto restringido**.
- Intento de acceder a un **order de otra cuenta**.
- **Producto no permitido** en cart.
- **Checkout** con producto no autorizado.
- **Pricing no autorizado**.
- **Error de permisos**.
- **Direct URL access** restringido.

Aclaraciones:

- **No exponer** detalles al buyer.
- **No revelar** reglas internas.
- Tratar estos eventos con **mayor cuidado** (eventos a revisar).
- El **logging de seguridad persistente** puede **requerir ADR**.

---

## 14. Logging de Datos y Configuración

| Evento | Impacto funcional | Prioridad | Documento relacionado | Acción recomendada |
| --- | --- | --- | --- | --- |
| Producto sin pricing | No se puede comprar | Alta | `data-model.md` | Corregir dato; `DATA_MISSING_PRICE` |
| Producto sin categoría | No navegable | Media | `product-catalog-strategy.md` | Asignar categoría |
| Buyer user sin buyer account | Sin acceso correcto | Alta | `security-model.md` | Revisar relación |
| Buyer Group mal asignado | Pricing/visibilidad erróneos | Alta | `pricing-and-visibility-strategy.md` | Revisar asignación |
| Storefront incompleto | Experiencia rota | Alta | `configuration-decisions.md` | Completar configuración |
| Permission Set faltante | Acceso bloqueado | Media | `security-model.md` | Revisar permisos |
| Configuración de checkout incompleta | Checkout falla | Alta | `cart-checkout-experience.md` | Completar configuración |
| Visibilidad inconsistente | Exposición/ocultación errónea | Alta | `pricing-and-visibility-strategy.md` | Revisar entitlements |

---

## 15. Logging en Cart y Checkout

| Evento | Qué registrar | Qué no registrar | Mensaje visible | Trazabilidad | Estado |
| --- | --- | --- | --- | --- | --- |
| Producto inválido en cart | `productId`, `cartId`, código | Datos de otra cuenta | "Este producto ya no está disponible…" | Sí | MVP |
| Cantidad inválida | Operación, valor inválido | — | "Introduce una cantidad válida." | No | MVP |
| Precio actualizado | `productId`, código | Pricing de otro segmento | "El precio de algunos productos se ha actualizado." | Opcional | MVP |
| Checkout bloqueado | Motivo (código), `cartId` | Detalle técnico crudo | Mensaje funcional según causa | Sí | MVP |
| Requiere aprobación | `orderTotal` (seguro), código | — | "Este pedido… requiere aprobación." | Sí | MVP |
| Crédito bloqueado | Código, `buyerAccountId` | Datos financieros sensibles | "No es posible confirmar… crédito." | Sí | MVP |
| Stock insuficiente | `sku`, código | — | "Stock insuficiente…" | Opcional | MVP |
| Error técnico inesperado | `errorCode`, contexto | Stack trace al buyer | "Ocurrió un problema… Inténtalo de nuevo." | Sí | MVP |
| Sesión expirada | Evento de sesión | Session ID | "Tu sesión ha caducado…" | Opcional | MVP |

---

## 16. Logging en Orders, Historial y Reorder

| Evento | Qué registrar | Qué no registrar | Mensaje visible | Trazabilidad |
| --- | --- | --- | --- | --- |
| Error al cargar historial | `errorCode`, `buyerAccountId` | Datos de otra cuenta | "No pudimos cargar tu historial…" | Sí |
| Acceso a order no permitido | Evento de seguridad, código | Datos del order ajeno | "Este pedido no está disponible." | Sí (revisar) |
| Reorder parcial | `orderId`, items excluidos (ids/códigos) | — | "Algunos productos no se pudieron añadir." | Opcional |
| Producto anterior no visible | `productId`, código | — | "Algunos productos ya no están disponibles…" | Opcional |
| Producto anterior sin pricing | `productId`, código | Pricing de otro segmento | "El precio de algunos productos se ha actualizado." | Opcional |
| Producto anterior sin stock | `sku`, código | — | "Algunos productos no tienen stock…" | Opcional |
| Error al iniciar reorder | `errorCode`, `orderId` | Stack trace al buyer | "No pudimos preparar el reorder…" | Sí |

---

## 17. Persistencia de Logs

| Opción | Uso posible | Ventajas | Riesgos | Estado | ¿ADR? |
| --- | --- | --- | --- | --- | --- |
| Logs temporales de plataforma/desarrollo | Debugging puntual | Simple, sin coste | No persistente | MVP | No |
| Debugging controlado | Troubleshooting | Suficiente al inicio | Limitado | MVP | No |
| Registros custom de log (objeto) | Trazabilidad persistente | Consultable | Coste, mantenimiento, datos | Futuro | Sí |
| Platform Events | Logging desacoplado | Escalable | Complejidad | Futuro | Sí |
| External logging | Centralización | Observabilidad | Integración/seguridad | Futuro | Sí |
| Monitoreo externo | Alertas/dashboards | Operación | Coste/integración | Futuro | Sí |

> **No se implementa logging persistente por defecto.** Cualquier opción
> persistente requiere justificación y **ADR**.

---

## 18. Sanitización de Logs

- **No** registrar secrets ni tokens.
- **Evitar** datos personales innecesarios.
- **Evitar** payloads completos sensibles.
- **Evitar** pricing sensible si no es necesario.
- **Evitar** datos de otra cuenta.
- **Resumir** errores cuando sea suficiente.
- Usar **`safeDetails`** en lugar de `rawDetails` cuando aplique.

---

## 19. Logging y Manejo de Errores

Relación con `error-handling-guidelines.md`:

- **No todo error** requiere log persistente.
- **Todo error crítico** debe ser **trazable**.
- Los **errores funcionales** pueden requerir mensaje UX **sin** log técnico
  persistente.
- Los **errores técnicos inesperados** deben tener **trazabilidad**.
- Los **errores de seguridad** requieren **atención especial**.
- Los **errores de integración futura** requieren **logging controlado**.

---

## 20. Logging y Testing

- Los tests deben **validar el comportamiento ante errores**.
- **No** testear logs temporales.
- Si existe **lógica de logging persistente**, debe **probarse**.
- Validar que **no se expongan** errores técnicos.
- Validar que los **errores funcionales** muestren los mensajes correctos.
- Validar escenarios de integración: **timeout, invalid response, functional
  error, unauthorized**.
- Validar que **datos sensibles no se propaguen** al front.

---

## 21. Matriz de Logging Recomendado

| Escenario | Nivel | Persistente | Contexto recomendado | Datos prohibidos | Estado |
| --- | --- | --- | --- | --- | --- |
| Producto sin stock | INFO | No | `sku`, código | — | MVP |
| Crédito bloqueado | WARN | No | código, `buyerAccountId` | Datos financieros | MVP |
| Pedido requiere aprobación | INFO | No | `orderTotal` (seguro), código | — | MVP |
| Producto restringido por URL directa | WARN | No (revisar) | `productId`, evento de seguridad | Detalle de la regla | MVP |
| Producto sin pricing | WARN | No | `productId`, `DATA_MISSING_PRICE` | Pricing de otro segmento | MVP |
| Buyer sin acceso | WARN | No (revisar) | `buyerUserId`, código | Datos de otra cuenta | MVP |
| Error Apex inesperado | ERROR | No (MVP) | `errorCode`, `operationName` | Stack trace al buyer | MVP |
| Error LWC técnico | ERROR | No | código, contexto seguro | Datos sensibles en browser | MVP |
| Flow fault path | WARN/ERROR | No | nombre del Flow, código | Detalle técnico al buyer | MVP |
| Timeout integración | ERROR | Futuro | `endpointName`, `INT_TIMEOUT` | Tokens, URL sensible | Futuro |
| Response inválida | ERROR | Futuro | `endpointName`, `INT_INVALID_RESPONSE` | Payload sensible | Futuro |
| Reorder parcial | INFO | No | `orderId`, items excluidos | — | MVP |

---

## 22. Checklist de Review de Logging

- [ ] ¿El log aporta valor?
- [ ] ¿Está clasificado el evento?
- [ ] ¿Se evita información sensible?
- [ ] ¿No se expone al buyer?
- [ ] ¿Incluye contexto suficiente?
- [ ] ¿Evita ruido innecesario?
- [ ] ¿Está alineado con el manejo de errores?
- [ ] ¿Es temporal o persistente?
- [ ] ¿Si es persistente, está justificado?
- [ ] ¿Requiere ADR?
- [ ] ¿Está cubierto por testing si aplica?

---

## 23. Riesgos de Logging

- **Loguear datos sensibles**.
- **Loguear demasiado**.
- **Loguear demasiado poco**.
- Usar logs para **ocultar mal diseño**.
- **Exponer logs** al buyer.
- Dejar **`console.log` o `System.debug`** innecesarios.
- Crear **framework complejo** sin necesidad.
- Crear **objetos custom de log** prematuramente.
- **No poder correlacionar** errores críticos.
- Registrar **payloads externos completos**.
- **No sanitizar** logs.

---

## 24. ADRs Relacionados con Logging

Crear un ADR si:

- Se crea **logging persistente**.
- Se crea un **objeto custom de log**.
- Se usan **Platform Events** para logging.
- Se integra con un **sistema externo** de logging.
- Se introduce `correlationId` como **patrón general**.
- Se registra **request/response** de integraciones.
- Se loguean **eventos de seguridad** de forma persistente.
- Se crea un **framework centralizado** de logging.

---

## 25. Relación con Otros Documentos

- `docs/development/error-handling-guidelines.md` define la **clasificación y el
  manejo** de errores.
- Este documento define el **logging y la trazabilidad**.
- `docs/development/apex-guidelines.md` define las **reglas Apex**.
- `docs/development/lwc-guidelines.md` define las **reglas LWC**.
- `docs/development/flow-guidelines.md` define las **reglas Flow**.
- `docs/development/integration-guidelines.md` define las **reglas de integración**.
- `docs/development/code-review-checklist.md` debe **incluir estas reglas**.
- `docs/salesforce/security-model.md` define la **seguridad** Salesforce-relevante.
- `docs/testing/` deberá considerar **errores y trazabilidad**.
- `adr/` registrará las **decisiones relevantes de logging**.
