/*************************************************************************\
    @ Author        :     Stephen Moore
    @ Date          :     8 Nov 2011
    @ Test File     :     Giftlog_Test
    @ Description   :     Untility Class for the Gift Expense Log object        
                          
    @ Last Modified By  : 
    @ Last Modified On  : 
    @ Last Modified Reason  : 
                                 
****************************************************************************/
public with sharing class GiftExpenseLogUtility {

    public static void UpdateApproverDelegatedUsers(List<Gift_Expense_Log__c> newGelItems){ 
        Set<Id> ApproverUserIds = new Set<Id>() ;   
        Map<Id, Id> GiftlogDelegatedApproverMap = new Map<Id, Id>() ;
        
        for (Gift_Expense_Log__c gel : newGelItems){
             System.Debug( '### GEL  GiftlogApproverMap  ' + gel.Approver__c + ' , ' + gel.Id );
             ApproverUserIds.add(gel.Approver__c);       
        }
        for (User approverRecord : [Select Id, DelegatedApproverId from User where DelegatedApproverId != null and Id in :ApproverUserIds]  ){
             System.Debug( '### GEL GiftlogDelegatedApproverMap ' + approverRecord.id + ' , ' + approverRecord.DelegatedApproverId);
             GiftlogDelegatedApproverMap.put(approverRecord.Id,approverRecord.DelegatedApproverId );  
        }
        for (Gift_Expense_Log__c gelUpdate : newGelItems){
             System.Debug( '### GEL Delegated Approver UPDATE ' + gelupdate.Approver__c + ' , ' + GiftlogDelegatedApproverMap.get(gelupdate.Approver__c));
             if (gelUpdate.Approver_s_Delegated_Approver__c != GiftlogDelegatedApproverMap.get(gelUpdate.Approver__c)){
                 gelUpdate.Approver_s_Delegated_Approver__c = GiftlogDelegatedApproverMap.get(gelUpdate.Approver__c);
             }            
        }             
          
    }
      
    public static void UpdateApproverReportingFields(List<Gift_Expense_Log__c> GELList){   
        List<Gift_Expense_Log__c> GELListUpdate = new List<Gift_Expense_Log__c>() ; 
        
        for (Gift_Expense_Log__c gelupdate : GELList){
            if (gelupdate.Status__c == 'Not Submitted' || gelupdate.Status__c == 'Approved' || gelupdate.Status__c == 'Rejected' ){
                GELListUpdate.add(gelupdate); 
            }   
        }
        
        if (GELListUpdate.size() > 0 ){
            ApprovalProcessFunctions af = new ApprovalProcessFunctions(GELListUpdate);
            af.commentsField = 'Approval_Comments__c';
            af.actualApproverIdField = 'Approval_Actual_Approver__c';
            af.approvalDateField = 'Approval_Date__c';
            af.assignedToIdField = 'Approval_Assigned_To__c';
            af.overAllStatusField = 'Approval_Overall_Status__c'; 
            af.submit(True); 
        }
    }
}