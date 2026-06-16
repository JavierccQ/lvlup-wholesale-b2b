# Casos de Prueba de Integración - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define un **catálogo de casos de prueba de integración** para la
**futura integración REST simulada** del proyecto `LvlUp-Wholesale-B2B` (mediante
Postman Mock Server u otro mecanismo equivalente), cubriendo stock, crédito, precio
final, ETA, estado de pedido y facturas.

Sirve como base para: integration testing, mock testing, Apex callout testing (si
aplica), error handling, logging y trazabilidad, validación de contratos REST,
validación de seguridad, regresión futura y ADRs de integración.

Este documento **no implementa integraciones ni define contratos definitivos**. La
prosa va en español; endpoints, payload fields, HTTP status, DTOs, clases Apex y
mocks en inglés.

> **Nota de formato:** plantilla completa en la §4 y el resto en **tablas
> compactas**. **Estado inicial:** como la integración es **futura**, los casos
> están en **Futuro** o **Pendiente** (de contrato/mock/Apex), no en ejecución.

---

## 2. Alcance de Integración

### Incluido como futuro / mock

Stock availability, final pricing, credit status, ETA, order status, invoices,
timeout handling, invalid response handling, HTTP error handling, mock responses,
y callout testing si existe Apex.

### Fuera del MVP

ERP real, autenticación productiva real, pagos reales, tax real, shipping real,
OMS avanzado, facturación real, integración productiva multiambiente y
observabilidad enterprise.

---

## 3. Principios de Testing de Integración

- **No probar ERP real** dentro del MVP.
- **Probar con mocks** antes de la integración real.
- **No hardcodear** endpoints, IDs ni secrets.
- Usar **Named Credentials** si hay callouts en Salesforce.
- **No exponer errores técnicos** al buyer.
- **No registrar tokens** ni payloads sensibles completos.
- Validar **success, functional error y technical error**.
- Validar **timeout** y **response inválida**.
- Validar **seguridad por buyer account**.
- Validar que el **checkout no continúe** si falla una validación crítica.
- Crear **ADR** si la integración cambia arquitectura o flujo crítico.

---

## 4. Convención de Casos de Prueba

Plantilla: **ID**, **Nombre**, **Área**, **Prioridad**, **Estado**, **Tipo de
integración**, **Actor / sistema**, **Precondiciones**, **Datos requeridos**,
**Request conceptual**, **Response conceptual**, **Pasos conceptuales**,
**Resultado esperado**, **Resultado no permitido**, **Riesgo cubierto**, **Logging
esperado**, **Documentos relacionados**, **Notas / gaps**.

Prefijos: `ITC-STOCK`, `ITC-PRICE`, `ITC-CREDIT`, `ITC-ETA`, `ITC-ORDER`,
`ITC-INVOICE`, `ITC-HTTP`, `ITC-TIMEOUT`, `ITC-SEC`, `ITC-LOG`, `ITC-MOCK`.

**Ejemplo en ficha completa:**

- **ID:** `ITC-STOCK-002`
- **Nombre:** Stock insuficiente
- **Área:** Stock availability
- **Prioridad:** Alta
- **Estado:** Futuro
- **Tipo de integración:** REST (mock)
- **Actor / sistema:** Storefront ↔ ERP simulado
- **Precondiciones:** Mock disponible; producto con stock insuficiente
- **Datos requeridos:** SKU con `available: false`
- **Request conceptual:** `{ "skus": ["LVL-CON-001"] }`
- **Response conceptual:** `{ "items": [{ "sku": "LVL-CON-001", "available": false, "quantity": 0 }] }`
- **Pasos conceptuales:** Consultar stock → recibir insuficiente → reflejar en
  cart/checkout
- **Resultado esperado:** "Stock insuficiente para la cantidad solicitada." y
  bloqueo/condición
- **Resultado no permitido:** Confirmar una cantidad no satisfacible
- **Riesgo cubierto:** Business rule integrity
- **Logging esperado:** Evento funcional (sin datos sensibles)
- **Documentos relacionados:** `integration-architecture.md`,
  `integration-guidelines.md`
