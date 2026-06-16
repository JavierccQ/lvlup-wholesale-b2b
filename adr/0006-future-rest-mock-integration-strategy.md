# ADR-0006 - Future REST Mock Integration Strategy

## Estado

Accepted

## Fecha

2026-06-16

## Contexto

- `LvlUp-Wholesale-B2B` busca simular un proyecto empresarial real de Salesforce B2B
  Commerce.
- En una implementación real, datos como stock, crédito, ETA, estado de pedido o
  facturas podrían venir desde un **ERP** u otros sistemas externos.
- Sin embargo, ERP real e integración productiva real están **fuera del MVP**.
- El proyecto necesita una estrategia que permita **practicar integración** sin
  introducir complejidad productiva prematura.
- La integración REST simulada futura permitirá practicar contratos API, Named
  Credentials, Apex callouts, DTOs, manejo de errores, testing con mocks y validación
  de escenarios de checkout.
- Esta integración **no** debe reemplazar capacidades estándar de Salesforce B2B
  Commerce si estas cubren el caso.
- Este ADR formaliza **cómo y cuándo** introducir integración REST mock en el proyecto,
  y recoge la integración que `0005` delegó aquí.

---

## Decisión

El proyecto adoptará una estrategia de integración futura basada en **REST mock antes
de cualquier integración real**.

La estrategia será:

1. Mantener el ERP real **fuera del MVP**.
2. Mantener la integración productiva real **fuera del MVP**.
3. Usar integración REST simulada solo cuando exista **valor claro de aprendizaje** o
   validación técnica.
4. Definir primero el **contrato funcional** antes de Apex.
5. Definir payloads request/response claros.
6. Simular respuestas de stock, crédito, precio final, ETA, estado de pedido y facturas
   si aplica.
7. Usar **Named Credential** si se implementa callout desde Salesforce.
8. **No** hardcodear endpoints ni secrets.
9. Usar Apex callout solo si existe **gap validado** y decisión arquitectónica.
10. Usar **mocks** en tests.
11. Cubrir success, functional error, HTTP error, timeout, invalid response y missing
    fields.
12. **No** confirmar checkout si una validación crítica externa queda incierta.
13. Mantener los mensajes al buyer **seguros y funcionales**.
14. Registrar cualquier integración implementada en documentación y testing.

**Postman Mock Server** puede evaluarse como opción práctica para simular endpoints,
pero **no** debe tratarse como herramienta obligatoria hasta validarlo.

---

## Alternativas Consideradas

### Alternativa 1 - REST mock futuro con contrato controlado

Descripción:

- Simular servicios externos mediante mock REST.
- Definir contratos claros.
- Probar callouts, errores, DTOs y testing.
- Mantener el ERP real fuera del MVP.

Resultado: **alternativa aceptada**.

### Alternativa 2 - Conectar ERP real desde el inicio

Descripción:

- Integrar directamente con un ERP real para stock, crédito, pedidos y facturas.

Resultado: **rechazada** porque el ERP real está fuera del MVP y aumentaría
complejidad, seguridad, credenciales, deployment y testing.

### Alternativa 3 - No practicar integración

Descripción:

- Mantener el proyecto únicamente con Salesforce estándar, configuración y datos.

Resultado: **rechazada parcialmente** porque el objetivo del proyecto incluye practicar
arquitectura Salesforce + integraciones simuladas, aunque en una fase posterior.

### Alternativa 4 - Simular integración solo con datos estáticos en Salesforce

Descripción:

- Modelar stock, crédito y estados como campos o registros internos sin callout.

Resultado: **aceptable para fases iniciales**, pero insuficiente para practicar
callouts, contratos REST, mocks y error handling.

### Alternativa 5 - Crear framework de integración enterprise completo

Descripción:

- Diseñar un framework genérico de integración, retries, observabilidad, logs
  persistentes y múltiples proveedores.

Resultado: **rechazada** por sobre-ingeniería para el MVP y la Developer Org.

---

## Consecuencias

### Positivas

- Permite practicar integración sin ERP real.
- Reduce la complejidad del MVP.
- Evita la dependencia de sistemas externos reales.
- Facilita probar errores controlados.
- Permite practicar Apex callouts y mocks.
- Permite validar contratos REST.
- Mejora la preparación para entrevistas técnicas.
- Mantiene la seguridad y los secretos bajo control.
- Permite evolucionar el proyecto gradualmente.
- Refuerza la separación entre el MVP actual y la integración futura.

### Negativas / Trade-offs

- No representa una integración productiva completa.
- Los datos externos serán simulados.
- No valida latencias o restricciones reales de ERP.
- Puede requerir mantenimiento de contratos mock.
- Puede requerir decisiones adicionales sobre logging, retries y fallback.
- Si se implementa callout, aumenta el testing técnico.
- Si afecta al checkout, aumenta el riesgo funcional y la regresión.

---

## Impacto en el Proyecto

### MVP

