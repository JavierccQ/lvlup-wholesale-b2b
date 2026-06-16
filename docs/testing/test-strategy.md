# Estrategia de Testing - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define la **estrategia general de testing** del proyecto
`LvlUp-Wholesale-B2B`: cómo se valida el MVP de forma funcional, UX, de seguridad,
de datos, de configuración y técnica.

Sirve como base para: validar el MVP, las capacidades estándar de B2B Commerce, la
configuración y los datos, la UX, la seguridad, el pricing y la visibilidad, el
cart/checkout/historial/reorder, Apex/LWC/Flow (si se implementan), las
integraciones futuras, la regresión y los criterios de aceptación; y para alimentar
agentes QA y evaluaciones IA.

Este documento **no define scripts automatizados ni herramientas finales**. La
prosa va en español; los términos técnicos y test methods en inglés. Aplica el
principio rector: *Configuration first, customization only when justified*.

> **Estado inicial:** los casos descritos están **por ejecutar** (estado
> *Pendiente*). Esta estrategia se completa al validar en la org.

---

## 2. Principios de Testing

- Probar el **comportamiento funcional**, no solo la configuración.
- Validar primero **estándar y configuración**.
- Probar con **buyer users**, no solo con admin.
- Probar escenarios **positivos y negativos**.
- Probar **seguridad y visibilidad**.
- Probar **pricing consistente**.
- Probar **mobile** cuando afecte al storefront.
- Probar **datos y dependencias**.
- Probar **errores y estados vacíos**.
- Mantener las pruebas **alineadas al MVP**.
- **No automatizar prematuramente** sin un proceso estable.

---

## 3. Alcance de Testing

### Incluido

Functional, UX, security, data, configuration, B2B Commerce estándar, storefront,
pricing y visibilidad, cart y checkout, order history y reorder, Apex (si existe),
LWC (si existe), Flow (si existe), integración futura con mocks, y regresión.

### Fuera del alcance inicial

Pagos reales, tax real, shipping real, ERP real, OMS avanzado, multi-idioma,
multi-divisa, marketplace, performance enterprise y un automation framework
definitivo.

---

## 4. Tipos de Testing

| Tipo | Objetivo | Cuándo aplica | Ejemplos | Prioridad MVP |
| --- | --- | --- | --- | --- |
| Functional testing | Validar comportamiento de negocio | Siempre | Compra estándar, reorder | Alta |
| UX testing | Validar experiencia y estados | Cambios de storefront | Empty/error/loading | Alta |
| Security testing | Validar acceso y visibilidad | Siempre | Catálogo restringido | Alta |
| Data testing | Validar datos y dependencias | Carga de datos | Pricing por cuenta | Alta |
| Configuration testing | Validar configuración SF | Cambios de config | Buyer Groups | Alta |
| Regression testing | Evitar romper lo existente | Tras cambios | Pricing/checkout | Media |
| Apex unit testing | Validar lógica Apex | Si hay Apex | Service tests | Alta (si aplica) |
| LWC testing | Validar componentes | Si hay LWC | Jest render/estados | Alta (si aplica) |
| Flow testing | Validar automatización | Si hay Flow | Fault paths | Media (si aplica) |
| Integration testing | Validar callouts | Fase futura | Mock de stock | Futuro |
| Error handling testing | Validar manejo de errores | Siempre | Mensajes seguros | Alta |
| Mobile testing | Validar en móvil | Storefront | PLP/checkout mobile | Alta |
| Smoke testing | Verificar que no está roto | Tras deploy | Login → cart | Alta |
| Acceptance testing | Validar el MVP | Cierre de MVP | Criterios §29 | Alta |

---

## 5. Estrategia de Datos de Prueba

- Datos **pequeños y representativos**.
- Cada dato **habilita un caso**.
- Evitar datos **sin propósito** y la **dependencia de IDs**.
- Probar **buyers y segmentos distintos**.
- Probar productos **visibles/restringidos**.
- Probar **pricing diferenciado**.
- Probar productos **sin stock funcional**.
- Probar **pedidos anteriores** si aplica historial/reorder.

