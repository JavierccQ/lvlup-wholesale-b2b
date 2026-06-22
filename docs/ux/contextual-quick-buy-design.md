# Diseño de Contextual Quick Buy - LvlUp WholeSale

> **Estado:** En revisión (diseño funcional comprometido, previo a fase técnica).
> **Tipo:** Diseño funcional + UX + arquitectura conceptual y contratos de componentes LWC.
> **Objetivo del documento:** servir de base para la fase técnica del feature.
>
> **Nomenclatura:** componentes con prefijo `lvlup` y carpetas LWC en **camelCase**
> (convención del proyecto, [`naming-conventions.md`](../development/naming-conventions.md §9, §11)).
> Eventos en minúsculas sin separadores. El prefijo `ccprev_` **no se usa** en este
> proyecto. Los nombres siguen siendo conceptuales hasta su creación.
>
> **Documentos relacionados:** [`storefront-journey.md`](storefront-journey.md),
> [`plp-pdp-guidelines.md`](plp-pdp-guidelines.md),
> [`empty-error-loading-states.md`](empty-error-loading-states.md),
> [`business-rules.md`](../business/business-rules.md),
> [`pricing-and-visibility-strategy.md`](../business/pricing-and-visibility-strategy.md),
> [`b2b-commerce-standard-capabilities.md`](../salesforce/b2b-commerce-standard-capabilities.md),
> [`lwc-guidelines.md`](../development/lwc-guidelines.md).

---

## 0. Propuesta de diseño comprometida

Dirección final tras resolver las decisiones abiertas:

- **Feature:** *Contextual Quick Buy* — modal de compra rápida **contextual al
  producto**, no un Quick Order global por SKU/CSV.
- **Diferenciador:** muestra **MOQ, múltiplos de compra, stock y precio del Buyer
  Group** del producto que el buyer está viendo, y valida el pedido *antes* de
  añadirlo al carrito.
- **Ubicación:** disponible **en cualquier lugar donde exista una Product Card**
  (PLP, categoría, búsqueda, destacados). Identificador único: **`ProductId`**.
- **Add to cart:** **real**, contra el carrito estándar del store (B2B Commerce).
- **Atributos:** el selector se construye preparado para atributos, pero **hoy
  ningún producto tiene atributos**, así que degrada con elegancia (no se muestra
  cuando no hay). Soporte real de atributos a futuro.
- **Precio:** **simple** → `precio unitario del Buyer Group × cantidad`. Sin
  tramos ni descuentos por volumen en esta versión.
- **Arquitectura:** padre orquestador (`lvlupProductQuickBuy`) + contenedor de
  modal (`lvlupQuickBuyModal`) + hijos de detalle. Estado centralizado en el
  padre; datos hacia abajo por `@api`, eventos hacia arriba por `CustomEvent`
  (re-dispatch en el contenedor) → cumple el objetivo de **practicar
  comunicación padre-hijo** en 3 niveles.
- **Recomendación:** pasar a fase técnica con MVP acotado (1 padre + 5–6 hijos).

---

## 1. Nombre funcional del componente

| # | Nombre | Tono | Cuándo encaja |
|---|--------|------|---------------|
| 1 | **Contextual Quick Buy** ⭐ | Comercial + técnico | Elegido: "compra rápida" *contextual al producto*, no el Quick Order global. |
| 2 | Guided Add to Cart | UX / onboarding | Si el énfasis es el flujo guiado. |
| 3 | Product Purchase Configurator | Funcional / B2B | Si crece hacia configuración real de variantes. |

**Decidido:** *Contextual Quick Buy*; componente padre `lvlupProductQuickBuy`.

---

## 2. Objetivo del componente

> Permitir que un **buyer B2B** complete la decisión de compra de un producto
> concreto —sin salir de la categoría, la búsqueda o la ficha— mediante un modal
> contextual que muestra **precio del Buyer Group, disponibilidad y reglas de
> compra (mínimos/múltiplos)** antes de añadirlo al carrito real, reduciendo
> errores de pedido y fricción en compras repetitivas de alto volumen.

El valor no es "comprar más rápido" (eso ya lo da Quick Order), sino **comprar
bien con la información del producto delante**.

---

## 3. User Story principal

> **Como** buyer B2B de LvlUp WholeSale,
> **quiero** configurar la cantidad de un producto desde un modal contextual sin
> abandonar el catálogo,
> **para** añadirlo al carrito respetando los mínimos, múltiplos y stock del
> mayorista, evitando errores y reprocesos.

