# Casos de Prueba de Seguridad - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define un **catálogo de casos de prueba de seguridad** para validar
que cada buyer del storefront B2B de `LvlUp-Wholesale-B2B` solo accede a la
información, productos, pricing, carrito, checkout, historial y reorder que le
corresponden.

Sirve como base para: validar buyer access y buyer account isolation, validar la
visibilidad de catálogo, validar el pricing por cuenta/Buyer Group, validar el
acceso seguro a PLP/PDP/cart/checkout/historial/reorder, detectar gaps de
seguridad, alimentar la regresión y los ADRs, y guiar a futuros agentes QA.

Este documento **no define una estrategia productiva completa de security testing
enterprise**. La prosa va en español; IDs, actores, estados y términos Salesforce
en inglés.

> **Nota de formato:** plantilla completa en la §3 (con ejemplo) y el resto en
> **tablas compactas** por área. **Estado inicial:** todos en **No ejecutado**.

---

## 2. Principios de Testing de Seguridad

- Probar con **buyer users**, no solo con admin.
- Validar **mínimo privilegio**.
- Validar **acceso por cuenta**.
- Validar **acceso por Buyer Group / segmento**.
- Validar que los **productos restringidos no se expongan**.
- Validar que el **pricing no se mezcle** entre segmentos.
- Validar que la **URL directa no salte** restricciones.
- Validar que **cart, checkout y reorder revaliden** permisos.
- Validar **errores seguros y no técnicos**.
- **Registrar gaps** antes de proponer customización.
- Crear **ADR** si se requiere lógica custom de seguridad.

---

## 3. Convención de Casos de Prueba

Plantilla: **ID**, **Nombre**, **Área**, **Prioridad**, **Estado**, **Actor**,
**Buyer account**, **Buyer Group / segmento**, **Precondiciones**, **Datos
requeridos**, **Pasos conceptuales**, **Resultado esperado**, **Resultado no
permitido**, **Riesgo cubierto**, **Documentos relacionados**, **Notas / gaps**.

Prefijos: `STC-AUTH`, `STC-ACCOUNT`, `STC-BG`, `STC-CATALOG`, `STC-SEARCH`,
`STC-PLP`, `STC-PDP`, `STC-PRICE`, `STC-CART`, `STC-CHK`, `STC-ORDER`,
`STC-REORDER`, `STC-PERM`, `STC-ERROR`, `STC-INT`, `STC-MOB`.

**Ejemplo en ficha completa:**

- **ID:** `STC-ACCOUNT-002`
- **Nombre:** Buyer no ve datos de otra buyer account
- **Área:** Account isolation
- **Prioridad:** Alta
- **Estado:** No ejecutado
- **Actor:** Buyer operativo
- **Buyer account:** Gaming Store Madrid
- **Buyer Group / segmento:** Tienda gaming local
- **Precondiciones:** Existe otra cuenta (Tech Reseller Iberia) con datos
- **Datos requeridos:** Dos buyer accounts con datos distintos
- **Pasos conceptuales:** Autenticarse como Gaming Store Madrid → intentar acceder
  a datos de otra cuenta (navegación/URL)
- **Resultado esperado:** Solo ve datos de su cuenta
- **Resultado no permitido:** Ver datos de Tech Reseller Iberia
- **Riesgo cubierto:** Account isolation / data exposure
- **Documentos relacionados:** `security-model.md`, `security-architecture.md`
- **Notas / gaps:** Pendiente de validación en la org

---

## 4. Estados de Caso de Seguridad

| Estado | Significado | Acción siguiente |
| --- | --- | --- |
| No ejecutado | Aún no probado | Programar ejecución |
| Ejecutado exitosamente | Pasó | Registrar evidencia |
| Fallido | No pasó | Registrar defecto de seguridad |
| Bloqueado | No se puede ejecutar | Desbloquear dependencia |
| Pendiente de datos | Faltan datos | Cargar datos |
| Pendiente de configuración | Falta configuración | Configurar |
| Pendiente de validación en org | Capacidad no verificada | Validar en la org |
| Requiere ADR | Implica decisión de seguridad | Crear ADR |
| Fuera del MVP | No aplica al MVP | Diferir |
| Futuro | Fase posterior | Diferir |

---

## 5. Datos Base para Pruebas de Seguridad

**Buyer Accounts:** Gaming Store Madrid, Tech Reseller Iberia, IT Solutions SMB,
Enterprise Gaming Procurement.

