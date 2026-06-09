# Glosario Salesforce B2B Commerce - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define un **glosario común** para el proyecto
`LvlUp-Wholesale-B2B`, de modo que negocio, UX, arquitectura, desarrollo, testing
y agentes de IA usen un vocabulario consistente.

Sirve como referencia para:

- Documentación funcional, UX, arquitectura y Salesforce.
- Desarrollo y testing.
- ADRs.
- Agentes de IA.
- Onboarding futuro.

Este glosario **no reemplaza la documentación oficial de Salesforce**; algunos
términos pueden requerir **validación en la org**. Los términos Salesforce/Commerce
se mantienen en inglés cuando es lo natural, con explicación en español.

---

## 2. Convenciones del Glosario

Cada término se documenta en una **tabla** con estos campos:

- **Término** (en inglés cuando es nombre propio/estándar).
- **Definición** (en español, clara y breve).
- **Uso en LvlUp WholeSale / Relación** (cómo aplica y términos relacionados).
- **Estado**: `MVP`, `Futuro`, `Fuera del MVP`, `Pendiente de validación` o
  `Referencia` (vocabulario general no sujeto a estado de alcance).

> Nota de formato: dado el volumen de términos, se usa formato de tabla en lugar de
> bloque por término, para mantener el glosario navegable. Los campos son
> equivalentes a los definidos para cada entrada.

---

## 3. Términos Generales del Proyecto

| Término | Definición | Uso en LvlUp WholeSale / Relación | Estado |
| --- | --- | --- | --- |
| LvlUp WholeSale | Empresa ficticia distribuidora mayorista B2B de tecnología y gaming | Negocio simulado del proyecto | Referencia |
| LvlUp-Wholesale-B2B | Nombre del proyecto Salesforce | Repositorio y org del proyecto | Referencia |
| MVP | Producto mínimo viable funcional | Alcance inicial (`mvp-scope.md`) | MVP |
| Storefront | Tienda online B2B del comprador | Portal principal del proyecto | MVP |
| Buyer | Comprador B2B autenticado | Actor principal | MVP |
| Seller | Vendedor/empresa que vende (LvlUp) | Rol interno; gestión comercial | Referencia |
| B2B | Comercio entre empresas | Modelo del proyecto | Referencia |
| B2C | Comercio a consumidor final | Contraste; el proyecto no es B2C | Referencia |
| Reseller | Cliente que revende | Segmento de comprador | MVP |
| Distributor | Distribuidor mayorista | Modelo de LvlUp (distribuidor a reseller) | Referencia |
| Enterprise customer | Cliente de gran tamaño con acuerdos | Segmento de comprador | MVP |
| Configuration first | Priorizar configuración antes que código | Principio rector | Referencia |
| Customization | Desarrollo a medida (LWC/Apex) | Solo si se justifica | Referencia |
| Standard capability | Capacidad nativa de la plataforma | Primera opción de solución | Referencia |
| Gap funcional | Necesidad no cubierta por el estándar | Disparador de evaluación custom/ADR | Referencia |
| ADR | Architecture Decision Record | Registro de decisiones relevantes (`adr/`) | Referencia |
| Roadmap | Plan de evolución por fases | Secuencia de implementación | Referencia |

---

## 4. Términos Salesforce Base

