/*************************************************************************
    @ Author:       Abhishek V
    @ Date:         1 Sep 2016
    @ Description:  US-1425: Provide search facilities for look-ups
    
    @ Last Modified : Abhishek V
    @ Date          : 08 Dec 2016
    @description   : Introduced new test method to test Campign lookup functionality

    @author:        Dzianisik Maksim
    @date:          April 2023
    @description:   SFP-9010 Deleted checking for "OpportunityCloseRedirect_SF1_Ext controller" constructor as part of decommissioning story

*************************************************************************/
@IsTest
private class NewOppLookupsSupportTest{
   
    private final static String USER_LAST_NAME = 'us1247';

    @TestSetup
    static void prepareData() {

        Account ugpBangAcc = TEST_DataFactory.stdBankEmpAcc;

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow).useGroupParent()
            .name('TestAccountLookup')
            .addContact(
                new BLD_Contact(uow)
            )
            .addOpportunity(
                new BLD_Opportunity(uow)
                    .name('TestOpptyLookup')
            );

        uow.commitWork();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            new BLD_USER().useCib()
                .lastName(USER_LAST_NAME)
                .commitWork();
        }
         
        new BLD_Contact(uow).useBankContact()
            .accountId(ugpBangAcc.Id);

        new BLD_Campaign(uow)
            .name('Test Camp')
            .active(true);

        uow.commitWork();
    }
    
    @IsTest
    static void testAccountLookup() {
        List<Account> foundAccounts = NewOppLookupsSupport.queryAccounts('Standard Bank Employees');
        system.assertEquals(1, foundAccounts.size(), 'One Account record was expected');
        
        List<Account> result = NewOppLookupsSupport.queryAccounts('');
        system.assertEquals(0, result.size(), 'No Account record was expected');
    }
    
    @IsTest
    static void testOpportunityLookup() {
        List<Opportunity> foundOpps = NewOppLookupsSupport.queryOpps('TestOpptyLookup');
        system.assertEquals(1, foundOpps.size(), 'One Oppty record was expected');
        
        List<Opportunity> result = NewOppLookupsSupport.queryOpps('');
        system.assertEquals(0, result.size(), 'No Opportunity record was expected');
    }
    
    @IsTest
    static void testUserLookup() {
        List<User> foundUsers = NewOppLookupsSupport.queryUsers(USER_LAST_NAME);
        system.assertEquals(1, foundUsers.size(), 'One User record was expected');
        
        List<User> result = NewOppLookupsSupport.queryUsers('');
        system.assertEquals(0, result.size(), 'No User record was expected');
    }
    
    @IsTest
    static void testContactLookup() {
        List<Contact> foundContacts = NewOppLookupsSupport.queryintcontact('testcontact');
        system.assertEquals(1, foundContacts.size(), 'One Contact record was expected');
        
        List<Contact> result = NewOppLookupsSupport.queryintcontact('');
        system.assertEquals(0, result.size(), 'No Contact record was expected');
        
        foundContacts = NewOppLookupsSupport.queryextcontact('testcontact');
        system.assertEquals(1, foundContacts.size(), 'One Contact record was expected');
        
        result = NewOppLookupsSupport.queryextcontact('');
        system.assertEquals(0, result.size(), 'No Contact record was expected');
    }
    
    @IsTest
    static void testCampaignLookup() {
        List<Campaign> foundCampaign = NewOppLookupsSupport.querycamp('Test Camp');
        system.assertEquals(1, foundCampaign.size());

        List<Campaign> result = NewOppLookupsSupport.querycamp('');
        system.assertEquals(0, result.size());
    }
    
    @IsTest
    static void testForCoverage() {
        Account ugpAcc = [Select ID from Account where Name = 'Standard Bank Employees'];
        Opportunity opp = [Select Id from Opportunity where Name = 'TestOpptyLookup'];

        try {
            ApexPages.StandardController sc = new ApexPages.StandardController(new Opportunity());
            new NewOppLookupsSupport(new ApexPages.StandardController(ugpAcc));
            new NewOppLookupsSupport(new Opprtunity_New_LDS_ctrl(sc));
            new NewOppLookupsSupport(new oppTeamCreationController(sc));
            new NewOppLookupsSupport(new LDS_TaskCtrl());
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
}