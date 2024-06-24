/**
 * Trigger Handler class for GlobalClientRevenue SObject
 *
 * @author Unknown
 * @date Unknown
 */
public class TRH_GlobalClientRevenue extends ABS_TriggerHandlerBase {
	private List<Global_Client_Revenue__c> records {
		get { return (List<Global_Client_Revenue__c>)Trigger.new; }
	}

	private List<Global_Client_Revenue__c> oldRecords {
		get { return (List<Global_Client_Revenue__c>)Trigger.old; }
	}

	private Map<Id, Global_Client_Revenue__c> id2OldRecords{
		get{ return (Map<Id, Global_Client_Revenue__c>) Trigger.oldMap; }
	}

	public override void handleBeforeInsert(){
		DMN_GlobalClientRevenue.assignClientFromCifNumber(records);
	}

	public override void handleBeforeUpdate(){
		DMN_GlobalClientRevenue.assignClientFromCifNumber(records);
	}

}