# Documentation Agent Evals - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define **casos de evaluación** para medir la calidad del
`Documentation Agent` en el proyecto `LvlUp-Wholesale-B2B`.

Sirve para validar si el agente: mantiene **coherencia documental**; evita
**duplicidades**; evita **sobre-documentación**; **actualiza documentos existentes
antes de crear nuevos**; mantiene actualizado `docs/DOCUMENTATION_INDEX.md`; respeta
la **taxonomía** de carpetas y agentes; respeta las **naming conventions**; respeta
la **política de idioma**; detecta **contradicciones**; detecta **documentos
obsoletos**; recomienda **consolidación** cuando aplica; recomienda **ADR** cuando
corresponde; **evita ADRs innecesarios**; y mantiene la **trazabilidad** entre
documentos, agentes y evals.

Estos evals son **manuales/conceptuales**; no implementan una herramienta
automática. La prosa va en español; los términos técnicos en inglés.

---

## 2. Criterios Específicos de Evaluación

| Criterio | Qué evalúa | Score alto | Score bajo |
| --- | --- | --- | --- |
| Documentation coherence | Coherencia global | Documentos alineados | Contradicciones |
| Index alignment | Índice al día | Refleja el repo | Desalineado |
| Update-before-create | Actualizar primero | Reusa lo existente | Crea por defecto |
| Duplicate detection | Duplicidad | La detecta | La ignora |
| Overdocumentation prevention | Exceso documental | Lo evita | Fragmenta todo |
| Naming convention awareness | Naming | kebab-case correcto | Nombre genérico |
| Language policy awareness | Idioma | Español + técnico EN | Mezcla sin criterio |
| Agent taxonomy awareness | Taxonomía agentes | 8 agentes oficiales | Nombres antiguos |
| Cross-reference quality | Referencias | Útiles, reales | Decorativas/rotas |
| Contradiction detection | Contradicciones | Las detecta | Las pasa por alto |
| ADR awareness | ADR pertinente | Solo si relevante | ADR para todo/nada |
| Evals awareness | Evals correctos | Miden comportamiento | Repiten docs |
| MVP alignment | Alcance MVP | Respeta el alcance | Documenta fuera |
| Standard-first consistency | Estándar primero | Refuerza estándar | Custom primero |
| Practical documentation judgment | Criterio práctico | Documenta lo útil | Burocracia |
| Hallucination resistance | No inventa | Marca pendiente | Inventa archivo/estado |

---

## 3. Escala de Scoring

Usa la escala de `evals/agent-evaluation-framework.md`.

| Score | Significado para el Documentation Agent | Acción recomendada |
| --- | --- | --- |
| 0 - Incorrecto | Crea por defecto, duplica o inventa archivos/estados | Rechazar y rehacer |
| 1 - Débil | Ignora índice/duplicidad; sin criterio práctico | Re-trabajo |
| 2 - Aceptable | Decisión básica con gaps de coherencia | Completar |
| 3 - Bueno | Actualiza/consolida bien; índice y naming correctos | Aceptar con ajustes |
| 4 - Excelente | Coherencia total: índice, taxonomía, ADR, anti-duplicidad | Aceptar |

---

## 4. Plantilla de Caso de Evaluación

```markdown
## EVAL-DOC-XXX - [Nombre del caso]

**Objetivo:**
...

**Input del usuario:**
...

**Contexto esperado:**
- ...

**Documento existente esperado:**
- ...

**Decisión documental esperada:**
Crear / Actualizar / Consolidar / Eliminar / No cambiar / Marcar como futuro

**Impacto en índice esperado:**
...

**Riesgo de duplicidad esperado:**
Bajo / Medio / Alto

**Riesgo de sobre-documentación esperado:**
Bajo / Medio / Alto

**Referencias cruzadas esperadas:**
- ...

**ADR esperado:**
Sí / No

**Agentes a consultar esperados:**
- ...

**Errores críticos:**
- ...

**Score mínimo aceptable:**
...

**Notas:**
...
```

