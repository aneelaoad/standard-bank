@isTest(SeeAllData = False)
private class StdBank_Cls_ClientDataChange_Test {

    @isTest
    static void testPage() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User userAdmin = (User) new BLD_USER(uow).useSysAdmin().division(DMN_User.GM_DIVISION).getRecord();
        User userStandard = (User) new BLD_USER(uow).useCib().division(DMN_User.GM_DIVISION).getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        List<Account> accounts = new List<Account> {(Account) new BLD_Account().useChild().getRecord()};
        insert accounts;

        Client_Data_Change__c clientDataChange = new Client_Data_Change__c();

        clientDataChange.Current_Client_Coordinator__c = userAdmin.Id;
        clientDataChange.New_Client_Coordinator__c = userStandard.Id;
        clientDataChange.New_Client_Coordinator_Role__c = 'Analyst';
        clientDataChange.Status__c = 'New';

        System.runAs(new User(Id = UserInfo.getUserId())){
            insert clientDataChange;
        }

        PageReference pgRef = Page.StdBank_Cls_ClientDataChange;

        Test.setCurrentPage(pgRef);

        ApexPages.currentPage().getParameters().put('ClientId', accounts[0].id);
        ApexPages.currentPage().getParameters().put('ClientOwner', accounts[0].id);

        Test.startTest();

        System.runAs(userAdmin) {
            try {
                ApexPages.StandardController standardController = new ApexPages.StandardController(clientDataChange);
                StdBank_Cls_ClientDataChange  controllerInstance = new StdBank_Cls_ClientDataChange(standardController);
                controllerInstance.cancelRequest();
            }
            catch (Exception ex) {
                System.assert(false, ex.getMessage());
            }
        }
        Test.stopTest();
    }

    @isTest
    static void testAccessClassic() {
        Client_Data_Change__c clientDataChange = new Client_Data_Change__c();
        // No reason to insert as we need instance and insert is causing validation to trigger
        //insert clientDataChange;

        PageReference pgRef = Page.StdBank_Cls_ClientDataChange;

        Test.setCurrentPage(pgRef);

        Test.startTest();

        ApexPages.StandardController standardController = new ApexPages.StandardController(clientDataChange);
        StdBank_Cls_ClientDataChange  controller = new StdBank_Cls_ClientDataChange(standardController);

        System.assertEquals(false, controller.getIsLightning());
        System.assertEquals(true, controller.getIsClassic());

        Test.stopTest();
    }

    @isTest
    static void testAccessLightning() {
        Client_Data_Change__c clientDataChange = new Client_Data_Change__c();
        // No reason to insert as we need instance and insert is causing validation to trigger
        //insert clientDataChange;

        PageReference pgRef = Page.StdBank_Cls_ClientDataChange;

        Test.setCurrentPage(pgRef);

        ApexPages.currentPage().getParameters().put('isdtp', 'p1');

        Test.startTest();

        ApexPages.StandardController standardController = new ApexPages.StandardController(clientDataChange);
        StdBank_Cls_ClientDataChange  controller = new StdBank_Cls_ClientDataChange(standardController);

        System.assertEquals(true, controller.getIsLightning());
        System.assertEquals(false, controller.getIsClassic());

        Test.stopTest();
    }
}