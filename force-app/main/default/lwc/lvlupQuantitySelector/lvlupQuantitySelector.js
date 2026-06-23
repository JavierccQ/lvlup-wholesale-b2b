// ============================================================================
//  lvlupQuantitySelector  →  HIJO: selector de cantidad (+ / - / escribir)
// ============================================================================
//  Es un "componente controlado": el valor REAL vive en el padre. Este componente
//  solo MUESTRA "value" y, cuando el usuario lo cambia, EMITE el nuevo valor con
//  un veredicto de validez (mínimo / máximo / múltiplo). NO valida stock (eso es
//  trabajo del panel de stock). Cada hijo valida únicamente su parcela.
// ============================================================================
import { LightningElement, api } from 'lwc';

export default class LvlupQuantitySelector extends LightningElement {
    @api min = 1;            // cantidad mínima (MOQ).
    @api max;                // cantidad máxima (puede no existir).
    @api step = 1;           // múltiplo de compra (case pack).
    @api value = 1;          // valor actual (lo controla el padre).
    @api disabled = false;   // deshabilitar mientras se añade al carrito.

    // Texto de las reglas que se muestra bajo el input (p. ej. "Mín: 5 · Múltiplos de 5").
    get rulesText() {
        const parts = [`Mín: ${this.min || 1}`];
        if ((this.step || 1) > 1) {
            parts.push(`Múltiplos de ${this.step}`);
        }
        if (this.max != null) {
            parts.push(`Máx: ${this.max}`);
        }
        return parts.join(' · '); // une las partes con " · ".
    }

    // Clase CSS del input: añade 'invalid' (borde rojo) si el valor no es válido.
    get inputClass() {
        return this.value != null && !this.validate(this.value).isValid
            ? 'qty invalid'
            : 'qty';
    }

    // Botón "−": resta un múltiplo y emite.
    handleDecrement() {
        this.emit((Number(this.value) || 0) - (this.step || 1));
    }
    // Botón "+": suma un múltiplo y emite.
    handleIncrement() {
        this.emit((Number(this.value) || 0) + (this.step || 1));
    }
    // El usuario escribió en el input: parseamos a entero y emitimos.
    handleChange(event) {
        const parsed = parseInt(event.target.value, 10);
        // Number.isNaN → si lo escrito no es un número, emitimos null (inválido).
        this.emit(Number.isNaN(parsed) ? null : parsed);
    }

    // Centraliza el "emitir": valida y dispara 'quantitychange' con el resultado.
    emit(newValue) {
        const verdict = this.validate(newValue);
        this.dispatchEvent(
            new CustomEvent('quantitychange', {
                detail: {
                    quantity: newValue,
                    isValid: verdict.isValid,
                    reason: verdict.reason // motivo si no es válido (para el mensaje).
                }
            })
        );
    }

    // Reglas de negocio B2B sobre la cantidad. Devuelve { isValid, reason }.
    validate(quantity) {
        if (quantity == null) {
            return { isValid: false, reason: 'Introduce una cantidad.' };
        }
        const min = this.min || 1;
        const step = this.step || 1;
        if (quantity < min) {
            return { isValid: false, reason: `Pedido mínimo: ${min} unidades.` };
        }
        if (this.max != null && quantity > this.max) {
            return { isValid: false, reason: `Máximo ${this.max} unidades por pedido.` };
        }
        // % es el módulo (resto de la división). Si no es 0, no es múltiplo de "step".
        if (step > 1 && quantity % step !== 0) {
            return { isValid: false, reason: `Este producto se vende en múltiplos de ${step}.` };
        }
        return { isValid: true, reason: null };
    }
}
