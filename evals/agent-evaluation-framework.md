# Agent Evaluation Framework - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define el **framework base para evaluar la calidad** de las
respuestas y decisiones de los agentes de IA del proyecto `LvlUp-Wholesale-B2B`.

Sirve para evaluar: alineación con el contexto del proyecto, respeto del MVP, uso
correcto de la documentación, **estándar primero**, calidad funcional y técnica,
seguridad, UX, testing, escalación entre agentes, recomendación de ADR y prevención
de la sobre-documentación.

Este archivo **no implementa una herramienta automática de evaluación**. La prosa
va en español; los términos técnicos en inglés.

---

## 2. Principios de Evaluación

- Evaluar **comportamiento**, no solo formato.
- Evaluar si el agente **consulta el contexto correcto**.
- Evaluar si respeta *Configuration first, customization only when justified*.
- Evaluar si **protege el MVP** y evita soluciones custom prematuras.
- Evaluar si **identifica riesgos** y marca **pendientes de validación**.
- Evaluar si **recomienda testing** y **escala correctamente**.
- Evaluar si **evita la sobre-documentación**.
- Evaluar si **no inventa capacidades Salesforce**.

---

## 3. Alcance del Framework

### Incluido

Evaluación de respuestas de agentes; de decisiones funcionales, de B2B Commerce, de
UX y técnicas; de QA/testing; documental; de ADR recommendation; y de riesgos.

### Fuera del alcance inicial

Herramienta automática de evaluación, métricas productivas reales, testing con
usuarios reales, evaluación estadística avanzada, benchmark externo, evaluación de
modelos IA fuera del proyecto e integración con CI/CD.

---

## 4. Dimensiones de Evaluación

| Dimensión | Qué evalúa | Señal de buena respuesta | Señal de mala respuesta | Agentes más afectados |
| --- | --- | --- | --- | --- |
| Context alignment | Usa el contexto correcto | Cita documentos relevantes | Ignora `PROJECT_CONTEXT`/índice | Todos |
| MVP alignment | Respeta el alcance | Marca lo fuera del MVP | Mete features fuera de fase | Orchestrator, BA |
| Standard-first behavior | Estándar antes que custom | Valida estándar primero | Salta a Apex/LWC | B2B Commerce, Architect, Developer |
| Salesforce B2B Commerce correctness | No inventa capacidades | "Pendiente de validación" | Inventa capacidades | B2B Commerce |
| Functional clarity | Problema bien definido | Actor/flujo/criterios claros | Ambigüedad | BA |
| Architecture quality | Decisión sólida | Justifica trade-offs | Over-engineering | Architect |
| Security awareness | Considera seguridad | Revalidación backend | "Seguridad solo UI" | Architect, Developer, QA |
| Buyer account isolation | Aislamiento por cuenta | Datos solo de su cuenta | Fuga entre cuentas | Todos |
| UX quality | Experiencia clara | Mobile-first, estados | LWC por estética | UX |
| Technical quality | Código sano | Bulk-safe, testeable | SOQL en loops, hardcoded IDs | Developer |
| Testing coverage | Cobertura suficiente | Positivos + negativos + seguridad | Solo happy path | QA |
| Documentation discipline | Documentación útil | Actualiza antes de crear | Duplica/sobre-documenta | Documentation |
| Escalation quality | Escala bien | Consulta al agente correcto | Decide en solitario | Todos |
| ADR awareness | ADR cuando toca | ADR en decisión relevante | ADR para todo / ninguno | Architect, Developer |
| Anti-overengineering | Solución proporcional | Simple y suficiente | Arquitectura enterprise innecesaria | Architect, Developer |
| Anti-overdocumentation | Documentación proporcional | Consolida | Archivo por microtema | Documentation, Orchestrator |

---

## 5. Escala de Scoring

| Score | Significado | Cuándo usar | Acción recomendada |
| --- | --- | --- | --- |
| 0 - Incorrecto | Respuesta peligrosa, fuera de contexto o inventada | Hay riesgo o alucinación | Rechazar y rehacer |
| 1 - Débil | Reconoce parcialmente, omite criterios importantes | Faltan dimensiones clave | Re-trabajo |
| 2 - Aceptable | Cubre lo básico, con gaps o poca trazabilidad | Sirve pero mejorable | Completar gaps |
| 3 - Bueno | Alineado, criterios correctos, riesgos razonables | Respuesta sólida | Aceptar con ajustes menores |
| 4 - Excelente | Totalmente alineado, seguro, accionable, con escalación/testing/documentación | Decisión crítica bien resuelta | Aceptar |

---

## 6. Criterios Globales de Calidad

Un agente puntúa alto si: usa el contexto correcto; respeta el MVP; valida estándar
antes de custom; **no inventa capacidades Salesforce**; identifica actor, flujo y
área afectada; considera buyer account isolation, pricing/visibility, cart/checkout
(si aplica) y UX/mobile (si aplica); considera testing y documentación; escala
cuando corresponde; recomienda ADR **solo cuando aplica**; y evita crear documentos
innecesarios.

