# Guía de Código: Contextual Quick Buy (para desarrollador junior)

> **Para quién es esto:** alguien que sabe programar (HTML, JS, algo de back-end)
> pero **nunca ha trabajado en Salesforce**. Explica, archivo por archivo, el
> feature *Contextual Quick Buy*: imports, variables, métodos, eventos y llamadas
> a API. Acompaña al diagrama visual
> [`contextual-quick-buy-architecture.html`](../ux/contextual-quick-buy-architecture.html)
> y al diseño funcional [`contextual-quick-buy-design.md`](../ux/contextual-quick-buy-design.md).

---

## 0. Primero: conceptos de Salesforce que necesitas

Salesforce es una plataforma cloud. Nuestro storefront (la tienda B2B) corre sobre
**Experience Cloud / LWR** (un tipo de sitio web de Salesforce). Lo que construimos
usa estas piezas:

| Concepto | En cristiano |
|---|---|
| **LWC (Lightning Web Component)** | Un componente web (HTML + JS + CSS), estándar moderno. Cada componente es una carpeta con 4 archivos. Es lo mismo que un Web Component, con azúcar de Salesforce. |
| **`@api`** | Decorador que hace **pública** una propiedad de un LWC. Es como un *prop* de React: el padre le pasa datos al hijo a través de propiedades `@api`. |
| **`CustomEvent`** | El mecanismo para que un **hijo avise al padre** ("evento hacia arriba"). El hijo hace `dispatchEvent(new CustomEvent('nombre', { detail }))`; el padre lo escucha con `onnombre={handler}`. |
| **Apex** | El lenguaje **back-end** de Salesforce (parecido a Java). Corre en el servidor y habla con la base de datos. |
| **`@AuraEnabled`** | Decorador que hace que un método Apex sea **llamable desde un LWC** (JS → servidor). Si además es `cacheable=true`, el resultado se cachea y solo sirve para **leer** datos. |
| **SOQL** | El "SQL de Salesforce". Se escribe entre corchetes: `[SELECT Id FROM Product2 WHERE ...]`. |
| **Objeto / Registro** | Un "objeto" es una tabla (p. ej. `Product2`, `Account`). Un "registro" es una fila. |
| **Campo custom** | Una columna que añadimos a una tabla. Termina en `__c` (p. ej. `Inventory_Quantity__c`). |
| **Permission Set** | Un "paquete de permisos" que asignas a usuarios: acceso a clases Apex, a campos, a objetos. |
| **`with sharing` / `without sharing`** | Le dice a una clase Apex si debe respetar las **reglas de visibilidad de registros** del usuario. Clave en este proyecto (ver el controller). |

**El patrón estrella del feature** es la **comunicación padre-hijo**: los datos bajan
por `@api` y los eventos suben por `CustomEvent`. Todo el árbol de componentes se
coordina así.

---

## 1. Mapa mental (qué hace cada pieza)

```
PLP (página de categoría)
└── Grid estándar (repite por producto, variable "Item")
    ├── lvlupProductImage      → imagen (URL externa) + link a la ficha
    ├── Product Card estándar  → nombre / SKU / precio
    └── lvlupProductQuickBuy   → EL FEATURE (botón + modal)
        ├── lvlupQuickBuyButton   (botón "Comprar")
        └── lvlupQuickBuyModal    (el modal)
            ├── lvlupStockAvailabilityPanel
            ├── lvlupProductAttributeSelector
            ├── lvlupQuantitySelector
            └── lvlupPurchaseSummary
```

`lvlupProductQuickBuy` es el **cerebro** (orquestador): guarda el estado y habla con
el servidor (Apex) y con el carrito (API estándar). Los demás son piezas tontas que
muestran datos y emiten eventos.

---

## 2. Apex (el back-end)

### 2.1 `LvlupQuickBuyController.cls`

Su único trabajo: dado el `Id` de un producto, devolver lo que el modal necesita
(nombre, SKU, imagen, precio, stock y reglas de compra).

```apex
public without sharing class LvlupQuickBuyController {
```
- **`public`**: visible para otras clases/LWC.
- **`without sharing`**: ⚠️ **lo más importante.** En B2B Commerce, los registros
  `Product2` **no se comparten al comprador** por las reglas de visibilidad
  normales; su visibilidad la da el *entitlement* de comercio. Si la clase fuera
  `with sharing`, la consulta devolvería **0 filas** para el comprador (¡aunque
  pueda ver el producto en la tienda!). `without sharing` evita ese bloqueo. El
  producto ya está entitled, así que es seguro.

