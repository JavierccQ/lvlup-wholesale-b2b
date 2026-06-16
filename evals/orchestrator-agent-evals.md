# Orchestrator Agent Evals - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define **casos de evaluación** para medir la calidad del
`Orchestrator Agent` en el proyecto `LvlUp-Wholesale-B2B`.

Sirve para validar si el agente: clasifica correctamente solicitudes; selecciona el
agente líder adecuado; identifica documentación relevante; protege el MVP; refuerza
estándar primero; detecta riesgos de seguridad, pricing, visibility, checkout e
integración; recomienda testing y documentación; recomienda ADR cuando aplica; evita
sobre-ingeniería y sobre-documentación; y no inventa capacidades ni decisiones.

Estos evals son **manuales/conceptuales**; no implementan una herramienta
automática. La prosa va en español; los términos técnicos en inglés.

---

## 2. Criterios Específicos de Evaluación

| Criterio | Qué evalúa | Score alto | Score bajo |
| --- | --- | --- | --- |
| Request classification | Tipifica la solicitud | Clasifica bien y por área | Confunde el tipo |
| Lead agent selection | Elige agente líder | Líder correcto | Líder erróneo |
| Supporting agents selection | Consultados adecuados | Conjunto correcto | Omite o sobra agentes |
| Documentation awareness | Documentos a consultar | Cita los relevantes | Ignora el índice |
| MVP protection | Respeta alcance | Marca fuera del MVP | Mete features fuera de fase |
| Standard-first enforcement | Estándar antes de custom | Frena custom prematuro | Permite el salto |
| Security awareness | Detecta riesgo | Prioriza seguridad | Ignora seguridad |
| Pricing/visibility awareness | Detecta impacto | Considera segmento/restricción | Ignora pricing/visibility |
| Cart/checkout awareness | Detecta impacto crítico | Revalidación/estado | Ignora checkout |
| Testing awareness | Recomienda pruebas | Pide testing/regresión | Cierra sin testing |
| ADR awareness | ADR proporcional | ADR solo cuando aplica | ADR para todo / ninguno |
| Overdocumentation prevention | Evita exceso | Propone actualizar | Crea archivos por inercia |
| Hallucination resistance | No inventa | Marca pendiente de validación | Inventa capacidad/decisión |
| Practical next step | Próximo paso claro | Acción accionable | Vago o sin salida |

---

## 3. Escala de Scoring

Usa la escala de `evals/agent-evaluation-framework.md` (`0 - Incorrecto`,
`1 - Débil`, `2 - Aceptable`, `3 - Bueno`, `4 - Excelente`).

| Score | Significado para el Orchestrator Agent | Acción recomendada |
| --- | --- | --- |
| 0 | Mala clasificación, riesgo o invención | Rechazar y rehacer |
| 1 | Clasifica parcialmente; omite agentes/riesgos | Re-trabajo |
| 2 | Ruta básica correcta, con gaps | Completar |
| 3 | Buena orquestación con criterios correctos | Aceptar con ajustes |
| 4 | Orquestación completa, segura y accionable | Aceptar |

---

## 4. Plantilla de Caso de Evaluación

```markdown
## EVAL-ORCH-XXX - [Nombre del caso]

**Objetivo:**
**Input del usuario:**
**Contexto esperado:**
- ...
**Agente líder esperado:**
**Agentes consultados esperados:**
- ...
**Documentos esperados:**
- ...
**Respuesta esperada:**
**Riesgos que debe detectar:**
- ...
**Testing esperado:**
**ADR esperado:** Sí / No
**Errores críticos:**
- ...
**Score mínimo aceptable:**
**Notas:**
```

---

## 5. Evals de Clasificación de Solicitudes

### `EVAL-ORCH-001` - Nuevo requerimiento funcional ambiguo
- **Input:** "Quiero que los clientes puedan pedir aprobación cuando el pedido sea muy caro."
- **Clasificación:** requerimiento funcional.
- **Agente líder:** `Business Analyst Agent`. **Consultados:** `B2B Commerce
  Specialist`, `Salesforce Architect`, `QA Specialist`.
- **Debe detectar:** umbral no definido (`DEC-008`); confirmed vs pending; MVP
  alignment; testing funcional; posible ADR si hay lógica central.
- **Score mínimo:** 3.

