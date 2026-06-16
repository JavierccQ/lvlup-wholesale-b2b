# Checklist de Regresión - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define una **checklist de regresión** para validar rápidamente que
un cambio **no rompe los flujos críticos** del storefront B2B Commerce de
`LvlUp-Wholesale-B2B`.

Sirve para: validar cambios antes de considerarlos completos, detectar impactos no
deseados, proteger los flujos críticos del MVP, validar el storefront tras
configuración/datos/metadata/código, guiar el smoke y el regression testing,
alimentar las release notes internas y guiar a futuros agentes QA.

Esta checklist **no reemplaza** los casos funcionales, de seguridad o integración;
**resume validaciones mínimas y repetibles**. La prosa va en español; los términos
técnicos en inglés.

> **Estado inicial:** las validaciones están **por ejecutar**; las que dependen de
> capacidades no confirmadas se marcan **pendiente de validación** o **futuro**.

---

## 2. Cuándo Ejecutar Regresión

| Tipo de cambio | Regresión mínima requerida | Regresión extendida recomendada | Prioridad |
| --- | --- | --- | --- |
| Catálogo / categorías / products | Smoke + Catálogo + PLP/PDP | + Pricing + Visibilidad | Alta |
| Price Books / pricing | Smoke + Pricing | + Cart/Checkout + Visibilidad | Alta |
| Buyer Groups | Smoke + Visibilidad + Pricing | + Catálogo + Seguridad | Alta |
| Visibilidad / entitlements | Smoke + Visibilidad | + Search/PLP/PDP + Seguridad | Alta |
| Buyer users / Permission Sets | Login + Seguridad | + Visibilidad + Pricing | Alta |
| Experience Builder | Smoke + Home/PLP/PDP | + Cart/Checkout + Mobile | Media |
| PLP / PDP | PLP/PDP | + Pricing + Visibilidad + Mobile | Alta |
| Cart / Checkout | Cart + Checkout | + Pricing + Stock + Seguridad | Alta |
| Order history / Reorder | Orders + Reorder | + Pricing + Visibilidad | Media |
| Flow / LWC / Apex | Targeted del área | + Core regression | Alta |
| Integración futura | Integration (mock) | + Error handling + Seguridad | Futuro |
| Datos de prueba | Smoke + área afectada | + Core regression | Media |
| Configuración de seguridad | Seguridad | + Visibilidad + Pricing | Alta |
| Deployment | Smoke + Post-deployment | + Core regression | Alta |

---

## 3. Niveles de Regresión

| Nivel | Cuándo usar | Duración esperada | Áreas cubiertas | Riesgo cubierto |
| --- | --- | --- | --- | --- |
| Smoke regression | Tras cualquier deploy/cambio | Rápida | Login, Home, PLP, PDP, cart, checkout (inicio) | Storefront roto |
| Core regression | Cambios en flujos del MVP | Media | Flujos críticos completos | Romper el MVP |
| Extended regression | Cambios amplios o sensibles | Más completa | + negativos, seguridad, mobile, errores | Regresiones sutiles |
| Targeted regression | Cambio acotado a un área | Acotada | Solo el área afectada y vecinas | Impacto local |

*(Duraciones cualitativas; no se fijan tiempos exactos sin validar.)*

---

## 4. Datos Base para Regresión

**Buyer Accounts:** Gaming Store Madrid, Tech Reseller Iberia, IT Solutions SMB,
Enterprise Gaming Procurement.

**Productos:** visible para todos; restringido; con pricing diferenciado; con stock
suficiente; con stock insuficiente; sin pricing (si aplica).

**Orders:** confirmado; pendiente (si aplica); con productos válidos para reorder;
con producto ya no disponible (si aplica).

> Los datos definitivos dependen de `data-loading-strategy.md`.

---

## 5. Smoke Regression Checklist

- [ ] Buyer puede iniciar sesión.
- [ ] Home carga correctamente.
- [ ] Menú o navegación principal visible.
- [ ] Categorías principales visibles.
- [ ] PLP carga productos.
- [ ] PDP carga un producto permitido.
- [ ] Pricing visible donde corresponde.
- [ ] Un producto permitido puede agregarse al cart.
- [ ] Cart carga correctamente.
- [ ] Checkout puede iniciarse.
- [ ] Un producto restringido no aparece para un buyer no autorizado.
- [ ] Los mensajes de error no muestran detalles técnicos.
- [ ] Logout o fin de sesión funciona (si aplica).

---

## 6. Login y Acceso

