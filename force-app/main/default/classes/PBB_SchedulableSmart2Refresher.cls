/**
 * Class created to create job to synchronize Smart2 database with Salesforce database
 * Should be started at 1 a.m.
 * <br/> SGPRT-3487
 *
 * @Author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @Date November 2020
 */
public with sharing class PBB_SchedulableSmart2Refresher implements Schedulable, Database.AllowsCallouts{

    private static final SRV_Logger LOGGER = (SRV_Logger) SRV_Logger.newInstance();

    public void execute(SchedulableContext context) {
        try {
            Set<Id> userIds = (new Map<Id, User>(SEL_Users.newInstance().selectWithAeNumber())).keySet();
            List<Set<Id>> userBatches = createBatches(userIds);
            for(Set<Id> userBatch : userBatches) {
                PBB_QUE_FetchConversations updateJob = new PBB_QUE_FetchConversations(userBatch);
                System.enqueueJob(updateJob);
            }
        } catch (Exception e) {
            LOGGER.log(e, PBB_SchedulableSmart2Refresher.class.getName(),DMN_Log.AREA_PBB_GATEWAY);
        }


    }

    private List<Set<Id>> createBatches(Set<Id> userIds) {
        List<Set<Id>> userBatches = new List<Set<Id>>();
        while(userIds.size() > 0) {
            Set<Id> userBatch = new Set<Id>();
            while(userIds.size() > 0 && userBatch.size() < Limits.getLimitCallouts() / 2) {
                for(Id userId : userIds) {
                    userBatch.add(userId);
                    userIds.remove(userId);
                }
            }
            userBatches.add(userBatch);
        }
        return userBatches;
    }
}