// ============================================================================
//  lvlupQuickBuyButton  →  HIJO "tonto": el botón "Comprar"
// ============================================================================
//  No tiene lógica de negocio. Su único trabajo: al hacer clic, AVISAR al padre
//  emitiendo un evento. Es el ejemplo más puro de comunicación HIJO → PADRE.
// ============================================================================
import { LightningElement, api } from 'lwc';

export default class LvlupQuickBuyButton extends LightningElement {
    // Propiedades públicas: el padre las rellena.
    @api productId;               // qué producto representa este botón.
    @api label = 'Comprar';       // texto del botón.
    @api disabled = false;        // si el botón está deshabilitado.

    // Se ejecuta al hacer clic (lo conecta el HTML con onclick={handleClick}).
    handleClick() {
        // dispatchEvent + CustomEvent = "emitir un evento hacia arriba".
        //   'buyclick'        → nombre del evento (en LWC: minúsculas, sin guiones).
        //   { detail: {...} } → datos que viajan con el evento; el padre los lee
        //                       como event.detail.productId.
        this.dispatchEvent(
            new CustomEvent('buyclick', {
                detail: { productId: this.productId }
            })
        );
    }
}
