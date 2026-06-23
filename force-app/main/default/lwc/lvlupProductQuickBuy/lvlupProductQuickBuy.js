// ============================================================================
//  lvlupProductQuickBuy  →  EL PADRE / ORQUESTADOR del feature Quick Buy
// ============================================================================
//  Un LWC (Lightning Web Component) es un componente web (HTML+JS+CSS). Esta es
//  la parte JS (la lógica). Este componente es el "cerebro": guarda TODO el
//  estado y coordina a sus hijos (botón + modal). Los datos bajan a los hijos
//  por propiedades @api; los avisos suben desde los hijos por eventos.
// ============================================================================

// --- IMPORTS (traer cosas de otros módulos) ---
// LightningElement: la clase base que todo LWC debe extender.
// api: decorador para hacer PÚBLICA una propiedad (como un "prop" de React).
import { LightningElement, api } from 'lwc';
// NavigationMixin: utilidad de Salesforce para NAVEGAR (cambiar de página) en el sitio.
import { NavigationMixin } from 'lightning/navigation';
// ¡Así se importa un MÉTODO APEX! La ruta @salesforce/apex/Clase.metodo
// convierte el método del servidor en una FUNCIÓN JS que devuelve una Promise.
import getProductPurchaseInfo from '@salesforce/apex/LvlupQuickBuyController.getProductPurchaseInfo';
// addItemToCart: función de la API ESTÁNDAR del carrito de B2B Commerce.
// Añade un producto al carrito real. Disponible en orgs con Commerce.
import { addItemToCart } from 'commerce/cartApi';

// "export default class ... extends NavigationMixin(LightningElement)":
// extendemos la clase base PERO envuelta en NavigationMixin (un "mixin" = le
// añade capacidades, aquí: poder navegar).
export default class LvlupProductQuickBuy extends NavigationMixin(LightningElement) {
    // --- PROPIEDADES PÚBLICAS (@api): entran desde la página / el Builder ---
    @api productId;                 // Id del producto. En el Grid se bindea a {!Item.id}.
    @api recordId;                  // En una "record page", Salesforce lo inyecta solo.
    @api buttonLabel = 'Comprar';   // Texto del botón (valor por defecto).

    // --- ESTADO INTERNO (privado, reactivo) ---
    // En LWC, reasignar una de estas propiedades REDIBUJA la plantilla automáticamente.
    isOpen = false;                 // ¿el modal está abierto?
    uiState = 'closed';             // estado actual de la UI (máquina de estados, ver recompute()).
    product;                        // datos del producto (los trae Apex).
    quantity;                       // cantidad elegida.
    selectedAttributes = {};        // atributos elegidos (hoy vacío).
    message;                        // mensaje a mostrar { type: 'ok'|'warn'|'bad', text }.

    // Banderas de validación: cada hijo reporta SU parcela; el padre las combina.
    quantityValid = false;
    quantityReason;                 // motivo si la cantidad no es válida.
    stockSufficient = false;
    attributesComplete = true;      // true por defecto: hoy no hay atributos obligatorios.

    // --- GETTERS (propiedades CALCULADAS, de solo lectura) ---
    // Un "get" se recalcula cada vez que se usa. Como un "computed".

    // El Id efectivo: usa productId; si no, el recordId de la página.
    get effectiveProductId() {
        return this.productId || this.recordId;
    }

    // Prepara el objeto que le pasamos al modal. Object.assign({}, a, b) hace una
    // COPIA de "product" y le añade attributes: [] (hoy no hay atributos).
    get modalProduct() {
        if (!this.product) {
            return null;
        }
        return Object.assign({}, this.product, { attributes: [] });
    }

    // --- MANEJADORES DE EVENTOS Y MÉTODOS ---

    // El botón hijo emitió 'buyclick' → abrimos y cargamos.
    handleBuyClick() {
        this.openAndLoad();
    }

