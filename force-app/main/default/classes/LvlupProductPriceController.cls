/**
 * Serves the buyer-facing card price (negotiated + strikethrough list price) for
 * the custom PLP grid, where the standard product card does not render prices at
 * runtime (validated 2026-07-17; see ADR-0008 addendum).
 *
 * `without sharing` on purpose (REGLA-004): storefront buyers do not get
 * Product2/PricebookEntry rows through sharing; visibility is granted by the
 * commerce entitlement, so reading display prices of entitled products is safe.
 *
 * Price books are resolved from standard commerce configuration, not hardcoded
 * names: the strikethrough price book comes from WebStore.StrikethroughPricebookId
 * and the selling price book from the buyer account's BuyerGroupPricebook chain.
 * Internal users (no buyer account) resolve no selling price and the LWC renders
 * nothing (QA runs as a real buyer per REGLA-001).
 */
public without sharing class LvlupProductPriceController {
  static final String WEBSTORE_NAME = 'LevelUp Wholesale';

  @AuraEnabled(cacheable=true)
  public static ProductPriceInfo getProductPrice(Id productId) {
    return getProductPrice(
      productId,
      resolveSellingPricebookId(),
      resolveStrikethroughPricebookId()
    );
  }

  // Core logic with injected price book ids so tests do not depend on
  // WebStore/BuyerGroup records (REGLA-011).
  public static ProductPriceInfo getProductPrice(
    Id productId,
    Id sellingPricebookId,
    Id strikethroughPricebookId
  ) {
    ProductPriceInfo info = new ProductPriceInfo();
    info.currencyIsoCode = UserInfo.getDefaultCurrency();
    for (PricebookEntry entry : [
      SELECT Pricebook2Id, UnitPrice
      FROM PricebookEntry
      WHERE
        Product2Id = :productId
        AND IsActive = TRUE
        AND Pricebook2Id IN (:sellingPricebookId, :strikethroughPricebookId)
    ]) {
      if (entry.Pricebook2Id == sellingPricebookId) {
        info.unitPrice = entry.UnitPrice;
      } else {
        info.listPrice = entry.UnitPrice;
      }
    }
    // The strikethrough price is only meaningful when it is higher than what
    // the buyer actually pays.
    if (
      info.listPrice != null &&
      info.unitPrice != null &&
      info.listPrice <= info.unitPrice
    ) {
      info.listPrice = null;
    }
    return info;
  }

  static Id resolveSellingPricebookId() {
    User currentUser = [
      SELECT Contact.AccountId
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];
    Id accountId = currentUser.Contact == null
      ? null
      : currentUser.Contact.AccountId;
    if (accountId == null) {
      return null;
    }
    for (BuyerGroupPricebook groupPricebook : [
      SELECT Pricebook2Id
      FROM BuyerGroupPricebook
      WHERE
        IsActive = TRUE
        AND BuyerGroupId IN (
          SELECT BuyerGroupId
          FROM BuyerGroupMember
          WHERE BuyerId = :accountId
        )
      LIMIT 1
    ]) {
      return groupPricebook.Pricebook2Id;
    }
    return null;
  }

  static Id resolveStrikethroughPricebookId() {
    for (WebStore store : [
      SELECT StrikethroughPricebookId
      FROM WebStore
      WHERE Name = :WEBSTORE_NAME
      LIMIT 1
    ]) {
      return store.StrikethroughPricebookId;
    }
    return null;
  }

  public class ProductPriceInfo {
    @AuraEnabled
    public Decimal unitPrice;
    @AuraEnabled
    public Decimal listPrice;
    @AuraEnabled
    public String currencyIsoCode;
  }
}
