/*************************************************************************\
    @ Author        : Revashlin Iyman
    @ Date          : 23rd Sept, 2010
    @ Test File     : BirthdayCronJob_Test.cls
    @ Description   : This batch class sends birthday reminders to the bank contacts
    @ Audit Trial   : Repeating block for each change to the code
    @ Last Modified By  :   Nikhita Reddy
    @ Last Modified On  :   14 Jan 2013
    @ Last Modified Reason  :   Indented the code and added comments. Updated the API Version to 27
****************************************************************************/

global class batchContactTeamBirthdayReminders implements Database.Batchable<sObject> {
    public Boolean runTestMethod = false;
    global String query;
    public Integer Month;
    public Integer Day;
    global Set<Id> ContactOwners;
    global Set<Id> ClientOwners;
    private Date today, birthdayToDate;

    private static String ACTIVITY_SUBJECT_BIRTHDAY_REMINDER = 'Birthday Reminder';
    
    global batchContactTeamBirthdayReminders() {
        /*Date theBigDay = Date.today().addDays(7);
        this.Day = theBigDay.day();
        this.Month = theBigDay.month();*/
        this.today = Date.today();
        this.birthdayToDate = Date.today().addDays(7);

        this.ContactOwners = new Set<Id>();
        this.ClientOwners = new Set<Id>();

        this.query = 'SELECT Id, SA_User__c, SA_Contact__c, SA_Contact__r.Name, SA_Contact__r.Birth_Day_Month__c, SA_Contact__r.Account.Name, SA_User__r.Id'+
                        +' FROM SA_Contact_Team_Member__c'+
                        +' WHERE SA_Contact__r.Inactive__c = false'+
                        +' AND SA_User__r.RecieveBirthdayReminderTasks__c = true'+
                        +' AND SA_Contact__r.Birthday_Date_Format__c <= :birthdayToDate'+
                        +' AND SA_Contact__r.Birthday_Date_Format__c >= :today';
                        
    }
    
    // Start method of the batch class
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (runTestMethod) {
            query = query + ' ORDER BY CreatedDate DESC LIMIT 200';
        }
        return Database.getQueryLocator(query);
    }
    
    // Execute method of the batch class
    global void execute(Database.BatchableContext BC, List<SA_Contact_Team_Member__c> scope) {
        List<Task> taskList = new List<Task>([SELECT WhoId, OwnerId FROM Task
                                              WHERE WhoId IN (SELECT SA_Contact__c
                                                            FROM SA_Contact_Team_Member__c
                                                            WHERE Id IN :scope) AND
                                                    Subject = :ACTIVITY_SUBJECT_BIRTHDAY_REMINDER AND
                                                    ActivityDate >= :Date.today().addDays(-7)
                                                    ]);
        Set<String> activityIdentifiers = new Set<String>();
        for (Task task : taskList) {
            activityIdentifiers.add(''+task.WhoId+task.OwnerId);
        }

        //String whoIdString = String.join(idList, ', ');
        List<Task> reminderTasks = new List<Task>();
        Task theReminderTask;
        
        // Generates a new Task as a birthday reminder
        for (SA_Contact_Team_Member__c reminderRecipient : scope) {
            // Don't create birthday Reminder if it's already Completed or already exists
            if (!activityIdentifiers.contains(''+reminderRecipient.SA_Contact__c+reminderRecipient.SA_User__c)) {
                theReminderTask = new Task();
                String[] dayMonth = reminderRecipient.SA_Contact__r.Birth_Day_Month__c.split('/');
                theReminderTask.ActivityDate = Date.newInstance(Date.today().year(), Integer.valueOf(dayMonth[1]), Integer.valueOf(dayMonth[0]));  //Date.today().addDays(7);
                theReminderTask.OwnerId = reminderRecipient.SA_User__r.Id;
                theReminderTask.Subject = ACTIVITY_SUBJECT_BIRTHDAY_REMINDER; // for: ' + reminderRecipient.SA_Contact__r.Name;
                theReminderTask.WhoId = reminderRecipient.SA_Contact__r.Id;
                theReminderTask.Description = 'This is a system generated task created as a birthday reminder for ' + reminderRecipient.SA_Contact__r.Name + ' from ' + reminderRecipient.SA_Contact__r.Account.Name + '. Please action according to your mandate regarding Contact birthdays.';
                theReminderTask.Type = 'Follow-up';
                theReminderTask.Status = 'Not Started';
                theReminderTask.Priority = 'Low';
                theReminderTask.IsReminderSet = true;
                theReminderTask.Item_to_Action__c = true;
                reminderTasks.add(theReminderTask);
            }
        }
        
        if (reminderTasks.size() > 0) {
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail = true;
            Database.insert(reminderTasks, dlo);
        }
    }

    // Finish method of the batch class
    global void finish(Database.BatchableContext BC) {
    }
}