/**
 * @author Katarzyna Teska
 * @date August 2021
 * @description After 28 days, if no response has been received from the approvers, the client plan request will receive an automatic system cancellation.
 * SFP-5517
 * */

public without sharing class SCHED_RejectPendingClientPlan implements Schedulable {
    /**
     * @description Client Plan auto-cancellation functionality
     * Fetch all pending Client Plan approval requests which have been submitted 28 days ago and reject them
     * @param sc Type: SchedulableContext
     * */
    public void execute(SchedulableContext sc) {
        Set<Id> clientIds = new Set<Id>();
        List<ProcessInstance> processInstances = [
                SELECT Id, TargetObjectId, ProcessDefinition.DeveloperName, Status, CreatedDate
                FROM ProcessInstance
                WHERE Status = 'Pending'
                AND ProcessDefinition.DeveloperName = :DMN_ClientPlan.APPROVAL_PROCESS_NAME
        ];

        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime currentTime = now.addSeconds(offset/1000);

        for (ProcessInstance p : processInstances) {
            Datetime autoRejectDate = p.CreatedDate.addDays(28);
            Datetime timeWithTZ = autoRejectDate.addSeconds(UserInfo.getTimeZone().getOffset(autoRejectDate) / 1000);

            if (currentTime >= timeWithTZ) {
                clientIds.add(p.TargetObjectId);
            }
        }

        if (!clientIds.isEmpty()) {
            ClientPlan_RejectPendingRequests.getRejectClientPlanStatus(clientIds);
        }
    }
}