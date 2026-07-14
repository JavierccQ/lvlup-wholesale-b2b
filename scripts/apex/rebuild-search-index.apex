/**
 * Triggers a rebuild of the B2B Commerce search index for the LevelUp
 * Wholesale store. Needed after creating products, entitlements or category
 * assignments so buyers see them on search/category pages (REGLA-003).
 *
 * Usage: sf apex run --file scripts/apex/rebuild-search-index.apex --target-org commerce-b2b-dev
 */
Id webstoreId = [SELECT Id FROM WebStore WHERE Name = 'LevelUp Wholesale' LIMIT 1].Id;
ConnectApi.CommerceSearchIndex result = ConnectApi.CommerceSearchSettings.createCommerceSearchIndex(webstoreId);
System.debug('Index rebuild requested: ' + result);
