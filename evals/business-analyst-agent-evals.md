# Business Analyst Agent Evals - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define **casos de evaluación** para medir la calidad del
`Business Analyst Agent` en el proyecto `LvlUp-Wholesale-B2B`.

Sirve para validar si el agente: entiende solicitudes funcionales; aclara
requerimientos ambiguos; identifica actores y buyer personas; identifica flujos B2B
afectados; define reglas de negocio y criterios de aceptación; cubre escenarios
positivos y negativos; protege el MVP; detecta gaps; recomienda validación estándar
y testing; escala cuando corresponde; y **evita proponer solución técnica
prematura**.

Estos evals son **manuales/conceptuales**; no implementan una herramienta
automática. La prosa va en español; los términos técnicos en inglés.

---

## 2. Criterios Específicos de Evaluación

| Criterio | Qué evalúa | Score alto | Score bajo |
| --- | --- | --- | --- |
| Requirement clarification | Aclara lo ambiguo | Convierte en requerimiento claro | Acepta ambigüedad |
| Actor identification | Identifica al actor | Actor correcto | Sin actor |
| Buyer persona identification | Identifica segmento | Persona correcta | Genérico |
| B2B flow identification | Mapea el flujo | Flujo correcto | Flujo erróneo/omitido |
| Business rule definition | Define reglas | Regla con condición/resultado | Regla vaga |
| Acceptance criteria quality | Criterios verificables | Dado/cuando/entonces | Ambiguos |
| Negative scenario coverage | Escenarios negativos | Incluye negativos | Solo happy path |
| MVP alignment | Respeta alcance | Marca fuera del MVP | Mete fuera de fase |
| Gap detection | Detecta gaps | Gap real identificado | Lo ignora |
| Standard validation awareness | Pide validar estándar | Escala a B2B Commerce | Asume capacidad |
| Testing awareness | Recomienda pruebas | Define testing | Omite testing |
| Escalation awareness | Escala bien | Agente correcto | Decide en solitario |
| Anti-technical-premature-solution | No salta a técnico | Mantiene foco funcional | Propone Apex/LWC |
| Documentation awareness | Documentos a actualizar | Indica cuáles | Ignora documentación |

---

## 3. Escala de Scoring

Usa la escala de `evals/agent-evaluation-framework.md` (`0`–`4`).

| Score | Significado para el Business Analyst Agent | Acción recomendada |
| --- | --- | --- |
| 0 | No entiende o inventa reglas | Rechazar y rehacer |
| 1 | Requerimiento parcial; sin criterios | Re-trabajo |
| 2 | Requerimiento básico con gaps | Completar |
| 3 | Requerimiento claro y verificable | Aceptar con ajustes |
| 4 | Requerimiento completo, con negativos, MVP y escalación | Aceptar |

---

## 4. Plantilla de Caso de Evaluación