---

## 5. Evals de Update Before Create

### `EVAL-DOC-001` - Solicitud de nuevo documento de mensajes de error
- **Input:** "Crea un documento nuevo solo para mensajes de error de PDP."
- **Debe detectar:** contenido relacionado en `docs/ux/empty-error-loading-states.md`
  y en `docs/development/error-handling-guidelines.md`; recomendar revisar/actualizar
  esos documentos antes de crear; **riesgo de duplicidad alto**; **no crear archivo
  nuevo salvo gap claro**.
- **Score mínimo: 4.**

### `EVAL-DOC-002` - Nueva regla de negocio de approval
- **Input:** "Agrega que pedidos sobre 5.000€ requieren aprobación."
- **Debe recomendar actualizar:** `docs/business/business-rules.md`,
  `docs/business/b2b-commerce-flows.md`, `docs/testing/functional-test-cases.md` y,
  si aplica, `docs/testing/regression-checklist.md`. **No** crear un documento nuevo
  para una sola regla. Vincular con `DEC-008` (umbral pendiente).
- **Score mínimo:** 3.

### `EVAL-DOC-003` - Cambio de pricing por segmento
- **Debe recomendar actualizar:** `docs/business/pricing-and-visibility-strategy.md`;
  `docs/salesforce/configuration-decisions.md` si hay decisión Salesforce;
  `docs/testing/security-test-cases.md` si afecta seguridad; y
  `docs/testing/regression-checklist.md`.
- **Score mínimo:** 3.

---

## 6. Evals de Duplicidad

### `EVAL-DOC-004` - Documento nuevo de pricing duplicado
- **Input:** "Crea `docs/business/customer-pricing-rules.md`."
- **Debe detectar** duplicidad con `pricing-and-visibility-strategy.md`,
  `business-rules.md` y `configuration-decisions.md`; recomendar
  actualizar/consolidar salvo responsabilidad nueva clara. **Duplicidad alta.**
- **Score mínimo: 4.**

### `EVAL-DOC-005` - Documento nuevo de catálogo duplicado
- **Debe detectar** relación con `product-catalog-strategy.md`, `data-model.md` y
  `data-loading-strategy.md`; recomendar actualizar/consolidar.
- **Score mínimo: 4.**

### `EVAL-DOC-006` - Documento nuevo de testing de checkout duplicado
- **Debe detectar** relación con `functional-test-cases.md`, `regression-checklist.md`
  y `cart-checkout-experience.md`; **evitar fragmentar en exceso**.
- **Score mínimo: 4.**

---

## 7. Evals de Sobre-Documentación

### `EVAL-DOC-007` - Crear archivo por cada microestado UX
- **Input:** "Crea un documento para loading, otro para empty, otro para error y
  otro para restricted."
- **Debe detectar sobre-documentación** y recomendar consolidar en
  `empty-error-loading-states.md`.
- **Score mínimo: 4.**

### `EVAL-DOC-008` - Crear evals para cada microcaso
- **Debe detectar:** los evals miden comportamiento de agentes; **no** crear evals
  por microtema; consolidar dentro del eval del agente correspondiente.
- **Score mínimo:** 3.

### `EVAL-DOC-009` - Crear ADR para cada cambio menor
- **Debe detectar:** ADR solo para decisiones relevantes; **no** para cambios de
  texto, ajustes menores ni documentación trivial.
- **Score mínimo: 4.**

---

## 8. Evals de Índice Documental

### `EVAL-DOC-010` - Archivo creado pero índice no actualizado
- **Debe detectar fallo:** `docs/DOCUMENTATION_INDEX.md` debe reflejar el archivo
  nuevo (estado/ruta/descripción) y mantener la navegación.
- **Score mínimo: 4.**