**Buyer Groups / Segmentos:** tienda gaming local, reseller tecnológico, empresa
IT, cliente enterprise.

**Productos:** visible para todos; visible solo para reseller; visible solo para
enterprise; bundle enterprise restringido; con pricing diferenciado; sin pricing
(caso negativo, si aplica).

**Orders:** pedido de Gaming Store Madrid, de Tech Reseller Iberia, de Enterprise
Gaming Procurement.

> Los datos definitivos dependen de `data-loading-strategy.md`.

---

## 6. Casos de Autenticación

| ID | Caso | Resultado esperado | Resultado no permitido | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| STC-AUTH-001 | Buyer autenticado accede al storefront | Acceso a su contexto | Acceso sin autenticar | Authentication | Alta | No ejecutado |
| STC-AUTH-002 | No autenticado no accede a áreas protegidas | Sin pricing/cart/checkout/historial | Acceso anónimo a datos | Access control | Alta | No ejecutado |
| STC-AUTH-003 | Sesión expirada bloquea acciones protegidas | Reautenticación requerida | Comprar con sesión caducada | Session handling | Alta | No ejecutado |
| STC-AUTH-004 | Error de login no expone detalles técnicos | "Email o contraseña incorrectos." | Revelar qué campo falla | Data exposure | Alta | No ejecutado |

---

## 7. Casos de Buyer Account Isolation

| ID | Caso | Resultado esperado | Resultado no permitido | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| STC-ACCOUNT-001 | Solo accede a datos de su cuenta | Datos propios | Datos ajenos | Account isolation | Alta | No ejecutado |
| STC-ACCOUNT-002 | No ve datos de otra cuenta | Aislamiento | Ver otra cuenta | Data exposure | Alta | No ejecutado |
| STC-ACCOUNT-003 | No accede al cart de otra cuenta | Solo su cart | Cart ajeno | Account isolation | Alta | No ejecutado |
| STC-ACCOUNT-004 | No accede al checkout de otra cuenta | Solo su checkout | Checkout ajeno | Account isolation | Alta | No ejecutado |
| STC-ACCOUNT-005 | No accede a historial de otra cuenta | Solo su historial | Historial ajeno | Data exposure | Alta | No ejecutado |
| STC-ACCOUNT-006 | No accede a detalle de pedido de otra cuenta | Solo sus pedidos | Pedido ajeno | Data exposure | Alta | Pendiente de validación |

---

## 8. Casos de Buyer Groups y Segmentos

| ID | Caso | Resultado esperado | Resultado no permitido | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| STC-BG-001 | Buyer Group afecta catálogo esperado | Catálogo de su segmento | Catálogo de otro segmento | Catalog visibility | Alta | Pendiente de validación |
| STC-BG-002 | Buyer Group afecta pricing esperado | Pricing de su segmento | Pricing de otro segmento | Pricing isolation | Alta | Pendiente de validación |
| STC-BG-003 | No hereda visibilidad de otro Buyer Group | Solo lo suyo | Visibilidad ajena | Catalog visibility | Alta | Pendiente de validación |
| STC-BG-004 | No hereda pricing de otro Buyer Group | Solo lo suyo | Pricing ajeno | Pricing isolation | Alta | Pendiente de validación |
| STC-BG-005 | Buyer sin Buyer Group esperado | Gap seguro / acceso mínimo | Acceso amplio por defecto | Least privilege | Media | Pendiente de validación |

---

## 9. Casos de Catálogo Restringido

| ID | Caso | Resultado esperado | Resultado no permitido | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| STC-CATALOG-001 | Producto común aparece para todos | Visible | — | Catalog visibility | Alta | No ejecutado |
| STC-CATALOG-002 | Restringido no aparece para no autorizado | Oculto | Visible | Catalog visibility | Alta | No ejecutado |
| STC-CATALOG-003 | Bundle enterprise solo para enterprise | Visible solo enterprise | Visible a otros | Catalog visibility | Alta | No ejecutado |
| STC-CATALOG-004 | Catálogo reseller no aparece a gaming local | Oculto si no corresponde | Visible | Catalog visibility | Media | No ejecutado |
| STC-CATALOG-005 | Cambio de visibilidad se refleja | Catálogo actualizado | Producto fantasma | Catalog visibility | Media | Pendiente de validación |

---

## 10. Casos de Search Seguro