- **Notas / gaps:** Contrato y mock pendientes

---

## 5. Estados de Caso de Integración

| Estado | Significado | Acción siguiente |
| --- | --- | --- |
| No ejecutado | Aún no probado | Programar (cuando exista mock) |
| Ejecutado exitosamente | Pasó | Registrar evidencia |
| Fallido | No pasó | Registrar defecto |
| Bloqueado | No se puede ejecutar | Desbloquear dependencia |
| Pendiente de contrato | Falta el contrato | Definir contrato |
| Pendiente de mock | Falta el mock | Crear mock |
| Pendiente de Apex | Falta el callout | Implementar Apex (con ADR) |
| Pendiente de Named Credential | Falta config de callout | Configurar Named Credential |
| Pendiente de validación en org | Capacidad no verificada | Validar en la org |
| Futuro | Fase posterior | Diferir |
| Fuera del MVP | No aplica | Diferir |
| Requiere ADR | Implica decisión | Crear ADR |

---

## 6. Contratos Conceptuales

Endpoints **conceptuales, no definitivos** (coherentes con
`integration-guidelines.md`):

| Endpoint conceptual | Propósito | Entrada conceptual | Salida conceptual | Uso en Salesforce | Estado |
| --- | --- | --- | --- | --- | --- |
| `/stock-availability` | Disponibilidad por SKU | `skus[]` | `items[]` con `available`, `quantity` | PLP/PDP/cart/checkout | Futuro / pendiente |
| `/final-pricing` | Precio final | `sku`, cuenta/Buyer Group | `finalPrice` | Pricing/checkout | Futuro / pendiente |
| `/credit-status` | Estado de crédito | cuenta | `creditStatus`, `availableCredit` | Checkout | Futuro / pendiente |
| `/eta` | Fecha estimada | `sku`, `quantity` | `eta` | PDP/checkout | Futuro |
| `/orders/{orderId}/status` | Estado de pedido | `orderId` | `status` | Historial | Futuro |
| `/invoices` | Facturas del cliente | cuenta | `invoices[]` | My Account | Futuro |

> No se definen contratos productivos cerrados; campos/rutas/esquemas se confirman
> en la fase de integración (ADR).

---

## 7. Datos Base para Pruebas de Integración

**Buyer Accounts:** Gaming Store Madrid, Tech Reseller Iberia, IT Solutions SMB,
Enterprise Gaming Procurement.

**Productos:** con stock suficiente / insuficiente / sin stock; con precio final
válido / sin precio final; con ETA / sin ETA.

**Crédito:** buyer con crédito válido / bloqueado / excedido / no disponible.

**Orders:** confirmado; pendiente de aprobación; no encontrado; perteneciente a
otra buyer account.

> Los datos definitivos dependen de `data-loading-strategy.md` y del mock.

---

## 8. Casos de Stock Availability

| ID | Caso | Resultado esperado | Riesgo cubierto | ¿Bloquea checkout? | Estado |
| --- | --- | --- | --- | --- | --- |
| ITC-STOCK-001 | Stock suficiente | Continúa el flujo | Business rule integrity | No | Futuro |
| ITC-STOCK-002 | Stock insuficiente | Aviso y bloqueo/condición | Business rule integrity | Sí (si crítico) | Futuro |
| ITC-STOCK-003 | Stock no disponible | "Este producto no tiene stock disponible." | Business rule integrity | Sí | Futuro |
| ITC-STOCK-004 | Producto no encontrado | Mensaje funcional seguro | Information disclosure | Según caso | Futuro |
| ITC-STOCK-005 | Response inválida | Manejo técnico seguro, mensaje neutro | Technical resilience | Si es crítico | Pendiente de mock |
| ITC-STOCK-006 | Timeout | No confirma si stock es crítico | Technical resilience | Sí | Pendiente de mock |

---

## 9. Casos de Final Pricing

