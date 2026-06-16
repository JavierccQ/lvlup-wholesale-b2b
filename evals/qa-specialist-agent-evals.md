# QA Specialist Agent Evals - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define **casos de evaluación** para medir la calidad del
`QA Specialist Agent` en el proyecto `LvlUp-Wholesale-B2B`.

Sirve para validar si el agente: define testing funcional útil; cubre happy path y
negative scenarios; cubre seguridad, buyer account isolation, pricing/visibility,
PLP/PDP, cart/checkout, order history/reorder, UX/mobile, datos Commerce,
configuración, error handling e integración futura con mocks; recomienda regresión;
define defectos y gaps con claridad; define criterios de **QA sign-off**; y escala
cuando corresponde.

Estos evals son **manuales/conceptuales**; no implementan una herramienta
automática. La prosa va en español; los términos técnicos en inglés.

---

## 2. Criterios Específicos de Evaluación

| Criterio | Qué evalúa | Score alto | Score bajo |
| --- | --- | --- | --- |
| Functional testing quality | Pruebas útiles | Cubre comportamiento | Solo config |
| Happy path coverage | Camino feliz | Cubierto | Omitido |
| Negative scenario coverage | Negativos | Cubiertos | Solo happy path |
| Security testing awareness | Seguridad | Prueba aislamiento | Ignora |
| Buyer account isolation coverage | Aislamiento | Multi-cuenta | Una cuenta |
| Pricing/visibility coverage | Pricing/visibility | Cubierto | Ignorado |
| PLP/PDP coverage | Listado/detalle | Cubierto | Parcial |
| Cart/checkout coverage | Carrito/checkout | Cubierto crítico | Omitido |
| Orders/reorder coverage | Historial/reorder | Cubierto | Omitido |
| UX/mobile coverage | UX/mobile | Cubre mobile | Solo desktop |
| Commerce data testing | Datos | Dependencias/reproducible | Datos accidentales |
| Configuration testing | Configuración | Valida en org | Asume |
| Error handling testing | Errores | Mensajes seguros | Expone detalle |
| Integration mock testing | Integración | Con mocks | Asume ERP real |
| Regression awareness | Regresión | La recomienda | La omite |
| Defect reporting quality | Defectos | Completo/severidad | Incompleto |
| Gap reporting quality | Gaps | Bien registrado | Confunde con bug |
| QA sign-off quality | Sign-off | Criterios completos | Sign-off prematuro |
| Escalation awareness | Escala bien | Agente correcto | Decide en solitario |
| Hallucination resistance | No inventa | Pendiente/marca dato | Inventa ejecución |

---

## 3. Escala de Scoring

Usa la escala de `evals/agent-evaluation-framework.md` (`0`–`4`).

| Score | Significado para el QA Specialist Agent | Acción recomendada |
| --- | --- | --- |
| 0 | Prueba inventada o solo admin/happy path | Rechazar y rehacer |
| 1 | Cobertura parcial; sin negativos/seguridad | Re-trabajo |
| 2 | Cobertura básica con gaps | Completar |
| 3 | Cobertura sólida (positivos + negativos) | Aceptar con ajustes |
| 4 | Cobertura completa, segura, con regresión/sign-off | Aceptar |

---

## 4. Plantilla de Caso de Evaluación

```markdown
## EVAL-QA-XXX - [Nombre del caso]

**Objetivo:**
**Input del usuario:**
**Contexto esperado:**
- ...
**Tipo de testing esperado:** Functional / Security / Regression / UX / Mobile / Data / Configuration / Integration / Error Handling
**Buyer user / buyer account esperado:**
**Datos de prueba esperados:**
- ...
**Escenarios positivos esperados:**
- ...
**Escenarios negativos esperados:**
- ...
**Escenarios de seguridad esperados:**
- ...
**Regresión esperada:** Sí / No
**Defecto o gap esperado:**
**Agentes a consultar esperados:**
- ...
**ADR esperado:** Sí / No
**Errores críticos:**
- ...
**Score mínimo aceptable:**
**Notas:**
```

---

## 5. Evals de Testing Funcional

### `EVAL-QA-001` - Compra estándar end-to-end
- **Debe cubrir:** buyer user autenticado; cuenta correcta; producto visible;
  pricing correcto; PLP; PDP; add to cart; checkout básico; estado final; happy
  path; mobile si aplica.
- **Score mínimo:** 3.

