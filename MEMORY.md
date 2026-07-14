# MEMORY.md

## Propósito

Memoria operativa **ligera** de `LvlUp-Wholesale-B2B`. Captura reglas,
preferencias e instrucciones recurrentes que el usuario indica durante el
trabajo diario y que **todavía no están** en la documentación formal del
proyecto.

No sustituye a `PROJECT_CONTEXT.md`, `CLAUDE.md`, `docs/DOCUMENTATION_INDEX.md`,
`docs/development/`, `docs/architecture/`, `docs/salesforce/`, `agents/`,
`evals/` ni `adr/`. Cuando una regla ya vive en uno de esos documentos, esa es
la **fuente de verdad**: aquí no se duplica.

---

## Uso obligatorio

- Antes de ejecutar una tarea, Claude lee este archivo junto con
  `CLAUDE.md` y `PROJECT_CONTEXT.md`.
- Si una instrucción del usuario introduce una regla nueva que no existe en la
  documentación actual, Claude **pregunta antes** de añadirla aquí.
- Claude **nunca** añade reglas automáticamente sin confirmación explícita del
  usuario.

---

## Criterios para añadir una regla

Añadir aquí **solo si** la regla:

- Es recurrente o reutilizable.
- Afecta cómo se trabaja en el proyecto.
- No está ya documentada en otro `.md`.
- No contradice el MVP, los ADRs ni el principio _standard-first_.
- No merece todavía un ADR ni una actualización formal de documentación.

**No** añadir aquí:

- Decisiones arquitectónicas relevantes (→ `adr/`).
- Cambios de alcance (→ `docs/business/mvp-scope.md`, ADRs).
- Reglas ya documentadas (p. ej. naming → `docs/development/naming-conventions.md`).
- Preferencias temporales o de una sola tarea.
- Información que pertenezca claramente a otro documento existente.

---

## Flujo de captura (ejemplo)

Demuestra el comportamiento esperado cuando el usuario corrige con una regla
aparentemente reutilizable.

> Usuario: _"Evita usar guiones o caracteres especiales al nombrar funciones.
> Usa nombres cortos, descriptivos y en camelCase."_

1. Claude verifica primero si la regla ya está documentada.
2. En este caso **sí lo está**: vive en `docs/development/naming-conventions.md`
   (§7 Apex Methods, §10 LWC JavaScript, §19 tabla resumen) —
   `mi-funcion()` → `miFuncion()`.
3. Por tanto Claude responde indicando **dónde** está definida y la aplica;
   **no** la añade a `MEMORY.md`.

Si la regla **no** estuviera documentada, Claude preguntaría:
_"Esta regla no parece estar documentada todavía. ¿Quieres que la añada a
`MEMORY.md`?"_, y solo la añadiría tras confirmación explícita.

---

## Reglas operativas

> Reglas operativas reutilizables descubiertas durante el desarrollo del feature
> _Contextual Quick Buy_ (sesión 2026-06-23), añadidas a petición explícita del
> usuario. Son lecciones recurrentes de B2B Commerce/LWR que ahorran tiempo en
> features futuros. El detalle completo vive en
> `docs/development/contextual-quick-buy-code-walkthrough.md`,
> `docs/salesforce/manual-inventory-setup-runbook.md` y
> `docs/ux/contextual-quick-buy-architecture.html`.

### REGLA-001 — Probar el storefront como Buyer real, no como Admin

- **Regla:** Para validar UI, visibilidad, precios, carrito o Apex de comprador, iniciar sesión como un **Buyer User real** en el sitio **publicado**. El Admin salta entitlements y sharing → oculta bugs. El "Preview as Authenticated User" del Builder es poco fiable; las extensiones tipo Adblock rompen el preview.
- **Ámbito:** QA / B2B Commerce.
- **Origen:** Sesión 2026-06-23 (Contextual Quick Buy).

### REGLA-002 — Cadena de habilitación de un Buyer de prueba

- **Regla:** Crear un comprador: Account → habilitar como Buyer (`BuyerAccount.IsActive = true`; **no** basta `BuyerStatus`) → `BuyerGroupMember` (hereda entitlement + price book) → Contact → Customer Community Plus User + membresía del sitio → contraseña. En dev org no llega el email de bienvenida → fijar con `System.setPassword`. "Habilitar buyer" y "añadir al grupo" van en **transacciones Apex separadas**.
- **Ámbito:** B2B Commerce / datos.
- **Origen:** Sesión 2026-06-23.

### REGLA-003 — Visibilidad de productos = entitlement + reindex