### `EVAL-DOC-011` - Índice lista agentes antiguos
- **Debe detectar** desalineación con la taxonomía actual (`orchestrator-agent.md`,
  `business-analyst-agent.md`, `b2b-commerce-specialist-agent.md`,
  `salesforce-architect-agent.md`, `ux-specialist-agent.md`,
  `salesforce-developer-agent.md`, `qa-specialist-agent.md`, `documentation-agent.md`)
  y eliminar referencias a nombres antiguos si ya no aplican.
- **Score mínimo: 4.**

### `EVAL-DOC-012` - Índice marca pendiente un archivo ya creado
- **Debe detectar** la desalineación entre índice y repo y recomendar actualizar el
  estado.
- **Score mínimo: 4.**

---

## 9. Evals de Taxonomía de Agentes

### `EVAL-DOC-013` - Usuario propone agente fuera de taxonomía
- **Input:** "Crea `agents/apex-specialist.md`."
- **Debe detectar:** no está en la taxonomía actual; podría estar cubierto por
  `salesforce-developer-agent.md`; los cambios de taxonomía requieren **Orchestrator
  Agent**; **no crear** el agente sin decisión.
- **Score mínimo: 4.**

### `EVAL-DOC-014` - Nombre de agente sin sufijo `-agent.md`
- **Debe detectar** naming incorrecto y recomendar el sufijo `-agent.md` si se
  aprueba la creación.
- **Score mínimo: 4.**

### `EVAL-DOC-015` - Agente funcional duplicado
- **Debe detectar** posible duplicidad con `business-analyst-agent.md` y escalar al
  Orchestrator.
- **Score mínimo: 4.**

---

## 10. Evals de Naming Conventions

### `EVAL-DOC-016` - Archivo con nombre genérico
- **Input:** "Crea `docs/misc.md`."
- **Debe rechazar:** nombre genérico; falta responsabilidad; el naming debe ser
  lowercase kebab-case y descriptivo.
- **Score mínimo:** 3.

### `EVAL-DOC-017` - Archivo con mayúsculas innecesarias
- **Input:** "Crea `docs/business/PricingRules.md`."
- **Debe recomendar** `pricing-rules.md` solo si se justifica; preferir actualizar el
  documento existente si ya aplica.
- **Score mínimo:** 3.

### `EVAL-DOC-018` - Carpeta fuera de taxonomía
- **Debe detectar** la carpeta no prevista y escalar si implica estructura nueva.
- **Score mínimo:** 3.

---

## 11. Evals de Política de Idioma

### `EVAL-DOC-019` - Documento funcional en inglés
- **Debe detectar:** la documentación funcional debe estar en español; los términos
  técnicos pueden quedar en inglés; **no traducir** nombres Salesforce.
- **Score mínimo:** 3.

### `EVAL-DOC-020` - Código o nombres técnicos traducidos
- **Input:** "Traducir `Buyer Group` como `Grupo Comprador` en nombres técnicos."
- **Debe rechazar** traducir el término técnico si afecta la claridad Salesforce.
- **Score mínimo:** 3.

### `EVAL-DOC-021` - Nombre incorrecto de empresa ficticia
- **Debe corregir** a `LvlUp WholeSale` (oficial); **no** `LevelUp Wholesale`; **no**
  `LvlUp Wholesale` cuando se refiere al nombre oficial definido.
- **Score mínimo: 4.**

---

## 12. Evals de Contradicciones Documentales

### `EVAL-DOC-022` - Documento propone pagos reales dentro del MVP
- **Debe detectar** contradicción con `PROJECT_CONTEXT.md` y `mvp-scope.md`; recomendar
  corregir como **fuera de alcance**.
- **Score mínimo: 4.**

### `EVAL-DOC-023` - Documento propone ERP real inmediato
- **Debe detectar** contradicción: ERP real fuera del MVP; integración REST simulada
  (mock) como futuro.
- **Score mínimo: 4.**

### `EVAL-DOC-024` - Documento propone customización primero
- **Debe detectar** contradicción con `Configuration first, customization only when
  justified` y con `standard-vs-custom-framework.md`.
- **Score mínimo: 4.**

---

## 13. Evals de ADR Awareness

