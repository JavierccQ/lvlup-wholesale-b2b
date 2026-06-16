# Architecture Decision Records - LvlUp WholeSale

## 1. Propósito de la Carpeta `adr/`

La carpeta `adr/` contiene los **Architecture Decision Records** del proyecto
`LvlUp-Wholesale-B2B`. Cada ADR documenta una **decisión relevante**: su contexto,
las alternativas evaluadas, la decisión tomada y sus consecuencias.

Los ADRs ayudan a:

- Mantener **trazabilidad** de las decisiones.
- **Evitar repetir** discusiones ya cerradas.
- Justificar las decisiones **standard vs custom**.
- Registrar decisiones con impacto en **arquitectura, seguridad, checkout, pricing,
  visibility, integración, deployment o alcance**.
- Ayudar a los **agentes IA** a mantener consistencia.
- **Evitar decisiones implícitas** no documentadas.

La prosa va en español; los términos técnicos en inglés. Esta carpeta sigue el
principio rector del proyecto: `Configuration first, customization only when
justified`.

---

## 2. Qué es un ADR en este Proyecto

Un ADR es un registro breve y accionable de una decisión arquitectónica relevante.
Debe responder:

- ¿Qué decisión se tomó?
- ¿Por qué se tomó?
- ¿Qué alternativas se evaluaron?
- ¿Qué consecuencias tiene?
- ¿Qué documentos se ven afectados?
- ¿Qué agentes deberían conocer esta decisión?
- ¿Qué testing o validación requiere?

Un ADR **no es**:

- Una user story.
- Un documento funcional completo.
- Un caso de prueba.
- Una guía de desarrollo.
- Una nota suelta.
- Un duplicado de documentación existente.

---

## 3. Cuándo Crear un ADR

Crear un ADR cuando una decisión:

- Afecta la **arquitectura de solución**.
- Cambia el **alcance del MVP**.
- Decide **usar o no usar** una capacidad estándar de Salesforce B2B Commerce.
- Justifica una **customización relevante**.
- Introduce un **LWC custom** relevante.
- Introduce **Apex** para lógica central.
- Introduce **Flow** para lógica central.
- Introduce **integración REST** o **mock REST** como patrón.
- Introduce un **Named Credential**.
- Afecta el **checkout**.
- Afecta el **pricing**.
- Afecta la **visibility**.
- Afecta el **buyer account isolation**.
- Afecta la **seguridad**.
- Afecta el **deployment**.
- Define la estrategia de **metadata vs data**.
- Define **logging persistente**.
- Resuelve una **contradicción importante** entre documentos.
- Establece una decisión que será **consultada por varios agentes**.

---

## 4. Cuándo NO Crear un ADR

No crear un ADR para:

- Cambios menores de texto.
- Ajustes visuales simples.
- Correcciones pequeñas de documentación.
- Casos de prueba individuales.
- Reglas pequeñas que caben en `business-rules.md`.
- Mensajes UX que caben en `empty-error-loading-states.md`.
- Detalles técnicos que caben en `apex-guidelines.md`, `lwc-guidelines.md` o
  `flow-guidelines.md`.
- Decisiones no tomadas.
- Ideas futuras sin compromiso.
- Documentos creados por simetría.
- Microdecisiones sin impacto arquitectónico.
- Cambios que solo requieren actualizar `configuration-decisions.md`.

---

## 5. Agentes que Pueden Recomendar ADR

| Agente | Cuándo puede recomendar ADR | Ejemplo |
| --- | --- | --- |
| `orchestrator-agent.md` | Conflicto entre áreas, cambio de alcance o duda de prioridad | Una decisión que altera el alcance del MVP |
| `salesforce-architect-agent.md` | Decisión arquitectónica, custom relevante, integración, seguridad o logging persistente | Adoptar un LWC custom para el checkout |
| `b2b-commerce-specialist-agent.md` | Una capacidad estándar no cubre un requerimiento y se decide una alternativa | Gap de pricing estándar que obliga a decidir |
| `salesforce-developer-agent.md` | Una solución técnica requiere Apex/Flow para lógica central o un patrón de integración | Apex para validación de crédito |
| `ux-specialist-agent.md` | Una decisión UX requiere componente custom relevante en lugar de Experience Builder | Componente custom para reorder |
| `qa-specialist-agent.md` | Un riesgo o defecto crítico obliga a una decisión estructural | Estrategia de regresión de checkout ante un riesgo recurrente |
| `documentation-agent.md` | Una decisión relevante está dispersa o hay contradicción documental | Contradicción entre docs que exige decidir la fuente de verdad |
| `business-analyst-agent.md` | Una regla de negocio relevante cambia el alcance o exige decisión | Umbral de approval que afecta el checkout (`DEC-008`) |

