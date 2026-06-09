# Alcance del MVP - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define el **alcance funcional del MVP** del portal B2B Commerce de
LvlUp WholeSale. Su función es evitar desviaciones, sobre-ingeniería y ambigüedad
durante la implementación, fijando con claridad qué entra en la primera versión,
qué queda fuera, qué depende de decisiones futuras y qué criterios permiten
considerar el MVP como completado.

El documento se apoya en `docs/business/ecommerce-strategy.md`,
`docs/business/buyer-personas.md`, `docs/business/business-rules.md` y
`docs/business/b2b-commerce-flows.md`, y aplica el principio rector del proyecto:
*Configuration first, customization only when justified*.

Este alcance debe **evolucionar mediante decisiones explícitas**, no por cambios
informales (ver sección 12).

---

## 2. Definición del MVP

El MVP es una **primera versión funcional** del storefront B2B que permite a un
comprador autenticado:

- acceder al portal;
- navegar el catálogo;
- buscar productos;
- ver detalles de producto;
- visualizar el pricing aplicable;
- agregar productos al carrito;
- completar un checkout básico;
- consultar el historial de pedidos;
- realizar un reorder;
- contemplar los escenarios funcionales de aprobación por importe, stock
  insuficiente, crédito y catálogo restringido.

El MVP **no busca cubrir todos los escenarios enterprise**, sino validar la base
funcional y arquitectónica del proyecto, priorizando capacidades estándar de
Salesforce B2B Commerce.

---

## 3. Objetivos del MVP

- Validar la experiencia básica de compra B2B end-to-end.
- Practicar la configuración estándar de Salesforce B2B Commerce.
- Simular un flujo enterprise realista y trazable.
- Crear una base sólida para los futuros agentes de IA especializados.
- Documentar reglas, flujos y decisiones de forma estable.
- Mantener el proyecto simple, trazable y extensible.

---

## 4. Alcance Funcional Incluido

Prioridad en formato MoSCoW (ver sección 9). Estado esperado en MVP:
**Incluido** (se implementa con estándar), **Documentado** (comportamiento
definido aunque la automatización se difiera), **Parcial** (reglas exactas
pendientes), **Pendiente** (requiere decisión).