    // Abre el modal en estado "cargando" y PIDE LOS DATOS AL SERVIDOR (Apex).
    openAndLoad() {
        this.isOpen = true;
        this.uiState = 'loadingProduct';
        this.message = null;
        this.product = null;

        // Llamamos al método Apex como una función que devuelve Promise.
        // Los argumentos van en un objeto cuya CLAVE debe llamarse igual que el
        // parámetro de Apex ('productId').
        getProductPurchaseInfo({ productId: this.effectiveProductId })
            .then((info) => {
                // .then() corre si la llamada tuvo éxito. "info" es el wrapper de Apex.
                this.product = info;
                this.quantity = info.minQuantity || 1; // arrancamos en el MOQ.
                this.selectedAttributes = {};
                this.quantityValid = true;
                this.attributesComplete = true;
                // ¿hay stock para esa cantidad inicial?
                this.stockSufficient =
                    this.quantity > 0 && (Number(info.stock) || 0) >= this.quantity;
                this.recompute(); // recalcula el estado de la UI.
            })
            .catch((error) => {
                // .catch() corre si la llamada falló. Mostramos el error REAL para depurar.
                this.uiState = 'open';
                const detail =
                    (error && error.body && error.body.message) || // formato típico de error Apex
                    (error && error.message) ||
                    'Error desconocido';
                this.message = {
                    type: 'bad',
                    text: `No se pudo cargar el producto: ${detail}`
                };
                // eslint-disable-next-line no-console
                console.error(
                    'lvlupProductQuickBuy: getProductPurchaseInfo failed. productId=' +
                        this.effectiveProductId,
                    error
                );
            });
    }

    // El selector de cantidad (vía el modal) avisó de un cambio.
    handleQuantityChange(event) {
        // event.detail es lo que el hijo metió en el CustomEvent.
        this.quantity = event.detail.quantity;
        this.quantityValid = event.detail.isValid;
        this.quantityReason = event.detail.reason;
        this.recompute();
    }

    // El selector de atributos avisó de un cambio (hoy inactivo, listo para el futuro).
    handleAttributeChange(event) {
        // Copiamos el objeto y actualizamos la clave que cambió (nombre dinámico [x]).
        this.selectedAttributes = Object.assign({}, this.selectedAttributes, {
            [event.detail.attributeName]: event.detail.value
        });
        this.attributesComplete = event.detail.allRequiredSelected;
        this.recompute();
    }

    // El panel de stock emitió su veredicto.
    handleStockValidated(event) {
        this.stockSufficient = event.detail.isSufficient;
        this.recompute();
    }

    /**
     * recompute(): LA MÁQUINA DE ESTADOS. Es la ÚNICA fuente de verdad del
     * uiState y del message. El PADRE decide si todo está listo; los hijos solo
     * reportan su parcela. Orden de prioridad de los problemas:
     *   cantidad inválida → atributos incompletos → sin stock → listo.
     */
    recompute() {
        // Si estamos añadiendo o ya se añadió, no recalculamos (no pisar esos estados).
        if (this.uiState === 'addingToCart' || this.uiState === 'addedSuccess') {
            return;
        }
        if (!this.product) {
            return;
        }
        if (!this.quantityValid) {
            this.uiState = 'invalidQuantity';
            this.message = { type: 'bad', text: this.quantityReason || 'Cantidad no válida.' };
        } else if (!this.attributesComplete) {
            this.uiState = 'incompleteAttributes';
            this.message = { type: 'warn', text: 'Selecciona las opciones obligatorias.' };
        } else if (!this.stockSufficient) {
            this.uiState = 'insufficientStock';
            // Mensaje distinto si es 0 (sin stock) o si pidió más de lo disponible.
            this.message =
                (Number(this.product.stock) || 0) <= 0
                    ? { type: 'bad', text: 'Este producto no tiene stock disponible.' }
                    : {
                          type: 'warn',
                          text: `Solo quedan ${this.product.stock} unidades disponibles.`
                      };
        } else {
            // Todo ok → habilitamos "Añadir".
            this.uiState = 'readyToAdd';
            this.message = { type: 'ok', text: 'Listo para añadir al carrito.' };
        }
    }

    // El modal confirmó → AÑADIR AL CARRITO REAL.
    handleConfirm(event) {
        const { productId, quantity } = event.detail; // desestructuración del detail.
        this.uiState = 'addingToCart';
        this.message = null;

        // addItemToCart(productId, quantity) → API estándar; devuelve Promise.
        addItemToCart(productId, quantity)
            .then(() => {
                this.uiState = 'addedSuccess';
                this.message = {
                    type: 'ok',
                    text: `Añadido al carrito: ${quantity} uds.`
                };
            })
            .catch(() => {
                this.uiState = 'addError';
                this.message = {
                    type: 'bad',
                    text: 'No se pudo añadir al carrito. Inténtalo de nuevo.'
                };
            });
    }

    // El modal pidió cerrarse → reseteamos todo al estado inicial.
    handleCloseModal() {
        this.isOpen = false;
        this.uiState = 'closed';
        this.product = null;
        this.message = null;
        this.quantity = null;
        this.selectedAttributes = {};
    }

    // "Ir al carrito" → navegamos a /cart usando NavigationMixin.
    handleGoToCart() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url: '/cart' }
        });
    }
}