| ID | Caso | Resultado esperado | Riesgo cubierto | ¿Bloquea checkout? | Estado |
| --- | --- | --- | --- | --- | --- |
| ITC-PRICE-001 | Precio final válido | Precio aplicable | Pricing integrity | No | Futuro |
| ITC-PRICE-002 | Precio final no disponible | "El precio no está disponible…" y bloqueo si aplica | Pricing integrity | Sí | Futuro |
| ITC-PRICE-003 | Precio final cambia respecto al cart | "El precio… se ha actualizado." | Pricing integrity | Hasta revisar | Futuro |
| ITC-PRICE-004 | Precio final para buyer incorrecto | Se rechaza | Pricing isolation | Sí | Futuro |
| ITC-PRICE-005 | Response inválida | Manejo técnico seguro | Technical resilience | Si es crítico | Pendiente de mock |
| ITC-PRICE-006 | Timeout | No continúa con precio incierto | Pricing integrity | Sí | Pendiente de mock |

---

## 10. Casos de Credit Status

| ID | Caso | Resultado esperado | Riesgo cubierto | ¿Bloquea checkout? | Estado |
| --- | --- | --- | --- | --- | --- |
| ITC-CREDIT-001 | Crédito válido | Continúa | Business rule integrity | No | Futuro |
| ITC-CREDIT-002 | Crédito bloqueado | Impide/condiciona | Business rule integrity | Sí | Futuro |
| ITC-CREDIT-003 | Crédito excedido | Order total > disponible se maneja | Business rule integrity | Sí | Futuro |
| ITC-CREDIT-004 | Crédito no disponible | Mensaje funcional, estado seguro | Information disclosure | Según regla | Futuro |
| ITC-CREDIT-005 | Response inválida | Manejo técnico seguro | Technical resilience | Si es crítico | Pendiente de mock |
| ITC-CREDIT-006 | Timeout | No confirma si crédito es crítico | Technical resilience | Sí | Pendiente de mock |

---

## 11. Casos de ETA

| ID | Caso | Resultado esperado | Riesgo cubierto | ¿Bloquea checkout? | Estado |
| --- | --- | --- | --- | --- | --- |
| ITC-ETA-001 | ETA disponible | Se muestra si está permitida | Functional | No | Futuro |
| ITC-ETA-002 | ETA no disponible | Ausencia controlada/mensaje | Functional | No | Futuro |
| ITC-ETA-003 | ETA parcial | Comportamiento parcial claro | Functional | No | Futuro |
| ITC-ETA-004 | Response inválida | Manejo seguro | Technical resilience | No | Pendiente de mock |
| ITC-ETA-005 | Timeout | No bloquea si ETA no es crítica (salvo decisión) | Technical resilience | No | Pendiente de mock |

---

## 12. Casos de Order Status

| ID | Caso | Resultado esperado | Riesgo cubierto | Estado |
| --- | --- | --- | --- | --- |
| ITC-ORDER-001 | Estado confirmado | Estado correcto | Functional | Futuro |
| ITC-ORDER-002 | Estado pendiente | Estado correcto | Functional | Futuro |
| ITC-ORDER-003 | En preparación | Estado correcto | Functional | Futuro |
| ITC-ORDER-004 | Pedido no encontrado | Mensaje seguro | Information disclosure | Futuro |
| ITC-ORDER-005 | Pedido de otra cuenta | Rechazo; sin exponer datos ajenos | Account isolation | Futuro |
| ITC-ORDER-006 | Response inválida | Manejo técnico seguro | Technical resilience | Pendiente de mock |
| ITC-ORDER-007 | Timeout | Degradación segura | Technical resilience | Pendiente de mock |

---

## 13. Casos de Invoices

