// Aborta el job programado para poder recompilar las clases del pipeline.
for (CronTrigger ct : [
    SELECT Id FROM CronTrigger
    WHERE CronJobDetail.Name = 'LvlUp Platzi Daily Import'
]) {
    System.abortJob(ct.Id);
    System.debug('Aborted job: ' + ct.Id);
}