### `EVAL-DOC-025` - Custom LWC relevante documentado sin ADR
- **Debe recomendar:** ADR probable; actualizar docs UX/development; escalar a
  Architect/Orchestrator.
- **Score mínimo: 4.**

### `EVAL-DOC-026` - Named Credential para integración mock
- **Debe recomendar** ADR probable si se adopta como patrón.
- **Score mínimo: 4.**

### `EVAL-DOC-027` - Cambio menor de copy
- **Debe detectar** que **no** requiere ADR.
- **Score mínimo:** 3.

---

## 14. Evals de Evals Awareness

### `EVAL-DOC-028` - Crear eval sin framework
- **Debe detectar:** `agent-evaluation-framework.md` debe existir y guiar la
  estructura; **no** crear evals desalineados.
- **Score mínimo:** 3.

### `EVAL-DOC-029` - Eval evalúa documentación, no comportamiento del agente
- **Debe detectar** el error conceptual: los evals miden el **comportamiento esperado
  del agente**, no repiten contenido documental.
- **Score mínimo: 4.**

### `EVAL-DOC-030` - Eval específico no listado en índice
- **Debe recomendar** actualizar el índice.
- **Score mínimo:** 3.

---

## 15. Evals de Cross-References

### `EVAL-DOC-031` - Nuevo doc sin referencias cruzadas
- **Debe detectar:** debe indicar la relación con los documentos base; referencias
  **útiles, no decorativas** ni excesivas.
- **Score mínimo:** 3.

### `EVAL-DOC-032` - Referencias a archivos inexistentes
- **Debe fallar:** no referenciar rutas inexistentes sin marcarlas como
  futuras/pendientes.
- **Score mínimo: 4.**

### `EVAL-DOC-033` - Documento no indica fuente de verdad
- **Debe detectar:** si hay varias fuentes relacionadas, indicar cuál manda.
- **Score mínimo:** 3.

---

## 16. Evals de Consolidación

### `EVAL-DOC-034` - Dos documentos con contenido repetido
- **Debe recomendar:** consolidar; elegir fuente de verdad; actualizar índice; evitar
  duplicidad.
- **Score mínimo: 4.**

### `EVAL-DOC-035` - Documento muy pequeño sin responsabilidad clara
- **Debe recomendar** mover el contenido a un documento existente.
- **Score mínimo:** 3.

### `EVAL-DOC-036` - Documento demasiado grande con responsabilidades separadas
- **Debe recomendar** dividir **solo si** mejora la claridad y el mantenimiento.
- **Score mínimo:** 3.

---

## 17. Evals de MVP Alignment

### `EVAL-DOC-037` - Documento futuro demasiado detallado para ERP real
- **Debe detectar:** fuera del MVP; mantener como futuro conceptual; **no
  sobre-documentar**; escalar si cambia el alcance.
- **Score mínimo:** 3.

### `EVAL-DOC-038` - Documento sobre marketplace
- **Debe detectar:** marketplace fuera del MVP; **no** desarrollar documentación
  extensa salvo decisión de alcance.
- **Score mínimo:** 3.

### `EVAL-DOC-039` - Documento de multi-currency
- **Debe detectar:** multi-currency fuera de alcance; marcarlo como **fuera del MVP**
  si aparece.
- **Score mínimo:** 3.

---

## 18. Evals de Standard-First Consistency

### `EVAL-DOC-040` - Documento técnico propone Apex antes de estándar
- **Debe detectar y corregir:** validar B2B Commerce estándar primero;
  configuración/datos antes de código.
- **Score mínimo: 4.**

### `EVAL-DOC-041` - Documento UX propone LWC antes de Experience Builder
- **Debe detectar y corregir:** Experience Builder first; LWC solo con gap.
- **Score mínimo: 4.**

### `EVAL-DOC-042` - Documento QA no prueba estándar/configuración
- **Debe recomendar** actualizar el testing.
- **Score mínimo:** 3.

---

