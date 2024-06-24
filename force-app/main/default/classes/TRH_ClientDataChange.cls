/**
 * Created by akepczynski on 09.04.2018.
 */

public without sharing class TRH_ClientDataChange extends ABS_TriggerHandlerBase{
    
    private Client_Data_Change__c[] records {
        get { return (Client_Data_Change__c[])Trigger.new; }
    }
    
    private Map<Id, Client_Data_Change__c> id2OldRecords{
        get{
            if(Trigger.old == null){
                return null;
            }
            return new Map<Id, Client_Data_Change__c>((Client_Data_Change__c[])Trigger.old);
        }
    }
    
    public override void handleBeforeInsert(){
        DMN_ClientDataChange.prepopulate(records);
        DMN_ClientDataChange.populateName(records, id2OldRecords);
        DMN_ClientDataChange.setRecordType(records, id2OldRecords);
    }
    
    public override void handleBeforeUpdate() {
        DMN_ClientDataChange.setRecordType(records, id2OldRecords);
		DMN_ClientDataChange.populateName(records, id2OldRecords);
    }
    
    public override void handleAfterUpdate(){
        DMN_ClientDataChange.ccChangeApprove(records, id2OldRecords);
        DMN_Case.createCaseForFailedDataChange(records, id2OldRecords);
        DMN_ClientDataChange.sendRejectionEmails(records, id2OldRecords);
    }
    
}