// Casa las imágenes ya importadas en CMS con sus Product2 (crea ProductMedia).
// Ejecutar DESPUÉS de importar el ZIP al CMS. Es idempotente.
LvlupExternalProductMediaPublisher.MediaResult r =
    LvlupExternalProductMediaPublisher.linkProductImages();
System.debug('Productos externos: ' + r.totalProducts);
System.debug('Imagenes casadas: ' + r.imagesMatched);
System.debug('ProductMedia creados: ' + r.mediaLinksCreated);
System.debug('Ya enlazados: ' + r.alreadyLinked);
System.debug('Errores: ' + r.errorCount);
