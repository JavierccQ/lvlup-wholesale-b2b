// ============================================================================
//  lvlupPurchaseSummary  →  HIJO "presentacional puro": el resumen del precio
// ============================================================================
//  No emite eventos ni tiene lógica de negocio. Solo recibe datos (props @api),
//  calcula "precio × cantidad" y lo muestra formateado como moneda. Es el tipo de
//  componente más simple: entran props → sale UI.
// ============================================================================
import { LightningElement, api } from 'lwc';

export default class LvlupPurchaseSummary extends LightningElement {
    @api unitPrice;            // precio unitario (del Buyer Group).
    @api quantity;             // cantidad elegida.
    @api currencyCode = 'EUR'; // moneda (por defecto euros).

    // ¿la cantidad es válida para calcular? (mayor que 0)
    get hasValidQuantity() {
        return Number(this.quantity) > 0;
    }

    // Subtotal = precio × cantidad. (Number(x) || 0 evita NaN si algo viene vacío.)
    get subtotal() {
        return (Number(this.unitPrice) || 0) * (Number(this.quantity) || 0);
    }

    // Subtotal formateado (o "—" si la cantidad no es válida).
    get formattedSubtotal() {
        return this.hasValidQuantity ? this.format(this.subtotal) : '—';
    }

    // Texto del cálculo, p. ej. "25 uds × 419,00 €".
    get calcText() {
        const units = this.hasValidQuantity ? this.quantity : '—';
        return `${units} uds × ${this.format(Number(this.unitPrice) || 0)}`;
    }

    // Formatea un número como moneda usando Intl.NumberFormat (API NATIVA del
    // navegador, no del servidor): respeta el formato español (es-ES) y la moneda.
    format(value) {
        try {
            return new Intl.NumberFormat('es-ES', {
                style: 'currency',
                currency: this.currencyCode || 'EUR'
            }).format(value);
        } catch (error) {
            // Si la moneda fuera inválida, mostramos algo simple en vez de romper.
            return `${value} ${this.currencyCode || 'EUR'}`;
        }
    }
}
