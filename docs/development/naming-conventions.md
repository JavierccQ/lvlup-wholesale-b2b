# Naming Conventions - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define las **convenciones de nombres** del proyecto
`LvlUp-Wholesale-B2B` para mantener consistencia en todo el repositorio.

Sirve para: documentación, estructura de carpetas, archivos Markdown, Apex, LWC,
Flow, integraciones, datos de prueba, ADRs, commits, agentes IA, evaluaciones y
code review.

Estas convenciones **no reemplazan las reglas oficiales de Salesforce**; las
**complementan** para este proyecto. Aplica el principio rector: *Configuration
first, customization only when justified*. La prosa va en español; los nombres
técnicos en inglés.

---

## 2. Principios Generales

- Nombres **claros, descriptivos y consistentes**.
- **Evitar abreviaturas** innecesarias.
- **Evitar nombres genéricos** (`Utils`, `Helper`, `Manager`, `New`, `Test`,
  `Temp`).
- El nombre debe **reflejar la responsabilidad**.
- **Inglés** para nombres técnicos.
- **Español** para documentación narrativa.
- Coherencia con el **glosario** (`commerce-cloud-glossary.md`).
- **No crear nombres definitivos** para artefactos que aún no existen.
- Si un nombre implica una **decisión arquitectónica**, documentarla.

---

## 3. Convención de Idioma

| Tipo de elemento | Idioma | Ejemplo correcto | Ejemplo incorrecto |
| --- | --- | --- | --- |
| Documentos Markdown (archivo) | Inglés (kebab-case) | `pricing-and-visibility-strategy.md` | `estrategia.md` |
| Títulos de documentos | Español | `# Guidelines Apex - LvlUp WholeSale` | `# Apex Doc` |
| Apex classes | Inglés | `CommerceCreditService` | `ServicioCredito` |
| Apex methods | Inglés | `validateCreditStatus` | `validarCredito` |
| Apex variables | Inglés | `buyerAccountId` | `idCuenta` |
| LWC component names | Inglés | `lvlupCreditStatusMessage` | `mensajeCredito` |
| Flow names | Inglés | `Validate_Order_Approval_Threshold` | `Aprobacion_Pedido` |
| API endpoints | Inglés | `/credit-status` | `/estado-credito` |
| JSON fields | Inglés (camelCase) | `creditStatus` | `estadoCredito` |
| Commit messages | Inglés | `docs: add naming conventions` | `docs: añadir convenciones` |
| ADR titles | Español | `Estrategia de integración` | `Integration strategy` |
| Test data names | Inglés (códigos) | `GAMING_STORE_MADRID` | `tiendaMadrid` |
| Agent names | Inglés (kebab-case) | `b2b-commerce-specialist` | `especialista-b2b` |

> Regla: **no mezclar idiomas dentro de un mismo nombre técnico** (`getEstadoCredito`
> es incorrecto). Mantener los términos Salesforce estándar en inglés.

---

## 4. Carpetas y Archivos Markdown

- Carpetas en **lowercase + kebab-case**.
- Archivos Markdown en **lowercase + kebab-case**.
- Nombres **descriptivos**; evitar `notes.md`, `misc.md`, `new-doc.md`.
- **Agrupación por dominio**: `docs/business/`, `docs/ux/`, `docs/architecture/`,
  `docs/salesforce/`, `docs/development/`, `docs/testing/`, `agents/`, `evals/`,
  `adr/`.

**Correctos:** `pricing-and-visibility-strategy.md`, `standard-vs-custom-framework.md`,
`data-loading-strategy.md`, `code-review-checklist.md`.

**Incorrectos:** `pricing.md`, `doc1.md`, `new_strategy.md`, `cosas.md`.

---

## 5. Títulos de Documentos

- Títulos en **español**, con claridad funcional.
- Incluir `LvlUp WholeSale` cuando aplique.
- Evitar títulos demasiado genéricos; reflejar el **alcance** del documento.

**Ejemplos:** `# Arquitectura de Solución - LvlUp WholeSale`,
`# Guidelines Apex - LvlUp WholeSale`, `# Estrategia de Carga de Datos - LvlUp WholeSale`.