| ID | Caso | Resultado esperado | Riesgo cubierto | Estado |
| --- | --- | --- | --- | --- |
| ITC-INVOICE-001 | Facturas disponibles | Listado de su cuenta | Functional | Futuro |
| ITC-INVOICE-002 | Buyer sin facturas | Empty state seguro | Information disclosure | Futuro |
| ITC-INVOICE-003 | Factura no encontrada | Mensaje seguro | Information disclosure | Futuro |
| ITC-INVOICE-004 | Factura de otra cuenta | Rechazo | Account isolation | Futuro |
| ITC-INVOICE-005 | Response inválida | Manejo seguro | Technical resilience | Pendiente de mock |
| ITC-INVOICE-006 | Timeout | Degradación segura | Technical resilience | Pendiente de mock |

> La **facturación real está fuera del MVP**.

---

## 14. Casos HTTP Genéricos

| ID | Caso | Tipo de error | Mensaje buyer | Retry | Logging | ¿Bloquea? | Estado |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ITC-HTTP-001 | 200 success | — | — | — | INFO opcional | No | Futuro |
| ITC-HTTP-002 | 400 bad request | Técnico | "No pudimos procesar la solicitud." | No | ERROR | Según caso | Futuro |
| ITC-HTTP-003 | 401 unauthorized | Técnico/seguridad | "No pudimos completar la operación." | No | ERROR (sin token) | Sí | Futuro |
| ITC-HTTP-004 | 403 forbidden | Seguridad | "No pudimos completar la operación." | No | ERROR | Sí | Futuro |
| ITC-HTTP-005 | 404 not found | Funcional/técnico | "La información no está disponible." | No | WARN | Según caso | Futuro |
| ITC-HTTP-006 | 409 conflict | Técnico | "No pudimos completar la operación." | No | WARN | Según caso | Futuro |
| ITC-HTTP-007 | 429 rate limited | Técnico | "Inténtalo de nuevo en unos minutos." | Limitado | WARN | Según caso | Futuro |
| ITC-HTTP-008 | 500 server error | Técnico | "El servicio no está disponible ahora." | Limitado | ERROR | Si es crítico | Futuro |
| ITC-HTTP-009 | 503 service unavailable | Técnico | "El servicio no está disponible ahora." | Limitado | ERROR | Si es crítico | Futuro |

---

## 15. Casos de Timeout y Retry

| ID | Caso | Resultado esperado | Riesgo cubierto | Estado |
| --- | --- | --- | --- | --- |
| ITC-TIMEOUT-001 | Timeout en validación crítica de checkout | No confirma; mensaje seguro | Business rule integrity | Futuro |
| ITC-TIMEOUT-002 | Timeout en consulta no crítica (ETA) | No bloquea (salvo decisión) | Technical resilience | Futuro |
| ITC-TIMEOUT-003 | Retry limitado ante error temporal | Reintento acotado | Technical resilience | Pendiente de ADR |
| ITC-TIMEOUT-004 | No retry ante error funcional | Sin reintento | Correctness | Futuro |
| ITC-TIMEOUT-005 | Validación crítica incierta | No confirma | Business rule integrity | Futuro |

> La **política de retry definitiva requiere ADR** si se implementa.

---

## 16. Casos de Seguridad en Integración

| ID | Caso | Resultado esperado | Riesgo cubierto | Estado |
| --- | --- | --- | --- | --- |
| ITC-SEC-001 | Request usa buyer account correcta | Contexto correcto | Account isolation | Futuro |
| ITC-SEC-002 | Response de otra buyer account se rechaza | Rechazo | Account isolation | Futuro |
| ITC-SEC-003 | No se expone endpoint/token al buyer | Sin fuga | Secret exposure | Futuro |
| ITC-SEC-004 | No se loguean secrets | Logs sanitizados | Secret exposure | Futuro |
| ITC-SEC-005 | Producto restringido no se valida como comprable | Restricción respetada | Backend enforcement | Futuro |
| ITC-SEC-006 | Pricing externo no rompe visibilidad Salesforce | Visibilidad intacta | Catalog/pricing integrity | Futuro |

---

## 17. Casos de Logging en Integración