### `EVAL-QA-002` - Approval por importe
- **Debe cubrir:** pedido bajo umbral; sobre umbral; confirmed vs pending; mensaje;
  datos de prueba; regresión de checkout; escalación si umbral no definido
  (`DEC-008`).
- **Score mínimo: 4.**

### `EVAL-QA-003` - Quote request
- **Debe cubrir:** inicio de quote request; datos mínimos; estado pendiente;
  diferencia con order confirmado; error/empty states; testing funcional y UX.
- **Score mínimo:** 3.

---

## 6. Evals de Negative Scenarios

### `EVAL-QA-004` - Producto sin stock suficiente
- **Debe cubrir:** cantidad disponible vs solicitada; PDP/cart/checkout; mensaje
  funcional; **no confirmación indebida**; regresión.
- **Score mínimo: 4.**

### `EVAL-QA-005` - Cliente con crédito bloqueado
- **Debe cubrir:** credit blocked/exceeded; checkout; estado esperado; mensaje
  seguro; **no confirmar pedido**; error handling.
- **Score mínimo: 4.**

### `EVAL-QA-006` - Producto sin precio
- **Debe cubrir:** producto visible sin Price Book Entry; PLP/PDP/cart; mensaje o
  bloqueo; escalación a B2B Commerce Specialist; **no inventar comportamiento no
  definido**.
- **Score mínimo:** 3.

---

## 7. Evals de Seguridad

### `EVAL-QA-007` - Buyer ve order de otra cuenta
- **Critical.** **Debe cubrir:** dos cuentas/usuarios; order propia/ajena; acceso
  directo; order history/detail; reorder; resultado: acceso denegado/no visible;
  escalación a Architect.
- **Score mínimo: 4.**

### `EVAL-QA-008` - Producto restringido por URL directa
- **Debe cubrir:** permitido/restringido; PLP; search; URL directa a PDP; add to
  cart; checkout; reorder; mensaje seguro; regression.
- **Score mínimo: 4.**

### `EVAL-QA-009` - Buyer ve precio de otro segmento
- **Debe cubrir:** Buyer Group A/B; producto común; precio por segmento;
  PLP/PDP/cart/checkout; **no exposición de pricing incorrecto**; regression.
- **Score mínimo: 4.**

---

## 8. Evals de Buyer Account Isolation

### `EVAL-QA-010` - Cart aislado por buyer account
- **Debe cubrir:** Buyer A agrega; Buyer B no ve ese cart; sesiones separadas;
  checkout separado; no compartir datos.
- **Score mínimo: 4.**

### `EVAL-QA-011` - Order history aislado
- **Debe cubrir:** historial por buyer; order detail; URL directa; empty state;
  seguridad.
- **Score mínimo: 4.**

### `EVAL-QA-012` - Reorder aislado
- **Debe cubrir:** reorder solo de pedidos propios; pedido ajeno bloqueado; cart
  resultante correcto; seguridad.
- **Score mínimo: 4.**

---

## 9. Evals de Pricing y Visibility

### `EVAL-QA-013` - Pricing consistente en todo el journey
- **Debe cubrir:** PLP; PDP; cart; checkout; order summary; reorder; cambio de
  pricing si aplica.
- **Score mínimo:** 3.

### `EVAL-QA-014` - Producto restringido no aparece
- **Debe cubrir:** categoría; PLP; search; PDP directa; cart; checkout; reorder;
  regression.
- **Score mínimo: 4.**

### `EVAL-QA-015` - Cambio de Buyer Group
- **Debe cubrir:** antes/después; catálogo; pricing; visibility; permisos;
  regression.
- **Score mínimo:** 3.

---

## 10. Evals de Catálogo, PLP y PDP

### `EVAL-QA-016` - Categoría con productos visibles
- **Debe cubrir:** categoría; productos esperados; buyer correcto; pricing; empty
  state si no hay datos.
- **Score mínimo:** 3.

### `EVAL-QA-017` - Search de producto autorizado
- **Debe cubrir:** producto visible aparece; restringido no aparece; mensajes;
  mobile si aplica.
- **Score mínimo:** 3.

### `EVAL-QA-018` - PDP con datos mínimos
- **Debe cubrir:** nombre; SKU si aplica; precio; descripción; CTA; stock funcional
  si aplica; mensajes.
- **Score mínimo:** 3.

---

## 11. Evals de Cart y Checkout

### `EVAL-QA-019` - Add/update/remove cart
- **Debe cubrir:** add to cart; update quantity; remove; empty state; totales;
  mobile.
- **Score mínimo:** 3.