Coherente con `data-loading-strategy.md`.

---

## 6. Buyer Accounts y Usuarios de Prueba

| Buyer (conceptual) | Segmento | Catálogo esperado | Pricing esperado | Visibilidad esperada | Casos positivos | Casos negativos | Estado |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Gaming Store Madrid | Gaming local | Gaming estándar | Precio base | Sin bundles enterprise | Compra/reorder gaming | Ver bundle enterprise | Pendiente |
| Tech Reseller Iberia | Reseller | Amplio | Preferente reseller | Catálogo amplio | Pricing reseller | Ver pricing de otro segmento | Pendiente |
| IT Solutions SMB | Empresa IT | Tecnológico | Corporativo | Sin gaming puro | Aprobación/crédito | Comprar restringido | Pendiente |
| Enterprise Gaming Procurement | Enterprise | Personalizado/restringido | Enterprise | Bundles enterprise | Pricing personalizado | Ver catálogo de otra cuenta | Pendiente |

---

## 7. Testing de Login y Acceso

| Caso | Actor | Precondición | Pasos conceptuales | Resultado esperado | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| Login válido | Buyer | Usuario activo | Acceder e iniciar sesión | Accede a su contexto | Alta | Pendiente |
| Acceso sin login | Anónimo | Sin sesión | Intentar ver catálogo completo | Acceso restringido | Alta | Pendiente |
| Sesión expirada | Buyer | Sesión caducada | Continuar tras expirar | Mensaje claro y reautenticación | Alta | Pendiente |
| Usuario sin acceso | Usuario | Sin permiso | Intentar entrar | Mensaje seguro, sin detalle | Media | Pendiente |
| Aislamiento de contexto | Buyer | Cuenta propia | Navegar | Solo su storefront/contexto | Alta | Pendiente |
| Error de login | Buyer | Credenciales inválidas | Login fallido | "Email o contraseña incorrectos." sin detalle técnico | Alta | Pendiente |

---

## 8. Testing de Catálogo y Categorías

- [ ] Las categorías son visibles.
- [ ] La PLP carga productos por categoría.
- [ ] Una categoría sin productos muestra empty state.
- [ ] Un producto activo aparece.
- [ ] Un producto no activo/no comprable se maneja correctamente (si aplica).
- [ ] La navegación funciona en desktop y mobile.

---

## 9. Testing de Search y PLP

- [ ] Search encuentra un producto permitido.
- [ ] Search no muestra un producto restringido.
- [ ] Search sin resultados muestra mensaje claro.
- [ ] La PLP muestra el precio aplicable.
- [ ] La PLP respeta la visibilidad.
- [ ] La PLP maneja loading/empty/error states.
- [ ] La PLP funciona en mobile.
- [ ] Add to cart desde PLP funciona (si el estándar lo permite).

---

## 10. Testing de PDP

- [ ] La PDP muestra un producto permitido.
- [ ] La PDP muestra la información mínima esperada.
- [ ] La PDP muestra el pricing aplicable.
- [ ] La PDP permite agregar al carrito un producto permitido.
- [ ] La PDP maneja un producto no visible.
- [ ] La PDP maneja un producto sin pricing.
- [ ] La PDP maneja stock insuficiente funcional.
- [ ] La PDP funciona en mobile.

---

## 11. Testing de Pricing

- [ ] El buyer A ve el precio esperado.
- [ ] El buyer B ve un precio esperado distinto (si aplica).
- [ ] Pricing consistente en PLP.
- [ ] Pricing consistente en PDP.
- [ ] Pricing consistente en cart.
- [ ] Pricing consistente en checkout.
- [ ] Un producto sin pricing se maneja con mensaje funcional.
- [ ] No se expone pricing de otro segmento.
- [ ] No se prueban promociones complejas ni multi-divisa (fuera del MVP).

