/**
* @author Michal Lipinski
* @description Batchable class that marks Clients for FAIS reminder creation
*/ 
global class BCH_FAISRemindMarker implements Database.Batchable<SObject>, Schedulable  {
	private static String HAS_REMINDER_NEED		= 'HAS_REMINDER_NEED';
	private static String HAS_REMINDER_NO_NEED		= 'HAS_REMINDER_NO_NEED';
	private static String NO_NEED			= 'NO_NEED';
	private static String NEED_REMINDER		= 'NEED_REMINDER';

	global BCH_FAISRemindMarker() {
		
	}
	
	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set of Clients that meets specific criteria
	 */ 
	global Database.QueryLocator start(Database.BatchableContext context) {
		Datetime yearAgoDt = System.now().addDays(-365 + 8);
		Date yearAgo = Date.newInstance(yearAgoDt.year(),yearAgoDt.month(),yearAgoDt.day());
		return Database.getQueryLocator('SELECT Id, Name, FAIS_reminder__c FROM Account WHERE ' +
		'Owner.IsActive = true AND ( (FAIS_Review_Date__c != null AND FAIS_Review_Date__c < :yearAgo AND (FAIS_reminder__c =: HAS_REMINDER_NO_NEED OR FAIS_reminder__c = :NO_NEED OR FAIS_reminder__c = null)' +
                ' AND (recordtype.DeveloperName =  \''+ DMN_Account.RT_ULTIMATE_PARENT + '\' or recordtype.DeveloperName = \''+ DMN_Account.RT_IMMEDIATE_PARENT +'\'))' +
		' OR (FAIS_Review_Date__c = null AND (billingcountry like \'%south%africa%\' OR billingcountry like \'SA\' ) AND (recordtype.DeveloperName = \''+ DMN_Account.RT_ULTIMATE_PARENT + '\' or recordtype.DeveloperName = \''+ DMN_Account.RT_IMMEDIATE_PARENT +'\') AND CIF_Client_Status__c = \'Open\' AND Owner.Alias != \'Archived\') )');
	}


	/**
	* @description method that fires Batch processing
	* @param ctx SchedulableContext
	*/ 
	global void execute(System.SchedulableContext ctx){
		BCH_FAISRemindMarker batchJob = new BCH_FAISRemindMarker();
		Database.executeBatch(batchJob);
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<Account> scope) {
		for(Account client : scope){
			client.FAIS_reminder__c = changeReminderStatus(client);
		}
		update scope;
	}
	
	private String changeReminderStatus(Account client){
		return client.FAIS_reminder__c == NO_NEED ? NEED_REMINDER : client.FAIS_reminder__c == HAS_REMINDER_NO_NEED ? HAS_REMINDER_NEED : NEED_REMINDER;
	}

	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
		
	}
}