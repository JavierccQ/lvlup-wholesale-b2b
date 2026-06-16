# Salesforce Architect Agent Evals - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define **casos de evaluación** para medir la calidad del
`Salesforce Architect Agent` en el proyecto `LvlUp-Wholesale-B2B`.

Sirve para validar si el agente: evalúa impacto arquitectónico; protege el
standard-first; juzga estándar vs custom; identifica riesgos de seguridad; protege
buyer account isolation; evalúa pricing/visibility y cart/checkout; evalúa
integración futura y modelo de datos; evalúa deployment, logging y error handling;
recomienda testing; recomienda **ADR cuando corresponde y lo evita en lo menor**;
evita sobre-ingeniería; y evita decisiones técnicas prematuras.

Estos evals son **manuales/conceptuales**; no implementan una herramienta
automática. La prosa va en español; los términos técnicos en inglés.

---

## 2. Criterios Específicos de Evaluación

| Criterio | Qué evalúa | Score alto | Score bajo |
| --- | --- | --- | --- |
| Architecture impact analysis | Impacto del cambio | Evalúa trade-offs | Lo ignora |
| Standard vs custom judgment | Estándar antes que custom | Frena custom prematuro | Permite el salto |
| Security awareness | Seguridad | Prioriza y escala | Ignora |
| Buyer account isolation | Aislamiento por cuenta | Lo protege | Lo rompe |
| Pricing/visibility risk analysis | Riesgo comercial | Detecta exposición | Lo ignora |
| Cart/checkout risk analysis | Riesgo crítico | Revalidación/estado | Lo ignora |
| Data architecture awareness | Datos/modelo | data≠metadata, sin hardcoded IDs | Confunde data/metadata |
| Integration architecture awareness | Integración futura | Mock/Named Credential | ERP real prematuro |
| Flow/LWC/Apex decision quality | Decisión técnica | Justificada | Custom por comodidad |
| Error handling awareness | Errores | Mensaje seguro | Expone detalle |
| Logging judgment | Logging | Persistente solo con ADR | Logging por defecto |
| Deployment readiness | Despliegue | Metadata/data, rollback | Ignora datos/rollback |
| Testing awareness | Pruebas | Recomienda testing | Omite |
| ADR awareness | ADR proporcional | ADR cuando aplica | ADR para todo/ninguno |
| Anti-overengineering | Proporcionalidad | Solución simple | Enterprise innecesario |
| Escalation quality | Escala bien | Agente correcto | Decide en solitario |
| Hallucination resistance | No inventa | Pendiente de validación | Inventa |

---

## 3. Escala de Scoring

Usa la escala de `evals/agent-evaluation-framework.md` (`0`–`4`).

| Score | Significado para el Salesforce Architect Agent | Acción recomendada |
| --- | --- | --- |
| 0 | Decisión peligrosa o inventada | Rechazar y rehacer |
| 1 | Análisis parcial; omite riesgos | Re-trabajo |
| 2 | Decisión básica con gaps | Completar |
| 3 | Decisión sólida con trade-offs | Aceptar con ajustes |
| 4 | Decisión completa, segura, con ADR/testing/escalación | Aceptar |

---

## 4. Plantilla de Caso de Evaluación

```markdown
## EVAL-ARCH-XXX - [Nombre del caso]

**Objetivo:**
**Input del usuario:**
**Contexto esperado:**
- ...
**Decisión arquitectónica esperada:**
**Análisis standard vs custom esperado:**
**Riesgos esperados:**
- ...
**Impacto en seguridad esperado:**
**Impacto en buyer account isolation esperado:**
**Impacto en pricing / visibility esperado:**
**Impacto en cart / checkout esperado:**
**Agentes a consultar esperados:**
- ...
**Testing esperado:**
- ...
**ADR esperado:** Sí / No
**Errores críticos:**
- ...
**Score mínimo aceptable:**
**Notas:**
```

---

## 5. Evals de Standard vs Custom

### `EVAL-ARCH-001` - Custom Apex para approval por importe
- **Input:** "Queremos una clase Apex para marcar pedidos grandes como pendientes."
- **Debe:** validar regla/umbral (`DEC-008`); validar estándar/configuración/Flow;
  Apex solo si gap real; impacto en checkout; confirmed vs pending; testing crítico;
  **ADR probable** si se adopta Apex central.
- **Score mínimo: 4.**

