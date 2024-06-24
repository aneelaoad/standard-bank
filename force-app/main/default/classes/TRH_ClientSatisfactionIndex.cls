public with sharing class TRH_ClientSatisfactionIndex extends ABS_TriggerHandlerBase {
	
	private Client_Satisfaction_Index__c[] records {
        get { return (Client_Satisfaction_Index__c[])Trigger.new; }
    } 

    private Client_Satisfaction_Index__c[] oldRecords {
        get { return (Client_Satisfaction_Index__c[])Trigger.old; }
    }

    private Map<Id, Client_Satisfaction_Index__c> id2OldRecords{
                                          	get{
                                               	if(Trigger.old == null){
                                                   	return null;
                                               	}
                                               	return new Map<Id, Client_Satisfaction_Index__c>((Client_Satisfaction_Index__c[])Trigger.old);
                                          	}
                                       	}

	public override void handleBeforeInsert() {
		CSITriggerHelper.validateCsiCountries(records);
	}

  	public override void handleAfterInsert(){ 
  		SHR_ClientSatisfactionIndex.manageSharing(records, id2OldRecords);
		CSITriggerHelper.updateCIBCSIRatingOnInsertingOrUpdating(records);

  	}

  	public override void handleAfterUpdate(){
  		SHR_ClientSatisfactionIndex.manageSharing(records, id2OldRecords);
		CSITriggerHelper.updateCIBCSIRatingOnInsertingOrUpdating(records, id2OldRecords);
  	}

	public override void handleBeforeDelete() {
	}
  	public override void handleAfterDelete(){
  		SHR_ClientSatisfactionIndex.manageSharing(records, id2OldRecords);
        CSITriggerHelper.updateCIBCSIRatingOnDeletion(oldRecords);
    }
}