| Término | Definición | Uso en LvlUp WholeSale / Relación | Estado |
| --- | --- | --- | --- |
| Salesforce Org | Instancia de Salesforce | Entorno del proyecto | MVP |
| Developer Org | Org de edición Developer | Org actual del proyecto | MVP |
| Metadata | Configuración desplegable | Se gestiona aparte de los datos | MVP |
| Data / Records | Registros de negocio | Catálogo, pricing, cuentas, etc. | MVP |
| Object | Entidad de datos | Estructura de registros | Referencia |
| Field | Campo de un objeto | Atributo de datos | Referencia |
| Standard Object | Objeto nativo de la plataforma | Preferido frente a custom | Referencia |
| Custom Object | Objeto creado a medida | Solo con justificación/ADR | Pendiente de validación |
| Custom Field | Campo creado a medida | Solo si se valida la necesidad | Pendiente de validación |
| Record | Instancia de un objeto | Dato concreto | Referencia |
| Permission Set | Conjunto de permisos asignable | Control de acceso (nombres por validar) | Pendiente de validación |
| Permission Set Group | Agrupación de Permission Sets | Gestión de permisos | Pendiente de validación |
| Profile | Perfil base de usuario | Acceso base; no se definen nombres | Pendiente de validación |
| Sharing | Reglas de compartición de registros | Aislamiento por cuenta | Pendiente de validación |
| Flow | Automatización declarativa | Antes que Apex cuando sea mantenible | MVP |
| Apex | Lenguaje de código de Salesforce | Solo lógica compleja/integración | Futuro |
| LWC | Lightning Web Components | UI custom solo si se justifica | Futuro |
| Salesforce DX | Modelo de desarrollo/herramientas | Estructura del proyecto | Referencia |
| Deployment | Despliegue de metadata | Separado de la carga de datos | Referencia |
| Sandbox | Entorno de pruebas | No usado aún (Developer Org) | Referencia |

---

## 5. Términos Experience Cloud / Storefront

| Término | Definición | Uso en LvlUp WholeSale / Relación | Estado |
| --- | --- | --- | --- |
| Experience Cloud | Plataforma de sitios/portales | Capa de experiencia del storefront | MVP |
| Experience Builder | Editor de la experiencia | Primera opción de configuración UI | MVP |
| Site | Sitio de Experience Cloud | Contenedor del storefront | MVP |
| Webstore | Tienda B2B Commerce | Núcleo del comercio | MVP |
| Storefront | Frontal de la tienda | Lo que ve el buyer | MVP |
| Page | Página de la experiencia | Home, PLP, PDP, etc. | MVP |
| Component | Componente de página | Estándar antes que custom | MVP |
| Theme | Tema visual | Branding básico | MVP |
| Navigation | Navegación del sitio | Categorías y accesos | MVP |
| Header | Cabecera global | Logo, search, cart, cuenta | MVP |
| Footer | Pie del sitio | Soporte/ayuda | MVP |
| Home Page | Página de inicio | Orientada a recurrencia | MVP |
| Login Page | Página de acceso | Autenticación del buyer | MVP |
| My Account | Área de cuenta | Datos y accesos del buyer | MVP |
| Mobile-first | Diseñar primero para móvil | Principio UX del proyecto | MVP |
| Responsive design | Diseño adaptable | Desktop y mobile | MVP |

---

## 6. Términos B2B Commerce