Coherente con `PR-001`, `PR-002`, `PR-003`.

---

## 12. Testing de Visibilidad / Entitlements

- [ ] Un producto visible aparece en PLP.
- [ ] Un producto restringido no aparece en PLP.
- [ ] Un producto restringido no aparece en search.
- [ ] La URL directa a una PDP restringida se maneja de forma segura.
- [ ] Un producto restringido no puede agregarse al carrito.
- [ ] El checkout bloquea un producto no permitido.
- [ ] El reorder revalida la visibilidad actual.
- [ ] El buyer no ve el catálogo de otro segmento.

Coherente con `PV-001`, `PV-006`, `PV-007`.

---

## 13. Testing de Cart

- [ ] Agregar un producto permitido.
- [ ] Modificar la cantidad.
- [ ] Eliminar un producto.
- [ ] Ver el subtotal.
- [ ] Ver el total funcional.
- [ ] Producto sin stock suficiente.
- [ ] Producto ya no visible.
- [ ] Producto con pricing actualizado.
- [ ] Cantidad inválida.
- [ ] Cart vacío.
- [ ] Error al cargar el cart.
- [ ] El cart funciona en mobile.

---

## 14. Testing de Checkout

- [ ] El checkout inicia con un cart válido.
- [ ] El checkout muestra el resumen correcto.
- [ ] El checkout muestra el total funcional.
- [ ] El checkout confirma el pedido cuando aplica.
- [ ] El checkout diferencia pedido confirmado de solicitud pendiente.
- [ ] El checkout bloquea un producto no autorizado.
- [ ] El checkout maneja crédito bloqueado/excedido (si aplica).
- [ ] El checkout maneja stock insuficiente.
- [ ] El checkout maneja aprobación por importe.
- [ ] Sesión expirada durante el checkout.
- [ ] Un error técnico no expone detalles internos.

Los **pagos, tax y shipping reales están fuera del MVP**.

---

## 15. Testing de Approval por Importe

- [ ] Un pedido bajo umbral no requiere aprobación.
- [ ] Un pedido sobre umbral requiere aprobación.
- [ ] La solicitud pendiente se comunica claramente.
- [ ] Un pedido pendiente no se confunde con confirmado.
- [ ] Umbral pendiente de definición (`DEC-008`).
- [ ] Automatización pendiente si no está implementada.
- [ ] Flow/Apex solo se prueba si existe.

---

## 16. Testing de Credit Validation

- [ ] Crédito válido permite continuar.
- [ ] Crédito bloqueado impide/condiciona el checkout.
- [ ] Crédito excedido impide/condiciona el checkout.
- [ ] Crédito no disponible muestra el mensaje correcto.
- [ ] Fuente futura (ERP simulado) pendiente.
- [ ] No se prueba integración real en el MVP.

---

## 17. Testing de Stock Funcional

- [ ] Stock suficiente permite comprar.
- [ ] Stock insuficiente muestra mensaje.
- [ ] Una cantidad superior al stock disponible se bloquea/condiciona.
- [ ] Stock no disponible se maneja.
- [ ] ETA futura si aplica.
- [ ] Backorder fuera o pendiente según decisión.
- [ ] La integración futura no se prueba hasta implementarse.

---

## 18. Testing de Orders / Historial

- [ ] El buyer ve su propio historial.
- [ ] El buyer no ve orders de otra cuenta.
- [ ] Un buyer sin pedidos ve empty state.
- [ ] El detalle de order muestra información suficiente.
- [ ] El estado confirmado es visible.
- [ ] El estado pendiente es visible (si aplica).
- [ ] El error al cargar el historial se maneja correctamente.

---

## 19. Testing de Reorder

