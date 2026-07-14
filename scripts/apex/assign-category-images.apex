/**
 * Assigns the category CMS images (ManagedContent.Name = 'CAT-<SLUG>') to their
 * ProductCategory as Banner Image + Tile Image (ProductCategoryMedia records),
 * replicating what the Commerce UI creates when assigning media manually.
 *
 * Idempotent: skips any category/media-group pair that already has media
 * assigned (e.g. 'Consolas de gaming', assigned manually via UI).
 *
 * Run AFTER importing scripts/cms/out/category-image-content.zip into the CMS.
 * Usage: sf apex run --file scripts/apex/assign-category-images.apex --target-org commerce-b2b-dev
 */
Map<String, String> categoryNameByContentName = new Map<String, String>{
    'CAT-CONSOLAS-GAMING' => 'Consolas de gaming',
    'CAT-VIDEOJUEGOS' => 'Videojuegos',
    'CAT-PORTATILES' => 'Portátiles',
    'CAT-MONITORES' => 'Monitores',
    'CAT-PERIFERICOS' => 'Periféricos',
    'CAT-NETWORKING' => 'Networking',
    'CAT-ACCESORIOS' => 'Accesorios',
    'CAT-BUNDLES-ENTERPRISE' => 'Bundles enterprise',
    'CAT-SMARTPHONES' => 'SmartPhones',
    'CAT-PRODUCTOS-PLATZI' => 'Productos de Platzi'
};

Map<String, Id> contentIdByName = new Map<String, Id>();
for (ManagedContent content : [
    SELECT Id, Name FROM ManagedContent WHERE Name IN :categoryNameByContentName.keySet()
]) {
    contentIdByName.put(content.Name, content.Id);
}

Map<String, Id> categoryIdByName = new Map<String, Id>();
for (ProductCategory category : [
    SELECT Id, Name FROM ProductCategory WHERE Name IN :categoryNameByContentName.values()
]) {
    categoryIdByName.put(category.Name, category.Id);
}

List<ElectronicMediaGroup> mediaGroups = [
    SELECT Id, DeveloperName FROM ElectronicMediaGroup
    WHERE DeveloperName IN ('bannerImage', 'tileImage')
];

Set<String> existingPairs = new Set<String>();
for (ProductCategoryMedia media : [
    SELECT ProductCategoryId, ElectronicMediaGroupId FROM ProductCategoryMedia
    WHERE ProductCategoryId IN :categoryIdByName.values()
]) {
    existingPairs.add(media.ProductCategoryId + '-' + media.ElectronicMediaGroupId);
}

List<ProductCategoryMedia> toInsert = new List<ProductCategoryMedia>();
List<String> notResolved = new List<String>();
List<String> skipped = new List<String>();
for (String contentName : categoryNameByContentName.keySet()) {
    String categoryName = categoryNameByContentName.get(contentName);
    Id contentId = contentIdByName.get(contentName);
    Id categoryId = categoryIdByName.get(categoryName);
    if (contentId == null || categoryId == null) {
        notResolved.add(contentName + ' (contentId=' + contentId + ', categoryId=' + categoryId + ')');
        continue;
    }
    for (ElectronicMediaGroup mediaGroup : mediaGroups) {
        String pair = categoryId + '-' + mediaGroup.Id;
        if (existingPairs.contains(pair)) {
            skipped.add(categoryName + ' / ' + mediaGroup.DeveloperName);
            continue;
        }
        toInsert.add(new ProductCategoryMedia(
            ProductCategoryId = categoryId,
            ElectronicMediaId = contentId,
            ElectronicMediaGroupId = mediaGroup.Id,
            SortOrder = 0
        ));
    }
}

insert toInsert;

System.debug('=== assign-category-images summary ===');
System.debug('Inserted ProductCategoryMedia: ' + toInsert.size());
System.debug('Skipped (already assigned): ' + skipped);
System.debug('Not resolved (missing CMS content or category): ' + notResolved);
