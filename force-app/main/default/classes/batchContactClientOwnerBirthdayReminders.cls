/*************************************************************************\
    @ Author        : Revashlin Iyman
    @ Date          : 23rd Sept, 2010
    @ Test File     : BirthdayCronJob_Test.cls
    @ Description   : This batch class sends birthday reminders to the client owner
    @ Audit Trial   : Repeating block for each change to the code
    @ Last Modified By  :   Nikhita Reddy
    @ Last Modified On  :   14 Jan 2013
    @ Last Modified Reason  :   Indented the code and added comments. Updated the API Version to 27
****************************************************************************/

global class batchContactClientOwnerBirthdayReminders implements Database.Batchable<sObject> {
    public Boolean runTestMethod = false;
    global String query;
    public Integer Month;
    public Integer Day;
    global Integer TotalReminders;
    private Date today, birthdayToDate;

    private static String ACTIVITY_SUBJECT_BIRTHDAY_REMINDER = 'Birthday Reminder';

    global batchContactClientOwnerBirthdayReminders() {
        /*Date theBigDay = Date.today().addDays(7);
        this.Day = theBigDay.day();
        this.Month = theBigDay.month();*/
        this.today = Date.today();
        this.birthdayToDate = Date.today().addDays(7);

        this.query = 'SELECT OwnerId, Owner.IsActive, Name, Id, Birth_Day_Month__c, Account.OwnerId, Account.Name, AccountId, Account.Owner.IsActive, Owner.RecieveBirthdayReminderTasks__c, Account.Owner.RecieveBirthdayReminderTasks__c' + 
                        +' FROM Contact WHERE Inactive__c = false'+
                        +' AND Birthday_Date_Format__c <= :birthdayToDate'+
                        +' AND Birthday_Date_Format__c >= :today'+
                        +' AND (Owner.RecieveBirthdayReminderTasks__c = true'+
                        +   ' OR  Account.Owner.RecieveBirthdayReminderTasks__c = true)';
                        
    }
    
    // Start method of the batch class
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (runTestMethod) {
            query = query + ' ORDER BY CreatedDate DESC LIMIT 200';
        }
        return Database.getQueryLocator(query);
    }
    
    // Execute method of the batch class
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Task> taskList = new List<Task>([SELECT WhoId, OwnerId FROM Task
                                              WHERE WhoId IN :scope AND
                                                    Subject = :ACTIVITY_SUBJECT_BIRTHDAY_REMINDER AND
                                                    ActivityDate >= :Date.today().addDays(-7)]);
        Set<String> activityIdentifiers = new Set<String>();
        for (Task task : taskList) {
            activityIdentifiers.add(''+task.WhoId+task.OwnerId);
        }
        //String whoIdString = String.join(idList, ', ');
        List<Task> reminderTasks = new List<Task>();
        Task theReminderTask;
        
        for (Contact birthdayPerson : scope) {
            // Don't create birthday Reminder if it's already already exists for contact owner
            // Add birthday Reminder for Contact Owner
            if (!activityIdentifiers.contains(''+birthdayPerson.Id+birthdayPerson.OwnerId)
                &&(birthdayPerson.Owner.RecieveBirthdayReminderTasks__c) 
                && (birthdayPerson.Owner.IsActive)) {

                theReminderTask = new Task();
                String[] dayMonth = birthdayPerson.Birth_Day_Month__c.split('/');
                theReminderTask.ActivityDate = Date.newInstance(Date.today().year(), Integer.valueOf(dayMonth[1]), Integer.valueOf(dayMonth[0]));  //Date.today().addDays(7);
                theReminderTask.OwnerId = birthdayPerson.OwnerId;
                theReminderTask.Subject = ACTIVITY_SUBJECT_BIRTHDAY_REMINDER; //for: ' + birthdayPerson.Name;
                theReminderTask.WhoId = birthdayPerson.Id;
                theReminderTask.Description = 'This is a system generated task created as a birthday reminder for ' + birthdayPerson.Name + ' from ' + birthdayPerson.Account.Name + '. Please action according to your mandate regarding Contact birthdays.';
                theReminderTask.Type = 'Follow-up';
                theReminderTask.Status = 'Not Started';
                theReminderTask.Priority = 'Low';
                theReminderTask.IsReminderSet = true;
                theReminderTask.Item_to_Action__c = true;
                reminderTasks.add(theReminderTask);
                activityIdentifiers.add(''+birthdayPerson.Id+birthdayPerson.OwnerId);
            }

            // Don't create birthday Reminder if it's already already exists for contact account owner
            // Add birthday Reminder for Client Owner
            if (!activityIdentifiers.contains(''+birthdayPerson.Id+birthdayPerson.Account.OwnerId)
                && (birthdayPerson.Account.Owner.RecieveBirthdayReminderTasks__c) 
                && (birthdayPerson.Account.Owner.IsActive)) {

                theReminderTask = new Task();
                String[] dayMonth = birthdayPerson.Birth_Day_Month__c.split('/');
                theReminderTask.ActivityDate = Date.newInstance(Date.today().year(), Integer.valueOf(dayMonth[1]), Integer.valueOf(dayMonth[0]));
                theReminderTask.OwnerId = birthdayPerson.Account.OwnerId;
                theReminderTask.Subject = ACTIVITY_SUBJECT_BIRTHDAY_REMINDER; // for: ' + birthdayPerson.Name;
                theReminderTask.WhoId = birthdayPerson.Id;
                theReminderTask.Description = 'This is a system generated task created as a birthday reminder for ' + birthdayPerson.Name + ' from ' + birthdayPerson.Account.Name + '. Please action according to your mandate regarding Contact birthdays.';
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
            Database.SaveResult[] results = Database.insert(reminderTasks, dlo);
        }
    }
    
    // Finish method of the batch class
    global void finish(Database.BatchableContext BC) {
        Database.executeBatch(new batchContactTeamBirthdayReminders());
    }
}