Soporte:

- Como buyer, quiero ver el **precio estimado por la cantidad elegida** (precio
  de mi Buyer Group × unidades) antes de confirmar.
- Como buyer, quiero que el sistema **me impida** cantidades inválidas.

---

## 4. Alcance funcional del MVP

| Capacidad | En MVP | Nota |
|-----------|:---:|------|
| Botón "Comprar" disponible junto a cualquier Product Card | ✅ | Recibe `productId` por `@api`. |
| Apertura/cierre de modal contextual | ✅ | Estado controlado por el padre. |
| Carga de datos del producto por `productId` | ✅ | Vía API estándar de producto del store. |
| Selector de cantidad (+/- y entrada manual) | ✅ | Con validación. |
| Reglas B2B: cantidad mínima, máxima y múltiplo | ✅ | Núcleo del valor B2B. |
| Panel de disponibilidad/stock (lectura) | ✅ | Lee `Product2.Inventory_Quantity__c`; con dato presente, bloquea. |
| Selector de atributos (degrada si no hay) | ✅ | Hoy sin atributos; preparado a futuro. |
| Resumen: `precio Buyer Group × cantidad` | ✅ | Simple, sin tramos. |
| Estados de UI completos (loading, error, éxito) | ✅ | Ver §10. |
| **Add to cart real** + feedback visual | ✅ | Carrito estándar del store. |

**Tamaño objetivo:** 1 padre + 5–6 hijos, 3 niveles de profundidad.

---

## 5. Fuera de alcance (primera versión)

- ❌ Atributos/variantes (no hay datos hoy; el selector queda preparado pero inactivo).
- ❌ Pricing por tramos/volumen o descuentos negociados (precio simple unitario × cantidad).
- ❌ Compra multi-producto / multi-línea en el mismo modal (eso es Quick Order).
- ❌ Validación propia de entitlements: se delega en el estándar (el API de
  producto y de carrito ya respeta visibilidad y entitlements del Buyer Group).
- ❌ Reserva de stock / ATP en tiempo real contra inventario externo.
- ❌ Listas de compra recurrente, reorder, plantillas de pedido.
- ❌ Checkout o cualquier paso posterior al carrito.
- ❌ Persistencia de configuración entre sesiones.

---

## 6. Diseño UX del flujo

```
[Cualquier vista con Product Card: PLP / categoría / búsqueda / PDP]
        │ (1) El buyer ve el botón "Comprar" junto a la card
        ▼
   lvlupQuickBuyButton  ──(2) click → 'buyclick' { productId }──►
        │
        ▼
 (3) El padre abre el modal y carga el producto (API estándar, por productId)
        ▼
   ┌──────────────────────── MODAL ────────────────────────┐
   │ (4) "cargando producto" → datos listos                 │
   │ (5) Buyer ajusta CANTIDAD (+/- o manual)               │
   │     → validación en vivo (mín/máx/múltiplo/stock)      │
   │ (6) ATRIBUTOS (si el producto los tuviera; hoy oculto) │
   │ (7) Panel de STOCK refleja disponibilidad              │
   │ (8) RESUMEN = precio Buyer Group × cantidad            │
   │ (9) "Añadir" se habilita solo si todo es válido        │
   └────────────────────────────────────────────────────────┘
        │ (10) confirmar → "añadiendo…" → add to cart REAL
        ▼
   éxito → "Añadido ✓" + refresca contador del carrito estándar
   error → "No se pudo añadir" + reintentar (el modal permanece)
```

**Decisiones UX clave:**

- El modal **no se cierra automáticamente** al añadir; muestra confirmación y
  ofrece "Seguir comprando" / "Ir al carrito".
- Validación **preventiva** (deshabilita el botón) y **explicativa** (dice el porqué).
- Cantidad por defecto = **cantidad mínima de pedido** (no 1).

---

## 7. Estructura visual del modal

```
┌───────────────────────────────────────────────┐
│ HEADER                                    [ ✕ ]│  título + cerrar
├───────────────────────────────────────────────┤
│  ┌────────┐   Nombre del producto              │
│  │ IMAGEN │   SKU: LVL-CON-001                  │  imagen + identidad
│  └────────┘   Marca / categoría                 │
├───────────────────────────────────────────────┤
│  ● En stock · 320 uds · Case pack: 5            │  lvlupStockAvailabilityPanel
├───────────────────────────────────────────────┤
│  (Atributos: oculto hasta que existan datos)    │  lvlupProductAttributeSelector
├───────────────────────────────────────────────┤
│  CANTIDAD   [ – ] [  25  ] [ + ]                 │  lvlupQuantitySelector
│  Mín: 5 · Múltiplos de 5 · Máx: 320             │  reglas visibles
├───────────────────────────────────────────────┤
│  25 uds × 419,00 €  =  10.475,00 €              │  lvlupPurchaseSummary
├───────────────────────────────────────────────┤
│  ⚠ / ✓  Zona de mensajes (error o éxito)        │  feedback contextual
├───────────────────────────────────────────────┤
│ FOOTER          [ Cancelar ]  [ Añadir ✓ ]      │  acciones
└───────────────────────────────────────────────┘
```