- **Regla:** Un buyer solo ve productos listados en `CommerceEntitlementProduct` de la política de su Buyer Group. Precio + categoría **no bastan**. Tras altas o cambios de entitlement, **reconstruir el índice de búsqueda**. Los seed scripts de catálogo deben entitlar cada producto.
- **Ámbito:** B2B Commerce / datos.
- **Origen:** Sesión 2026-06-23.

### REGLA-004 — Apex de storefront: `without sharing` + acceso a la clase

- **Regla:** Controllers llamados por compradores que consulten `Product2`/objetos de commerce deben ser **`without sharing`** (`with sharing` → 0 filas para el buyer, porque la visibilidad la da el entitlement, no el sharing). Además, conceder al perfil/permission set del buyer **acceso a la clase Apex** (si falta → `400` en `/webruntime/api/apex/execute`).
- **Ámbito:** Apex / B2B Commerce.
- **Origen:** Sesión 2026-06-23.

### REGLA-005 — PLP custom por producto: Grid + "Nested Expression"

- **Regla:** La "Results" estándar no admite hijos. Para inyectar componentes por card: **Grid (Repeaters)** con data source **Nested Expression** = `{!Search.Results.cardCollection}`, prefijo `Item`, + Product Card (`{!Item}`). Paths del item: `{!Item.id}`, SKU `{!Item.fields.StockKeepingUnit.value}`, imagen `{!Item.defaultImage.url}`. Las `@api` de componentes custom **no tienen autocompletado** en el Builder (teclear la expresión a mano).
- **Ámbito:** Experience Builder / LWC.
- **Origen:** Sesión 2026-06-23.

### REGLA-006 — Imágenes CMS con URL externa no renderizan en la card del grid

- **Regla:** Imágenes `sfdc_cms__image` con URL externa (0 File Storage) se ven en la **PDP** pero **no** en la miniatura de la Product Card del grid (no genera renditions). Workaround: LWC propio que pinte la URL (`lvlupProductImage`).
- **Ámbito:** B2B Commerce / LWC.
- **Origen:** Sesión 2026-06-23.

### REGLA-007 — Cambios de código LWC requieren Publish; Apex es inmediato

- **Regla:** En LWR, los cambios de **código LWC** se sirven cacheados → **republicar** el sitio (Experience Builder → Publish) para verlos. Los cambios de **Apex** aplican al instante.
- **Ámbito:** Deploy / LWR.
- **Origen:** Sesión 2026-06-23.

---

> Reglas de la sesión de **integración de productos externos (Platzi → `Product2`)**,
> sesión 2026-06-29, añadidas a petición explícita del usuario. Complementan (no
> duplican) REGLA-003/004/006/007, que se reaplicaron en esta integración. El flujo
> completo explicado vive en
> `docs/salesforce/integracion-productos-externos-guion-narrativo.md`.

### REGLA-008 — Callout antes de DML; patrón async para integraciones programadas

- **Regla:** Apex prohíbe hacer un **callout después de un DML** en la misma transacción. En una orquestación (importar + publicar), el **callout va primero** y luego todo el DML. Para correrlo programado, usar **`Schedulable` → `System.enqueueJob` → `Queueable implements Database.AllowsCallouts`** (el callout corre en el Queueable, no en el Schedulable).
- **Ámbito:** Apex / integraciones.
- **Origen:** Sesión 2026-06-29 (Platzi).

### REGLA-009 — Desplegar clases en la cadena de un job programado

- **Regla:** No se puede recompilar una clase que esté en la **cadena de dependencias de un job Scheduled activo** (error "This schedulable class has jobs pending"). Flujo: **abortar el job** (`System.abortJob`) → desplegar → **reprogramar**. Alternativa: habilitar "Deploy with Apex jobs pending" en Deployment Settings.
- **Ámbito:** Deploy / Apex.
- **Origen:** Sesión 2026-06-29.

### REGLA-010 — Límite de 40 caracteres en identificadores Apex

- **Regla:** Los nombres de clase/identificadores Apex topan en **40 caracteres**. El test `<Clase>Test` de una clase con nombre largo suele pasarse del límite → abreviar (p. ej. `LvlupExternalProductEntitlementPublisher` + `Test` = 44 → `LvlupExtProductEntitlementPublisherTest`). Verificar el largo al nombrar antes de desplegar.
- **Ámbito:** Apex.
- **Origen:** Sesión 2026-06-29.

### REGLA-011 — Testabilidad de objetos CMS/commerce → inyección de dependencias

