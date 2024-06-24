/**
 * Created by akepczynski on 08.04.2018.
 */

public without sharing class UTL_Approval {
    
    private static Map<String, Id> procDevName2Id{
        get{
            if(procDevName2Id == null){
                collect();
            }
            return procDevName2Id;
        }
        set;
    }
    private static Map<Id, String> id2ProcDevName{
        get{
            if(id2ProcDevName == null){
                collect();
            }
            return id2ProcDevName;
        }
        set;
    }
    private static ProcessDefinition[] procesDefinitions{
        get{
            if(procesDefinitions == null){
                collect();
            }
            return procesDefinitions;
        }
        set;
    }
    
    private static void collect(){
        procDevName2Id = new Map<String, String>();
        id2ProcDevName = new Map<Id, String>();
        procesDefinitions = [SELECT Name, DeveloperName FROM ProcessDefinition];
        
        for(ProcessDefinition pd : procesDefinitions){
            procDevName2Id.put(pd.DeveloperName, pd.Id);
            id2ProcDevName.put(pd.Id, pd.DeveloperName);
        }
    }
    
    public static ApprovalResults runApproval(Id recordId, String approvalName){
        return runApproval(recordId, UserInfo.getUserId(), approvalName, 'Submitt for Approval', true);
    }
    
    public static ApprovalResults runApproval(  Id recordId, Id submitterId,  String approvalName, String submitMessage,
        Boolean skipEntryCriteria ){
        ApprovalResults aRes;
        try {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setComments(submitMessage);
            request.setObjectId(recordId);
            request.setSubmitterId(submitterId);
            request.setProcessDefinitionNameOrId(approvalName);
            request.setSkipEntryCriteria(skipEntryCriteria);
            Approval.ProcessResult result = Approval.process(request);
            aRes = new ApprovalResults(result);
        
        }
        catch (Exception ex){
            aRes = new ApprovalResults(true, ex.getMessage());
        }
        return aRes;
    }
    
    public class ApprovalResults{
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String processId;
        @AuraEnabled public String recordId;
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public Boolean isError;
        
        public ApprovalResults(Boolean isError, String errorMessage){
            this(isError, errorMessage, null);
        }
        
        public ApprovalResults(Boolean isError, String errorMessage, String recordId){
            this.isSuccess = !isError;
            this.isError   = isError;
            this.errorMessage = errorMessage;
            this.recordId = recordId;
        }
        
        public ApprovalResults(Approval.ProcessResult results){
            this.isSuccess = results.isSuccess();
            this.isError   = !results.isSuccess();
            this.errorMessage = results.getErrors() == null ? '' : results.getErrors()[0].getMessage();
            this.recordId = results.getEntityId();
        }
    }

}