### `EVAL-ARCH-002` - LWC custom para PLP por estética
- **Input:** "Quiero reemplazar la PLP estándar por un LWC más bonito."
- **Debe:** Experience Builder/componentes estándar primero; LWC por estética no se
  justifica; UX Specialist revisa; riesgo de duplicar el estándar; testing
  mobile/visibility si se insistiera; **no ADR** si se rechaza.
- **Score mínimo: 4.**

### `EVAL-ARCH-003` - Flow para reglas complejas de checkout
- **Input:** "Un Flow debería decidir todas las validaciones de checkout."
- **Debe:** checkout crítico; riesgo de Flow complejo; separar reglas; validar
  estándar/configuración; posible Apex si transaccionalidad/control técnico; **ADR**
  si lógica central.
- **Score mínimo:** 3.

---

## 6. Evals de Seguridad

### `EVAL-ARCH-004` - Buyer ve order de otra cuenta
- **Seguridad crítica.** **Debe:** buyer account isolation rota; order access;
  riesgo Critical; **no resolver solo con UI**; security testing + regression
  obligatorios; escalar a QA y B2B Commerce Specialist; ADR si cambio
  arquitectónico.
- **Score mínimo: 4.**

### `EVAL-ARCH-005` - Producto restringido por URL directa
- **Debe:** direct URL access; product visibility; control server-side/estándar;
  safe error; cart/checkout revalidation; QA security testing.
- **Score mínimo: 4.**

### `EVAL-ARCH-006` - Error técnico visible al buyer
- **Debe:** error handling; no stack trace; no endpoints; no objetos internos;
  mensajes seguros; UX y QA; Developer Agent si hay código.
- **Score mínimo:** 3.

---

## 7. Evals de Buyer Account Isolation

### `EVAL-ARCH-007` - Cart compartido entre buyers
- **Debe:** riesgo crítico; buyer account isolation; cart ownership; session/user
  context; testing con múltiples buyer users; **no resolver solo con front**.
- **Score mínimo: 4.**

### `EVAL-ARCH-008` - Pricing de otro segmento visible
- **Debe:** riesgo comercial alto; Buyer Group; Price Books; visibility;
  consistencia PLP/PDP/cart/checkout; regression.
- **Score mínimo: 4.**

### `EVAL-ARCH-009` - Reorder de pedido ajeno
- **Debe:** order access; reorder security; buyer account validation; cart
  revalidation; security testing.
- **Score mínimo: 4.**

---

## 8. Evals de Pricing y Visibility

### `EVAL-ARCH-010` - Custom logic para pricing
- **Input:** "Creemos lógica Apex para calcular precios personalizados."
- **Debe:** validar Price Books/estándar primero; riesgo de inconsistencia
  PLP/PDP/cart/checkout; riesgo de seguridad comercial; integración futura fuera del
  MVP salvo decisión; **ADR** si se adopta custom pricing.
- **Score mínimo: 4.**

### `EVAL-ARCH-011` - Producto restringido ocultado solo con CSS
- **Debe FALLAR la propuesta:** la seguridad no depende de UI/CSS; requiere control
  de visibility real; testing de direct URL/cart/checkout; escalación.
- **Score mínimo: 4.**

### `EVAL-ARCH-012` - Reorder no revalida pricing actual
- **Debe:** pricing stale risk; reorder revalida reglas actuales; cart/checkout
  confirma estado final; QA regression.
- **Score mínimo:** 3.

---

## 9. Evals de Cart y Checkout

### `EVAL-ARCH-013` - Checkout confirma con crédito bloqueado
- **Crítico.** **Debe:** credit validation; confirmed vs pending; cart/checkout
  revalidation; **no confirmar si validación crítica falla**; integración real fuera
  del MVP; ADR si lógica central o mock; testing crítico.
- **Score mínimo: 4.**

### `EVAL-ARCH-014` - Timeout de validación de stock
- **Debe:** no confirmar si la validación crítica queda incierta; error handling;
  retry policy si aplica; logging seguro; **ADR** si se define retry/fallback;
  integration testing.
- **Score mínimo:** 3.

### `EVAL-ARCH-015` - Producto inválido permanece en checkout
- **Debe:** cart/checkout revalidation; visibility; pricing; stock; UX safe message;
  regression.
- **Score mínimo:** 3.

---

## 10. Evals de Integración Futura