---

## 6. Apex Classes

- **PascalCase**, en inglés.
- **Sufijos por responsabilidad**: `Service`, `Controller`, `Selector`,
  `Repository` (solo si se justifica), `Request`, `Response`, `Result`, `Mock`,
  `Test`, `Factory`.

**Ejemplos conceptuales:** `CommerceCreditService`, `StockAvailabilityService`,
`OrderApprovalService`, `CommerceIntegrationService`, `StockAvailabilityRequest`,
`StockAvailabilityResponse`, `CommerceCreditServiceTest`, `CommerceIntegrationMock`.

**Evitar:** `Utils`, `Helper`, `Manager`, `Process`, `Class1`, `TestClass`,
`LvlupStuff`.

*(Ejemplos conceptuales, no clases definitivas.)*

---

## 7. Apex Methods

- **camelCase**, descriptivos, **iniciando con verbo**.
- Evitar genéricos (`process`, `execute`, `doStuff`) salvo contexto muy claro.
- **Regla obligatoria:** todo método Apex en camelCase con nombre que refleje su
  responsabilidad.

**Ejemplos:** `validateCreditStatus`, `calculateApprovalRequirement`,
`fetchStockAvailability`, `buildStockRequest`, `parseCreditResponse`,
`handleIntegrationError`.

**Evitar:** `Process`, `doIt`, `run`, `method1`, `validate`.

---

## 8. Apex Variables y Constantes

- Variables en **camelCase**.
- Constantes en **UPPER_SNAKE_CASE**.
- Booleanos con prefijos claros: `is`, `has`, `should`, `can`.

**Ejemplos:** `buyerAccountId`, `requestedQuantity`, `availableStock`,
`isCreditBlocked`, `hasApprovalRequired`, `MAX_RETRY_ATTEMPTS`,
`DEFAULT_TIMEOUT_SECONDS`.

**Evitar:** `x`, `data`, `flag`, `temp`, `obj`, `lst`.

---

## 9. LWC Components

- Carpeta del componente en **camelCase** (requisito de la plataforma); referencia
  documental en **kebab-case** si se prefiere.
- Nombre **funcional y descriptivo**, en inglés.
- **No** crear componentes por estética sin gap validado.
- Prefijo de proyecto **consistente** (p. ej. `lvlup`).

**Ejemplos conceptuales (carpeta camelCase / referencia kebab-case):**
`lvlupProductStockBadge` / `lvlup-product-stock-badge`,
`lvlupCreditStatusMessage`, `lvlupApprovalStatusPanel`,
`lvlupReorderValidationSummary`, `lvlupQuoteRequestPanel`.

**Evitar:** `customComponent`, `testLwc`, `newCard`, `productThing`, `component1`.

> Nota técnica: el nombre de carpeta de un LWC debe ser **camelCase** (la plataforma
> no admite guiones). El kebab-case se usa solo como referencia legible en
> documentación.

*(Ejemplos conceptuales, no componentes definitivos.)*

---

## 10. LWC JavaScript

- Variables y métodos en **camelCase**.
- Constantes en **UPPER_SNAKE_CASE**.
- Booleanos con `is`, `has`, `should`, `can`.
- Eventos con nombres claros (ver §11).

**Ejemplos:** `isLoading`, `hasError`, `stockStatus`, `approvalStatus`,
`handleQuantityChange`, `dispatchApprovalRequestedEvent`, `MAX_VISIBLE_ITEMS`.

---

## 11. LWC Events

- **Convención del proyecto: todo en minúsculas, sin separadores** (es la opción más
  segura para LWC, ya que el nombre del evento no admite camelCase ni guiones de
  forma fiable).
- Nombre **orientado a la acción**; payload **pequeño y explícito**.
- Evitar eventos genéricos (`change`, `click`, `update`) si no son claros.

**Ejemplos (convención adoptada):** `stockstatuschange`, `approvalrequested`,
`quotecreated`, `reordervalidated`.

