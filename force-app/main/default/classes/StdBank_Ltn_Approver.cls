/**************************************************************************************
Apex Class Name     : StdBank_Ltn_Approver
Version             : 1.0
Created Date        : 20 JUL 2016
Function            : Backend controller for Lightning Approver Component
Modification Log    :
* Developer                     Date                    Description
* ----------------------------------------------------------------------------
* Daniel Horky                  20/07/2016              Original Version
  Manoj Gupta                   18/05/2017              Reassign functionality (reassign method)
*************************************************************************************/

public class StdBank_Ltn_Approver {

    @AuraEnabled
    public static List<ProcessInstanceWorkitem> getData() {
        return [SELECT ActorId, Actor.Name, Actor.Email, CreatedDate, ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.Type FROM ProcessInstanceWorkitem  WHERE ActorId = :UserInfo.getUserId() AND ProcessInstance.Status = 'Pending' AND IsDeleted = false];
    }

    @AuraEnabled
    public static List<User> getUsers() {
        return [SELECT Id, Name FROM User WHERE Id != :UserInfo.getUserId()];
    }

    @AuraEnabled
    public static String approve(Id itemToApprove, String comment) {
        Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();

        request.setAction('Approve');
        request.setComments(comment);
        request.setWorkitemId(itemToApprove);

        Approval.ProcessResult result = Approval.process(request);

        return new StdBank_Ltn_BackendResult(result.isSuccess(), ((result.isSuccess()) ? 'Item was successfully approved!' : JSON.serialize(result.getErrors()))).toJSON();
    }

    @AuraEnabled
    public static String reject(Id itemToReject, String comment) {
        Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();

        request.setAction('Reject');
        request.setComments(comment);
        request.setWorkitemId(itemToReject);

        Approval.ProcessResult result = Approval.process(request);

        return new StdBank_Ltn_BackendResult(result.isSuccess(), ((result.isSuccess()) ? 'Item was successfully rejected!' : JSON.serialize(result.getErrors()))).toJSON();
    }

    @AuraEnabled
    public static void reassign(Id itemToReassign, Id userToReassign) {
        
       List<ProcessInstanceWorkItem> piwi_to_update = new List<ProcessInstanceWorkItem>();
        List<ProcessInstanceWorkItem> piwi = [SELECT Id,ActorId,OriginalActorId 
                            FROM ProcessInstanceWorkitem 
                               WHERE Id =: itemToReassign limit 1];
         try {                    
          if (piwi.size()>0)
          {
          piwi[0].ActorId = userToReassign;
          piwi_to_update.add(piwi[0]);
          }  
          update piwi_to_update;  
       }
       catch(DMLException e) {
            System.debug('Approval record reassign exception ' + e.getMessage());
        }
                        
       // return new StdBank_Ltn_BackendResult(result.isSuccess(), ((result.isSuccess()) ? 'Item was successfully rejected!' : JSON.serialize(result.getErrors()))).toJSON();
    }
}