| Término | Definición | Uso en LvlUp WholeSale / Relación | Estado |
| --- | --- | --- | --- |
| Salesforce B2B Commerce | Solución de comercio B2B | Base del proyecto | MVP |
| Commerce App | Aplicación de gestión de Commerce | Administración del store | Pendiente de validación |
| Commerce Setup | Configuración de Commerce | Setup del store | Pendiente de validación |
| Webstore | Tienda B2B | Contenedor del comercio | MVP |
| Product Catalog | Catálogo de productos | Organiza el surtido | MVP |
| Product Category | Categoría de productos | Navegación del catálogo | MVP |
| Product | Producto vendible (concepto) | Núcleo de PLP/PDP | MVP |
| Product2 | Objeto estándar de producto | Registros de producto | MVP |
| SKU | Identificador de referencia | Identifica productos (`LVL-*`) | MVP |
| Product Detail Page | Página de detalle de producto | Decisión de compra | MVP |
| Product Listing Page | Página de listado | Comparar productos | MVP |
| PLP | Sigla de Product Listing Page | Listado por categoría/búsqueda | MVP |
| PDP | Sigla de Product Detail Page | Detalle del producto | MVP |
| Search | Búsqueda de productos | Respeta visibilidad | MVP |
| Cart | Carrito de compra | Compra en curso | MVP |
| Checkout | Proceso de confirmación | Sin pago real en MVP | MVP |
| Order | Pedido | Resultado del checkout | MVP |
| Order History | Historial de pedidos | Trazabilidad | MVP |
| Reorder | Repetir un pedido | Compra recurrente | MVP |
| Buyer Account | Cuenta compradora | Límite de acceso | MVP |
| Buyer User | Usuario del buyer | Único operativo en MVP | MVP |
| Buyer Group | Agrupación de compradores | Pricing/visibilidad | Pendiente de validación |
| Entitlement | Derecho de acceso a producto | Visibilidad de catálogo | Pendiente de validación |
| Product Visibility | Qué productos ve el buyer | Catálogo restringido | Pendiente de validación |
| Price Book | Libro de precios | Soporta pricing | Pendiente de validación |
| Price Book Entry | Entrada de precio por producto | Precio aplicable | Pendiente de validación |
| Pricing | Precio aplicable | Por cuenta/Buyer Group | MVP |
| Contract Pricing | Pricing negociado por contrato | Posible base de pricing | Pendiente de validación |
| Account-based pricing | Pricing por cuenta | Diferenciación por cliente | Pendiente de validación |
| Catalog visibility | Visibilidad del catálogo | Coherente en todo el journey | Pendiente de validación |

---

## 7. Términos de Catálogo

| Término | Definición | Uso en LvlUp WholeSale / Relación | Estado |
| --- | --- | --- | --- |
| Catalog | Catálogo de productos | Base de navegación (`product-catalog-strategy.md`) | MVP |
| Category | Categoría | Agrupa productos | MVP |
| Product hierarchy | Jerarquía de productos | Estructura del catálogo | Pendiente de validación |
| Product family | Familia de producto | Agrupación funcional | Pendiente de validación |
| Product attributes | Atributos de producto | Datos para PLP/PDP | Pendiente de validación |
| Product image | Imagen de producto | Visualización | MVP |
| Placeholder image | Imagen sustituta | Cuando falta imagen | MVP |
| Active product | Producto activo | Disponible en catálogo | MVP |
| Purchasable product | Producto comprable | Permite añadir al carrito | MVP |
| Restricted product | Producto restringido | No visible para ciertos buyers | MVP |
| Bundle | Paquete de productos | Venta combinada | MVP |
| Enterprise bundle | Bundle para enterprise | Segmento enterprise | MVP |
| Gaming console | Consola de gaming | Categoría ancla | MVP |
| Peripherals | Periféricos | Categoría transversal | MVP |
| Networking | Productos de red | Reseller/empresa | MVP |
| Accessories | Accesorios | Complementos | MVP |

---

## 8. Términos de Pricing y Visibilidad

| Término | Definición | Uso en LvlUp WholeSale / Relación | Estado |
| --- | --- | --- | --- |
| Pricing | Precio aplicable | Personalizado por cuenta/segmento (`PR-*`) | MVP |
| Base price | Precio base | Punto de partida | MVP |
| Segment price | Precio por segmento | Diferenciación por grupo | Pendiente de validación |
| Buyer Group pricing | Pricing por Buyer Group | Segmentación de precio | Pendiente de validación |
| Account-specific pricing | Pricing por cuenta | Precio negociado | Pendiente de validación |
| Price Book | Libro de precios | Soporte de pricing | Pendiente de validación |
| Price Book Entry | Precio por producto | Resolución de precio | Pendiente de validación |
| Product visibility | Visibilidad de producto | Catálogo restringido (`PV-*`) | Pendiente de validación |
| Entitlement | Derecho de visibilidad | Controla acceso a productos | Pendiente de validación |
| Restricted catalog | Catálogo restringido | Subconjunto permitido | MVP |
| Visible product | Producto visible | Aparece para el buyer | MVP |
| Hidden product | Producto oculto | No aparece para el buyer | MVP |
| Price consistency | Consistencia de precio | Igual en PLP/PDP/cart/checkout (`PR-003`) | MVP |
| Price recalculation | Recálculo de precio | En reorder/cambios | MVP |
| Promotion | Promoción | Promociones complejas fuera del MVP | Fuera del MVP |
| Multi-currency | Multi-divisa | Fuera del MVP | Fuera del MVP |