| ID | Caso | Resultado esperado | Resultado no permitido | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| STC-SEARCH-001 | Encuentra producto permitido | Resultado relevante | — | Catalog visibility | Alta | No ejecutado |
| STC-SEARCH-002 | No devuelve producto restringido | Oculto | Aparece | Catalog visibility | Alta | No ejecutado |
| STC-SEARCH-003 | No filtra solo visualmente | Filtrado en backend | Filtrado solo en UI | Backend enforcement | Alta | Pendiente de validación |
| STC-SEARCH-004 | Sin resultados no revela existencia restringida | Empty neutro | Insinuar producto restringido | Information disclosure | Media | No ejecutado |
| STC-SEARCH-005 | Search mobile mantiene restricciones | Restricción mantenida | Fuga en mobile | Catalog visibility | Media | No ejecutado |

---

## 11. Casos de PLP Seguro

| ID | Caso | Resultado esperado | Resultado no permitido | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| STC-PLP-001 | Solo productos permitidos | Permitidos | Restringidos | Catalog visibility | Alta | No ejecutado |
| STC-PLP-002 | No muestra producto restringido | Oculto | Visible | Catalog visibility | Alta | No ejecutado |
| STC-PLP-003 | No muestra pricing no autorizado | Pricing propio | Pricing ajeno | Pricing isolation | Alta | No ejecutado |
| STC-PLP-004 | Add to cart respeta visibilidad | Solo permitidos | Añadir restringido | Backend enforcement | Media | Pendiente de validación |
| STC-PLP-005 | Empty state no revela restringidos | Empty neutro | Insinuar restringidos | Information disclosure | Media | No ejecutado |
| STC-PLP-006 | PLP mobile mantiene restricciones | Restricción mantenida | Fuga en mobile | Catalog visibility | Media | No ejecutado |

---

## 12. Casos de PDP Seguro

| ID | Caso | Resultado esperado | Resultado no permitido | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| STC-PDP-001 | PDP de producto permitido carga | Detalle correcto | — | Access control | Alta | No ejecutado |
| STC-PDP-002 | PDP restringida por URL directa | Bloqueo/manejo seguro | Acceso por URL | Direct URL access | Alta | Pendiente de validación |
| STC-PDP-003 | PDP restringida no revela pricing | Sin pricing | Pricing expuesto | Pricing isolation | Alta | Pendiente de validación |
| STC-PDP-004 | PDP restringida no permite add to cart | Bloqueado | Añadir restringido | Backend enforcement | Alta | Pendiente de validación |
| STC-PDP-005 | Producto no disponible no expone lógica | Mensaje neutro | Revelar regla interna | Information disclosure | Media | No ejecutado |
| STC-PDP-006 | PDP mobile mantiene restricciones | Restricción mantenida | Fuga en mobile | Access control | Media | No ejecutado |

> El comportamiento exacto de **URL directa** debe validarse en la org.

---

## 13. Casos de Pricing Seguro

| ID | Caso | Resultado esperado | Resultado no permitido | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| STC-PRICE-001 | Ve solo pricing aplicable | Pricing propio | Pricing ajeno | Pricing isolation | Alta | No ejecutado |
| STC-PRICE-002 | No ve precio de otro segmento | Aislamiento | Precio ajeno | Pricing isolation | Alta | No ejecutado |
| STC-PRICE-003 | Pricing consistente PLP/PDP/cart/checkout | Mismo precio | Inconsistencia explotable | Pricing integrity | Alta | No ejecutado |
| STC-PRICE-004 | Producto sin pricing | Mensaje neutro | Información indebida | Information disclosure | Media | No ejecutado |
| STC-PRICE-005 | Pricing actualizado sin exponer lógica | Aviso funcional | Revelar lógica interna | Information disclosure | Media | No ejecutado |
| STC-PRICE-006 | Reorder revalida pricing actual | Precio actual | Precio obsoleto explotable | Pricing integrity | Alta | No ejecutado |

---

## 14. Casos de Cart Seguro

| ID | Caso | Resultado esperado | Resultado no permitido | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| STC-CART-001 | Agregar producto permitido | Se añade | — | Access control | Alta | No ejecutado |
| STC-CART-002 | No agregar producto restringido | Bloqueado | Añadir restringido | Backend enforcement | Alta | No ejecutado |
| STC-CART-003 | Revalida visibilidad actual | Revalidación | Mantener no visible | Backend enforcement | Alta | No ejecutado |
| STC-CART-004 | Revalida pricing actual | Pricing actual | Precio manipulado | Pricing integrity | Alta | No ejecutado |
| STC-CART-005 | No permite manipular precio desde UI | Precio del backend | Precio alterado en cliente | Tamper protection | Alta | No ejecutado |
| STC-CART-006 | Maneja producto que dejó de ser visible | Aviso/bloqueo | Comprar no visible | Backend enforcement | Media | No ejecutado |
| STC-CART-007 | No expone datos de otra cuenta | Aislamiento | Datos ajenos | Account isolation | Alta | No ejecutado |

