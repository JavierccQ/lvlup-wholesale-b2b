/*
 * Seed standard Purchase Quantity Rules (ADR-0009, phase 2 of the product
 * information enrichment initiative).
 *
 * These are DATA (records), not metadata (see adr/0003-commerce-data-vs-metadata-strategy.md).
 *
 * What it does, idempotently:
 *   1. Reads the current purchase-rule combo (min / increment / max) of every
 *      ACTIVE product (internal + external) from the (now deprecated) custom
 *      fields Min_Order_Quantity__c / Order_Increment__c / Max_Order_Quantity__c.
 *      These fields are the ONE-TIME migration source; the standard rule becomes
 *      the single source of truth afterwards (ADR-0009 D-Campos).
 *   2. Creates ONE standard PurchaseQuantityRule per distinct combo (functional
 *      deterministic Name, matched by its Minimum/Increment/Maximum values, so a
 *      re-run reuses the existing rule instead of duplicating it). No hardcoded
 *      org IDs.
 *   3. Creates/repairs ONE ProductQuantityRule junction per product, pointing it
 *      at the rule that matches the product's combo. Extra/duplicate junctions
 *      are removed so every product ends with exactly one rule.
 *
 * Defaults: a product with null min/increment maps to min 1 / increment 1; a null
 * max means "no maximum". These match the lvlupQuantitySelector defaults, so a
 * product without explicit rule fields (e.g. future Platzi products once the
 * publisher stops writing the fields) gets a safe unrestricted rule.
 *
 * Run: sf apex run --file scripts/apex/seed-purchase-quantity-rules.apex --target-org commerce-b2b-dev
 * No search reindex is required (quantity rules feed the product data provider,
 * not the search index).
 */

// ---- Small value object for a normalized combo -------------------------------
class Combo {
  Integer minimum; // never null (defaults to 1)
  Integer increment; // never null (defaults to 1)
  Integer maximum; // null = no maximum

  Combo(Decimal mn, Decimal inc, Decimal mx) {
    this.minimum = (mn == null) ? 1 : mn.intValue();
    this.increment = (inc == null) ? 1 : inc.intValue();
    this.maximum = (mx == null) ? null : mx.intValue();
  }

  String key() {
    return minimum +
      '/' +
      increment +
      '/' +
      (maximum == null ? 'none' : String.valueOf(maximum));
  }

  String ruleName() {
    return 'MOQ ' +
      minimum +
      ' / Inc ' +
      increment +
      ' / Max ' +
      (maximum == null ? '∞' : String.valueOf(maximum));
  }
}

// ---- 1) Read every active product's current combo -----------------------------
Map<Id, Combo> comboByProduct = new Map<Id, Combo>();
Map<String, Combo> comboByKey = new Map<String, Combo>();
for (Product2 p : [
  SELECT
    Id,
    StockKeepingUnit,
    Min_Order_Quantity__c,
    Order_Increment__c,
    Max_Order_Quantity__c
  FROM Product2
  WHERE IsActive = TRUE
]) {
  Combo c = new Combo(
    p.Min_Order_Quantity__c,
    p.Order_Increment__c,
    p.Max_Order_Quantity__c
  );
  comboByProduct.put(p.Id, c);
  comboByKey.put(c.key(), c);
}
System.debug(
  'Active products: ' +
    comboByProduct.size() +
    ' | distinct combos: ' +
    comboByKey.size()
);

// ---- 2) Ensure one PurchaseQuantityRule per distinct combo --------------------
// Match existing rules by their (Minimum, Increment, Maximum) so re-runs reuse them.
Map<String, Id> ruleIdByKey = new Map<String, Id>();
for (PurchaseQuantityRule r : [
  SELECT Id, Minimum, Increment, Maximum
  FROM PurchaseQuantityRule
]) {
  Combo c = new Combo(r.Minimum, r.Increment, r.Maximum);
  if (comboByKey.containsKey(c.key()) && !ruleIdByKey.containsKey(c.key())) {
    ruleIdByKey.put(c.key(), r.Id);
  }
}

List<PurchaseQuantityRule> newRules = new List<PurchaseQuantityRule>();
for (String key : comboByKey.keySet()) {
  if (!ruleIdByKey.containsKey(key)) {
    Combo c = comboByKey.get(key);
    newRules.add(
      new PurchaseQuantityRule(
        Name = c.ruleName(),
        Minimum = c.minimum,
        Increment = c.increment,
        Maximum = c.maximum
      )
    );
  }
}
if (!newRules.isEmpty()) {
  insert newRules;
  for (PurchaseQuantityRule r : newRules) {
    ruleIdByKey.put(new Combo(r.Minimum, r.Increment, r.Maximum).key(), r.Id);
  }
}
System.debug(
  'Rules created this run: ' +
    newRules.size() +
    ' | total rules available: ' +
    ruleIdByKey.size()
);

// ---- 3) One ProductQuantityRule junction per product --------------------------
// Index existing junctions by product; keep the first, mark the rest for deletion.
Map<Id, ProductQuantityRule> junctionByProduct = new Map<Id, ProductQuantityRule>();
List<ProductQuantityRule> duplicates = new List<ProductQuantityRule>();
for (ProductQuantityRule j : [
  SELECT Id, ProductId, PurchaseQuantityRuleId
  FROM ProductQuantityRule
  WHERE ProductId IN :comboByProduct.keySet()
]) {
  if (junctionByProduct.containsKey(j.ProductId)) {
    duplicates.add(j);
  } else {
    junctionByProduct.put(j.ProductId, j);
  }
}

List<ProductQuantityRule> toInsert = new List<ProductQuantityRule>();
List<ProductQuantityRule> toUpdate = new List<ProductQuantityRule>();
Integer alreadyOk = 0;
for (Id productId : comboByProduct.keySet()) {
  Id targetRuleId = ruleIdByKey.get(comboByProduct.get(productId).key());

  ProductQuantityRule existing = junctionByProduct.get(productId);
  if (existing == null) {
    // Name is an auto-number field on ProductQuantityRule (not writeable).
    toInsert.add(
      new ProductQuantityRule(
        ProductId = productId,
        PurchaseQuantityRuleId = targetRuleId
      )
    );
  } else if (existing.PurchaseQuantityRuleId != targetRuleId) {
    existing.PurchaseQuantityRuleId = targetRuleId;
    toUpdate.add(existing);
  } else {
    alreadyOk++;
  }
}

if (!duplicates.isEmpty()) {
  delete duplicates;
}
if (!toInsert.isEmpty()) {
  insert toInsert;
}
if (!toUpdate.isEmpty()) {
  update toUpdate;
}

// ---- 4) Report -----------------------------------------------------------------
System.debug(
  'Junctions inserted: ' +
    toInsert.size() +
    ' | re-pointed: ' +
    toUpdate.size() +
    ' | already correct: ' +
    alreadyOk +
    ' | duplicates removed: ' +
    duplicates.size()
);

for (PurchaseQuantityRule r : [
  SELECT
    Name,
    Minimum,
    Increment,
    Maximum,
    (SELECT Id FROM ProductQuantityRules)
  FROM PurchaseQuantityRule
  ORDER BY Minimum, Maximum
]) {
  System.debug(
    'RULE ' + r.Name + ' -> products: ' + r.ProductQuantityRules.size()
  );
}
