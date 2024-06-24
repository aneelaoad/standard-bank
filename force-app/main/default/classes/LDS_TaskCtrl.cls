/*************************************************************************
    @ Author        : Abhishek V
    @ Date          : 9. 11. 2016
    @ Test File     : LDS_TaskCtrl
    @ Description   : US-1662

****************************************************************************/

public without sharing class LDS_TaskCtrl{
    public Task taskRec      { get; set; }
    public Id IdForTask      { get; set; }
    public Id IdForTaskCP    { get; 
        set{
            system.debug('###x taskID setter called with value=' + value);
            IdForTaskCP = value;
            IdForTask = value;
            if(value != null){
                editWindow();
            }
        }
    }
    public Id taskidtoupdate{get; private set;}
    public boolean disablenewbtn{get; set;}
    public boolean lightning{get; set;}
    public Id idTaskForTest;

    public Boolean windowDisplayed { get; set; }
    
    public Datetime reminderDateTime{get;set;}
    public Id opptyId {
        get; 
        
        set {
            system.debug('###x opptyId setter called with value=' + value);
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
   
    public LDS_TaskCtrl() {
        windowDisplayed = false;
        
        taskRec = new Task();
        system.debug(logginglevel.error, 'Im in constructor of component lds task' + taskRec);
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
        system.debug('++++'+lightning);
        if(lightning){
            taskRec = new Task();
            setDefaultsTaskRec(taskRec);
            reminderDateTimeString = activityDateString = '';
            
            windowDisplayed = true;
        }
        return null;
        
    }
    
    public PageReference editWindow() {
        system.debug('++++'+lightning);
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
        taskidtoupdate = IdForTask;

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
            system.debug(logginglevel.error, 'activityDateString' + activityDateString);
        
        }else{
            activityDateString = '';
        }
           
           
        DateTime outputReminderDate = listTask[0].reminderDateTime; 
        system.debug(logginglevel.error, 'outputReminderDate' + outputReminderDate);  
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
     taskRec.Id = taskidtoupdate;
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
                    system.debug('+++++before update task -' +taskRec.ID+taskRec.subject+IdForTask+IdForTaskCP+taskidtoupdate);
                    update taskRec;
                   
                    // prepare for reuse
                    IdForTask = null;
                    taskidtoupdate = null;
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
        taskidtoupdate = null;
        
        windowDisplayed = false; 
        return null;
      
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
                    system.debug(logginglevel.error, 'beforeInsertTask' + taskRec);
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