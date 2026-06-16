# Guidelines de Integración - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define los **criterios y buenas prácticas de desarrollo** para
integraciones en el proyecto `LvlUp-Wholesale-B2B`: cuándo integrar, cómo diseñar
contratos REST, cómo usar mocks, cuándo usar Apex callouts, y cómo manejar errores,
resiliencia, seguridad, trazabilidad y testing.

Sirve como base para:

- Decidir **cuándo integrar**.
- Evitar la **integración prematura**.
- Diseñar **contratos REST futuros**.
- Preparar la **integración simulada** con Postman Mock Server.
- Diseñar **Apex callouts** si se justifican.
- Definir el **manejo de errores** y la **resiliencia**.
- Definir el **testing de integración**.
- Guiar los **ADRs** relacionados con integración.

Este documento **no define una integración real ni contratos definitivos**. Es la
contraparte de desarrollo de `docs/architecture/integration-architecture.md`. La
prosa va en español; endpoints, DTOs, JSON, clases, métodos y comentarios en
inglés.

---

## 2. Principio Principal para Integraciones

> **No se debe integrar antes de necesitarlo.**

Orden de evaluación:

1. ¿El dato **vive en Salesforce**?
2. ¿Puede resolverse con **estándar/configuración**?
3. ¿Puede **representarse funcionalmente** para el MVP?
4. ¿Puede **simularse** con datos locales o documentación?
5. ¿Hace falta un **mock externo**?
6. ¿Hace falta un **Apex callout**?
7. ¿Hace falta **integración real**?
8. ¿Requiere **ADR**?

El **ERP real está fuera del MVP**. La integración inicial será **futura y
simulada**.

---

## 3. Cuándo Integrar

- El dato **no vive en Salesforce**.
- El proceso **depende de un sistema externo**.
- Se requiere validar **stock externo**.
- Se requiere validar **crédito externo**.
- Se requiere consultar **ETA externa**.
- Se requiere consultar **estado de pedido externo**.
- Se requiere consultar **facturas externas**.
- La **simulación aporta valor** técnico o arquitectónico.
- Existe un **contrato funcional claro**.
- Existe una **estrategia de testing**.

---

## 4. Cuándo Evitar Integración

- Si el caso está **fuera del MVP**.
- Si el dato puede **representarse localmente**.
- Si **no existe contrato funcional** todavía.
- Si **no se ha validado el estándar** Salesforce.
- Si la integración **solo complica el MVP**.
- Si **no hay estrategia de errores**.
- Si **no hay estrategia de testing**.
- Si **no hay ADR** para una integración relevante.
- Si se intenta **conectar el ERP real antes de tiempo**.

---

## 5. Sistemas de Integración Previstos

| Sistema | Tipo | Propósito | Estado | Observaciones |
| --- | --- | --- | --- | --- |
| Salesforce B2B Commerce | Plataforma | Núcleo del comercio | Activo | Fuente interna |
| Salesforce Data Layer | Datos | Cuentas, productos, pricing, pedidos | Activo | Fuente de verdad interna |
| Apex Integration Layer | Capa Apex (futura) | Encapsular callouts y mapeo | Futuro | Solo si se justifica |
| Named Credential | Configuración (futura) | Endpoint y autenticación | Futuro | Para callouts |
| Postman Mock Server | Simulación (futura) | Simular respuestas del ERP | Futuro | Enfoque inicial de simulación |
| ERP simulado | Externo simulado | Stock, pricing, crédito, ETA, estado, facturas | Futuro | Representado por el mock |
| ERP real | Externo | Datos reales | Fuera del MVP | Requiere ADRs y seguridad ampliada |

---

## 6. Casos de Integración Futura

### Stock Availability

- **Propósito.** Conocer la disponibilidad real por producto/SKU.
- **Cuándo se consultaría.** PLP/PDP y, sobre todo, antes de confirmar en checkout.
- **Pantallas impactadas.** PLP, PDP, carrito, checkout.
- **Resultado esperado.** Disponibilidad por SKU; bloqueo de cantidad no
  satisfacible.
- **Estado.** Futuro / pendiente de validación.

### Final Pricing

- **Propósito.** Obtener el precio final confirmado por el ERP.
- **Cuándo se consultaría.** Resolución de pricing y checkout.
- **Relación con pricing estándar.** Complementa/confirma el pricing por
  cuenta/Buyer Group.
- **Riesgo de inconsistencia.** Divergencia entre precio mostrado y precio final.
- **Estado.** Futuro / pendiente de validación.

### Credit Status

- **Propósito.** Conocer el estado/límite de crédito del cliente.
- **Cuándo se consultaría.** Al confirmar el pedido en checkout.
- **Impacto en checkout.** Puede impedir o condicionar la confirmación.
- **Estado.** Futuro / pendiente de validación.

### Estimated Delivery / ETA

- **Propósito.** Mostrar la fecha estimada de entrega.
- **Impacto UX.** Información en PDP/checkout/pedido.
- **Estado.** Futuro.

