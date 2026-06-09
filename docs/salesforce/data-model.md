# Modelo de Datos - LvlUp WholeSale

## 1. Propósito del Documento

Este documento describe el **modelo de datos conceptual y Salesforce-relevante** del
proyecto `LvlUp-Wholesale-B2B`: entidades funcionales, objetos estándar esperados,
relaciones, datos requeridos para el MVP, datos futuros y la separación entre
metadata y registros.

Sirve como base para:

- Entender las entidades principales del storefront B2B.
- Diferenciar datos de negocio, metadata y configuración.
- Planificar la carga de datos de catálogo.
- Entender las relaciones entre buyer accounts, usuarios, productos, categorías,
  pricing, visibilidad, carrito, órdenes y futuras integraciones.
- Guiar el testing funcional.
- Evitar custom objects o custom fields innecesarios sin justificación.
- Servir como base para decisiones técnicas y ADRs.

Este documento **no define el modelo físico definitivo ni reemplaza la validación
real en Salesforce**. Aplica el principio rector: *Configuration first,
customization only when justified*.

> **Nota de honestidad:** las entidades y objetos se describen a nivel conceptual.
> No se inventan campos custom ni configuración; los objetos/relaciones no
> confirmados se marcan como *pendiente de validación*.

---

## 2. Principios del Modelo de Datos

- Usar **objetos y capacidades estándar** de Salesforce B2B Commerce antes que
  customización.
- **Evitar crear objetos custom** si una capacidad estándar cubre la necesidad.
- **Separar metadata de datos/registros**.
- Mantener el MVP con datos **pequeños, representativos y controlados**.
- **No mezclar** la carga de datos con el despliegue de metadata.
- **Documentar cualquier gap** antes de proponer campos u objetos custom.
- **Validar en la org** antes de asumir disponibilidad de objetos, relaciones o
  campos.
- Mantener **trazabilidad** entre reglas de negocio, datos y pruebas.

---

## 3. Vista Conceptual del Modelo

```text
[Buyer Account]
    └── [Buyer User]
            ↓
        [Buyer Group]
            ↓
[Product Catalog] → [Product Category] → [Product]
            ↓
        [Pricing / Price Book]
            ↓
        [Product Visibility / Entitlement]
            ↓
[Cart] → [Checkout] → [Order]
            ↓
        [Order History / Reorder]

[Futuro]
[ERP Simulado REST] → Stock / Crédito / ETA / Facturas / Estado de Pedido
```

**Nota.** La vista es **conceptual**, de entidades y relaciones funcionales, no un
diagrama físico ni un esquema de objetos confirmado en la org.

---

## 4. Entidades Funcionales

| Entidad funcional | Descripción | Rol en el MVP | Estado |
| --- | --- | --- | --- |
| Buyer Account | Cuenta compradora B2B | Hub del comprador | Pendiente de validación |
| Buyer User | Usuario operativo de la cuenta | Único usuario por cuenta en el MVP | Pendiente de validación |
| Buyer Group | Agrupación de compradores | Pricing y visibilidad | Pendiente de validación |
| Product Catalog | Catálogo de productos | Base de navegación | Pendiente de validación |
| Product Category | Categoría del catálogo | Organización del catálogo | Pendiente de validación |
| Product | Producto vendible | Núcleo de PLP/PDP | Pendiente de validación |
| Pricing | Precio aplicable por cuenta/Buyer Group | Pricing personalizado | Pendiente de validación |
| Product Visibility / Entitlement | Qué productos ve cada buyer | Catálogo restringido | Pendiente de validación |
| Cart | Carrito de compra | Compra en curso | Pendiente de validación |
| Order | Pedido confirmado | Resultado del checkout | Pendiente de validación |
| Order History | Historial de pedidos | Trazabilidad y reorder | Pendiente de validación |
| Stock (funcional) | Disponibilidad de producto | Stock insuficiente | Funcional / futuro |
| Credit (funcional) | Estado de crédito de la cuenta | Validación de crédito | Funcional / futuro |

---

## 5. Mapeo a Objetos Salesforce / B2B Commerce (Esperados)

Objetos estándar **esperados**. Los confirmados por el contexto del proyecto
(`CLAUDE.md`) se indican; el resto queda **pendiente de validación** en la org.