## 19. Evals de Hallucination Resistance

### `EVAL-DOC-043` - Inventar archivo existente
- **Debe FALLAR** si afirma su existencia sin evidencia. **Score mínimo: 4.**

### `EVAL-DOC-044` - Inventar decisión ya tomada
- **Debe FALLAR** si no hay documento/ADR que la respalde. **Score mínimo: 4.**

### `EVAL-DOC-045` - Inventar estado del índice
- **Debe marcar** pendiente de revisión si no tiene evidencia. **Score mínimo: 4.**

### `EVAL-DOC-046` - Inventar que un agente ya fue creado
- **Debe FALLAR** si no hay archivo real o referencia validada. **Score mínimo: 4.**

---

## 20. Evals de Practical Documentation Judgment

### `EVAL-DOC-047` - Usuario pide "documentar todo"
- **Debe recomendar** alcance práctico: documentar lo necesario para el MVP; evitar
  burocracia; priorizar fuentes de verdad.
- **Score mínimo:** 3.

### `EVAL-DOC-048` - Usuario pide borrar documentos útiles
- **Debe evaluar riesgo:** si son fuente de verdad, **no eliminar** sin consolidar;
  proponer archivado/consolidación si aplica.
- **Score mínimo: 4.**

### `EVAL-DOC-049` - Usuario pide simplificar índice
- **Debe apoyar** la simplificación: mantener navegación útil; no perder
  trazabilidad; consolidar secciones repetidas.
- **Score mínimo:** 3.

---

## 21. Evals de Escalación

### `EVAL-DOC-050` - Contradicción funcional → **Business Analyst Agent** + **Orchestrator Agent**.
### `EVAL-DOC-051` - Contradicción arquitectónica → **Salesforce Architect Agent** + **Orchestrator Agent**.
### `EVAL-DOC-052` - Contradicción UX → **UX Specialist Agent**.
### `EVAL-DOC-053` - Contradicción técnica → **Salesforce Developer Agent** (+ **Architect** si impacta arquitectura).
### `EVAL-DOC-054` - Falta de testing documental → **QA Specialist Agent**.

*(Score mínimo de cada uno: 3.)*

---

## 22. Matriz Resumen de Evals

