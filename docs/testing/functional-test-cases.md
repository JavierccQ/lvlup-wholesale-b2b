# Casos de Prueba Funcionales - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define un **catálogo de casos de prueba funcionales** para validar el
comportamiento del storefront B2B de `LvlUp-Wholesale-B2B`, cubriendo los flujos
principales y los escenarios negativos del MVP.

Sirve como base para: validación manual del MVP, testing funcional y de regresión,
validación de configuración Salesforce y de datos, validación de pricing y
visibilidad, validación de cart/checkout/historial/reorder, identificación de gaps,
futuras automatizaciones y agentes QA.

Este documento **no define scripts automáticos ni una herramienta definitiva**. La
prosa va en español; los IDs, actores, estados y términos Salesforce en inglés.

> **Nota de formato:** dado el volumen de casos, se usa la **ficha completa** de la
> §2 como plantilla y como ejemplo en `FTC-LOGIN-001`; el resto se cataloga en
> **tablas compactas** con campos equivalentes, para mantener el catálogo
> ejecutable y navegable.
>
> **Estado inicial:** todos los casos están en **No ejecutado**.

---

## 2. Convención de Casos de Prueba

Plantilla estándar por caso:

- **ID**, **Nombre**, **Área**, **Prioridad**, **Estado**, **Actor**,
  **Precondiciones**, **Datos requeridos**, **Pasos conceptuales**, **Resultado
  esperado**, **Resultado negativo esperado** (si aplica), **Documentos
  relacionados**, **Notas / gaps**.

Prefijos de ID: `FTC-LOGIN`, `FTC-HOME`, `FTC-CAT`, `FTC-SEARCH`, `FTC-PLP`,
`FTC-PDP`, `FTC-PRI`, `FTC-VIS`, `FTC-CART`, `FTC-CHK`, `FTC-APP`, `FTC-CRE`,
`FTC-STK`, `FTC-ORD`, `FTC-REO`, `FTC-UX`, `FTC-MOB`.

**Ejemplo en ficha completa:**

- **ID:** `FTC-LOGIN-001`
- **Nombre:** Buyer inicia sesión correctamente
- **Área:** Login y acceso
- **Prioridad:** Alta
- **Estado:** No ejecutado
- **Actor:** Buyer operativo (p. ej. Gaming Store Madrid)
- **Precondiciones:** Usuario buyer activo asociado a una cuenta
- **Datos requeridos:** Credenciales válidas del buyer
- **Pasos conceptuales:** Acceder al storefront → introducir credenciales → iniciar
  sesión
- **Resultado esperado:** Accede a su experiencia con su contexto de cuenta cargado
- **Resultado negativo esperado:** Con credenciales inválidas, "Email o contraseña
  incorrectos." sin detalle técnico
- **Documentos relacionados:** `security-model.md`, `business-rules.md`
  (`BR-ACCESS-001`)
- **Notas / gaps:** Pendiente de validación en la org

---

## 3. Estados de Caso de Prueba

| Estado | Significado | Acción siguiente |
| --- | --- | --- |
| No ejecutado | Aún no probado | Programar ejecución |
| Ejecutado exitosamente | Pasó | Cerrar/registrar evidencia |
| Fallido | No pasó | Registrar defecto |
| Bloqueado | No se puede ejecutar | Desbloquear dependencia |
| Pendiente de datos | Faltan datos de prueba | Cargar datos |
| Pendiente de configuración | Falta configuración | Configurar |
| Pendiente de validación en org | Capacidad no verificada | Validar en la org |
| Fuera del MVP | No aplica al MVP | Diferir |
| Futuro | Fase posterior | Diferir |

---

## 4. Datos Base de Prueba

**Buyer Accounts:** Gaming Store Madrid, Tech Reseller Iberia, IT Solutions SMB,
Enterprise Gaming Procurement.

**Buyer Users:** un usuario operativo por buyer account.

**Buyer Groups / Segmentos:** tienda gaming local, reseller tecnológico, empresa
IT, cliente enterprise.

**Catálogo (categorías):** consolas de gaming, videojuegos, portátiles, monitores,
periféricos, networking, accesorios, bundles enterprise.