```apex
    @AuraEnabled(cacheable=true)
    public static ProductPurchaseInfo getProductPurchaseInfo(Id productId) {
```
- **`@AuraEnabled(cacheable=true)`**: este método se puede llamar desde el LWC y su
  resultado se cachea (es de solo lectura).
- **`static`**: no necesita instanciar la clase.
- Recibe un `Id productId` (el `Id` es un tipo nativo de Salesforce de 18 caracteres).
- Devuelve un `ProductPurchaseInfo` (una clase wrapper definida abajo).

```apex
        Product2 product = [
            SELECT Id, Name, StockKeepingUnit, DisplayUrl,
                   Inventory_Quantity__c, Min_Order_Quantity__c,
                   Order_Increment__c, Max_Order_Quantity__c
            FROM Product2
            WHERE Id = :productId
            LIMIT 1
        ];
```
- Esto es **SOQL**. Trae **una** fila de `Product2` cuyo `Id` coincide.
- `:productId` es un **bind variable**: inyecta de forma segura la variable de Apex
  en la consulta (equivale a un parámetro preparado; evita inyección).
- Selecciona campos estándar (`Name`, `StockKeepingUnit`, `DisplayUrl`) y nuestros 4
  campos custom (`*__c`).
- Si no hay filas, el assignment a un solo `Product2` lanza
  `QueryException` ("List has no rows...") — eso fue justo el bug que arreglamos con
  `without sharing`.

```apex
        Decimal unitPrice = null;
        for (PricebookEntry entry : [
            SELECT UnitPrice FROM PricebookEntry
            WHERE Product2Id = :productId AND IsActive = true
            ORDER BY Pricebook2.IsStandard DESC
            LIMIT 1
        ]) {
            unitPrice = entry.UnitPrice;
        }
```
- El **precio** vive en `PricebookEntry` (precio de un producto dentro de un *price
  book*). Hacemos un `for` sobre la consulta (patrón seguro: si no hay precio,
  `unitPrice` queda en `null` sin lanzar excepción).
- `ORDER BY Pricebook2.IsStandard DESC LIMIT 1`: toma un precio (priorizando el
  estándar). Es el "precio del MVP".

```apex
        ProductPurchaseInfo info = new ProductPurchaseInfo();
        info.productId = product.Id;
        info.name = product.Name;
        ... (rellena todos los campos) ...
        return info;
    }
```
- Crea el objeto de respuesta, lo rellena y lo devuelve. El LWC recibe esto como un
  objeto JS plano.

```apex
    public class ProductPurchaseInfo {
        @AuraEnabled public Id productId;
        @AuraEnabled public String name;
        ...
    }
```
- Clase interna (**wrapper / DTO**). Cada campo lleva `@AuraEnabled` para que viaje
  al LWC. Sin ese decorador, el campo no sería visible en JS.

> **Nota de seguridad:** no forzamos FLS (field-level security) sobre los campos de
> inventario porque son datos de *display* que el comprador debe ver. Está
> documentado en el comentario de cabecera de la clase.

### 2.2 `LvlupQuickBuyControllerTest.cls`

Salesforce **exige tests** para subir Apex a producción (mínimo 75% de cobertura).
Este test:
- Crea un `Product2` y un `PricebookEntry` de prueba (datos aislados; los tests no
  ven los datos reales por defecto).
- Llama a `getProductPurchaseInfo`.
- Hace `System.assertEquals(...)` para verificar que cada campo vuelve correcto.
- Da **100% de cobertura** del controller.

`Test.startTest()` / `Test.stopTest()` delimitan el código bajo prueba (resetea los
límites de la plataforma). `Test.getStandardPricebookId()` da el id del price book
estándar (en tests no se puede usar el real directamente).

---

## 3. Campos custom de `Product2`

Inventario y reglas de compra **no existen de forma usable** en Commerce estándar
sin Omnichannel Inventory (no disponible en esta org). Por eso los guardamos como
campos custom (decisión documentada). Son 4, todos `Number`:

| Campo (API) | Significado |
|---|---|
| `Inventory_Quantity__c` | Unidades en stock. |
| `Min_Order_Quantity__c` | Cantidad mínima de pedido (MOQ). |
| `Order_Increment__c` | Múltiplo de compra / case pack. |
| `Max_Order_Quantity__c` | Máximo por pedido. |

Cada uno es un archivo XML simple (`*.field-meta.xml`) que define etiqueta, tipo y
precisión. No tienen lógica.

---

## 4. LWC, componente por componente

Recuerda la estructura de un LWC: carpeta con `*.js` (lógica), `*.html` (plantilla),
`*.css` (estilo) y `*.js-meta.xml` (configuración: si es visible en el Builder, en
qué páginas, qué propiedades expone).

### 4.1 `lvlupProductQuickBuy` — el PADRE / orquestador

**Imports:**
```js
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getProductPurchaseInfo from '@salesforce/apex/LvlupQuickBuyController.getProductPurchaseInfo';
import { addItemToCart } from 'commerce/cartApi';
```
- `LightningElement`: la clase base de todo LWC.
- `api`: el decorador para propiedades públicas.
- `NavigationMixin`: utilidad para **navegar** (cambiar de página) dentro del sitio.
- `getProductPurchaseInfo`: ¡así se importa un **método Apex**! La ruta
  `@salesforce/apex/Clase.metodo` convierte el método del servidor en una **función
  JS que devuelve una Promise**.
- `addItemToCart`: función de la **API estándar del carrito** de Commerce
  (`commerce/cartApi`). Añade un producto al carrito real. Disponible en orgs B2B.

**Declaración:**
```js
export default class LvlupProductQuickBuy extends NavigationMixin(LightningElement) {
```
- `extends NavigationMixin(LightningElement)`: un *mixin* — extiende la clase base
  añadiéndole capacidad de navegación.

**Propiedades públicas (entran desde el Builder / la página):**
```js
@api productId;     // Id del producto (se bindea a {!Item.id} en el Grid)
@api recordId;      // si está en una record page, Salesforce lo inyecta solo
@api buttonLabel = 'Comprar';
```

**Estado interno (reactivo):** `isOpen`, `uiState`, `product`, `quantity`,
`selectedAttributes`, `message`, `quantityValid`, `stockSufficient`,
`attributesComplete`. En LWC, reasignar una propiedad de clase **redibuja** la
plantilla automáticamente (reactividad).

**Getters (propiedades calculadas):**
```js
get effectiveProductId() { return this.productId || this.recordId; }
get modalProduct() { return this.product ? {...this.product, attributes: []} : null; }
```
- Un `get` es una propiedad de solo lectura que se recalcula al usarse. Equivale a
  un *computed*.

**Métodos clave:**
- `handleBuyClick()` → llama a `openAndLoad()`.
- `openAndLoad()`: abre el modal, pone `uiState='loadingProduct'` y **llama a Apex**:
  ```js
  getProductPurchaseInfo({ productId: this.effectiveProductId })
      .then((info) => { ...guarda el producto, fija cantidad = MOQ, recompute()... })
      .catch((error) => { ...muestra el error real... });
  ```
  El método Apex se llama como **función que devuelve Promise**; los argumentos van
  en un objeto cuyo nombre de clave **debe coincidir** con el del parámetro Apex
  (`productId`).
- `handleQuantityChange / handleAttributeChange / handleStockValidated`: reciben los
  eventos de los hijos y actualizan el estado, luego `recompute()`.
- `recompute()`: **la máquina de estados**. Según las banderas (cantidad válida,
  atributos completos, stock suficiente) decide el `uiState` y el `message`. Es el
  único sitio donde se decide si el modal está "listo para añadir".
- `handleConfirm(event)`: hace el **add-to-cart real**:
  ```js
  addItemToCart(productId, quantity)
      .then(() => { uiState = 'addedSuccess'; })
      .catch(() => { uiState = 'addError'; });
  ```
- `handleCloseModal()`: resetea todo.
- `handleGoToCart()`: navega al carrito con `NavigationMixin.Navigate`.

