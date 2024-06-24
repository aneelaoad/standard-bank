public class TRH_CreditLine extends ABS_TriggerHandlerBase {

	private Credit_Line__c[] records {
        get { return (Credit_Line__c[])Trigger.new; }
    }

    private Map<Id, Credit_Line__c> oldMap {
        get { return (Map<Id, Credit_Line__c>)Trigger.oldMap; }
    }
	
	public override void handleAfterInsert() { 
		SHR_CreditLine.manageSharing(records, oldMap);
	}

	public override void handleAfterUpdate() { 
		SHR_CreditLine.manageSharing(records, oldMap);
	}

	public override void handleAfterDelete() { 
		SHR_CreditLine.manageSharing(records, oldMap); 
	}
}