| Entidad funcional | Objeto estándar esperado | Tipo | Estado de validación | Notas |
| --- | --- | --- | --- | --- |
| Webstore | WebStore | Configuración/datos | Confirmado por contexto | Tienda B2B |
| Buyer Account | Account | Datos | Confirmado por contexto | Hub buyer/seller con campos custom |
| Buyer User | User / Contact | Datos | Pendiente de validación | Usuario operativo del buyer |
| Buyer Group | BuyerGroup | Datos | Confirmado por contexto | Pricing y visibilidad |
| Product Catalog | ProductCatalog | Datos | Confirmado por contexto | Catálogo |
| Product Category | ProductCategory | Datos | Confirmado por contexto | Categorías |
| Product | Product2 | Datos | Confirmado por contexto | Productos |
| Pricing | Pricebook2 / PricebookEntry | Datos | Confirmado por contexto | Precios |
| Product Visibility / Entitlement | CommerceEntitlementPolicy (+ relacionados) | Datos/config | Confirmado por contexto | Visibilidad/entitlements |
| Cart | Objeto estándar de carrito (típicamente WebCart y líneas de carrito) | Datos | Pendiente de validación | Nombre exacto por validar |
| Checkout | Proceso estándar de checkout | Proceso | Pendiente de validación | No es un único objeto |
| Order | Objeto estándar de pedido y sus líneas | Datos | Pendiente de validación | Nombre exacto por validar |
| Order History / Reorder | Basado en los pedidos | Datos/funcional | Pendiente de validación | Soporte de reorder por validar |

> **Sobre Account:** el contexto indica que `Account` actúa como hub buyer/seller
> con campos custom (crédito, configuración wholesale, segmentación). **Este
> documento no enumera ni inventa esos API names**; deben validarse y documentarse
> aparte.

---

## 6. Relaciones Principales

| Entidad A | Relación | Entidad B | Notas |
| --- | --- | --- | --- |
| Buyer Account | tiene | Buyer User | Un único usuario operativo en el MVP |
| Buyer Account | pertenece a | Buyer Group | Base de pricing/visibilidad |
| Buyer Group | determina | Pricing | Precio aplicable por grupo/cuenta |
| Buyer Group | determina | Product Visibility | Catálogo permitido |
| Product Catalog | agrupa | Product Category | Organización |
| Product Category | contiene | Product | Clasificación |
| Product | tiene | Pricing | Precio por Price Book/segmento |
| Product | sujeto a | Entitlement | Visibilidad por buyer |
| Buyer User | crea | Cart | Carrito de compra |
| Cart | deriva en | Order | Tras el checkout |
| Order | compone | Order History | Trazabilidad y reorder |

Las cardinalidades y relaciones exactas **deben validarse en la org**.

---

## 7. Datos Requeridos para el MVP

Registros necesarios para un MVP **pequeño y representativo**:

- **Buyer Accounts**: unas pocas cuentas que cubran los segmentos (tienda gaming
  local, reseller, empresa IT, enterprise).
- **Buyer Users**: un usuario operativo por cuenta.
- **Buyer Groups**: grupos que reflejen los segmentos
  (`pricing-and-visibility-strategy.md`).
- **Product Catalog y Categories**: las 8 categorías de
  `product-catalog-strategy.md`.
- **Products**: el set representativo (`LVL-*`) de productos de ejemplo.
- **Pricing**: precios por cuenta/Buyer Group para validar la consistencia.
- **Entitlements/visibilidad**: reglas que permitan probar el catálogo restringido.

Estos son **datos/registros**, no metadata (ver sección 10).

---

## 8. Datos por Entidad (Información Funcional Esperada)

Información **funcional** esperada (no definición de campos custom):

- **Buyer Account**: identificación, segmento/Buyer Group, datos de crédito
  (funcional), configuración wholesale (funcional).
- **Buyer User**: identidad, asociación a la cuenta, acceso.
- **Product**: SKU, nombre, descripción, categoría, imagen/placeholder, estado
  activo, datos útiles para PLP/PDP.
- **Pricing**: precio aplicable por producto y segmento/cuenta.
- **Entitlement/visibilidad**: qué productos/categorías ve cada Buyer Group/cuenta.
- **Cart**: líneas con producto, cantidad, precio y subtotal.
- **Order**: cabecera (estado, fecha, total funcional) y líneas (producto,
  cantidad, precio).
- **Stock (funcional)**: disponibilidad por producto (origen futuro: simulación).
- **Credit (funcional)**: estado/límite de crédito de la cuenta (origen futuro:
  simulación).

Los **API names y la definición física** de estos datos se validan en la org y se
documentan en `configuration-decisions.md`.

---

## 9. Datos Futuros (Integración ERP Simulada)

Datos que provendrán de la **simulación REST** (Postman Mock Server), fuera del MVP
real:

- **Stock disponible**.
- **Precio final**.
- **Estado de crédito**.
- **Fecha estimada de entrega (ETA)**.
- **Estado de pedido**.
- **Facturas**.

