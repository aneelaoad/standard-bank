/*************************************************************************
    @ Author     : Abhishek V
    @ Date         : 10. 11. 2016
    @description  : US-1664 - Test class for LDS_TaskCtrl
    
****************************************************************************/

@IsTest
public class LDS_TaskCtrl_Test{
    
    @TestSetup
    static void prepareData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getSystemAdminBAprofileIDtaskDeletion()
        });
        
        User userCC;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            userCC = (User) new BLD_USER().useCib().syncContact().commitWork().getRecord();
        }
        system.assert(userCC != null && userCC.id != null);
        
        Account ugpAcc;
        
        system.runAs(userCC) {
            ugpAcc = (Account) new BLD_Account().useGroupParent()
                .name('Parent Client')
                .CIF('Parent Client1234')
                .proposedClientCoordinator(userCC)
                .commitWork()
                .getRecord();
        }

        new BLD_Opportunity()
            .linkAccountId(ugpAcc.Id)
            .commitWork();
    }
    
    @IsTest
    static void testFunctionalityEditWindow() {
        Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
        Boolean isExceptionThrown = false;
        try {
            System.Test.startTest();
            LDS_TaskCtrl mctc = new LDS_TaskCtrl();
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
            Test.stopTest();
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        System.assert(!isExceptionThrown);
    }
    
    @IsTest
    static void testFunctionalityUpdateTask() {
        Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
        Boolean isExceptionThrown = false;
        try {
            Test.startTest();
            LDS_TaskCtrl mctc = new LDS_TaskCtrl();
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
            mctc.IdForTaskCP = mctc.idTaskForTest;
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
            mctc.Lightning = true;
            mctc.displayWindow();
            mctc.opptyName = 'Test Name';
            mctc.disablenewbtn = false;
            Test.stopTest();
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        System.assert(!isExceptionThrown);
    }

    @IsTest
    static void testFunctionalityCreateTaskWithoutDateFields() {
        Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
        Boolean isExceptionThrown = false;
        try {
            Test.startTest();
            LDS_TaskCtrl mctc = new LDS_TaskCtrl();
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
            Test.stopTest();
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        System.assert(!isExceptionThrown);
    }

    @IsTest
    static void testFunctionalityUpdateWithoutTaskId() {
        Boolean isExceptionThrown = false;
        try {
            Test.startTest();
            LDS_TaskCtrl mctc = new LDS_TaskCtrl();
            mctc.updateTask();
            Test.stopTest();
        }
        catch (Exception ex) {
            isExceptionThrown = true;
        }
        System.assert(!isExceptionThrown);
    }

    @IsTest
    static void testFunctionalityCreateWithoutisReminderSet() {
        Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            LDS_TaskCtrl mctc = new LDS_TaskCtrl();
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
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(!isExceptionThrown);
    }
}