# Arquitectura de Solución - LvlUp WholeSale

## 1. Propósito del Documento

Este documento describe la **arquitectura general de solución** del proyecto
`LvlUp-Wholesale-B2B`: cómo se alinean el negocio B2B, la experiencia UX,
Salesforce B2B Commerce, Experience Cloud, los datos, la seguridad, la
automatización, la integración futura, el testing y la documentación.

Sirve como base para:

- Alinear negocio, UX y tecnología.
- Guiar decisiones de implementación.
- Evitar la sobre-ingeniería.
- Identificar los componentes de Salesforce involucrados.
- Definir responsabilidades por capa.
- Preparar futuras decisiones técnicas.
- Servir como base para ADRs.
- Servir como contexto para los agentes de IA especializados.

Este documento **no reemplaza la documentación oficial de Salesforce** ni define la
configuración técnica final. Aplica el principio rector del proyecto:
*Configuration first, customization only when justified*, y se apoya en
`docs/architecture/standard-vs-custom-framework.md`.

---

## 2. Resumen Ejecutivo de la Solución

LvlUp WholeSale es un **storefront B2B** para compradores autenticados, construido
sobre **Salesforce B2B Commerce** y **Experience Cloud**:

- Storefront B2B para **compradores autenticados**.
- **Catálogo** de tecnología y gaming.
- **Pricing y visibilidad** según la cuenta o el Buyer Group.
- **Carrito y checkout básico**.
- **Historial y reorder**.
- **Flujos funcionales** de aprobación por importe, crédito y stock.
- **Integración ERP real fuera del MVP**, con posible **simulación REST** futura.
- Uso prioritario de **capacidades estándar** de Salesforce.

La solución prioriza la configuración estándar y reserva la customización para
necesidades funcionales claramente justificadas.

---

## 3. Principios Arquitectónicos

- *Configuration first, customization only when justified*.
- **Estándar de Salesforce B2B Commerce** antes que customización.
- **Experience Builder** antes que LWC custom.
- **Flow** antes que Apex cuando sea mantenible.
- **Apex** solo para lógica compleja, integraciones o control transaccional.
- **Integraciones externas** solo cuando el dato o el proceso no viva en Salesforce.
- Documentar las decisiones relevantes mediante **ADRs**.
- Mantener el **MVP controlado y extensible**.
- **Separar** metadata, datos y documentación.
- Diseñar pensando en **mantenibilidad y testing**.

---

## 4. Vista de Alto Nivel

```text
[Buyer B2B]
    ↓
[Experience Cloud / Storefront]
    ↓
[Salesforce B2B Commerce]
    ↓
[Datos Salesforce: Account, Products, Catalog, Pricing, Buyer Groups]
    ↓
[Automatización: Flow / Apex si se justifica]
    ↓
[Integraciones futuras: ERP simulado REST / Postman Mock Server]
```

**Nota.** La vista es conceptual y de responsabilidades, no un diagrama de
despliegue ni de configuración. Cada capa se detalla en las secciones siguientes.

---

## 5. Capas de la Solución y Responsabilidades

| Capa | Responsabilidad | Tecnología preferida |
| --- | --- | --- |
| Experiencia | Presentación, navegación y journey del comprador | Experience Cloud + Experience Builder (LWC solo si se justifica) |
| Comercio | Catálogo, carrito, checkout, pedidos | Salesforce B2B Commerce estándar |
| Datos | Cuentas, productos, categorías, pricing, visibilidad, pedidos | Modelo estándar de B2B Commerce + datos del MVP |
| Automatización | Reglas de negocio, aprobación, validaciones | Flow primero; Apex si se justifica |
| Seguridad | Autenticación, visibilidad y acceso por cuenta/Buyer Group | Permission Sets, Buyer Groups, sharing estándar |
| Integración | Datos externos (stock, crédito, ERP) | Simulación REST futura (fuera del MVP real) |

Cada capa tiene una responsabilidad acotada; la lógica de negocio no debe filtrarse
a la capa de experiencia ni los datos confundirse con metadata.

---

## 6. Componentes de Salesforce Involucrados

A nivel conceptual, la solución se apoya en los siguientes bloques estándar
(su configuración concreta se validará y documentará en `docs/salesforce/`):

- **Experience Cloud / Site**: storefront LWR donde vive la UI del portal.
- **Salesforce B2B Commerce**: catálogo, carrito, checkout y pedidos.
- **Modelo de datos de Commerce**: objetos estándar de producto, catálogo, pricing,
  Buyer Groups y entitlements (ver sección 7).
