# Salesforce Developer Agent Evals - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define **casos de evaluación** para medir la calidad del
`Salesforce Developer Agent` en el proyecto `LvlUp-Wholesale-B2B`.

Sirve para validar si el agente: propone desarrollo **solo con gap validado**;
distingue entre Flow/LWC/Apex/integración; evita customización prematura; respeta
estándar primero; diseña soluciones mantenibles; respeta seguridad y buyer account
isolation; considera pricing/visibility y cart/checkout; considera error handling,
logging seguro, testing técnico y deployment readiness; recomienda mocks; recomienda
ADR cuando corresponde; y evita la sobre-ingeniería.

Estos evals son **manuales/conceptuales**; no implementan una herramienta
automática. La prosa va en español; código y nombres en inglés.

---

## 2. Criterios Específicos de Evaluación

| Criterio | Qué evalúa | Score alto | Score bajo |
| --- | --- | --- | --- |
| Gap validation awareness | Gap validado antes de custom | Exige gap | Custom sin gap |
| Standard-first behavior | Estándar primero | Frena custom | Salta a código |
| Flow decision quality | Flow apropiado | Simple/mantenible | Flow complejo crítico |
| LWC decision quality | LWC apropiado | Solo con gap UX | Por estética |
| Apex decision quality | Apex apropiado | Justificado | Por comodidad |
| Integration decision quality | Integración futura | Mock/Named Credential | ERP real prematuro |
| Security awareness | Seguridad server-side | Revalida en backend | Confía en UI |
| Buyer account isolation | Aislamiento | Valida cuenta | Fuga |
| Pricing/visibility awareness | Pricing/visibility | Revalida server-side | Confía en front |
| Cart/checkout awareness | Crítico | No confirma si falla | Confirma con error |
| Error handling quality | Errores | Mensaje seguro | getMessage() crudo |
| Logging judgment | Logging | Seguro/persistente con ADR | Logs sensibles |
| Testing awareness | Pruebas | Positivos/negativos/bulk | Omite |
| Mocking awareness | Mocks | Callout mocks | Sin mocks |
| Deployment readiness | Despliegue | Sin secrets/IDs | Hardcoded |
| Naming conventions | Nombres | camelCase/descriptivo | Genéricos |
| Code review awareness | Revisión | Single responsibility | God class |
| ADR awareness | ADR proporcional | ADR cuando aplica | ADR para todo/ninguno |
| Anti-overengineering | Proporcional | Simple/acotado | Framework innecesario |
| Hallucination resistance | No inventa | Pendiente de validación | Inventa |

---

## 3. Escala de Scoring

Usa la escala de `evals/agent-evaluation-framework.md` (`0`–`4`).

| Score | Significado para el Salesforce Developer Agent | Acción recomendada |
| --- | --- | --- |
| 0 | Custom peligroso/inventado | Rechazar y rehacer |
| 1 | Técnica sin gap; omite seguridad/tests | Re-trabajo |
| 2 | Solución básica con gaps | Completar |
| 3 | Solución técnica justificada y testeable | Aceptar con ajustes |
| 4 | Solución completa, segura, con mocks/tests/ADR | Aceptar |

---

## 4. Plantilla de Caso de Evaluación

```markdown
## EVAL-DEV-XXX - [Nombre del caso]

**Objetivo:**
**Input del usuario:**
**Contexto esperado:**
- ...
**Gap técnico esperado:** Validado / Pendiente / No existe gap
**Tipo de solución esperado:** Configuration / Flow / LWC / Apex / Integration / No custom
**Decisión técnica esperada:**
**Riesgos esperados:**
- ...
**Impacto en seguridad esperado:**
**Impacto en buyer account isolation esperado:**
**Impacto en pricing / visibility esperado:**
**Impacto en cart / checkout esperado:**
**Testing esperado:**
- ...
**Mocks esperados:** Sí / No / No aplica
**Deployment readiness esperado:**
**ADR esperado:** Sí / No
**Errores críticos:**
- ...
**Score mínimo aceptable:**
**Notas:**
```

---

## 5. Evals de Gap Validation

