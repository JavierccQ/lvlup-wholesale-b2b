# Guidelines LWC - LvlUp WholeSale

> **Nota:** la estructura de este documento se ha alineado con sus documentos
> hermanos (`apex-guidelines.md`, `flow-guidelines.md`) y con el objetivo
> declarado, dado que la plantilla de secciones no llegó completa. Es ajustable si
> se requiere otra organización.

## 1. Propósito del Documento

Este documento define los **criterios y buenas prácticas** para desarrollar
Lightning Web Components (LWC) en el proyecto `LvlUp-Wholesale-B2B`: cuándo un LWC
custom está justificado, cómo diseñarlo, cómo integrarlo con Experience Builder y
Salesforce B2B Commerce, y qué criterios de seguridad, UX, accesibilidad, testing y
mantenibilidad debe cumplir.

Sirve como base para:

- Decidir **cuándo LWC custom está justificado**.
- Evitar la **UI custom innecesaria**.
- Diseñar componentes **mantenibles y mobile-first**.
- Integrar correctamente con **Experience Builder** y el storefront.
- Consumir **servicios Apex** solo cuando estén justificados.
- Respetar **seguridad, accesibilidad y estados UX**.
- Diseñar **tests** (Jest).

Este documento **no define la implementación LWC concreta del MVP**; los ejemplos
son conceptuales. La prosa va en español; nombres de componentes, clases JS,
variables, métodos, eventos, archivos y comentarios en inglés.

---

## 2. Principio Principal para LWC

> **El LWC custom no es la primera opción.** Va **después** de Experience Builder y
> de los componentes estándar.

Orden de evaluación (alineado con `standard-vs-custom-framework.md`):

1. **Salesforce B2B Commerce estándar**.
2. **Experience Builder / componentes estándar**.
3. **Configuración de datos**.
4. **Flow** si la lógica es declarativa.
5. **LWC** si hay un **gap UX/funcional real** no cubierto por el estándar.
6. **Apex** como backing del LWC solo si se justifica.
7. **Integración externa** si el dato vive fuera de Salesforce.

Cualquier LWC relevante debe **justificarse** contra el framework y, cuando sea un
componente central, registrarse en un **ADR**. **No se crea LWC por estética.**

---

## 3. Cuándo Usar LWC

Escenarios válidos (la mayoría, futuros y sujetos a validación):

- **Visualización especial de stock** no cubierta por el estándar.
- **Mensajes custom** de pricing, crédito o aprobación.
- **Experiencia específica de reorder**.
- **Componente de quote request**.
- **Componente de estado de pedido**.
- **Integración UI con servicios Apex** justificados.

En todos los casos: debe existir un **gap validado** frente a Experience Builder y
los componentes estándar.

---

## 4. Cuándo Evitar LWC

- Si **Experience Builder** o un **componente estándar** cubren la necesidad.
- Solo por **estética** o preferencia visual.
- Para **replicar** algo que ya existe en el estándar.
- Sin haber **validado primero** Experience Builder.
- Si aumenta el **mantenimiento sin valor funcional**.
- Si compromete la **upgradeability** del storefront.
- Si el caso está **fuera del MVP**.
- Si **no hay estrategia de testing**.

---

## 5. Reglas de Naming

- Carpeta/componente en **camelCase** (`stockAvailabilityBadge`).
- Clase JS en **PascalCase** (`StockAvailabilityBadge`).
- Propiedades públicas (`@api`) y variables en **camelCase**.
- Eventos custom en **minúsculas, sin guiones** (`quantitychange`,
  `reorderrequest`).
- Constantes en **UPPER_SNAKE_CASE**.
- Nombres **descriptivos** con dominio funcional; **comentarios en inglés**.
- Evitar nombres genéricos (`customComponent`, `wrapper`, `helper`).

**Ejemplo recomendado (conceptual):**

```javascript
// stockAvailabilityBadge.js
import { LightningElement, api } from 'lwc';

export default class StockAvailabilityBadge extends LightningElement {
    @api sku;
    @api availability; // 'available' | 'insufficient' | 'unavailable'
    // Presentational only; no business logic here
}
```

**Ejemplo a evitar:**

```javascript
// Avoid: generic name, unclear responsibility
export default class Comp1 extends LightningElement {
    @api data; // unclear payload, mixed concerns
}
```

---

## 6. Estructura y Organización del Componente