---

## 15. Casos de Checkout Seguro

| ID | Caso | Resultado esperado | Resultado no permitido | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| STC-CHK-001 | Confirma solo productos autorizados | Solo permitidos | Confirmar restringido | Backend enforcement | Alta | No ejecutado |
| STC-CHK-002 | Bloquea producto restringido | Bloqueado | Confirmar restringido | Backend enforcement | Alta | No ejecutado |
| STC-CHK-003 | Revalida pricing vigente | Pricing actual | Precio obsoleto/alterado | Pricing integrity | Alta | No ejecutado |
| STC-CHK-004 | Revalida buyer account | Su cuenta | Otra cuenta | Account isolation | Alta | No ejecutado |
| STC-CHK-005 | No confirma con datos de otra cuenta | Bloqueado | Confirmar ajeno | Account isolation | Alta | No ejecutado |
| STC-CHK-006 | Crédito bloqueado sin revelar lógica | Mensaje funcional | Revelar regla/dato | Information disclosure | Media | Pendiente de validación |
| STC-CHK-007 | Approval required ≠ confirmado | Estados distintos | Confundir estados | State integrity | Alta | Pendiente de validación |
| STC-CHK-008 | Error técnico no expone stack trace | Mensaje seguro | Stack trace | Data exposure | Alta | No ejecutado |

> Pagos reales, tax real y shipping real están **fuera del MVP**.

---

## 16. Casos de Orders e Historial Seguro

| ID | Caso | Resultado esperado | Resultado no permitido | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| STC-ORDER-001 | Ve solo orders de su cuenta | Sus orders | Orders ajenos | Account isolation | Alta | No ejecutado |
| STC-ORDER-002 | No ve orders de otra cuenta | Aislamiento | Order ajeno | Data exposure | Alta | No ejecutado |
| STC-ORDER-003 | URL directa a order ajeno | Bloqueo/manejo seguro | Acceso por URL | Direct URL access | Alta | Pendiente de validación |
| STC-ORDER-004 | Detalle no expone datos de otra cuenta | Solo sus datos | Datos ajenos | Data exposure | Alta | No ejecutado |
| STC-ORDER-005 | Buyer sin orders ve empty seguro | "Todavía no tienes pedidos." | Insinuar datos ajenos | Information disclosure | Media | No ejecutado |
| STC-ORDER-006 | Error en historial no expone detalles | Mensaje seguro | Stack trace | Data exposure | Media | No ejecutado |

---

## 17. Casos de Reorder Seguro

| ID | Caso | Resultado esperado | Resultado no permitido | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| STC-REORDER-001 | Reorder desde order propio | Permitido | — | Access control | Alta | Pendiente de validación |
| STC-REORDER-002 | No reorder de order de otra cuenta | Bloqueado | Reorder ajeno | Account isolation | Alta | No ejecutado |
| STC-REORDER-003 | Revalida visibilidad actual | Excluye no visibles | Incluir restringido | Backend enforcement | Alta | No ejecutado |
| STC-REORDER-004 | Revalida pricing actual | Pricing actual | Precio obsoleto | Pricing integrity | Alta | No ejecutado |
| STC-REORDER-005 | Maneja producto ya no autorizado | Excluye/avisa | Comprar no autorizado | Backend enforcement | Alta | No ejecutado |
| STC-REORDER-006 | Parcial no incluye restringidos | Solo válidos | Incluir restringido | Catalog visibility | Alta | No ejecutado |
| STC-REORDER-007 | No salta reglas de stock funcional | Respeta stock | Saltar stock | Business rule integrity | Media | No ejecutado |

---

## 18. Casos de Permission Sets / Acceso

