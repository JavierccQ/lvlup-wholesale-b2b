# Checklist de Validación de Org - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define una **checklist práctica** para validar qué capacidades
estándar, objetos, configuraciones, componentes y comportamientos de Salesforce
B2B Commerce están **realmente disponibles** en la Developer Org de
`LvlUp-Wholesale-B2B`.

Sirve para:

- Confirmar las capacidades estándar disponibles.
- Identificar gaps reales.
- Evitar la customización prematura.
- Alimentar `configuration-decisions.md`.
- Alimentar `limitations-and-assumptions.md`.
- Determinar cuándo una decisión debe escalarse a ADR.
- Preparar configuración, datos y testing.
- Reducir los supuestos no validados.

Esta checklist **no reemplaza la documentación oficial de Salesforce** ni los
comandos de inspección técnica. Aplica el principio rector: *Configuration first,
customization only when justified*.

> **Estado inicial:** ningún ítem se ha validado todavía. Todos los checkboxes
> empiezan **sin marcar** (estado *No revisado*). Esta checklist se completa al
> ejecutar la validación en la org.

---

## 2. Principios de Validación

- **Validar antes de decidir**.
- **No asumir** capacidades por su nombre.
- **Registrar evidencia funcional**.
- **Separar** hallazgos confirmados de supuestos.
- **Validar con un usuario buyer** cuando aplique.
- **Validar mobile** cuando aplique.
- **No customizar** antes de documentar el gap.
- **Actualizar los documentos** relacionados tras cada validación.

---

## 3. Estados de Validación

| Estado | Significado | Cuándo usarlo | Acción siguiente |
| --- | --- | --- | --- |
| No revisado | Aún no validado | Estado inicial | Programar validación |
| En revisión | Validación en curso | Mientras se comprueba | Completar |
| Validado | Confirmado en la org | Funciona como se espera | Documentar |
| Parcialmente validado | Funciona con límites | Cobertura parcial | Documentar gap |
| No disponible | No existe en la org | Capacidad ausente | Evaluar alternativa |
| Bloqueado | No se puede validar aún | Falta acceso/dependencia | Desbloquear |
| Fuera del MVP | No aplica al MVP | Excluido del alcance | Diferir |
| Requiere ADR | Implica customización/excepción | Antes de implementar | Crear ADR |

---

## 4. Plantilla de Ítem de Validación

Cada ítem relevante puede documentarse con:

- **ID** (p. ej. `VAL-COM-001`)
- **Área**
- **Elemento a validar**
- **Pregunta de validación**
- **Resultado esperado**
- **Estado**
- **Evidencia**
- **Impacto si falla**
- **Documento a actualizar**
- **¿Requiere ADR?**
- **Próximo paso**

Prefijos de ID (orientativos): `VAL-ORG` (general), `VAL-STO` (storefront),
`VAL-EXB` (Experience Builder), `VAL-CAT` (catálogo), `VAL-PRD` (productos),
`VAL-ACC` (buyer accounts), `VAL-USR` (buyer users), `VAL-BG` (Buyer Groups),
`VAL-PRI` (pricing), `VAL-VIS` (visibilidad), `VAL-SRC` (search), `VAL-PLP`,
`VAL-PDP`, `VAL-CRT` (cart), `VAL-CHK` (checkout), `VAL-ORD` (orders/historial),
`VAL-REO` (reorder), `VAL-APP` (approval), `VAL-CRE` (credit), `VAL-STK` (stock),
`VAL-SEC` (permisos), `VAL-UX` (mobile), `VAL-DATA` (datos), `VAL-GAP` (gaps).

---

## 5. Validación General de Org

| ID | Validación | Resultado esperado | Estado inicial | Evidencia requerida | Documento relacionado |
| --- | --- | --- | --- | --- | --- |
| VAL-ORG-001 | La Developer Org es accesible | Acceso correcto | No revisado | Acceso confirmado | `solution-architecture.md` |
| VAL-ORG-002 | B2B Commerce está disponible | Capacidad presente | No revisado | Capacidad visible | `b2b-commerce-standard-capabilities.md` |
| VAL-ORG-003 | El Site/storefront está activo | Storefront operativo | No revisado | Storefront accesible | `solution-architecture.md` |
| VAL-ORG-004 | El admin accede a la configuración relevante | Acceso de configuración | No revisado | Configuración visible | `configuration-decisions.md` |
| VAL-ORG-005 | La org permite trabajar con datos de catálogo | Catálogo gestionable | No revisado | Datos cargables | `data-loading-strategy.md` |
| VAL-ORG-006 | La org permite configurar Experience Builder | Builder accesible | No revisado | Builder editable | `ux-principles.md` |
| VAL-ORG-007 | La org permite crear/validar buyers | Buyers gestionables | No revisado | Buyer operativo | `security-model.md` |
| VAL-ORG-008 | La org permite revisar permisos relevantes | Permisos visibles | No revisado | Permisos revisados | `security-model.md` |