- **Regla:** Algunos objetos **no son insertables en tests** (`ManagedContent`) o su DML está restringido en contexto de test (`ProductMedia`). Diseñar la clase con un **método core que reciba los datos por parámetro** (Map/Set/Ids) más un método público que los descubra por SOQL; el test inyecta datos y valida la lógica sin depender de esos objetos. `CommerceEntitlementPolicy`/`CommerceEntitlementProduct` y `ProductCatalog`/`ProductCategory` **sí** son insertables. Para PBE estándar en test: `Test.getStandardPricebookId()`.
- **Ámbito:** Apex / testing.
- **Origen:** Sesión 2026-06-29.

### REGLA-012 — Import de imágenes al CMS = referencia por URL, no binario

- **Regla:** El paquete de import de Managed Content (Enhanced CMS) para imagen por URL usa `content.json` con **`type: "sfdc_cms__image"` y `source.type: "url"`** apuntando a la URL externa (`fileSize`/`mimeType` en `null`), **sin** carpeta `_media/` ni `ref`. El `title` pasa a ser `ManagedContent.Name`. El ZIP debe usar rutas con **`/`** (el `Compress-Archive` de PowerShell 5 usa `\` y rompe el import → construir el ZIP con rutas `/`). Generador: `scripts/cms/generate-platzi-image-package.mjs`.
- **Ámbito:** B2B Commerce / CMS.
- **Origen:** Sesión 2026-06-29.

### REGLA-013 — Imágenes de productos EXTERNOS en el storefront (extiende REGLA-006)

- **Regla:** El LWC `lvlupProductImage` usa `{!Item.defaultImage.url}` si existe; si no, **fallback `<baseUrl = GitHub del repo>/<SKU>.png`** (así se sirven los internos, alojados en `data/product-images/<SKU>.png`). Para productos **externos** con imagen en su propio host, `defaultImage.url` llega **vacío** y el fallback GitHub da 404. Solución: alimentar la URL **per-SKU vía Apex cacheable** (`LvlupProductImageController.getExternalImageUrls` → `Map<SKU,URL>`), que el LWC prioriza; y añadir el host externo como **Trusted URL** (`CspTrustedSite`, `img-src`) o la CSP lo bloquea (`ERR_BLOCKED_BY_ORB`). El casado imagen↔producto es por **`ManagedContent.Name = Product2.ProductCode`**.
- **Ámbito:** B2B Commerce / LWC / CSP.
- **Origen:** Sesión 2026-06-29.

### REGLA-014 — Contraste de inputs = token `FormElementTextColor` del branding

- **Regla:** Texto invisible en inputs (blanco sobre blanco) = el token del branding set **`FormElementTextColor`** está en `var(--dxp-g-root-contrast)` (blanco en el tema oscuro) mientras el fondo del input es blanco. Fijarlo a un oscuro (p. ej. `#1A1A1A`) en el branding set arregla **todos los inputs estándar** de golpe, sin tocar títulos/banners (esos usan `Heading*Color`, que quedan en blanco). Fuente: `…/sfdc_cms__brandingSet/B2B_Commerce/content.json`.
- **Ámbito:** UX / branding / storefront.
- **Origen:** Sesión 2026-06-29.

### REGLA-015 — Named Credential nuevo: External Credential + acceso al principal

- **Regla:** En la UI nueva de Named Credentials, el campo **External Credential** no ofrece opciones hasta **crear uno primero** (Named Credential = a dónde se llama; External Credential = cómo se autentica). Tras crearlo, su **principal** necesita acceso explícito, que se concede vía **Permission Set** (si falta → error de permisos al hacer el callout).
- **Ámbito:** Integraciones / seguridad.
- **Origen:** Sesión 2026-06-29.

### REGLA-016 — Pedir capturas/exports del org antes de asumir lo no visible

- **Regla:** Cuando el resultado depende de **configuración del org que no se ve en el repo** (branding, CSP/Trusted URLs, índice de búsqueda, contenido CMS, cómo un componente renderiza), **pedir al usuario una captura o un export antes** de proponer la solución, en vez de iterar sobre suposiciones. Sus capturas/exports son la fuente de verdad para converger rápido.
- **Ámbito:** Método de trabajo / preferencia del usuario.
- **Origen:** Sesión 2026-06-29.

### REGLA-017 — Esqueleto reutilizable de integración inbound

- **Regla:** Las integraciones entrantes se estructuran en capas con **una responsabilidad cada una**: **Service** (solo callout HTTP + `JSON.deserialize` a wrappers tipados) → **Importer** (upsert **idempotente por _External ID_** a un objeto **staging** con `Sync_Status__c` como máquina de estados) → **Publisher(es)** (staging → registros reales con **trazabilidad bidireccional** y **DML parcial** `Database.*(list, false)`). Cada publisher expone un método core inyectable (para tests) y devuelve un wrapper de resultado con contadores. Reutilizar este esqueleto en integraciones futuras.
- **Ámbito:** Apex / integraciones.
- **Origen:** Sesión 2026-06-29.

---

> Reglas de la sesión de **Buyer Group Catalog Pulse (CDC + Platform Events)**,
> sesión 2026-07-08, añadidas a petición explícita del usuario. Lecciones
> reutilizables de Change Data Capture y Platform Events. El detalle completo vive
> en `docs/development/catalog-pulse-development-walkthrough.md`,
> `docs/salesforce/manual-catalog-pulse-cdc-runbook.md` y
> `adr/0007-event-driven-catalog-pulse-architecture.md`.

### REGLA-018 — CDC: en UPDATE, los campos no cambiados no son fiables

- **Regla:** En un change event de UPDATE, CDC solo trae los campos que cambiaron; los booleanos NO cambiados llegan como su default `false` (no null). Nunca decidir lógica con un campo que no esté en `header.getChangedFields()`; fiarse de un valor solo si el campo cambió, o si la operación es CREATE/UNDELETE (traen valores reales).
- **Ámbito:** Apex / CDC.
- **Origen:** Sesión 2026-07-08 (Catalog Pulse). Detalle en `docs/development/catalog-pulse-development-walkthrough.md` §6.

### REGLA-019 — CDC capta cualquier fuente y solo dispara ante cambios reales

- **Regla:** Un Apex trigger sobre `<Objeto>ChangeEvent` (con la entidad en el canal `ChangeEvents`) capta cambios de UI, API y Apex por igual. CDC NO emite evento si el DML reescribe valores idénticos → los upserts idempotentes (re-sync diario) no generan ruido. Verificar habilitación con `PlatformEventChannelMember WHERE SelectedEntity = '<Objeto>ChangeEvent'`.
- **Ámbito:** CDC / B2B Commerce.
- **Origen:** Sesión 2026-07-08 (Catalog Pulse). Runbook `manual-catalog-pulse-cdc-runbook.md` §2.

### REGLA-020 — Testear CDC + Platform Events en Apex

- **Regla:** CDC: `Test.enableChangeDataCapture()` antes del DML + `Test.getEventBus().deliver()` (uno por salto de la cadena) dentro de `Test.startTest/stopTest`. Subscriber de Platform Event: `EventBus.publish(...)` y dejar que `Test.stopTest()` haga el flush. La lógica se testea con wrappers/DTOs propios sin depender de los objetos de evento.
- **Ámbito:** Apex / testing / eventos.
- **Origen:** Sesión 2026-07-08 (Catalog Pulse).

### REGLA-021 — Triggers async (CDC/Platform Event) corren como Automated Process

- **Regla:** Los triggers de ChangeEvent y de Platform Event se ejecutan async como el usuario **Automated Process** (`autoproc`). Para ver sus logs, crear un `TraceFlag` (LogType `USER_DEBUG`) sobre ese usuario y leer el `ApexLog`; el log del usuario que hizo el DML no los contiene.
- **Ámbito:** Apex / debugging / eventos.
- **Origen:** Sesión 2026-07-08 (Catalog Pulse).

### REGLA-022 — FLS: consultar campos custom por API/report exige permission set

- **Regla:** Un usuario (incl. admin) necesita FLS de lectura para consultar un campo custom por SOQL en API/reports; sin él la query da `No such column` aunque el campo exista. El Apex `without sharing`/system mode ignora FLS (por eso un LWC servido por Apex funciona sin ese permiso, pero una query directa del admin no).
- **Ámbito:** Seguridad / FLS.
- **Origen:** Sesión 2026-07-08 (Catalog Pulse).

### REGLA-023 — `group` y `desc` son palabras reservadas en Apex

- **Regla:** No usar `group` ni `desc` (ni otras palabras reservadas de SOQL/Apex) como nombre de variable; el deploy falla con "Identifier name is reserved". Usar alternativas (`buyerGroup`, `cleaned`, etc.).
- **Ámbito:** Apex.
- **Origen:** Sesión 2026-07-08 (Catalog Pulse).

---

> Reglas de las sesiones de **imágenes de categoría + paginador custom + rediseño del Login**
> (sesiones 2026-07-13 y 2026-07-14), añadidas a petición explícita del usuario. Lecciones de
> B2B Commerce LWR sobre CMS por URL, paginación de búsqueda y CSS sobre componentes estándar.
> El diseño aprobado del Login vive en `docs/ux/login-page-design-spec.md`.

### REGLA-024 — Imágenes CMS por URL sí renderizan en tiles de categoría (matiza REGLA-006)

- **Regla:** Las imágenes `sfdc_cms__image` por referencia URL (REGLA-012, 0 File Storage) **sí** se pintan en el Banner/Tile Image de categoría ("Shop by Category"), aunque la miniatura en la UI admin del Commerce salga rota (no genera renditions; solo cosmético). La asociación son **2 `ProductCategoryMedia` por categoría** (grupos `bannerImage` y `tileImage`, `ElectronicMediaId` = Id del `ManagedContent`), automatizable por Apex. Herramientas: `scripts/cms/generate-category-image-package.mjs` + `scripts/apex/assign-category-images.apex`.
- **Ámbito:** B2B Commerce / CMS.
- **Origen:** Sesión 2026-07-13.

### REGLA-025 — Assets de páginas guest: GitHub raw, no CMS

- **Regla:** La entrega CMS (`/cms/delivery/media/...`) **redirige al login** para usuarios no autenticados → ningún asset del CMS sirve para páginas guest (login, self-register). Servirlos desde el repo GitHub (`raw.githubusercontent.com`, ya Trusted URL); GitHub entrega `.svg` con `Content-Type: image/svg+xml` (válido en `<img>`). Verificar el acceso guest con `curl` antes de dar una URL por buena.
- **Ámbito:** B2B Commerce / CMS / CSP.
- **Origen:** Sesión 2026-07-14 (logo del login roto para invitados).

### REGLA-026 — Reindexar la búsqueda: cómo y cuándo (operativiza REGLA-003)

- **Regla:** El índice se reconstruye con **`ConnectApi.CommerceSearchSettings.createCommerceSearchIndex(webstoreId)`** (`scripts/apex/rebuild-search-index.apex`); el endpoint REST `/commerce/management/.../search/indexes` no existe en esta org. Los **syncs programados** (Platzi) crean productos/entitlements que **nadie ve** hasta reindexar — el banner del Builder muestra la fecha del último índice; revisarla al diagnosticar "productos que faltan". Hay límite diario de rebuilds manuales.
- **Ámbito:** B2B Commerce / búsqueda.
- **Origen:** Sesión 2026-07-13 (índice de 5 días ocultaba 6 productos Platzi).

### REGLA-027 — El Grid custom de la PLP no pagina; la paginación vive en la URL (`?page=N`)

- **Regla:** El patrón Grid + Nested Expression (REGLA-005) **pierde la paginación estándar**: el paginador propio del Grid lee un `expressionDataProvider` estático y no renderiza en runtime (en el Builder sí, por ser design-time) → buyers limitados a la primera página (~20). El estado de paginación del commerce search data provider está en la **URL**: navegar con `?page=N` recarga esa página y `{!Search.Results.cardCollection}` se refresca. Solución: **`c:lvlupSearchPaginator`** (NavigationMixin + CurrentPageReference; total parseado de `{!Search.Results.description}`; el componente estándar se ancla a `{!Search.Pagination.currentPage}`).
- **Ámbito:** B2B Commerce / LWC / Experience Builder.
- **Origen:** Sesión 2026-07-13.

### REGLA-028 — CSS global sobre componentes estándar: reglas de combate

- **Regla:** El head markup (`mainAppPage`) carga en **todo** el site (login incluido): scope con selectores que solo existan en la página objetivo (clases propias `lvlup-*`, custom elements como `community_login-login-form`) o `:has()`. Los componentes estándar renderizan **light DOM** con clases scoped `lwc-<hash>` (**no usarlas**: usar tags de custom element y clases semánticas `comm-*`/`slds-*`). El espaciado entre componentes lo pone la clase **`component-wrapper-spacer`** del wrapper: anularlo en origen (`margin-bottom: 0`), **nunca** con márgenes negativos (los wrappers **recortan** el contenido desbordado). El rich text del Builder pisa el color de los links con estilos scoped → requiere `!important`. Y máximo **una** iteración a ciegas: al segundo fallo, pedir el DOM real (REGLA-016).
- **Ámbito:** UX / CSS / Experience Builder.
- **Origen:** Sesiones 2026-07-13/14 (hover de tiles y rediseño del Login).

<!-- Plantilla para nuevas reglas:

### REGLA-001 — <título corto>

- **Regla:** <qué se debe hacer o evitar>.
- **Ámbito:** <Apex | LWC | Flow | docs | commits | ...>.
- **Origen:** <fecha o conversación donde se acordó>.
-->