| Zona | Contenido | Estado dinámico |
|------|-----------|-----------------|
| Header | Título + cerrar | siempre visible |
| Identidad | Imagen, nombre, SKU, marca | skeleton si carga |
| Disponibilidad | Stock, unidades, case pack | color semántico (verde/ámbar/rojo) |
| Atributos | Selectores; solo si el producto los define | **oculto** mientras no haya datos |
| Cantidad | Stepper + reglas (mín/máx/múltiplo) | borde rojo si inválido |
| Resumen | `precio Buyer Group × cantidad` | recalcula en cada cambio |
| Mensajes | Error de validación o éxito | una sola zona, no apila |
| Footer | Cancelar (secundario) + Añadir (primario) | deshabilitado si inválido / spinner si añadiendo |

---

## 8. Componentización LWC padre-hijo

```
lvlupProductQuickBuy             (PADRE / orquestador de estado + integración)
├── lvlupQuickBuyButton          (hijo · dispara apertura)
└── lvlupQuickBuyModal           (hijo contenedor · presenta el modal)
    ├── lvlupQuantitySelector
    ├── lvlupProductAttributeSelector
    ├── lvlupStockAvailabilityPanel
    └── lvlupPurchaseSummary
```

| Componente | Responsabilidad | Comunicación que practica |
|------------|-----------------|---------------------------|
| `lvlupProductQuickBuy` | Orquestador: estado (producto, cantidad, atributos, validez, uiState), carga de producto e **integración real con el carrito**. | "Smart parent": centraliza estado y baja props. |
| `lvlupQuickBuyButton` | Botón "Comprar". Sin lógica de negocio. | Hijo → padre: evento de intención. |
| `lvlupQuickBuyModal` | Contenedor de presentación: reenvía datos a sus hijos y burbujea sus eventos al padre. | Padre intermedio: recibir de hijos y re-emitir (re-dispatch). |
| `lvlupQuantitySelector` | Stepper con reglas visibles; valida formato local y notifica. | Hijo controlado: el valor real vive en el padre. |
| `lvlupProductAttributeSelector` | Selección de atributos definidos por el producto; se oculta si no hay. | Hijo → padre con payload estructurado. |
| `lvlupStockAvailabilityPanel` | Muestra stock/case pack y valida cantidad vs disponibilidad. | Hijo que devuelve un **veredicto**. |
| `lvlupPurchaseSummary` | Calcula y muestra `precio × cantidad`. | Hijo presentacional puro. |

**Por qué enseña bien padre-hijo:** 3 niveles (padre → contenedor → hijos),
practicando paso directo de props y **re-dispatch** de eventos a través del
contenedor intermedio (`lvlupQuickBuyModal`).

### 8.1 Integración estándar (add to cart real)

Prioridad *standard-first* ([ADR 0002](../../adr/0002-standard-first-b2b-commerce-approach.md)).
El padre `lvlupProductQuickBuy` orquesta la integración usando módulos estándar
de commerce (no Apex salvo gap justificado):

- **Contexto** (`webStoreId`, `effectiveAccountId`) → módulo de contexto del store.
- **Producto y precio del Buyer Group** (nombre, SKU, imagen, `unitPrice`,
  reglas de compra) → API estándar de producto, que ya devuelve el precio
  entitled para la cuenta efectiva.
- **Añadir al carrito** → API estándar de carrito; tras éxito, refrescar el
  contador/summary del carrito del store.
- **Stock y reglas de compra** → campos custom de `Product2`
  (`Inventory_Quantity__c`, `Min_Order_Quantity__c`, `Order_Increment__c`,
  `Max_Order_Quantity__c`), porque la org no usa OCI. Ver
  [`manual-inventory-setup-runbook.md`](../salesforce/manual-inventory-setup-runbook.md).