| ID | Caso | Resultado esperado | Resultado no permitido | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| STC-PERM-001 | Buyer con permisos mínimos para navegar | Navega lo permitido | — | Least privilege | Alta | Pendiente de validación |
| STC-PERM-002 | Buyer sin permisos administrativos | Sin admin | Acceso admin | Least privilege | Alta | Pendiente de validación |
| STC-PERM-003 | Buyer no ve objetos/datos internos innecesarios | Solo lo necesario | Datos internos | Least privilege | Alta | Pendiente de validación |
| STC-PERM-004 | Admin configura sin permisos buyer | Separación de roles | Mezcla de roles | Separation of duties | Media | Pendiente de validación |
| STC-PERM-005 | Permisos excesivos se detectan como gap | Gap registrado | Permisos amplios sin revisión | Least privilege | Alta | Pendiente de validación |

> No se inventan Permission Sets definitivos; pendiente de validación en la org.

---

## 19. Casos de Errores Seguros

| ID | Caso | Resultado esperado | Resultado no permitido | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| STC-ERROR-001 | Producto restringido no revela lógica | Mensaje neutro | Revelar regla | Information disclosure | Alta | No ejecutado |
| STC-ERROR-002 | Error de pricing no revela otro segmento | Mensaje neutro | Pricing ajeno | Pricing isolation | Alta | No ejecutado |
| STC-ERROR-003 | Error de checkout no revela stack trace | Mensaje seguro | Stack trace | Data exposure | Alta | No ejecutado |
| STC-ERROR-004 | Error de integración no revela endpoint/token | Mensaje neutro | Endpoint/token | Secret exposure | Alta | Futuro |
| STC-ERROR-005 | Error de permisos no revela configuración | Mensaje neutro | Config interna | Information disclosure | Media | No ejecutado |
| STC-ERROR-006 | Error técnico muestra mensaje funcional | Mensaje seguro | Detalle técnico | Data exposure | Alta | No ejecutado |

---

## 20. Casos de Integración Futura y Seguridad

*(Futuro / pendiente; coherente con `integration-guidelines.md` y
`logging-guidelines.md`.)*

| ID | Caso | Resultado esperado | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| STC-INT-001 | Callout no consulta datos de otra cuenta | Solo datos propios | Account isolation | Media | Futuro |
| STC-INT-002 | Named Credential evita secrets hardcoded | Sin secretos en código | Secret exposure | Alta | Futuro |
| STC-INT-003 | Error de integración no expone detalles | Mensaje neutro | Information disclosure | Media | Futuro |
| STC-INT-004 | Response externa no permite pricing no autorizado | Pricing validado | Pricing integrity | Alta | Futuro |
| STC-INT-005 | Logs de integración sin datos sensibles | Logs sanitizados | Data exposure | Media | Futuro |

---

## 21. Casos Mobile de Seguridad

| ID | Caso | Resultado esperado | Riesgo cubierto | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| STC-MOB-001 | PLP mobile mantiene visibilidad | Restricción mantenida | Catalog visibility | Alta | No ejecutado |
| STC-MOB-002 | PDP mobile mantiene restricción | Restricción mantenida | Access control | Alta | No ejecutado |
| STC-MOB-003 | Cart mobile no expone datos indebidos | Aislamiento | Data exposure | Alta | No ejecutado |
| STC-MOB-004 | Checkout mobile mantiene validaciones | Validaciones activas | Backend enforcement | Alta | No ejecutado |
| STC-MOB-005 | Mensajes mobile no exponen detalles | Mensaje seguro | Data exposure | Media | No ejecutado |

---

## 22. Matriz de Priorización

Resumen por área (el detalle por caso está en las secciones 6–21).

| Área | Riesgo cubierto | Prioridad | MVP/Futuro/Pendiente | Dependencia | Estado |
| --- | --- | --- | --- | --- | --- |
| Autenticación | Access control | Alta | MVP | Login/sesión | No ejecutado |
| Account isolation | Data exposure | Alta | MVP | Multi-cuenta | No ejecutado |
| Buyer Groups | Catalog/pricing isolation | Alta | Pendiente | Buyer Groups | Pendiente de validación |
| Catálogo restringido | Catalog visibility | Alta | MVP | Entitlements | No ejecutado |
| Search | Catalog visibility | Alta | MVP/Pendiente | Búsqueda estándar | No ejecutado |
| PLP | Catalog/pricing | Alta | MVP | Visibilidad/pricing | No ejecutado |
| PDP | Direct URL/pricing | Alta | Pendiente | Control de acceso | Pendiente de validación |
| Pricing | Pricing isolation/integrity | Alta | MVP | Pricing por segmento | No ejecutado |
| Cart | Tamper/backend enforcement | Alta | MVP | Revalidación | No ejecutado |
| Checkout | Account/pricing/state | Alta | MVP | Revalidación | No ejecutado |
| Orders/Historial | Data exposure | Alta | MVP/Pendiente | Acceso por cuenta | No ejecutado |
| Reorder | Account/backend enforcement | Alta | MVP/Pendiente | Historial | No ejecutado |
| Permission Sets | Least privilege | Alta | Pendiente | Permisos | Pendiente de validación |
| Errores | Information disclosure | Alta | MVP | Manejo de errores | No ejecutado |
| Integración | Secret/data exposure | Media | Futuro | Callouts | Futuro |
| Mobile | Catalog/access | Alta | MVP | Storefront | No ejecutado |