### `EVAL-DEV-001` - Apex sin gap validado
- **Input:** "Crea una clase Apex para validar si un pedido requiere aprobación."
- **Debe:** falta regla/umbral (`DEC-008`); falta validación estándar/config/Flow;
  **Apex no aún**; escalar a Business Analyst, B2B Commerce y Architect si impacta
  checkout.
- **Score mínimo: 4.**

### `EVAL-DEV-002` - LWC sin gap UX validado
- **Input:** "Haz un LWC para mejorar la PLP."
- **Debe:** falta gap UX; Experience Builder/componentes estándar primero; **no por
  estética**; escalar a UX Specialist.
- **Score mínimo: 4.**

### `EVAL-DEV-003` - Integración real sin decisión de alcance
- **Input:** "Conectemos el ERP real para stock."
- **Debe:** ERP real fuera del MVP; integración mock futura; **no implementar real**;
  escalar a Architect/Orchestrator si se plantea cambio de alcance.
- **Score mínimo: 4.**

---

## 6. Evals de Flow Decision Quality

### `EVAL-DEV-004` - Flow simple para approval threshold
- **Input:** "Si el total supera un importe definido, el pedido queda pendiente."
- **Debe:** regla clara; si estándar/config no cubre, Flow viable si simple y
  mantenible; impacto en checkout; fault paths; testing/regresión; **ADR** si
  lógica central crítica.
- **Score mínimo:** 3.

### `EVAL-DEV-005` - Flow complejo para todas las validaciones de checkout
- **Debe:** riesgo de Flow gigante; checkout crítico; error handling complejo;
  posible Apex; Architect valida; **ADR probable**.
- **Score mínimo: 4.**

### `EVAL-DEV-006` - Flow sin fault paths
- **Debe:** fault paths obligatorios; mensajes funcionales; testing de error; **no
  considerar listo**.
- **Score mínimo:** 3.

---

## 7. Evals de LWC Decision Quality

### `EVAL-DEV-007` - LWC para reorder partial summary con gap validado
- **Input:** "El estándar no permite un resumen claro de productos excluidos en
  reorder parcial."
- **Debe:** gap UX validado; Builder/componentes revisados; LWC justificable;
  revalidar pricing/visibility/stock **server-side**; **no confiar en UI**; testing
  LWC + QA regression; **ADR probable**.
- **Score mínimo: 4.**

### `EVAL-DEV-008` - LWC para ocultar producto restringido
- **Debe rechazar:** la seguridad no se resuelve con LWC; visibility por
  estándar/config/server-side; escalar a Architect/B2B Commerce/QA.
- **Score mínimo: 4.**

### `EVAL-DEV-009` - LWC sin estados UX
- **Debe detectar ausencia de:** loading/empty/error; pending/restricted si aplica;
  mobile behavior; safe error messages.
- **Score mínimo:** 3.

---

## 8. Evals de Apex Decision Quality

### `EVAL-DEV-010` - Apex para callout de crédito (mock validado)
- **Debe:** integración mock/futura aprobada; Named Credential; DTOs; timeout; error
  handling; **mocks para tests**; sin hardcoded endpoints/secrets; checkout impact;
  **ADR probable**.
- **Score mínimo: 4.**

### `EVAL-DEV-011` - Apex por comodidad para asignar Buyer Group
- **Debe rechazar:** puede resolverse con configuración/data loading; sin gap
  validado; riesgo de custom innecesario.
- **Score mínimo:** 3.

### `EVAL-DEV-012` - Apex sin bulkification
- **Debe:** bulkification obligatoria; **no SOQL/DML en loops**; tests bulk; code
  review.
- **Score mínimo:** 3.

---

## 9. Evals de Integration Decision Quality

### `EVAL-DEV-013` - Postman Mock Server para stock
- **Debe:** integración simulada futura; contrato REST conceptual; Named Credential
  si hay callout; mocks; integration test cases; error handling; **ADR si se
  adopta**.
- **Score mínimo:** 3.

### `EVAL-DEV-014` - Endpoint hardcodeado
- **Debe FALLAR:** no hardcoded endpoints; usar Named Credential; sin secrets en
  código; deployment readiness.
- **Score mínimo: 4.**

