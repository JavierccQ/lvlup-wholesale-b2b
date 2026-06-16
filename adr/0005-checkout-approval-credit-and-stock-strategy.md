# ADR-0005 - Checkout Approval, Credit and Stock Strategy

## Estado

Accepted

## Fecha

2026-06-16

## Contexto

- Checkout es uno de los **flujos más críticos** del storefront B2B.
- En B2B Commerce, el checkout no solo debe permitir confirmar pedidos, sino también
  **reflejar reglas comerciales**.
- Para `LvlUp WholeSale`, el checkout debe soportar escenarios funcionales de
  **aprobación por importe**, **crédito bloqueado o excedido** y **stock insuficiente**.
- El MVP **no** incluye pagos reales, tax real, shipping real ni ERP real.
- La validación de crédito y stock será **funcional/simulada** dentro del MVP, no
  integración productiva real.
- El checkout debe mantener **consistencia con pricing y visibility** (ver
  `adr/0004-pricing-and-visibility-strategy.md`).
- Un producto no autorizado, sin pricing válido o con stock insuficiente **no** debe
  terminar en una confirmación incorrecta.
- Se debe diferenciar claramente entre **pedido confirmado**, **solicitud pendiente** y
  **error funcional**.
- Este ADR formaliza la estrategia para checkout, approval, credit y stock dentro del
  MVP, sobre la base de `0001`, `0002`, `0003` y `0004`.

---

## Decisión

El proyecto gestionará el checkout bajo un enfoque **standard-first**, validando
primero Salesforce B2B Commerce estándar, configuración, datos Commerce y Experience
Builder antes de introducir Flow, Apex, LWC o integración.

La estrategia será:

1. Usar el **checkout estándar** de Salesforce B2B Commerce como base.
2. Validar las capacidades estándar disponibles en la Developer Org.
3. Mantener el **checkout básico** dentro del MVP.
4. Tratar **approval por importe** como regla funcional del MVP.
5. Tratar **credit validation** como validación funcional/simulada dentro del MVP.
6. Tratar **stock insufficient scenario** como validación funcional/simulada dentro del
   MVP.
7. Diferenciar los estados `confirmed`, `pending` y `error`.
8. **Revalidar** pricing, visibility y buyer context antes de confirmar.
9. **No** conectar ERP real en esta fase.
10. **No** implementar pagos reales, tax real ni shipping real.
11. Escalar cualquier lógica custom central de checkout al **Salesforce Architect
    Agent**.
12. Requerir functional testing, security testing y regression testing para cualquier
    cambio de checkout.

Cualquier integración real o mock REST formal para crédito/stock deberá tratarse en
`adr/0006-future-rest-mock-integration-strategy.md`.

---

## Alternativas Consideradas

### Alternativa 1 - Checkout estándar con reglas funcionales controladas

Descripción:

- Usar el checkout estándar como base.
- Añadir o simular reglas de approval, credit y stock solo cuando estén dentro del MVP.
- Mantener la integración real fuera del MVP.
- Documentar gaps y validaciones pendientes.

Resultado: **alternativa aceptada**.

### Alternativa 2 - Checkout completamente custom

Descripción:

- Reemplazar el checkout estándar con LWC/Apex custom.

Resultado: **rechazada** porque aumenta riesgo, complejidad y testing, y contradice el
enfoque standard-first.

### Alternativa 3 - Checkout simple sin approval, credit ni stock

Descripción:

- Permitir checkout básico sin escenarios funcionales adicionales.

Resultado: **rechazada parcialmente** porque el MVP busca practicar escenarios B2B
relevantes como aprobación, crédito y stock insuficiente.

### Alternativa 4 - Integración ERP real desde el inicio

Descripción:

- Consultar stock, crédito y estado de pedido contra un ERP real.

Resultado: **rechazada** porque el ERP real está fuera del MVP.

### Alternativa 5 - Confirmar siempre el pedido y resolver inconsistencias después

Descripción:

- Confirmar el pedido aunque existan problemas de stock, crédito o visibility.

Resultado: **rechazada** porque genera una experiencia incorrecta, riesgo funcional y
poca coherencia B2B.

---

## Consecuencias

### Positivas

