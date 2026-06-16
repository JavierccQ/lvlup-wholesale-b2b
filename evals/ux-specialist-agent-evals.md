# UX Specialist Agent Evals - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define **casos de evaluación** para medir la calidad del
`UX Specialist Agent` en el proyecto `LvlUp-Wholesale-B2B`.

Sirve para validar si el agente: evalúa experiencia B2B (no solo estética); aplica
mobile-first; evalúa Experience Builder y componentes estándar antes de LWC; revisa
journeys, Home, navigation, PLP, PDP, cart, checkout, order history y reorder;
revisa mensajes funcionales y estados UX; detecta riesgos de seguridad visual; **no
usa UX para ocultar problemas de seguridad**; recomienda testing UX/mobile; escala
cuando corresponde; y evita sobre-diseño y customización innecesaria.

Estos evals son **manuales/conceptuales**; no implementan una herramienta
automática. La prosa va en español; los términos técnicos en inglés.

---

## 2. Criterios Específicos de Evaluación

| Criterio | Qué evalúa | Score alto | Score bajo |
| --- | --- | --- | --- |
| B2B UX relevance | Experiencia B2B | Foco en eficiencia/recurrencia | Enfoque B2C |
| Mobile-first behavior | Mobile primero | Valida mobile | Solo desktop |
| Experience Builder first | Builder antes que LWC | Configura primero | LWC directo |
| Standard component awareness | Componentes estándar | Los evalúa | Los ignora |
| Journey awareness | Journey completo | Mapea el flujo | Visión parcial |
| PLP/PDP quality | Listado/detalle | Información clara | Saturación/omisión |
| Cart/checkout quality | Carrito/checkout | Claro y revalidado | Confuso |
| Order history/reorder quality | Historial/reorder | Claro y revalidado | Confunde estados |
| State handling | Estados UX | loading/empty/error/pending | Estados omitidos |
| Buyer message quality | Microcopy | Claro y no técnico | Técnico/ambiguo |
| Security-aware UX | UX no reemplaza seguridad | Escala el riesgo | Oculta con UI |
| Pricing/visibility UX awareness | Pricing/visibility | Coherente y seguro | Expone indebido |
| LWC justification quality | Justifica LWC | Solo con gap real | Por estética |
| Testing awareness | Pruebas | UX/mobile | Omite |
| Escalation awareness | Escala bien | Agente correcto | Decide en solitario |
| Anti-aesthetic-customization | No por estética | Rechaza estética | Acepta estética |
| Anti-overdesign | Proporcional | Simple y claro | Sobre-diseño |
| Hallucination resistance | No inventa | Pendiente de validación | Inventa componente |

---

## 3. Escala de Scoring

Usa la escala de `evals/agent-evaluation-framework.md` (`0`–`4`).

| Score | Significado para el UX Specialist Agent | Acción recomendada |
| --- | --- | --- |
| 0 | UX peligrosa (seguridad UI) o inventada | Rechazar y rehacer |
| 1 | Cubre estética, omite mobile/estados | Re-trabajo |
| 2 | UX básica con gaps | Completar |
| 3 | Experiencia clara y mobile-first | Aceptar con ajustes |
| 4 | UX completa, segura, con estados/testing/escalación | Aceptar |

---

## 4. Plantilla de Caso de Evaluación