---

## 9. Términos de Carrito y Checkout

| Término | Definición | Uso en LvlUp WholeSale / Relación | Estado |
| --- | --- | --- | --- |
| Cart | Carrito | Compra en curso | MVP |
| Cart item | Línea de carrito | Producto + cantidad | MVP |
| Quantity | Cantidad | Validable | MVP |
| Subtotal | Subtotal de línea | Cálculo de carrito | MVP |
| Total | Total del carrito | Total funcional (sin tax/shipping) | MVP |
| Checkout | Confirmación de compra | Básico en MVP | MVP |
| Checkout validation | Revalidación en checkout | Última barrera funcional | MVP |
| Confirmed order | Pedido confirmado | Pedido firme | MVP |
| Pending request | Solicitud pendiente | Aprobación/cotización | MVP |
| Approval required | Requiere aprobación | Por importe (`BR-APPROVAL-*`) | MVP |
| Credit validation | Validación de crédito | Puede bloquear/condicionar | MVP |
| Stock validation | Validación de stock | Disponibilidad funcional | MVP |
| Insufficient stock | Stock insuficiente | Aviso y bloqueo de cantidad | MVP |
| Backorder | Pedido pendiente de reposición | Decisión pendiente | Futuro |
| ETA | Fecha estimada de entrega | Dato futuro (ERP simulado) | Futuro |
| Tax | Impuestos | Tax real fuera del MVP | Fuera del MVP |
| Shipping | Envío | Shipping real fuera del MVP | Fuera del MVP |
| Payment | Pago | Pagos reales fuera del MVP | Fuera del MVP |

---

## 10. Términos de Orders, Historial y Reorder

| Término | Definición | Uso en LvlUp WholeSale / Relación | Estado |
| --- | --- | --- | --- |
| Order | Pedido | Resultado del checkout | MVP |
| Order status | Estado del pedido | Confirmado/pendiente | MVP |
| Order history | Historial de pedidos | Trazabilidad (`BR-HISTORY-*`) | MVP |
| Order detail | Detalle de pedido | Base del reorder | MVP |
| Reorder | Repetir compra | Revalida pricing/visibilidad/stock | MVP |
| Partial reorder | Reorder parcial | Solo productos válidos | MVP |
| Previous order | Pedido anterior | Origen del reorder | MVP |
| Current pricing | Pricing actual | Se aplica en reorder | MVP |
| Current visibility | Visibilidad actual | Se revalida en reorder | MVP |
| Product no longer available | Producto ya no disponible | Se informa en reorder | MVP |

---

## 11. Términos de Aprobación, Crédito y Cotización

| Término | Definición | Uso en LvlUp WholeSale / Relación | Estado |
| --- | --- | --- | --- |
| Approval | Aprobación de pedido | Por importe | MVP |
| Approval threshold | Umbral de aprobación | Pendiente de definición (`DEC-008`) | Pendiente de validación |
| Approver | Rol que aprueba | Buyer Approver futuro | Futuro |
| Approval request | Solicitud de aprobación | Estado pendiente | MVP |
| Pending approval | Pendiente de aprobación | Diferente de confirmado | MVP |
| Credit status | Estado de crédito | Válido/bloqueado/excedido | MVP |
| Credit limit | Límite de crédito | Reglas pendientes (`DEC-009`) | Pendiente de validación |
| Credit blocked | Crédito bloqueado | Impide la compra | MVP |
| Credit exceeded | Crédito excedido | Impide/condiciona | MVP |
| Quote | Cotización | Condiciones especiales | Futuro |
| Quote request | Solicitud de cotización | Alcance por confirmar | Pendiente de validación |
| Pending quote | Cotización pendiente | No es pedido confirmado | Futuro |