- [ ] Buyer autorizado inicia sesión.
- [ ] Usuario no autenticado no accede a áreas protegidas.
- [ ] Sesión expirada se maneja correctamente.
- [ ] Usuario sin permisos recibe mensaje seguro.
- [ ] No se muestran errores técnicos al buyer.
- [ ] No se prueba solo con usuario admin.

---

## 7. Home y Navegación

- [ ] Home carga para buyer autenticado.
- [ ] Categorías visibles según configuración.
- [ ] Navegación funciona.
- [ ] Header muestra accesos esperados.
- [ ] Acceso a cart funciona.
- [ ] Acceso a My Account / historial funciona (si aplica).
- [ ] No hay enlaces rotos evidentes.
- [ ] Mobile navigation funciona (si aplica).

---

## 8. Catálogo y Categorías

- [ ] Categorías principales visibles.
- [ ] Productos aparecen en la categoría correcta.
- [ ] Categoría sin productos muestra empty state.
- [ ] Producto activo visible aparece.
- [ ] Producto restringido no aparece.
- [ ] Producto no comprable se maneja correctamente (si aplica).
- [ ] Los cambios de catálogo no rompen PLP/PDP.

---

## 9. Search y PLP

- [ ] Search encuentra un producto permitido.
- [ ] Search no devuelve un producto restringido.
- [ ] Search sin resultados muestra mensaje claro.
- [ ] PLP muestra productos permitidos.
- [ ] PLP muestra la información mínima del producto.
- [ ] PLP muestra el pricing aplicable.
- [ ] PLP respeta la visibilidad.
- [ ] PLP maneja empty state.
- [ ] PLP maneja error state seguro.
- [ ] PLP funciona en mobile.

---

## 10. PDP

- [ ] PDP de producto permitido carga correctamente.
- [ ] PDP muestra nombre, SKU (si aplica), descripción, precio y disponibilidad.
- [ ] PDP permite agregar un producto permitido al cart.
- [ ] PDP restringida por URL directa se bloquea/maneja de forma segura.
- [ ] PDP sin pricing se maneja correctamente.
- [ ] PDP con stock insuficiente muestra mensaje funcional.
- [ ] Cantidad inválida se maneja correctamente.
- [ ] PDP funciona en mobile.

---

## 11. Pricing

- [ ] Precio correcto en PLP.
- [ ] Precio correcto en PDP.
- [ ] Precio correcto en cart.
- [ ] Precio correcto en checkout.
- [ ] Pricing consistente entre pantallas.
- [ ] El buyer no ve pricing de otro segmento.
- [ ] Un producto sin pricing no expone información indebida.
- [ ] Un cambio de pricing no deja cart/checkout inconsistente.
- [ ] Multi-divisa (fuera del MVP) no se valida.

---

## 12. Visibilidad / Entitlements

- [ ] El buyer ve solo productos permitidos.
- [ ] El buyer no ve productos restringidos.
- [ ] Un producto restringido no aparece en search.
- [ ] Un producto restringido no aparece en PLP.
- [ ] URL directa a PDP restringida se maneja de forma segura.
- [ ] Un producto restringido no se agrega al cart.
- [ ] El checkout revalida la visibilidad.
- [ ] El reorder revalida la visibilidad actual.

---

## 13. Cart

- [ ] Un producto permitido se agrega al cart.
- [ ] La cantidad se modifica correctamente.
- [ ] El producto se elimina correctamente.
- [ ] El cart muestra subtotal/total funcional.
- [ ] Cart vacío muestra empty state.
- [ ] Producto sin stock suficiente se maneja.
- [ ] Producto ya no visible se maneja.
- [ ] Producto con pricing actualizado se maneja.
- [ ] Cantidad inválida se bloquea o corrige.
- [ ] Cart funciona en mobile.

---

## 14. Checkout

- [ ] Checkout inicia con cart válido.
- [ ] Checkout muestra el resumen correcto.
- [ ] Checkout muestra el total funcional.
- [ ] Checkout confirma el pedido cuando aplica.
- [ ] Checkout diferencia pedido confirmado de solicitud pendiente.
- [ ] Checkout bloquea un producto no autorizado.
- [ ] Checkout revalida el pricing.
- [ ] Checkout revalida el stock funcional.
- [ ] Checkout maneja crédito bloqueado/excedido (si aplica).
- [ ] Checkout maneja approval required (si aplica).
- [ ] Un error técnico no expone detalles internos.
- [ ] Pagos, tax y shipping reales quedan fuera del MVP.

---

## 15. Approval por Importe

- [ ] Pedido bajo umbral no requiere aprobación (si la regla existe).
- [ ] Pedido sobre umbral requiere aprobación (si la regla existe).
- [ ] La solicitud pendiente se comunica claramente.
- [ ] Pending order no se confunde con confirmed order.
- [ ] Umbral no configurado queda registrado como gap (`DEC-008`).
- [ ] Automatización pendiente marcada como pendiente de validación.