| Área funcional | Funcionalidad | Descripción | Prioridad | Estado esperado en MVP |
| --- | --- | --- | --- | --- |
| Acceso | Login B2B | Acceso autenticado al storefront | Must | Incluido |
| Acceso | Usuario buyer operativo | Único usuario operativo por cuenta en el MVP | Must | Incluido |
| Acceso | Experiencia autenticada | Contexto de cuenta cargado tras el login | Must | Incluido |
| Catálogo | Product Catalog | Catálogo de tecnología y gaming asignado a la cuenta | Must | Incluido |
| Catálogo | Categorías | Agrupación de productos orientada a compra B2B | Must | Incluido |
| Catálogo | PLP | Listado de productos con precio y disponibilidad | Must | Incluido |
| Catálogo | PDP | Detalle de producto con precio y disponibilidad | Must | Incluido |
| Catálogo | Búsqueda | Localización rápida dentro del catálogo visible | Must | Incluido |
| Catálogo | Catálogo restringido | Visibilidad limitada por cuenta o Buyer Group | Should | Incluido |
| Pricing | Pricing por cuenta/Buyer Group | Precios negociados específicos | Must | Incluido |
| Pricing | Consistencia de precio | Mismo precio en PLP, PDP, carrito y checkout | Must | Incluido |
| Pricing | Pricing personalizado | Comportamiento funcional esperado por segmento | Must | Parcial (reglas exactas pendientes) |
| Stock | Visualización de disponibilidad | El comprador identifica si hay stock | Must | Incluido |
| Stock | Manejo de stock insuficiente | Aviso y bloqueo de cantidad no satisfacible | Should | Documentado (comportamiento exacto por confirmar) |
| Stock | Preparación para simulación REST | Diseño que admita stock simulado futuro | Could | Documentado (futuro cercano) |
| Carrito | Agregar productos | Añadir productos visibles y disponibles | Must | Incluido |
| Carrito | Modificar cantidades | Ajustar cantidades por línea | Must | Incluido |
| Carrito | Eliminar productos | Quitar líneas del carrito | Must | Incluido |
| Carrito | Visualizar subtotal | Producto, cantidad, precio y subtotal | Must | Incluido |
| Carrito | Validar restricciones | Reflejar stock, pricing y visibilidad | Should | Incluido |
| Checkout | Checkout básico | Proceso de confirmación simple | Must | Incluido |
| Checkout | Revisión de pedido | Revisar productos, cantidades e importes | Must | Incluido |
| Checkout | Confirmación o derivación | Confirmar o derivar a aprobación | Must | Incluido |
| Checkout | Exclusión pagos/tax/shipping | Sin pago, impuestos ni envío reales | Must | Incluido (exclusión explícita) |
| Historial y Reorder | Historial de pedidos | Consulta de pedidos anteriores | Must | Incluido |
| Historial y Reorder | Detalle de pedido | Detalle de cada pedido | Must | Incluido |
| Historial y Reorder | Reorder | Repetir una compra anterior | Must | Incluido |
| Historial y Reorder | Validación en reorder | Revalidar disponibilidad, pricing y visibilidad | Should | Incluido |
| Aprobación | Aprobación por importe | Escenario de pedido que supera un umbral | Should | Documentado (automatización parcial) |
| Aprobación | Estado pendiente | Distinción entre confirmado y pendiente | Should | Incluido |
| Aprobación | Umbral de aprobación | Valor que dispara la aprobación | Should | Pendiente de decisión |
| Crédito | Validación de crédito | Validar estado/límite antes de confirmar | Should | Parcial / documentado |
| Crédito | Bloqueo o condición | Impedir o condicionar el pedido | Should | Pendiente (reglas exactas) |
| Cotización | Solicitud de cotización | Escenario funcional de quote request | Could | Documentado |
| Cotización | Automatización completa | Workflow completo de quoting | Won't (MVP) | Futuro |

---

## 5. Alcance Técnico Incluido

A nivel técnico, y sin definir todavía implementaciones concretas (que vivirán en
`docs/architecture/`), el MVP contempla:

- Uso de **Salesforce B2B Commerce estándar** como base del storefront.
- Uso de **Experience Builder** para la configuración de la experiencia.
- **Configuración antes que customización** en todas las decisiones.
- Posible uso de **Flow** cuando la automatización sea mantenible de forma
  declarativa.
- Posible uso de **LWC** solo si los componentes estándar no son suficientes.
- Posible uso de **Apex** solo cuando se justifique (lógica compleja,
  integraciones, consistencia transaccional).
- Documentación de decisiones relevantes en **ADRs**.
- **Testing** funcional y técnico según aplique a cada capacidad.

Las implementaciones concretas (modelado de datos, configuración de Buyer Groups,
Price Books, entitlements, etc.) no se definen aquí; corresponden a los documentos
de arquitectura.

---

## 6. Fuera de Alcance del MVP

| Elemento fuera de alcance | Motivo | Posible fase futura |
| --- | --- | --- |
| Pagos reales | El MVP valida flujo funcional, no transacciones financieras | Futuro posible |
| Tax real | Cálculo fiscal fuera del foco del MVP | Futuro posible |
| Shipping real | Cálculo logístico fuera del foco del MVP | Futuro posible |
| OMS avanzado | El historial básico cubre el MVP | Futuro posible |
| Integración real con ERP | Complejidad y dependencia externa | Simulación REST primero; ERP real más adelante |
| Promociones complejas | No aportan a la validación base B2B | Futuro posible |
| Multi-idioma | El MVP opera inicialmente en España | Futuro posible (expansión) |
| Multi-divisa | El MVP opera en un único mercado | Futuro posible (expansión) |
| Marketplace | Modelo distinto al distribuidor-a-reseller | No incluido |
| Pricing avanzado por volumen | No justificado en el MVP | Futuro si se justifica |
| Jerarquía completa de roles buyer | Un único usuario operativo por cuenta basta para el MVP | Futuro si lo requiere el estándar o el negocio |
| Automatización completa de quote request | Excede el alcance funcional del MVP | Fase posterior |
| Automatización completa de approval flow | El umbral y el rol aprobador están pendientes | Fase posterior |

