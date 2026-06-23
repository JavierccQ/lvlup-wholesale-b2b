// ============================================================================
//  lvlupStockAvailabilityPanel  →  HIJO: muestra el stock y emite un VEREDICTO
// ============================================================================
//  Muestra "En stock / Sin stock / Quedan X" y, además, calcula si hay stock
//  suficiente para la cantidad pedida y AVISA al padre con 'stockvalidated'.
//  El aviso se hace en renderedCallback (un "hook" del ciclo de vida) con una
//  guarda para NO emitir en bucle infinito.
// ============================================================================
import { LightningElement, api } from 'lwc';

export default class LvlupStockAvailabilityPanel extends LightningElement {
    @api stock;             // unidades disponibles.
    @api casePack;          // tamaño del case pack (informativo).
    @api requestedQuantity; // cuántas pidió el usuario.

    _lastKey;               // guarda: recuerda el último veredicto emitido (privado por el "_").

    // Number(x) || 0 → convierte a número; si es null/NaN, queda 0.
    get available() { return Number(this.stock) || 0; }
    get requested() { return Number(this.requestedQuantity) || 0; }

    get isOutOfStock() { return this.available <= 0; }
    get isInsufficient() { return !this.isOutOfStock && this.requested > this.available; }

    // Clase del "led" (puntito de color): verde / ámbar / rojo.
    get ledClass() {
        if (this.isOutOfStock) return 'led bad';
        if (this.isInsufficient) return 'led warn';
        return 'led ok';
    }

    // Texto de estado que se muestra.
    get statusText() {
        if (this.isOutOfStock) return 'Sin stock';
        if (this.isInsufficient) return `Quedan ${this.available} uds · solicitado ${this.requested}`;
        return `En stock · ${this.available} uds`;
    }

    // Muestra "· case pack N" solo si el case pack es mayor que 1.
    get casePackText() {
        return (Number(this.casePack) || 1) > 1 ? `· case pack ${this.casePack}` : '';
    }

    // renderedCallback() es un HOOK DEL CICLO DE VIDA: el framework lo llama
    // DESPUÉS de cada render del componente. Cuidado: puede ejecutarse MUCHAS veces.
    renderedCallback() {
        const isSufficient = this.requested > 0 && this.requested <= this.available;
        // Creamos una "clave" con los 3 datos. Solo emitimos si la clave CAMBIÓ
        // respecto a la última vez (_lastKey). Sin esta guarda, emitiríamos en cada
        // render → el padre cambiaría estado → re-render → ... bucle infinito.
        const key = `${this.available}|${this.requested}|${isSufficient}`;
        if (key !== this._lastKey) {
            this._lastKey = key;
            this.dispatchEvent(
                new CustomEvent('stockvalidated', {
                    detail: {
                        requestedQuantity: this.requested,
                        available: this.available,
                        isSufficient
                    }
                })
            );
        }
    }
}
