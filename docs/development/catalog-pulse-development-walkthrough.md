# Guía de Desarrollo - Buyer Group Catalog Pulse (CDC + Platform Events)

Explicación completa de lo que se construyó en el feature _Buyer Group Catalog
Pulse_: qué, cómo, por qué, cómo funciona, y los aprendizajes clave. Organizada
de menos a más profundidad.

---

## 1. Qué construimos: "Buyer Group Catalog Pulse"

Un **feed de novedades de catálogo** para el storefront B2B: cuando un producto cambia (alta, reposición, actualización), aparece automáticamente como una tarjeta en un **carrusel** dentro del sitio, pero **solo para los compradores que están autorizados a ver ese producto**.

El objetivo real era doble:

- **Funcional**: dar a los buyers una sección "Novedades para ti".
- **De aprendizaje**: practicar **Change Data Capture (CDC)**, **Platform Events** y **arquitectura event-driven** en Salesforce, dejando la base lista para una futura acción de **Agentforce**.

---

## 2. La arquitectura: 5 capas desacopladas

```
   Cambio en Product2 (pipeline Platzi o edición manual)
        │
        ▼
  [1] CDC ─────────────  Product2ChangeEvent  (captura el cambio a bajo nivel)
        │  trigger Apex fino
        ▼
  [2] CURACIÓN ────────  LvlupCatalogPulseCuration
        │               decide changeType (NEW/RESTOCK/UPDATED), título, prioridad
        │               y publica ↓
        ▼
  [3] PLATFORM EVENT ──  Catalog_Pulse_Event__e  (evento de NEGOCIO, no copia cruda)
        │  trigger Apex suscriptor
        ▼
  [4] PERSISTENCIA ────  LvlupCatalogPulseSubscriber → Catalog_Pulse_Item__c
        │               (upsert idempotente: el feed consultable)
        ▼
  [5] SERVICIO ────────  LvlupCatalogPulseController.getCatalogPulseForBuyer()
        │               (cacheable + filtra por entitlement del buyer)
        ▼
  [6] UI ──────────────  lvlupCatalogPulseCarousel (LWR)
        │
        ▼
  [FUTURO] Agentforce Action reutiliza el mismo controller
```

**La idea central:** el navegador **no escucha eventos**. Los eventos viven solo en el backend; el LWC consulta **datos ya persistidos** (`Catalog_Pulse_Item__c`). Eso hace la solución robusta, cacheable y consultable por IA.

---

## 3. Recorrido pieza por pieza (cómo funciona cada una)

### [1] Detección — `LvlupProduct2ChangeEventTrigger`

Un trigger de **una línea** sobre `Product2ChangeEvent`. CDC emite un evento cada vez que un `Product2` se crea/edita/borra, **sin importar la fuente** (el pipeline de Platzi, una edición manual en Merchandising, un dataloader…). Ese es el superpoder de CDC frente a "engancharse al pipeline": captura **todo**.

### [2] Curación — `LvlupCatalogPulseCuration`

Traduce el cambio crudo en **significado de negocio**:

- `CREATE`/`UNDELETE` → `NEW` (prioridad HIGH).
- `UPDATE` con subida de inventario → `RESTOCK`.
- Otro `UPDATE` → `UPDATED`.

Y publica un `Catalog_Pulse_Event__e` con título/mensaje legibles. **El evento no es una copia del CDC**: es un hecho de negocio ("nuevo producto disponible"), lo que te permite cambiar la lógica de UI sin tocar la captura.

### [3] Evento de negocio — `Catalog_Pulse_Event__e`

Un **Platform Event** con `Publish After Commit` (solo se publica si la transacción que causó el cambio realmente confirmó). Desacopla al que detecta del que persiste.

### [4] Persistencia — `LvlupCatalogPulseSubscriber` → `Catalog_Pulse_Item__c`

Un trigger sobre el Platform Event materializa el feed. La clave está en `Pulse_Key__c = productId|changeType|segment` como **External Id única**: el `upsert` por esa clave hace que reprocesar el mismo cambio **actualice** la novedad en vez de duplicarla (idempotencia). Cada novedad tiene vigencia (`Expiration_Date__c`, 14 días) y estado (`Status__c`).

### [5] Servicio — `LvlupCatalogPulseController`

`getCatalogPulseForBuyer()`, `@AuraEnabled(cacheable=true)`, `without sharing`. Resuelve el contexto del comprador:

```
Usuario → Contact.AccountId → BuyerGroupMember → políticas (CommerceEntitlementBuyerGroup)
       → productos entitled (CommerceEntitlementProduct)
```

y devuelve **solo** novedades activas, vigentes, de su segmento **y de productos que está entitled a ver**.

### [6] UI — `lvlupCatalogPulseCarousel`

LWC mobile-first con estados loading/empty/error, branding del proyecto, y `@wire` al controller cacheable.

---

## 4. Los 3 conceptos que practicaste (a fondo)

### Change Data Capture (CDC)

Es un mecanismo que **emite un evento por cada cambio de datos** de un objeto. Datos clave que aprendimos en vivo:

- Un **change event de UPDATE trae solo los campos que cambiaron**; el resto llega null (o su default). Esto causó el bug (sección 6).
- CDC **solo dispara si algún valor cambió de verdad**. Un `upsert` idempotente que reescribe lo mismo → sin evento → **sin ruido** (por eso las corridas diarias de Platzi no generan novedades falsas).
- Se testea con `Test.enableChangeDataCapture()` + `Test.getEventBus().deliver()`.

