/*************************************************************************\
    @ Author        :     Stephen Moore
    @ Date          :     9 Nov 2011
    @ Test File     :     N/A
    @ Description   :     Test Class for Gift Logs

    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Modification Description :  Case #6521- Change contact to use TestFatcory
                                   API Version moved from 23 to 25

    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : 21  FEB 2013
    @ Modification Description :  EN #31- Use of TestDataUtilityClass
                                  Added best prctices to the test class
                                  API Version moved from 25 to 27
****************************************************************************/
@isTest(SeeAllData=false)
public with sharing class GiftExpenseLog_Test {

    //Static data Member
    public static Gift_Expense_Log_Variables__c oGiftExpenseVariable ;

    static testMethod void GiftLogApproverTestMethod() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User user01 = (User) new BLD_USER(uow).useCib().getRecord();
        User user02 = (User) new BLD_USER(uow).useCib().getRecord();
        User user03 = (User) new BLD_USER(uow).useCib().getRecord();
        User user04 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }

        oGiftExpenseVariable = TEST_DataFactory.getGiftExpenseLogVariable();
        insert oGiftExpenseVariable;

        BLD_Account accBld = new BLD_Account(uow).useChild()
            .name(DMN_Account.STANDARD_BANK_EMPLOYEES)
            .proposedClientCoordinator(user04);

        BLD_Contact bankConBld = new BLD_Contact(uow).useBankContact().account(accBld);
        BLD_Contact clientConBld = new BLD_Contact(uow).useClientContact().account(accBld);

        uow.commitWork();

        List<User> usersToUpdate = new List<User>();
        user01.DelegatedApproverId = user02.id;
        usersToUpdate.add(user01);
        user02.DelegatedApproverId = user03.id;
        usersToUpdate.add(user02);
        update usersToUpdate;

        Test.startTest();

        Gift_Expense_Log__c giftExpLogRec = (Gift_Expense_Log__c) new BLD_GiftExpenseLog(uow)
            .bankContact(bankConBld)
            .clientContact(clientConBld)
            .approverId(user01.Id)
            .commitWork()
            .getRecord();

        String objectPrefix = Schema.getGlobalDescribe().get('Gift_Expense_Log__c').getDescribe().getKeyPrefix();
        ApexPages.StandardController sc = new ApexPages.StandardController(giftExpLogRec);

        GiftExpenseNewOverride controller = new GiftExpenseNewOverride(sc);

        String theURL = controller.defaultFields().getUrl();

        System.Assert(theURL.contains(objectPrefix + '/e'));

        giftExpLogRec.Approver__c = user02.id;
        update giftExpLogRec;

        delete oGiftExpenseVariable ;
        String theURL2 = controller.defaultFields().getUrl();

        //Create new Approval Process 1
        Approval.ProcessSubmitRequest submitRequestTest = new Approval.ProcessSubmitRequest();
        //submitRequestTest.setComments('Test');
        submitRequestTest.setObjectId(giftExpLogRec.Id);
        //Simmulate Submit
        Approval.ProcessResult result = Approval.process(submitRequestTest);
        System.assert(result.isSuccess(), 'Result Status:' + result.isSuccess());

        List<Id> newWorkItemIds = result.getNewWorkitemIds();

        Approval.ProcessWorkitemRequest processRequestTest = new Approval.ProcessWorkitemRequest();
        processRequestTest.setComments('Approved Comments');
        processRequestTest.setAction('Approve');
        processRequestTest.setWorkitemId(newWorkItemIds.get(0));

        Approval.ProcessResult result2 = Approval.process(processRequestTest);
        System.assert(result2.isSuccess(), 'Result Status:' + result2.isSuccess());

        Gift_Expense_Log__c testRecord = [SELECT Approval_Overall_Status__c FROM Gift_Expense_Log__c WHERE Id = :giftExpLogRec.Id];
        System.assertEquals('Approved', testRecord.Approval_Overall_Status__c);

        Test.stopTest();

    }
}