### `EVAL-ORCH-002` - Solicitud técnica prematura de Apex
- **Input:** "Crea una clase Apex para validar stock en checkout."
- **Debe frenar** el Apex directo.
- **Agente líder:** `B2B Commerce Specialist` o `Business Analyst` según contexto.
- **Debe detectar:** validar estándar/configuración/datos primero; stock funcional
  dentro del MVP; integración real fuera del MVP; Apex solo si gap validado; posible
  ADR si bloquea checkout.
- **Score mínimo:** 3.

### `EVAL-ORCH-003` - Solicitud UX de componente custom
- **Input:** "Quiero un LWC más bonito para mostrar productos en la PLP."
- **Debe frenar** el LWC por estética.
- **Agente líder:** `UX Specialist`. **Consultados:** `B2B Commerce Specialist`,
  `Salesforce Architect` (si hay customización).
- **Debe detectar:** Experience Builder first; componentes estándar; LWC solo con
  gap UX real; testing mobile.
- **Score mínimo:** 3.

---

## 6. Evals de Standard First

### `EVAL-ORCH-004` - Producto restringido no aparece para un buyer
- **Agente líder:** `B2B Commerce Specialist`.
- **Documentos:** `pricing-and-visibility-strategy`, `b2b-commerce-standard-capabilities`,
  `security-model`, `functional-test-cases`, `security-test-cases`.
- **Debe evitar:** Apex directo, LWC directo, manipulación visual.
- **Score mínimo:** 3.

### `EVAL-ORCH-005` - Buyer ve precio incorrecto
- **Riesgo alto.** **Agente líder:** `B2B Commerce Specialist`. **Consultados:**
  `Salesforce Architect`, `QA Specialist`.
- **Debe detectar:** pricing/visibility; Buyer Group; Price Book; seguridad
  comercial; regresión.
- **Score mínimo:** 4.

### `EVAL-ORCH-006` - Problema de datos Commerce
- **Input:** "Los productos no aparecen en la categoría de consolas."
- **Clasificación:** posible configuración/data issue.
- **Debe evitar** el desarrollo custom (distinguir data/config de código).
- **Score mínimo:** 3.

---

## 7. Evals de Seguridad

### `EVAL-ORCH-007` - Buyer accede a pedido de otra cuenta
- **Clasificación:** seguridad crítica. **Agente líder:** `Salesforce Architect`.
  **Consultados:** `B2B Commerce Specialist`, `QA Specialist`, `Salesforce
  Developer` (si hay custom code).
- **Debe recomendar:** security testing; regression; posible ADR si requiere cambio
  arquitectónico.
- **Score mínimo: 4.**

### `EVAL-ORCH-008` - URL directa a PDP restringida
- **Debe detectar:** direct URL access; product visibility; buyer account
  isolation; error seguro; testing de seguridad.
- **Score mínimo:** 4.

### `EVAL-ORCH-009` - Error técnico visible al buyer
- **Agentes:** `Salesforce Developer`, `UX Specialist`, `QA Specialist`.
- **Debe detectar:** error handling; no stack trace; safe message; regression.
- **Score mínimo:** 3.

---

## 8. Evals de Checkout

### `EVAL-ORCH-010` - Checkout confirma pedido con crédito bloqueado
- **Clasificación:** riesgo crítico de checkout. **Agente líder:** `Salesforce
  Architect`. **Consultados:** `Business Analyst`, `B2B Commerce Specialist`,
  `Salesforce Developer`, `QA Specialist`.
- **Debe detectar:** credit validation; confirmed vs pending; cart/checkout
  revalidation; testing crítico; ADR si se introduce lógica custom.
- **Score mínimo: 4.**

### `EVAL-ORCH-011` - Pedido sobre umbral no queda pendiente
- **Debe detectar:** approval threshold; business rule; checkout state; QA
  regression; posible Flow/Apex solo tras análisis.
- **Score mínimo:** 3.

### `EVAL-ORCH-012` - Producto restringido llega al carrito
- **Debe detectar:** security; visibility; cart revalidation; checkout risk.
- **Score mínimo:** 4.

---

## 9. Evals de Integración Futura

### `EVAL-ORCH-013` - Solicitud de conectar ERP real
- **Input:** "Conectemos ya el ERP real para stock y facturas."
- **Respuesta:** ERP real está **fuera del MVP**. **Agente líder:** `Salesforce
  Architect`.
- **Debe detectar:** fuera del MVP; integración mock futura; ADR si se decide
  cambiar alcance; **no implementar integración real**.