### `EVAL-DEV-015` - Timeout sin manejo
- **Debe:** timeout esperado; error funcional seguro; **no confirmar checkout** si la
  validación crítica queda incierta; logging seguro; testing negativo.
- **Score mínimo:** 3.

---

## 10. Evals de Seguridad Técnica

### `EVAL-DEV-016` - Apex devuelve orders sin validar buyer account
- **Debe FALLAR:** buyer account isolation; order access; **server-side
  validation**; security tests; no depender de UI.
- **Score mínimo: 4.**

### `EVAL-DEV-017` - LWC recibe pricing no autorizado y lo oculta
- **Debe FALLAR:** **no enviar datos no autorizados al cliente**; pricing security
  server-side/estándar; escalar.
- **Score mínimo: 4.**

### `EVAL-DEV-018` - Error expone Permission Set o perfil interno
- **Debe:** safe error message; no detalles internos; UX/QA involvement.
- **Score mínimo:** 3.

---

## 11. Evals de Pricing / Visibility

### `EVAL-DEV-019` - Custom Apex recalcula pricing
- **Debe:** validar Price Books/estándar primero; riesgo de inconsistencia;
  seguridad comercial; **ADR si custom pricing**; testing PLP/PDP/cart/checkout.
- **Score mínimo: 4.**

### `EVAL-DEV-020` - LWC muestra productos sin revalidar visibility
- **Debe FALLAR:** la visibility no depende del front; revalidación
  server-side/estándar; security testing.
- **Score mínimo:** 3.

### `EVAL-DEV-021` - Reorder usa pricing histórico sin advertencia
- **Debe:** revalidar pricing actual; mensaje funcional si cambia; cart/checkout
  final; regression.
- **Score mínimo:** 3.

---

## 12. Evals de Cart y Checkout

### `EVAL-DEV-022` - Checkout confirma con error de validación
- **Crítico.** **Debe:** **no confirmar** si la validación crítica falla; error
  handling; state pending/error; QA regression; Architect involvement.
- **Score mínimo: 4.**

### `EVAL-DEV-023` - Producto inválido permanece en cart
- **Debe:** revalidación de cart; visibility/pricing/stock; mensaje seguro; testing.
- **Score mínimo:** 3.

### `EVAL-DEV-024` - Approval status inconsistente
- **Debe:** confirmed vs pending; business rule; testing funcional; posible
  Flow/Apex según gap; **ADR si lógica central**.
- **Score mínimo:** 3.

---

## 13. Evals de Error Handling

### `EVAL-DEV-025` - `Exception.getMessage()` directo al buyer
- **Debe rechazar:** no exponer excepción técnica; mensaje funcional seguro; logging
  interno si justificado; QA error testing.
- **Score mínimo: 4.**

### `EVAL-DEV-026` - Catch vacío
- **Debe FALLAR:** no silenciar errores; manejo explícito; testing negativo; logging
  seguro si aplica.
- **Score mínimo:** 3.

### `EVAL-DEV-027` - Error de callout sin fallback funcional
- **Debe:** mensaje seguro; **no confirmar si validación crítica**; testing de HTTP
  error/timeout/invalid response.
- **Score mínimo:** 3.

---

## 14. Evals de Logging

### `EVAL-DEV-028` - `System.debug` como estrategia final
- **Debe rechazar:** no estrategia definitiva; logging seguro; no datos sensibles;
  persistente solo si justificado/ADR.
- **Score mínimo:** 3.

### `EVAL-DEV-029` - Objeto custom de log sin ADR
- **Debe:** logging persistente no es default; **ADR probable**; retención
  conceptual; seguridad de datos.
- **Score mínimo:** 3.

### `EVAL-DEV-030` - Log registra token o payload sensible
- **Debe FALLAR automáticamente.**
- **Score mínimo: 4.**

---

## 15. Evals de Testing Técnico

### `EVAL-DEV-031` - Apex callout sin mock
- **Debe FALLAR:** callout mock obligatorio; success/HTTP error/timeout/invalid
  response; sin dependencia de org data.
- **Score mínimo: 4.**

### `EVAL-DEV-032` - Tests dependen de datos existentes
- **Debe rechazar:** crear test data propia; no depender de org data; tests
  reproducibles.
- **Score mínimo:** 3.

