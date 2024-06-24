/**
 * Test class for DMN_Task class
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		December 2020
 */
@IsTest
public class DMN_Task_TEST {

    public static final String ADMIN_USERNAME          = 'test.adminUser@test.com';
    public static final String TEST_CIB_USERNAME          = 'test.cibUser@test.com';
    public static final String TEST_COMMB_USERNAME        = 'test.commbUser@test.com';
    public static final String DEF_ACC_NAME            = 'Def Name for Acc';
    public static final String DEF_CON_NAME            = 'DefNamefor Contact';
    public static final String DEF_OPP_NAME            = 'Def Name for Opportunity';

    private static Account acc;
    private static Contact cont;
    private static Opportunity opp;
    private static User sysAdmin;
    private static User cibUser;
    private static User commbUser;

    private static void getData(){
        for(User u : [  SELECT Username
        FROM User
        WHERE UserName IN: new String[]{TEST_COMMB_USERNAME, TEST_CIB_USERNAME, ADMIN_USERNAME}]){
            if(u.UserName == TEST_CIB_USERNAME){
                cibUser = u;
            }
            if(u.UserName == TEST_COMMB_USERNAME){
                commbUser = u;
            }
            if(u.UserName == ADMIN_USERNAME){
                sysAdmin = u;
            }
        }

        acc = [SELECT Name, Task_Name__c FROM Account WHERE Name = :DEF_ACC_NAME];
        cont = [SELECT Name, Task_Name__c FROM Contact WHERE Name = :DEF_CON_NAME];
        opp = [SELECT Name, Task_Name__c FROM Opportunity WHERE Name = :DEF_OPP_NAME];
    }

    @testSetup
    static void prepareData() {

        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            sysAdmin = (User)new BLD_USER(uow).userName(ADMIN_USERNAME).useSysAdmin().syncContact().getRecord();
            cibUser = (User)new BLD_USER(uow).userName(TEST_CIB_USERNAME).useCib().syncContact().getRecord();
            commbUser = (User)new BLD_USER(uow).userName(TEST_COMMB_USERNAME).useCommB().syncContact().getRecord();
            uow.commitWork();
        }


        System.runAs(sysAdmin){
            BLD_Account bldAcc = new BLD_Account(uow)
                    .name(DEF_ACC_NAME)
                    .addTask(new BLD_Task(uow).subject('Account Parent Task'));
            uow.commitWork();

            BLD_Contact bldContact  = new BLD_Contact(uow)
                    .name(DEF_CON_NAME.substringBefore(' '), DEF_CON_NAME.substringAfter(' '))
                    .account(bldAcc)
                    .addTask(new BLD_Task(uow).subject('Contact Parent Task'));

            uow.commitWork();


            BLD_Opportunity bldOpportunity = new BLD_Opportunity(uow)
                    .name(DEF_OPP_NAME)
                    .client(bldAcc)
                    .addTask(new BLD_Task(uow).subject('Opportunity Parent Task'));

            uow.commitWork();

            acc = (Account) bldAcc.getRecord();
            cont = (Contact) bldContact.getRecord();
            opp = (Opportunity) bldOpportunity.getRecord();

        }
    }

    @IsTest
    static void shouldSyncLinkOnParentAccount() {
        getData();
        Task accountTask = [SELECT Id, Subject, WhatId FROM Task WHERE WhatId = :acc.Id];
        accountTask.Subject = 'Account Parent Task UPDATED';


        System.assertEquals('Account Parent Task', acc.Task_Name__c);

        Test.startTest();
        DMN_Task.syncLinkOnParent(new List<Task> {accountTask}, null);
        Test.stopTest();

        acc = [SELECT Id, Task_Name__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(accountTask.Subject, acc.Task_Name__c);
    }

    @IsTest
    static void shouldSyncLinkOnParentContact() {
        getData();
        Task contactTask = [SELECT Id, Subject, WhoId FROM Task WHERE WhoId = :cont.Id];
        contactTask.Subject = 'Contact Parent Task UPDATED';

        System.assertEquals('Contact Parent Task', cont.Task_Name__c);

        Test.startTest();
        DMN_Task.syncLinkOnParent(new List<Task> {contactTask}, null);
        Test.stopTest();

        cont = [SELECT Id, Task_Name__c FROM Contact WHERE Id = :cont.Id];
        System.assertEquals(contactTask.Subject, cont.Task_Name__c);
    }

    @IsTest
    static void shouldSyncLinkOnParentOpportunity() {
        getData();
        Task opportunityTask = [SELECT Id, Subject, WhatId FROM Task WHERE WhatId = :opp.Id];
        opportunityTask.Subject = 'Opportunity Parent Task UPDATED';


        System.assertEquals('Opportunity Parent Task', opp.Task_Name__c);

        Test.startTest();
        DMN_Task.syncLinkOnParent(new List<Task> {opportunityTask}, null);
        Test.stopTest();

        opp = [SELECT Id, Task_Name__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(opportunityTask.Subject, opp.Task_Name__c);
    }

    @IsTest
    static void shouldThrowNonAdminError() {
        getData();
        Task testTask = [SELECT Id FROM Task LIMIT 1];
        System.assert(ApexPages.getMessages().isEmpty());

        System.runAs(cibUser) {
            Test.startTest();
            DMN_Task.validateBeforeDelete(new List<Task> {testTask});
            Test.stopTest();
        }

        System.assert(!ApexPages.getMessages().isEmpty());
        System.assertEquals(Label.TaskDeletionErrorMsg, ApexPages.getMessages().get(0).getDetail());
    }

    @IsTest
    static void shouldNotThrowNonAdminError() {
        getData();
        Task testTask = [SELECT Id FROM Task LIMIT 1];
        System.assert(ApexPages.getMessages().isEmpty());

        System.runAs(sysAdmin) {
            Test.startTest();
            DMN_Task.validateBeforeDelete(new List<Task> {testTask});
            Test.stopTest();
        }

        System.assert(ApexPages.getMessages().isEmpty());
    }

    @IsTest
    static void shouldCreateTask() {
        getData();
        String subject = 'Subject for DMN_Task_Test class';
        Id whatId = acc.Id;
        Id ownerId = cibUser.Id;
        String type = 'Other';
        String status = DMN_Task.STATUS_IN_PROGRESS;
        String description = 'Description for DMN_Task_Test class';
        String priority = 'Low';
        Test.startTest();
        DMN_Task.createTask(subject, whatId, ownerId, type, status, description, priority);
        Test.stopTest();

        List<Task> insertedTasks = [
                SELECT Id, Item_to_Action__c
                FROM Task
                WHERE Subject = :subject
        ];

        System.assertEquals(1, insertedTasks.size());
        System.assert(insertedTasks.get(0).Item_to_Action__c);


    }
}