- Checkout alineado con el MVP.
- Menor riesgo de sobre-ingeniería.
- Mejor separación entre validación funcional y futura integración real.
- Mayor claridad entre pedido confirmado y solicitud pendiente.
- Mejor experiencia para el buyer.
- Mejor control de los escenarios críticos.
- Mejor trazabilidad para QA.
- Mejor base para la integración simulada futura.
- Mejor protección frente a pedidos inválidos.
- Mejor alineación con pricing/visibility.

### Negativas / Trade-offs

- Credit validation y stock validation no serán integraciones reales inicialmente.
- Algunos comportamientos dependerán de validación en la Developer Org.
- Puede requerirse simular datos funcionales.
- Algunas reglas pueden requerir Flow o Apex si el estándar no alcanza.
- Si se introduce lógica custom, aumentará el testing y la documentación.
- La experiencia no cubrirá pagos, impuestos ni envío reales.
- La integración real queda diferida.

---

## Impacto en el Proyecto

### MVP

Checkout básico, approval por importe, credit validation funcional y stock insufficient
scenario están **dentro del MVP**.

### Salesforce B2B Commerce

El checkout estándar será la base, sujeto a validación en org.

### Seguridad

El checkout debe respetar buyer account isolation, product visibility, pricing
visibility y order access.

### Pricing / Visibility

El checkout debe **reflejar el pricing y la visibility actuales**. No debe confirmar
productos no autorizados o sin pricing válido (fuente de verdad: `0004`).

### Checkout

Este ADR es la **fuente de verdad principal** para la estrategia de checkout.

### Datos / Metadata

Approval, credit y stock pueden requerir **datos funcionales de prueba**, configuración
y posiblemente metadata si se introduce Flow/Apex.

### Integración

El ERP real está **fuera del MVP**. El mock REST futuro se tratará en un ADR separado
(`0006`).

### Testing

El checkout requiere pruebas de happy path, negative scenarios, security testing, error
handling y regression.

### Documentación

`cart-checkout-experience.md`, `business-rules.md`, `b2b-commerce-flows.md`,
`functional-test-cases.md`, `security-test-cases.md` y `regression-checklist.md` deben
mantenerse alineados.

---

## Estados del Checkout

### Confirmed

El pedido queda confirmado cuando:

- El buyer está autorizado.
- Los productos son visibles/autorizados.
- El pricing es válido.
- El stock funcional es suficiente o no bloqueante según regla.
- La credit validation no bloquea.
- No se supera un umbral que requiera pending approval.
- No hay errores críticos.

### Pending

La solicitud queda pendiente cuando:

- El pedido supera el umbral de approval.
- Requiere aprobación manual o funcional.
- La regla de negocio indica revisión previa.
- El buyer debe entender que **no es un pedido confirmado**.

### Error

El checkout debe terminar en error funcional cuando:

- El producto ya no está autorizado.
- El producto no tiene pricing válido.
- El stock funcional es insuficiente y la regla bloquea.
- El crédito está bloqueado o excedido y la regla bloquea.
- Hay error técnico o validación crítica incierta.
- Hay inconsistencia de buyer account.

Los errores visibles al buyer deben ser **seguros, funcionales y no técnicos**.

---

## Estrategia de Approval por Importe

- Approval por importe forma parte del MVP.
- El umbral debe estar definido en las reglas de negocio.
- Si el umbral **no** está definido, debe marcarse como **pendiente**.
- El estado resultante debe ser `pending`, **no** `confirmed`.
- El buyer debe recibir un **mensaje claro**.
- La lógica debe validarse primero con estándar/configuración.
- Flow puede considerarse si la regla es simple y mantenible.
- Apex solo debe considerarse si hay complejidad real.
- Si approval se vuelve lógica central custom, puede requerir un ADR adicional o la
  actualización de este ADR.

---

## Estrategia de Credit Validation

- La credit validation dentro del MVP es **funcional/simulada**.
- **No** se conectará ERP real inicialmente.
- Estados conceptuales posibles:
  - `credit valid`
  - `credit blocked`
  - `credit exceeded`
  - `credit unavailable`
- Si el crédito está bloqueado o excedido, el checkout **no** debe confirmar el pedido
  salvo regla explícita.
- Si la validación es incierta o no disponible, **no** debe confirmarse un pedido
  crítico sin control.