### `EVAL-DEV-033` - LWC sin pruebas de estados
- **Debe:** loading/empty/error; eventos; Apex interaction; mensajes seguros.
- **Score mínimo:** 3.

### `EVAL-DEV-034` - Flow sin pruebas de fault path
- **Debe:** fault path; negative scenarios; data missing; permisos.
- **Score mínimo:** 3.

---

## 16. Evals de Deployment Readiness

### `EVAL-DEV-035` - Cambio técnico con IDs hardcodeados
- **Debe FALLAR:** no hardcoded IDs; data loading/configuration; deployment risk.
- **Score mínimo: 4.**

### `EVAL-DEV-036` - Metadata sin datos dependientes identificados
- **Debe:** Commerce data dependencies; Price Books; Buyer Groups; Product Catalog;
  post-deployment validation.
- **Score mínimo:** 3.

### `EVAL-DEV-037` - Secret en repo
- **Debe FALLAR automáticamente.** Recomendar Named Credential, environment config,
  security review.
- **Score mínimo: 4.**

---

## 17. Evals de Naming y Code Review

### `EVAL-DEV-038` - Método Apex mal nombrado
- **Debe:** métodos en camelCase; nombre descriptivo según responsabilidad; evitar
  genéricos.
- **Score mínimo:** 3.

### `EVAL-DEV-039` - Clase con múltiples responsabilidades
- **Debe:** single responsibility; separación de concerns; mantenibilidad.
- **Score mínimo:** 3.

### `EVAL-DEV-040` - LWC con nombre genérico
- **Debe:** naming claro; responsabilidad clara; alineación con naming conventions.
- **Score mínimo:** 3.

---

## 18. Evals de ADR Awareness

### `EVAL-DEV-041` - Apex central para checkout
- **ADR probable.** **Debe:** checkout crítico; error handling; testing; Architect
  involvement.
- **Score mínimo:** 3.

### `EVAL-DEV-042` - Cambio menor de label en LWC
- **Debe:** **no requiere ADR**; testing ligero si aplica; documentation update si
  corresponde.
- **Score mínimo:** 3.

### `EVAL-DEV-043` - Named Credential para mock REST
- **ADR probable** si se adopta como patrón.
- **Score mínimo:** 3.

---

## 19. Evals de Anti-Overengineering

### `EVAL-DEV-044` - Framework genérico de integración para el MVP
- **Debe detectar sobre-ingeniería** y preferir una solución simple, segura y
  acotada.
- **Score mínimo:** 3.

### `EVAL-DEV-045` - Librería UI custom completa
- **Debe rechazar:** Experience Builder/SLDS/componentes estándar primero; LWC solo
  con gap.
- **Score mínimo:** 3.

### `EVAL-DEV-046` - Motor custom de pricing
- **Debe rechazar** salvo decisión arquitectónica validada (ADR).
- **Score mínimo: 4.**

---

## 20. Evals de Hallucination Resistance

### `EVAL-DEV-047` - Inventar clase Apex existente
- **Debe FALLAR** si afirma existencia sin evidencia.
- **Score mínimo: 4.**

### `EVAL-DEV-048` - Inventar objeto/campo custom
- **Debe FALLAR** si lo trata como existente sin documentación.
- **Score mínimo: 4.**

### `EVAL-DEV-049` - Afirmar que un test ya pasa
- **Debe FALLAR** si no hay evidencia de ejecución.
- **Score mínimo: 4.**

### `EVAL-DEV-050` - Afirmar capacidad validada en org
- **Debe marcar** pendiente de validación si no hay evidencia.
- **Score mínimo: 4.**

---

## 21. Matriz Resumen de Evals

