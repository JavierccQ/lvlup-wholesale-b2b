/**
 * Reports the current B2B Commerce search index status for the LevelUp Wholesale
 * store. Poll after rebuild-search-index.apex until indexStatus=Completed /
 * indexUsage=Live (a full build takes ~4 min, REGLA-032).
 *
 * Usage: sf apex run --file scripts/apex/check-search-index-status.apex --target-org commerce-b2b-dev
 */
Id webstoreId = [
  SELECT Id
  FROM WebStore
  WHERE Name = 'LevelUp Wholesale'
  LIMIT 1
]
.Id;
ConnectApi.CommerceSearchIndexCollection indexes = ConnectApi.CommerceSearchSettings.getCommerceSearchIndexes(
  webstoreId
);
for (ConnectApi.CommerceSearchIndex idx : indexes.indexes) {
  System.debug(
    'INDEX status=' +
      idx.indexStatus +
      ' usage=' +
      idx.indexUsage +
      ' type=' +
      idx.indexBuildType +
      ' completionDate=' +
      idx.completionDate
  );
}
