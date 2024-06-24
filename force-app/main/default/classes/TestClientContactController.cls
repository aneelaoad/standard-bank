/*****************************************************************************************************\
    @ Author        : 
    @ Date          : 
    @ Description   : Test class for ClientContactController.cls                      
    @ Last Modified By  :   Prabhanshu Agrawal    
    @ Last Modified On  :   12- Mar -2014
    @ Description   :  


    @ Last Modified By  :   Manoj Gupta       
    @ Last Modified On  :   Dec 2015
    @ Last Modified Reason  : EN:0838 - Replacing Corporate Banking references to Client Coverage
    
    @ Last Modified By      :   Jana Cechova
    @ Last Modified On      :   Dec, 2016
    @ Last Modified Reason  :   US-1643/ US-1729: Duplicate Contact Rules 
******************************************************************************************************/

@istest(SeeAllData = false)
Public class TestClientContactController{

    /**********************************************************
    Scenario - Test for save and add Scenarios.
    **********************************************************/

    static testMethod void test_for_save_and_add_scenarios () {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User testUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User testUserKCC1 = (User) new BLD_USER(uow).useCib().division(DMN_User.GM_DIVISION).getRecord();
        User testUserKCC2 = (User) new BLD_USER(uow).useCib().division(DMN_User.CLIENT_COVERAGE_DIVISION).getRecord();
        User testUserKCC3 = (User) new BLD_USER(uow).useCib().division(DMN_User.IB_DIVISION).getRecord();
        User testUserKCC4 = (User) new BLD_USER(uow).useCib().division(DMN_User.TPS_DIVISION).getRecord();
        User testUserKCC5 = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }

        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getErrorMessages(),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getCstTeamRankings()
        });

        BLD_Account accBld = new BLD_Account(uow).useChild()
            .addClientTeam(new BLD_ClientTeam(uow).user(testUserKCC1.Id).role(DMN_ClientTeam.ROLE_TPS_CHAMPION))
            .addClientTeam(new BLD_ClientTeam(uow).user(testUserKCC2.Id).role(DMN_ClientTeam.ROLE_TRADER))
            .addClientTeam(new BLD_ClientTeam(uow).user(testUserKCC3.Id).role(DMN_ClientTeam.ROLE_ADVISORY_BANKER));

        List<BLD_Contact> conBuilders = new List<BLD_Contact>();
        for (Integer i = 0; i < 5; i++) {
            conBuilders.add(new BLD_Contact(uow).useClientContact()
                .account(accBld)
                .addKeyClientContact(
                    new BLD_KeyClientContact(uow).client(accBld)
                )
            );
        }

        new BLD_ClientPlan(uow).account(accBld);

        new BLD_ContactTeamMember(uow).contact(conBuilders[0]).user(testUserKCC1.Id);
        new BLD_ContactTeamMember(uow).contact(conBuilders[0]).user(testUserKCC2.Id);
        new BLD_ContactTeamMember(uow).contact(conBuilders[0]).user(testUserKCC3.Id);
        new BLD_ContactTeamMember(uow).contact(conBuilders[0]).user(testUserKCC4.Id);
        new BLD_ContactTeamMember(uow).contact(conBuilders[0]).user(testUserKCC5.Id);

        uow.commitWork();

        Test.startTest();
        System.runAs(TestUser){
            PageReference pageRef = Page.ClientPlan;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', accBld.getRecordId());

            //Instantiate custom controller
            ClientContactController con = new ClientContactController();
            ApexPages.StandardController stdcontroller = new ApexPages.StandardController(accBld.getRecord());
            ClientContactController cc = new ClientContactController(stdcontroller);
                
            list<ClientContactController.Wrapper> wraptestcon = con.wrap ;        
            wraptestcon[0].ischeck = true;
            wraptestcon[1].ischeck = true; 

            con.SaveRecord();
            con.KCCData();
        
            cc.KCCData();

            ClientContactController.Wrapper w = new ClientContactController.Wrapper((Contact) conBuilders[0].getRecord());
            system.assertEquals(w.ischeck,false);
            w.ischeck = true;
            system.assertEquals(w.ischeck,true);
        
            con.getContactKeyCCmap();
            con.AddContacts();
            con.SaveRecord();
        }        
        Test.stopTest();
        
    }
    
    /**********************************************************
    Scenario - Test for edit and delete Scenarios.
    **********************************************************/
    
    static testMethod void test_for_edit_and_delete_scenarios () {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User testUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User testUserKCC1 = (User) new BLD_USER(uow).useCib().division(DMN_User.GM_DIVISION).getRecord();
        User testUserKCC2 = (User) new BLD_USER(uow).useCib().division(DMN_User.CLIENT_COVERAGE_DIVISION).getRecord();
        User testUserKCC3 = (User) new BLD_USER(uow).useCib().division(DMN_User.IB_DIVISION).getRecord();
        User testUserKCC4 = (User) new BLD_USER(uow).useCib().division(DMN_User.TPS_DIVISION).getRecord();
        User testUserKCC5 = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }

        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getErrorMessages(),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getCstTeamRankings()
        });

        BLD_Account accBld = new BLD_Account(uow).useChild()
            .addClientTeam(new BLD_ClientTeam(uow).user(testUserKCC1.Id).role(DMN_ClientTeam.ROLE_TPS_CHAMPION))
            .addClientTeam(new BLD_ClientTeam(uow).user(testUserKCC2.Id).role(DMN_ClientTeam.ROLE_TRADER))
            .addClientTeam(new BLD_ClientTeam(uow).user(testUserKCC3.Id).role(DMN_ClientTeam.ROLE_ADVISORY_BANKER));

        List<BLD_Contact> conBuilders = new List<BLD_Contact>();
        List<BLD_KeyClientContact> kccBuilders = new List<BLD_KeyClientContact>();
        for (Integer i = 0; i < 5; i++) {
            conBuilders.add(new BLD_Contact(uow).useClientContact()
                .account(accBld)
            );
            kccBuilders.add(new BLD_KeyClientContact(uow)
                .client(accBld)
                .contact(conBuilders[i])
            );
        }

        new BLD_ClientPlan(uow).account(accBld);

        new BLD_ContactTeamMember(uow).contact(conBuilders[0]).user(testUserKCC1.Id);
        new BLD_ContactTeamMember(uow).contact(conBuilders[0]).user(testUserKCC2.Id);
        new BLD_ContactTeamMember(uow).contact(conBuilders[0]).user(testUserKCC3.Id);
        new BLD_ContactTeamMember(uow).contact(conBuilders[0]).user(testUserKCC4.Id);
        new BLD_ContactTeamMember(uow).contact(conBuilders[0]).user(testUserKCC5.Id);

        uow.commitWork();

        Test.startTest();
        System.runAs(TestUser){
            PageReference pageRef = Page.ClientPlan; 
            Test.setCurrentPage(pageRef);        
            ApexPages.currentPage().getParameters().put('id', accBld.getRecordId());
        
            //Instantiate custom controller
            ClientContactController con = new ClientContactController();        
            ApexPages.StandardController stdcontroller = new ApexPages.StandardController((Contact) conBuilders[0].getRecord());
            ClientContactController cc = new ClientContactController(stdcontroller);
                
            list<ClientContactController.DeleteWrapper> deletewraptestcon = con.Delete_Wrap ;        
            deletewraptestcon[0].ischeck = true;
            deletewraptestcon[1].ischeck = true; 

            ClientContactController.DeleteWrapper dw = new ClientContactController.DeleteWrapper((Key_Client_Contact__c) kccBuilders[0].getRecord());
            system.assertEquals(dw.ischeck,false);
            dw.ischeck = true;
            system.assertEquals(dw.ischeck,true);
        
            con.EditContacts();
            con.CancelPop();
            con.deleteKCC();                            
        }        
        Test.stopTest();
        
    }
}