La integración real queda **fuera del MVP**. La integración mock es futura y solo debe
introducirse cuando el proyecto haya estabilizado capacidades estándar y datos
Commerce.

### Salesforce B2B Commerce

La integración mock **no** debe reemplazar funcionalidades estándar si estas cubren el
caso.

### Seguridad

**No** deben hardcodearse endpoints, tokens ni secrets. El **Named Credential** debe
evaluarse si se implementa callout.

### Pricing / Visibility

Pricing y visibility estándar siguen siendo prioridad (fuente de verdad: `0004`). El
precio final externo solo debe evaluarse como futuro y con mucho cuidado.

### Checkout

Stock y crédito externos simulados pueden afectar el checkout, por lo que cualquier
validación incierta **no** debe confirmar pedidos críticos sin control (alineado con
`0005`).

### Datos / Metadata

La integración mock debe **convivir** con los datos Commerce internos y no sustituirlos
sin decisión explícita.

### Integración

Este ADR es la **fuente de verdad principal** para la integración REST mock futura.

### Testing

Toda integración debe cubrir success, errores funcionales, HTTP errors, timeouts,
invalid responses y missing fields.

### Documentación

`integration-architecture.md`, `integration-guidelines.md`, `integration-test-cases.md`,
`error-handling-guidelines.md` y `logging-guidelines.md` deben mantenerse alineados.

---

## Servicios Mock Candidatos

Posibles servicios futuros, **sin implementarlos todavía**:

### Stock Service

Propósito:

- Consultar la disponibilidad funcional de producto.

Datos posibles:

- `productCode`
- `availableQuantity`
- `status`
- `eta`

Estados conceptuales:

- `available`
- `insufficient`
- `unavailable`
- `unknown`

### Credit Service

Propósito:

- Consultar el estado funcional de crédito del buyer account.

Datos posibles:

- `accountCode`
- `creditStatus`
- `availableCredit`
- `creditLimit`

Estados conceptuales:

- `valid`
- `blocked`
- `exceeded`
- `unavailable`

### Final Price Service

Propósito:

- Simular un precio final externo si en una fase futura se decide practicar pricing
  externo.

Advertencia:

- **No** debe reemplazar Price Books dentro del MVP sin ADR adicional o actualización
  explícita.

### ETA Service

Propósito:

- Simular la fecha estimada de disponibilidad o entrega.

Advertencia:

- El shipping real está fuera del MVP.

### Order Status Service

Propósito:

- Simular el estado externo de un pedido.

Advertencia:

- El OMS avanzado está fuera del MVP.

### Invoice Service

Propósito:

- Simular la consulta de facturas.

Advertencia:

- La facturación real está fuera del MVP.

---

## Principios de Diseño de Contratos REST

- Contratos simples.
- JSON claro.
- Campos funcionales, no excesivos.
- Versionado conceptual si aplica.
- Códigos de estado claros.
- Errores funcionales separados de errores técnicos.
- No exponer datos sensibles.
- No acoplar la UI directamente al contrato externo.
- No depender de IDs internos de Salesforce como contrato externo.
- Usar identificadores funcionales cuando aplique.
- Documentar request, response y errores esperados.
- Mantener payloads estables para testing.

---

## Error Handling Esperado

Cualquier integración mock debe contemplar:

- Success response.
- Functional error.
- HTTP 400.
- HTTP 401/403.
- HTTP 404.
- HTTP 500.
- Timeout.
- Invalid JSON.
- Missing required field.
- Unexpected status.
- Service unavailable.

Los errores técnicos **no** deben mostrarse directamente al buyer.

---

## Reglas para Checkout con Integración Mock

- Si la credit validation devuelve `blocked`, **no** confirmar.
- Si la credit validation devuelve `exceeded`, **no** confirmar o dejar `pending` según
  regla funcional.
- Si el stock devuelve `insufficient`, **no** confirmar o bloquear la cantidad según
  regla.
- Si el stock devuelve `unknown` o hay timeout en una validación crítica, **no**
  confirmar sin control.
- Si el servicio externo falla, mostrar un **mensaje funcional seguro**.
- **No** usar la respuesta externa para saltarse pricing/visibility estándar.
- Registrar el testing de errores.
- Escalar al **Architect** si se define retry/fallback.

---

## Named Credential y Seguridad

- Si Salesforce realiza callouts, debe evaluarse **Named Credential**.
- **No** hardcodear endpoints.
- **No** hardcodear tokens.
- **No** guardar secrets en el repo.
- **No** loguear tokens ni payloads sensibles.
- **No** exponer errores internos al buyer.
- Validar permisos y contexto del buyer antes del callout si aplica.
- Cualquier patrón de autenticación debe documentarse antes de implementarse.

---

## Criterios para Permitir Integración Mock

Se puede permitir integración mock si:

- El caso está alineado con el MVP o una fase futura aprobada.
- No existe capacidad estándar suficiente para el objetivo de práctica.
- El contrato está definido.
- El impacto en checkout está analizado.
- El impacto en seguridad está analizado.
- Los errores están definidos.
- QA tiene casos de integración.
- El `Salesforce Developer Agent` valida la viabilidad técnica.
- El `Salesforce Architect Agent` valida la decisión.
- El `Documentation Agent` valida los documentos afectados.
- **No** se convierte en integración productiva real.