> Decisión: se adopta **lowercase sin separadores** y se mantiene de forma
> consistente. La referencia kebab-case (`stock-status-change`) se usa solo en
> documentación legible, no como nombre real del evento.

---

## 12. Flow Names

- En **inglés**.
- **Convención del proyecto: `Title_Case_With_Underscores`** (consistente con
  `flow-guidelines.md`).
- Nombre **funcional**, con dominio cuando aplique.
- Evitar `New Flow`, `Flow1`, `Test Flow`.

**Ejemplos conceptuales:** `Validate_Order_Approval_Threshold`,
`Update_Pending_Approval_Status`, `Notify_Credit_Block_Status`,
`Create_Quote_Request`.

**Evitar:** `Flow1`, `New_Flow`, `TestApproval`, `ProcessStuff`.

---

## 13. Flow Resources

- Variables en **camelCase**, nombres claros.
- Inputs y outputs **identificables**.
- Booleanos con prefijos (`is`, `has`, `should`, `can`).
- Evitar `var1`, `record`, `collection1`.

**Ejemplos:** `buyerAccountId`, `orderTotal`, `approvalThreshold`,
`isApprovalRequired`, `creditStatus`, `orderStatus`.

---

## 14. API Endpoints y Contratos

- Endpoints conceptuales en **inglés**, **lowercase + kebab-case**, orientados a
  recursos.
- **Versionar** cuando aplique.
- **No definir endpoints definitivos** hasta la fase correspondiente.

**Ejemplos conceptuales:** `/stock-availability`, `/credit-status`,
`/final-pricing`, `/orders/{orderId}/status`, `/invoices`.

**JSON fields en camelCase:**

```json
{
  "buyerAccountCode": "GAMING_STORE_MADRID",
  "requestedQuantity": 10,
  "creditStatus": "BLOCKED"
}
```

*(Contratos ilustrativos, no definitivos; coherentes con `integration-guidelines.md`.)*

---

## 15. Datos de Prueba

- **Códigos de cuenta/segmento** en **UPPER_SNAKE_CASE**: `GAMING_STORE_MADRID`,
  `TECH_RESELLER_IBERIA`, `IT_SOLUTIONS_SMB`, `ENTERPRISE_GAMING_PROCUREMENT`.
- **SKUs** con patrón `LVL-<CAT>-NNN`: `LVL-CON-001`, `LVL-LAP-001`
  (coherente con `product-catalog-strategy.md`).
- **Buyer Groups** con nombre funcional en inglés: `Gaming Local Buyers`,
  `Tech Resellers`, `Corporate IT Buyers`, `Enterprise Buyers`.
- Los datos de prueba deben ser **reproducibles** y **no depender de IDs manuales**
  (ver `data-loading-strategy.md`).
- Evitar nombres ambiguos (`test1`, `cuentaPrueba`, `productoX`).

---

## 16. ADRs

- Archivos en `adr/` con patrón **`NNNN-short-kebab-case.md`** (prefijo numérico
  secuencial): `0001-project-scope.md`, `0002-standard-vs-custom-strategy.md`.
- El **slug** del archivo, conciso y en inglés (consistente con el índice).
- El **título y el contenido** del ADR, en **español**.
- Numeración **incremental y estable**; no reordenar ADRs existentes.

**Ejemplo de cabecera (conceptual):**

```text
# ADR 0003 - Estrategia de Integración
Estado: Propuesto | Aceptado | Reemplazado
```

---

## 17. Commit Messages

- En **inglés**, estilo **Conventional Commits**: `type: subject` en imperativo.
- Tipos habituales: `docs`, `feat`, `fix`, `refactor`, `test`, `chore`, `config`.
- **Subject conciso** (idealmente ≤ 72 caracteres); cuerpo opcional con detalle.
- Incluir el footer de co-autoría cuando corresponda (según `CLAUDE.md`).

**Ejemplos:** `docs: add naming conventions`,
`feat: add stock availability badge component`,
`fix: correct credit status mapping`.

**Evitar:** `update`, `cambios`, `wip`, `fix bug`, `asdf`.

---

## 18. Agentes IA y Evaluaciones

