/*************************************************************************
    @ Author        : psvestka
    @ Date          : 17. 5. 2016
    @ Test File     : MeetingConsole_TasksController_Test
    @ Description   : US-1237

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : May 25, 2016
    @ Modification Description : US-1367 :  introducing a custom pop-up window
    
    
    @ Last Modified By  : Jana Cechova
    @ Last Modified On  : Jun 20, 2016
    @ Modification Description : DEF-001926: Editing an existing Task from the Console does not refresh Task list on Console
    
    @ Last Modified By  : Jana Cechova
    @ Last Modified On  : Aug 18, 2016
    @ Modification Description : Created public Id idTaskForTest; for test class MeetingConsole_TasksController_Test
    
    @ Last Modified By  : Abhishek V
    @ Last Modified On  : Sep 14, 2016
    @ Modification Description : Included DMLoptions for email settings when a task is inserted or updated

    @ Last Modified By  : Emmanuel Nocks Mulea
    @ Last Modified On  : Jan 16, 2020
    @ Modification Description : Making the class to be compatible with Aura Components
****************************************************************************/

public without sharing class MeetingConsole_TasksController {

    public final String nbacActionType = 'NBAC Action Item';

    public Task taskRec         { get; set; }
    public String gpClientName  { get; set; }
    public Id IdForTask      { get; set; }
    public Id idTaskForTest;

    public Boolean windowDisplayed { get; set; }
    
    public Datetime reminderDateTime{get;set;}
    public Id opptyId {
        get; 
        
        set {
            opptyId = value;
            taskRec.whatId = opptyId;
        } 
    }
    
    public String opptyName    { get; set; }
    
    public String activityDateString {
        get;
        set {
            activityDateString = value;
            
            if (String.isEmpty(activityDateString)) {
              return;
            }
            
            taskRec.activityDate = constructDate(activityDateString);
        }
    }
    
    public String reminderDateTimeString {
        get;
        set {
            reminderDateTimeString = value;
            
            if (String.isEmpty(reminderDateTimeString)) {
                return;
            }
            
            taskRec.reminderDateTime = constructDateTime(reminderDateTimeString);
        }
    }
   
    public MeetingConsole_TasksController() {
        windowDisplayed = false;
        
        taskRec = new Task();
       
        setDefaultsTaskRec(taskRec);
        reminderDateTimeString = activityDateString = '';
    }
    
    private Date constructDate(String value) {
        Date d = null;
        
        if (String.isEmpty(value) || !value.contains('/')) {
            return d;
        }
        
        List<String> dateSplit = value.split('/');
        if (dateSplit.size() != 3) {
            return d;
        }
        
        Integer year = Integer.valueOf(dateSplit[2]);
        Integer month = Integer.valueOf(dateSplit[1]);
        Integer day = Integer.valueOf(dateSplit[0]);
        
        d = Date.newInstance(year, month, day);
        
        return d;
    }
    
    private DateTime constructDateTime(String value) {
        DateTime dt = null;
        
        if (String.isEmpty(value) || !value.contains(' ')) {
            return dt;
        }
        
        String datePart = value.split(' ')[0];
        String timePart = value.split(' ')[1];
        
        Date d = constructDate(datePart);
        if (d == null) {
            return dt;
        }
        
        if (!timePart.contains(':')) {
            return dt;
        }
        
        List<String> times = timePart.split(':');
        Integer h = Integer.valueOf(times[0]);
        Integer m = Integer.valueOf(times[1]);
        
        dt = DateTime.newInstance(d.year(), d.month(), d.day());
        dt = dt.addHours(h);
        dt = dt.addMinutes(m);
        
        return dt;
    }
    
    public PageReference displayWindow() {
        // prepare for reuse
        taskRec = new Task();
        setDefaultsTaskRec(taskRec);
        reminderDateTimeString = activityDateString = '';
        
        windowDisplayed = true;
        return null;
    }
    
    public PageReference editWindow() {
        list<Task> listTask = new list<Task>();
        system.debug(logginglevel.error, 'IdForTask' + IdForTask);
        listTask = [SELECT id, subject, 
                                priority, 
                                status, 
                                type, 
                                activitydate,
                                reminderDateTime, 
                                owner.name, 
                                ownerId, 
                                description, 
                                short_description__c,
                                isReminderSet
                                
                        FROM Task 
                        WHERE id = :IdForTask];

        taskRec.subject = listTask[0].subject;
        taskRec.priority = listTask[0].priority;
        taskRec.status = listTask[0].status;
        taskRec.type = listTask[0].type;
        taskRec.description = listTask[0].description;
        taskRec.Short_Description__c = listTask[0].Short_Description__c;
        taskRec.isReminderSet = listTask[0].isReminderSet;
        taskRec.ownerId = listTask[0].ownerId;
        taskRec.reminderDateTime = listTask[0].reminderDateTime;
           
        Date outputActivityDate = listTask[0].activitydate;
        if(outputActivityDate != null){
            String sMonth = String.valueof(outputActivityDate.month());
            String sDay = String.valueof(outputActivityDate.day());
            if(sMonth.length()==1){
              sMonth = '0' + sMonth;
            }
            if(sDay.length()==1){
              sDay = '0' + sDay;
            }
            String sToday = sDay + '/' + sMonth + '/' + String.valueof(outputActivityDate.year());
            activityDateString = sToday;
        }else{
            activityDateString = '';
        }
           
           
        DateTime outputReminderDate = listTask[0].reminderDateTime;
        if(outputReminderDate != null){
            reminderDateTimeString =  String.valueof(outputReminderDate.format('dd/MM/yyyy HH:mm'));
          
           
        }else{
            reminderDateTimeString = '';
        }
        
        windowDisplayed = true;
        return null;
    }
    
    public PageReference updateTask() {
     windowDisplayed = false;
     taskRec.Id = IdForTask;
            if(activityDateString == '' || activityDateString.length()==0){
                taskRec.activitydate = null;
            }
            if(reminderDateTimeString == '' || reminderDateTimeString.length()==0){
                taskRec.reminderDateTime = null;
            
            }
            
            try {
                    Database.DMLOptions dlo = new Database.DMLOptions();
                    dlo.EmailHeader.triggerUserEmail = true;
                    taskRec.setOptions(dlo);
                    update taskRec;
                   
                    // prepare for reuse
                    IdForTask = null;
                    taskRec = new Task();
                    setDefaultsTaskRec(taskRec);
                    hideWindow();
                    reminderDateTimeString = activityDateString = '';
                    
                } catch (Exception e){
                    ApexPages.getMessages().clear();
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error occured. '+ e.getMessage()));
                }
                
               
         return null;  
         
    } 
    
    
    public PageReference hideWindow() {
        // prepare for reuse
        taskRec = new Task();
        setDefaultsTaskRec(taskRec);
        reminderDateTimeString = activityDateString = '';
        IdForTask = null;
        
        windowDisplayed = false; 
        return null;
      
    }
    /***
Use
@param  	    :  string opptyId,string gpClientName
@return   	    :  List of Task
@ Description 	:  get a list of task
***/
    @AuraEnabled
    public  static List<Task> getTasksList(string opptyId,string gpClientName){
        String nbacActionType = 'NBAC Action Item';
        List<Task> tasks = new List<Task>();
        if (!String.isEmpty(opptyId)) {
            List<Account> clientsWithOpps = getRelatedClientsWithOpps(gpClientName);
            List<Id> recordIds = new List<Id> ();
            List<Opportunity> opps = new List<Opportunity> ();
            for(Account acc : clientsWithOpps) {
                recordIds.add(acc.Id);
                opps.addAll(acc.Opportunities);
            }
            for(Opportunity opp : opps) {
                recordIds.add(opp.Id);
            }
            recordIds.add(opptyId);
            tasks = [SELECT id, subject, priority, status, type, activitydate, owner.name, ownerId, description, short_description__c
            FROM Task WHERE whatId IN :recordIds And Type = :nbacActionType ORDER BY priority DESC, activityDate DESC NULLS LAST];

        } else {
            tasks = new List<Task>();
        }
        return tasks;
    }
    public List<Task> tasks {
        get {
            if (!String.isEmpty(opptyId)) {
                List<Account> clientsWithOpps = getRelatedClientsWithOpps(gpClientName);
                List<Id> recordIds = new List<Id> ();
                List<Opportunity> opps = new List<Opportunity> ();
                for(Account acc : clientsWithOpps) {
                    recordIds.add(acc.Id);
                    opps.addAll(acc.Opportunities);
                }
                for(Opportunity opp : opps) {
                    recordIds.add(opp.Id);
                }
                recordIds.add(opptyId);
                tasks = [SELECT id, subject, priority, status, type, activitydate, owner.name, ownerId, description, short_description__c
                        FROM Task WHERE whatId IN :recordIds And Type = :nbacActionType ORDER BY priority DESC, activityDate DESC NULLS LAST];

            } else {
                tasks = new List<Task>();
            }
            return tasks;
        }
        
        private set;
    }
    /***
Use
@param  	    :  string gpClientName
@return   	    :  List of Account
@ Description 	:  get related Clients with Opp
***/
    private static List<Account> getRelatedClientsWithOpps (String gpClientName) {
        List<Account> clientsWithOpps = new List<Account> ();
        clientsWithOpps = [Select Id, (SELECT Id
                                        FROM Opportunities
                                        WHERE (Account.Name =:gpClientName
                                                OR Account.Parent.Name =:gpClientName
                                                OR Account.Parent.Parent.Name =:gpClientName))
                            FROM Account
                            Where (Name =:gpClientName
                                    OR Parent.Name =:gpClientName
                                    OR Parent.Parent.Name =:gpClientName)];
        return clientsWithOpps;
    }
    
    private static void setDefaultsTaskRec(Task rec) {
        system.assert(rec != null);
        
        rec.priority = 'High';
        rec.status = 'Not Started';
        rec.type = DMN_Task.TYPE_NBAC_ACTION_ITEM;        
        
    }
    
    public PageReference createTask() {
        if (!taskRec.isReminderSet) {
            taskRec.reminderDateTime = null;
        }
        if(IdForTask==null){
                try {
                    Database.DMLOptions dlo = new Database.DMLOptions();
                    dlo.EmailHeader.triggerUserEmail = true;
                    taskRec.setOptions(dlo);
                    insert taskRec;
                    idTaskForTest = taskRec.id;
                    system.debug(logginglevel.error, 'afterInsertTask' + taskRec);
                    // prepare for reuse
                    taskRec = new Task();
                    setDefaultsTaskRec(taskRec);
                    hideWindow();
                    reminderDateTimeString = activityDateString = '';
                } catch (Exception e){
                    ApexPages.getMessages().clear();
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error occured. '+ e.getMessage()));
                }
           } 
            return null;
        }
        
}