- **Score mínimo:** 4.

### `EVAL-ORCH-014` - Postman Mock Server para stock
- **Clasificación:** integración futura/mock. **Consultados:** `Salesforce
  Architect`, `Salesforce Developer`, `QA Specialist`.
- **Debe recomendar ADR** si se adopta como decisión.
- **Score mínimo:** 3.

### `EVAL-ORCH-015` - Timeout en servicio de crédito
- **Debe detectar:** checkout crítico; error handling; retry policy; logging; ADR si
  se define política.
- **Score mínimo:** 3.

---

## 10. Evals de Documentación

### `EVAL-ORCH-016` - Crear archivo nuevo innecesario
- **Input:** "Crea otro documento específico para mensajes de error de PDP."
- **Debe evaluar** si ya existe `empty-error-loading-states.md` o
  `error-handling-guidelines.md`. **Agente líder:** `Documentation Agent`.
- **Debe preferir actualizar** el documento existente.
- **Score mínimo:** 3.

### `EVAL-ORCH-017` - Índice desalineado con archivos reales
- **Agente líder:** `Documentation Agent`.
- **Debe detectar:** taxonomía real; archivos existentes; índice como fuente de
  navegación; no seguir creando archivos hasta realinear.
- **Score mínimo:** 3.

### `EVAL-ORCH-018` - Crear evals por cada microtema
- **Debe detectar** sobre-documentación y **recomendar consolidar o aplazar**.
- **Score mínimo:** 3.

---

## 11. Evals de ADR Awareness

### `EVAL-ORCH-019` - Custom LWC para reorder
- **Debe detectar:** customización relevante; UX; security; pricing/visibility;
  testing; **ADR probable**.
- **Score mínimo:** 3.

### `EVAL-ORCH-020` - Cambio menor de texto en empty state
- **Debe detectar:** **no requiere ADR**; puede actualizar UX docs si aplica;
  testing ligero.
- **Score mínimo:** 3.

### `EVAL-ORCH-021` - Named Credential para integración mock
- **Debe detectar:** integración; security; Developer/Architect; **ADR probable**.
- **Score mínimo:** 3.

---

## 12. Evals de Escalación entre Agentes

### `EVAL-ORCH-022` - Solicitud con impacto funcional, UX y técnico
- **Debe** seleccionar el agente líder correcto y el conjunto de consultados.
- **Score mínimo:** 3.

### `EVAL-ORCH-023` - Conflicto entre UX y seguridad
- **Debe priorizar la seguridad** y escalar a `Salesforce Architect`.
- **Score mínimo:** 4.

### `EVAL-ORCH-024` - Conflicto entre MVP y nueva necesidad
- **Debe marcar fuera del MVP** o requerir decisión explícita.
- **Score mínimo:** 3.

---

## 13. Evals de Hallucination Resistance

### `EVAL-ORCH-025` - ¿Existe esta capacidad en la org?
- **Debe marcar pendiente de validación** si no hay evidencia.
- **Score mínimo:** 4 (no inventar).

### `EVAL-ORCH-026` - Asumir que todo Commerce es metadata deployable
- **Debe corregir la suposición** (data ≠ metadata).
- **Score mínimo:** 4.

### `EVAL-ORCH-027` - Continuar con un archivo que ya existe
- **Debe detectar** posible duplicidad y usar el índice/estado real.
- **Score mínimo:** 3.

---

## 14. Matriz Resumen de Evals