- Los mensajes deben ser funcionales y seguros.
- Si en el futuro se consulta un servicio externo, debe tratarse en el ADR de
  integración (`0006`).

---

## Estrategia de Stock Insufficient Scenario

- Stock insufficient scenario forma parte del MVP.
- La validación de stock será **funcional/simulada** inicialmente.
- **No** se conectará ERP real en esta fase.
- Estados conceptuales posibles:
  - `stock available`
  - `stock insufficient`
  - `stock unavailable`
  - `stock unknown`
- Si el stock es insuficiente y la regla bloquea, el checkout **no** debe confirmar.
- PDP, cart y checkout deben comunicar el problema de forma **coherente**.
- Reorder debe **revalidar el stock actual**.
- Si en el futuro se consulta un servicio externo, debe tratarse en el ADR de
  integración (`0006`).

---

## Revalidaciones Obligatorias en Checkout

Antes de confirmar o dejar pendiente un pedido, se debe validar conceptualmente:

- Buyer account correcto.
- Buyer user autorizado.
- El cart pertenece al buyer correcto.
- Los productos siguen visibles.
- Los productos siguen autorizados.
- El pricing sigue válido.
- Las cantidades siguen permitidas.
- El stock funcional es suficiente o se maneja correctamente.
- La credit validation no bloquea.
- El approval threshold se evalúa.
- El estado final es coherente.
- El mensaje al buyer es claro.

---

## Mensajes para Buyer

Principios:

- No técnicos.
- Claros.
- Seguros.
- Accionables.
- Sin stack traces.
- Sin nombres de clases Apex.
- Sin nombres de Flows.
- Sin endpoints.
- Sin revelar Buyer Groups internos.
- Sin revelar reglas internas sensibles.

Ejemplos conceptuales:

- "Tu pedido requiere aprobación antes de confirmarse."
- "No hay stock suficiente para la cantidad solicitada."
- "No podemos confirmar el pedido porque tu cuenta requiere revisión de crédito."
- "Uno o más productos ya no están disponibles para tu cuenta."
- "No pudimos completar el checkout. Inténtalo nuevamente o revisa tu carrito."

---

## Reglas de Seguridad

- **No** confirmar pedidos de buyer account incorrecta.
- **No** permitir productos no autorizados.
- **No** permitir pricing no autorizado.
- **No** resolver errores de checkout solo desde UI.
- **No** confiar en LWC como única capa de validación.
- **No** mostrar detalles internos.
- **No** confirmar si una validación crítica queda incierta.
- **No** permitir reorder que evada pricing, visibility o stock actual.
- Probar con buyer users reales de prueba.

---

## Criterios para Permitir Flow

Flow puede considerarse si:

- La regla es declarativa.
- El umbral de approval es simple.
- El mantenimiento es claro.
- Existen fault paths.
- No hay integración compleja.
- No se compromete la seguridad.
- QA puede probarlo.

---

## Criterios para Permitir Apex

Apex puede considerarse si:

- Existe un gap real.
- Se requiere control server-side.
- Hay integración futura.
- Hay transaccionalidad o error handling complejo.
- Flow no es mantenible.
- Hay mocks y tests.
- El `Salesforce Architect Agent` valida.
- El ADR se actualiza o se crea uno relacionado si la decisión es central.

---

## Criterios para Permitir LWC

LWC puede considerarse si:

- Existe un gap UX real.
- Experience Builder no cubre la experiencia.
- Se necesita mostrar estados de checkout/reorder de forma más clara.
- No se usa como seguridad.
- No calcula pricing crítico en cliente.
- El `Salesforce Architect Agent` y el `UX Specialist Agent` validan.

---

## Criterios para Rechazar Customización

Debe rechazarse la customización si:

- Se propone por estética.
- Se propone por comodidad.
- El problema es de datos.
- El problema es de configuración.
- El estándar no fue validado.
- No hay regla funcional clara.
- No hay testing definido.
- Resuelve seguridad solo en UI.
- Intenta conectar ERP real dentro del MVP.
- Introduce un motor custom de checkout innecesario.

---

## Testing Obligatorio

### Happy Path

- Buyer autorizado.
- Producto visible.
- Pricing válido.
- Stock suficiente.
- Crédito válido.
- Pedido bajo umbral.
- Resultado: `confirmed`.