- **Account**: hub del comprador B2B y de sus datos de buyer/seller.
- **Automatización declarativa (Flow)** y, si se justifica, **Apex**.
- **Permission Sets / Permission Set Groups** para el control de acceso.
- **Named Credentials / Remote Site Settings** para callouts (solo en la fase de
  integración).

Este documento **no afirma configuración concreta** (campos, reglas o valores); la
describe a nivel arquitectónico.

---

## 7. Modelo de Datos Conceptual (B2B Commerce)

Objetos estándar del modelo de B2B Commerce que intervienen, según el contexto del
proyecto:

- **WebStore**: la tienda B2B.
- **Product2**: productos del catálogo.
- **ProductCatalog / ProductCategory**: catálogo y categorías.
- **Pricebook2 / PricebookEntry**: pricing.
- **BuyerGroup**: agrupación de compradores para pricing y visibilidad.
- **CommerceEntitlementPolicy**: visibilidad/entitlements del catálogo.
- **Account**: cuenta del comprador B2B (con campos de buyer/seller, base para
  crédito y segmentación).
- **Objetos estándar de carrito y de pedido**: soportan carrito, checkout,
  historial y reorder (sus nombres y relaciones concretas se confirmarán en
  `docs/salesforce/`).

> **Importante:** el catálogo, los productos, los precios y los entitlements son
> **datos/registros**, no metadata desplegable. La estrategia de carga de datos se
> documentará por separado (ver secciones 14 y 19).

---

## 8. Capa de Experiencia (Experience Cloud / Storefront)

- La UI del portal vive en el **storefront LWR** de Experience Cloud.
- **Experience Builder** es la primera opción para layout, páginas, navegación,
  Home y componentes estándar.
- El **LWC custom** se reserva para necesidades UX críticas no cubiertas por el
  estándar (ver `standard-vs-custom-framework.md` §5).
- La experiencia es **mobile-first y responsive** y respeta los principios y
  guidelines de `docs/ux/`.
- Los estados transversales (loading, empty, error, pending) siguen
  `docs/ux/empty-error-loading-states.md`.

---

## 9. Capa de Automatización (Flow / Apex)

- **Flow primero** para automatizaciones declarativas y mantenibles (p. ej.
  orquestación de aprobación por importe si el estándar no la cubre).
- **Apex** solo para lógica compleja, transaccionalidad, validaciones no viables en
  Flow, servicios para LWC o integraciones.
- La aprobación por importe y la validación de crédito se **documentan a nivel
  funcional** y se evalúan con estándar/Flow antes de considerar Apex
  (`BR-APPROVAL-*`, `BR-CREDIT-*`).
- Toda automatización debe respetar governor limits y contar con testing.

---

## 10. Seguridad y Control de Acceso

- **Autenticación**: solo compradores autenticados acceden a la experiencia B2B
  completa (`BR-ACCESS-001`).
- **Visibilidad por cuenta/Buyer Group**: el catálogo y el pricing dependen del
  Buyer Group o la cuenta (`PV-*`, `PR-*`); lo restringido no se muestra.
- **Permission Sets / Permission Set Groups**: gobiernan el acceso a
  funcionalidades; cualquier capacidad nueva puede requerir actualizarlos.
- **Un único usuario operativo por cuenta** en el MVP; la jerarquía Buyer
  User/Approver/Admin es futura (`BR-ACCESS-005`, `BR-ACCESS-006`).
- El modelo de seguridad detallado se documentará en `docs/salesforce/security-model.md`.

---

## 11. Capa de Integración (Futura)

- El **ERP real está fuera del MVP**.
- La integración será **simulada a futuro** mediante **REST / Postman Mock Server**.
- Datos candidatos a simular: stock, pricing final, estado de crédito, estado de
  pedido, fecha estimada de entrega y facturas.
- **Named Credentials** y **Remote Site Settings** se usarán cuando la fase de
  integración lo requiera; los **callouts** solo entonces.
- Los **contratos request/response** se documentarán y la integración se aislará
  con **mocks** en los tests.
- La arquitectura de integración detallada vivirá en
  `docs/architecture/integration-architecture.md`.

---

## 12. Mapeo de Capacidades del MVP a la Arquitectura