**Productos:** visibles para todos, restringidos por segmento, con pricing
diferenciado, con stock funcional suficiente, con stock funcional insuficiente, y
sin pricing (caso negativo, si aplica).

> Los datos definitivos dependen de `data-loading-strategy.md`.

---

## 5. Casos de Login y Acceso

| ID | Caso | Actor | Resultado esperado | Resultado negativo | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| FTC-LOGIN-001 | Buyer inicia sesión correctamente | Buyer | Accede a su contexto | Credenciales inválidas → mensaje seguro | Alta | No ejecutado |
| FTC-LOGIN-002 | No autenticado no accede a experiencia completa | Anónimo | Sin pricing/cart/checkout/historial | — | Alta | No ejecutado |
| FTC-LOGIN-003 | Sesión expirada | Buyer | "Tu sesión ha caducado…" y reautenticación | — | Alta | No ejecutado |
| FTC-LOGIN-004 | Usuario sin acceso al storefront | Usuario | Mensaje seguro, no técnico | — | Media | No ejecutado |

---

## 6. Casos de Home y Navegación

| ID | Caso | Actor | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| FTC-HOME-001 | Home carga para buyer autenticado | Buyer | Home con accesos clave | Alta | No ejecutado |
| FTC-HOME-002 | Navegación por categorías visible | Buyer | Categorías navegables | Alta | No ejecutado |
| FTC-HOME-003 | Acceso a carrito desde header | Buyer | Carrito accesible | Alta | No ejecutado |
| FTC-HOME-004 | Acceso a My Account / historial | Buyer | Acceso disponible si aplica | Media | Pendiente de validación |
| FTC-HOME-005 | Home responsive en mobile | Buyer | Usable en mobile | Alta | No ejecutado |

---

## 7. Casos de Catálogo y Categorías

| ID | Caso | Actor | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| FTC-CAT-001 | Categorías principales visibles | Buyer | Se ven las categorías | Alta | No ejecutado |
| FTC-CAT-002 | Categoría muestra productos asociados | Buyer | PLP con productos | Alta | No ejecutado |
| FTC-CAT-003 | Categoría sin productos | Buyer | Empty state claro | Media | No ejecutado |
| FTC-CAT-004 | Producto activo en categoría correcta | Buyer | Aparece en su categoría | Alta | No ejecutado |
| FTC-CAT-005 | Producto no activo/no comprable | Buyer | Se maneja correctamente si aplica | Media | Pendiente de validación |

---

## 8. Casos de Search

| ID | Caso | Actor | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| FTC-SEARCH-001 | Search encuentra producto visible | Buyer | Resultado relevante | Alta | No ejecutado |
| FTC-SEARCH-002 | Search sin resultados | Buyer | "No encontramos productos…" | Alta | No ejecutado |
| FTC-SEARCH-003 | Search no muestra producto restringido | Buyer | No aparece | Alta | No ejecutado |
| FTC-SEARCH-004 | Search funciona en mobile | Buyer | Usable en mobile | Media | No ejecutado |

---

## 9. Casos de PLP

| ID | Caso | Actor | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| FTC-PLP-001 | PLP muestra productos permitidos | Buyer | Solo permitidos | Alta | No ejecutado |
| FTC-PLP-002 | PLP muestra información mínima | Buyer | Nombre, imagen, SKU (si aplica), precio, disponibilidad, acceso a detalle | Alta | No ejecutado |
| FTC-PLP-003 | PLP respeta visibilidad por buyer | Buyer | Sin restringidos | Alta | No ejecutado |
| FTC-PLP-004 | PLP muestra pricing aplicable | Buyer | Precio del segmento | Alta | No ejecutado |
| FTC-PLP-005 | PLP maneja empty state | Buyer | Mensaje claro | Media | No ejecutado |
| FTC-PLP-006 | PLP maneja error state | Buyer | "No pudimos cargar…" | Media | No ejecutado |
| FTC-PLP-007 | PLP funciona en mobile | Buyer | Usable en mobile | Alta | No ejecutado |
| FTC-PLP-008 | Add to cart desde PLP | Buyer | Se añade si el estándar lo permite | Media | Pendiente de validación |

