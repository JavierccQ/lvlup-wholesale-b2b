# B2B Commerce Specialist Agent Evals - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define **casos de evaluación** para medir la calidad del
`B2B Commerce Specialist Agent` en el proyecto `LvlUp-Wholesale-B2B`.

Sirve para validar si el agente: evalúa capacidades estándar de B2B Commerce; revisa
configuración antes de customizar; revisa datos Commerce antes de proponer código;
identifica dependencias entre buyer account, Buyer Groups, catálogo, pricing y
visibility; detecta gaps reales; marca pendientes de validación en org; **evita
Apex/LWC/Flow/integración prematura**; identifica riesgos de seguridad; recomienda
testing/regresión; y escala correctamente.

Estos evals son **manuales/conceptuales**; no implementan una herramienta
automática. La prosa va en español; los términos técnicos en inglés.

---

## 2. Criterios Específicos de Evaluación

| Criterio | Qué evalúa | Score alto | Score bajo |
| --- | --- | --- | --- |
| Standard capability validation | Valida el estándar | Confirma o marca pendiente | Asume capacidad |
| Configuration-first behavior | Configura antes de codificar | Resuelve por config | Salta a código |
| Commerce data awareness | Considera datos | Detecta data issue | Lo ignora |
| Org validation awareness | Pendiente de validación | Marca pendiente | Afirma sin evidencia |
| Product catalog understanding | Catálogo/categorías | Asociaciones correctas | Confunde catálogo |
| Pricing understanding | Pricing por segmento | Consistencia/aislamiento | Pricing erróneo |
| Visibility / entitlements understanding | Visibilidad | Restringe correctamente | Expone restringidos |
| Buyer Groups understanding | Segmentación | Acceso correcto | Herencia indebida |
| Storefront / Experience Builder awareness | Builder first | Config visual | LWC directo |
| PLP/PDP awareness | Listado/detalle | Información correcta | Omite estados |
| Cart/checkout awareness | Carrito/checkout | Revalidación | Ignora checkout |
| Orders/reorder awareness | Historial/reorder | Revalida actual | Datos obsoletos |
| Security awareness | Seguridad | Aislamiento por cuenta | Fuga |
| Gap analysis quality | Gaps reales | Gap bien definido | Gap inventado/omitido |
| Anti-premature-customization | No salta a custom | Estándar primero | Custom prematuro |
| Testing awareness | Pruebas | Recomienda testing | Omite testing |
| Escalation awareness | Escala bien | Agente correcto | Decide en solitario |
| Hallucination resistance | No inventa | Pendiente de validación | Inventa capacidad |

---

## 3. Escala de Scoring

Usa la escala de `evals/agent-evaluation-framework.md` (`0`–`4`).

| Score | Significado para el B2B Commerce Specialist Agent | Acción recomendada |
| --- | --- | --- |
| 0 | Inventa capacidad o salta a custom | Rechazar y rehacer |
| 1 | Validación parcial; omite datos/estándar | Re-trabajo |
| 2 | Cubre lo básico con gaps | Completar |
| 3 | Valida estándar/config/datos con criterio | Aceptar con ajustes |
| 4 | Validación completa, segura y con escalación | Aceptar |

---

## 4. Plantilla de Caso de Evaluación

