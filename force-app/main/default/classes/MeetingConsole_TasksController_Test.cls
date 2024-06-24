/*************************************************************************
    @ Author     : psvestka
    @ Date         : 20. 5. 2016
    @description  : US-1237
    
    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : June 15, 2016
    @ Last Modified Reason  : US-1355 - Ensuring at least 2 Core Team Members exist on Internal Core Meetings
    
    @ Last Modified By  : Jana Cechova
    @ Last Modified On  : June 20, 2016
    @ Last Modified Reason  : DEF-001926: Editing an existing Task from the Console does not refresh Task list on Console
    
    @ Last Modified By  : Jana Cechova
    @ Last Modified On  : Aug 18, 2016
    @ Last Modified Reason  : Increase code coverage
****************************************************************************/
@IsTest
public class MeetingConsole_TasksController_Test {
    
    @TestSetup
    static void prepareData() {

        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getSystemAdminBAprofileIDtaskDeletion()
        });

        User userCC;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            userCC = (User) new BLD_USER().useCib().commitWork().getRecord();
        }

        Account ugpAcc;
        
        System.runAs(userCC) {
            ugpAcc = (Account) new BLD_Account().useGroupParent()
                .name('Parent Client')
                .CIF('Parent Client1234')
                .proposedClientCoordinator(userCC)
                .commitWork()
                .getRecord();
        }

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Opportunity oppBuilder = new BLD_Opportunity(uow)
            .linkAccountId(ugpAcc.Id);

        for (Integer i = 0; i < 2; i++) {
            new BLD_Task(uow)
                .linkToParent(oppBuilder)
                .assignedTo(userCC)
                .type(DMN_Task.TYPE_NBAC_ACTION_ITEM);
        }

        uow.commitWork();
    }
    
    @IsTest
    static void testListTasks() {
        Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
        MeetingConsole_TasksController mctc = new MeetingConsole_TasksController();
        List<Task> newfetchedTasks = mctc.tasks;
        mctc.opptyId = opp.id;
        List<Task> fetchedTasks = mctc.tasks;
        system.assert(fetchedTasks != null);
        system.assertEquals(2, fetchedTasks.size());
    }
    
    @IsTest
    static void testFunctionalityEditWindow() {
        try {
            Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
            MeetingConsole_TasksController mctc = new MeetingConsole_TasksController();
            mctc.opptyId = opp.id;
            mctc.taskRec.subject = 'TestSubject';
            mctc.taskRec.priority = 'Low';
            mctc.taskRec.status = 'Completed';
            mctc.taskRec.type = DMN_Task.TYPE_NBAC_ACTION_ITEM;
            mctc.taskRec.description = 'TestDescription';
            mctc.taskRec.Short_Description__c = 'TestShortDescription';
            mctc.taskRec.isReminderSet = true;
            mctc.taskRec.reminderDateTime = date.today();
            mctc.taskRec.activitydate = date.today();
            mctc.createTask();
            mctc.IdForTask = mctc.idTaskForTest;
            mctc.editWindow();
        }
        catch(Exception ex) {
            System.assert(false);
        }
    }

    @IsTest
    static void testFunctionalityUpdateTask() {
        try {
            Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
            MeetingConsole_TasksController mctc = new MeetingConsole_TasksController();
            mctc.opptyId = opp.id;
            mctc.taskRec.subject = 'TestSubject';
            mctc.taskRec.priority = 'Low';
            mctc.taskRec.status = 'Completed';
            mctc.taskRec.type = DMN_Task.TYPE_NBAC_ACTION_ITEM;
            mctc.taskRec.description = 'TestDescription';
            mctc.taskRec.Short_Description__c = 'TestShortDescription';
            mctc.taskRec.isReminderSet = true;
            mctc.taskRec.reminderDateTime = date.today();
            mctc.taskRec.activitydate = date.today();
            mctc.createTask();
            mctc.IdForTask = mctc.idTaskForTest;
            mctc.editWindow();
            mctc.taskRec.subject = 'TestTestSubject';
            mctc.taskRec.priority = 'Low';
            mctc.taskRec.status = 'Completed';
            mctc.taskRec.type = DMN_Task.TYPE_NBAC_ACTION_ITEM;
            mctc.taskRec.description = 'TestTestDescription';
            mctc.taskRec.Short_Description__c = 'TestTestShortDescription';
            mctc.taskRec.isReminderSet = false;
            mctc.taskRec.reminderDateTime = system.now();
            mctc.taskRec.activitydate = System.today()+60;
            mctc.updateTask();
            mctc.displayWindow();
        }
        catch(Exception ex) {
            System.assert(false);
        }
    }

    @IsTest
    static void testFunctionalityCreateTaskWithoutDateFields() {
        try {
            Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
            MeetingConsole_TasksController mctc = new MeetingConsole_TasksController();
            mctc.opptyId = opp.id;
            mctc.taskRec.subject = 'TestSubject';
            mctc.taskRec.priority = 'Low';
            mctc.taskRec.status = 'Completed';
            mctc.taskRec.type = DMN_Task.TYPE_NBAC_ACTION_ITEM;
            mctc.taskRec.description = 'TestDescription';
            mctc.taskRec.Short_Description__c = 'TestShortDescription';
            mctc.taskRec.isReminderSet = true;
            mctc.createTask();
            mctc.IdForTask = mctc.idTaskForTest;
            mctc.editWindow();
            mctc.taskRec.subject = 'TestTestSubject';
            mctc.taskRec.priority = 'Low';
            mctc.taskRec.status = 'Completed';
            mctc.taskRec.type = DMN_Task.TYPE_NBAC_ACTION_ITEM;
            mctc.taskRec.description = 'TestTestDescription';
            mctc.taskRec.Short_Description__c = 'TestTestShortDescription';
            mctc.taskRec.isReminderSet = false;
            mctc.updateTask();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

    @IsTest
    static void testFunctionalityUpdateWithoutTaskId() {
        try {
            MeetingConsole_TasksController mctc = new MeetingConsole_TasksController();
            mctc.updateTask();
        }
        catch(Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

    @IsTest
    static void testFunctionalityCreateWithoutisReminderSet() {
        try {
            Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
            MeetingConsole_TasksController mctc = new MeetingConsole_TasksController();
            mctc.opptyId = opp.id;
            mctc.taskRec.subject = 'TestSubject';
            mctc.taskRec.priority = 'Low';
            mctc.taskRec.status = 'Completed';
            mctc.taskRec.type = DMN_Task.TYPE_NBAC_ACTION_ITEM;
            mctc.taskRec.description = 'TestDescription';
            mctc.taskRec.Short_Description__c = 'TestShortDescription';
            mctc.taskRec.isReminderSet = false;
            mctc.createTask();
        }
        catch(Exception ex) {
            System.assert(false);
        }
    }
}