---

## 10. Casos de PDP

| ID | Caso | Actor | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| FTC-PDP-001 | PDP muestra producto visible | Buyer | Detalle correcto | Alta | No ejecutado |
| FTC-PDP-002 | PDP muestra información mínima | Buyer | Nombre, SKU, descripción, categoría, precio, disponibilidad, cantidad | Alta | No ejecutado |
| FTC-PDP-003 | Agregar producto permitido al carrito | Buyer | Producto añadido | Alta | No ejecutado |
| FTC-PDP-004 | PDP maneja producto no visible | Buyer | "Este producto no está disponible para tu cuenta." | Alta | No ejecutado |
| FTC-PDP-005 | PDP maneja producto sin pricing | Buyer | "El precio no está disponible…" | Media | No ejecutado |
| FTC-PDP-006 | PDP maneja stock insuficiente | Buyer | "Stock insuficiente…" | Alta | No ejecutado |
| FTC-PDP-007 | PDP maneja cantidad inválida | Buyer | "Introduce una cantidad válida." | Alta | No ejecutado |
| FTC-PDP-008 | PDP funciona en mobile | Buyer | Usable en mobile | Alta | No ejecutado |

---

## 11. Casos de Pricing

| ID | Caso | Actor | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| FTC-PRI-001 | Precio aplicable en PLP | Buyer | Precio del segmento | Alta | No ejecutado |
| FTC-PRI-002 | Precio aplicable en PDP | Buyer | Precio del segmento | Alta | No ejecutado |
| FTC-PRI-003 | Consistencia PLP↔PDP | Buyer | Mismo precio | Alta | No ejecutado |
| FTC-PRI-004 | Consistencia PDP↔cart | Buyer | Mismo precio | Alta | No ejecutado |
| FTC-PRI-005 | Consistencia cart↔checkout | Buyer | Mismo precio | Alta | No ejecutado |
| FTC-PRI-006 | No ve pricing de otro segmento | Buyer | No expuesto | Alta | No ejecutado |
| FTC-PRI-007 | Producto sin pricing | Buyer | Mensaje funcional | Media | No ejecutado |
| FTC-PRI-008 | Pricing actualizado en cart/checkout | Buyer | "El precio… se ha actualizado." | Media | Pendiente de validación |

---

## 12. Casos de Visibilidad / Entitlements

| ID | Caso | Actor | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| FTC-VIS-001 | Producto visible para autorizado | Buyer | Aparece | Alta | No ejecutado |
| FTC-VIS-002 | Restringido no aparece en PLP | Buyer | Oculto | Alta | No ejecutado |
| FTC-VIS-003 | Restringido no aparece en search | Buyer | Oculto | Alta | No ejecutado |
| FTC-VIS-004 | URL directa a PDP restringida | Buyer | Acceso seguro/bloqueado | Alta | Pendiente de validación |
| FTC-VIS-005 | Restringido no se agrega al carrito | Buyer | Bloqueado | Alta | No ejecutado |
| FTC-VIS-006 | Checkout bloquea no autorizado | Buyer | No confirma | Alta | No ejecutado |
| FTC-VIS-007 | Reorder revalida visibilidad | Buyer | Excluye/avisa | Alta | No ejecutado |
| FTC-VIS-008 | No ve catálogo de otro segmento | Buyer | Aislamiento | Alta | No ejecutado |

---

## 13. Casos de Cart

| ID | Caso | Actor | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| FTC-CART-001 | Agregar producto permitido | Buyer | "Producto añadido al carrito." | Alta | No ejecutado |
| FTC-CART-002 | Modificar cantidad | Buyer | Subtotal recalculado | Alta | No ejecutado |
| FTC-CART-003 | Eliminar producto | Buyer | Línea eliminada | Alta | No ejecutado |
| FTC-CART-004 | Subtotal y total funcional | Buyer | Importes correctos | Alta | No ejecutado |
| FTC-CART-005 | Carrito vacío | Buyer | "Tu carrito está vacío." | Media | No ejecutado |
| FTC-CART-006 | Producto sin stock suficiente | Buyer | Aviso de stock | Alta | No ejecutado |
| FTC-CART-007 | Producto ya no visible | Buyer | Aviso y bloqueo de línea | Media | No ejecutado |
| FTC-CART-008 | Producto con pricing actualizado | Buyer | Aviso de cambio | Media | No ejecutado |
| FTC-CART-009 | Cantidad inválida | Buyer | "Introduce una cantidad válida." | Alta | No ejecutado |
| FTC-CART-010 | Error al cargar carrito | Buyer | "No pudimos cargar tu carrito…" | Media | No ejecutado |
| FTC-CART-011 | Carrito funciona en mobile | Buyer | Usable en mobile | Alta | No ejecutado |