```markdown
## EVAL-BA-XXX - [Nombre del caso]

**Objetivo:**
**Input del usuario:**
**Contexto esperado:**
- ...
**Actor esperado:**
**Buyer persona / segmento esperado:**
**Flujo B2B esperado:**
**Reglas de negocio esperadas:**
- ...
**Acceptance criteria esperados:**
- ...
**Escenarios negativos esperados:**
- ...
**MVP alignment esperado:** Dentro del MVP / Fuera del MVP / Pendiente de decisión
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

## 5. Evals de Requerimientos Ambiguos

### `EVAL-BA-001` - Solicitud ambigua de aprobación
- **Input:** "Quiero que los pedidos grandes pidan aprobación."
- **Debe detectar:** "pedido grande" sin umbral (`DEC-008`); actor buyer; flujo
  approval por importe; confirmed vs pending; necesidad de regla; testing funcional;
  validación estándar; posible escalación a B2B Commerce y Architect.
- **Score mínimo:** 3.

### `EVAL-BA-002` - Solicitud ambigua de crédito
- **Input:** "No quiero que clientes con mal crédito compren."
- **Debe detectar:** qué es "mal crédito"; estados valid/blocked/exceeded/
  unavailable; impacto en checkout; mensaje funcional; fuente del dato pendiente;
  ERP real fuera del MVP; validación estándar/futura.
- **Score mínimo: 4.**

### `EVAL-BA-003` - Solicitud ambigua de stock
- **Input:** "Si no hay stock, que no puedan comprar."
- **Debe detectar:** stock funcional dentro del MVP; definir
  suficiente/insuficiente/no disponible; impacto en PDP/cart/checkout; mensaje UX;
  integración real fuera del MVP; escenarios negativos; testing.
- **Score mínimo:** 3.

---

## 6. Evals de MVP Alignment

### `EVAL-BA-004` - Solicitud de pagos reales
- **Input:** "Quiero conectar pagos reales en checkout."
- **Clasificación:** fuera del MVP. **Debe detectar:** pagos reales excluidos;
  riesgo de scope creep; decisión explícita si se insiste; no proponer técnica.
- **Score mínimo: 4.**

### `EVAL-BA-005` - Solicitud de marketplace
- **Input:** "Quiero que otros proveedores vendan dentro del storefront."
- **Clasificación:** fuera del MVP. **Debe detectar:** impacto grande en
  arquitectura/catálogo/seguridad/pricing/operaciones; revisión de alcance; posible
  ADR si cambia el proyecto.
- **Score mínimo: 4.**

### `EVAL-BA-006` - Solicitud de reorder
- **Input:** "Los compradores deben repetir pedidos anteriores."
- **Clasificación:** dentro del MVP. **Debe detectar:** flujo reorder; revalidación
  de pricing/visibility/stock; order history; escenarios negativos; testing
  funcional y seguridad.
- **Score mínimo:** 3.

---

## 7. Evals de Buyer Personas y Segmentos

### `EVAL-BA-007` - Producto solo para cliente enterprise
- **Input:** "Este bundle solo debe estar disponible para clientes enterprise."
- **Debe detectar:** persona Enterprise Gaming Procurement; catálogo restringido;
  visibility/entitlements; pricing segmentado (si aplica); search/PLP/PDP/cart/
  checkout/reorder; seguridad; testing de visibility.
- **Score mínimo:** 3.

### `EVAL-BA-008` - Precios distintos por tipo de cliente
- **Input:** "Los revendedores deben tener un precio distinto al de tiendas pequeñas."
- **Debe detectar:** Tech Reseller Iberia vs Gaming Store Madrid; Buyer Group;
  pricing personalizado; consistencia PLP/PDP/cart/checkout; **no exponer pricing de
  otro segmento**; validación estándar.
- **Score mínimo:** 4.

### `EVAL-BA-009` - Cliente sin catálogo asignado
- **Input:** "Un buyer entra y no ve productos."
- **Debe detectar:** posible problema de buyer access/Buyer Group/catálogo/
  visibility/data; **no asumir bug técnico**; escalar a B2B Commerce Specialist;
  testing con buyer user.
- **Score mínimo:** 3.

---

## 8. Evals de Flujos B2B

### `EVAL-BA-010` - Compra estándar
- **Input:** "Un buyer debe poder comprar productos visibles desde catálogo hasta checkout."
- **Debe identificar:** compra estándar; login/PLP/PDP/cart/checkout; pricing
  visible; producto autorizado; checkout básico; testing end-to-end.
- **Score mínimo:** 3.

### `EVAL-BA-011` - Stock insuficiente
- **Input:** "El buyer intenta comprar más unidades de las disponibles."
- **Debe identificar:** flujo stock insuficiente; cantidad vs stock; mensaje
  funcional; bloqueo/condicionamiento; testing negativo.
- **Score mínimo:** 3.

### `EVAL-BA-012` - Quote request
- **Input:** "Quiero que el cliente pueda pedir cotización."
- **Debe identificar:** quote request dentro del MVP; diferencia con order
  confirmado; datos mínimos; estado pendiente; validación estándar/configuración;
  posible UX/custom futuro si el estándar no alcanza.
- **Score mínimo:** 3.

---

## 9. Evals de Acceptance Criteria

### `EVAL-BA-013` - Acceptance criteria incompletos
- **Input:** "Que funcione bien el checkout."
- **Debe rechazar la ambigüedad** y definir criterios verificables (buyer
  autenticado → cart válido → inicia checkout → ve resumen → confirma/pendiente
  según reglas → errores funcionales claros).
- **Score mínimo:** 3.

### `EVAL-BA-014` - Acceptance criteria sin escenario negativo
- **Input:** "Producto restringido no debe verse en PLP."
- **Debe agregar negativos:** no aparece en search; URL directa a PDP segura; no se
  agrega al cart; checkout lo bloquea; reorder lo revalida.
- **Score mínimo:** 3.

### `EVAL-BA-015` - Acceptance criteria sin mobile
- **Input:** "Checkout debe mostrar aprobación pendiente."
- **Debe detectar** que afecta al storefront y **agregar validación mobile**.
- **Score mínimo:** 3.

---

## 10. Evals de Gap Analysis

### `EVAL-BA-016` - Gap funcional potencial en approval
- **Debe distinguir:** regla funcional vs capacidad estándar pendiente vs gap real
  no validado; escalar a B2B Commerce Specialist; posible Architect si impacta
  checkout.
- **Score mínimo:** 3.

### `EVAL-BA-017` - Gap de UX confundido con requerimiento funcional
- **Input:** "No me gusta cómo se ve el mensaje de stock."
- **Debe clasificar** como posible UX issue; consultar UX Specialist y
  `empty-error-loading-states.md`; **no proponer LWC directamente**.
- **Score mínimo:** 3.

### `EVAL-BA-018` - Gap de datos confundido con desarrollo
- **Input:** "Los productos no salen, habrá que desarrollar algo."
- **Debe detectar** posible problema de datos/configuración y **no proponer
  desarrollo**.
- **Score mínimo:** 3.

---

## 11. Evals de Seguridad Funcional

### `EVAL-BA-019` - Buyer ve pedido de otra cuenta
- **Clasificación:** seguridad crítica. **Escalar a:** Orchestrator, Salesforce
  Architect, QA. **Debe detectar:** buyer account isolation; order access; testing
  de seguridad; **no tratarlo como ajuste menor**.
- **Score mínimo: 4.**

### `EVAL-BA-020` - Buyer ve precio de otro segmento
- **Debe detectar:** riesgo comercial; pricing/visibility; Buyer Group; testing de
  seguridad y regresión; escalación.
- **Score mínimo: 4.**

### `EVAL-BA-021` - Producto restringido accesible por URL directa
- **Debe detectar:** security issue; restricted catalog; direct URL; PDP;
  cart/checkout revalidation; testing.
- **Score mínimo:** 4.

---

## 12. Evals de Escalación

### `EVAL-BA-022` - Requiere validación estándar
- **Escalar a** `B2B Commerce Specialist Agent`. Ej.: "¿el estándar permite
  reorder?".
- **Score mínimo:** 3.

### `EVAL-BA-023` - Afecta arquitectura
- **Escalar a** `Salesforce Architect Agent`. Ej.: "bloquear checkout consultando
  crédito externo".
- **Score mínimo:** 3.

### `EVAL-BA-024` - Afecta UX
- **Escalar a** `UX Specialist Agent`. Ej.: "cambiar cómo se muestran estados
  pendientes y errores en checkout".
- **Score mínimo:** 3.

### `EVAL-BA-025` - Requiere QA
- **Escalar a** `QA Specialist Agent`. Ej.: "validar que un buyer no vea productos
  restringidos".
- **Score mínimo:** 3.

---

## 13. Evals de Anti-Solución Técnica Prematura

### `EVAL-BA-026` - Usuario pide Apex directamente
- **Input:** "Haz una clase Apex para calcular si un pedido requiere aprobación."
- **Debe** definir regla, umbral y estado; validar estándar/configuración/Flow;
  **no proponer Apex todavía**.
- **Score mínimo:** 3.

### `EVAL-BA-027` - Usuario pide LWC directamente
- **Input:** "Haz un LWC para mostrar crédito bloqueado."
- **Debe** definir necesidad funcional y mensaje; validar estándar/Experience
  Builder; escalar a UX/B2B Commerce/Architect si aplica.
- **Score mínimo:** 3.

### `EVAL-BA-028` - Usuario pide integración real
- **Input:** "Conectemos el ERP real para validar stock."
- **Debe** indicar ERP real fuera del MVP; stock funcional/mock futuro; revisión de
  alcance si se insiste.
- **Score mínimo:** 4.

---

## 14. Evals de Documentación

### `EVAL-BA-029` - Requerimiento cambia regla de negocio
- **Debe recomendar actualizar:** `business-rules`, `b2b-commerce-flows`,
  `functional-test-cases`.
- **Score mínimo:** 3.

### `EVAL-BA-030` - Requerimiento cambia alcance MVP
- **Debe recomendar actualizar:** `mvp-scope`; **posible ADR** si se aprueba.
- **Score mínimo:** 3.

### `EVAL-BA-031` - Requerimiento cambia pricing/visibility
- **Debe recomendar actualizar:** `pricing-and-visibility-strategy`,
  `functional-test-cases`, `security-test-cases` (si aplica).
- **Score mínimo:** 3.

---

## 15. Evals de Hallucination Resistance

### `EVAL-BA-032` - Asumir una regla no definida
- **Input:** "El umbral de aprobación ya sabes cuál es."
- **Debe** indicar que no hay valor definido en contexto y marcar **pendiente**.
- **Score mínimo: 4.**

### `EVAL-BA-033` - Afirmar capacidad estándar no validada
- **Input:** "Salesforce seguro ya hace esto, ¿verdad?"
- **Debe** marcar **pendiente de validación**.
- **Score mínimo: 4.**

### `EVAL-BA-034` - Términos no definidos
- **Input:** "Que los clientes premium tengan flujo especial."
- **Debe** pedir definición de "premium" o **declarar supuesto**.
- **Score mínimo:** 3.

---

## 16. Matriz Resumen de Evals

| ID | Área | Input resumido | Flujo esperado | Riesgo principal | Score mínimo | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| EVAL-BA-001 | Ambiguo | Aprobación "pedidos grandes" | Approval | Umbral sin definir | 3 | No ejecutado |
| EVAL-BA-002 | Ambiguo | "Mal crédito" | Credit validation | Dato/ERP | 4 | No ejecutado |
| EVAL-BA-003 | Ambiguo | Sin stock no compran | Stock insuficiente | Integración prematura | 3 | No ejecutado |
| EVAL-BA-004 | MVP | Pagos reales | Checkout | Scope creep | 4 | No ejecutado |
| EVAL-BA-005 | MVP | Marketplace | — | Cambio de modelo | 4 | No ejecutado |
| EVAL-BA-006 | MVP | Reorder | Reorder | Revalidación | 3 | No ejecutado |
| EVAL-BA-007 | Personas | Bundle solo enterprise | Restricted catalog | Visibility | 3 | No ejecutado |
| EVAL-BA-008 | Personas | Precio por tipo de cliente | Custom pricing | Pricing isolation | 4 | No ejecutado |
| EVAL-BA-009 | Personas | Buyer sin catálogo | Visibility/data | Asumir bug | 3 | No ejecutado |
| EVAL-BA-010 | Flujos | Compra estándar | Compra estándar | Cobertura E2E | 3 | No ejecutado |
| EVAL-BA-011 | Flujos | Más unidades que stock | Stock insuficiente | Escenario negativo | 3 | No ejecutado |
| EVAL-BA-012 | Flujos | Quote request | Quote request | Confundir con pedido | 3 | No ejecutado |
| EVAL-BA-013 | Acceptance | "Que funcione el checkout" | Checkout | Ambigüedad | 3 | No ejecutado |
| EVAL-BA-014 | Acceptance | Restringido no en PLP | Visibility | Faltan negativos | 3 | No ejecutado |
| EVAL-BA-015 | Acceptance | Pendiente en checkout | Checkout | Falta mobile | 3 | No ejecutado |
| EVAL-BA-016 | Gap | Gap en approval | Approval | Confundir gap | 3 | No ejecutado |
| EVAL-BA-017 | Gap | Mensaje de stock feo | UX | Confundir con funcional | 3 | No ejecutado |
| EVAL-BA-018 | Gap | "Habrá que desarrollar" | Data/config | Desarrollo innecesario | 3 | No ejecutado |
| EVAL-BA-019 | Seguridad | Pedido de otra cuenta | Order access | Account isolation | 4 | No ejecutado |
| EVAL-BA-020 | Seguridad | Precio de otro segmento | Pricing | Pricing isolation | 4 | No ejecutado |
| EVAL-BA-021 | Seguridad | Restringido por URL | Direct URL access | Visibility | 4 | No ejecutado |
| EVAL-BA-022 | Escalación | ¿Estándar permite reorder? | — | Asumir estándar | 3 | No ejecutado |
| EVAL-BA-023 | Escalación | Crédito externo en checkout | — | Arquitectura | 3 | No ejecutado |
| EVAL-BA-024 | Escalación | Estados/errores checkout | — | UX | 3 | No ejecutado |
| EVAL-BA-025 | Escalación | Validar restringidos | — | QA | 3 | No ejecutado |
| EVAL-BA-026 | Anti-técnico | Apex para approval | Approval | Apex prematuro | 3 | No ejecutado |
| EVAL-BA-027 | Anti-técnico | LWC para crédito | Credit | LWC prematuro | 3 | No ejecutado |
| EVAL-BA-028 | Anti-técnico | ERP real para stock | Stock | Fuera del MVP | 4 | No ejecutado |
| EVAL-BA-029 | Documentación | Cambia regla de negocio | — | Trazabilidad | 3 | No ejecutado |
| EVAL-BA-030 | Documentación | Cambia alcance MVP | — | Scope/ADR | 3 | No ejecutado |
| EVAL-BA-031 | Documentación | Cambia pricing/visibility | — | Trazabilidad | 3 | No ejecutado |
| EVAL-BA-032 | Hallucination | Umbral "ya sabes" | Approval | Inventar regla | 4 | No ejecutado |
| EVAL-BA-033 | Hallucination | "Salesforce ya lo hace" | — | Inventar capacidad | 4 | No ejecutado |
| EVAL-BA-034 | Hallucination | "Clientes premium" | — | Término sin definir | 3 | No ejecutado |

---

## 17. Criterios de Aprobación del Business Analyst Agent

- **Score mínimo 3** para requerimientos normales.
- **Score 4** para seguridad, checkout, pricing/visibility o cambios de MVP.
- **Fallo automático** si: propone Apex/LWC/Flow/integración sin análisis funcional;
  ignora el MVP; ignora buyer account isolation en casos sensibles; inventa reglas
  no definidas; o no define criterios de aceptación verificables en requerimientos
  críticos.

---

## 18. Relación con Otros Evals

Este archivo evalúa **solo** al `Business Analyst Agent`. Relacionados:
`agent-evaluation-framework.md`, `orchestrator-agent-evals.md`, y los futuros evals
de B2B Commerce, Architect, UX, Developer, QA y Documentation Agent.

---

## 19. Relación con Documentos

- `business-analyst-agent.md` define el **comportamiento esperado**.
- `agent-evaluation-framework.md` define el **framework general**.
- `mvp-scope.md` define el **alcance**.
- `buyer-personas.md` define los **actores**.
- `business-rules.md` define las **reglas**.
- `b2b-commerce-flows.md` define los **flujos**.
- `pricing-and-visibility-strategy.md` define **pricing/visibility**.
- `functional-test-cases.md` define las **pruebas funcionales**.
- `standard-vs-custom-framework.md` guía la **escalación a validación estándar**.
- `agents/` define la **colaboración entre agentes**.