---

## 7. Criterios Globales de Fallo

Un agente puntúa bajo si: propone Apex directamente sin validar estándar; propone
LWC por estética; propone integración real dentro del MVP; ignora buyer account
isolation, pricing/visibility, checkout, seguridad o testing; inventa
objetos/campos/componentes/capacidades; crea documentos por inercia; no marca
pendientes de validación; recomienda ADR para decisiones triviales o **no** lo
recomienda para decisiones críticas; o contradice `PROJECT_CONTEXT.md` o `CLAUDE.md`.

---

## 8. Evaluación por Agente

### Orchestrator Agent
Clasifica correctamente la solicitud; selecciona agente líder; identifica documentos
base; detecta riesgos; evita sobre-documentación; recomienda ADR cuando aplica.

### Business Analyst Agent
Refina requerimientos; define actores, reglas de negocio y acceptance criteria;
protege el MVP; no propone solución técnica prematura.

### B2B Commerce Specialist Agent
Valida estándar; revisa configuración y datos Commerce; detecta gaps reales; no
salta a customización.

### Salesforce Architect Agent
Evalúa impacto arquitectónico; revisa seguridad y standard vs custom; revisa
integración; recomienda ADR correctamente.

### UX Specialist Agent
Revisa mobile-first y Experience Builder first; revisa mensajes y estados UX; no
propone LWC por estética.

### Salesforce Developer Agent
Propone técnica solo con gap validado; distingue Flow/LWC/Apex/integration; respeta
seguridad; considera testing y deployment.

### QA Specialist Agent
Cubre happy path y negative scenarios; cubre seguridad y pricing/visibility; cubre
regression; prueba con buyer user.

### Documentation Agent
Evita duplicidad; mantiene el índice; recomienda actualizar antes de crear; detecta
sobre-documentación; mantiene consistencia de idioma y naming.

---

## 9. Matriz de Evaluación Global

Manual y simple (sin fórmulas complejas). El peso es orientativo.

| Criterio | Peso sugerido | Score 0-4 | Evidencia esperada | Comentarios |
| --- | --- | --- | --- | --- |
| Context alignment | Alto | — | Documentos citados | — |
| MVP alignment | Alto | — | Alcance respetado | — |
| Standard-first | Alto | — | Estándar validado primero | — |
| Security | Alto | — | Revalidación/seguridad | — |
| Buyer account isolation | Alto | — | Aislamiento por cuenta | — |
| Pricing/visibility | Alto | — | Consistencia/restricción | — |
| UX/mobile | Medio | — | Estados y mobile | — |
| Technical correctness | Medio | — | Bulk-safe, testeable | — |
| Testing | Alto | — | Positivos + negativos | — |
| Documentation | Medio | — | Sin duplicidad | — |
| Escalation | Medio | — | Agente correcto | — |
| ADR awareness | Medio | — | ADR proporcional | — |
| Practicality | Medio | — | Solución proporcional | — |

---

## 10. Plantilla de Evaluación de Respuesta

```markdown
## Evaluación de Respuesta de Agente

**Agente evaluado:**
**Solicitud evaluada:**
**Contexto usado:**
**Score global:** 0 / 1 / 2 / 3 / 4
**Puntos fuertes:**
- ...
**Gaps detectados:**
- ...
**Riesgos:**
- ...
**Criterios omitidos:**
- ...
**¿Escaló correctamente?** Sí / No / No aplica
**¿Recomendó testing?** Sí / No / No aplica
**¿Recomendó ADR correctamente?** Sí / No / No aplica
**¿Hubo sobre-documentación?** Sí / No
**Corrección recomendada:**
```

---

## 11. Plantilla de Caso de Evaluación

```markdown
## Caso de Evaluación

**ID:** EVAL-...
**Agente objetivo:**
**Input del usuario:**
**Contexto esperado:**
- ...
**Respuesta esperada:**
**Criterios de evaluación:**
- ...
**Errores críticos a detectar:**
- ...
**Score mínimo aceptable:**
**Notas:**
```

---

## 12. Tipos de Casos de Evaluación

| Tipo | Qué mide | Agentes aplicables | Ejemplo conceptual |
| --- | --- | --- | --- |
| Functional requirement eval | Refinamiento funcional | BA, Orchestrator | Convertir idea ambigua en requerimiento claro |
| Standard vs custom eval | Estándar antes que custom | B2B Commerce, Architect, Developer | Frenar un salto directo a Apex |
| Security eval | Seguridad/aislamiento | Architect, Developer, QA | Detectar fuga de visibilidad |
| UX eval | Experiencia/mobile | UX | Evitar LWC por estética |
| Technical solution eval | Calidad técnica | Developer | Flow vs Apex justificado |
| Testing eval | Cobertura de pruebas | QA | Incluir negativos y seguridad |
| Documentation eval | Disciplina documental | Documentation | Actualizar en vez de crear |
| ADR eval | ADR awareness | Architect, Developer | ADR solo en decisión relevante |
| Overdocumentation eval | Anti-sobredocumentación | Documentation, Orchestrator | Consolidar en vez de fragmentar |
| Hallucination resistance eval | No inventar | Todos | Marcar "pendiente de validación" |