---

## 14. Casos de Checkout

| ID | Caso | Actor | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| FTC-CHK-001 | Checkout inicia con cart válido | Buyer | Acceso al checkout | Alta | No ejecutado |
| FTC-CHK-002 | Muestra resumen del pedido | Buyer | Resumen correcto | Alta | No ejecutado |
| FTC-CHK-003 | Muestra total funcional | Buyer | Total correcto | Alta | No ejecutado |
| FTC-CHK-004 | Confirma pedido cuando aplica | Buyer | "Pedido confirmado." | Alta | No ejecutado |
| FTC-CHK-005 | Diferencia confirmado vs pendiente | Buyer | Estados distintos | Alta | No ejecutado |
| FTC-CHK-006 | Bloquea producto no autorizado | Buyer | No confirma | Alta | No ejecutado |
| FTC-CHK-007 | Maneja pricing no vigente | Buyer | Aviso y revalidación | Alta | No ejecutado |
| FTC-CHK-008 | Maneja stock insuficiente | Buyer | Aviso y bloqueo | Alta | No ejecutado |
| FTC-CHK-009 | Maneja crédito bloqueado/excedido | Buyer | Mensaje funcional | Media | Pendiente de validación |
| FTC-CHK-010 | Maneja aprobación por importe | Buyer | Solicitud pendiente | Media | Pendiente de validación |
| FTC-CHK-011 | Sesión expirada durante checkout | Buyer | Reautenticación | Media | No ejecutado |
| FTC-CHK-012 | Error técnico no expone detalles | Buyer | Mensaje seguro | Alta | No ejecutado |

> Pagos reales, tax real y shipping real están **fuera del MVP**.

---

## 15. Casos de Approval por Importe

| ID | Caso | Actor | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| FTC-APP-001 | Pedido bajo umbral | Buyer | Confirmación directa | Media | Pendiente de validación |
| FTC-APP-002 | Pedido sobre umbral | Buyer | Requiere aprobación | Media | Pendiente de validación |
| FTC-APP-003 | Solicitud pendiente se comunica | Buyer | Mensaje claro | Media | Pendiente de validación |
| FTC-APP-004 | Pendiente ≠ confirmado | Buyer | Estados distintos | Alta | Pendiente de validación |
| FTC-APP-005 | Umbral no configurado | — | Documentar como gap (`DEC-008`) | Media | Pendiente de validación |

---

## 16. Casos de Credit Validation

| ID | Caso | Actor | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| FTC-CRE-001 | Crédito válido permite continuar | Buyer | Continúa | Media | Pendiente de validación |
| FTC-CRE-002 | Crédito bloqueado | Buyer | Impide/condiciona | Media | Pendiente de validación |
| FTC-CRE-003 | Crédito excedido | Buyer | Impide/condiciona | Media | Pendiente de validación |
| FTC-CRE-004 | Crédito no disponible | Buyer | Mensaje funcional | Media | Pendiente de validación |
| FTC-CRE-005 | Crédito vía integración futura | — | Documentado | Baja | Futuro |

---

## 17. Casos de Stock Funcional

| ID | Caso | Actor | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| FTC-STK-001 | Stock suficiente | Buyer | Permite comprar | Alta | No ejecutado |
| FTC-STK-002 | Stock insuficiente | Buyer | "Stock insuficiente…" | Alta | No ejecutado |
| FTC-STK-003 | Cantidad > stock | Buyer | Bloquea/condiciona | Alta | No ejecutado |
| FTC-STK-004 | Stock no disponible | Buyer | Se maneja | Media | No ejecutado |
| FTC-STK-005 | ETA futura | Buyer | Solo si disponible | Baja | Futuro |
| FTC-STK-006 | Backorder | — | Fuera/pendiente | Baja | Futuro |