### `EVAL-ARCH-016` - Conectar ERP real dentro del MVP
- **Fuera del MVP.** **Debe:** ERP real excluido; mock REST futuro; cambio de
  alcance si se insiste; ADR si se modifica el MVP; **no proponer implementación
  real**.
- **Score mínimo: 4.**

### `EVAL-ARCH-017` - Adoptar Postman Mock Server para stock
- **Debe:** integración simulada futura; contrato REST conceptual; Named Credential
  si hay callout; error handling; QA integration testing; **ADR probable**.
- **Score mínimo:** 3.

### `EVAL-ARCH-018` - Named Credential para servicio externo
- **Debe:** seguridad de secrets/endpoints; deployment; environment configuration;
  testing con mocks; **ADR probable**; **no hardcodear endpoint**.
- **Score mínimo:** 3.

---

## 11. Evals de Data Architecture

### `EVAL-ARCH-019` - Hardcoded IDs para Buyer Groups
- **Debe rechazar:** no hardcoded IDs; data loading strategy; external identifiers
  si aplica; deployment risk; reproducibilidad.
- **Score mínimo:** 3.

### `EVAL-ARCH-020` - Confundir Commerce data con metadata
- **Debe:** no todo es metadata deployable; separar configuración/metadata/data;
  validación org; data loading.
- **Score mínimo: 4.**

### `EVAL-ARCH-021` - Objeto custom para stock sin validar estándar/mock
- **Debe:** scope MVP; integración futura; evitar objeto custom prematuro; **ADR**
  si se crea objeto relevante.
- **Score mínimo:** 3.

---

## 12. Evals de Flow, LWC y Apex

### `EVAL-ARCH-022` - Flow gigante para reglas de negocio
- **Debe:** baja mantenibilidad; riesgo de error handling; separar lógica; posible
  Apex si la complejidad lo justifica; **ADR** si central.
- **Score mínimo:** 3.

### `EVAL-ARCH-023` - LWC para ocultar producto restringido
- **Debe FALLAR:** la seguridad no depende de UI; la visibility se resuelve en
  estándar/configuración/server-side; testing de seguridad.
- **Score mínimo: 4.**

### `EVAL-ARCH-024` - Apex sin tests ni mocks
- **Debe:** testing técnico obligatorio; mock para callout si aplica; sin
  dependencia de org data; code review; deployment readiness.
- **Score mínimo:** 3.

---

## 13. Evals de Error Handling y Logging

### `EVAL-ARCH-025` - Logs persistentes de checkout
- **Debe:** logging persistente no es default; puede requerir objeto custom; riesgo
  de datos sensibles; **ADR** si se adopta; testing y retención conceptual.
- **Score mínimo:** 3.

### `EVAL-ARCH-026` - Mostrar `Exception.getMessage()` al buyer
- **Debe rechazar:** mensaje técnico inseguro; safe error; UX involvement; QA error
  testing.
- **Score mínimo: 4.**

### `EVAL-ARCH-027` - Correlation ID para integración mock
- **Debe:** útil si hay trazabilidad real; no sobre-ingeniería si no aporta valor;
  **ADR** si se adopta como estándar de logging/integración.
- **Score mínimo:** 3.

---

## 14. Evals de Deployment y Operabilidad

### `EVAL-ARCH-028` - Deploy sin considerar datos Commerce
- **Debe:** metadata vs data; data loading; Buyer Groups; Price Books; Product
  Catalog; post-deployment validation.
- **Score mínimo:** 3.

### `EVAL-ARCH-029` - Secret en código
- **Debe FALLAR automáticamente:** secrets no en repo; Named Credential; environment
  configuration; security.
- **Score mínimo: 4.**

### `EVAL-ARCH-030` - Sin rollback conceptual
- **Debe:** deployment readiness incompleto; rollback conceptual; testing/regression;
  documentation update.
- **Score mínimo:** 3.

---

## 15. Evals de ADR Awareness

### `EVAL-ARCH-031` - Custom LWC relevante para reorder
- **ADR probable.** **Debe:** UX; security; pricing/visibility; cart result;
  testing.
- **Score mínimo:** 3.

### `EVAL-ARCH-032` - Cambio menor de texto en empty state
- **Debe:** **no requiere ADR**; actualizar UX docs si aplica.
- **Score mínimo:** 3.

### `EVAL-ARCH-033` - Integración REST mock para crédito
- **ADR probable.** **Debe:** integration architecture; Named Credential; error
  handling; checkout impact; testing.
- **Score mínimo:** 3.

---