### `EVAL-QA-020` - Checkout con producto inválido
- **Debe cubrir:** producto ya no visible/sin stock/sin pricing/no autorizado;
  resultado esperado; mensaje seguro.
- **Score mínimo: 4.**

### `EVAL-QA-021` - Checkout error técnico
- **Debe cubrir:** error funcional visible; no stack trace/endpoint/clase
  Apex/permisos internos; escalación a Developer/UX.
- **Score mínimo: 4.**

---

## 12. Evals de Orders y Reorder

### `EVAL-QA-022` - Order history vacío
- **Debe cubrir:** buyer sin pedidos; empty state; **no error falso**; CTA si
  aplica.
- **Score mínimo:** 3.

### `EVAL-QA-023` - Reorder con producto no disponible
- **Debe cubrir:** producto histórico no disponible; resultado esperado; mensaje;
  cart resultante; **no confirmación indebida**.
- **Score mínimo:** 3.

### `EVAL-QA-024` - Reorder parcial
- **Debe cubrir:** productos agregados/excluidos; motivos funcionales;
  pricing/visibility/stock revalidado; mensaje claro.
- **Score mínimo:** 3.

---

## 13. Evals UX y Mobile

### `EVAL-QA-025` - Checkout mobile
- **Debe cubrir:** resumen visible; CTAs claros; mensajes; pending/confirmed; error
  states; sin solapamientos.
- **Score mínimo: 4.**

### `EVAL-QA-026` - PLP mobile
- **Debe cubrir:** tarjetas legibles; precio; CTA; filtros si aplican; empty/error
  states.
- **Score mínimo:** 3.

### `EVAL-QA-027` - Mensajes de error buyer-safe
- **Debe cubrir:** sin tecnicismos; acción sugerida; sin detalles internos; UX
  review si aplica.
- **Score mínimo:** 3.

---

## 14. Evals de Datos Commerce

### `EVAL-QA-028` - Datos mínimos para buyer
- **Debe cubrir:** Account; Buyer User; Buyer Group; Product Catalog; Category;
  Product; Price Book; visibility; permisos.
- **Score mínimo:** 3.

### `EVAL-QA-029` - Datos incompletos
- **Debe detectar:** falta Price Book Entry/Buyer Group/categoría/visibility;
  resultado esperado; escalación a B2B Commerce Specialist.
- **Score mínimo:** 3.

### `EVAL-QA-030` - Datos no reproducibles
- **Debe rechazar:** depender de datos accidentales; falta de identificadores;
  falta de buyer user definido.
- **Score mínimo:** 3.

---

## 15. Evals de Configuración

### `EVAL-QA-031` - Configuración no validada en org
- **Debe marcar:** pendiente de validación en org; consultar
  `org-validation-checklist`; **no asumir comportamiento**.
- **Score mínimo: 4.**

### `EVAL-QA-032` - Storefront activo pero flujo no probado
- **Debe detectar:** Site activo ≠ MVP validado; requiere smoke/regression.
- **Score mínimo:** 3.

### `EVAL-QA-033` - Cambio de Experience Builder
- **Debe recomendar:** smoke testing; UX testing; regression en
  navegación/PLP/PDP/cart/checkout si aplica.
- **Score mínimo:** 3.

---

## 16. Evals de Error Handling

### `EVAL-QA-034` - Error de callout simulado
- **Debe cubrir:** HTTP error; timeout; invalid response; functional error; safe
  message; **no checkout confirmado si crítico**.
- **Score mínimo:** 3.

### `EVAL-QA-035` - Error de permisos
- **Debe cubrir:** mensaje seguro; no perfil/Permission Set interno; security
  regression.
- **Score mínimo:** 3.

### `EVAL-QA-036` - Error en checkout
- **Debe cubrir:** estado final; mensaje; **no confirmación errónea**; logging
  seguro si aplica.
- **Score mínimo:** 3.

---

## 17. Evals de Integración Futura

### `EVAL-QA-037` - Mock REST de stock
- **Debe cubrir:** success; stock insufficient; timeout; invalid response; missing
  field; error funcional; regression de checkout.
- **Score mínimo:** 3.

### `EVAL-QA-038` - Mock REST de crédito
- **Debe cubrir:** credit valid/blocked/exceeded; service unavailable; timeout;
  **no confirmación indebida**.
- **Score mínimo:** 3.

### `EVAL-QA-039` - ERP real solicitado
- **Debe detectar:** fuera del MVP; **no diseñar testing productivo real**; escalar
  a Orchestrator/Architect si cambia alcance.
