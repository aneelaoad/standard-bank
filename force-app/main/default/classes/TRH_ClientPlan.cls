public with sharing class TRH_ClientPlan  extends ABS_TriggerHandlerBase  {

	private Client_Plan__c[] records {
        get { return (Client_Plan__c[])Trigger.new; }
    }
    private Map<Id, Client_Plan__c> id2oldRecord {
        get {if(Trigger.old == null){
        		return null;
        	}
        	return new Map<Id, Client_Plan__c>((Client_Plan__c[])Trigger.old);
        }
    }

    public override void handleBeforeUpdate(){
        DMN_ClientPlan.prepareForApproval(records, id2oldRecord);
    }

    public override void handleAfterUpdate() {
        DMN_ClientPlan.runApproval(records, id2oldRecord);
    	DMN_ClientPlan.sendApprovedInfoEmail(records, id2oldRecord);
    }
}