- Cada LWC con sus archivos: `*.html`, `*.js`, `*.css`, `*.js-meta.xml`.
- **Responsabilidad única**: separar presentación de lógica.
- Componentes **pequeños y cohesivos**; componer padres/hijos.
- **Presentacionales vs contenedores**: el contenedor obtiene datos, el hijo
  presenta.
- **No** meter lógica de negocio en el cliente (vive en backend/Apex/estándar).
- Estilos **encapsulados**; evitar overrides globales que rompan el storefront.

---

## 7. Integración con Experience Builder y B2B Commerce

- Exponer el componente al storefront vía `*.js-meta.xml` con los **targets**
  adecuados (pendiente de validación en la org).
- Definir **propiedades configurables** para que el admin lo ajuste sin código.
- **No romper** la navegación ni el layout estándar.
- **No duplicar** componentes estándar del storefront.
- Probar el componente **dentro de Experience Builder** y en el storefront real.
- Respetar el **contexto del buyer** (cuenta/Buyer Group) que provee la plataforma.

---

## 8. Comunicación y Datos

- Entrada vía **`@api`** (propiedades públicas), inmutables desde el hijo.
- Salida vía **eventos custom** (`CustomEvent`), no mutando props del padre.
- Datos de Salesforce vía **`@wire`** cuando sea posible (cacheable) o llamadas
  imperativas a **Apex `@AuraEnabled`** cuando se requiera.
- Los métodos Apex backing siguen `apex-guidelines.md` (con sharing, CRUD/FLS,
  bulk-safe, tests).
- **No** poner reglas de negocio (pricing, visibilidad, aprobación) en el cliente:
  el cliente **presenta**, el backend **decide**.
- Devolver **DTOs/result objects** claros desde Apex.

---

## 9. Estados UX

Todo LWC con datos debe contemplar los estados de
`docs/ux/empty-error-loading-states.md`:

- **Loading**: indicador mientras se obtienen datos.
- **Empty**: estado vacío explicado con acción siguiente.
- **Error**: mensaje **no técnico** y accionable.
- **Pending**: para aprobación/cotización (diferenciado del éxito).
- **Restricted**: no exponer lo no permitido.
- **Validation**: indicar cómo corregir (p. ej. cantidad inválida).

Los mensajes deben ser **claros y no técnicos**, coherentes con el microcopy ya
definido.

---

## 10. Seguridad en LWC

- **No confiar solo en la UI**: ocultar en el cliente **no** protege el dato
  (coherente con `security-model.md`).
- La seguridad real vive en **backend** (Apex con sharing/CRUD/FLS, entitlements).
- **No exponer** datos de otra buyer account ni **pricing** de otro segmento.
- **No mostrar** productos restringidos ni permitir su compra desde el componente.
- **No hardcodear** IDs, URLs ni secretos en el JS.
- **No exponer errores técnicos** al buyer.
- Tratar el componente como **no confiable**: el backend revalida siempre.

---

## 11. Accesibilidad (a11y)

- **HTML semántico** y uso de componentes base (SLDS/Lightning) cuando aporten a11y.
- **Labels** asociados a inputs; texto alternativo en imágenes.
- **Contraste suficiente**; no depender solo del color para el estado.
- **Navegación por teclado** y orden de foco lógico.
- Usar **ARIA** solo cuando sea necesario y correcto.
- Mensajes de error **percibibles** (visibles y anunciables).

---

## 12. Mobile-First y Responsive

- Diseñar **primero para móvil**; layout adaptable a desktop.
- **Botones táctiles** y áreas de toque adecuadas.
- Evitar **tablas complejas** en móvil; preferir tarjetas/listas.
- Información crítica (precio, disponibilidad, acción) **visible sin scroll**
  excesivo.
- Probar en **breakpoints** representativos.

---

## 13. Performance

- Preferir **`@wire` cacheable** frente a llamadas imperativas repetidas.
- **Minimizar** el número de llamadas a Apex/servicios.
- Renderizado condicional con **`lwc:if`/`template if`**; evitar trabajo innecesario.
- **No** hacer trabajo pesado en `renderedCallback`.
- **Paginar/limitar** datos en listados (PLP) cuando aplique.
- Evitar **re-renders** innecesarios y cálculos repetidos.

---

## 14. Testing (Jest)