---

## 12. Términos de Integración

| Término | Definición | Uso en LvlUp WholeSale / Relación | Estado |
| --- | --- | --- | --- |
| Integration | Integración con sistemas externos | Futura/simulada | Futuro |
| REST | Estilo de API sobre HTTP | Enfoque de integración | Futuro |
| API | Interfaz de programación | Contrato de integración | Futuro |
| Endpoint | Punto de acceso de la API | No definitivo aún | Pendiente de validación |
| Request | Petición a la API | Contrato conceptual | Futuro |
| Response | Respuesta de la API | Contrato conceptual | Futuro |
| JSON | Formato de datos | Formato esperado | Futuro |
| Callout | Llamada saliente desde Salesforce | Solo en fase de integración | Futuro |
| Named Credential | Configuración segura de callout | Endpoint/credenciales | Futuro |
| External system | Sistema externo | ERP simulado | Futuro |
| ERP | Sistema de gestión empresarial | ERP real fuera del MVP | Fuera del MVP |
| Mock | Doble de pruebas | Aísla integraciones en tests | Futuro |
| Postman Mock Server | Servidor de simulación REST | Simulación inicial del ERP | Futuro |
| Timeout | Tiempo máximo de espera | Manejo de fallos | Futuro |
| Retry | Reintento | Estrategia de resiliencia | Futuro |
| Idempotency | Idempotencia | Operaciones repetibles sin efecto extra | Futuro |
| Error handling | Manejo de errores | Mensajes no técnicos al buyer | MVP |
| Logging | Registro técnico | Controlado; sin datos sensibles | Futuro |
| Traceability | Trazabilidad | Correlación funcional | MVP |

---

## 13. Términos UX

| Término | Definición | Uso en LvlUp WholeSale / Relación | Estado |
| --- | --- | --- | --- |
| UX | Experiencia de usuario | Principios en `ux-principles.md` | MVP |
| UI | Interfaz de usuario | Estándar antes que custom | MVP |
| Journey | Recorrido del comprador | `storefront-journey.md` | MVP |
| Wireframe | Esquema de pantalla | `wireframes.md` (conceptual) | MVP |
| Empty state | Estado vacío | Sin contenido que mostrar | MVP |
| Error state | Estado de error | Mensaje no técnico | MVP |
| Loading state | Estado de carga | Feedback de proceso | MVP |
| Pending state | Estado pendiente | Aprobación/cotización | MVP |
| Restricted state | Estado restringido | Producto no permitido | MVP |
| Validation state | Estado de validación | Condición funcional no cumplida | MVP |
| Microcopy | Textos breves de UI | Claros y accionables | MVP |
| CTA | Llamada a la acción | Botón/acción principal | MVP |
| Product card | Tarjeta de producto | Ítem en PLP | MVP |
| Mobile-first | Primero móvil | Principio de diseño | MVP |
| Responsive | Adaptable | Desktop y mobile | MVP |
| Accessibility | Accesibilidad | Contraste, etiquetas, jerarquía | MVP |

---

## 14. Términos de Seguridad