- [ ] Reorder desde un pedido válido.
- [ ] Reorder agrega los productos actuales al carrito.
- [ ] Reorder revalida el pricing actual.
- [ ] Reorder revalida la visibilidad actual.
- [ ] Reorder maneja un producto ya no disponible.
- [ ] Reorder parcial.
- [ ] Reorder con stock insuficiente.
- [ ] Reorder funciona en mobile (si aplica).

---

## 20. Testing de Seguridad

- [ ] El buyer solo ve productos permitidos.
- [ ] El buyer solo ve el pricing aplicable.
- [ ] El buyer solo ve orders de su cuenta.
- [ ] El buyer no accede a una PDP restringida.
- [ ] El buyer no compra un producto restringido.
- [ ] El buyer no manipula el pricing.
- [ ] El buyer no accede a datos de otra cuenta.
- [ ] Los errores de seguridad no revelan detalles internos.
- [ ] Se prueba con **buyer user**, no solo admin.

Coherente con `security-model.md`.

---

## 21. Testing UX y Estados

- [ ] Loading states.
- [ ] Empty states.
- [ ] Error states.
- [ ] Pending states.
- [ ] Restricted states.
- [ ] Validation states.
- [ ] Mensajes no técnicos.
- [ ] Acciones claras.
- [ ] Mobile-first.
- [ ] Diferencia entre confirmado y pendiente.
- [ ] Coherencia entre PLP, PDP, cart y checkout.

---

## 22. Testing Mobile

- [ ] Login.
- [ ] Home.
- [ ] Navigation.
- [ ] PLP.
- [ ] PDP.
- [ ] Cart.
- [ ] Checkout.
- [ ] Historial.
- [ ] Reorder.
- [ ] Mensajes de error.
- [ ] Botones y CTAs.
- [ ] Lectura de precios y cantidades.

---

## 23. Testing de Apex

*(Solo si existe Apex; coherente con `apex-guidelines.md` §12.)*

- Tests unitarios con **datos propios** (sin depender de org data).
- **Positive** y **negative scenarios**.
- **Error handling** y **security** (`runAs`).
- **Bulkification**.
- **Callout mocks** (`HttpCalloutMock`).
- **Sin IDs hardcodeados**.
- Test methods con **nombres descriptivos**.

---

## 24. Testing de LWC

*(Solo si existe LWC; coherente con `lwc-guidelines.md` §14.)*

- Render básico.
- Loading/empty/error states.
- Datos válidos e incompletos.
- Eventos.
- Interacción con Apex (si aplica).
- Seguridad de datos (no exponer sensibles).
- Comportamiento mobile funcional.

---

## 25. Testing de Flow

*(Solo si existe Flow; coherente con `flow-guidelines.md` §13.)*

- Escenario positivo y negativo.
- Fault paths.
- Datos faltantes.
- Permisos.
- Impacto en objetos relacionados.
- Sin IDs hardcodeados.
- Dependencias documentadas.
- Si bloquea checkout, pruebas reforzadas.

---

## 26. Testing de Integración Futura

*(Solo si se implementa mock/integración; coherente con `integration-guidelines.md`.)*

- Success response.
- Functional error.
- Technical error.
- Timeout.
- Invalid JSON.
- Missing field.
- Unauthorized.
- Stock insufficient.
- Credit blocked.
- Price unavailable.
- Order not found.
- Invoice unavailable.

---

## 27. Smoke Testing

Checklist mínima para confirmar que el storefront no está roto:

- [ ] Login buyer.
- [ ] Home carga.
- [ ] Categorías visibles.
- [ ] PLP carga.
- [ ] PDP carga.
- [ ] Producto permitido al cart.
- [ ] Cart carga.
- [ ] Checkout inicia.
- [ ] Pricing visible.
- [ ] Producto restringido no aparece.
- [ ] Logout/session handling básico.

---

## 28. Regression Testing