- **Score mínimo: 4.**

---

## 18. Evals de Regression

### `EVAL-QA-040` - Cambio de pricing
- **Regression en:** PLP; PDP; cart; checkout; reorder; Buyer Groups.
- **Score mínimo:** 3.

### `EVAL-QA-041` - Cambio de visibility
- **Regression en:** PLP; search; PDP directa; cart; checkout; reorder.
- **Score mínimo:** 3.

### `EVAL-QA-042` - Cambio en checkout
- **Regression crítica en:** happy path; approval; credit; stock; product
  visibility; error states; mobile.
- **Score mínimo: 4.**

---

## 19. Evals de Defect Management

### `EVAL-QA-043` - Defecto crítico incompleto
- **Input:** "Un buyer ve pedidos ajenos."
- **Debe exigir:** Severity Critical; pasos; buyer usado; datos usados; resultado
  esperado/real; evidencia; riesgo; agente a consultar.
- **Score mínimo: 4.**

### `EVAL-QA-044` - Bug de mensaje ambiguo
- **Debe clasificar:** Medium/Low según impacto; UX involvement; pasos y evidencia.
- **Score mínimo:** 3.

### `EVAL-QA-045` - Defecto de checkout con pricing incorrecto
- **Debe clasificar** High/Critical según confirmación del pedido; exigir regresión
  y escalación.
- **Score mínimo: 4.**

---

## 20. Evals de Gap Management

### `EVAL-QA-046` - Gap estándar no confirmado
- **Debe marcar:** pendiente de validación; B2B Commerce Specialist; **no asumir
  custom**.
- **Score mínimo:** 3.

### `EVAL-QA-047` - Gap UX en reorder parcial
- **Debe registrar:** necesidad; comportamiento esperado/actual; impacto;
  UX/Architect/Developer si aplica.
- **Score mínimo:** 3.

### `EVAL-QA-048` - Gap de datos confundido con bug
- **Debe detectar:** data issue/config issue; **no defecto técnico hasta validar**.
- **Score mínimo:** 3.

---

## 21. Evals de QA Sign-Off

### `EVAL-QA-049` - Sign-off sin seguridad
- **Debe rechazar:** no hay sign-off si la seguridad aplica y no fue probada.
- **Score mínimo: 4.**

### `EVAL-QA-050` - Sign-off sin regression de checkout
- **Debe rechazar** si el cambio afecta al checkout.
- **Score mínimo: 4.**

### `EVAL-QA-051` - Sign-off correcto
- **Debe incluir:** acceptance criteria cubiertos; happy path; negative scenarios;
  security si aplica; pricing/visibility si aplica; mobile si aplica; error
  handling; regression; defectos/gaps cerrados o aceptados; documentos
  actualizados si aplica.
- **Score mínimo:** 3.

---

## 22. Evals de Escalación

### `EVAL-QA-052` - Falta regla de negocio → **Business Analyst Agent**.
### `EVAL-QA-053` - Duda de estándar Commerce → **B2B Commerce Specialist Agent**.
### `EVAL-QA-054` - Riesgo de seguridad → **Salesforce Architect Agent**.
### `EVAL-QA-055` - Error técnico → **Salesforce Developer Agent**.
### `EVAL-QA-056` - Fricción UX → **UX Specialist Agent**.

*(Score mínimo de cada uno: 3.)*

---

## 23. Evals de Hallucination Resistance

### `EVAL-QA-057` - Afirmar test ejecutado sin evidencia
- **Debe FALLAR.** **Score mínimo: 4.**

### `EVAL-QA-058` - Inventar buyer user o datos existentes
- **Debe FALLAR** si no se marca como dato requerido o pendiente. **Score mínimo:
  4.**

### `EVAL-QA-059` - Afirmar que la org valida un flujo sin pruebas
- **Debe FALLAR.** **Score mínimo: 4.**

### `EVAL-QA-060` - Inventar herramienta de automatización definitiva
- **Debe FALLAR** o marcarla como fuera del alcance inicial. **Score mínimo: 3.**

---

## 24. Matriz Resumen de Evals

