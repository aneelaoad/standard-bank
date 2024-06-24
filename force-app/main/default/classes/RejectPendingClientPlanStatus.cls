/**
 * Created by: Dyllan Higgins - March 2021
 * Date modified: 29/03/2021
 */

public with sharing class RejectPendingClientPlanStatus {
    @InvocableMethod(Label='Reject Pending Client Plan')
    public static void getRejectClientPlanStatus(List<EmCDateReq> emSendReqs) {
        Set<Id> clientPlanIds = new Set<Id>();
        for (EmCDateReq request : emSendReqs ) {
            clientPlanIds.add(request.clientPlanId);
        }
        SRV_Approval srvApprovalClass = new SRV_Approval();
        List<ProcessInstance> pi = [
                SELECT Id
                FROM ProcessInstance
                WHERE Status = :SRV_Approval.PENDING
                AND TargetObjectId IN :clientPlanIds
                AND ProcessDefinition.DeveloperName = :DMN_ClientPlan.APPROVAL_PROCESS_NAME
        ];
        srvApprovalClass.apply(pi);
        srvApprovalClass.reject();
    }

    public class EmCDateReq {
        @InvocableVariable(Label='Client Plan Id' Required=true)
        public Id clientPlanId;
    }
}