| Término | Definición | Uso en LvlUp WholeSale / Relación | Estado |
| --- | --- | --- | --- |
| Authentication | Autenticación | Acceso del buyer (`BR-ACCESS-001`) | MVP |
| Authorization | Autorización | Qué puede hacer el buyer | MVP |
| Least privilege | Mínimo privilegio | Principio de seguridad | MVP |
| Access control | Control de acceso | Por cuenta/Buyer Group | MVP |
| Buyer access | Acceso del buyer | Solo su cuenta | MVP |
| Catalog visibility | Visibilidad de catálogo | Seguridad de visibilidad | MVP |
| Pricing visibility | Visibilidad de pricing | Solo su segmento | MVP |
| Permission Set | Conjunto de permisos | Nombres por validar | Pendiente de validación |
| Permission Set Group | Agrupación de permisos | Gestión de acceso | Pendiente de validación |
| Sharing | Compartición de registros | Aislamiento por cuenta | Pendiente de validación |
| Restricted access | Acceso restringido | Productos/datos no permitidos | MVP |
| Direct URL access | Acceso por URL directa | Debe manejarse de forma segura | Pendiente de validación |
| Data exposure | Exposición de datos | Riesgo a evitar | MVP |
| Security gap | Brecha de seguridad | Disparador de ADR | MVP |

---

## 15. Términos de Testing

| Término | Definición | Uso en LvlUp WholeSale / Relación | Estado |
| --- | --- | --- | --- |
| Functional testing | Pruebas funcionales | Basadas en flujos B2B | MVP |
| Regression testing | Pruebas de regresión | Evitar romper lo existente | Futuro |
| Security testing | Pruebas de seguridad | Acceso/visibilidad | MVP |
| UX testing | Pruebas de UX | Mobile/estados | MVP |
| Integration testing | Pruebas de integración | Con mocks (futuro) | Futuro |
| Test data | Datos de prueba | Set MVP (`data-loading-strategy.md`) | MVP |
| Positive scenario | Escenario positivo | Caso esperado correcto | MVP |
| Negative scenario | Escenario negativo | Restricción/bloqueo | MVP |
| Edge case | Caso límite | Stock/crédito/visibilidad | MVP |
| Acceptance criteria | Criterios de aceptación | Derivados de flujos | MVP |
| Validation checklist | Checklist de validación | `org-validation-checklist.md` | MVP |
| Mock response | Respuesta simulada | Pruebas de integración | Futuro |

---

## 16. Términos de Agentes IA

| Término | Definición | Uso en LvlUp WholeSale / Relación | Estado |
| --- | --- | --- | --- |
| AI Agent | Agente de IA especializado | Infraestructura de agentes (`agents/`) | Futuro |
| Orchestrator Agent | Agente coordinador | Enruta entre agentes | Futuro |
| Functional Analyst Agent | Agente de análisis funcional | Requisitos/flujos | Futuro |
| Salesforce Architect Agent | Agente de arquitectura | Decisiones técnicas | Futuro |
| B2B Commerce Specialist Agent | Agente de B2B Commerce | Estrategia de commerce | Futuro |
| UX Specialist Agent | Agente de UX | Experiencia/journey | Futuro |
| Apex Specialist Agent | Agente de Apex | Código Apex | Futuro |
| LWC Specialist Agent | Agente de LWC | Componentes UI | Futuro |
| Flow Specialist Agent | Agente de Flow | Automatización declarativa | Futuro |
| Integration Specialist Agent | Agente de integración | REST/mocks | Futuro |
| QA Specialist Agent | Agente de QA | Testing | Futuro |
| Documentation Specialist Agent | Agente de documentación | Documentación técnica | Futuro |
| Evaluation | Evaluación de calidad | Calidad de respuestas de agentes | Futuro |
| Eval | Caso/suite de evaluación | Vive en `evals/` | Futuro |
| Guardrail | Límite/restricción del agente | Comportamiento seguro | Futuro |
| Prompt | Instrucción al modelo | Vive en `agents/`, no aquí | Futuro |
| System instruction | Instrucción de sistema | Definición de rol | Futuro |
| Context file | Archivo de contexto | Documentos que alimentan al agente | Futuro |

> Los **prompts concretos** de los agentes deben vivir en `agents/` y las
> **evaluaciones** en `evals/`; este glosario solo define el vocabulario.

---

## 17. Términos Fuera del MVP