### Order Status

- **Propósito.** Reflejar el estado del pedido en el ERP.
- **Impacto en order history.** Estado del pedido en el historial/detalle.
- **Estado.** Futuro.

### Invoices

- **Propósito.** Consultar las facturas del cliente.
- **Impacto en My Account / historial.** Listado de facturas.
- **Estado.** Futuro.

---

## 7. Estrategia REST

- **REST** será el enfoque inicial.
- **JSON** será el formato esperado.
- Endpoints **simples y orientados a recursos**.
- Contratos **versionables**.
- **Diferenciar** errores funcionales y técnicos.
- **No diseñar endpoints definitivos** hasta la fase correspondiente.

**Ejemplos conceptuales (no definitivos):**

```text
GET  /stock
POST /pricing
GET  /credit-status
GET  /orders/{orderId}/status
GET  /invoices
```

> Estos endpoints solo ilustran la **forma**; rutas, parámetros, versionado y
> esquemas reales se definirán en la fase de simulación (decisión de ADR).

---

## 8. Contratos y DTOs

- Definir primero el **contrato funcional** (entrada/salida) por caso.
- Mapear request/response a **DTOs internos** (no usar estructuras externas por
  toda la app).
- Mantener los DTOs **inmutables y claros**.
- Versionar los contratos cuando cambien.

**Ejemplo conceptual de contrato de stock (ilustrativo, no definitivo):**

```json
// Request
{ "skus": ["LVL-CON-001", "LVL-LAP-001"] }

// Response
{
  "items": [
    { "sku": "LVL-CON-001", "available": true,  "quantity": 25 },
    { "sku": "LVL-LAP-001", "available": false, "quantity": 0 }
  ]
}
```

DTOs conceptuales en Apex (futuros): `StockRequest`, `StockResponse`,
`PricingRequest`, `PricingResult`, `CreditStatusResult`. Los nombres finales se
definen en la fase de integración.

---

## 9. Estrategia de Mocks / Postman Mock Server

- **Postman Mock Server** representa al ERP ficticio en la fase de simulación.
- Debe cubrir **escenarios**: éxito, casos límite (sin stock, crédito excedido) y
  errores/timeout.
- **No** tratar el mock como producción ni como contrato definitivo.
- En **tests de Apex**, los callouts se aíslan con **`HttpCalloutMock`** (no se
  llama al mock externo desde los tests).
- El mock permite **validar el comportamiento funcional** del storefront frente a
  respuestas controladas antes de cualquier integración real.

---

## 10. Apex Callouts

- **No hay callouts en el MVP**; aplica a la fase de integración.
- Usar **Named Credentials** para endpoint y autenticación; **nunca** hardcodear
  URLs ni secretos.
- Aislar las llamadas en una **capa de integración** (`*Client` / `*Callout`),
  separada de la lógica de negocio (coherente con `apex-guidelines.md` §6 y §11).
- Responsabilidades de la capa: construir request, ejecutar callout, interpretar
  response, **mapear a DTO interno**, manejar errores y traza.
- Considerar **callouts asíncronos** (Queueable) si el caso lo requiere.
- Introducir Apex de integración es una **decisión de ADR**.

---

## 11. Manejo de Errores