**Plantilla (`.html`):** solo renderiza al botón y al modal, pasándoles props y
escuchando sus eventos:
```html
<c-lvlup-quick-buy-button product-id={effectiveProductId} onbuyclick={handleBuyClick}>
<c-lvlup-quick-buy-modal product={modalProduct} is-open={isOpen} ui-state={uiState}
    onquantitychange={handleQuantityChange} onconfirmaddtocart={handleConfirm} ...>
```
- Ojo: en HTML los nombres van en **kebab-case** (`product-id`), en JS en
  **camelCase** (`productId`). Los eventos se escuchan con `on` + nombre en minúscula.

### 4.2 `lvlupQuickBuyButton` — el botón (hijo tonto)

```js
@api productId; @api label = 'Comprar'; @api disabled = false;
handleClick() {
    this.dispatchEvent(new CustomEvent('buyclick', { detail: { productId: this.productId } }));
}
```
- No tiene lógica de negocio. Al hacer clic, **emite el evento `buyclick`** hacia
  arriba con el `productId` en `detail`. El padre lo escucha. Esto es **comunicación
  hijo→padre** en su forma más pura.

### 4.3 `lvlupQuickBuyModal` — el contenedor del modal (padre intermedio)

Es el caso más interesante de comunicación: recibe props del padre **y** re-emite
los eventos de sus propios hijos hacia el padre (*re-dispatch*).

```js
handleQuantityChange(event) {
    this.dispatchEvent(new CustomEvent('quantitychange', { detail: event.detail }));
}
```
- Recibe `quantitychange` de `lvlupQuantitySelector` y lo **vuelve a emitir** al
  padre. Lo mismo con `attributechange` y `stockvalidated`.
- Emite sus propios eventos: `closemodal`, `confirmaddtocart`, `gotocart`.
- **Getters** como `isLoading`, `isAdding`, `canAdd`, `primaryDisabled`, derivan del
  `uiState` para decidir qué mostrar y si el botón "Añadir" está activo.
- La plantilla usa `lwc:if / lwc:elseif / lwc:else` (el "if/else" de LWC) para pintar
  los distintos estados (cargando, éxito, formulario, error). Reutiliza
  `lvlupProductImage` para la miniatura del producto.

### 4.4 `lvlupQuantitySelector` — selector de cantidad (componente controlado)

```js
@api min = 1; @api max; @api step = 1; @api value = 1;
```
- Es un **componente controlado**: el valor "real" vive en el padre. El hijo solo
  muestra `value` y, al cambiar, **emite** el nuevo valor.
- `validate(quantity)`: comprueba mínimo, máximo y múltiplo, y devuelve
  `{ isValid, reason }`.
- `emit(newValue)`: dispara `quantitychange` con `{ quantity, isValid, reason }`.
- **No** valida stock (eso es del panel). Cada hijo valida solo su parcela.

### 4.5 `lvlupStockAvailabilityPanel` — disponibilidad (emite un veredicto)

```js
@api stock; @api casePack; @api requestedQuantity;
renderedCallback() {
    const isSufficient = this.requested > 0 && this.requested <= this.available;
    // dispara 'stockvalidated' SOLO si cambió (guardado en this._lastKey)
}
```
- `renderedCallback()` es un **hook de ciclo de vida**: corre tras cada render.
- Calcula si hay stock suficiente y emite `stockvalidated`. Usa una *guard* (`_lastKey`)
  para no emitir en bucle (solo cuando el resultado cambia). Es el patrón correcto
  para emitir eventos derivados sin loops infinitos.

### 4.6 `lvlupProductAttributeSelector` — atributos (degrada con elegancia)

- `@api attributes = []` y `@api selected = {}`.
- Si `attributes` está vacío (el catálogo hoy no tiene atributos), **no renderiza
  nada** (`hasAttributes` es `false`). Está listo para el futuro sin estorbar hoy.
- Al cambiar un `<select>`, emite `attributechange` con
  `{ attributeName, value, allRequiredSelected }`.

### 4.7 `lvlupPurchaseSummary` — resumen (presentacional puro)

```js
@api unitPrice; @api quantity; @api currencyCode = 'EUR';
get formattedSubtotal() {
    return new Intl.NumberFormat('es-ES', { style:'currency', currency:'EUR' }).format(this.subtotal);
}
```
- No emite eventos. Solo calcula `unitPrice × quantity` y lo formatea con
  `Intl.NumberFormat` (API nativa del navegador, sin servidor).

### 4.8 `lvlupProductImage` — imagen del producto (rendimiento + navegación)

