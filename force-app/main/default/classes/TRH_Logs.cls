public class TRH_Logs extends ABS_TriggerHandlerBase {
	@TestVisible
    private Log__c[] logs {
		get { return(Log__c[]) Trigger.new; }
	}
}