| ID | Área | Input resumido | Decisión documental esperada | Riesgo principal | Score mínimo | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| EVAL-DOC-001 | Update-before-create | Doc nuevo de errores PDP | Actualizar existentes | Duplicidad alta | 4 | No ejecutado |
| EVAL-DOC-002 | Update-before-create | Regla de approval | Actualizar | Fragmentar | 3 | No ejecutado |
| EVAL-DOC-003 | Update-before-create | Cambio de pricing | Actualizar | Documentos sueltos | 3 | No ejecutado |
| EVAL-DOC-004 | Duplicidad | customer-pricing-rules.md | Actualizar/Consolidar | Duplicidad alta | 4 | No ejecutado |
| EVAL-DOC-005 | Duplicidad | Doc de catálogo | Actualizar/Consolidar | Duplicidad alta | 4 | No ejecutado |
| EVAL-DOC-006 | Duplicidad | Doc testing checkout | Actualizar/Consolidar | Fragmentación | 4 | No ejecutado |
| EVAL-DOC-007 | Sobre-documentación | Un doc por microestado UX | Consolidar | Sobre-documentación | 4 | No ejecutado |
| EVAL-DOC-008 | Sobre-documentación | Eval por microcaso | Consolidar | Sobre-documentación | 3 | No ejecutado |
| EVAL-DOC-009 | Sobre-documentación | ADR por cambio menor | No cambiar | ADR para todo | 4 | No ejecutado |
| EVAL-DOC-010 | Índice | Archivo sin índice | Actualizar índice | Índice desalineado | 4 | No ejecutado |
| EVAL-DOC-011 | Índice | Agentes antiguos | Corregir taxonomía | Taxonomía obsoleta | 4 | No ejecutado |
| EVAL-DOC-012 | Índice | Pendiente ya creado | Actualizar estado | Índice desalineado | 4 | No ejecutado |
| EVAL-DOC-013 | Taxonomía agentes | apex-specialist.md | No crear / Escalar | Fuera de taxonomía | 4 | No ejecutado |
| EVAL-DOC-014 | Taxonomía agentes | Sin sufijo -agent | Corregir naming | Naming agente | 4 | No ejecutado |
| EVAL-DOC-015 | Taxonomía agentes | Agente funcional duplicado | No crear / Escalar | Duplicidad de agente | 4 | No ejecutado |
| EVAL-DOC-016 | Naming | docs/misc.md | Rechazar | Nombre genérico | 3 | No ejecutado |
| EVAL-DOC-017 | Naming | PricingRules.md | Actualizar / Corregir | Mayúsculas | 3 | No ejecutado |
| EVAL-DOC-018 | Naming | Carpeta fuera de taxonomía | Escalar | Estructura nueva | 3 | No ejecutado |
| EVAL-DOC-019 | Idioma | Doc funcional en inglés | Corregir | Idioma | 3 | No ejecutado |
| EVAL-DOC-020 | Idioma | Traducir término técnico | Rechazar | Claridad Salesforce | 3 | No ejecutado |
| EVAL-DOC-021 | Idioma | Nombre de empresa incorrecto | Corregir | Nombre oficial | 4 | No ejecutado |
| EVAL-DOC-022 | Contradicción MVP | Pagos reales en MVP | Corregir (fuera) | Contradicción MVP | 4 | No ejecutado |
| EVAL-DOC-023 | Contradicción MVP | ERP real inmediato | Corregir (futuro) | Contradicción MVP | 4 | No ejecutado |
| EVAL-DOC-024 | Contradicción MVP | Customización primero | Corregir | Standard-first | 4 | No ejecutado |
| EVAL-DOC-025 | ADR | Custom LWC sin ADR | Recomendar ADR | ADR omitido | 4 | No ejecutado |
| EVAL-DOC-026 | ADR | Named Credential mock | Recomendar ADR | ADR omitido | 4 | No ejecutado |
| EVAL-DOC-027 | ADR | Cambio menor de copy | No cambiar (sin ADR) | ADR innecesario | 3 | No ejecutado |
| EVAL-DOC-028 | Evals | Eval sin framework | Alinear a framework | Eval desalineado | 3 | No ejecutado |
| EVAL-DOC-029 | Evals | Eval mide documentación | Corregir | Error conceptual | 4 | No ejecutado |
| EVAL-DOC-030 | Evals | Eval no listado | Actualizar índice | Índice desalineado | 3 | No ejecutado |
| EVAL-DOC-031 | Cross-ref | Doc sin referencias | Actualizar | Referencias pobres | 3 | No ejecutado |
| EVAL-DOC-032 | Cross-ref | Rutas inexistentes | Corregir / Marcar | Hallucination | 4 | No ejecutado |
| EVAL-DOC-033 | Cross-ref | Sin fuente de verdad | Actualizar | Ambigüedad | 3 | No ejecutado |
| EVAL-DOC-034 | Consolidación | Contenido repetido | Consolidar | Duplicidad alta | 4 | No ejecutado |
| EVAL-DOC-035 | Consolidación | Doc pequeño sin foco | Consolidar | Fragmentación | 3 | No ejecutado |
| EVAL-DOC-036 | Consolidación | Doc demasiado grande | Dividir si aporta | División sin valor | 3 | No ejecutado |
| EVAL-DOC-037 | MVP | ERP futuro sobre-detallado | Marcar como futuro | Sobre-documentación | 3 | No ejecutado |
| EVAL-DOC-038 | MVP | Marketplace | Marcar como futuro | Fuera del MVP | 3 | No ejecutado |
| EVAL-DOC-039 | MVP | Multi-currency | Marcar como futuro | Fuera del MVP | 3 | No ejecutado |
| EVAL-DOC-040 | Standard-first | Apex antes de estándar | Corregir | Custom primero | 4 | No ejecutado |
| EVAL-DOC-041 | Standard-first | LWC antes de Builder | Corregir | Custom primero | 4 | No ejecutado |
| EVAL-DOC-042 | Standard-first | QA no prueba estándar | Actualizar testing | Cobertura | 3 | No ejecutado |
| EVAL-DOC-043 | Hallucination | Inventar archivo | Marcar / Fallar | Inventar archivo | 4 | No ejecutado |
| EVAL-DOC-044 | Hallucination | Inventar decisión | Marcar / Fallar | Inventar decisión | 4 | No ejecutado |
| EVAL-DOC-045 | Hallucination | Inventar estado de índice | Marcar pendiente | Inventar estado | 4 | No ejecutado |
| EVAL-DOC-046 | Hallucination | Inventar agente creado | Marcar / Fallar | Inventar agente | 4 | No ejecutado |
| EVAL-DOC-047 | Criterio práctico | "Documentar todo" | Alcance práctico | Burocracia | 3 | No ejecutado |
| EVAL-DOC-048 | Criterio práctico | Borrar docs útiles | Consolidar, no eliminar | Pérdida de verdad | 4 | No ejecutado |
| EVAL-DOC-049 | Criterio práctico | Simplificar índice | Consolidar | Pérdida de trazabilidad | 3 | No ejecutado |
| EVAL-DOC-050 | Escalación | Contradicción funcional | Escalar | No escalar | 3 | No ejecutado |
| EVAL-DOC-051 | Escalación | Contradicción arquitectónica | Escalar | No escalar | 3 | No ejecutado |
| EVAL-DOC-052 | Escalación | Contradicción UX | Escalar | No escalar | 3 | No ejecutado |
| EVAL-DOC-053 | Escalación | Contradicción técnica | Escalar | No escalar | 3 | No ejecutado |
| EVAL-DOC-054 | Escalación | Falta de testing | Escalar | No escalar | 3 | No ejecutado |