---

## 18. Casos de Orders / Historial

| ID | Caso | Actor | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| FTC-ORD-001 | Buyer ve historial propio | Buyer | Sus pedidos | Alta | Pendiente de validación |
| FTC-ORD-002 | Buyer sin pedidos | Buyer | "Todavía no tienes pedidos." | Media | No ejecutado |
| FTC-ORD-003 | No ve pedidos de otra cuenta | Buyer | Aislamiento | Alta | No ejecutado |
| FTC-ORD-004 | Detalle de pedido | Buyer | Información suficiente | Alta | Pendiente de validación |
| FTC-ORD-005 | Pedido confirmado | Buyer | Estado correcto | Alta | No ejecutado |
| FTC-ORD-006 | Pedido pendiente | Buyer | Estado correcto si aplica | Media | Pendiente de validación |
| FTC-ORD-007 | Error al cargar historial | Buyer | "No pudimos cargar tu historial…" | Media | No ejecutado |

---

## 19. Casos de Reorder

| ID | Caso | Actor | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| FTC-REO-001 | Reorder desde pedido válido | Buyer | Inicia reorder | Alta | Pendiente de validación |
| FTC-REO-002 | Agrega productos actuales al carrito | Buyer | Productos válidos al cart | Alta | Pendiente de validación |
| FTC-REO-003 | Revalida pricing actual | Buyer | Precio actualizado | Alta | No ejecutado |
| FTC-REO-004 | Revalida visibilidad actual | Buyer | Excluye no visibles | Alta | No ejecutado |
| FTC-REO-005 | Producto ya no disponible | Buyer | Aviso claro | Media | No ejecutado |
| FTC-REO-006 | Reorder parcial | Buyer | "Algunos productos no se pudieron añadir." | Alta | No ejecutado |
| FTC-REO-007 | Reorder con stock insuficiente | Buyer | Aviso de stock | Media | No ejecutado |
| FTC-REO-008 | Reorder en mobile | Buyer | Usable si aplica | Media | No ejecutado |

---

## 20. Casos de Estados UX Transversales

| ID | Caso | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- |
| FTC-UX-001 | Loading state visible | Indicador de carga | Alta | No ejecutado |
| FTC-UX-002 | Empty state claro | Mensaje + acción | Alta | No ejecutado |
| FTC-UX-003 | Error state no técnico | Mensaje seguro | Alta | No ejecutado |
| FTC-UX-004 | Pending state diferenciado | Distinto de éxito | Alta | No ejecutado |
| FTC-UX-005 | Restricted state seguro | No expone reglas | Alta | No ejecutado |
| FTC-UX-006 | Validation state accionable | Indica cómo corregir | Alta | No ejecutado |

---

## 21. Casos Mobile

| ID | Caso | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- |
| FTC-MOB-001 | Login mobile | Usable | Alta | No ejecutado |
| FTC-MOB-002 | Home mobile | Usable | Alta | No ejecutado |
| FTC-MOB-003 | PLP mobile | Usable | Alta | No ejecutado |
| FTC-MOB-004 | PDP mobile | Usable | Alta | No ejecutado |
| FTC-MOB-005 | Cart mobile | Usable | Alta | No ejecutado |
| FTC-MOB-006 | Checkout mobile | Usable | Alta | No ejecutado |
| FTC-MOB-007 | Historial mobile | Usable | Media | No ejecutado |
| FTC-MOB-008 | Reorder mobile | Usable si aplica | Media | No ejecutado |

---

## 22. Matriz de Priorización

Resumen por área (el detalle por caso, con su prioridad y estado, está en las
secciones 5–21).