| Capacidad MVP | Capa principal | Enfoque preferido |
| --- | --- | --- |
| Catálogo y categorías | Comercio + Datos | Estándar + configuración de datos |
| PLP / PDP | Experiencia + Comercio | Estándar / Experience Builder |
| Pricing personalizado | Datos | Price Books / Buyer Groups |
| Visibilidad por Buyer Group/cuenta | Datos + Seguridad | Entitlements / Buyer Groups estándar |
| Carrito | Comercio | Estándar |
| Checkout básico | Comercio | Estándar (sin pago/tax/shipping reales) |
| Historial y detalle de pedido | Comercio + Datos | Estándar |
| Reorder | Comercio | Estándar; revalida pricing/stock/visibilidad |
| Aprobación por importe | Automatización | Estándar/Flow; documentado |
| Validación de crédito | Automatización + Integración futura | Documentado; simulación futura |
| Stock funcional | Datos + Integración futura | Funcional; simulación REST futura |

---

## 13. Aplicación del Framework Estándar vs Custom

Esta arquitectura **opera bajo** `docs/architecture/standard-vs-custom-framework.md`:

- Toda capacidad se resuelve primero con **estándar/configuración**.
- El **LWC/Apex/integración** requiere justificación y, cuando aplica, **ADR**.
- Las decisiones relevantes (LWC central, Apex de lógica core, integración,
  excepción al estándar, cambio de alcance) se registran en `adr/`.
- La matriz de decisión por tipo de requerimiento del framework es la referencia
  para evaluar cada caso.

---

## 14. Estrategia de Datos vs Metadata

- **Metadata** (desplegable): configuración de la experiencia, automatizaciones,
  permission sets, etc.
- **Datos/registros** (no metadata): catálogo, productos, categorías, pricing,
  Buyer Groups y entitlements.
- **No mezclar** el deploy de metadata con la migración de registros.
- La **estrategia de carga de datos** del MVP (catálogo, pricing, Buyer Groups) se
  documentará en `docs/salesforce/` cuando el proyecto llegue a esa fase.

---

## 15. Testing y Mantenibilidad

- **Testing funcional**: derivado de los flujos (`docs/business/b2b-commerce-flows.md`)
  y de las reglas (`docs/business/business-rules.md`), documentado en
  `docs/testing/`.
- **Testing técnico**: test classes de Apex y pruebas de LWC cuando existan.
- **Mocks**: obligatorios para aislar integraciones en los tests.
- **Mantenibilidad**: priorizar el estándar y lo declarativo; mantener Flows y LWC
  pequeños y con responsabilidad clara; preservar la upgradeability.

---

## 16. Riesgos Arquitectónicos

- **Customizar demasiado pronto** sin validar el estándar.
- **Mezclar data y metadata** en los despliegues.
- Usar **Apex/Flow** más allá de su ámbito adecuado.
- **Romper la upgradeability** del storefront estándar.
- Implementar **integración real antes de necesitarla**.
- No considerar **seguridad/permisos** ni **mobile**.
- **No documentar** decisiones relevantes (ausencia de ADRs).
- Sobredimensionar el MVP.

---

## 17. Supuestos Actuales

- La Developer Org tiene **B2B Commerce y un Site activo**.
- Se prioriza el **estándar** y el aprendizaje de la plataforma.
- El **ERP real está fuera** del MVP.
- Los datos de catálogo/pricing pueden requerir una **estrategia de carga** propia.
- Algunas **capacidades estándar deben validarse en la org** antes de decidir.
- El MVP asume **un único usuario operativo por cuenta**.

---

## 18. Decisiones Pendientes

- Capacidades estándar realmente disponibles para PLP/PDP/carrito/checkout.
- Nombres y relaciones concretas de los objetos de carrito/pedido en la org.
- Estrategia final de Buyer Groups y de pricing.
- Si la aprobación requiere Flow, estándar o custom.
- Si el crédito se documenta, simula o automatiza, y su fuente de datos.
- Modelo de seguridad detallado (permission sets, sharing).
- Momento de introducir la simulación REST (Postman Mock Server).
- Qué decisiones requerirán ADR.

---

## 19. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general** del proyecto.
- `docs/business/` define **negocio, reglas, flujos y alcance**.
- `docs/ux/` define la **experiencia y el comportamiento esperado**.
- `docs/architecture/standard-vs-custom-framework.md` define el **framework de
  decisión** que rige esta arquitectura.
- Este documento define la **arquitectura de solución general**.
- `docs/architecture/integration-architecture.md` deberá definir la **integración**.
- `docs/architecture/security-architecture.md` deberá definir la **seguridad**.
- `docs/architecture/limitations-and-assumptions.md` deberá recoger **límites y
  supuestos técnicos**.
- `docs/salesforce/` deberá documentar las **capacidades, el modelo de datos y la
  configuración**.
- `adr/` registrará las **decisiones relevantes**.
- `agents/` deberá usar esta arquitectura como **contexto** para sus
  recomendaciones.
- `evals/` podrá **evaluar** si los agentes la respetan.