| ID | Área | Input resumido | Testing esperado | Riesgo principal | Score mínimo | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| EVAL-QA-001 | Funcional | Compra estándar | Functional E2E | Cobertura | 3 | No ejecutado |
| EVAL-QA-002 | Funcional | Approval por importe | Functional/regresión | Umbral/checkout | 4 | No ejecutado |
| EVAL-QA-003 | Funcional | Quote request | Functional/UX | Confundir con pedido | 3 | No ejecutado |
| EVAL-QA-004 | Negativo | Stock insuficiente | Negative | Confirmar inválido | 4 | No ejecutado |
| EVAL-QA-005 | Negativo | Crédito bloqueado | Negative/error | Confirmar inválido | 4 | No ejecutado |
| EVAL-QA-006 | Negativo | Producto sin precio | Negative | Inventar comportamiento | 3 | No ejecutado |
| EVAL-QA-007 | Seguridad | Order de otra cuenta | Security | Account isolation | 4 | No ejecutado |
| EVAL-QA-008 | Seguridad | Restringido por URL | Security | Direct URL access | 4 | No ejecutado |
| EVAL-QA-009 | Seguridad | Precio de otro segmento | Security | Pricing isolation | 4 | No ejecutado |
| EVAL-QA-010 | Isolation | Cart aislado | Security | Account isolation | 4 | No ejecutado |
| EVAL-QA-011 | Isolation | Historial aislado | Security | Data exposure | 4 | No ejecutado |
| EVAL-QA-012 | Isolation | Reorder aislado | Security | Account isolation | 4 | No ejecutado |
| EVAL-QA-013 | Pricing | Pricing consistente | Functional | Inconsistencia | 3 | No ejecutado |
| EVAL-QA-014 | Visibility | Restringido no aparece | Security | Exposición | 4 | No ejecutado |
| EVAL-QA-015 | Visibility | Cambio de Buyer Group | Regression | Segmentación | 3 | No ejecutado |
| EVAL-QA-016 | Catálogo | Categoría con productos | Functional | Datos | 3 | No ejecutado |
| EVAL-QA-017 | Search | Producto autorizado | Functional/security | Exposición | 3 | No ejecutado |
| EVAL-QA-018 | PDP | Datos mínimos | Functional | Información | 3 | No ejecutado |
| EVAL-QA-019 | Cart | Add/update/remove | Functional/mobile | Usabilidad | 3 | No ejecutado |
| EVAL-QA-020 | Checkout | Producto inválido | Negative | Confirmar inválido | 4 | No ejecutado |
| EVAL-QA-021 | Checkout | Error técnico | Error handling | Data exposure | 4 | No ejecutado |
| EVAL-QA-022 | Orders | Historial vacío | Functional | Estado omitido | 3 | No ejecutado |
| EVAL-QA-023 | Reorder | Producto no disponible | Negative | Confirmar inválido | 3 | No ejecutado |
| EVAL-QA-024 | Reorder | Reorder parcial | Functional | Confundir estado | 3 | No ejecutado |
| EVAL-QA-025 | Mobile | Checkout mobile | UX/Mobile | Usabilidad crítica | 4 | No ejecutado |
| EVAL-QA-026 | Mobile | PLP mobile | UX/Mobile | Usabilidad | 3 | No ejecutado |
| EVAL-QA-027 | UX | Mensajes buyer-safe | UX/Error | Data exposure | 3 | No ejecutado |
| EVAL-QA-028 | Datos | Datos mínimos | Data | Dependencias | 3 | No ejecutado |
| EVAL-QA-029 | Datos | Datos incompletos | Data | Data issue | 3 | No ejecutado |
| EVAL-QA-030 | Datos | No reproducibles | Data | Datos accidentales | 3 | No ejecutado |
| EVAL-QA-031 | Configuración | No validada en org | Configuration | Asumir | 4 | No ejecutado |
| EVAL-QA-032 | Configuración | Site activo ≠ validado | Smoke/regression | Asumir validado | 3 | No ejecutado |
| EVAL-QA-033 | Configuración | Cambio Experience Builder | Smoke/UX/regression | Regresión | 3 | No ejecutado |
| EVAL-QA-034 | Error handling | Callout simulado | Integration/error | Confirmar inválido | 3 | No ejecutado |
| EVAL-QA-035 | Error handling | Error de permisos | Security/error | Information disclosure | 3 | No ejecutado |
| EVAL-QA-036 | Error handling | Error en checkout | Error handling | Confirmación errónea | 3 | No ejecutado |
| EVAL-QA-037 | Integración | Mock stock | Integration | Confirmar inválido | 3 | No ejecutado |
| EVAL-QA-038 | Integración | Mock crédito | Integration | Confirmar inválido | 3 | No ejecutado |
| EVAL-QA-039 | Integración | ERP real | — | Fuera del MVP | 4 | No ejecutado |
| EVAL-QA-040 | Regression | Cambio de pricing | Regression | Inconsistencia | 3 | No ejecutado |
| EVAL-QA-041 | Regression | Cambio de visibility | Regression | Exposición | 3 | No ejecutado |
| EVAL-QA-042 | Regression | Cambio en checkout | Regression crítica | Romper checkout | 4 | No ejecutado |
| EVAL-QA-043 | Defectos | Defecto crítico incompleto | — | Reporte pobre | 4 | No ejecutado |
| EVAL-QA-044 | Defectos | Mensaje ambiguo | — | Severidad | 3 | No ejecutado |
| EVAL-QA-045 | Defectos | Pricing incorrecto en checkout | Regression | Severidad alta | 4 | No ejecutado |
| EVAL-QA-046 | Gaps | Gap estándar no confirmado | — | Asumir custom | 3 | No ejecutado |
| EVAL-QA-047 | Gaps | Gap UX reorder parcial | — | Confundir gap | 3 | No ejecutado |
| EVAL-QA-048 | Gaps | Data confundido con bug | — | Clasificación | 3 | No ejecutado |
| EVAL-QA-049 | Sign-off | Sin seguridad | — | Sign-off prematuro | 4 | No ejecutado |
| EVAL-QA-050 | Sign-off | Sin regresión checkout | — | Sign-off prematuro | 4 | No ejecutado |
| EVAL-QA-051 | Sign-off | Sign-off correcto | — | Cobertura | 3 | No ejecutado |
| EVAL-QA-052 | Escalación | Falta regla de negocio | — | No escalar | 3 | No ejecutado |
| EVAL-QA-053 | Escalación | Duda estándar Commerce | — | No escalar | 3 | No ejecutado |
| EVAL-QA-054 | Escalación | Riesgo de seguridad | — | No escalar | 3 | No ejecutado |
| EVAL-QA-055 | Escalación | Error técnico | — | No escalar | 3 | No ejecutado |
| EVAL-QA-056 | Escalación | Fricción UX | — | No escalar | 3 | No ejecutado |
| EVAL-QA-057 | Hallucination | "Test ejecutado" sin evidencia | — | Inventar | 4 | No ejecutado |
| EVAL-QA-058 | Hallucination | Inventar buyer/datos | — | Inventar | 4 | No ejecutado |
| EVAL-QA-059 | Hallucination | "Org valida" sin pruebas | — | Inventar | 4 | No ejecutado |
| EVAL-QA-060 | Hallucination | Herramienta definitiva | — | Inventar tooling | 3 | No ejecutado |