- **Agentes** en `agents/` con archivo **kebab-case en inglés** por rol:
  `orchestrator.md`, `b2b-commerce-specialist.md`, `salesforce-architect.md`,
  `apex-specialist.md`, `lwc-specialist.md`, `flow-specialist.md`,
  `integration-specialist.md`, `qa-specialist.md`, `documentation-specialist.md`.
- El **nombre del rol** en inglés; el **contenido** del agente, en español (salvo
  términos técnicos).
- **Evaluaciones** en `evals/` con patrón **`<domain>-evals.md`**:
  `catalog-evals.md`, `pricing-evals.md`, `checkout-evals.md`,
  `integration-evals.md`, `ux-evals.md`, y `eval-results.md`.
- **No** incluir prompts dentro de este documento; viven en `agents/`.

---

## 19. Tabla Resumen de Convenciones

| Tipo | Convención | Idioma | Ejemplo |
| --- | --- | --- | --- |
| Carpeta/archivo Markdown | kebab-case | Inglés | `data-loading-strategy.md` |
| Título de documento | Frase descriptiva | Español | `# Modelo de Datos - LvlUp WholeSale` |
| Apex class | PascalCase + sufijo | Inglés | `CommerceCreditService` |
| Apex method | camelCase (verbo) | Inglés | `validateCreditStatus` |
| Apex variable | camelCase | Inglés | `buyerAccountId` |
| Apex constant | UPPER_SNAKE_CASE | Inglés | `MAX_RETRY_ATTEMPTS` |
| LWC folder | camelCase | Inglés | `lvlupProductStockBadge` |
| LWC variable/method | camelCase | Inglés | `handleQuantityChange` |
| LWC event | lowercase sin separadores | Inglés | `approvalrequested` |
| Flow name | Title_Case_With_Underscores | Inglés | `Validate_Order_Approval_Threshold` |
| Flow resource | camelCase | Inglés | `approvalThreshold` |
| API endpoint | kebab-case orientado a recurso | Inglés | `/credit-status` |
| JSON field | camelCase | Inglés | `creditStatus` |
| Test data code | UPPER_SNAKE_CASE | Inglés | `GAMING_STORE_MADRID` |
| SKU | `LVL-<CAT>-NNN` | Inglés | `LVL-CON-001` |
| ADR file | `NNNN-kebab-case.md` | Inglés (slug) | `0001-project-scope.md` |
| Commit | `type: subject` | Inglés | `docs: add naming conventions` |
| Agent file | kebab-case | Inglés | `apex-specialist.md` |
| Eval file | `<domain>-evals.md` | Inglés | `pricing-evals.md` |

---

## 20. Anti-patrones de Naming

- Nombres **genéricos** (`Utils`, `Helper`, `Manager`, `data`, `temp`, `flag`).
- **Mezclar idiomas** en un mismo nombre técnico (`getEstadoCredito`).
- **Abreviaturas** crípticas (`bAccId`, `qty1`, `crdSt`).
- Nombres que **no reflejan la responsabilidad** (`Class1`, `Flow1`, `component1`).
- **Números mágicos** como nombres (`process2`, `v2final`).
- Archivos **vagos** (`notes.md`, `cosas.md`, `new-doc.md`).
- Commits **no informativos** (`wip`, `update`, `fix`).
- Crear **nombres definitivos** para artefactos aún no validados.

---

## 21. Relación con Otros Documentos

- `docs/salesforce/commerce-cloud-glossary.md` define el **vocabulario** que estos
  nombres deben respetar.
- `docs/development/apex-guidelines.md`, `lwc-guidelines.md`, `flow-guidelines.md` e
  `integration-guidelines.md` definen el **detalle por tecnología**.
- `docs/development/code-review-checklist.md` **verifica** estas convenciones en la
  review.
- `docs/salesforce/data-loading-strategy.md` y `product-catalog-strategy.md` definen
  los **datos de prueba** y los SKUs.
- `CLAUDE.md` define la **política de idioma** que esta guía operativiza.
- `adr/`, `agents/` y `evals/` siguen las convenciones de nombres aquí descritas.