---

## 16. Credit Validation

- [ ] Crédito válido permite continuar.
- [ ] Crédito bloqueado bloquea o condiciona el checkout.
- [ ] Crédito excedido bloquea o condiciona el checkout.
- [ ] Crédito no disponible muestra mensaje funcional.
- [ ] Si depende de integración futura, queda marcado como futuro/pendiente.

---

## 17. Stock Funcional

- [ ] Stock suficiente permite la compra.
- [ ] Stock insuficiente muestra mensaje funcional.
- [ ] Cantidad superior al stock se bloquea o condiciona.
- [ ] Stock no disponible se maneja correctamente.
- [ ] ETA futura solo se valida si está disponible.
- [ ] Backorder fuera o pendiente según decisión.

---

## 18. Orders / Historial

- [ ] El buyer ve su historial propio.
- [ ] Un buyer sin orders ve empty state.
- [ ] El buyer no ve orders de otra cuenta.
- [ ] El detalle de order muestra información suficiente.
- [ ] Confirmed order muestra el estado correcto.
- [ ] Pending order muestra el estado correcto (si aplica).
- [ ] Un error al cargar el historial no expone detalles técnicos.

---

## 19. Reorder

- [ ] Reorder desde un order propio permitido.
- [ ] Reorder agrega los productos actuales al cart.
- [ ] Reorder revalida el pricing actual.
- [ ] Reorder revalida la visibilidad actual.
- [ ] Reorder maneja un producto ya no disponible.
- [ ] Reorder parcial funciona (si aplica).
- [ ] Reorder con stock insuficiente se maneja.
- [ ] Reorder funciona en mobile (si aplica).

---

## 20. Seguridad

- [ ] El buyer solo ve datos de su cuenta.
- [ ] El buyer solo ve el catálogo permitido.
- [ ] El buyer solo ve el pricing aplicable.
- [ ] El buyer no accede a un order de otra cuenta.
- [ ] El buyer no accede al cart/checkout de otra cuenta.
- [ ] Los errores de seguridad no revelan lógica interna.
- [ ] Los Permission Sets no conceden permisos excesivos.
- [ ] No se confía solo en ocultar elementos de UI.
- [ ] Pruebas ejecutadas con buyer user.

---

## 21. UX y Estados

- [ ] Loading states visibles.
- [ ] Empty states claros.
- [ ] Error states no técnicos.
- [ ] Pending states diferenciados.
- [ ] Restricted states seguros.
- [ ] Validation states accionables.
- [ ] Mensajes consistentes.
- [ ] CTAs claros.
- [ ] Mobile-first respetado.
- [ ] No se introduce un patrón B2C innecesario.

---

## 22. Mobile Regression

- [ ] Login mobile.
- [ ] Home mobile.
- [ ] Navegación mobile.
- [ ] PLP mobile.
- [ ] PDP mobile.
- [ ] Cart mobile.
- [ ] Checkout mobile.
- [ ] Historial mobile.
- [ ] Reorder mobile (si aplica).
- [ ] Mensajes de error mobile.
- [ ] Botones y CTAs usables.

---

## 23. Error Handling Regression

- [ ] Un error funcional muestra un mensaje claro.
- [ ] Un error técnico muestra un mensaje seguro.
- [ ] No se muestra stack trace.
- [ ] No se muestran nombres de clases, endpoints o Flows.
- [ ] Un error de pricing no revela datos de otro buyer.
- [ ] Un error de producto restringido no revela lógica interna.
- [ ] Un error de integración futura no expone endpoint/token.
- [ ] El retry solo aparece si aplica.

---

## 24. Integration Regression Futura

*(Futuro / pendiente; coherente con `integration-test-cases.md`.)*

- [ ] Stock service mock success.
- [ ] Stock service mock timeout.
- [ ] Pricing service mock success.
- [ ] Pricing service mock invalid response.
- [ ] Credit service mock blocked.
- [ ] Credit service mock timeout.
- [ ] ETA service no bloquea checkout si no es crítico.
- [ ] Order status service no expone pedidos de otra cuenta.
- [ ] Invoice service no expone facturas de otra cuenta.
- [ ] Los logs no contienen secrets.

---

## 25. Regression por Tipo de Cambio

