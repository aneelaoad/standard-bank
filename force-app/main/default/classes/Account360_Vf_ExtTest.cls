/****************************************************************************  
* @author       Maham Hassan
* @date         21/03/2022
* @description  Test class for Account360_Vf_Ext class.
*
****************************************************************************/
@isTest
public with sharing class Account360_Vf_ExtTest {

    public static final String 
        TEST_USER_NAME    = 'test.customerPlan@test.com',
        TEST_ACCOUNT_NAME = 'Test Account 123',
        TEST_OPP_NAME     = 'Test Opportunity',
        TEST_OPP_NAME_2     = 'Test Opportunity 12',
        OPP_STAGE         = '2 - Develop',
        TASK_SUBJECT      = 'Test Subject',
        CASE_SUBJECT      = 'Test Case Subject';



    private static Account account;

    private static Account360_Vf_Ext acc360;
    
    @testSetup
    private static void setup(){

        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        ABS_ObjectBuilderBase accBld = new BLD_Account(uow).name(TEST_ACCOUNT_NAME).useCommB().commitWork();
        
        // Opportunities
        new BLD_Opportunity(uow).name(TEST_OPP_NAME).stage(OPP_STAGE).linkAccountId(accBld.getRecord().Id).closeDate(Date.today()).commitWork();
        new BLD_Opportunity(uow).name(TEST_OPP_NAME_2).stage(OPP_STAGE).linkAccountId(accBld.getRecord().Id).closeDate(Date.today()).commitWork();
        
        // Tasks
        new BLD_Task(uow).subject(TASK_SUBJECT).whatId(accBld.getRecord().Id).commitWork();
        new BLD_Task(uow).subject(TASK_SUBJECT).whatId(accBld.getRecord().Id).commitWork();

        // Cases
        new BLD_Case(uow).subject(CASE_SUBJECT).accountId(accBld.getRecord().Id).commitWork();
        new BLD_Case(uow).subject(CASE_SUBJECT).accountId(accBld.getRecord().Id).commitWork();
    }

    private static void setAccount360() {
        account = [Select Id, Name from Account where Name =: TEST_ACCOUNT_NAME ];
        ApexPages.StandardController controller = new ApexPages.StandardController(account);
        acc360 = new Account360_Vf_Ext(controller);
    }

    @isTest
    private static void checkOpportunities() {
        setAccount360();
        List<Account360_Vf_Ext.OpportunitySelection> oppSelections = new List<Account360_Vf_Ext.OpportunitySelection>();
        oppSelections = acc360.getOpportunities();
        if (oppSelections.size() > 0) {
            oppSelections[0].checked = true;
        }
        acc360.save360();
        setAccount360();
        acc360.getOpportunities();
        acc360.getSelectedOpportunities();
        System.assertEquals(1, acc360.getCountOpp(), 'Related Opportunities which are not selected should be 1');
    }

    @isTest
    private static void checkTasks() {
        setAccount360();
        List<Account360_Vf_Ext.TaskSelection> taskSelections = new List<Account360_Vf_Ext.TaskSelection>();
        taskSelections = acc360.getTasks();
        if (taskSelections.size() > 0) {
            taskSelections[0].checked = true;
        }
        acc360.save360();
        setAccount360();
        acc360.getTasks();
        acc360.getSelectedTasks();
        System.assertEquals(1, acc360.getCountTask(), 'Related Tasks which are not selected should be 1');
    }

    @isTest
    private static void checkCases() {
        setAccount360();
        List<Account360_Vf_Ext.CaseSelection> caseSelections = new List<Account360_Vf_Ext.CaseSelection>();
        caseSelections = acc360.getCases();
        if (caseSelections.size() > 0) {
            caseSelections[0].checked = true;
        }
        acc360.save360();
        setAccount360();
        acc360.getCases();
        acc360.getSelectedCases();
        System.assertEquals(1, acc360.getCountCase(), 'Related Cases which are not selected should be 1');
    }

    @isTest
    private static void checkFinancialAccounts() {
        setAccount360();
        finserv__FinancialAccount__c finAcc = new finserv__FinancialAccount__c();
        finAcc.FinServ__PrimaryOwner__c = account.Id;
        insert finAcc;
        List<Account360_Vf_Ext.FinancialAccountSelection> finAccountSelections = new List<Account360_Vf_Ext.FinancialAccountSelection>();
        finAccountSelections = acc360.getFinancialAccounts();
        if (finAccountSelections.size() > 0) {
            finAccountSelections[0].checked = true;
        }
        acc360.save360();
        setAccount360();
        acc360.getFinancialAccounts();
        acc360.getSelectedFinancialAccount();
        System.assertEquals(1, acc360.getCountFinancialAccount(), 'Related Financial Account Relationships which are not selected should be 1');
    }

    @isTest
    private static void checkAccountAccountRelation() {
        setAccount360();
        FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c();
        role.FinServ__InverseRole__c = 'New Role';
        insert role;
        FinServ__AccountAccountRelation__c accAccRel = new FinServ__AccountAccountRelation__c();
        accAccRel.Finserv__Role__c = role.Id;
        accAccRel.FinServ__Account__c = account.Id;
        insert accAccRel;
        List<Account360_Vf_Ext.AccountRelationshipSelection> accAccountSelections = new List<Account360_Vf_Ext.AccountRelationshipSelection>();
        accAccountSelections = acc360.getAccountRelationships();
        if (accAccountSelections.size() > 0) {
            accAccountSelections[0].checked = true;
        }
        acc360.save360();
        setAccount360();
        acc360.getAccountRelationships();
        acc360.getSelectedAccountRelationships();
        System.assertEquals(1, acc360.getCountAccRel(), 'Related Account-Account Relationships which are not selected should be 1');
    }

    @isTest
    private static void checkAccountContactRelation() {
        setAccount360();
        CMN_Account_Contact_Relationship_Detail__c conAccRel = new CMN_Account_Contact_Relationship_Detail__c();
        conAccRel.Client__c = account.Id;
        insert conAccRel;
        List<Account360_Vf_Ext.AccountContactRelationshipSelection> conAccountSelections = new List<Account360_Vf_Ext.AccountContactRelationshipSelection>();
        conAccountSelections = acc360.getAccountContactRelationships();
        if (conAccountSelections.size() > 0) {
            conAccountSelections[0].checked = true;
        }
        acc360.save360();
        setAccount360();
        acc360.getAccountContactRelationships();
        acc360.getSelectedAccountContactRelationships();
        System.assertEquals(0, acc360.getCountAccRel(), 'Related CMN Account Contact Relationships which are not selected should be 0');
    }

    @isTest
    private static void checkPDF() {
        setAccount360();
        acc360.attach360PDF();
        Attachment attachment = [Select Id, Name from Attachment];

        System.assertEquals('Ver~1~360VIEW-' + account.Id + '-' + System.Today() + '.pdf', attachment.Name, 'Attach PDF should have name Ver~1~360VIEW-' + account.Id + '-' + System.Today() + '.pdf');
    }   

}