| Término | Motivo de exclusión | Posible fase futura | Riesgo si se adelanta |
| --- | --- | --- | --- |
| Payment | El MVP valida flujo, no cobro | Futuro posible | Complejidad/cumplimiento |
| Tax | Complejidad fiscal | Futuro posible | Esfuerzo desviado |
| Shipping | Complejidad logística | Futuro posible | Esfuerzo desviado |
| Advanced OMS | Historial básico suficiente | Futuro posible | Sobre-ingeniería |
| Real ERP integration | Dependencia externa | Tras simulación | Acoplamiento prematuro |
| Marketplace | Modelo distinto | No incluido | Cambio de modelo |
| Multi-language | Opera en España | Futuro (expansión) | Esfuerzo desviado |
| Multi-currency | Un solo mercado | Futuro (expansión) | Complejidad de pricing |
| Advanced promotions | No aporta a la base B2B | Futuro posible | Complejidad de pricing |
| Real invoice processing | Fuera del MVP | Futuro | Acoplamiento prematuro |
| Real external pricing engine | No justificado | Futuro si se justifica | Acoplamiento externo |

---

## 18. Términos Pendientes de Validación en la Org

| Término | Qué debe validarse | Documento relacionado | Estado |
| --- | --- | --- | --- |
| Buyer Groups | Disponibilidad y efecto en pricing/visibilidad | `org-validation-checklist.md` §12 | Pendiente de validación |
| Entitlements | Mecanismo de visibilidad | `org-validation-checklist.md` §14 | Pendiente de validación |
| Product visibility | Consistencia en el journey | `pricing-and-visibility-strategy.md` | Pendiente de validación |
| Pricing behavior | Resolución por cuenta/Buyer Group | `org-validation-checklist.md` §13 | Pendiente de validación |
| PLP components | Componentes disponibles | `org-validation-checklist.md` §16 | Pendiente de validación |
| PDP components | Componentes disponibles | `org-validation-checklist.md` §17 | Pendiente de validación |
| Cart standard behavior | Capacidades del carrito | `org-validation-checklist.md` §18 | Pendiente de validación |
| Checkout standard behavior | Capacidades del checkout | `org-validation-checklist.md` §19 | Pendiente de validación |
| Order History | Acceso y alcance | `org-validation-checklist.md` §20 | Pendiente de validación |
| Reorder | Soporte estándar | `org-validation-checklist.md` §21 | Pendiente de validación |
| Permission Sets | Permisos necesarios | `security-model.md` | Pendiente de validación |
| Buyer User setup | Creación/licencia de usuario | `org-validation-checklist.md` §11 | Pendiente de validación |
| Direct URL access behavior | Acceso a PDP restringida por URL | `security-model.md` | Pendiente de validación |
| Experience Builder components | Componentes y límites | `org-validation-checklist.md` §7 | Pendiente de validación |

---

## 19. Reglas de Uso del Glosario

- **Usar estos términos** de forma consistente en toda la documentación.
- **No renombrar** términos Salesforce estándar sin motivo.
- Mantener los **términos técnicos en inglés** cuando son nombres propios o de uso
  amplio.
- **Explicar en español** los términos al usarlos en documentación funcional.
- **Actualizar el glosario** cuando se agregue un concepto nuevo.
- **No usar el glosario para decidir arquitectura**; es referencia terminológica.
- Las **decisiones** viven en `configuration-decisions.md` o en `adr/`.

---

## 20. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general**.
- `docs/business/` define **negocio y reglas**.
- `docs/ux/` define la **experiencia**.
- `docs/architecture/` define la **arquitectura**.
- `docs/salesforce/b2b-commerce-standard-capabilities.md` define las **capacidades
  estándar**.
- `docs/salesforce/data-model.md` define **entidades y relaciones**.
- `docs/salesforce/security-model.md` define la **seguridad Salesforce-relevante**.
- Este documento define el **vocabulario común**.
- `agents/` deberá usar este glosario para **mantener consistencia**.
- `evals/` podrá **validar** si los agentes usan los términos correctamente.
