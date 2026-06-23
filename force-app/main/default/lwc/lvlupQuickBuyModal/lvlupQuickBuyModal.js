// ============================================================================
//  lvlupQuickBuyModal  →  CONTENEDOR del modal ("padre intermedio")
// ============================================================================
//  Es el caso de comunicación más interesante: recibe datos del PADRE (props
//  @api) Y recibe eventos de SUS PROPIOS HIJOS (cantidad, stock, atributos) y los
//  RE-EMITE hacia el padre. A eso se le llama "re-dispatch": el evento sube 3
//  niveles (hijo → este contenedor → padre). El contenedor casi no piensa: solo
//  decide QUÉ mostrar según el estado y reenvía eventos.
// ============================================================================
import { LightningElement, api } from 'lwc';

export default class LvlupQuickBuyModal extends LightningElement {
    // --- Datos que baja el PADRE ---
    @api product;                 // objeto del producto (o null mientras carga).
    @api isOpen = false;          // ¿mostrar el modal?
    @api uiState = 'closed';      // estado actual (decide qué pantalla pintar).
    @api quantity;               // cantidad actual.
    @api selectedAttributes = {}; // atributos elegidos.
    @api message;                // mensaje { type, text }.

    // --- GETTERS derivados del uiState (deciden qué se ve) ---
    // El HTML usa estos para mostrar/ocultar partes (lwc:if={isLoading}, etc.).
    get isLoading() { return this.uiState === 'loadingProduct'; }
    get isAdding()  { return this.uiState === 'addingToCart'; }
    get isSuccess() { return this.uiState === 'addedSuccess'; }
    get isError()   { return this.uiState === 'addError'; }
    get canAdd()    { return this.uiState === 'readyToAdd'; }

    // Mostrar el formulario si hay producto y no estamos cargando ni en éxito.
    get showForm() { return !!this.product && !this.isLoading && !this.isSuccess; }
    // Deshabilitar controles mientras se añade al carrito.
    get controlsDisabled() { return this.isAdding; }

    // Texto del botón principal según el estado.
    get primaryLabel() {
        if (this.isAdding) return 'Añadiendo…';
        if (this.isError) return 'Reintentar';
        return 'Añadir';
    }
    // El botón principal está deshabilitado salvo que estemos "listos" o en error (reintentar).
    get primaryDisabled() {
        if (this.isAdding) return true;
        return !(this.canAdd || this.isError);
    }

    get hasMessage() { return !!(this.message && this.message.text); }
    // Devuelve la clase CSS según el tipo de mensaje (ok / warn / bad).
    get messageClass() { return `msg ${this.message ? this.message.type : ''}`; }
    // ¿el producto tiene atributos para mostrar? (hoy no).
    get hasAttributes() {
        return !!(this.product && this.product.attributes && this.product.attributes.length);
    }

    // --- Valores que este contenedor BAJA a sus propios hijos ---
    // (usan ?: para evitar errores cuando product es null)
    get unitPrice()  { return this.product ? this.product.unitPrice : null; }
    get stock()      { return this.product ? this.product.stock : 0; }
    get increment()  { return this.product ? this.product.increment : 1; }
    get minQuantity(){ return this.product ? this.product.minQuantity : 1; }
    get maxQuantity(){ return this.product ? this.product.maxQuantity : null; }
    get attributes() { return this.product ? this.product.attributes : []; }

    // Evita que un clic DENTRO de la caja del modal cierre el modal (que solo se
    // cierra al hacer clic en el fondo oscuro / backdrop).
    stopPropagation(event) {
        event.stopPropagation();
    }

    // --- RE-DISPATCH: recibe eventos de los hijos y los reemite al padre ---
    // Recibe 'quantitychange' del selector y lo vuelve a emitir igual hacia arriba.
    handleQuantityChange(event) {
        this.dispatchEvent(new CustomEvent('quantitychange', { detail: event.detail }));
    }
    handleAttributeChange(event) {
        this.dispatchEvent(new CustomEvent('attributechange', { detail: event.detail }));
    }
    handleStockValidated(event) {
        this.dispatchEvent(new CustomEvent('stockvalidated', { detail: event.detail }));
    }

    // --- Eventos PROPIOS del modal hacia el padre ---
    handleClose() {
        this.dispatchEvent(new CustomEvent('closemodal', { detail: { reason: 'cancel' } }));
    }
    handleBackdrop() { // clic en el fondo oscuro
        this.dispatchEvent(new CustomEvent('closemodal', { detail: { reason: 'backdrop' } }));
    }
    handleContinue() { // "Seguir comprando" tras el éxito
        this.dispatchEvent(new CustomEvent('closemodal', { detail: { reason: 'success' } }));
    }
    handleConfirm() { // "Añadir" → pide al padre que añada al carrito
        this.dispatchEvent(
            new CustomEvent('confirmaddtocart', {
                detail: {
                    productId: this.product ? this.product.productId : null,
                    quantity: this.quantity,
                    selectedAttributes: this.selectedAttributes
                }
            })
        );
    }
    handleGoToCart() {
        this.dispatchEvent(new CustomEvent('gotocart'));
    }
}