---

## 6. Validación de Storefront / Site

| Punto | Resultado esperado | Riesgo si falla | Documento relacionado |
| --- | --- | --- | --- |
| Storefront existente identificado | Storefront localizado | Sin base de trabajo | `solution-architecture.md` |
| Site activo | Site operativo | Sin acceso al portal | `solution-architecture.md` |
| Home accesible | Home carga | Sin punto de entrada | `wireframes.md` |
| Navegación básica disponible | Navegación operativa | Sin exploración | `storefront-journey.md` |
| Experiencia accesible autenticado | Acceso buyer | Sin experiencia B2B | `security-model.md` |
| Experiencia no autenticada controlada | Acceso restringido sin login | Exposición indebida | `security-model.md` |
| Branding básico configurable | Branding ajustable | UX pobre | `ux-principles.md` |
| Mobile responsive básico | Responsive correcto | Mala UX mobile | `ux-principles.md` |

---

## 7. Validación de Experience Builder

- [ ] Acceso a Experience Builder.
- [ ] Páginas disponibles.
- [ ] Layout editable.
- [ ] Componentes estándar disponibles.
- [ ] Header/navigation configurables.
- [ ] Home configurable.
- [ ] Páginas de catálogo configurables.
- [ ] Páginas de producto configurables.
- [ ] Páginas de carrito/checkout configurables o identificables.
- [ ] Limitaciones detectadas y documentadas.

*(No se inventan nombres concretos de componentes; se registran al validar.)*

---

## 8. Validación de Catálogo

| ID | Validación | Resultado esperado | Estado | Evidencia | Impacto |
| --- | --- | --- | --- | --- | --- |
| VAL-CAT-001 | Existe capacidad de Product Catalog | Catálogo disponible | No revisado | Catálogo creado | Sin catálogo no hay tienda |
| VAL-CAT-002 | Existen categorías o estructura equivalente | Categorías disponibles | No revisado | Categorías visibles | Sin navegación |
| VAL-CAT-003 | Productos asociables a catálogo | Asociación posible | No revisado | Producto en catálogo | Producto huérfano |
| VAL-CAT-004 | Productos asociables a categorías | Asociación posible | No revisado | Producto en categoría | Sin clasificación |
| VAL-CAT-005 | Categorías aparecen en navegación | Navegación correcta | No revisado | Categoría navegable | Catálogo invisible |
| VAL-CAT-006 | PLP muestra productos por categoría | PLP correcta | No revisado | PLP con productos | Sin listado |
| VAL-CAT-007 | Producto activo/no activo distinguible | Estado visible | No revisado | Estado probado | Comprar no comprable |
| VAL-CAT-008 | Imágenes o placeholders se muestran | Imagen/placeholder | No revisado | Imagen visible | PLP/PDP pobre |

---

## 9. Validación de Productos

- [ ] Los productos pueden crearse o reutilizarse.
- [ ] Los productos pueden tener SKU o identificador funcional.
- [ ] Los productos pueden tener nombre y descripción.
- [ ] Los productos pueden asociarse a categoría.
- [ ] Los productos pueden mostrarse en PLP.
- [ ] Los productos pueden abrir PDP.
- [ ] Un producto no activo/no comprable puede probarse (si aplica).
- [ ] Los atributos relevantes pueden visualizarse o documentarse.

---

## 10. Validación de Buyer Accounts

- [ ] Se pueden representar cuentas compradoras.
- [ ] Se puede asociar un buyer user a una buyer account.
- [ ] La cuenta puede influir en acceso, pricing o visibilidad (si el estándar lo
      permite).
- [ ] Cada buyer account puede tener un usuario operativo (MVP).
- [ ] El buyer no ve datos de otra cuenta.
- [ ] La relación cuenta-usuario queda validada o marcada como gap.

---

## 11. Validación de Buyer Users

- [ ] Se puede crear o habilitar un usuario buyer.
- [ ] El buyer puede iniciar sesión.
- [ ] El buyer puede acceder al storefront.
- [ ] El buyer puede ver el catálogo permitido.
- [ ] El buyer puede agregar al carrito.
- [ ] El buyer puede iniciar checkout.
- [ ] El buyer puede consultar historial (si aplica).
- [ ] El buyer no puede acceder a información de otra cuenta.

*(No se inventan licencias ni Permission Sets; se marcan como pendiente de
validación.)*

---

## 12. Validación de Buyer Groups