- **Diferenciar** error funcional (mensaje al buyer) de error técnico (traza).
- **Para el buyer**: mensajes claros y no técnicos, alineados con
  `empty-error-loading-states.md` (p. ej. "No pudimos comprobar la disponibilidad.
  Inténtalo de nuevo.").
- **No exponer** stack traces, payloads crudos ni detalles del sistema externo.
- Mapear los **códigos de error** del servicio a resultados internos claros.
- Definir el comportamiento ante **fallo del servicio** (degradar o reintentar).

---

## 12. Resiliencia

- Definir **timeouts** razonables para los callouts.
- Definir política de **reintentos** (cuándo sí/no; evitar tormentas de
  reintentos).
- Diseñar operaciones **idempotentes** cuando aplique.
- Prever **degradación funcional** si el sistema externo no responde (mensaje claro;
  no bloquear toda la experiencia sin explicación).
- Vigilar los **límites de callouts** de la plataforma.

---

## 13. Seguridad de Integración

- **Named Credentials** para gestionar endpoint y credenciales.
- **No hardcodear** URLs, tokens ni secretos en código o metadata.
- **Mínimo dato** expuesto a la integración y desde ella.
- **No exponer** datos sensibles del ERP al frontend más allá de lo necesario.
- **No exponer** errores técnicos al buyer.
- Tratar **crédito, stock, pricing y facturas** con cuidado adicional.
- Coherente con `security-architecture.md` y `security-model.md`.

---

## 14. Trazabilidad y Logging

- Registrar las llamadas y errores de forma **controlada** (sin datos sensibles).
- Mantener **correlación funcional** (cuenta, pedido, carrito, llamada).
- **No** registrar payloads completos con datos sensibles.
- La estrategia de logging detallada se define en `docs/development/logging-guidelines.md`
  *(previsto)*.

---

## 15. Testing de Integración

- **Mocks obligatorios** (`HttpCalloutMock` / `Test.setMock`) para aislar callouts
  en los tests de Apex.
- Probar **escenarios**: éxito, sin stock, crédito excedido, error/timeout.
- Validar el **mapeo** request/response → DTO interno.
- Validar el **manejo de errores** y la **resiliencia** (timeouts/reintentos).
- Complementar con **validación funcional** frente al Postman Mock Server.
- Derivar los casos a `docs/testing/` y, donde aplique, a `evals/`.

**Ejemplo conceptual de mock de callout (Apex):**

```apex
@isTest
private class StockClientTest {
    private class StockMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"items":[{"sku":"LVL-CON-001","available":true,"quantity":25}]}');
            return res;
        }
    }
    // @isTest method would set Test.setMock and assert the mapped StockResponse
}
```

---

## 16. Naming de Artefactos de Integración

- Clases de integración en **PascalCase** con sufijo claro: `*Client`, `*Callout`,
  `*Service`, `*Mock`.
- DTOs en **PascalCase**: `*Request`, `*Response`, `*Result`.
- Métodos en **camelCase** que reflejen la operación (`getStockBySku`,
  `validateCreditStatus`).
- **Comentarios en inglés**; documentación funcional en español.
- Evitar nombres genéricos (`IntegrationUtils`, `ApiManager`) sin justificación.

---

## 17. Anti-patrones a Evitar

- **Integrar antes de necesitarlo** o conectar el ERP real prematuramente.
- **Hardcodear** endpoints/credenciales.
- **SOQL/DML/callouts en bucles**.
- **Exponer errores técnicos** o payloads crudos al buyer.
- Usar estructuras del sistema externo **por toda la app** (sin DTOs internos).
- **Tests sin mocks** que dependan del sistema externo.
- **Inventar contratos definitivos** prematuramente.
- Integración **sin estrategia de errores/resiliencia**.
- Introducir Apex de integración **sin ADR**.

---

## 18. Checklist antes de Integrar

- [ ] ¿El dato vive fuera de Salesforce?
- [ ] ¿Se validó el estándar/configuración antes?
- [ ] ¿Puede representarse/simularse en el MVP en su lugar?
- [ ] ¿Existe un contrato funcional claro?
- [ ] ¿Se usan Named Credentials (sin secretos en código)?
- [ ] ¿La integración está aislada en su capa y es mockeable?
- [ ] ¿Hay manejo de errores y resiliencia (timeouts/reintentos)?
- [ ] ¿Se respeta la seguridad (mínimo dato, no exponer al front)?
- [ ] ¿Hay estrategia de testing con mocks?
- [ ] ¿Requiere un ADR?

---

## 19. Fases de Integración

1. **Fase 0 — Documental (MVP).** Contratos funcionales y escenarios documentados;
   **sin callouts**.
2. **Fase 1 — Simulación.** Postman Mock Server respondiendo a los contratos;
   primeros callouts con Named Credentials y **mocks en tests**.
3. **Fase 2 — Integración real (fuera del alcance actual).** Conexión a un ERP real;
   requiere **ADRs**, seguridad y testing ampliados.

Cada avance de fase es una **decisión explícita** y, cuando aplique, un **ADR**.
Coherente con `integration-architecture.md` §16.

---

## 20. Relación con ADRs

Crear un ADR cuando:

- Se introducen **callouts** desde Salesforce.
- Se adopta el **patrón de integración** y sus contratos.
- Se pasa de **documentación a simulación** (Postman Mock Server).
- Se introduce **Apex de integración**.
- Se avanza hacia **integración real**.

---

## 21. Supuestos y Decisiones Pendientes

**Supuestos.**

- El **ERP real está fuera** del MVP.
- La simulación inicial será **REST + Postman Mock Server**.
- En el MVP **no hay callouts**.
- Los **contratos se documentan** antes de simularse.
- Los ejemplos de este documento son **conceptuales**.

**Decisiones pendientes.**

- Contratos concretos (campos, operaciones, esquemas).
- Momento de introducir el Postman Mock Server (`DEC-016`).
- Qué datos se simulan primero (probablemente stock y crédito).
- Estrategia de errores, timeouts y reintentos.
- Sincronía vs asincronía por caso.
- Estrategia de versionado de contratos.

---

## 22. Relación con Otros Documentos

- `docs/architecture/integration-architecture.md` define la **arquitectura
  conceptual** de integración.
- Este documento define las **guidelines de desarrollo** de integración.
- `docs/development/apex-guidelines.md` define los **callouts y la capa Apex**.
- `docs/development/logging-guidelines.md` *(previsto)* definirá el **logging**.
- `docs/salesforce/security-model.md` y `docs/architecture/security-architecture.md`
  definen la **seguridad** de integración.
- `docs/ux/empty-error-loading-states.md` define los **mensajes** ante errores.
- `docs/testing/` deberá definir el **testing** detallado.
- `adr/` registrará las **decisiones de integración**.