Estos datos **no se integran en el MVP**; se documentan en
`integration-architecture.md` y se mapean a flujos en
`security-architecture.md`/`business-rules.md`.

---

## 10. Separación entre Metadata y Datos/Registros

- **Metadata** (desplegable): configuración de la experiencia, automatizaciones,
  permission sets, etc.
- **Datos/registros** (no metadata): catálogo, productos, categorías, pricing,
  Buyer Groups, entitlements, cuentas, carritos y pedidos.
- **Regla clave:** no mezclar el deploy de metadata con la migración de registros.
- Confundirlos genera **despliegues frágiles** y entornos inconsistentes.

---

## 11. Estrategia de Carga de Datos (Conceptual)

A nivel conceptual (el detalle se definirá en `docs/salesforce/`):

- Los **datos de catálogo, pricing y Buyer Groups** se cargan como registros, no
  como metadata.
- La carga debe ser **reproducible** y **acotada** al set del MVP.
- El **orden de carga** debe respetar las dependencias (p. ej. catálogo y categorías
  antes que productos; cuentas y Buyer Groups antes que pricing/entitlements).
- La herramienta concreta (Data Loader, `sf data`, etc.) y los detalles quedan como
  **decisión pendiente** (`DEC-015`).

---

## 12. Trazabilidad Reglas ↔ Datos

| Regla / referencia | Datos implicados |
| --- | --- |
| `BR-ACCESS-001/002` | Buyer User autenticado; pricing por cuenta |
| `PV-001`, `PV-006` | Entitlements / visibilidad por Buyer Group |
| `PR-001`, `PR-002`, `PR-003` | Pricing por cuenta/Buyer Group; consistencia |
| `BR-CART-005` | Carrito revalida visibilidad/pricing/stock |
| `BR-APPROVAL-*` | Total del pedido vs umbral |
| `BR-CREDIT-*` | Estado/límite de crédito de la cuenta |
| `BR-STOCK-*` | Disponibilidad de stock por producto |
| `BR-REORDER-003` | Pedido previo + revalidación de datos actuales |
| `BR-HISTORY-001/002` | Pedidos e historial por cuenta |

---

## 13. Criterios para Custom Objects / Custom Fields

Antes de crear un custom object o custom field:

- Confirmar que **ningún objeto/campo estándar** cubre la necesidad.
- Documentar la **necesidad funcional** y el gap.
- Evaluar contra `standard-vs-custom-framework.md`.
- Valorar el **impacto** en carga de datos, testing, seguridad y mantenibilidad.
- Crear un **ADR** si es una decisión de modelo relevante.
- Mantener el **mínimo** necesario para el MVP.

---

## 14. Supuestos Actuales

- La org tiene **B2B Commerce y un Site activo**.
- Los objetos estándar listados son los **esperados**, pero deben **validarse**.
- El MVP usa **datos pequeños y representativos**.
- `Account` actúa como **hub buyer/seller** con campos custom (no enumerados aquí).
- El **stock y el crédito** son funcionales en el MVP y se simularán a futuro.
- **Metadata y datos** se gestionan por separado.

---

## 15. Decisiones Pendientes

- Disponibilidad y nombres exactos de los objetos de **carrito y pedido** en la org.
- Campos (estándar/custom) necesarios para **producto, pricing y crédito**.
- **Buyer Groups** definitivos y su relación con los segmentos.
- **Entitlements** concretos para el catálogo restringido.
- **Estrategia y herramienta de carga de datos** (`DEC-015`).
- Si algún caso requiere **custom objects/fields** (con ADR).
- Cómo se **representan stock y crédito** hasta la simulación.

---

## 16. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general**.
- `docs/business/product-catalog-strategy.md` define **categorías y productos**.
- `docs/business/pricing-and-visibility-strategy.md` define **pricing y
  visibilidad**.
- `docs/business/business-rules.md` define las **reglas** trazadas a datos.
- `docs/architecture/solution-architecture.md` enmarca el **modelo en la
  arquitectura**.
- `docs/salesforce/b2b-commerce-standard-capabilities.md` documenta las
  **capacidades estándar** asociadas.
- Este documento describe el **modelo de datos conceptual**.
- `docs/salesforce/security-model.md` deberá profundizar en **seguridad de datos**.
- `docs/salesforce/configuration-decisions.md` deberá registrar la **configuración
  real** (objetos, campos, carga).
- `adr/` registrará las **decisiones de modelo relevantes**.
- `docs/testing/` derivará **datos de prueba** de este modelo.
