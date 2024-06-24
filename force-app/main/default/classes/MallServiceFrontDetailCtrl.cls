/**
 * @description MallServiceFrontDetailCtrl
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallServiceFrontDetailCtrl {
    /**
     * 
     * @description : getApprovalHistoryByServiceIds 
     *  @param serviceIds List<String>
     *  @return : List<ProcessInstanceStep>
     */
    @AuraEnabled
    public static List<ProcessInstanceStep> getApprovalHistoryByServiceIds(List<String> serviceIds) {
        try {
            Set<Id> serviceIdsSet = new Set<Id>();
            serviceIdsSet.addAll((List<Id>)serviceIds);
            List<Offering__c> offerings = SEL_Offerings.newInstance().selectByParentOffering(serviceIdsSet);
            List<String> childServiceIds = new List<String>();
            for(Offering__c offering : offerings) {
                childServiceIds.add(offering.Id);
            }
            serviceIds.addAll(childServiceIds);
    
            serviceIdsSet = new Set<Id>();
            serviceIdsSet.addAll((List<Id>)serviceIds);
            List<ProcessInstanceStep> processInstanceSteps = SEL_ProcessInstanceSteps.newInstance().selectByTargetObjectId(serviceIdsSet);
            return processInstanceSteps;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallServiceFrontDetailCtrl.getApprovalHistoryByServiceIds', e);
        }
    }
}