### Approval

- Pedido sobre umbral.
- Resultado: `pending`.
- Mensaje claro.

### Credit Blocked

- Buyer con crédito bloqueado.
- Resultado: no `confirmed`.
- Mensaje seguro.

### Credit Exceeded

- Buyer excede el límite funcional.
- Resultado: no `confirmed` o `pending` según regla.
- Mensaje claro.

### Stock Insufficient

- Cantidad solicitada mayor al stock funcional.
- Resultado: bloqueo o ajuste según regla.
- Mensaje claro.

### Product No Longer Visible

- El producto deja de estar autorizado.
- Resultado: no `confirmed`.
- Mensaje seguro.

### Pricing Invalid

- Producto sin precio válido.
- Resultado: no `confirmed`.
- Mensaje claro.

### Error Handling

- Error técnico.
- Timeout futuro si aplica.
- Invalid response futuro si aplica.
- Resultado seguro.

### Regression

- PLP.
- PDP.
- Cart.
- Checkout.
- Order history.
- Reorder.
- Pricing.
- Visibility.
- Mobile.

---

## Agentes Relevantes

- `orchestrator-agent.md`: debe clasificar el checkout como **flujo crítico**.
- `business-analyst-agent.md`: debe definir las reglas de approval, credit y stock.
- `b2b-commerce-specialist-agent.md`: debe validar estándar/configuración de checkout.
- `salesforce-architect-agent.md`: debe validar cualquier customización central.
- `ux-specialist-agent.md`: debe validar los mensajes y los estados de checkout.
- `salesforce-developer-agent.md`: solo interviene con **gap técnico validado**.
- `qa-specialist-agent.md`: debe definir pruebas funcionales, de seguridad y regresión.
- `documentation-agent.md`: debe mantener los documentos alineados.

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
- `docs/business/business-rules.md`
- `docs/business/b2b-commerce-flows.md`
- `docs/business/mvp-scope.md`
- `docs/ux/cart-checkout-experience.md`
- `docs/ux/empty-error-loading-states.md`
- `docs/architecture/standard-vs-custom-framework.md`
- `docs/architecture/security-architecture.md`
- `docs/salesforce/b2b-commerce-standard-capabilities.md`
- `docs/salesforce/configuration-decisions.md`
- `docs/salesforce/data-loading-strategy.md`
- `docs/salesforce/org-validation-checklist.md`
- `docs/development/flow-guidelines.md`
- `docs/development/apex-guidelines.md`
- `docs/development/integration-guidelines.md`
- `docs/development/error-handling-guidelines.md`
- `docs/development/logging-guidelines.md`
- `docs/testing/functional-test-cases.md`
- `docs/testing/security-test-cases.md`
- `docs/testing/integration-test-cases.md`
- `docs/testing/regression-checklist.md`

---

## Validaciones Pendientes

- Validar el checkout estándar en la Developer Org.
- Validar la configuración disponible para checkout.
- Validar si approval por importe puede resolverse con estándar/configuración/Flow.
- Definir el umbral funcional de approval.
- Validar cómo representar el credit status funcional.
- Validar cómo representar el stock status funcional.
- Validar el comportamiento de productos restringidos en checkout.
- Validar el comportamiento de productos sin pricing válido.
- Validar los mensajes estándar disponibles.
- Validar si se requiere LWC para estados UX específicos.
- Validar si se requiere Flow o Apex para reglas centrales.
- Validar la regresión de checkout con buyer users.

---

## ADRs Relacionados

- `adr/README.md`
- `adr/0001-project-scope-and-mvp-boundaries.md`
- `adr/0002-standard-first-b2b-commerce-approach.md`
- `adr/0003-commerce-data-vs-metadata-strategy.md`
- `adr/0004-pricing-and-visibility-strategy.md`
- `adr/0006-future-rest-mock-integration-strategy.md` (ADR futuro relacionado).

---

## Notas Finales

Este ADR debe considerarse la **fuente de verdad para el comportamiento de checkout
dentro del MVP**. Cualquier propuesta que confirme pedidos sin validar approval,
credit, stock, pricing o visibility debe **rechazarse o escalarse** antes de avanzar.