---

## 23. Casos Fuera del MVP

| Caso | Motivo de exclusión | Fase futura posible | Riesgo si se adelanta |
| --- | --- | --- | --- |
| Seguridad de pagos reales | Pagos fuera del MVP | Futuro posible | Cumplimiento/complejidad |
| Seguridad de tax real | Tax fuera del MVP | Futuro posible | Esfuerzo desviado |
| Seguridad de shipping real | Shipping fuera del MVP | Futuro posible | Esfuerzo desviado |
| ERP real | Dependencia externa | Tras simulación | Acoplamiento prematuro |
| SSO avanzado | No requerido en el MVP | Futuro posible | Complejidad de identidad |
| MFA avanzado | No requerido en el MVP | Futuro posible | Complejidad de identidad |
| Marketplace | Modelo distinto | No incluido | Cambio de modelo |
| Multi-idioma | Opera en España | Futuro (expansión) | Esfuerzo desviado |
| Multi-divisa | Un solo mercado | Futuro (expansión) | Complejidad |
| OMS avanzado | Historial básico suficiente | Futuro posible | Sobre-ingeniería |
| Seguridad productiva enterprise completa | Fase documental/MVP | Futuro | Sobredimensionar el MVP |

---

## 24. Registro de Ejecución

```markdown
## Ejecución de Caso de Seguridad

**ID:**
**Fecha:**
**Ejecutado por:**
**Buyer usado:**
**Buyer account:**
**Buyer Group / segmento:**
**Datos usados:**
**Resultado:** Pass / Fail / Blocked / Pending
**Resultado real:**
**Riesgo observado:**
**Evidencia:**
**Defecto o gap:**
**Requiere ADR:** Sí / No
**Documento a actualizar:**
```

---

## 25. Gestión de Gaps de Seguridad

Un gap de seguridad debe registrarse con: **ID**, **caso afectado**,
**descripción**, **riesgo**, **severidad**, **área**, **alternativa estándar
evaluada**, **posible solución**, **¿requiere configuración?**, **¿requiere
Flow?**, **¿requiere LWC?**, **¿requiere Apex?**, **¿requiere ADR?** y **estado**.

Los gaps se reflejan en `configuration-decisions.md` y, si implican una decisión
de seguridad relevante, en `adr/`.

---

## 26. Severidad de Defectos de Seguridad

| Severidad | Descripción | Ejemplo | Acción recomendada |
| --- | --- | --- | --- |
| Critical | Exposición/acceso grave entre cuentas | Buyer ve orders de otra cuenta | Bloquear; corregir de inmediato; ADR |
| High | Exposición relevante de datos/pricing | Buyer ve pricing de otro segmento | Corregir antes de avanzar |
| Medium | Exposición de configuración interna no sensible | Error revela config interna no crítica | Corregir y revisar |
| Low | Mensaje poco claro sin exposición de datos | Mensaje confuso sin fuga | Mejorar microcopy |

---

## 27. Relación con Otros Documentos

- `docs/testing/test-strategy.md` define la **estrategia general**.
- `docs/testing/functional-test-cases.md` define los **casos funcionales**.
- Este documento define los **casos de seguridad**.
- `docs/salesforce/security-model.md` define la **seguridad Salesforce-relevante**.
- `docs/architecture/security-architecture.md` define los **principios de
  seguridad**.
- `docs/ux/empty-error-loading-states.md` define los **mensajes seguros**.
- `docs/development/error-handling-guidelines.md` define el **manejo de errores**.
- `docs/development/logging-guidelines.md` define la **trazabilidad segura**.
- `docs/salesforce/configuration-decisions.md` se **actualiza** ante gaps.
- `adr/` se usa si una solución implica una **decisión de seguridad relevante**.