- Todo LWC con lógica debe tener **tests con Jest** (`sfdx-lwc-jest`).
- Probar **render**, **estados** (loading/empty/error/pending/validation) y
  **eventos**.
- **Mockear** `@wire` y las llamadas a Apex; no depender de datos reales.
- Probar **casos positivos, negativos y límite** (stock, pricing, visibilidad).
- Asserts con **comportamiento esperado claro**.
- El Apex backing se prueba con **test classes** (ver `apex-guidelines.md` §12).

---

## 15. Manejo de Errores

- Capturar errores de `@wire`/Apex y mostrar **mensajes funcionales**.
- **No** exponer stack traces ni payloads crudos.
- Ofrecer una **acción siguiente** (reintentar, volver, ajustar).
- Diferenciar **error técnico** (log/trace) de **error funcional** (mensaje al
  buyer).
- Mantener la coherencia con los mensajes de `empty-error-loading-states.md`.

---

## 16. Anti-patrones a Evitar

- LWC donde **Experience Builder/estándar** ya resuelve.
- **Lógica de negocio en el cliente** (pricing/visibilidad/aprobación).
- **Ocultar datos solo con CSS/JS** como "seguridad".
- **Hardcodear** IDs, URLs o secretos.
- Componentes **"god component"** que lo hacen todo.
- **No manejar** estados empty/error/loading.
- **Exponer** errores técnicos o datos sensibles.
- Componentes **sin tests**.
- Romper **mobile** o la **upgradeability** del storefront.
- Crear LWC **antes de validar** el estándar/Experience Builder.

---

## 17. Checklist antes de Crear un LWC

- [ ] ¿Lo resuelve el estándar de B2B Commerce o Experience Builder?
- [ ] ¿Existe un gap UX/funcional validado y documentado?
- [ ] ¿Tiene responsabilidad única y nombre claro (en inglés)?
- [ ] ¿Es mobile-first y accesible?
- [ ] ¿Maneja loading/empty/error/pending/validation?
- [ ] ¿La lógica de negocio está en backend, no en el cliente?
- [ ] ¿No expone datos sensibles, pricing indebido ni productos restringidos?
- [ ] ¿El Apex backing está justificado y respeta seguridad?
- [ ] ¿Tiene tests Jest?
- [ ] ¿Está dentro del MVP?
- [ ] ¿Requiere un ADR?

---

## 18. Relación con ADRs

Crear un ADR cuando:

- Se introduce un **LWC custom para un comportamiento relevante** (PLP/PDP, carrito,
  checkout, reorder, etc.).
- El LWC **reemplaza** un componente estándar.
- El LWC consume **Apex de lógica central o de integración**.
- El LWC maneja **datos sensibles** o afecta a la **seguridad/visibilidad**.
- Se introduce una **excepción** al principio estándar primero.

---

## 19. Supuestos y Decisiones Pendientes

**Supuestos.**

- En el MVP, el LWC custom se usa **solo si** Experience Builder/estándar no
  alcanzan.
- Los ejemplos de este documento son **conceptuales**.
- Los **targets** y la integración real con el storefront **se validan** en la org.

**Decisiones pendientes.**

- Qué pantallas requerirán realmente LWC (PLP/PDP/cart/checkout) — `DEC-019`.
- Componentes estándar disponibles por pantalla (`DEC-002`).
- Si reorder/quote/credit/stock necesitan UI custom.
- Estrategia de testing Jest del proyecto.

---

## 20. Relación con Otros Documentos

- `docs/architecture/standard-vs-custom-framework.md` define **cuándo LWC está
  justificado**.
- `docs/ux/ux-principles.md`, `plp-pdp-guidelines.md`, `cart-checkout-experience.md`
  y `empty-error-loading-states.md` definen la **experiencia y los estados** que el
  LWC debe respetar.
- `docs/development/apex-guidelines.md` define los **servicios Apex** que el LWC
  consume.
- `docs/development/flow-guidelines.md` define el **criterio Flow vs LWC**.
- `docs/development/integration-guidelines.md` define la **integración** que un LWC
  podría consumir (vía Apex).
- `docs/development/code-review-checklist.md` consolida la **review de LWC**.
- `docs/salesforce/security-model.md` define la **seguridad** que el LWC debe
  respetar.
- `docs/testing/` deberá definir la **estrategia de pruebas** detallada.
- `adr/` registrará las **decisiones de uso de LWC**.