- [ ] Existe capacidad de Buyer Groups o agrupación equivalente.
- [ ] Una buyer account puede asociarse a un Buyer Group.
- [ ] El Buyer Group puede influir en el catálogo.
- [ ] El Buyer Group puede influir en el pricing.
- [ ] El Buyer Group puede influir en la visibilidad.
- [ ] Los segmentos funcionales pueden representarse.
- [ ] Las limitaciones quedan documentadas.

---

## 13. Validación de Pricing

- [ ] Existe pricing visible en PLP.
- [ ] Existe pricing visible en PDP.
- [ ] El pricing se mantiene en el carrito.
- [ ] El pricing se mantiene en el checkout.
- [ ] El pricing puede variar por cuenta o Buyer Group (si el estándar lo permite).
- [ ] Un producto sin pricing puede manejarse funcionalmente.
- [ ] Los cambios de pricing se reflejan de forma consistente.
- [ ] Promociones complejas y multi-divisa quedan fuera del MVP.

---

## 14. Validación de Visibilidad / Entitlements

- [ ] Un producto visible para un buyer aparece en PLP.
- [ ] Un producto restringido no aparece en PLP.
- [ ] Un producto restringido no aparece en búsqueda.
- [ ] La PDP directa de un producto restringido se maneja de forma segura.
- [ ] Un producto restringido no puede agregarse al carrito.
- [ ] El checkout revalida el producto permitido.
- [ ] El reorder revalida la visibilidad (si aplica).
- [ ] La visibilidad puede gestionarse sin customización o se documenta el gap.

---

## 15. Validación de Search

- [ ] Search está disponible.
- [ ] Search respeta el catálogo visible.
- [ ] Search no muestra productos restringidos.
- [ ] Search maneja el estado sin resultados.
- [ ] Search funciona en mobile.
- [ ] Las limitaciones quedan documentadas.

---

## 16. Validación de PLP

- [ ] La PLP muestra productos.
- [ ] La PLP muestra la información mínima necesaria.
- [ ] La PLP muestra pricing (si aplica).
- [ ] La PLP respeta la visibilidad.
- [ ] La PLP permite acceso a PDP.
- [ ] La PLP permite agregar al carrito (si el estándar lo permite).
- [ ] La PLP maneja estados empty/loading/error.
- [ ] La PLP funciona en mobile.

---

## 17. Validación de PDP

- [ ] La PDP muestra la información del producto.
- [ ] La PDP muestra el pricing aplicable.
- [ ] La PDP respeta la visibilidad.
- [ ] La PDP permite agregar al carrito.
- [ ] La PDP maneja producto no disponible/no visible.
- [ ] La PDP maneja producto sin pricing.
- [ ] La PDP funciona en mobile.

---

## 18. Validación de Cart

- [ ] El buyer puede agregar un producto permitido al carrito.
- [ ] El buyer puede modificar la cantidad.
- [ ] El buyer puede eliminar un producto.
- [ ] El carrito muestra pricing y subtotal.
- [ ] El carrito respeta la visibilidad actual.
- [ ] El carrito maneja un producto no permitido.
- [ ] El carrito maneja el pricing actualizado.
- [ ] El carrito funciona en mobile.
- [ ] Las limitaciones quedan documentadas.

---

## 19. Validación de Checkout

- [ ] El buyer puede iniciar checkout.
- [ ] El checkout muestra el resumen de productos.
- [ ] El checkout muestra el total funcional.
- [ ] El checkout permite confirmar cuando aplica.
- [ ] El checkout diferencia pedido confirmado de solicitud pendiente (si se
      configura o documenta).
- [ ] El checkout maneja bloqueo por stock/crédito/aprobación (si aplica o queda
      como gap).
- [ ] Pagos, tax y shipping reales quedan fuera del MVP.
- [ ] El checkout funciona en mobile.

---

## 20. Validación de Orders / Historial

- [ ] Se puede consultar el historial de pedidos (si el estándar lo permite).
- [ ] El buyer solo ve pedidos de su cuenta.
- [ ] El detalle de pedido muestra información suficiente.
- [ ] El pedido confirmado queda trazable.
- [ ] El estado pendiente queda diferenciado (si aplica).
- [ ] Las limitaciones quedan documentadas.

---

## 21. Validación de Reorder

- [ ] Reorder está disponible o se identifica el gap.
- [ ] Reorder puede iniciarse desde historial/detalle.
- [ ] Reorder revalida los productos actuales.
- [ ] Reorder revalida el pricing.
- [ ] Reorder revalida la visibilidad.
- [ ] Reorder maneja un producto no disponible.
- [ ] Reorder maneja el pricing actualizado.
- [ ] Reorder funciona en mobile (si aplica).

---

## 22. Validación de Approval por Importe

