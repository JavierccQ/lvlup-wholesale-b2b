// ============================================================================
//  lvlupProductPrice → card price line for the custom PLP grid
// ============================================================================
//  The standard product card inside the Grid + {!Item} pattern does not render
//  its price block at runtime (REGLA-005/027 family; see ADR-0008 addendum), so
//  this presentational component paints the negotiated price plus the
//  strikethrough list price from the existing pricing data via cacheable Apex.
// ============================================================================
import { LightningElement, api, wire } from "lwc";
import getProductPrice from "@salesforce/apex/LvlupProductPriceController.getProductPrice";

export default class LvlupProductPrice extends LightningElement {
  // Product2 Id. In the Grid it is bound manually to {!Item.id} (REGLA-005).
  @api productId;

  price;

  @wire(getProductPrice, { productId: "$productId" })
  wiredPrice({ data, error }) {
    if (data) {
      this.price = data;
    } else if (error) {
      // Render nothing for the buyer; keep the diagnostic in the console.
      this.price = undefined;
      console.error(
        "lvlupProductPrice: getProductPrice failed. productId=" +
          this.productId,
        error
      );
    }
  }

  get showPrice() {
    return Boolean(this.price) && this.price.unitPrice != null;
  }

  get showListPrice() {
    return this.showPrice && this.price.listPrice != null;
  }

  get formattedUnitPrice() {
    return this.format(this.price.unitPrice);
  }

  get formattedListPrice() {
    return this.format(this.price.listPrice);
  }

  // Matches the standard results card formatting (en-US locale of the store).
  format(value) {
    try {
      return new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: this.price.currencyIsoCode || "USD"
      }).format(value);
    } catch {
      return `${value}`;
    }
  }
}