| ID | Caso | Resultado esperado | Riesgo cubierto | Estado |
| --- | --- | --- | --- | --- |
| ITC-LOG-001 | Timeout trazable internamente | Registro seguro (`INT_TIMEOUT`) | Traceability | Futuro |
| ITC-LOG-002 | Response inválida trazable | Registro seguro (`INT_INVALID_RESPONSE`) | Traceability | Futuro |
| ITC-LOG-003 | Error funcional que bloquea checkout trazable | Registro con correlación segura | Traceability | Futuro |
| ITC-LOG-004 | Logs sin tokens ni secrets | Logs sanitizados | Secret exposure | Futuro |
| ITC-LOG-005 | Logs sin payload sensible completo | Logs resumidos/sanitizados | Data exposure | Futuro |
| ITC-LOG-006 | Correlation ID se mantiene si se adopta | Correlación consistente | Traceability | Futuro / pendiente de ADR |

---

## 18. Casos de Mock Server

| ID | Caso | Resultado esperado | Estado |
| --- | --- | --- | --- |
| ITC-MOCK-001 | Mock devuelve success response | Flujo de éxito validado | Pendiente de mock |
| ITC-MOCK-002 | Mock devuelve functional error | Manejo funcional validado | Pendiente de mock |
| ITC-MOCK-003 | Mock devuelve technical error | Manejo técnico seguro | Pendiente de mock |
| ITC-MOCK-004 | Mock devuelve invalid JSON | Parsing seguro | Pendiente de mock |
| ITC-MOCK-005 | Mock simula timeout | Manejo de timeout | Pendiente de mock |
| ITC-MOCK-006 | Mock simula unauthorized | Manejo seguro | Pendiente de mock |
| ITC-MOCK-007 | Mock simula buyer mismatch | Rechazo por aislamiento | Pendiente de mock |

> **Postman Mock Server** es una opción futura, no una herramienta cerrada
> definitivamente (decisión de ADR).

---

## 19. Testing Apex Callout

*(Solo si se implementa Apex; coherente con `apex-guidelines.md` §11–§12 y
`integration-guidelines.md`.)*

Casos: success callout, HTTP error, timeout, invalid response, missing required
field, functional error, security mismatch, retry (si aplica), logging (si aplica).

- Debe usarse **`HttpCalloutMock`**; **no** depender de servicios reales.
- **Sin IDs/endpoints/secrets hardcodeados**; Named Credentials.
- Introducir Apex de integración es una **decisión de ADR**.

---

## 20. Testing de UI ante Integración

*(Solo si la UI consume resultados integrados; coherente con `lwc-guidelines.md` y
`empty-error-loading-states.md`.)*

- Loading state durante la consulta.
- Error funcional visible (mensaje claro).
- Error técnico seguro (sin detalle).
- Retry manual si aplica.
- **Checkout bloqueado** si una validación crítica falla.
- ETA no bloquea si se decide no crítica.
- Precio final actualizado se comunica claramente.
- Crédito bloqueado se comunica claramente.
- Stock insuficiente se comunica claramente.

---

## 21. Matriz de Priorización

Resumen por área (el detalle por caso está en las secciones 8–18).

| Área | Riesgo cubierto | Prioridad | MVP/Futuro/Pendiente | Dependencia | Estado |
| --- | --- | --- | --- | --- | --- |
| Stock availability | Business rule integrity | Alta | Futuro | Mock/contrato | Futuro |
| Final pricing | Pricing integrity | Alta | Futuro | Mock/contrato | Futuro |
| Credit status | Business rule integrity | Alta | Futuro | Mock/contrato | Futuro |
| ETA | Functional | Media | Futuro | Mock | Futuro |
| Order status | Functional/account isolation | Media | Futuro | Mock | Futuro |
| Invoices | Account isolation | Media | Futuro | Mock | Futuro |
| HTTP genéricos | Technical resilience | Alta | Futuro | Mock | Futuro |
| Timeout/Retry | Technical resilience | Alta | Futuro/ADR | Política de retry | Pendiente de ADR |
| Seguridad | Account/secret exposure | Alta | Futuro | Callout/Named Cred | Futuro |
| Logging | Traceability | Media | Futuro | Logging | Futuro |
| Mock Server | Test enablement | Alta | Pendiente | Postman Mock | Pendiente de mock |

