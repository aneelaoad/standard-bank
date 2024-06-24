/*****************************************************************************************************\
    @ Author        : 
    @ Date          : 
    @description   : Test class for ClientWalletController.cls
    @ Last Modified By  :   Prabhanshu Agrawal    
    @ Last Modified On  :   12- Mar -2014
    @ Description   :       
******************************************************************************************************/
@IsTest
Public class TestClientWalletController{

    @IsTest
    static void testForPositiveScenarios() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User testUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User testUserCW1 = (User) new BLD_USER(uow).useCib().getRecord();
        User testUserCW2 = (User) new BLD_USER(uow).useCib().getRecord();
        User testUserCW3 = (User) new BLD_USER(uow).useCib().division(DMN_User.IB_DIVISION).getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
            TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getUserProfileIds(),
                TEST_DataFactory.getErrorMessages(),
                TEST_DataFactory.getCcSettings(),
                TEST_DataFactory.getCstTeamRankings()
            });
        }

        BLD_Account accBld = new BLD_Account(uow).useChild();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }

        new BLD_ClientPlan(uow).account(accBld);

        new BLD_ClientTeam(uow).account(accBld).user(testUserCW1.Id).role(DMN_ClientTeam.ROLE_TPS_CHAMPION);
        new BLD_ClientTeam(uow).account(accBld).user(testUserCW2.Id).role(DMN_ClientTeam.ROLE_TRADER);
        new BLD_ClientTeam(uow).account(accBld).user(testUserCW3.Id).role(DMN_ClientTeam.ROLE_ADVISORY_BANKER);

        List<Share_Wallet__c> shareOfWallet = new List<Share_Wallet__c> {
            (Share_Wallet__c) new BLD_ShareWallet(uow).client(accBld)
                .division(DMN_ShareWallet.DIVISION_INVESTMENT_BANKING)
                .totalWalletSize(110)
                .revenue(130)
                .budget(150)
                .addProduct(
                    new BLD_ShareWalletProduct(uow)
                )
                .getRecord(),
            (Share_Wallet__c) new BLD_ShareWallet(uow).client(accBld)
                .division(DMN_ShareWallet.DIVISION_GLOBAL_MARKETS)
                .totalWalletSize(100)
                .revenue(100)
                .budget(100)
                .addProduct(
                    new BLD_ShareWalletProduct(uow)
                )
                .getRecord()
        };

        uow.commitWork();

         Test.startTest();
         System.runAs(TestUser){
             PageReference pageRef = Page.ClientPlan;
             Test.setCurrentPage(pageRef);
             ApexPages.currentPage().getParameters().put('id', accBld.getRecordId());
             ClientWalletController  con = new ClientWalletController();
             ApexPages.StandardController stdcontroller = new ApexPages.StandardController(accBld.getRecord());
             ClientWalletController cwc = new ClientWalletController(stdcontroller);
             con.CalculateTotalSums(shareOfWallet);
             System.assertEquals(con.total_client_wallet, 210);
             System.assertEquals(con.total_CIB_Revenue, 230);
             System.assertEquals(con.total_Budget, 250);
             con.getDivisionMap();
             con.getDivisionLst();
             cwc.getRenderMapSOW();
             cwc.getRenderMapSOWP();
             con.CalculateTotalSums(shareOfWallet);
         }
         Test.stopTest();
    }   

    @IsTest
    static void testForNegativeScenarios() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User testUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User testUserCW1 = (User) new BLD_USER(uow).useCib().getRecord();
        User testUserCW2 = (User) new BLD_USER(uow).useCib().getRecord();
        User testUserCW3 = (User) new BLD_USER(uow).useCib().division(DMN_User.IB_DIVISION).getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
            List<SObject> settings = new List<SObject>();
            settings.addAll((List<SObject>) TEST_DataFactory.getUserProfileIds());
            settings.addAll((List<SObject>) TEST_DataFactory.getErrorMessages());
            settings.addAll((List<SObject>) TEST_DataFactory.getCcSettings());
            settings.addAll((List<SObject>) TEST_DataFactory.getCstTeamRankings());
            insert settings;
        }

        BLD_Account accBld = new BLD_Account(uow).useChild();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }

        new BLD_ClientPlan(uow).account(accBld);

        new BLD_ClientTeam(uow).account(accBld).user(testUserCW1.Id).role(DMN_ClientTeam.ROLE_TPS_CHAMPION);
        new BLD_ClientTeam(uow).account(accBld).user(testUserCW2.Id).role(DMN_ClientTeam.ROLE_TRADER);
        new BLD_ClientTeam(uow).account(accBld).user(testUserCW3.Id).role(DMN_ClientTeam.ROLE_ADVISORY_BANKER);

        new BLD_ShareWallet(uow).client(accBld)
            .division(DMN_ShareWallet.DIVISION_INVESTMENT_BANKING)
            .totalWalletSize(110)
            .revenue(130)
            .budget(150);

        uow.commitWork();
                      
         Test.startTest();
         System.runAs(TestUser){
             try {
                 PageReference pageRef = Page.ClientPlan;
                 Test.setCurrentPage(pageRef);
                 ApexPages.currentPage().getParameters().put('id', accBld.getRecordId());
                 ClientWalletController  con = new ClientWalletController();

                 ApexPages.StandardController stdcontroller = new ApexPages.StandardController((Account) accBld.getRecord());
                 ClientWalletController cwc = new ClientWalletController(stdcontroller);
             }
             catch(Exception ex) {
                 System.assert(false, ex.getMessage());
             }
         }
         Test.stopTest();
    }
}