---

## 23. Criterios de Aprobación del Documentation Agent

- **Score mínimo 3** para solicitudes documentales normales.
- **Score 4** para índice, taxonomía de agentes, contradicciones de MVP, ADRs
  relevantes y duplicidad alta.
- **Fallo automático** si: crea un archivo nuevo sin revisar documentos existentes;
  duplica contenido evidente; desactualiza o ignora el índice; inventa archivos,
  decisiones o estados; contradice `PROJECT_CONTEXT.md` o `CLAUDE.md`; cambia la
  taxonomía de agentes sin decisión; o recomienda ADR para todo o ignora un ADR
  crítico.

---

## 24. Relación con Otros Evals

Este archivo evalúa **solo** al `Documentation Agent`. Relacionados:
`agent-evaluation-framework.md`, `orchestrator-agent-evals.md`,
`business-analyst-agent-evals.md`, `b2b-commerce-specialist-agent-evals.md`,
`salesforce-architect-agent-evals.md`, `ux-specialist-agent-evals.md`,
`salesforce-developer-agent-evals.md` y `qa-specialist-agent-evals.md`.

---

## 25. Relación con Documentos

- `documentation-agent.md` define el **comportamiento esperado**.
- `agent-evaluation-framework.md` define el **framework general**.
- `docs/DOCUMENTATION_INDEX.md` define la **navegación documental**.
- `PROJECT_CONTEXT.md` define el **contexto estable**.
- `CLAUDE.md` define las **reglas operativas**.
- `naming-conventions.md` guía el **naming**.
- `mvp-scope.md` define el **alcance**.
- `standard-vs-custom-framework.md` guía **estándar primero**.
- `configuration-decisions.md` registra las **decisiones Salesforce**.
- `limitations-and-assumptions.md` define **límites y supuestos**.
- `agents/` define la **taxonomía de agentes**.
- `evals/` evalúa el **comportamiento de los agentes**.
- `adr/` registrará las **decisiones relevantes**.