| Si cambia… | Ejecutar como mínimo… | Riesgo principal | Documentos relacionados |
| --- | --- | --- | --- |
| Pricing | Smoke + §11 + §14 | Pricing inconsistente | `pricing-and-visibility-strategy.md` |
| Product visibility | Smoke + §12 + §20 | Exposición indebida | `pricing-and-visibility-strategy.md`, `security-model.md` |
| Product catalog | Smoke + §8 + §9/§10 | Catálogo roto | `product-catalog-strategy.md` |
| Buyer Group | Smoke + §12 + §11 | Segmentación errónea | `pricing-and-visibility-strategy.md` |
| Permission Set | §6 + §20 | Acceso indebido | `security-model.md` |
| Experience Builder page | Smoke + §7 + §9/§10 + §22 | Experiencia rota | `ux-principles.md` |
| PLP | §9 + §11 + §12 | Listado/visibilidad | `plp-pdp-guidelines.md` |
| PDP | §10 + §11 + §12 | Detalle/visibilidad | `plp-pdp-guidelines.md` |
| Cart | §13 + §11 + §17 | Compra inconsistente | `cart-checkout-experience.md` |
| Checkout | §14 + §11 + §20 | Confirmación errónea | `cart-checkout-experience.md` |
| Order history | §18 | Datos ajenos | `b2b-commerce-flows.md` |
| Reorder | §19 + §11 + §12 | Reorder con datos obsoletos | `b2b-commerce-flows.md` |
| Flow | Targeted + §14/§15 | Automatización rota | `flow-guidelines.md` |
| LWC | Targeted + §21 + §22 | UI rota | `lwc-guidelines.md` |
| Apex | Targeted + área afectada | Lógica rota | `apex-guidelines.md` |
| Integration mock | §24 | Integración futura | `integration-test-cases.md` |
| Data loading | Smoke + área afectada | Datos inconsistentes | `data-loading-strategy.md` |

---

## 26. Criterios de Pass / Fail

| Resultado | Significado | Acción siguiente |
| --- | --- | --- |
| Pass | El comportamiento esperado se cumple sin defectos relevantes | Continuar |
| Fail | El comportamiento esperado no se cumple | Registrar defecto y corregir |
| Blocked | No se puede ejecutar (datos/config/acceso) | Desbloquear dependencia |
| Pending validation | Depende de validación real en la org | Validar en la org |
| Not applicable | No aplica al cambio revisado | Omitir |

---

## 27. Registro de Regresión

```markdown
## Registro de Regresión

**Fecha:**
**Cambio validado:**
**Área afectada:**
**Tipo de regresión:** Smoke / Core / Extended / Targeted
**Buyer usado:**
**Datos usados:**
**Checklist ejecutada:**
**Resultado:** Pass / Fail / Blocked / Pending
**Defectos encontrados:**
- ...
**Gaps detectados:**
- ...
**Documentos a actualizar:**
- ...
**ADR requerido:** Sí / No
**Notas:**
```

---

## 28. Gestión de Defectos Detectados

Todo defecto debe registrar: **ID**, **área**, **descripción**, **severidad**,
**pasos para reproducir**, **resultado esperado**, **resultado real**, **buyer
usado**, **datos usados**, **evidencia**, **impacto**, **documento relacionado** y
**estado**.

Los defectos relevantes se reflejan en `configuration-decisions.md` y, si implican
una decisión, en `adr/`.

---

## 29. Severidad de Defectos de Regresión

| Severidad | Descripción | Ejemplo | Acción recomendada |
| --- | --- | --- | --- |
| Critical | Rotura crítica o exposición grave | Buyer ve un order de otra cuenta | Bloquear; corregir de inmediato |
| High | Flujo crítico incorrecto | Checkout confirma con pricing incorrecto | Corregir antes de avanzar |
| Medium | Problema funcional no crítico | Cart muestra un mensaje poco claro | Planificar corrección |
| Low | Detalle menor sin exposición | Texto UX mejorable | Mejorar cuando se pueda |

---

## 30. Relación con Otros Documentos

- `docs/testing/test-strategy.md` define la **estrategia general**.
- `docs/testing/functional-test-cases.md` define los **casos funcionales**.
- `docs/testing/security-test-cases.md` define los **casos de seguridad**.
- `docs/testing/integration-test-cases.md` define los **casos de integración
  futura**.
- Este documento resume la **regresión mínima y extendida**.
- `docs/development/deployment-guidelines.md` define la **validación pre/post
  deployment**.
- `docs/development/error-handling-guidelines.md` define los **errores**.
- `docs/salesforce/data-loading-strategy.md` define los **datos necesarios**.
- `docs/salesforce/security-model.md` define la **seguridad a validar**.
- `docs/salesforce/configuration-decisions.md` se **actualiza** ante gaps.
- `adr/` se usa si la regresión evidencia una **decisión relevante**.
