LvlupExternalProductCategoryPublisher.CategoryResult result =
    LvlupExternalProductCategoryPublisher.assignProductsToCategory();
System.debug('Total productos elegibles: ' + result.totalProducts);
System.debug('Asignaciones creadas: ' + result.assignmentsCreated);
System.debug('Ya asignados previamente: ' + result.alreadyAssigned);
System.debug('Errores: ' + result.errorCount);
