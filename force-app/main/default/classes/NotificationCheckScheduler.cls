/*-------------------------------------------------------------------------------------------------------------------------
  This class was created for US-3699 
  As an Angola agent handling email-to-case, I want to be notified when a client sends an email related to an open case in order to assist with the query.cases at batch interval times.

  This class will be scheduled to run every 2 mins.  Function of this class is to query for Angolan Cases that are open 
  and flagged with Notification__c field value of 'Unread Email'.  All emails related to these cases will be interrogated and if no related
  emails are found with Status of '0'/New then the Flag field Notification__c will be cleared
	

//System.scheduleBatch Method for scheduling Batch Jobs from dev console
	 		
NotificationCheckScheduler p = new NotificationCheckScheduler();
			
String sch0 = '0 00 * * * ?';String sch22 = '0 22 * * * ?';String sch44 = '0 44 * * * ?';  
String sch2 = '0 02 * * * ?';String sch24 = '0 24 * * * ?';String sch46 = '0 46 * * * ?';
String sch4 = '0 04 * * * ?';String sch26 = '0 26 * * * ?';String sch48 = '0 48 * * * ?';
String sch6 = '0 06 * * * ?';String sch28 = '0 28 * * * ?';String sch50 = '0 50 * * * ?';
String sch8 = '0 08 * * * ?';String sch30 = '0 30 * * * ?';String sch52 = '0 52 * * * ?';
String sch10 = '0 10 * * * ?';String sch32 = '0 32 * * * ?';String sch54 = '0 54 * * * ?';
String sch12 = '0 12 * * * ?';String sch34 = '0 34 * * * ?';String sch56 = '0 56 * * * ?';
String sch14 = '0 14 * * * ?';String sch36 = '0 36 * * * ?';String sch58 = '0 58 * * * ?';
String sch16 = '0 16 * * * ?';String sch38 = '0 38 * * * ?';
String sch18 = '0 18 * * * ?';String sch40 = '0 40 * * * ?';
String sch20 = '0 20 * * * ?';String sch42 = '0 42 * * * ?';

system.schedule('AngolaNotificationCheck Job 0min', sch0, p);system.schedule('AngolaNotificationCheck Job 22min', sch22, p);system.schedule('AngolaNotificationCheck Job 44min', sch44, p);
system.schedule('AngolaNotificationCheck Job 2min', sch2, p);system.schedule('AngolaNotificationCheck Job 24min', sch24, p);system.schedule('AngolaNotificationCheck Job 46min', sch46, p);
system.schedule('AngolaNotificationCheck Job 4min', sch4, p);system.schedule('AngolaNotificationCheck Job 26min', sch26, p);system.schedule('AngolaNotificationCheck Job 48min', sch48, p);
system.schedule('AngolaNotificationCheck Job 6min', sch6, p);system.schedule('AngolaNotificationCheck Job 28min', sch28, p);system.schedule('AngolaNotificationCheck Job 50min', sch50, p);
system.schedule('AngolaNotificationCheck Job 8min', sch8, p);system.schedule('AngolaNotificationCheck Job 30min', sch30, p);system.schedule('AngolaNotificationCheck Job 52min', sch52, p);
system.schedule('AngolaNotificationCheck Job 10min', sch10, p);system.schedule('AngolaNotificationCheck Job 32min', sch32, p);system.schedule('AngolaNotificationCheck Job 54min', sch54, p);
system.schedule('AngolaNotificationCheck Job 12min', sch12, p);system.schedule('AngolaNotificationCheck Job 34min', sch34, p);system.schedule('AngolaNotificationCheck Job 56min', sch56, p);
system.schedule('AngolaNotificationCheck Job 14min', sch14, p);system.schedule('AngolaNotificationCheck Job 36min', sch36, p);system.schedule('AngolaNotificationCheck Job 58min', sch58, p);
system.schedule('AngolaNotificationCheck Job 16min', sch16, p);system.schedule('AngolaNotificationCheck Job 38min', sch38, p);
system.schedule('AngolaNotificationCheck Job 18min', sch18, p);system.schedule('AngolaNotificationCheck Job 40min', sch40, p);
system.schedule('AngolaNotificationCheck Job 20min', sch20, p);system.schedule('AngolaNotificationCheck Job 42min', sch42, p);

//Delete Scheduled jobs from dev console:
for(CronTrigger delCron: [SELECT Id FROM CronTrigger where CronJobDetail.Name like 'Angola%' ])  {
    System.abortJob(delCron.Id);
}
 	      
* ------------------------------------------------------------------------------------------------------------------------*/
global class NotificationCheckScheduler implements System.Schedulable {
 
    global void execute(SchedulableContext sc) {
        
        DoFlagCheck();
    }
    
    public static void DoFlagCheck(){
        
        /* 
         * SFP-8961 : Scheduled job 'AngolaNotificationCheck Job 30min' is throwing limit query exception.Too many query rows: 50001. 
         * Decomissioining the scheduler class since it's no longer used for bussiness process
         * Modified By : Aseem.Doddamani@standardbank.co.za
         * Modification Date : 06/12/2021
          
         // Modification Starts
        
        //Method Variables
        List<Case> allCases = new List<Case>();
        Set<Id> allCasesIds = new Set<Id>();
        Set<Id> allCasesToBeUpdatedIds = new Set<Id>();
        List<Case> allCasesToBeUpdated = new List<Case>();
        List<EmailMessage> allEmails = new List<EmailMessage>();
        Id RecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CCC Angola').getRecordTypeId();
        
        //Main
        //Fetch cases from CasesSelector class
		SEL_Cases selector = new SEL_Cases();
        allCases = selector.selectByNotification(false, 'Unread Email', RecTypeId);  
		allCasesIds = (new Map<Id,SObject>(allCases)).keySet();
            
            if (allCases.size()> 0){                  
                //Fetch cases from SEL_EmailMessages class
                SEL_EmailMessages emailSelector = new SEL_EmailMessages();
                allEmails = emailSelector.selectByParentId(allCasesIds);
                
                if (allEmails.size() > 0){
          
                    for (EmailMessage e : allEmails){
                        if (e.status != '0'){
                            allCasesToBeUpdatedIds.add(e.ParentId); system.debug('Ids Added:' + ' ' + e.ParentId);                           
                        } else if (e.status == '0'){
                            allCasesToBeUpdatedIds.remove(e.ParentId); system.debug('Ids Removed:' + ' ' + e.ParentId);
                        }                                               
                    }
                    
                    
                } 
			} 


        //Finally update cases and remove flag
        if(allCasesToBeUpdatedIds.size() > 0){
            allCasesToBeUpdated = [Select Id, Status, Notification__c from Case where isClosed = false and Recordtype.Name = 'CCC Angola' and id in :allCasesToBeUpdatedIds];
            
            if(allCasesToBeUpdated.size() > 0){
                for (case caseToBeUpdated : allCasesToBeUpdated){
                    caseToBeUpdated.Notification__c = '';
                }
                
                Database.SaveResult[] srList = Database.update(allCasesToBeUpdated, false);
            }
        }
		//Modification Ends		
		*/

        
    }
}