Resuelve un problema real: la Product Card estándar **no pinta imágenes con URL
externa** en la grilla. Este componente las pinta.

**Imports:** `NavigationMixin` (para enlazar a la ficha).

**Propiedades:** `imageUrl` (preferida, se bindea a `{!Item.defaultImage.url}`),
`sku` (fallback: arma la URL de GitHub), `productId` (para el link),
`baseUrl`, `fileExtension`, `altText`.

```js
get resolvedUrl() {
    if (this.imageUrl) return this.imageUrl;          // 1º: URL directa
    if (!this.sku) return null;
    return `${base}/${this.sku}${ext}`;               // 2º: la arma con el SKU
}
```

**Navegación a la ficha (PDP):**
```js
connectedCallback() {
    this[NavigationMixin.GenerateUrl](this.pageReference).then(url => this.pdpUrl = url);
}
handleClick(event) {
    if (event.ctrlKey || event.metaKey || ...) return;  // respeta "abrir en pestaña nueva"
    event.preventDefault();
    this[NavigationMixin.Navigate](this.pageReference);  // navega dentro de la SPA
}
```
- `GenerateUrl` calcula el `href` real (para que el `<a>` soporte abrir en pestaña
  nueva). `Navigate` hace la navegación **imperativa** (más fiable que confiar en
  que el router intercepte el clic en LWR).
- `pageReference` apunta a la *record page* de `Product2` (la ficha del producto).

**Rendimiento (lo cuidamos a propósito):** `loading="lazy"` (las imágenes fuera de
pantalla no se descargan hasta hacer scroll), `decoding="async"`, **0 llamadas
Apex** y **0 File Storage** (la imagen vive en un host externo). Importante con 51+
tarjetas.

---

## 5. Permission Sets (permisos)

En Salesforce, desplegar código **no** lo hace accesible a los usuarios; hay que
**conceder permisos**. Dos permission sets:

### 5.1 `LvlUp_Inventory_Management`
Da acceso (FLS) a los 4 campos custom de `Product2`. Se asigna al **admin** que
edita inventario. Pensado para gestión interna.

### 5.2 `LvlUp_Quick_Buy_Buyer`
Da al **comprador del storefront**:
- **Acceso a la clase Apex** `LvlupQuickBuyController` (sin esto, el LWC del
  comprador recibe `400 Bad Request` al llamar al servidor).
- **FLS de lectura** sobre los 4 campos.

> Esto fue clave para que el modal funcionara: los usuarios de comunidad necesitan
> acceso explícito a la clase Apex.

---

## 6. El flujo completo (de punta a punta)

1. La **PLP** repite, por cada producto, el `lvlupProductImage` + Product Card +
   `lvlupProductQuickBuy`, todos bindeados al producto actual (`{!Item...}`).
2. El comprador hace clic en **"Comprar"** → `lvlupQuickBuyButton` emite `buyclick`.
3. `lvlupProductQuickBuy` abre el modal y **llama a Apex** (`getProductPurchaseInfo`)
   para traer datos + stock + reglas.
4. El modal muestra el producto. El comprador ajusta **cantidad** → los hijos emiten
   `quantitychange` / `stockvalidated`, que suben (vía el modal) al padre.
5. El padre **recalcula** (`recompute`) y habilita "Añadir" solo si todo es válido.
6. Al confirmar, el padre llama a **`addItemToCart`** (API estándar) → carrito real.
7. Feedback: "Añadido ✓" y el contador del carrito sube.

El diagrama [`contextual-quick-buy-architecture.html`](../ux/contextual-quick-buy-architecture.html)
muestra esto gráficamente (árbol de componentes, flujo de eventos y secuencia
end-to-end).

---

## 7. Glosario rápido

- **PLP**: Product List Page (página de listado/categoría).
- **PDP**: Product Detail Page (ficha del producto).
- **MOQ**: Minimum Order Quantity (cantidad mínima de pedido).
- **DTO / wrapper**: clase simple que solo transporta datos (`ProductPurchaseInfo`).
- **Promise**: en JS, un valor futuro (resultado de una operación asíncrona, como
  una llamada al servidor).
- **Reactividad LWC**: reasignar una propiedad de clase redibuja la plantilla.
- **Bind variable (`:var`)**: forma segura de meter una variable Apex en SOQL.