- [ ] Determinar si existe una capacidad estándar útil.
- [ ] Determinar si puede resolverse con configuración.
- [ ] Determinar si Flow sería suficiente.
- [ ] Determinar si requiere Apex/custom.
- [ ] Umbral pendiente de definición (`DEC-008`).
- [ ] Si se customiza, requiere ADR.
- [ ] El estado MVP puede quedar documentado funcionalmente.

---

## 23. Validación de Credit Status

- [ ] Determinar si el crédito puede representarse sin integración.
- [ ] Determinar si puede simularse documentalmente.
- [ ] Determinar si requiere integración futura.
- [ ] Determinar si el checkout debe bloquear por crédito en el MVP o en el futuro.
- [ ] Si requiere Apex/integración, requiere ADR.

---

## 24. Validación de Stock Funcional

- [ ] Determinar si el stock puede representarse de forma simple.
- [ ] Determinar si el stock puede mostrarse en PLP/PDP/cart/checkout.
- [ ] Determinar si el stock insuficiente puede bloquear la compra.
- [ ] Determinar si se documentará sin automatizar.
- [ ] Determinar si requiere integración futura.
- [ ] Si requiere Apex/integración, requiere ADR.

---

## 25. Validación de Permission Sets / Acceso

- [ ] Identificar los permisos necesarios para el buyer.
- [ ] Identificar los permisos necesarios para el admin.
- [ ] Evitar permisos excesivos.
- [ ] Validar el acceso con un buyer real de prueba.
- [ ] Validar que el buyer no accede a datos de otra cuenta.
- [ ] Validar que el buyer no accede a productos restringidos.
- [ ] Registrar los gaps en `security-model.md`.

*(No se inventan nombres concretos.)*

---

## 26. Validación Mobile

- [ ] Login usable en mobile.
- [ ] Home usable en mobile.
- [ ] PLP usable en mobile.
- [ ] PDP usable en mobile.
- [ ] Cart usable en mobile.
- [ ] Checkout usable en mobile.
- [ ] Historial usable en mobile.
- [ ] Reorder usable en mobile (si aplica).
- [ ] Mensajes de error/empty/loading visibles.

---

## 27. Validación de Datos

- [ ] Buyer accounts creadas correctamente.
- [ ] Buyer users asociados correctamente.
- [ ] Buyer Groups asignados correctamente.
- [ ] Categorías visibles.
- [ ] Productos asociados a categorías.
- [ ] Pricing aplicado.
- [ ] Visibilidad aplicada.
- [ ] Los datos de prueba permiten escenarios positivos y negativos.
- [ ] No hay dependencia innecesaria de IDs manuales.
- [ ] Los datos son reproducibles.

---

## 28. Evidencia de Validación

Tipo de evidencia a capturar por ítem:

- Captura funcional.
- Nota breve de validación.
- Resultado esperado vs resultado real.
- Limitación encontrada.
- Link o referencia interna (si aplica).
- Documento actualizado.
- ADR creado (si aplica).

*(No se incluyen imágenes todavía; aquí solo se define el criterio.)*

---

## 29. Gaps y Acciones Posteriores

| ID | Gap encontrado | Área | Impacto | Alternativa estándar evaluada | Acción recomendada | ¿Requiere ADR? | Estado |
| --- | --- | --- | --- | --- | --- | --- | --- |
| VAL-GAP-001 | *(a registrar al validar)* | — | — | — | — | — | Abierto |

*(Esta tabla se completa con los gaps reales detectados durante la validación;
inicialmente está vacía salvo el ejemplo de formato.)*

---

## 30. Checklist de Actualización Documental

Tras validar, actualizar según corresponda:

- [ ] `docs/salesforce/configuration-decisions.md`
- [ ] `docs/salesforce/b2b-commerce-standard-capabilities.md`
- [ ] `docs/salesforce/data-model.md`
- [ ] `docs/salesforce/security-model.md`
- [ ] `docs/salesforce/data-loading-strategy.md`
- [ ] `docs/architecture/limitations-and-assumptions.md`
- [ ] `adr/` (si aplica)
- [ ] `docs/testing/` (cuando se creen pruebas)

---

## 31. Relación con Otros Documentos

- `docs/salesforce/b2b-commerce-standard-capabilities.md` define las **capacidades a
  evaluar**.
- Este documento define **cómo validar** esas capacidades en la org.
- `docs/salesforce/configuration-decisions.md` debe **actualizarse con los
  resultados**.
- `docs/salesforce/data-loading-strategy.md` define los **datos necesarios** para
  validar.
- `docs/architecture/limitations-and-assumptions.md` consolida **gaps y decisiones
  pendientes**.
- `adr/` registra las **decisiones relevantes**.
- `docs/testing/` debe derivar **casos de prueba** desde las validaciones
  confirmadas.