| Área cambiada | Casos de regresión mínimos | Prioridad |
| --- | --- | --- |
| Pricing | Consistencia PLP/PDP/cart/checkout; pricing por segmento | Alta |
| Visibility | Producto restringido oculto; reorder revalida | Alta |
| Cart | Agregar/modificar/eliminar; restricciones | Alta |
| Checkout | Confirmado vs pendiente; bloqueos | Alta |
| Buyer access | Aislamiento por cuenta; permisos | Alta |
| Datos de catálogo | PLP/PDP; categorías; pricing | Alta |
| LWC/Apex/Flow | Casos del componente/servicio afectado | Alta |
| Experience Builder | Navegación; PLP/PDP/cart/checkout; mobile | Media |
| Integración futura | Mocks: éxito/error/timeout | Futuro |

---

## 29. Acceptance Criteria del MVP

- [ ] El buyer puede iniciar sesión.
- [ ] El buyer ve el catálogo permitido.
- [ ] El buyer ve el pricing correcto.
- [ ] El buyer navega PLP/PDP.
- [ ] El buyer agrega un producto al cart.
- [ ] El buyer inicia un checkout básico.
- [ ] Un producto restringido no se expone.
- [ ] Pricing consistente.
- [ ] Cart/checkout manejan errores funcionales.
- [ ] Historial/reorder validados (si el estándar lo permite).
- [ ] Mobile básico usable.
- [ ] No se implementan features fuera del MVP.
- [ ] Documentación actualizada.

---

## 30. Registro de Evidencia

Por caso ejecutado puede guardarse: resultado esperado, resultado real, captura
(si aplica), buyer usado, datos usados, fecha, estado, gap detectado, documento
actualizado y ADR (si aplica).

*(No se incluyen imágenes ni rutas reales; aquí solo se define el criterio.)*

---

## 31. Gestión de Defectos

| Tipo de defecto | Definición | Ejemplo | Prioridad sugerida | Acción recomendada |
| --- | --- | --- | --- | --- |
| Functional | Comportamiento de negocio incorrecto | Checkout no bloquea sin stock | Alta | Corregir y re-probar |
| UX | Experiencia confusa o estado mal manejado | Error técnico visible | Media-alta | Ajustar microcopy/estado |
| Security | Exposición/acceso indebido | Ver producto restringido | Alta | Corregir y registrar |
| Data | Dato inconsistente/mal relacionado | Producto sin pricing | Alta | Corregir dato |
| Configuration | Configuración incompleta | Storefront incompleto | Alta | Completar configuración |
| Technical | Error/excepción inesperada | Apex exception | Alta | Corregir y test |
| Integration | Fallo de callout/mapeo | Timeout no manejado | Media (futuro) | Manejar y mockear |
| Documentation | Documentación desactualizada | Doc no refleja cambio | Media | Actualizar documento |

---

## 32. Riesgos de Testing

- Probar **solo con admin**.
- **No probar buyer real**.
- **No probar visibilidad**.
- **No probar pricing por segmento**.
- **No probar mobile**.
- **No probar errores**.
- **No probar reorder**.
- **No probar datos negativos**.
- **Automatizar antes de estabilizar**.
- **No documentar gaps**.
- **No actualizar** decisiones de configuración.

---

## 33. Relación con Otros Documentos

- `docs/salesforce/org-validation-checklist.md` valida las **capacidades reales**.
- `docs/salesforce/data-loading-strategy.md` define los **datos de prueba**.
- `docs/salesforce/security-model.md` define la **seguridad a validar**.
- `docs/ux/empty-error-loading-states.md` define los **estados UX**.
- `docs/development/code-review-checklist.md` define la **revisión técnica**.
- Este documento define la **estrategia general de testing**.
- `docs/testing/functional-test-cases.md` *(previsto)* detallará los **casos
  funcionales**.
- `docs/testing/security-test-cases.md` *(previsto)* detallará los **casos de
  seguridad**.
- `docs/testing/integration-test-cases.md` *(previsto)* detallará los **casos de
  integración futura**.
- `evals/` podrá **evaluar** a los agentes IA usando esta estrategia.