### Platform Events

Mensajería pub/sub desacoplada. Aprendimos:

- `Publish After Commit` para no anunciar cambios que no confirmaron.
- El evento debe expresar **negocio**, no la estructura interna del cambio.
- Se testea publicando el evento y dejando que `Test.stopTest()` haga el _flush_.

### Event-driven / por qué persistir en vez de "streaming al browser"

Los eventos son **efímeros**. Si el LWC escuchara el bus directamente, un buyer que entra "tarde" se perdería las novedades, y no habría nada consultable para Agentforce. Por eso: **evento → dato persistido → consulta**. El bus comunica; el objeto es la fuente de verdad.

---

## 5. Por qué lo hicimos así (las decisiones de diseño)

| Decisión                                                            | Por qué                                                                                                                                                                                          |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Standard-first** (ADR-0002)                                       | La visibilidad la resuelven los **entitlements** estándar y el precio los **price books**. Solo hicimos custom lo que el estándar no da: el feed curado y segmentado.                            |
| **El entitlement es la frontera de seguridad**, no la UI (ADR-0004) | El controller re-valida contra `CommerceEntitlementProduct`. Aunque exista una novedad de un producto, si el buyer no está entitled, **no la ve**. Nunca se filtra desde el front.               |
| **`without sharing`** en el controller                              | En B2B Commerce los productos no se comparten por sharing (la visibilidad la da el entitlement). Con `with sharing` la consulta daría 0 filas. Se compensa con el join de entitlement explícito. |
| **Objeto = metadata, registros = data** (ADR-0003)                  | `Catalog_Pulse_Item__c` se despliega; las novedades se crean en runtime. Sin IDs hardcodeados; el segmento se resuelve por nombre de Buyer Group.                                                |
| **Idempotencia** (`Pulse_Key__c`)                                   | Para que reprocesar eventos o corridas repetidas no dupliquen novedades.                                                                                                                         |
| **Núcleos inyectables** (`buildEvents`, `buildItems`, `queryPulse`) | Separar la lógica pura del acceso a CDC/DML la hace **testeable** sin depender de objetos difíciles de simular.                                                                                  |
| **Híbrida (opción C)** en vez de Flow-first o Apex-sin-CDC          | Era la única que cumplía **los tres objetivos de aprendizaje a la vez** (CDC + Platform Events + event-driven) manteniendo estándar la visibilidad.                                              |

---

## 6. El bug que encontramos (y lo que enseña)

Tu edición de la Description no generaba novedad, pero un alta sí. El log del Automated Process user reveló:

```
ChangeEventHeader {changeType=UPDATE, ...}
"IsActive": false        ← ¡el producto SÍ está activo!
```

**Causa:** en un change event de `UPDATE`, los **campos booleanos no modificados llegan como su default `false`**, no como `null`. Mi guard `if (isActive == false) continue;` descartaba el evento creyendo el producto inactivo. Los `CREATE` traían todos los campos con valores reales, por eso el alta sí funcionaba.

**El fix:** confiar en `IsActive` solo cuando es fiable (altas, o cuando `IsActive` está entre los campos cambiados); si no, asumir activo.

**La lección de oro:** en CDC, un campo que llega en un UPDATE puede ser un valor real **o** un default heredado. Nunca decidas lógica de negocio con el valor de un campo booleano que no está en `getChangedFields()`.

---

## 7. Datos adicionales que descubrimos en la org (gotchas reales)

- **CDC ya estaba habilitado** para `Product2` (miembro del canal estándar `ChangeEvents`), así que el trigger recibía eventos de todas las fuentes.
- **FLS**: para _ver_ los campos del feed en queries/reports hay que asignar el permission set. Sin él, una consulta da `No such column` aunque el campo exista. (En Apex `without sharing` no aplica, por eso el carrusel funciona sin ese permiso.)
- **Cacheable = hard refresh**: como el Apex es `cacheable=true`, el navegador cachea el resultado; hay que recargar (Ctrl+Shift+R) para ver novedades nuevas.
- **PRICE_DROP no se detecta** con CDC de `Product2`, porque el **precio vive en `PricebookEntry`**, no en `Product2`. Queda soportado en el modelo para un futuro CDC de precios.
- **Publish del site** es necesario para ver cambios de código LWC (REGLA-007), pero el Apex aplica al instante.

---

## 8. Estado actual y qué queda

**Desplegado y verificado en la org:** objeto + Platform Event + 2 triggers + 3 clases + LWC + 2 permission sets. **17 tests Apex al 100%** (triggers 100%, curación 94%, subscriber 88%, controller 77%) + **4 Jest** verdes. Pipeline validado en vivo (INSERT y UPDATE generan novedades; 11 novedades visibles en tu carrusel).

**Abierto:**

- `ADR-0007` está en estado **`Proposed`** — cuando valides todo, lo pasamos a `Accepted`.
- Los archivos del repo están **sin commitear**.
- **Iteración 2 posible**: `PRICE_DROP` vía CDC de `PricebookEntry`, afinar `Segment_Key__c` por Buyer Group concreto, y la **Agentforce Action** (`getCatalogPulseForBuyer` / `summarizeNewProductsForBuyer`) reutilizando el controller.

**Dónde leerlo en el repo:** `adr/0007-event-driven-catalog-pulse-architecture.md` (la decisión) y `docs/salesforce/manual-catalog-pulse-cdc-runbook.md` (los pasos operativos, ya corregidos con lo que aprendimos).