---

## 22. Casos Fuera del MVP

| Caso | Motivo de exclusión | Fase futura posible | Riesgo si se adelanta |
| --- | --- | --- | --- |
| ERP real | Dependencia externa | Tras simulación | Acoplamiento prematuro |
| Auth productiva OAuth real | No requerida aún | Futuro | Complejidad de identidad |
| Pagos reales | Fuera del MVP | Futuro posible | Cumplimiento |
| Tax real | Fuera del MVP | Futuro posible | Esfuerzo desviado |
| Shipping real | Fuera del MVP | Futuro posible | Esfuerzo desviado |
| OMS avanzado | Historial básico suficiente | Futuro posible | Sobre-ingeniería |
| Facturación real | Fuera del MVP | Futuro | Acoplamiento |
| SLA/performance enterprise | No aplica al MVP | Futuro | Sobredimensionar |
| Observabilidad enterprise | No aplica al MVP | Futuro | Sobredimensionar |
| Multi-org integration deployment | No aplica al MVP | Futuro | Complejidad |

---

## 23. Registro de Ejecución

```markdown
## Ejecución de Caso de Integración

**ID:**
**Fecha:**
**Ejecutado por:**
**Mock / servicio usado:**
**Buyer usado:**
**Datos usados:**
**Request conceptual:**
**Response recibida:**
**Resultado:** Pass / Fail / Blocked / Pending
**Resultado real:**
**Logging observado:**
**Defecto o gap:**
**Requiere ADR:** Sí / No
**Documento a actualizar:**
```

---

## 24. Gestión de Gaps de Integración

Un gap debe registrarse con: **ID**, **caso afectado**, **descripción**, **área**,
**riesgo**, **severidad**, **contrato afectado**, **alternativa estándar
evaluada**, **posible solución**, **¿requiere Apex?**, **¿requiere Named
Credential?**, **¿requiere mock?**, **¿requiere ADR?** y **estado**.

Los gaps se reflejan en `configuration-decisions.md` y, si implican una decisión
relevante, en `adr/`.

---

## 25. Severidad de Defectos de Integración

| Severidad | Descripción | Ejemplo | Acción recomendada |
| --- | --- | --- | --- |
| Critical | Validación crítica omitida | Checkout confirma con crédito fallido | Bloquear; corregir de inmediato; ADR |
| High | Exposición/uso indebido de datos | Pricing externo muestra precio de otro buyer | Corregir antes de avanzar |
| Medium | Error técnico mal manejado | ETA no disponible muestra error técnico | Corregir manejo de error |
| Low | Mensaje mejorable sin fuga | Mensaje de error poco claro | Mejorar microcopy |

---

## 26. ADRs Relacionados con Integración

Crear un ADR si:

- Se adopta **Postman Mock Server** como estándar.
- Se define un **contrato REST estable**.
- Se implementa un **Apex callout**.
- Se introduce un **Named Credential**.
- Se define una **retry policy**.
- Se **bloquea checkout** por integración externa.
- Se **registra request/response**.
- Se introduce **correlation ID**.
- Se **conecta el ERP real** en una fase futura.

---

## 27. Relación con Otros Documentos

- `docs/testing/test-strategy.md` define la **estrategia general**.
- `docs/testing/functional-test-cases.md` define los **casos funcionales**.
- `docs/testing/security-test-cases.md` define los **casos de seguridad**.
- Este documento define los **casos de integración**.
- `docs/architecture/integration-architecture.md` define la **arquitectura
  conceptual**.
- `docs/development/integration-guidelines.md` define las **reglas de integración**.
- `docs/development/error-handling-guidelines.md` define los **errores**.
- `docs/development/logging-guidelines.md` define la **trazabilidad**.
- `docs/development/apex-guidelines.md` aplica si hay **callouts Apex**.
- `docs/salesforce/security-model.md` define la **seguridad Salesforce-relevante**.
- `adr/` se usa para las **decisiones relevantes**.