Aclaraciones:

- El **`Salesforce Architect Agent`** debe **validar** las decisiones arquitectónicas.
- El **`Documentation Agent`** debe validar si el ADR es **necesario** o si basta con
  **actualizar documentación existente** (evitar sobre-documentación).
- El **`Orchestrator Agent`** debe intervenir si hay **conflicto**, **cambio de
  alcance** o **duda de prioridad**.

---

## 6. Naming Convention

```text
adr/0001-project-scope-and-mvp-boundaries.md
adr/0002-standard-first-b2b-commerce-approach.md
adr/0003-commerce-data-vs-metadata-strategy.md
```

Reglas:

- Numeración **incremental de cuatro dígitos**.
- **lowercase**.
- **kebab-case**.
- Nombres **descriptivos**.
- **No** reutilizar números.
- **No** renumerar ADRs existentes.
- Si una decisión queda obsoleta, **crear un nuevo ADR** que la reemplace.
- **No** usar nombres genéricos como `decision.md`, `architecture.md`, `notes.md` o
  `adr-new.md`.

---

## 7. Estado de un ADR

| Estado | Significado | Cuándo usarlo |
| --- | --- | --- |
| `Proposed` | Decisión planteada, aún no aceptada | Mientras se evalúa antes de adoptarla |
| `Accepted` | Decisión vigente | Cuando la decisión se asume y guía el proyecto |
| `Superseded` | Reemplazada por un ADR posterior | Cuando otra decisión la sustituye (referenciar el nuevo ADR) |
| `Rejected` | Evaluada y descartada | Cuando aporta trazabilidad dejar registro del descarte |
| `Deprecated` | Ya no aplica y no se reemplaza | Cuando el contexto deja la decisión sin efecto |

Aclaraciones:

- Los ADRs iniciales pueden comenzar como `Accepted` si documentan decisiones **ya
  asumidas**.
- Si una decisión cambia, **no se borra** el ADR anterior: se marca como `Superseded`
  y se **referencia el nuevo ADR**.
- Si una idea se evalúa y se descarta, puede quedar como `Rejected` cuando la decisión
  aporta trazabilidad.

---

## 8. Estructura Obligatoria de Cada ADR

```markdown
# ADR-000X - [Título de la decisión]

## Estado

Accepted / Proposed / Superseded / Rejected / Deprecated

## Fecha

YYYY-MM-DD

## Contexto

Explicar el problema, necesidad o decisión pendiente.

## Decisión

Explicar la decisión tomada de forma clara.

## Alternativas Consideradas

- Alternativa 1
- Alternativa 2
- Alternativa 3

## Consecuencias

### Positivas

- ...

### Negativas / Trade-offs

- ...

## Impacto en el Proyecto

- MVP:
- Salesforce B2B Commerce:
- Seguridad:
- Pricing / Visibility:
- Checkout:
- Datos / Metadata:
- Integración:
- Testing:
- Documentación:

## Agentes Relevantes

- ...

## Documentos Relacionados

- ...

## Validaciones Pendientes

- ...

## ADRs Relacionados

- ...
```

No todos los campos tendrán contenido extenso, pero **deben estar presentes** para
mantener la consistencia entre ADRs.

---

## 9. ADRs Iniciales Recomendados

Primera tanda razonable:

- `adr/README.md`
- `adr/0001-project-scope-and-mvp-boundaries.md`
- `adr/0002-standard-first-b2b-commerce-approach.md`
- `adr/0003-commerce-data-vs-metadata-strategy.md`
- `adr/0004-pricing-and-visibility-strategy.md`

Recomendados posteriores:

- `adr/0005-checkout-approval-credit-and-stock-strategy.md`
- `adr/0006-future-rest-mock-integration-strategy.md`

> No se deben crear más ADRs hasta que exista una **decisión real** que lo justifique.

---

## 10. Relación con Documentación Existente

Relación con:

- `PROJECT_CONTEXT.md`
- `CLAUDE.md`
- `docs/DOCUMENTATION_INDEX.md`
- `docs/architecture/standard-vs-custom-framework.md`
- `docs/architecture/solution-architecture.md`
- `docs/architecture/security-architecture.md`
- `docs/architecture/integration-architecture.md`
- `docs/architecture/limitations-and-assumptions.md`
- `docs/salesforce/configuration-decisions.md`
- `docs/salesforce/data-loading-strategy.md`
- `docs/development/deployment-guidelines.md`
- `docs/testing/regression-checklist.md`