| Área | Prioridad global | MVP/Futuro/Pendiente | Dependencia | Estado global |
| --- | --- | --- | --- | --- |
| Login y acceso | Alta | MVP | Buyer user activo | No ejecutado |
| Home y navegación | Alta | MVP | Storefront | No ejecutado |
| Catálogo y categorías | Alta | MVP | Datos de catálogo | No ejecutado |
| Search | Alta | MVP | Catálogo visible | No ejecutado |
| PLP | Alta | MVP | Catálogo, pricing | No ejecutado |
| PDP | Alta | MVP | Pricing, stock | No ejecutado |
| Pricing | Alta | MVP | Buyer Groups/pricing | No ejecutado |
| Visibilidad | Alta | MVP/Pendiente | Entitlements | Pendiente de validación |
| Cart | Alta | MVP | Pricing, stock | No ejecutado |
| Checkout | Alta | MVP/Pendiente | Cart, reglas | No ejecutado |
| Approval | Media | Pendiente | Umbral (`DEC-008`) | Pendiente de validación |
| Credit | Media | Pendiente | Reglas/integración | Pendiente de validación |
| Stock | Alta | MVP/Futuro | Dato de stock | No ejecutado |
| Orders/Historial | Alta | MVP/Pendiente | Capacidad estándar | Pendiente de validación |
| Reorder | Alta | MVP/Pendiente | Historial | Pendiente de validación |
| UX/estados | Alta | MVP | Transversal | No ejecutado |
| Mobile | Alta | MVP | Storefront | No ejecutado |

---

## 23. Casos Fuera del MVP

| Caso | Motivo de exclusión | Fase futura posible | Riesgo si se adelanta |
| --- | --- | --- | --- |
| Payment real | Fuera del foco del MVP | Futuro posible | Complejidad/cumplimiento |
| Tax real | Complejidad fiscal | Futuro posible | Esfuerzo desviado |
| Shipping real | Complejidad logística | Futuro posible | Esfuerzo desviado |
| ERP real | Dependencia externa | Tras simulación | Acoplamiento prematuro |
| OMS avanzado | Historial básico suficiente | Futuro posible | Sobre-ingeniería |
| Promociones complejas | No aporta a la base B2B | Futuro posible | Complejidad |
| Multi-idioma | Opera en España | Futuro (expansión) | Esfuerzo desviado |
| Multi-divisa | Un solo mercado | Futuro (expansión) | Complejidad |
| Marketplace | Modelo distinto | No incluido | Cambio de modelo |
| Facturas reales | Fuera del MVP | Futuro | Acoplamiento |
| Motor externo real de pricing | No justificado | Futuro si se justifica | Acoplamiento |

---

## 24. Registro de Ejecución

```markdown
## Ejecución de Caso

**ID:**
**Fecha:**
**Ejecutado por:**
**Buyer usado:**
**Datos usados:**
**Resultado:** Pass / Fail / Blocked / Pending
**Resultado real:**
**Evidencia:**
**Defecto o gap:**
**Documento a actualizar:**
```

---

## 25. Gestión de Gaps Detectados

Un gap funcional debe registrarse con: **ID**, **caso afectado**, **descripción**,
**área**, **impacto**, **alternativa estándar evaluada**, **posible solución**,
**¿requiere configuración?**, **¿requiere Flow?**, **¿requiere LWC?**, **¿requiere
Apex?**, **¿requiere ADR?** y **estado**.

Los gaps se reflejan en `configuration-decisions.md` y, si implican una decisión
relevante, en `adr/`.

---

## 26. Relación con Otros Documentos

- `docs/testing/test-strategy.md` define la **estrategia general**.
- Este documento define los **casos funcionales**.
- `docs/testing/security-test-cases.md` *(previsto)* profundizará en **seguridad**.
- `docs/testing/integration-test-cases.md` *(previsto)* profundizará en
  **integración futura**.
- `docs/salesforce/data-loading-strategy.md` define los **datos necesarios**.
- `docs/salesforce/security-model.md` define la **seguridad a validar**.
- `docs/ux/empty-error-loading-states.md` define los **estados UX** y mensajes.
- `docs/development/error-handling-guidelines.md` define el **manejo de errores**.
- `docs/salesforce/configuration-decisions.md` se **actualiza** ante gaps.
- `adr/` se usa si una solución implica una **decisión relevante**.
