/**
 * ============================================================================
 *  LvlupPlatziDailyScheduler  (disparador programado diario)
 * ============================================================================
 *  Schedulable que, en cada disparo, encola el Queueable del pipeline. Se separa
 *  del Queueable para que el contexto programado solo haga una cosa: encolar el
 *  trabajo con callouts. Se programa una vez con System.schedule (cron diario).
 *
 *  Ejemplo de programación (Anonymous Apex):
 *    System.schedule('LvlUp Platzi Daily Import',
 *                    '0 0 3 * * ?',
 *                    new LvlupPlatziDailyScheduler());
 * ============================================================================
 */
public with sharing class LvlupPlatziDailyScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        System.enqueueJob(new LvlupPlatziPipelineQueueable());
    }
}