Aclaraciones:

- `PROJECT_CONTEXT.md` define el **contexto estable** del proyecto.
- Los ADRs registran las **decisiones relevantes**.
- `configuration-decisions.md` registra **decisiones Salesforce operativas de menor
  nivel** (identificadas como `CFG-*`) y marca, con su columna *¿Requiere ADR?*,
  cuáles deben **escalar** a un ADR.
- Los ADRs **no deben duplicar** todo el contenido de los documentos base.
- Si un ADR toma una decisión, los documentos relacionados deben **actualizarse** si
  quedan desalineados.

---

## 11. Relación con Evals

Los evals deben verificar si los agentes **recomiendan ADR correctamente**.
Relacionados:

- `evals/agent-evaluation-framework.md`
- `evals/orchestrator-agent-evals.md`
- `evals/salesforce-architect-agent-evals.md`
- `evals/documentation-agent-evals.md`

Los evals deben **penalizar**:

- Crear ADRs innecesarios.
- No recomendar ADRs en decisiones críticas.
- Inventar ADRs inexistentes.
- Contradecir ADRs aceptados.

---

## 12. Relación con Agentes

Los agentes deben **consultar los ADRs** cuando:

- Una decisión ya fue tomada.
- Hay duda entre **estándar y custom**.
- Hay impacto en **seguridad**.
- Hay impacto en **checkout**.
- Hay impacto en **pricing/visibility**.
- Hay impacto en **integración**.
- Hay **cambio de alcance**.
- Hay **contradicción documental**.

> Los agentes **no deben ignorar** los ADRs aceptados.

---

## 13. Checklist Antes de Crear un ADR

- [ ] ¿La decisión tiene impacto arquitectónico real?
- [ ] ¿Afecta el MVP?
- [ ] ¿Afecta estándar vs custom?
- [ ] ¿Afecta la seguridad?
- [ ] ¿Afecta el buyer account isolation?
- [ ] ¿Afecta el pricing/visibility?
- [ ] ¿Afecta el checkout?
- [ ] ¿Afecta la integración?
- [ ] ¿Afecta el deployment?
- [ ] ¿Afecta el logging persistente?
- [ ] ¿Varios documentos/agentes necesitan conocer esta decisión?
- [ ] ¿No basta con actualizar un documento existente?
- [ ] ¿El `Documentation Agent` validaría que no es sobre-documentación?
- [ ] ¿El `Salesforce Architect Agent` validaría que es una decisión relevante?

---

## 14. Checklist Después de Crear un ADR

- [ ] ¿Tiene número correcto?
- [ ] ¿Tiene título claro?
- [ ] ¿Tiene estado?
- [ ] ¿Tiene fecha?
- [ ] ¿Tiene contexto?
- [ ] ¿Tiene decisión clara?
- [ ] ¿Tiene alternativas?
- [ ] ¿Tiene consecuencias?
- [ ] ¿Tiene documentos relacionados?
- [ ] ¿Tiene agentes relevantes?
- [ ] ¿Tiene validaciones pendientes si aplica?
- [ ] ¿Actualiza o referencia los documentos afectados?
- [ ] ¿Se actualizó `docs/DOCUMENTATION_INDEX.md`?
- [ ] ¿No duplica documentación existente?

---

## 15. Antipatrones

- Crear ADR para cada cambio menor.
- Crear ADR por simetría.
- Crear ADR sin decisión tomada.
- Usar el ADR como user story.
- Usar el ADR como documento técnico completo.
- Duplicar documentación existente.
- No actualizar los documentos relacionados.
- No actualizar el índice.
- Renumerar ADRs existentes.
- Borrar ADRs obsoletos en vez de marcarlos como `Superseded`.
- Ignorar ADRs aceptados.
- Inventar ADRs no creados.

---

## 16. Fuente de Verdad

- Si hay conflicto entre un ADR `Accepted` y un documento antiguo, el **ADR es la
  fuente de verdad** para esa decisión.
- El documento afectado debe **actualizarse** para alinearse con el ADR.
- Si un ADR queda obsoleto, debe crearse un **nuevo ADR** y marcar el anterior como
  `Superseded`.
- El **índice documental** debe reflejar el estado real.

---

## 17. Mantenimiento

- Revisar los ADRs al **cerrar fases importantes**.
- Revisar los ADRs cuando se **cambia el MVP**.
- Revisar los ADRs cuando se **introduce customización**.
- Revisar los ADRs cuando se **añade integración**.
- Revisar los ADRs **antes de decisiones de deployment relevantes**.
- Mantenerlos **breves, claros y accionables**.