| ID | Área | Input resumido | Decisión técnica esperada | Riesgo principal | Score mínimo | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| EVAL-DEV-001 | Gap | Apex sin gap | No custom; escalar | Apex sin gap | 4 | No ejecutado |
| EVAL-DEV-002 | Gap | LWC sin gap UX | Builder first | LWC por estética | 4 | No ejecutado |
| EVAL-DEV-003 | Gap | ERP real | Fuera del MVP | Integración prematura | 4 | No ejecutado |
| EVAL-DEV-004 | Flow | Approval simple | Flow si simple; ADR si central | Checkout | 3 | No ejecutado |
| EVAL-DEV-005 | Flow | Flow para todo el checkout | Separar; posible Apex; ADR | Flow gigante | 4 | No ejecutado |
| EVAL-DEV-006 | Flow | Sin fault paths | Fault paths | Error no manejado | 3 | No ejecutado |
| EVAL-DEV-007 | LWC | Reorder summary (gap real) | LWC justificado; server-side | Seguridad UI | 4 | No ejecutado |
| EVAL-DEV-008 | LWC | Ocultar restringido | Rechazar; server-side | Seguridad UI-only | 4 | No ejecutado |
| EVAL-DEV-009 | LWC | Sin estados UX | Estados completos | Estados omitidos | 3 | No ejecutado |
| EVAL-DEV-010 | Apex | Callout crédito (mock) | Named Credential; mocks; ADR | Secrets/checkout | 4 | No ejecutado |
| EVAL-DEV-011 | Apex | Apex para Buyer Group | Config/data loading | Custom innecesario | 3 | No ejecutado |
| EVAL-DEV-012 | Apex | Sin bulkification | Bulk-safe | Límites/governor | 3 | No ejecutado |
| EVAL-DEV-013 | Integración | Postman Mock stock | Mock futuro; ADR | Adoptar sin ADR | 3 | No ejecutado |
| EVAL-DEV-014 | Integración | Endpoint hardcodeado | Named Credential | Secret/endpoint | 4 | No ejecutado |
| EVAL-DEV-015 | Integración | Timeout sin manejo | No confirmar; safe error | Validación incierta | 3 | No ejecutado |
| EVAL-DEV-016 | Seguridad | Orders sin validar cuenta | Server-side validation | Account isolation | 4 | No ejecutado |
| EVAL-DEV-017 | Seguridad | Pricing no autorizado al cliente | No enviar al front | Pricing isolation | 4 | No ejecutado |
| EVAL-DEV-018 | Seguridad | Error expone permisos | Safe error | Information disclosure | 3 | No ejecutado |
| EVAL-DEV-019 | Pricing | Apex recalcula pricing | Price Books primero; ADR | Inconsistencia | 4 | No ejecutado |
| EVAL-DEV-020 | Visibility | LWC sin revalidar visibility | Server-side | Exposición | 3 | No ejecutado |
| EVAL-DEV-021 | Pricing | Reorder pricing histórico | Revalidar actual | Precio obsoleto | 3 | No ejecutado |
| EVAL-DEV-022 | Checkout | Confirma con error | No confirmar | Checkout crítico | 4 | No ejecutado |
| EVAL-DEV-023 | Cart | Producto inválido en cart | Revalidación | Confirmar inválido | 3 | No ejecutado |
| EVAL-DEV-024 | Checkout | Approval inconsistente | confirmed vs pending | Estado erróneo | 3 | No ejecutado |
| EVAL-DEV-025 | Error handling | getMessage() al buyer | Safe error | Data exposure | 4 | No ejecutado |
| EVAL-DEV-026 | Error handling | Catch vacío | Manejo explícito | Error silenciado | 3 | No ejecutado |
| EVAL-DEV-027 | Error handling | Callout sin fallback | Safe error; no confirmar | Validación incierta | 3 | No ejecutado |
| EVAL-DEV-028 | Logging | System.debug final | Logging seguro | Estrategia pobre | 3 | No ejecutado |
| EVAL-DEV-029 | Logging | Objeto custom de log | ADR | Persistente sin ADR | 3 | No ejecutado |
| EVAL-DEV-030 | Logging | Log de token/payload | Falla automática | Secret exposure | 4 | No ejecutado |
| EVAL-DEV-031 | Testing | Callout sin mock | Callout mock | Sin aislamiento | 4 | No ejecutado |
| EVAL-DEV-032 | Testing | Tests con org data | Test data propia | Dependencia | 3 | No ejecutado |
| EVAL-DEV-033 | Testing | LWC sin estados | Probar estados | Cobertura | 3 | No ejecutado |
| EVAL-DEV-034 | Testing | Flow sin fault path | Probar fault path | Cobertura | 3 | No ejecutado |
| EVAL-DEV-035 | Deployment | IDs hardcodeados | Sin hardcoded IDs | Reproducibilidad | 4 | No ejecutado |
| EVAL-DEV-036 | Deployment | Metadata sin datos | Identificar datos | Storefront incompleto | 3 | No ejecutado |
| EVAL-DEV-037 | Deployment | Secret en repo | Falla automática | Secret exposure | 4 | No ejecutado |
| EVAL-DEV-038 | Naming | Método mal nombrado | camelCase descriptivo | Claridad | 3 | No ejecutado |
| EVAL-DEV-039 | Code review | God class | Single responsibility | Mantenibilidad | 3 | No ejecutado |
| EVAL-DEV-040 | Naming | LWC genérico | Naming claro | Claridad | 3 | No ejecutado |
| EVAL-DEV-041 | ADR | Apex central checkout | ADR probable | Lógica central | 3 | No ejecutado |
| EVAL-DEV-042 | ADR | Label de LWC | No requiere ADR | ADR innecesario | 3 | No ejecutado |
| EVAL-DEV-043 | ADR | Named Credential mock | ADR probable | Patrón | 3 | No ejecutado |
| EVAL-DEV-044 | Anti-OE | Framework de integración | Solución simple | Over-engineering | 3 | No ejecutado |
| EVAL-DEV-045 | Anti-OE | Librería UI custom | Estándar primero | Over-engineering | 3 | No ejecutado |
| EVAL-DEV-046 | Anti-OE | Motor custom de pricing | Rechazar salvo ADR | Over-engineering | 4 | No ejecutado |
| EVAL-DEV-047 | Hallucination | Clase Apex "existe" | Falla | Inventar | 4 | No ejecutado |
| EVAL-DEV-048 | Hallucination | Objeto custom "existe" | Falla | Inventar | 4 | No ejecutado |
| EVAL-DEV-049 | Hallucination | "El test ya pasa" | Falla | Inventar evidencia | 4 | No ejecutado |
| EVAL-DEV-050 | Hallucination | "Capacidad validada" | Pendiente de validación | Afirmar sin evidencia | 4 | No ejecutado |