```markdown
## EVAL-B2B-XXX - [Nombre del caso]

**Objetivo:**
**Input del usuario:**
**Contexto esperado:**
- ...
**Capacidad estándar esperada a revisar:**
**Configuración esperada a revisar:**
- ...
**Datos Commerce esperados:**
- ...
**Estado de validación esperado:** Validado / Pendiente de validación en org / No cubierto por estándar / Fuera del MVP
**Gap esperado:** Sí / No
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

## 5. Evals de Standard Capability Validation

### `EVAL-B2B-001` - Validar reorder estándar
- **Input:** "Necesito saber si los buyers pueden repetir pedidos anteriores."
- **Debe:** reorder dentro del MVP; validar capacidad estándar; revisar order
  history/detail; revalidación de pricing/visibility/stock; **pendiente de
  validación en org** si no hay evidencia; testing funcional y de seguridad; **no**
  proponer LWC/Apex de entrada.
- **Score mínimo:** 3.

### `EVAL-B2B-002` - Validar approval por importe
- **Input:** "Queremos que pedidos sobre cierto importe queden pendientes."
- **Debe:** flujo approval por importe; umbral pendiente (`DEC-008`); confirmed vs
  pending; validar estándar/configuración; escalar a Architect/Developer si no
  alcanza; posible ADR si afecta checkout.
- **Score mínimo: 4.**

### `EVAL-B2B-003` - Validar quote request
- **Input:** "Queremos que el buyer pueda pedir una cotización."
- **Debe:** quote request dentro del MVP; validar estándar/configuración;
  diferenciar de order confirmado; revisar UX y testing; **no inventar objeto custom
  directamente**.
- **Score mínimo:** 3.

---

## 6. Evals de Catálogo y Categorías

### `EVAL-B2B-004` - Producto no aparece en categoría
- **Input:** "Un producto de consolas no aparece en su categoría."
- **Debe** sospechar data/config: Product Catalog; category association; producto
  activo/comprable; visibility; Buyer Group; PLP; **no asumir bug de código**.
- **Score mínimo:** 3.

### `EVAL-B2B-005` - Categoría sin productos
- **Debe:** puede ser empty state esperado o data issue; validar asociaciones,
  visibility y buyer context; recomendar testing.
- **Score mínimo:** 3.

### `EVAL-B2B-006` - Nuevo bundle enterprise
- **Input:** "Vamos a agregar un bundle enterprise al catálogo."
- **Debe:** producto/categoría; visibility restringida; pricing; Buyer Group
  enterprise; testing PLP/PDP/cart/checkout; seguridad.
- **Score mínimo:** 3.

---

## 7. Evals de Pricing

### `EVAL-B2B-007` - Buyer ve precio incorrecto
- **Riesgo alto.** **Debe:** Price Book; Price Book Entry; Buyer Group/segmento;
  pricing strategy; consistencia PLP/PDP/cart/checkout; regresión; seguridad
  comercial.
- **Score mínimo: 4.**

### `EVAL-B2B-008` - Producto sin precio
- **Debe:** data/config issue; Price Book Entry faltante; mensaje funcional;
  bloqueo/no disponibilidad; testing negativo.
- **Score mínimo:** 3.

### `EVAL-B2B-009` - Pricing distinto para reseller
- **Input:** "Los resellers deben ver precio distinto."
- **Debe:** Tech Reseller Iberia; Buyer Group/segmento; Price Book strategy;
  validación estándar; **no exponer pricing de otros segmentos**; testing seguridad.
- **Score mínimo:** 4.

---

## 8. Evals de Visibility / Entitlements

### `EVAL-B2B-010` - Producto restringido aparece en PLP
- **Riesgo visibility/security.** **Debe revisar:** product visibility; Buyer Group;
  catalog access; entitlements; PLP; search; PDP; cart/checkout; regression.
- **Score mínimo: 4.**

### `EVAL-B2B-011` - Producto restringido accesible por URL directa
- **Debe:** direct URL access; PDP security; product visibility; safe error;
  cart/checkout revalidation; escalación a Architect/QA.
- **Score mínimo: 4.**

### `EVAL-B2B-012` - Reorder incluye producto ya no visible
- **Debe:** reorder revalida visibility actual; pricing actual; stock funcional;
  mensaje funcional; QA regression.
- **Score mínimo:** 3.

---

## 9. Evals de Buyer Groups y Buyer Access

### `EVAL-B2B-013` - Buyer sin Buyer Group esperado
- **Input:** "El buyer entra pero no ve catálogo ni precios."
- **Debe:** buyer account; buyer user; Buyer Group assignment; catalog access;
  pricing; visibility; gap de permiso/configuración.
- **Score mínimo:** 3.

### `EVAL-B2B-014` - Buyer hereda catálogo incorrecto
- **Debe:** riesgo de acceso indebido; Buyer Group; entitlements/visibility; testing
  de seguridad; escalación a Architect si hay riesgo.
- **Score mínimo: 4.**

### `EVAL-B2B-015` - Nuevo segmento de cliente
- **Input:** "Queremos un segmento especial para empresas grandes."
- **Debe:** buyer persona/segmento; catálogo; pricing; visibility; MVP scope;
  configuración y datos; posible actualización documental.
- **Score mínimo:** 3.

---

## 10. Evals de Storefront y Experience Builder

### `EVAL-B2B-016` - Cambiar layout de PLP
- **Debe revisar:** Experience Builder; componentes estándar; UX Specialist Agent;
  **no recomendar LWC directamente**.
- **Score mínimo:** 3.

### `EVAL-B2B-017` - Home no muestra categorías
- **Debe:** configuración Storefront; navigation/menu; category visibility; buyer
  context; Experience Builder; **no asumir desarrollo**.
- **Score mínimo:** 3.

### `EVAL-B2B-018` - Mensaje de stock en PDP
- **Debe revisar:** capacidad estándar/configuración; UX docs; si requiere LWC,
  escalar a UX/Architect/Developer; **no proponer LWC de entrada**.
- **Score mínimo:** 3.

---

## 11. Evals de Cart y Checkout

### `EVAL-B2B-019` - Producto restringido llega al cart
- **Debe:** cart revalidation; visibility; security; checkout risk; escalación a
  Architect/QA; regression.
- **Score mínimo: 4.**

### `EVAL-B2B-020` - Checkout no diferencia pedido pendiente
- **Debe:** confirmed vs pending; approval required; UX message;
  configuración/estándar; escalación si requiere lógica custom.
- **Score mínimo:** 3.

### `EVAL-B2B-021` - Checkout confirma con stock insuficiente
- **Debe:** stock validation; checkout critical risk; stock funcional del MVP;
  integración real fuera del MVP; testing crítico; escalación.
- **Score mínimo: 4.**

---

## 12. Evals de Orders y Reorder

### `EVAL-B2B-022` - Buyer no ve historial de pedidos
- **Debe:** order history estándar; buyer account access; datos de orders de
  prueba; permisos; configuración; empty state.
- **Score mínimo:** 3.

### `EVAL-B2B-023` - Buyer ve pedido de otra cuenta
- **Clasificación:** seguridad crítica. **Escalar a** Salesforce Architect, QA,
  Orchestrator.
- **Score mínimo: 4.**

### `EVAL-B2B-024` - Reorder parcial
- **Debe:** productos actuales; visibility actual; pricing actual; stock funcional;
  mensaje al buyer; testing funcional.
- **Score mínimo:** 3.

---

## 13. Evals de Data vs Code

### `EVAL-B2B-025` - Apex para productos que no aparecen
- **Input:** "Los productos no aparecen, creemos un Apex."
- **Debe rechazar** el salto a código y revisar Product Catalog, Categories,
  visibility, Buyer Group, Price Book, storefront configuration.
- **Score mínimo:** 3.

### `EVAL-B2B-026` - LWC para mostrar precios
- **Debe validar primero:** pricing estándar; Price Books; buyer context; PLP/PDP
  standard components; Experience Builder; **no LWC directo**.
- **Score mínimo:** 3.

### `EVAL-B2B-027` - Flow para asignar catálogo
- **Debe revisar primero:** configuración estándar de Buyer Groups/access; data
  loading; **no Flow sin gap**.
- **Score mínimo:** 3.

---

## 14. Evals de Org Validation Awareness

### `EVAL-B2B-028` - Capacidad no validada en org
- **Input:** "¿Seguro B2B Commerce soporta esto en mi Developer Org?"
- **Debe:** **pendiente de validación en org**; consultar `org-validation-checklist`;
  **no afirmar sin evidencia**.
- **Score mínimo: 4.**

### `EVAL-B2B-029` - Configuración Commerce no deployable
- **Debe:** **no asumir que todo es metadata**; diferenciar metadata/data/manual
  configuration; consultar deployment/data loading docs.
- **Score mínimo: 4.**

### `EVAL-B2B-030` - Storefront activo pero comportamiento no validado
- **Debe:** Site activo ≠ flujo completo validado; requiere pruebas funcionales.
- **Score mínimo:** 3.

---

## 15. Evals de Escalación

### `EVAL-B2B-031` - Gap estándar real
- **Escalar a** Salesforce Architect; Salesforce Developer (si hay técnica); QA.
- **Score mínimo:** 3.

### `EVAL-B2B-032` - Riesgo de seguridad
- **Escalar a** Salesforce Architect, QA, Orchestrator.
- **Score mínimo: 4.**

### `EVAL-B2B-033` - Gap UX
- **Escalar a** UX Specialist; Salesforce Developer solo si LWC se justifica.
- **Score mínimo:** 3.

### `EVAL-B2B-034` - Cambio de alcance
- **Escalar a** Orchestrator y Business Analyst.
- **Score mínimo:** 3.

---

## 16. Evals de Hallucination Resistance

### `EVAL-B2B-035` - Inventar capacidad estándar
- **Falla** si afirma una capacidad específica sin documentación/validación.
- **Score mínimo: 4.**

### `EVAL-B2B-036` - Inventar objeto/campo custom
- **Falla** si propone un objeto/campo custom como si ya existiera.
- **Score mínimo: 4.**

### `EVAL-B2B-037` - Inventar que la org ya está validada
- **Falla** si dice "validado" sin evidencia.
- **Score mínimo: 4.**

---

## 17. Matriz Resumen de Evals

| ID | Área | Input resumido | Capacidad/configuración esperada | Riesgo principal | Score mínimo | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| EVAL-B2B-001 | Standard | ¿Reorder posible? | Reorder estándar | Custom prematuro | 3 | No ejecutado |
| EVAL-B2B-002 | Standard | Approval por importe | Estándar/Flow | Umbral/checkout | 4 | No ejecutado |
| EVAL-B2B-003 | Standard | Quote request | Estándar/config | Objeto custom | 3 | No ejecutado |
| EVAL-B2B-004 | Catálogo | Producto sin categoría | Catalog/category | Asumir código | 3 | No ejecutado |
| EVAL-B2B-005 | Catálogo | Categoría vacía | Asociaciones/visibility | Data issue | 3 | No ejecutado |
| EVAL-B2B-006 | Catálogo | Bundle enterprise | Visibility/pricing | Restricción | 3 | No ejecutado |
| EVAL-B2B-007 | Pricing | Precio incorrecto | Price Book/Buyer Group | Pricing/seguridad | 4 | No ejecutado |
| EVAL-B2B-008 | Pricing | Producto sin precio | Price Book Entry | Data issue | 3 | No ejecutado |
| EVAL-B2B-009 | Pricing | Precio reseller | Buyer Group/Price Book | Pricing isolation | 4 | No ejecutado |
| EVAL-B2B-010 | Visibility | Restringido en PLP | Entitlements/visibility | Exposición | 4 | No ejecutado |
| EVAL-B2B-011 | Visibility | Restringido por URL | Direct URL/PDP | Exposición | 4 | No ejecutado |
| EVAL-B2B-012 | Visibility | Reorder no visible | Revalidación | Producto obsoleto | 3 | No ejecutado |
| EVAL-B2B-013 | Buyer access | Sin Buyer Group | Assignment/access | Acceso/config | 3 | No ejecutado |
| EVAL-B2B-014 | Buyer access | Catálogo incorrecto | Entitlements | Acceso indebido | 4 | No ejecutado |
| EVAL-B2B-015 | Buyer access | Nuevo segmento | Buyer Group/datos | Scope/config | 3 | No ejecutado |
| EVAL-B2B-016 | Storefront | Layout PLP | Experience Builder | LWC directo | 3 | No ejecutado |
| EVAL-B2B-017 | Storefront | Home sin categorías | Configuración/nav | Asumir desarrollo | 3 | No ejecutado |
| EVAL-B2B-018 | Storefront | Mensaje stock PDP | Estándar/config | LWC directo | 3 | No ejecutado |
| EVAL-B2B-019 | Cart/checkout | Restringido en cart | Revalidación | Visibility/seguridad | 4 | No ejecutado |
| EVAL-B2B-020 | Cart/checkout | No diferencia pendiente | Confirmed vs pending | Estado | 3 | No ejecutado |
| EVAL-B2B-021 | Cart/checkout | Confirma sin stock | Stock validation | Checkout crítico | 4 | No ejecutado |
| EVAL-B2B-022 | Orders | Sin historial | Order history | Acceso/datos | 3 | No ejecutado |
| EVAL-B2B-023 | Orders | Pedido de otra cuenta | Order access | Account isolation | 4 | No ejecutado |
| EVAL-B2B-024 | Orders | Reorder parcial | Revalidación | Datos obsoletos | 3 | No ejecutado |
| EVAL-B2B-025 | Data vs code | Apex para productos | Catalog/config | Salto a código | 3 | No ejecutado |
| EVAL-B2B-026 | Data vs code | LWC para precios | Pricing estándar | LWC prematuro | 3 | No ejecutado |
| EVAL-B2B-027 | Data vs code | Flow para catálogo | Buyer Group/config | Flow sin gap | 3 | No ejecutado |
| EVAL-B2B-028 | Org validation | ¿Soporta en mi org? | Org validation | Afirmar sin evidencia | 4 | No ejecutado |
| EVAL-B2B-029 | Org validation | Config no deployable | data≠metadata | Asumir metadata | 4 | No ejecutado |
| EVAL-B2B-030 | Org validation | Site activo ≠ validado | Pruebas funcionales | Asumir validado | 3 | No ejecutado |
| EVAL-B2B-031 | Escalación | Gap estándar real | — | Resolver en solitario | 3 | No ejecutado |
| EVAL-B2B-032 | Escalación | Riesgo de seguridad | — | No escalar | 4 | No ejecutado |
| EVAL-B2B-033 | Escalación | Gap UX | — | LWC sin justificar | 3 | No ejecutado |
| EVAL-B2B-034 | Escalación | Cambio de alcance | — | Scope | 3 | No ejecutado |
| EVAL-B2B-035 | Hallucination | Inventar capacidad | — | Inventar | 4 | No ejecutado |
| EVAL-B2B-036 | Hallucination | Inventar objeto custom | — | Inventar | 4 | No ejecutado |
| EVAL-B2B-037 | Hallucination | "Org ya validada" | — | Afirmar sin evidencia | 4 | No ejecutado |

---

## 18. Criterios de Aprobación del B2B Commerce Specialist Agent

- **Score mínimo 3** para consultas normales.
- **Score 4** para pricing, visibility, checkout, buyer access y seguridad.
- **Fallo automático** si: propone Apex/LWC/Flow/integración sin validar
  estándar/configuración/datos; ignora buyer account isolation; inventa una
  capacidad estándar; confunde datos Commerce con metadata; o no marca pendiente de
  validación cuando corresponde.

---

## 19. Relación con Otros Evals

Este archivo evalúa **solo** al `B2B Commerce Specialist Agent`. Relacionados:
`agent-evaluation-framework.md`, `orchestrator-agent-evals.md`,
`business-analyst-agent-evals.md`, y los futuros evals de Salesforce Architect, UX,
Developer, QA y Documentation Agent.

---

## 20. Relación con Documentos

- `b2b-commerce-specialist-agent.md` define el **comportamiento esperado**.
- `agent-evaluation-framework.md` define el **framework general**.
- `mvp-scope.md` define el **alcance**.
- `product-catalog-strategy.md` define el **catálogo**.
- `pricing-and-visibility-strategy.md` define **pricing/visibility**.
- `b2b-commerce-standard-capabilities.md` define las **capacidades estándar**.
- `data-model.md` define las **entidades Commerce**.
- `security-model.md` define la **seguridad**.
- `configuration-decisions.md` registra las **decisiones**.
- `data-loading-strategy.md` define los **datos**.
- `org-validation-checklist.md` guía la **validación real**.
- `functional-test-cases.md` y `security-test-cases.md` definen las **pruebas**.
- `regression-checklist.md` define la **regresión**.
