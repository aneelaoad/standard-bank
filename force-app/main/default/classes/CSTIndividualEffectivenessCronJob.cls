/**
 * CST - Report for Individual View - Client Engagement - runs CSTIndividualEffectivenessBatch
 * <br/>EN-0777
 *
 * @author psvestka
 * @date 24.7.2015
 */
public without sharing class CSTIndividualEffectivenessCronJob implements Schedulable {

    /**
     * Executes CSTIndividualEffectivenessBatch batch class.
     * @param sc Default param
     */
    public void execute(SchedulableContext sc) {
        CSTIndividualEffectivenessBatch batch = new CSTIndividualEffectivenessBatch();

        Database.executeBatch(batch, 5);
    }
}