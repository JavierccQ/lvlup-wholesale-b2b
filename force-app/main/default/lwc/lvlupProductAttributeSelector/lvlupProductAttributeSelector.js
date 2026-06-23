// ============================================================================
//  lvlupProductAttributeSelector  →  HIJO: selector de atributos (color, etc.)
// ============================================================================
//  "Degrada con elegancia": si el producto NO tiene atributos (caso actual del
//  catálogo), no renderiza NADA y no estorba. Está listo para el futuro: cuando
//  haya atributos, los muestra como <select> y emite 'attributechange'.
// ============================================================================
import { LightningElement, api } from 'lwc';

export default class LvlupProductAttributeSelector extends LightningElement {
    // attributes: lista de atributos del producto. Forma esperada de cada uno:
    //   { name, label, required, options: [{ label, value }] }
    @api attributes = [];
    // selected: objeto con lo ya elegido, p. ej. { color: 'negro' }.
    @api selected = {};

    // ¿Hay atributos? El HTML usa esto para mostrar/ocultar todo el bloque.
    get hasAttributes() {
        return Array.isArray(this.attributes) && this.attributes.length > 0;
    }

    // El usuario cambió un <select>.
    handleChange(event) {
        // data-name="color" en el HTML → se lee como event.target.dataset.name.
        const attributeName = event.target.dataset.name;
        const value = event.target.value;

        // { ...this.selected, [attributeName]: value } → copia lo elegido y
        // actualiza/añade la clave que cambió (nombre dinámico con [ ]).
        const updated = { ...this.selected, [attributeName]: value };

        // ¿Están elegidos TODOS los atributos obligatorios?
        //   filter(required) → quedarse con los obligatorios.
        //   every(...)       → comprobar que cada uno tiene valor en "updated".
        const allRequiredSelected = (this.attributes || [])
            .filter((attr) => attr.required)
            .every((attr) => updated[attr.name]);

        // Avisamos al padre con el cambio y si ya está todo lo obligatorio.
        this.dispatchEvent(
            new CustomEvent('attributechange', {
                detail: { attributeName, value, allRequiredSelected }
            })
        );
    }
}