## 16. Evals de Anti-Overengineering

### `EVAL-ARCH-034` - Microservicios para el MVP
- **Debe rechazar la sobre-ingeniería:** Developer Org; MVP práctico; ERP real fuera
  del MVP; simulación futura suficiente.
- **Score mínimo: 4.**

### `EVAL-ARCH-035` - Framework de logging complejo
- **Debe:** no justificado; logging simple/seguro primero; **ADR** solo si
  persistente.
- **Score mínimo:** 3.

### `EVAL-ARCH-036` - Diseñar OMS avanzado
- **Debe:** advanced OMS fuera del MVP; scope creep; decisión explícita si se
  insiste.
- **Score mínimo:** 4.

---

## 17. Evals de Hallucination Resistance

### `EVAL-ARCH-037` - Afirmar capacidad no validada
- **Debe marcar** "pendiente de validación en org".
- **Score mínimo: 4.**

### `EVAL-ARCH-038` - Inventar objeto/campo custom existente
- **Debe FALLAR** si lo trata como existente sin evidencia.
- **Score mínimo: 4.**

### `EVAL-ARCH-039` - Inventar que un ADR ya existe
- **Debe FALLAR** si no hay archivo o referencia real.
- **Score mínimo: 4.**

---

## 18. Matriz Resumen de Evals

| ID | Área | Input resumido | Decisión esperada | Riesgo principal | Score mínimo | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| EVAL-ARCH-001 | Standard vs custom | Apex para approval | Validar estándar; ADR si Apex | Apex prematuro | 4 | No ejecutado |
| EVAL-ARCH-002 | Standard vs custom | LWC PLP por estética | Rechazar; Builder first | LWC por estética | 4 | No ejecutado |
| EVAL-ARCH-003 | Standard vs custom | Flow para todo el checkout | Separar; estándar/Apex | Flow complejo | 3 | No ejecutado |
| EVAL-ARCH-004 | Seguridad | Order de otra cuenta | Aislamiento; testing | Account isolation | 4 | No ejecutado |
| EVAL-ARCH-005 | Seguridad | URL directa restringida | Control server-side | Direct URL access | 4 | No ejecutado |
| EVAL-ARCH-006 | Seguridad | Error técnico visible | Safe error | Data exposure | 3 | No ejecutado |
| EVAL-ARCH-007 | Isolation | Cart compartido | Cart ownership | Account isolation | 4 | No ejecutado |
| EVAL-ARCH-008 | Isolation | Pricing de otro segmento | Buyer Group/visibility | Pricing isolation | 4 | No ejecutado |
| EVAL-ARCH-009 | Isolation | Reorder ajeno | Order/buyer validation | Account isolation | 4 | No ejecutado |
| EVAL-ARCH-010 | Pricing | Apex pricing | Price Books primero; ADR | Inconsistencia | 4 | No ejecutado |
| EVAL-ARCH-011 | Pricing | Ocultar con CSS | Rechazar; visibility real | Seguridad UI-only | 4 | No ejecutado |
| EVAL-ARCH-012 | Pricing | Reorder pricing stale | Revalidar actual | Precio obsoleto | 3 | No ejecutado |
| EVAL-ARCH-013 | Checkout | Confirma con crédito bloqueado | No confirmar; ADR | Checkout crítico | 4 | No ejecutado |
| EVAL-ARCH-014 | Checkout | Timeout de stock | No confirmar; retry/ADR | Validación incierta | 3 | No ejecutado |
| EVAL-ARCH-015 | Checkout | Producto inválido en checkout | Revalidación | Confirmar inválido | 3 | No ejecutado |
| EVAL-ARCH-016 | Integración | ERP real en MVP | Fuera del MVP; ADR scope | Integración prematura | 4 | No ejecutado |
| EVAL-ARCH-017 | Integración | Postman Mock stock | Mock futuro; ADR | Adoptar sin ADR | 3 | No ejecutado |
| EVAL-ARCH-018 | Integración | Named Credential | Seguridad de callout; ADR | Hardcoded endpoint | 3 | No ejecutado |
| EVAL-ARCH-019 | Data | Hardcoded IDs | Rechazar; data loading | IDs hardcodeados | 3 | No ejecutado |
| EVAL-ARCH-020 | Data | data como metadata | Separar; validar org | data≠metadata | 4 | No ejecutado |
| EVAL-ARCH-021 | Data | Objeto custom stock | Evitar prematuro; ADR | Custom prematuro | 3 | No ejecutado |
| EVAL-ARCH-022 | Flow/LWC/Apex | Flow gigante | Separar; posible Apex | Mantenibilidad | 3 | No ejecutado |
| EVAL-ARCH-023 | Flow/LWC/Apex | LWC oculta restringido | Rechazar; server-side | Seguridad UI-only | 4 | No ejecutado |
| EVAL-ARCH-024 | Flow/LWC/Apex | Apex sin tests/mocks | Testing obligatorio | Sin cobertura | 3 | No ejecutado |
| EVAL-ARCH-025 | Logging | Logs persistentes checkout | No default; ADR | Datos sensibles | 3 | No ejecutado |
| EVAL-ARCH-026 | Error handling | getMessage() al buyer | Rechazar; safe error | Data exposure | 4 | No ejecutado |
| EVAL-ARCH-027 | Logging | Correlation ID mock | Solo si aporta; ADR | Sobre-ingeniería | 3 | No ejecutado |
| EVAL-ARCH-028 | Deployment | Deploy sin datos | Metadata vs data | Storefront incompleto | 3 | No ejecutado |
| EVAL-ARCH-029 | Deployment | Secret en código | Falla automática | Secret exposure | 4 | No ejecutado |
| EVAL-ARCH-030 | Deployment | Sin rollback | Rollback conceptual | Sin reversa | 3 | No ejecutado |
| EVAL-ARCH-031 | ADR | LWC reorder | ADR probable | Custom relevante | 3 | No ejecutado |
| EVAL-ARCH-032 | ADR | Texto empty state | No requiere ADR | ADR innecesario | 3 | No ejecutado |
| EVAL-ARCH-033 | ADR | REST mock crédito | ADR probable | Integración | 3 | No ejecutado |
| EVAL-ARCH-034 | Anti-OE | Microservicios MVP | Rechazar | Over-engineering | 4 | No ejecutado |
| EVAL-ARCH-035 | Anti-OE | Framework logging | Simple primero | Over-engineering | 3 | No ejecutado |
| EVAL-ARCH-036 | Anti-OE | OMS avanzado | Fuera del MVP | Scope creep | 4 | No ejecutado |
| EVAL-ARCH-037 | Hallucination | Capacidad no validada | Pendiente de validación | Inventar | 4 | No ejecutado |
| EVAL-ARCH-038 | Hallucination | Objeto custom "existe" | Falla | Inventar | 4 | No ejecutado |
| EVAL-ARCH-039 | Hallucination | ADR "ya existe" | Falla | Inventar | 4 | No ejecutado |

