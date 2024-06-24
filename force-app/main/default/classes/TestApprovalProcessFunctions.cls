/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 10/2011
    @ Description   : Test class for ApprovalProcessFuncation.cls                       
    
    @ Last Modified By: Charles Mutsu
    @ Last Modified Date: 01/03/2013
    @ Description:  Implemented TestDataUtilityClass for generating Test Data
                    Changed the version from 20 to 27.
                    
    @ Last Modified By: Navin Rai
    @ Last Modified Date: 07/17/2013
    @ Description:  Updated as per EN-217, increasing code coverage
                    Changed the version from 27 to 28.

    @ Last Modified By: Petr Roubal
    @ Last Modified Date: 5 Jan 2016
    @ Description:  EN-0498 - Client Sector Fields - Deletion of fields (Clean-up)

    @ Last Modified By: Jarred Schultz
    @ Last Modified Date: 01/04/2019
    @ Description:  US-3444 Updated to remove PCC object creation
******************************************************************************************************/
@isTest(SeeAllData = False)

public with sharing class TestApprovalProcessFunctions {

    static testMethod void TestClass() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User user01 = (User) new BLD_USER(uow).useCib().getRecord();
        User user02 = (User) new BLD_USER(uow).useCib().getRecord();
        User user03 = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
            user01.DelegatedApproverId = user02.Id;
            user02.DelegatedApproverId = user03.Id;
            update new List<User>{user01, user02};
        }

        Gift_Expense_Log_Variables__c oGiftExpenseVariable = TEST_DataFactory.getGiftExpenseLogVariable();
        insert oGiftExpenseVariable;

        BLD_Account accBld = new BLD_Account(uow)
            .name(DMN_Account.STANDARD_BANK_EMPLOYEES);

        BLD_Contact bankConBld = new BLD_Contact(uow).useBankContact().account(accBld);
        BLD_Contact clientConBld = new BLD_Contact(uow).useClientContact().account(accBld);

        Gift_Expense_Log__c giftLog = (Gift_Expense_Log__c) new BLD_GiftExpenseLog(uow)
            .bankContact(bankConBld)
            .clientContact(clientConBld)
            .getRecord();

        uow.commitWork();

        String objectPrefix = Schema.getGlobalDescribe().get('Gift_Expense_Log__c').getDescribe().getKeyPrefix();
        ApexPages.StandardController sc = new ApexPages.StandardController(giftLog);
        
        GiftExpenseNewOverride controller = new GiftExpenseNewOverride(sc);
        
        String theURL = controller.defaultFields().getUrl();
        
        System.Assert(theURL.contains(objectPrefix+'/e'));
        
        giftLog.Approver__c = user02.Id;
        update giftLog;
        
        delete oGiftExpenseVariable ;
        String theURL2 = controller.defaultFields().getUrl();
        
        //Create new Approval Process 1
        Approval.ProcessSubmitRequest submitRequestTest = new Approval.ProcessSubmitRequest();
        //submitRequestTest.setComments('Test');
        submitRequestTest.setObjectId(giftLog.Id);
        //Simmulate Submit
        Approval.ProcessResult result = Approval.process(submitRequestTest );

        List < Id > newWorkItemIds = result.getNewWorkitemIds();
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('PCC 1 Step Comments');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {
            UserInfo.getUserId()
        });
        req2.setWorkitemId(newWorkItemIds.get(0));
        Test.startTest();

        List<Gift_Expense_Log__c> olstTestGiftExpenseLog = new List<Gift_Expense_Log__c> {giftLog};

        ApprovalProcessFunctions AF = new ApprovalProcessFunctions(olstTestGiftExpenseLog);
        AF.actualApproverIdField = 'Approval_Actual_Approver__c';
        AF.approvalDateField = 'Approval_Date__c';
        AF.assignedToIdField = 'Approval_Assigned_To__c';
        AF.commentsField = 'Approval_Comments__c';
        AF.statusField = 'Status__c';
        AF.overAllStatusField = 'Status__c';
        AF.actualApproverNameField = 'Approver__c';
        AF.assignedToNameField = 'Approver__c';
        AF.submit(true);

        ApprovalProcessFunctions AF3 = new ApprovalProcessFunctions(olstTestGiftExpenseLog);
        AF.submit(false);

        Test.stopTest();
    }
}