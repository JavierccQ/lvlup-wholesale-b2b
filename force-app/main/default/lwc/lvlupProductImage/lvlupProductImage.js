// ============================================================================
//  lvlupProductImage  →  imagen del producto (en la grilla PLP y en el modal)
// ============================================================================
//  Existe porque la Product Card ESTÁNDAR no pinta imágenes con URL externa en la
//  grilla de búsqueda. Este componente las pinta él mismo. Además, si recibe un
//  productId, envuelve la imagen en un enlace a la ficha del producto (PDP).
//
//  Pensado para RENDIMIENTO (importante con 51+ tarjetas):
//   - 0 llamadas Apex / 0 ida-y-vuelta al servidor para la imagen (la URL se
//     calcula en el cliente).
//   - loading="lazy" en el <img> (HTML): no descarga imágenes fuera de pantalla.
//   - 0 File Storage de Salesforce (la imagen vive en un host externo).
// ============================================================================
import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getExternalImageUrls from '@salesforce/apex/LvlupProductImageController.getExternalImageUrls';

// Constante de módulo (fuera de la clase): la URL base por defecto de las imágenes.
const DEFAULT_BASE_URL =
    'https://raw.githubusercontent.com/JavierccQ/lvlup-wholesale-b2b/main/data/product-images';

export default class LvlupProductImage extends NavigationMixin(LightningElement) {
    // Fuente de imagen PREFERIDA: se bindea a {!Item.defaultImage.url} en el Grid.
    @api imageUrl;
    // Fuente ALTERNATIVA: si no hay imageUrl, arma la URL con el SKU
    // ({!Item.fields.StockKeepingUnit.value}).
    @api sku;
    // Habilita el enlace a la ficha (PDP): se bindea a {!Item.id}.
    @api productId;
    @api altText;                       // texto alternativo de la imagen.
    @api baseUrl = DEFAULT_BASE_URL;    // URL base (configurable en el Builder).
    @api fileExtension = '.png';        // extensión del archivo.

    hasError = false;   // se pone true si la imagen no carga (404, etc.).
    pdpUrl;             // URL calculada de la ficha (para el atributo href del <a>).

    // Map SKU -> URL externa real (productos de integración, p. ej. Platzi). El
    // índice de búsqueda NO expone esa URL, así que la pedimos por Apex. La
    // llamada es @wire cacheable: se hace UNA vez y se comparte entre TODAS las
    // tarjetas de la grilla (sin penalizar el rendimiento).
    externalUrlsBySku;

    @wire(getExternalImageUrls)
    wiredExternalUrls({ data }) {
        if (data) {
            this.externalUrlsBySku = data;
            // Si la imagen ya había fallado con el fallback, reintentar ahora que
            // tenemos la URL real.
            this.hasError = false;
        }
    }

    // pageReference: el "objeto destino" de la navegación. Aquí: la record page de
    // Product2 (que en Commerce es la ficha del producto / PDP).
    get pageReference() {
        return {
            type: 'standard__recordPage',
            attributes: {
                recordId: this.productId,
                objectApiName: 'Product2',
                actionName: 'view'
            }
        };
    }

    // connectedCallback(): HOOK del ciclo de vida; corre cuando el componente se
    // INSERTA en el DOM. Aquí calculamos la URL de la ficha (GenerateUrl es async →
    // devuelve Promise) para poder ponerla como href real del enlace (esto permite
    // "abrir en pestaña nueva").
    connectedCallback() {
        if (this.productId) {
            this[NavigationMixin.GenerateUrl](this.pageReference)
                .then((url) => {
                    this.pdpUrl = url;
                })
                .catch(() => {
                    // Si no hay contexto de navegación, dejamos la imagen sin enlace.
                });
        }
    }

    // Clic en la imagen → navegamos a la ficha de forma IMPERATIVA (más fiable en
    // LWR que confiar en que el router intercepte el clic del <a>).
    handleClick(event) {
        if (!this.productId) {
            return;
        }
        // Si el usuario hace ctrl/cmd/shift-clic o clic central, NO interceptamos:
        // dejamos que el navegador use el href nativo (abrir en pestaña/ventana nueva).
        if (event.ctrlKey || event.metaKey || event.shiftKey || event.button === 1) {
            return;
        }
        event.preventDefault();                                  // evita la navegación nativa.
        this[NavigationMixin.Navigate](this.pageReference);      // navega dentro de la SPA.
    }

    // Resuelve qué URL usar para el <img>, por prioridad.
    get resolvedUrl() {
        // 1º: URL externa por SKU (productos de integración). Cada producto
        // referencia su imagen desde SU fuente de verdad, sin copiar nada al repo.
        if (this.externalUrlsBySku && this.sku && this.externalUrlsBySku[this.sku]) {
            return this.externalUrlsBySku[this.sku];
        }
        // 2º: URL directa (defaultImage.url), si el índice la expone.
        if (this.imageUrl) {
            return this.imageUrl;
        }
        // 3º: fallback por SKU (catálogo interno alojado en GitHub).
        if (!this.sku) {
            return null;
        }
        // .replace(/\/+$/, '') quita barras "/" sobrantes al final del baseUrl.
        const base = (this.baseUrl || DEFAULT_BASE_URL).replace(/\/+$/, '');
        const ext = this.fileExtension || '.png';
        // Template string: arma "https://.../<SKU>.png".
        return `${base}/${this.sku}${ext}`;
    }

    // ¿mostrar la imagen? Solo si hay URL y no falló la carga.
    get showImage() {
        return !!this.resolvedUrl && !this.hasError;
    }

    // Texto alternativo (accesibilidad): el dado, o el SKU, o un genérico.
    get computedAlt() {
        return this.altText || this.sku || 'Producto';
    }

    // onerror del <img>: si la imagen no carga, mostramos un placeholder limpio.
    handleError() {
        this.hasError = true;
    }
}