---

## 7. Supuestos del MVP

- Cada buyer account tiene un **único usuario operativo**.
- La jerarquía **Buyer User / Buyer Approver / Buyer Admin** queda prevista para el
  futuro.
- El proyecto opera **inicialmente en España**.
- El **ERP real** está fuera de alcance.
- La **integración REST simulada** (Postman Mock Server) puede agregarse en una
  fase futura.
- El **umbral de aprobación** está pendiente de definición.
- Las **reglas exactas de crédito** están pendientes.
- Los **segmentos de Buyer Groups** están pendientes.
- El diseño **UX prioriza mobile-first** usando capacidades estándar cuando sea
  posible.

---

## 8. Dependencias Funcionales

| Funcionalidad | Depende de | Habilita | Riesgo si no está disponible |
| --- | --- | --- | --- |
| Login B2B | Usuario buyer activo | Pricing, catálogo personalizado, carrito, historial | Sin login no hay experiencia B2B personalizada |
| Catálogo | Productos y categorías asignados | PLP, PDP, búsqueda | Sin catálogo no hay navegación ni compra |
| Pricing | Cuenta o Buyer Group | Compra con precios consistentes | Precios incorrectos o genéricos generan errores de compra |
| Stock | Datos disponibles o simulados | Validación de compra y de stock insuficiente | Sin stock fiable, decisiones de compra erróneas |
| Carrito | Catálogo, pricing, stock | Checkout | Sin carrito no hay flujo de compra |
| Checkout | Carrito | Pedido, aprobación, crédito | Sin checkout no se completan pedidos |
| Historial | Pedidos previos | Reorder, trazabilidad | Sin historial no hay reorder ni autonomía |
| Reorder | Historial, pricing, stock, visibilidad | Compra recurrente rápida | Reorder con datos obsoletos genera errores |
| Aprobación por importe | Checkout, umbral definido | Pedido aprobado | Umbral no definido genera ambigüedad |
| Validación de crédito | Checkout, dato de crédito | Confirmación condicionada | Regla o fuente no definida bloquea ventas |

---

## 9. Prioridades del MVP

Clasificación MoSCoW de las funcionalidades del MVP.

### Must Have

Necesarias para considerar el MVP válido:

- Login B2B y experiencia autenticada.
- Product Catalog, categorías, PLP, PDP y búsqueda.
- Pricing por cuenta/Buyer Group y su consistencia en todo el journey.
- Visualización de disponibilidad de stock.
- Carrito completo (agregar, modificar, eliminar, subtotal).
- Checkout básico con revisión y confirmación.
- Historial, detalle de pedido y reorder.

### Should Have

Importantes pero no bloqueantes para una primera versión:

- Catálogo restringido por cuenta/Buyer Group.
- Manejo de stock insuficiente.
- Escenario de aprobación por importe (al menos documentado).
- Validación funcional de crédito (al menos documentada).
- Validación de restricciones en el reorder.

### Could Have

Deseables si el avance lo permite:

- Solicitud de cotización como escenario funcional.
- Preparación explícita para la simulación REST de stock/crédito.

### Won't Have for MVP

Explícitamente excluidas (ver sección 6):

