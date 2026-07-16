// ============================================================================
//  lvlupProductAvailability → PDP container for the stock availability panel
// ============================================================================
//  Thin container (ADR-0008 / D6): receives the Product2 recordId from the
//  product page, loads purchase info through the existing cacheable Apex
//  (LvlupQuickBuyController, REGLA-004) and renders the existing presentational
//  panel (lvlupStockAvailabilityPanel). No business logic of its own, so Quick
//  Buy behaviour is untouched.
// ============================================================================
import { LightningElement, api, wire } from "lwc";
import getProductPurchaseInfo from "@salesforce/apex/LvlupQuickBuyController.getProductPurchaseInfo";

export default class LvlupProductAvailability extends LightningElement {
  // Product2 Id. On the Builder product page it is bound to {!recordId}.
  @api recordId;

  info;

  @wire(getProductPurchaseInfo, { productId: "$recordId" })
  wiredPurchaseInfo({ data, error }) {
    if (data) {
      this.info = data;
    } else if (error) {
      // Render nothing for the buyer; keep the diagnostic in the console.
      this.info = undefined;
      console.error(
        "lvlupProductAvailability: getProductPurchaseInfo failed. recordId=" +
          this.recordId,
        error
      );
    }
  }

  get showPanel() {
    return Boolean(this.info);
  }
}
