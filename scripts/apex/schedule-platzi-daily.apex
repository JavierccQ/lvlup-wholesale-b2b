// Programa el pipeline de Platzi para que corra todos los días a las 03:00
// (hora de la org). El cron es: segundos minutos horas día mes díaSemana.
String cron = '0 0 3 * * ?';
String jobId = System.schedule(
    'LvlUp Platzi Daily Import',
    cron,
    new LvlupPlatziDailyScheduler()
);
System.debug('Scheduled CronTrigger Id: ' + jobId);