| ID | Área | Input resumido | Agente líder esperado | Riesgo principal | Score mínimo | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| EVAL-ORCH-001 | Clasificación | Aprobación por importe | Business Analyst | Scope/umbral | 3 | No ejecutado |
| EVAL-ORCH-002 | Clasificación | Apex para stock | B2B Commerce/BA | Apex prematuro | 3 | No ejecutado |
| EVAL-ORCH-003 | Clasificación | LWC "más bonito" PLP | UX Specialist | LWC por estética | 3 | No ejecutado |
| EVAL-ORCH-004 | Standard-first | Restringido aparece | B2B Commerce | Custom prematuro | 3 | No ejecutado |
| EVAL-ORCH-005 | Standard-first | Precio incorrecto | B2B Commerce | Pricing/seguridad | 4 | No ejecutado |
| EVAL-ORCH-006 | Standard-first | Productos sin categoría | B2B Commerce | Data vs código | 3 | No ejecutado |
| EVAL-ORCH-007 | Seguridad | Pedido de otra cuenta | Salesforce Architect | Account isolation | 4 | No ejecutado |
| EVAL-ORCH-008 | Seguridad | URL directa PDP restringida | Salesforce Architect | Direct URL access | 4 | No ejecutado |
| EVAL-ORCH-009 | Seguridad | Error técnico visible | Developer/UX/QA | Data exposure | 3 | No ejecutado |
| EVAL-ORCH-010 | Checkout | Confirma con crédito bloqueado | Salesforce Architect | Checkout crítico | 4 | No ejecutado |
| EVAL-ORCH-011 | Checkout | Sobre umbral no pendiente | Business Analyst | Approval state | 3 | No ejecutado |
| EVAL-ORCH-012 | Checkout | Restringido en carrito | B2B Commerce | Visibility/checkout | 4 | No ejecutado |
| EVAL-ORCH-013 | Integración | Conectar ERP real | Salesforce Architect | Fuera del MVP | 4 | No ejecutado |
| EVAL-ORCH-014 | Integración | Postman Mock stock | Salesforce Architect | ADR de integración | 3 | No ejecutado |
| EVAL-ORCH-015 | Integración | Timeout de crédito | Salesforce Architect | Resiliencia/checkout | 3 | No ejecutado |
| EVAL-ORCH-016 | Documentación | Doc nuevo de errores PDP | Documentation | Duplicidad | 3 | No ejecutado |
| EVAL-ORCH-017 | Documentación | Índice desalineado | Documentation | Trazabilidad | 3 | No ejecutado |
| EVAL-ORCH-018 | Documentación | Evals por microtema | Documentation | Sobre-documentación | 3 | No ejecutado |
| EVAL-ORCH-019 | ADR | Custom LWC reorder | Salesforce Architect | ADR probable | 3 | No ejecutado |
| EVAL-ORCH-020 | ADR | Texto de empty state | UX Specialist | ADR innecesario | 3 | No ejecutado |
| EVAL-ORCH-021 | ADR | Named Credential mock | Salesforce Architect | ADR probable | 3 | No ejecutado |
| EVAL-ORCH-022 | Escalación | Impacto funcional+UX+técnico | Según análisis | Coordinación | 3 | No ejecutado |
| EVAL-ORCH-023 | Escalación | UX vs seguridad | Salesforce Architect | Priorizar seguridad | 4 | No ejecutado |
| EVAL-ORCH-024 | Escalación | MVP vs nueva necesidad | Business Analyst | Scope | 3 | No ejecutado |
| EVAL-ORCH-025 | Hallucination | ¿Capacidad en la org? | — | Inventar capacidad | 4 | No ejecutado |
| EVAL-ORCH-026 | Hallucination | Todo es metadata | — | data≠metadata | 4 | No ejecutado |
| EVAL-ORCH-027 | Hallucination | Archivo ya existente | Documentation | Duplicidad | 3 | No ejecutado |

---

## 15. Criterios de Aprobación del Orchestrator Agent

- **Score mínimo 3** para solicitudes normales.
- **Score 4** para seguridad, checkout, pricing/visibility o integración.
- **Fallo automático** si: propone customización sin validar estándar; ignora buyer
  account isolation en casos sensibles; inventa validación de org; o crea documentos
  innecesarios cuando debe actualizar existentes.

---

## 16. Relación con Otros Evals

Este archivo evalúa **solo** al `Orchestrator Agent`. Futuros archivos (solo si
aportan valor y están en el índice):

- `business-analyst-agent-evals.md`
- `b2b-commerce-specialist-agent-evals.md`
- `salesforce-architect-agent-evals.md`
- `ux-specialist-agent-evals.md`
- `salesforce-developer-agent-evals.md`
- `qa-specialist-agent-evals.md`
- `documentation-agent-evals.md`

---

## 17. Relación con Documentos

- `agent-evaluation-framework.md` define el **framework general**.
- `orchestrator-agent.md` define el **comportamiento esperado**.
- `DOCUMENTATION_INDEX.md` guía la **estructura**.
- `standard-vs-custom-framework.md` guía el **standard-first**.
- `security-architecture.md` guía la **seguridad**.
- `test-strategy.md` guía el **testing**.
- `regression-checklist.md` guía la **regresión**.
- `agents/` define los **agentes especializados**.
