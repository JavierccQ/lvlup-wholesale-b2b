/**
 * ============================================================================
 *  LvlupPlatziPipelineQueueable  (ejecución asíncrona del pipeline)
 * ============================================================================
 *  Ejecuta el pipeline completo de Platzi en contexto asíncrono. Implementa
 *  `Database.AllowsCallouts` porque el primer paso (import) hace un CALLOUT HTTP.
 *
 *  Se usa un Queueable (en vez de llamar al pipeline directamente desde el
 *  Scheduler) porque es el patrón recomendado para combinar trabajo programado
 *  con callouts y respetar los límites de gobernador del contexto asíncrono.
 * ============================================================================
 */
public with sharing class LvlupPlatziPipelineQueueable implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        LvlupExternalProductPipeline.runFullPipeline();
    }
}