> El detalle técnico fino (nombres exactos de adapters/métodos) se cierra en la
> fase técnica; aquí se fija el **enfoque**: estándar primero, `productId` como
> clave, precio y entitlements delegados al estándar.

---

## 9. Contratos de componentes (`@api` + eventos)

Interfaces conceptuales (no implementación). Tipos orientativos.

### `lvlupProductQuickBuy` (padre)
| `@api` (entrada) | Tipo | Origen |
|---|---|---|
| `productId` | String | Contexto de la Product Card |
| (opcional) `webStoreId` / `effectiveAccountId` | String | Contexto del store si no se resuelve internamente |

Escucha: `buyclick`, `quantitychange`, `attributechange`, `stockvalidated`,
`closemodal`, `confirmaddtocart`. No emite a un padre interno.

### `lvlupQuickBuyButton` (hijo)
| `@api` | Tipo | | Emite | `detail` |
|---|---|---|---|---|
| `productId` | String | | `buyclick` | `{ productId }` |
| `label` | String | | | |
| `disabled` | Boolean | | | |

### `lvlupQuickBuyModal` (contenedor)
| `@api` | Tipo | | Emite | `detail` |
|---|---|---|---|---|
| `product` | Object | | `closemodal` | `{ reason }` |
| `isOpen` | Boolean | | `confirmaddtocart` | `{ productId, quantity, selectedAttributes }` |
| `uiState` | String | | *(re-emite eventos de hijos)* | |
| `quantity` | Number | | | |
| `selectedAttributes` | Object | | | |
| `subtotal` | Number | | | |
| `message` | Object `{type,text}` | | | |

### `lvlupQuantitySelector` (hijo)
| `@api` | Tipo | | Emite | `detail` |
|---|---|---|---|---|
| `min` | Number | | `quantitychange` | `{ quantity, isValid, reason }` |
| `max` | Number | | | |
| `step` (múltiplo) | Number | | | |
| `value` | Number | | | |

### `lvlupProductAttributeSelector` (hijo)
| `@api` | Tipo | | Emite | `detail` |
|---|---|---|---|---|
| `attributes` | Array (vacío hoy) | | `attributechange` | `{ attributeName, value, allRequiredSelected }` |
| `selected` | Object | | | |

> Con `attributes` vacío, el componente **no renderiza** y reporta
> `allRequiredSelected = true` para no bloquear el flujo.

### `lvlupStockAvailabilityPanel` (hijo)
| `@api` | Tipo | | Emite | `detail` |
|---|---|---|---|---|
| `stock` | Number | | `stockvalidated` | `{ requestedQuantity, available, isSufficient }` |
| `casePack` | Number | | | |
| `requestedQuantity` | Number | | | |

### `lvlupPurchaseSummary` (hijo)
| `@api` | Tipo | | Emite |
|---|---|---|---|
| `unitPrice` | Number (precio Buyer Group) | | (presentacional) |
| `quantity` | Number | | |
| `currency` | String | | |

Subtotal = `unitPrice × quantity`.

---

## 10. Estados de UI

Una sola máquina de estados en el padre (`uiState`).

| Estado | Disparador | Botón "Añadir" |
|--------|------------|:--------------:|
| `closed` | inicial / tras cerrar | — |
| `open` | `buyclick` | según validez |
| `loadingProduct` | apertura mientras llegan datos | deshabilitado |
| `invalidQuantity` | cantidad fuera de mín/máx/múltiplo | deshabilitado |
| `insufficientStock` | cantidad > disponible | deshabilitado |
| `incompleteAttributes` | atributo obligatorio sin elegir (futuro) | deshabilitado |
| `readyToAdd` | todo válido | **habilitado** |
| `addingToCart` | `confirmaddtocart` → llamada real | spinner |
| `addedSuccess` | carrito responde OK | "Seguir / Ir al carrito" |
| `addError` | carrito responde KO | reintentar habilitado |

**Regla de oro:** `readyToAdd` es el **único** estado desde el que se confirma.
Coherente con [`empty-error-loading-states.md`](empty-error-loading-states.md).

---

## 11. Validaciones funcionales (sentido B2B)

