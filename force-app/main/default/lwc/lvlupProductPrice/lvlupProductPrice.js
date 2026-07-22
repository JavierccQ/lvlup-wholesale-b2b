// ============================================================================
//  lvlupProductPrice → SKU + brand + price block for the custom PLP grid card
// ============================================================================
//  The standard product card inside the Grid + {!Item} pattern does not render
//  its price block at runtime (REGLA-005/027 family; see ADR-0008 addendum).
//  This component renders the whole meta+price block (SKU, brand and price) so
//  the layout is fully controlled — notably the SKU and the discount badge share
//  one row. The standard card is kept only for the product name and the wishlist
//  heart; its own SKU and brand are hidden via scoped CSS. SKU and brand come in
//  as @api bound to {!Item.fields...}; the price comes from cacheable Apex.
// ============================================================================
import { LightningElement, api, wire } from "lwc";
import getProductPrice from "@salesforce/apex/LvlupProductPriceController.getProductPrice";

export default class LvlupProductPrice extends LightningElement {
  // Product2 Id. In the Grid it is bound manually to {!Item.id} (REGLA-005).
  @api productId;
  // Meta bound to the search item fields ({!Item.fields.*.value}).
  @api sku;
  @api brand;

  price;

  @wire(getProductPrice, { productId: "$productId" })
  wiredPrice({ data, error }) {
    if (data) {
      this.price = data;
    } else if (error) {
      // Render no price for the buyer; keep the diagnostic in the console.
      this.price = undefined;
      console.error(
        "lvlupProductPrice: getProductPrice failed. productId=" +
          this.productId,
        error
      );
    }
  }

  get showSku() {
    return Boolean(this.sku);
  }

  get showBrand() {
    return Boolean(this.brand);
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

  // Whole-percent saving vs the list price; only shown when there is a real
  // discount (list price higher than what the buyer pays).
  get discountPercent() {
    if (!this.showListPrice) {
      return null;
    }
    const list = Number(this.price.listPrice);
    const unit = Number(this.price.unitPrice);
    if (!list || list <= unit) {
      return null;
    }
    return Math.round(((list - unit) / list) * 100);
  }

  get showDiscount() {
    return this.discountPercent > 0;
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