---

## 13. Evaluación de Alucinaciones

Señales: inventar objetos/campos; inventar capacidades B2B Commerce; inventar
archivos inexistentes; inventar decisiones no tomadas; inventar configuración
"validada"; decir que algo está implementado sin evidencia; **omitir "pendiente de
validación"** cuando corresponde; proponer integración real sin contexto.

> Cualquier alucinación de implementación "validada" debe puntuar **0** y corregirse
> exigiendo el marcado de pendiente de validación.

---

## 14. Evaluación de Sobre-Documentación

Señales: crear archivos sin necesidad; proponer documentos fuera de fase; duplicar
contenido; fragmentar excesivamente una carpeta; no revisar el índice; no actualizar
lo existente antes de crear; crear evals/ADRs/agentes por simetría.

> El **Documentation Agent** y el **Orchestrator Agent** deben detectar y corregir
> esto.

---

## 15. Evaluación de ADR Awareness

Evaluar que el agente recomienda ADR cuando hay: custom LWC relevante; Apex para
lógica central; Flow central; integración REST; Named Credential; checkout
relevante; pricing/visibility relevante; seguridad relevante; logging persistente;
o cambio de alcance del MVP.

> También se evalúa que **evite** ADR para decisiones menores.

---

## 16. Evaluación de Testing Awareness

Evaluar que el agente considera: functional testing, security testing, regression,
buyer user testing, pricing/visibility, cart/checkout, error handling, mobile e
integration mocks (si aplica).

---

## 17. Evaluación de Seguridad

Evaluar que el agente considera: buyer account isolation; product visibility;
pricing visibility; order access; cart/checkout revalidation; direct URL access;
**no UI-only security**; safe error messages; **no secrets/log exposure**.

---

## 18. Evaluación de Standard-First

Evaluar que el agente sigue el orden: 1) Salesforce B2B Commerce estándar,
2) Experience Builder, 3) Configuración, 4) Datos, 5) Flow, 6) LWC, 7) Apex,
8) Integración externa.

> Penalizar si **salta directamente a custom** sin gap.

---

## 19. Evaluación de Escalación entre Agentes

| Situación | Escalación esperada | Error común |
| --- | --- | --- |
| Necesidad funcional ambigua | Business Analyst Agent | Saltar a solución técnica |
| Duda de capacidad estándar | B2B Commerce Specialist Agent | Asumir capacidad no validada |
| Riesgo de seguridad / decisión técnica relevante | Salesforce Architect Agent | Decidir en solitario |
| Fricción UX / mensajes / mobile | UX Specialist Agent | Ignorar mobile |
| Gap real que requiere código | Salesforce Developer Agent | Apex/LWC sin validar estándar |
| Cobertura de pruebas / regresión | QA Specialist Agent | Cerrar sin testing |
| Duplicidad / índice / consolidación | Documentation Agent | Crear archivo innecesario |
| Conflicto / cambio de alcance / múltiples agentes | Orchestrator Agent | No coordinar |

---

## 20. Mínimos de Aprobación

- **Score 3 o superior** para aceptar una respuesta importante.
- **Score 4** para decisiones críticas.
- **Score menor a 2** requiere re-trabajo.
- Cualquier respuesta con **riesgo de seguridad crítico** falla automáticamente.
- Cualquier respuesta que **invente implementación validada** falla automáticamente.
- Cualquier respuesta que **recomiende customización sin validar estándar** debe
  corregirse.

---

## 21. Relación con Otros Archivos de Evals

Este framework es la base para futuros archivos (solo si el índice los requiere y
aportan valor real):

- `evals/orchestrator-agent-evals.md`
- `evals/business-analyst-agent-evals.md`
- `evals/b2b-commerce-specialist-agent-evals.md`
- `evals/salesforce-architect-agent-evals.md`
- `evals/ux-specialist-agent-evals.md`
- `evals/salesforce-developer-agent-evals.md`
- `evals/qa-specialist-agent-evals.md`
- `evals/documentation-agent-evals.md`

> Esos archivos **no se crean ahora**; este documento solo los referencia.

---

## 22. Relación con Documentos

- `agents/` define el **comportamiento esperado** de los agentes.
- Este archivo define **cómo evaluar** ese comportamiento.
- `PROJECT_CONTEXT.md` define el **contexto general**.
- `CLAUDE.md` define las **reglas operativas**.
- `standard-vs-custom-framework.md` guía la **evaluación de customización**.
- `security-architecture.md` guía la **evaluación de seguridad**.
- `code-review-checklist.md` guía la **evaluación técnica**.
- `test-strategy.md` guía la **evaluación QA**.
- `regression-checklist.md` guía la **regresión**.
- `docs/DOCUMENTATION_INDEX.md` guía la **estructura documental**.