---

## 22. Criterios de Aprobación del Salesforce Developer Agent

- **Score mínimo 3** para decisiones técnicas normales.
- **Score 4** para seguridad, checkout, pricing/visibility, integración, logging
  persistente y deployment.
- **Fallo automático** si: propone custom sin gap validado; Apex por comodidad; LWC
  por estética; resuelve seguridad solo en UI; hardcodea IDs/endpoints/secrets;
  ignora tests/mocks en callouts; ignora buyer account isolation; o inventa
  implementación existente o validada.

---

## 23. Relación con Otros Evals

Este archivo evalúa **solo** al `Salesforce Developer Agent`. Relacionados:
`agent-evaluation-framework.md`, `orchestrator-agent-evals.md`,
`business-analyst-agent-evals.md`, `b2b-commerce-specialist-agent-evals.md`,
`salesforce-architect-agent-evals.md`, `ux-specialist-agent-evals.md`, y los futuros
evals de QA y Documentation Agent.

---

## 24. Relación con Documentos

- `salesforce-developer-agent.md` define el **comportamiento esperado**.
- `agent-evaluation-framework.md` define el **framework general**.
- `standard-vs-custom-framework.md` guía **estándar vs custom**.
- `solution-architecture.md` define la **arquitectura**.
- `security-architecture.md` y `security-model.md` guían la **seguridad**.
- `integration-architecture.md` guía la **integración futura**.
- `apex-guidelines.md`, `lwc-guidelines.md`, `flow-guidelines.md` e
  `integration-guidelines.md` guían el **desarrollo**.
- `error-handling-guidelines.md` y `logging-guidelines.md` guían **errores y
  logging**.
- `deployment-guidelines.md` guía el **deployment**.
- `naming-conventions.md` guía los **nombres**.
- `code-review-checklist.md` guía la **revisión técnica**.
- `test-strategy.md`, `integration-test-cases.md` y `regression-checklist.md` guían
  el **testing**.
- `adr/` registrará las **decisiones técnicas relevantes**.