---

## 19. Criterios de Aprobación del Salesforce Architect Agent

- **Score mínimo 3** para decisiones normales.
- **Score 4** para seguridad, checkout, pricing/visibility, integración, deployment
  y ADRs.
- **Fallo automático** si: propone customización sin validar estándar; ignora buyer
  account isolation; acepta seguridad solo en UI; propone secret hardcodeado; ignora
  testing en cambios críticos; inventa validación en org; o recomienda arquitectura
  fuera del MVP sin marcar el scope change.

---

## 20. Relación con Otros Evals

Este archivo evalúa **solo** al `Salesforce Architect Agent`. Relacionados:
`agent-evaluation-framework.md`, `orchestrator-agent-evals.md`,
`business-analyst-agent-evals.md`, `b2b-commerce-specialist-agent-evals.md`, y los
futuros evals de UX, Developer, QA y Documentation Agent.

---

## 21. Relación con Documentos

- `salesforce-architect-agent.md` define el **comportamiento esperado**.
- `agent-evaluation-framework.md` define el **framework general**.
- `standard-vs-custom-framework.md` guía **estándar vs custom**.
- `solution-architecture.md` define la **arquitectura**.
- `security-architecture.md` define la **seguridad**.
- `integration-architecture.md` define la **integración futura**.
- `limitations-and-assumptions.md` define los **límites**.
- `data-model.md` define el **modelo de datos**.
- `security-model.md` define la **seguridad Salesforce**.
- `deployment-guidelines.md` guía el **deployment**.
- `error-handling-guidelines.md` guía los **errores**.
- `logging-guidelines.md` guía el **logging**.
- `test-strategy.md`, `security-test-cases.md`, `integration-test-cases.md` y
  `regression-checklist.md` guían el **testing**.
- `adr/` registrará las **decisiones arquitectónicas relevantes**.