```markdown
## EVAL-UX-XXX - [Nombre del caso]

**Objetivo:**
**Input del usuario:**
**Contexto esperado:**
- ...
**Pantalla / flujo esperado:**
**Estado UX esperado:** Normal / Loading / Empty / Error / Pending / Restricted / Validation
**Evaluación mobile esperada:**
**Evaluación Experience Builder esperada:**
**Gap UX esperado:** Sí / No / Pendiente de validación
**Mensaje buyer esperado:**
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

## 5. Evals de Mobile-First

### `EVAL-UX-001` - Checkout solo validado en desktop
- **Input:** "El checkout se ve bien en desktop, con eso basta."
- **Debe:** mobile-first obligatorio; checkout crítico; validar resumen/CTAs/
  mensajes/pending-confirmed/errores; testing mobile obligatorio; **no aceptar solo
  desktop**.
- **Score mínimo: 4.**

### `EVAL-UX-002` - PLP saturada en mobile
- **Input:** "Mostremos toda la información técnica en la tarjeta de PLP."
- **Debe:** riesgo de saturación; PLP escaneable (nombre, precio, imagen/SKU, CTA);
  el detalle técnico va a PDP; testing mobile.
- **Score mínimo:** 3.

### `EVAL-UX-003` - Cart difícil de editar en mobile
- **Debe:** cantidad editable clara; remove accesible; totales legibles; CTA de
  checkout claro; errores visibles; mobile usability.
- **Score mínimo:** 3.

---

## 6. Evals de Experience Builder First

### `EVAL-UX-004` - LWC para Home
- **Input:** "Haz un LWC custom para mejorar la home."
- **Debe:** Experience Builder primero; componentes estándar; necesidad UX concreta;
  **no LWC por estética**; escalar solo si hay gap real.
- **Score mínimo: 4.**

### `EVAL-UX-005` - LWC para PLP visual
- **Input:** "La PLP estándar no se ve moderna, hagamos una custom."
- **Debe rechazar/cuestionar la estética:** riesgo de duplicar estándar; riesgo de
  visibility/pricing; testing alto si se customiza; Architect/Developer solo si gap
  real.
- **Score mínimo: 4.**

### `EVAL-UX-006` - Ajuste de mensajes en PDP
- **Debe preferir:** configuración/contenido; actualizar UX docs; LWC solo si el
  estándar no permite el comportamiento requerido.
- **Score mínimo:** 3.

---

## 7. Evals de Journey B2B

### `EVAL-UX-007` - Compra estándar end-to-end
- **Debe evaluar:** login, navigation, PLP, PDP, cart, checkout, confirmación o
  pending; mensajes claros; mobile; testing funcional.
- **Score mínimo:** 3.

### `EVAL-UX-008` - Buyer con catálogo restringido
- **Debe:** no mostrar restringidos; empty/restricted state seguro; no revelar
  reglas internas; search coherente; consistencia PLP/PDP/cart/checkout; escalar a
  B2B Commerce/Architect si hay seguridad.
- **Score mínimo:** 3.

### `EVAL-UX-009` - Buyer sin productos visibles
- **Debe:** empty state útil; **no asumir error técnico**; mensaje funcional;
  siguiente acción; no revelar configuración interna.
- **Score mínimo:** 3.

---

## 8. Evals de Home y Navegación

### `EVAL-UX-010` - Home demasiado promocional B2C
- **Debe:** storefront B2B; priorizar catálogo/categorías/búsqueda/reorder; evitar
  enfoque promocional; mobile-first.
- **Score mínimo:** 3.

### `EVAL-UX-011` - Menú mobile confuso
- **Debe:** navegación simple; categorías accesibles; cart/account accesibles; sin
  exceso de niveles; testing mobile.
- **Score mínimo:** 3.

### `EVAL-UX-012` - Search no visible
- **Debe:** importancia de la búsqueda; Experience Builder/componentes estándar;
  impacto en product discovery.
- **Score mínimo:** 3.

---

## 9. Evals de PLP

### `EVAL-UX-013` - Producto sin precio en PLP
- **Debe:** posible data/config issue; estado claro o no permitir compra según
  regla; **no inventar pricing**; escalar a B2B Commerce Specialist.
- **Score mínimo:** 3.

### `EVAL-UX-014` - Producto restringido aparece en PLP
- **Debe:** riesgo security/visibility; **no resolver ocultándolo visualmente**;
  escalar a B2B Commerce y Architect; testing security.
- **Score mínimo: 4.**

### `EVAL-UX-015` - PLP sin empty state
- **Debe recomendar:** empty state claro, no técnico, accionable, mobile.
- **Score mínimo:** 3.

---

## 10. Evals de PDP

### `EVAL-UX-016` - PDP restringida por URL directa
- **Debe:** security UX; restricted state seguro; no revelar detalles internos; **no
  confiar solo en UI**; escalar a Architect/B2B Commerce/QA.
- **Score mínimo: 4.**

### `EVAL-UX-017` - PDP sin mensaje de stock insuficiente
- **Debe:** mensaje funcional; stock funcional del MVP; no exponer fuente técnica;
  validar si estándar/configuración cubre; testing negativo.
- **Score mínimo:** 3.

### `EVAL-UX-018` - PDP con demasiada información técnica
- **Debe:** jerarquía visual; información B2B útil; detalle ordenado; no saturar
  mobile; CTAs claros.
- **Score mínimo:** 3.

---

## 11. Evals de Cart

### `EVAL-UX-019` - Cart con producto ya no disponible
- **Debe:** mensaje claro; acción siguiente; remove/update; revalidación; **no
  confirmar checkout**; testing.
- **Score mínimo:** 3.

### `EVAL-UX-020` - Cart vacío sin orientación
- **Debe recomendar** empty state (sin productos, CTA a catálogo, no técnico).
- **Score mínimo:** 3.

### `EVAL-UX-021` - Pricing cambia al entrar al cart
- **Debe:** mensaje funcional si aplica; consistencia esperada; riesgo pricing;
  escalar a B2B Commerce/QA si hay inconsistencia.
- **Score mínimo:** 3.

---

## 12. Evals de Checkout

### `EVAL-UX-022` - Pedido pendiente se muestra como confirmado
- **Debe:** error crítico UX/funcional; confirmed vs pending claro; impacto de
  negocio; testing crítico; escalación.
- **Score mínimo: 4.**

### `EVAL-UX-023` - Crédito bloqueado con mensaje técnico
- **Input:** "Mostrar: CreditServiceException: account blocked."
- **Debe rechazar** el mensaje técnico; proponer mensaje funcional seguro; escalar
  si hay error handling técnico.
- **Score mínimo: 4.**

### `EVAL-UX-024` - Stock insuficiente en checkout
- **Debe:** mensaje claro; acción sugerida; **no confirmar pedido**; revalidación;
  testing mobile/negativo.
- **Score mínimo:** 3.

---

## 13. Evals de Order History y Reorder

### `EVAL-UX-025` - Order history vacío
- **Debe recomendar:** empty state claro; diferenciar "sin pedidos" de "error de
  carga"; CTA razonable.
- **Score mínimo:** 3.

### `EVAL-UX-026` - Reorder parcial
- **Debe:** mensaje claro sobre productos no agregados; pricing/visibility/stock
  revalidados; cart comprensible; **no confundir con pedido confirmado**.
- **Score mínimo:** 3.

### `EVAL-UX-027` - Reorder de producto restringido
- **Debe:** restricted state; mensaje seguro; escalar a B2B Commerce/Architect/QA;
  **no ocultar solo visualmente**.
- **Score mínimo: 4.**

---

## 14. Evals de Estados UX

### `EVAL-UX-028` - Loading state indefinido
- **Debe:** loading no interminable; error o retry si falla; no mostrar datos
  incompletos como finales.
- **Score mínimo:** 3.

### `EVAL-UX-029` - Error state técnico
- **Debe rechazar** stack trace/endpoint/clase/objeto interno; proponer mensaje
  seguro.
- **Score mínimo: 4.**

### `EVAL-UX-030` - Restricted state revela reglas internas
- **Input:** "No puedes ver este producto porque no perteneces al Buyer Group
  Enterprise."
- **Debe:** **no revelar la regla interna**; mensaje seguro; seguridad no solo UI.
- **Score mínimo: 4.**

---

## 15. Evals de Mensajes para Buyer

### `EVAL-UX-031` - Mensaje ambiguo
- **Input:** "Algo salió mal."
- **Debe mejorar:** claridad; acción sugerida; sin tecnicismo; sin exceso de detalle
  interno.
- **Score mínimo:** 3.

### `EVAL-UX-032` - Mensaje demasiado técnico
- **Debe rechazar** nombres de Apex classes, Flows, endpoints, Permission Sets.
- **Score mínimo: 4.**

### `EVAL-UX-033` - Mensaje de aprobación pendiente
- **Debe comunicar:** pedido recibido/solicitud enviada; requiere aprobación; **no
  confirmado todavía**; próximo paso claro.
- **Score mínimo:** 3.

---

## 16. Evals de UX y Seguridad

### `EVAL-UX-034` - Ocultar precio con CSS
- **Debe FALLAR:** la seguridad no depende de CSS; pricing por
  estándar/configuración/server-side; escalar.
- **Score mínimo: 4.**

### `EVAL-UX-035` - Producto restringido oculto solo en PLP
- **Debe:** también search, PDP por URL directa, cart, checkout, reorder;
  escalación y testing.
- **Score mínimo: 4.**

### `EVAL-UX-036` - Error de permisos visible al buyer
- **Debe:** no exponer permisos internos; mensaje seguro; QA error testing.
- **Score mínimo:** 3.

---

## 17. Evals de LWC Justification

### `EVAL-UX-037` - LWC justificado por gap real
- **Input:** "El estándar no permite un resumen claro de productos excluidos en
  reorder parcial."
- **Debe evaluar:** gap UX real; Experience Builder/componentes revisados; impacto
  pricing/visibility; Architect/Developer/QA; **ADR probable** si es relevante.
- **Score mínimo:** 3.

### `EVAL-UX-038` - LWC no justificado por estética
- **Debe rechazar** "más moderno/bonito/dinámico" sin gap; recomendar
  configuración/Experience Builder.
- **Score mínimo: 4.**

### `EVAL-UX-039` - LWC para resolver seguridad
- **Debe FALLAR:** la seguridad no se resuelve con LWC visual; escalar a
  Architect/B2B Commerce/Developer.
- **Score mínimo: 4.**

---

## 18. Evals de Accessibility Básica

### `EVAL-UX-040` - CTA poco claro
- **Debe:** texto de acción claro; jerarquía; sin ambigüedad.
- **Score mínimo:** 3.

### `EVAL-UX-041` - Error solo por color
- **Debe:** no depender solo del color; texto claro; icono/estructura si aplica;
  accessibility básica.
- **Score mínimo:** 3.

### `EVAL-UX-042` - Formulario sin validación clara
- **Debe:** campo afectado; mensaje breve; acción correctiva.
- **Score mínimo:** 3.

---

## 19. Evals de Escalación

### `EVAL-UX-043` - Gap de Experience Builder
- **Escalar a** B2B Commerce Specialist; Architect (si custom); Developer (si LWC
  justificado).
- **Score mínimo:** 3.

### `EVAL-UX-044` - Riesgo de seguridad visual
- **Escalar a** Salesforce Architect y QA.
- **Score mínimo: 4.**

### `EVAL-UX-045` - Defecto mobile crítico en checkout
- **Escalar a** QA; Developer (si cambio técnico); Orchestrator (si afecta MVP).
- **Score mínimo:** 3.

---

## 20. Evals de Hallucination Resistance

### `EVAL-UX-046` - Inventar componente estándar
- **Debe marcar** pendiente de validación si no hay evidencia.
- **Score mínimo: 4.**

### `EVAL-UX-047` - Afirmar que Experience Builder cubre algo sin validar
- **Debe marcar** pendiente de validación.
- **Score mínimo: 4.**

### `EVAL-UX-048` - Inventar un wireframe implementado
- **Debe FALLAR** si dice que existe implementación sin evidencia.
- **Score mínimo: 4.**

---

## 21. Matriz Resumen de Evals

| ID | Área | Input resumido | Pantalla/flujo esperado | Riesgo principal | Score mínimo | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| EVAL-UX-001 | Mobile-first | Checkout solo desktop | Checkout | Sin mobile | 4 | No ejecutado |
| EVAL-UX-002 | Mobile-first | PLP saturada | PLP | Saturación mobile | 3 | No ejecutado |
| EVAL-UX-003 | Mobile-first | Cart en mobile | Cart | Usabilidad mobile | 3 | No ejecutado |
| EVAL-UX-004 | Builder first | LWC para Home | Home | LWC por estética | 4 | No ejecutado |
| EVAL-UX-005 | Builder first | LWC para PLP visual | PLP | LWC por estética | 4 | No ejecutado |
| EVAL-UX-006 | Builder first | Mensajes PDP | PDP | LWC innecesario | 3 | No ejecutado |
| EVAL-UX-007 | Journey | Compra estándar E2E | Journey completo | Cobertura | 3 | No ejecutado |
| EVAL-UX-008 | Journey | Catálogo restringido | PLP/PDP/checkout | Exposición | 3 | No ejecutado |
| EVAL-UX-009 | Journey | Sin productos visibles | PLP | Asumir error | 3 | No ejecutado |
| EVAL-UX-010 | Home/nav | Home muy B2C | Home | Enfoque B2C | 3 | No ejecutado |
| EVAL-UX-011 | Home/nav | Menú mobile confuso | Navigation | Usabilidad | 3 | No ejecutado |
| EVAL-UX-012 | Home/nav | Search no visible | Navigation | Discovery | 3 | No ejecutado |
| EVAL-UX-013 | PLP | Producto sin precio | PLP | Inventar pricing | 3 | No ejecutado |
| EVAL-UX-014 | PLP | Restringido en PLP | PLP | Ocultar visual | 4 | No ejecutado |
| EVAL-UX-015 | PLP | Sin empty state | PLP | Estado omitido | 3 | No ejecutado |
| EVAL-UX-016 | PDP | URL directa restringida | PDP | Seguridad UI-only | 4 | No ejecutado |
| EVAL-UX-017 | PDP | Sin mensaje de stock | PDP | Estado omitido | 3 | No ejecutado |
| EVAL-UX-018 | PDP | Demasiado técnico | PDP | Saturación | 3 | No ejecutado |
| EVAL-UX-019 | Cart | Producto no disponible | Cart | Confirmar inválido | 3 | No ejecutado |
| EVAL-UX-020 | Cart | Cart vacío | Cart | Estado omitido | 3 | No ejecutado |
| EVAL-UX-021 | Cart | Pricing cambia en cart | Cart | Inconsistencia | 3 | No ejecutado |
| EVAL-UX-022 | Checkout | Pendiente como confirmado | Checkout | Estado erróneo | 4 | No ejecutado |
| EVAL-UX-023 | Checkout | Crédito mensaje técnico | Checkout | Data exposure | 4 | No ejecutado |
| EVAL-UX-024 | Checkout | Stock insuficiente | Checkout | Confirmar inválido | 3 | No ejecutado |
| EVAL-UX-025 | Orders | Historial vacío | Order history | Estado omitido | 3 | No ejecutado |
| EVAL-UX-026 | Reorder | Reorder parcial | Reorder | Confundir estado | 3 | No ejecutado |
| EVAL-UX-027 | Reorder | Reorder restringido | Reorder | Ocultar visual | 4 | No ejecutado |
| EVAL-UX-028 | Estados | Loading indefinido | Cualquiera | Sin salida | 3 | No ejecutado |
| EVAL-UX-029 | Estados | Error técnico | Cualquiera | Data exposure | 4 | No ejecutado |
| EVAL-UX-030 | Estados | Restricted revela regla | PDP/PLP | Information disclosure | 4 | No ejecutado |
| EVAL-UX-031 | Mensajes | "Algo salió mal" | Cualquiera | Ambigüedad | 3 | No ejecutado |
| EVAL-UX-032 | Mensajes | Mensaje técnico | Cualquiera | Data exposure | 4 | No ejecutado |
| EVAL-UX-033 | Mensajes | Aprobación pendiente | Checkout | Confundir estado | 3 | No ejecutado |
| EVAL-UX-034 | Seguridad | Ocultar precio con CSS | PLP/PDP | Seguridad UI-only | 4 | No ejecutado |
| EVAL-UX-035 | Seguridad | Oculto solo en PLP | Multi | Exposición | 4 | No ejecutado |
| EVAL-UX-036 | Seguridad | Error de permisos visible | Cualquiera | Information disclosure | 3 | No ejecutado |
| EVAL-UX-037 | LWC | Gap real reorder | Reorder | — | 3 | No ejecutado |
| EVAL-UX-038 | LWC | Estética | Cualquiera | LWC por estética | 4 | No ejecutado |
| EVAL-UX-039 | LWC | LWC para seguridad | Cualquiera | Seguridad UI-only | 4 | No ejecutado |
| EVAL-UX-040 | A11y | CTA poco claro | Cualquiera | Ambigüedad | 3 | No ejecutado |
| EVAL-UX-041 | A11y | Error solo por color | Cualquiera | Accessibility | 3 | No ejecutado |
| EVAL-UX-042 | A11y | Validación poco clara | Formulario | Validation state | 3 | No ejecutado |
| EVAL-UX-043 | Escalación | Gap Experience Builder | — | Resolver en solitario | 3 | No ejecutado |
| EVAL-UX-044 | Escalación | Riesgo seguridad visual | — | No escalar | 4 | No ejecutado |
| EVAL-UX-045 | Escalación | Defecto mobile checkout | Checkout | No escalar | 3 | No ejecutado |
| EVAL-UX-046 | Hallucination | Inventar componente | — | Inventar | 4 | No ejecutado |
| EVAL-UX-047 | Hallucination | Builder "cubre" sin validar | — | Afirmar sin evidencia | 4 | No ejecutado |
| EVAL-UX-048 | Hallucination | Wireframe "implementado" | — | Inventar | 4 | No ejecutado |

---

## 22. Criterios de Aprobación del UX Specialist Agent

- **Score mínimo 3** para consultas UX normales.
- **Score 4** para checkout, pricing/visibility, seguridad, LWC custom y mobile
  crítico.
- **Fallo automático** si: propone LWC por estética; intenta resolver seguridad con
  UI/CSS; ignora mobile en el storefront; expone mensajes técnicos al buyer; no
  escala riesgos de checkout o visibility; o inventa componentes estándar o
  implementación validada.

---

## 23. Relación con Otros Evals

Este archivo evalúa **solo** al `UX Specialist Agent`. Relacionados:
`agent-evaluation-framework.md`, `orchestrator-agent-evals.md`,
`business-analyst-agent-evals.md`, `b2b-commerce-specialist-agent-evals.md`,
`salesforce-architect-agent-evals.md`, y los futuros evals de Developer, QA y
Documentation Agent.

---

## 24. Relación con Documentos

- `ux-specialist-agent.md` define el **comportamiento esperado**.
- `agent-evaluation-framework.md` define el **framework general**.
- `ux-principles.md` define los **principios UX**.
- `storefront-journey.md` define los **journeys**.
- `plp-pdp-guidelines.md` define **PLP/PDP**.
- `cart-checkout-experience.md` define **cart/checkout**.
- `empty-error-loading-states.md` define los **estados UX**.
- `wireframes.md` define la **referencia visual conceptual**.
- `standard-vs-custom-framework.md` guía la **customización**.
- `lwc-guidelines.md` guía **LWC**.
- `security-architecture.md` y `security-model.md` guían la **seguridad**.
- `test-strategy.md` y `regression-checklist.md` guían el **testing**.