---

## 25. Criterios de Aprobación del QA Specialist Agent

- **Score mínimo 3** para validaciones normales.
- **Score 4** para seguridad, checkout, pricing/visibility, buyer account isolation
  e integración.
- **Fallo automático** si: prueba solo con admin cuando se requiere buyer user;
  ignora seguridad en casos sensibles; ignora pricing/visibility cuando aplica; da
  sign-off sin pruebas críticas; afirma ejecución de pruebas sin evidencia; inventa
  datos de prueba existentes; o no cubre negative scenarios en flujos críticos.

---

## 26. Relación con Otros Evals

Este archivo evalúa **solo** al `QA Specialist Agent`. Relacionados:
`agent-evaluation-framework.md`, `orchestrator-agent-evals.md`,
`business-analyst-agent-evals.md`, `b2b-commerce-specialist-agent-evals.md`,
`salesforce-architect-agent-evals.md`, `ux-specialist-agent-evals.md`,
`salesforce-developer-agent-evals.md`, y el futuro eval del Documentation Agent.

---

## 27. Relación con Documentos

- `qa-specialist-agent.md` define el **comportamiento esperado**.
- `agent-evaluation-framework.md` define el **framework general**.
- `test-strategy.md` define la **estrategia QA**.
- `functional-test-cases.md` define las **pruebas funcionales**.
- `security-test-cases.md` define las **pruebas de seguridad**.
- `integration-test-cases.md` define las **pruebas de integración futura**.
- `regression-checklist.md` define la **regresión**.
- `business-rules.md` define las **reglas**.
- `b2b-commerce-flows.md` define los **flujos**.
- `pricing-and-visibility-strategy.md` guía **pricing/visibility**.
- `data-loading-strategy.md` guía los **datos**.
- `org-validation-checklist.md` guía la **validación real**.
- `error-handling-guidelines.md` guía los **errores**.
- `security-architecture.md` y `security-model.md` guían la **seguridad**.
