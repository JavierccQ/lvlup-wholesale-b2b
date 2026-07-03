LvlupExternalProductPricePublisher.PriceResult r =
    LvlupExternalProductPricePublisher.publishPrices();
System.debug('Productos elegibles: ' + r.totalProducts);
System.debug('Entradas estándar creadas: ' + r.standardEntriesCreated);
System.debug('Entradas de venta creadas: ' + r.storeEntriesCreated);
System.debug('Errores: ' + r.errorCount);
