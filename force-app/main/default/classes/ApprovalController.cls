public without sharing class ApprovalController {

    @AuraEnabled
    public static UTL_Approval.ApprovalResults recall(Id recordId, String message){
        
        String queryString = 'SELECT CreatedById FROM ' + recordId.getSobjectType().getDescribe().getName()
                            + ' WHERE Id =: recordId';
        
        Sobject sObj = Database.query(queryString);
        
        if(UserInfo.getUserId() != sObj.get('CreatedById')){
            return new UTL_Approval.ApprovalResults(true, 'Only submitter can recall approval.');
        }
        
        
        ProcessInstanceWorkitem[] piws = [  SELECT Id
                                            FROM ProcessInstanceWorkitem
                                            WHERE ProcessInstance.TargetObjectId =: recordId
                                                AND ProcessInstance.Status =: SRV_Approval.PENDING
                                            LIMIT 1];
        
        if(piws.isEmpty()){
            return new UTL_Approval.ApprovalResults(true, 'There is no Runing approval on record.');
        }
        
        SRV_Approval appr = new SRV_Approval();
    
        for (ProcessInstanceWorkitem piw : piws) {
            appr.apply(piw, message);
        }
        
        return new UTL_Approval.ApprovalResults(appr.recall()[0]);
    }
    
    
    
}