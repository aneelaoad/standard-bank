public with sharing class TRH_AccountInformation extends ABS_TriggerHandlerBase {
	private Account_Information__c [] records {
        get { return (Account_Information__c [])Trigger.new; }
    } 

    private Account_Information__c [] oldRecords {
        get { return (Account_Information__c [])Trigger.old; }
    }

    private Map<Id, Account_Information__c > id2OldRecords{
                                          	get{
                                               	if(Trigger.old == null){
                                                   	return null;
                                               	}
                                               	return new Map<Id, Account_Information__c >((Account_Information__c [])Trigger.old);
                                          	}
                                       	}

  	public override void handleAfterInsert(){ 
  		SHR_AccountInformation.manageSharing(records, id2OldRecords);
  	}
	public override void handleBeforeInsert(){
		DMN_AccountInformation.insertExternalIdOnPBBRecords(records);
	}
  	public override void handleAfterUpdate(){
  		SHR_AccountInformation.manageSharing(records, id2OldRecords);
  	}

  	public override void handleAfterDelete(){
  		SHR_AccountInformation.manageSharing(records, id2OldRecords);
  	}
}