- Pagos, tax y shipping reales; OMS avanzado; ERP real.
- Promociones complejas; multi-idioma; multi-divisa; marketplace.
- Automatización completa de quote request y de approval flow.
- Jerarquía completa de roles buyer y pricing por volumen no justificado.

---

## 10. Criterios de Éxito del MVP

El MVP se considera completado cuando:

- Un buyer puede **iniciar sesión**.
- Un buyer puede **navegar el catálogo**.
- Un buyer puede **visualizar PLP y PDP**.
- Un buyer puede **ver el pricing aplicable** a su cuenta.
- Un buyer puede **agregar productos al carrito**.
- Un buyer puede **completar un checkout básico**.
- Un buyer puede **consultar el historial** de pedidos.
- Un buyer puede **iniciar un reorder**.
- Los escenarios de **aprobación por importe, stock insuficiente y crédito** están
  documentados o implementados según el alcance definido.
- Las decisiones **estándar vs custom** están justificadas.
- La **documentación base** está actualizada y es coherente.

---

## 11. Riesgos de Scope Creep

- Intentar implementar la **integración real con ERP** demasiado pronto.
- **Customizar componentes estándar** sin justificación frente al principio
  *Configuration first*.
- Crear **demasiados roles buyer** antes de necesitarlos.
- Implementar **promociones complejas** prematuramente.
- **Sobredimensionar** los flujos de approval, quote y credit.
- Mezclar el aprendizaje de B2B Commerce con **demasiada customización** Apex/LWC.
- Convertir la **documentación en burocracia** no accionable.

---

## 12. Reglas para Cambiar el Alcance

Cualquier cambio relevante del alcance del MVP debe:

- Tener una **justificación funcional** clara.
- Evaluarse contra el principio *Configuration first, customization only when
  justified*.
- Identificar su **impacto** en UX, arquitectura, testing y documentación.
- **Actualizar este documento** de forma explícita.
- Crear un **ADR** si implica una decisión arquitectónica relevante.

---

## 13. MVP vs Fases Futuras

| Capacidad | MVP | Fase futura | Comentario |
| --- | --- | --- | --- |
| Login B2B | Sí | — | Base de la experiencia autenticada |
| Catálogo, PLP, PDP, búsqueda | Sí | — | Núcleo de navegación |
| Pricing por cuenta/Buyer Group | Sí | Refinamiento de reglas | Reglas exactas por definir |
| Checkout básico | Sí | — | Sin pago/tax/shipping reales |
| Historial y reorder | Sí | — | Apoyan la recurrencia |
| Aprobación por importe | Documentado | Automatización completa | Umbral y aprobador pendientes |
| Validación de crédito | Parcial | Reglas y fuente definitivas | Pendiente de decisión |
| Solicitud de cotización | Opcional | Automatización completa | Alcance MVP por confirmar |
| Postman Mock Server (REST) | No | Futuro cercano | Simulación de stock/crédito |
| Pagos reales | No | Futuro posible | Fuera del foco del MVP |
| ERP real | No | Futuro | Simulación REST primero |
| OMS avanzado | No | Futuro posible | Historial básico suficiente |
| Multi-idioma | No | Futuro posible | Ligado a expansión regional |
| Multi-divisa | No | Futuro posible | Ligado a expansión regional |
| Marketplace | No | No incluido | Modelo distinto al del negocio |

---

## 14. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general** del proyecto y del negocio.
- `docs/business/ecommerce-strategy.md` define la **estrategia de e-commerce B2B**.
- `docs/business/buyer-personas.md` define los **perfiles de comprador**.
- `docs/business/business-rules.md` define las **reglas de negocio**.
- `docs/business/b2b-commerce-flows.md` define los **flujos funcionales**.
- Este documento **delimita el alcance del MVP**.
- Las **decisiones técnicas** deberán documentarse en `docs/architecture/`.
- Los **casos de prueba** deberán derivarse luego en `docs/testing/` o `evals/`.
- Las **decisiones importantes** deberán registrarse en `adr/`.