---

## Criterios para Rechazar o Aplazar Integración

Debe rechazarse o aplazarse si:

- Se propone ERP real.
- Se propone para reemplazar el estándar sin gap.
- No hay contrato.
- No hay testing.
- No hay error handling.
- Se propone hardcodear endpoint o secret.
- Afecta al checkout sin análisis.
- Genera sobre-ingeniería.
- Requiere logging persistente no justificado.
- Intenta resolver pricing/visibility de forma insegura.

---

## Testing Obligatorio

### Success

- El servicio responde correctamente.
- Salesforce interpreta la response.
- Estado funcional esperado.

### Functional Error

- El servicio responde con un error de negocio.
- Mensaje buyer seguro.
- Estado del flujo correcto.

### HTTP Error

- HTTP 400/401/403/404/500.
- Manejo seguro.
- No stack trace.

### Timeout

- Timeout controlado.
- No confirmación indebida si es checkout crítico.
- Mensaje seguro.

### Invalid Response

- JSON inválido.
- Campos faltantes.
- Tipos incorrectos.
- Estado seguro.

### Security

- No secrets visibles.
- No datos de otra cuenta.
- Buyer context respetado.

### Regression

- PLP/PDP si aplica.
- Cart.
- Checkout.
- Order history.
- Reorder.
- Error handling.

---

## Logging y Trazabilidad

- **No** usar `System.debug` como estrategia final.
- **No** loguear secrets.
- **No** loguear tokens.
- **No** loguear datos sensibles innecesarios.
- El logging persistente **no** es default.
- Si se propone un objeto custom de log, requiere análisis y posible ADR.
- El correlation ID puede evaluarse si hay valor real.
- En el MVP, mantener el logging simple y seguro.

---

## Agentes Relevantes

- `orchestrator-agent.md`: debe clasificar la integración como decisión
  relevante/futura.
- `business-analyst-agent.md`: debe definir la necesidad funcional del dato externo.
- `b2b-commerce-specialist-agent.md`: debe validar si el estándar cubre el caso.
- `salesforce-architect-agent.md`: debe validar la arquitectura de integración.
- `salesforce-developer-agent.md`: debe diseñar la solución técnica solo con **gap
  validado**.
- `qa-specialist-agent.md`: debe definir los integration test cases.
- `documentation-agent.md`: debe mantener los docs y ADRs alineados.

---

## Documentos Relacionados

- `PROJECT_CONTEXT.md`
- `CLAUDE.md`
- `docs/DOCUMENTATION_INDEX.md`
- `adr/README.md`
- `adr/0001-project-scope-and-mvp-boundaries.md`
- `adr/0002-standard-first-b2b-commerce-approach.md`
- `adr/0003-commerce-data-vs-metadata-strategy.md`
- `adr/0004-pricing-and-visibility-strategy.md`
- `adr/0005-checkout-approval-credit-and-stock-strategy.md`
- `docs/architecture/integration-architecture.md`
- `docs/architecture/security-architecture.md`
- `docs/architecture/limitations-and-assumptions.md`
- `docs/development/integration-guidelines.md`
- `docs/development/apex-guidelines.md`
- `docs/development/error-handling-guidelines.md`
- `docs/development/logging-guidelines.md`
- `docs/development/deployment-guidelines.md`
- `docs/testing/integration-test-cases.md`
- `docs/testing/security-test-cases.md`
- `docs/testing/regression-checklist.md`
- `docs/salesforce/configuration-decisions.md`
- `docs/salesforce/org-validation-checklist.md`

---

## Validaciones Pendientes

- Validar si se usará Postman Mock Server u otra alternativa.
- Definir los contratos REST específicos cuando llegue la fase de integración.
- Definir qué servicios mock serán realmente necesarios.
- Validar si se requiere Named Credential en la Developer Org.
- Validar la estrategia de Apex callouts.
- Validar los DTOs y response models si se implementa.
- Validar el timeout esperado.
- Validar el error handling.
- Validar si se requiere retry policy.
- Validar si se requiere logging persistente.
- Validar el testing con mocks.
- Validar el impacto en checkout si se integra stock o crédito.

---

## ADRs Relacionados

- `adr/README.md`
- `adr/0001-project-scope-and-mvp-boundaries.md`
- `adr/0002-standard-first-b2b-commerce-approach.md`
- `adr/0003-commerce-data-vs-metadata-strategy.md`
- `adr/0004-pricing-and-visibility-strategy.md`
- `adr/0005-checkout-approval-credit-and-stock-strategy.md`

---

## Notas Finales

Este ADR debe considerarse la **fuente de verdad para cualquier integración REST
simulada futura**. Ningún agente debe proponer ERP real, endpoints hardcodeados,
secrets en código o integración productiva dentro del MVP.