| Validación | Regla | Mensaje (ejemplo) | Bloquea |
|------------|-------|-------------------|:-------:|
| Cantidad mínima (MOQ) | `quantity ≥ minOrderQty` | "Pedido mínimo: 5 unidades." | ✅ |
| Cantidad máxima | `quantity ≤ maxOrderQty` | "Máximo 500 unidades por pedido." | ✅ |
| Múltiplo de compra | `quantity % step === 0` | "Se vende en múltiplos de 5." | ✅ |
| Stock disponible | `quantity ≤ available` (si hay dato) | "Solo quedan 320 unidades." | ✅* |
| Atributos obligatorios | todos los `required` seleccionados (futuro) | "Selecciona el color." | ✅ |
| Producto no disponible | el estándar no lo devuelve / inactivo | "Este producto no está disponible." | ✅ |
| Restringido para la cuenta | sin entitlement (lo resuelve el estándar) | "No disponible para tu cuenta." | ✅ |

\* Stock se lee de `Product2.Inventory_Quantity__c` (inventario simulado en campos
custom; la org no usa OCI). Las reglas de compra salen de `Min_Order_Quantity__c`,
`Order_Increment__c` y `Max_Order_Quantity__c`. Con dato presente el panel
**bloquea**; sin dato, informativo. Ver
[`manual-inventory-setup-runbook.md`](../salesforce/manual-inventory-setup-runbook.md)
y [`business-rules.md`](../business/business-rules.md).

---

## 12. Criterios de aceptación (MVP, testeables)

1. Junto a una Product Card, al hacer clic en "Comprar" se abre el modal con
   imagen, nombre y SKU del producto identificado por su `productId`.
2. En carga, el skeleton se reemplaza por precio (del Buyer Group) y stock.
3. Dado MOQ=5, la cantidad por defecto al abrir es 5 (no 1).
4. Dado múltiplo=5, al introducir 7 "Añadir" se deshabilita con el motivo.
5. Dado stock=320 (si hay dato), al pedir 400 el panel se marca en rojo y
   "Añadir" se deshabilita.
6. Dado un producto **sin atributos**, el selector de atributos no se muestra y
   no bloquea el flujo.
7. Dado precio Buyer Group 419 € y cantidad 25, el resumen muestra 10.475,00 € y
   recalcula al cambiar la cantidad.
8. Al confirmar, el botón muestra spinner y se ejecuta el **add to cart real**;
   al resolver OK, muestra "Añadido ✓" y refresca el contador del carrito.
9. Si el carrito devuelve error, se muestra el error y el modal no se cierra.
10. **Padre-hijo:** un cambio en `lvlupQuantitySelector` emite `quantitychange`,
    llega al padre vía `lvlupQuickBuyModal` y el estado del padre se actualiza.
11. "Cancelar"/cierre emite `closemodal` y vuelve a `closed` sin tocar el carrito.

---

## 13. Decisiones (resueltas y abiertas)

| # | Decisión | Resolución |
|---|----------|------------|
| 0 | Prefijo de nombres | ✅ **`lvlup` + camelCase**. `ccprev_` prohibido en el proyecto. |
| 1 | Dónde se inserta el botón | ✅ **Donde haya Product Card** (PLP/categoría/búsqueda/PDP), componente independiente. |
| 2 | Wrapper vs componente separado | ✅ **Componente separado** que recibe `productId`. |
| 3 | Origen del producto | ✅ **`productId`** + **API estándar de producto** del store. |
| 4 | Add to cart real o simulado | ✅ **Real**, carrito estándar del store. |
| 5 | Pricing | ✅ **Simple**: `precio Buyer Group × cantidad`. |
| 6 | Atributos | ✅ Selector **preparado, hoy inactivo** (sin datos); real a futuro. |
| 7 | Stock | ✅ **Resuelto con campos custom:** la org no soporta inventario estándar sin OCI, así que el stock vive en `Product2.Inventory_Quantity__c` (+ reglas en `Min_Order_Quantity__c`, `Order_Increment__c`, `Max_Order_Quantity__c`), sembrado en los 52 productos activos. Con dato, el panel **bloquea**. Ver [`manual-inventory-setup-runbook.md`](../salesforce/manual-inventory-setup-runbook.md). |
| 8 | Duplicidad con Quick Order estándar | ✅ Mitigada por el posicionamiento contextual (MOQ/múltiplos/precio/stock visibles). |

---

## 14. Recomendación final

El feature pasa a fase técnica con MVP acotado: **1 padre + 5–6 hijos en 3
niveles**, **add to cart real** vía API estándar del carrito, datos de producto y
precio del Buyer Group desde la API estándar de producto, atributos preparados
pero inactivos y stock best-effort (hoy **informativo**, sin inventario en la
org). Todas las decisiones de diseño están cerradas. Próximo paso: fase técnica
(estructura de carpetas LWC, contratos en código y primer componente) y fijar los
nombres exactos de adapters/métodos estándar de commerce.
