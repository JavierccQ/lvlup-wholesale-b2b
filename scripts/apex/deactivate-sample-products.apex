/*
 * One-off cleanup: deactivate the generic Salesforce sample products that shipped with
 * the org (GenWatt generators "GC*", Installation "IN7*", SLA "SL9*" = 17 products).
 *
 * Deactivation (IsActive = false) rather than delete: reversible and avoids
 * reference/cascade errors. Deactivated products do not appear in the storefront/search.
 *
 * Intentionally keeps "Shipping Charge Product" (commerce checkout shipping charge) and
 * the LVL-* catalog untouched.
 *
 * Run: sf apex run --file scripts/apex/deactivate-sample-products.apex --target-org commerce-b2b-dev
 */
List<Product2> toDeactivate = new List<Product2>();
for (Product2 p : [
    SELECT Id, Name, ProductCode
    FROM Product2
    WHERE IsActive = true
      AND (ProductCode LIKE 'GC%' OR ProductCode LIKE 'IN7%' OR ProductCode LIKE 'SL9%')
]) {
    p.IsActive = false;
    toDeactivate.add(p);
    System.debug('Deactivating: ' + p.ProductCode + ' | ' + p.Name);
}
if (!toDeactivate.isEmpty()) { update toDeactivate; }
System.debug('Deactivated ' + toDeactivate.size() + ' sample products.');
