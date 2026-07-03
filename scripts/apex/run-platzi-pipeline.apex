LvlupExternalProductPipeline.PipelineResult r =
    LvlupExternalProductPipeline.runFullPipeline();

System.debug('IMPORT  -> procesados=' + r.importResult.totalProcessed +
             ' creados=' + r.importResult.createdCount +
             ' actualizados=' + r.importResult.updatedCount);
System.debug('PUBLISH -> procesados=' + r.publishResult.totalProcessed +
             ' creados=' + r.publishResult.createdCount +
             ' actualizados=' + r.publishResult.updatedCount +
             ' errores=' + r.publishResult.errorCount);
System.debug('CATEGORY-> total=' + r.categoryResult.totalProducts +
             ' asignados=' + r.categoryResult.assignmentsCreated +
             ' yaAsignados=' + r.categoryResult.alreadyAssigned);
System.debug('PRICE   -> total=' + r.priceResult.totalProducts +
             ' std=' + r.priceResult.standardEntriesCreated +
             ' store=' + r.priceResult.storeEntriesCreated +
             ' actualizados=' + r.priceResult.pricesUpdated +
             ' errores=' + r.priceResult.errorCount);
