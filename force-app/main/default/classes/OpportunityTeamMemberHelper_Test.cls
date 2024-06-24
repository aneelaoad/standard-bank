/*****************************************************************************************************\
    @ Author        : Petr Roubal
    @ Date          :  January 2016
    @description   : Test class for OpportunityTeamMemberHelper and OpportunityTeamMemberTrigger
 ******************************************************************************************************/

@IsTest(seeAllData=false)
private class OpportunityTeamMemberHelper_Test {

    private static Map<String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    private final static Id UGP_REC_TYPE_ID  = mapAccountRecordTypes.get('Ultimate Group Parent').getRecordTypeId();
    @TestSetup
    private static void prepareData() {
            CST_Allowed_Combinations__c cstAllowedCombinations = new CST_Allowed_Combinations__c(
                Name = 'OTM CommB',
                Opportunity_Team_Roles__c = 'BCC Portfolio Manager\nBCC Product Specialist\nBCC Service Manager\nBCC Relationship Manager\nBCC Business Development Manager\nOriginator - Primary\nBCC CSU Agent\nBCC CSU Manager',
                Unique_Team_Roles__c = DMN_ClientTeam.ROLE_COMMB_RELATION_MANGER,
                User_Global_Area__c = DMN_User.CIB_GA_COMMB
            );
        	insert cstAllowedCombinations;
    }
    static testMethod void testTriggerFuncionality() {
        // create user with CommB
        List<User> users = new List<User>();
        User userCC = createUser(DCN_Profile.CUSTOM_STD_MOBILE, 'user_test0041_cc@testorg.com');
        userCC.User_CIB_Global_Area__c = 'BCC';
        userCC.user_division__c = 'Commercial Banking';
        users.add(userCC);

        userCC = createUser(DCN_Profile.CUSTOM_STD_MOBILE, 'user_test0041_cc@testorg.com');
        userCC.User_CIB_Global_Area__c = 'CIBSA';
        users.add(userCC);

        insert users;

        Account acc;
        Opportunity opp;
        system.runas(users[0]){
            acc = CreateAccount();
            insert acc;

            opp = new Opportunity();
            opp.AccountId= acc.Id;
            opp.Name= 'Opportunity_'+ acc.Name;
            opp.CloseDate=System.today();
            opp.StageName='2 - Develop';
            opp.Short_Summary__c = 'test opportunity';
            opp.CurrencyIsoCode = 'ZAR';

            insert opp;
        }
        OpportunityTeamMember otm = [Select Id, TeamMemberRole, UserId from OpportunityTeamMember where OpportunityId = :opp.Id ];
		otm.TeammemberRole = DMN_ClientTeam.ROLE_COMMB_RELATION_MANGER;
        update otm;
        system.assertEquals(users[0].id,otm.UserId);
        system.assertEquals(otm.TeammemberRole, DMN_ClientTeam.ROLE_COMMB_RELATION_MANGER);

        system.runas(users[1]){
            acc = CreateAccount();
            acc.Name = '2nd Test Client';
            acc.CIF__c = '4321';
            insert acc;

            opp = new Opportunity();
            opp.AccountId= acc.Id;
            opp.Name= 'Opportunity_'+ acc.Name;
            opp.CloseDate=System.today();
            opp.StageName='2 - Develop';
            opp.Short_Summary__c = 'test opportunity';
            opp.CurrencyIsoCode = 'ZAR';

            insert opp;
        }

        otm = [Select Id, TeamMemberRole, UserId from OpportunityTeamMember where OpportunityId = :opp.Id ];
		otm.TeammemberRole = DMN_ClientTeam.ROLE_BUSINESS;
        update otm;
        system.assertEquals(users[1].id,otm.UserId);
        system.assertEquals(otm.TeammemberRole, DMN_ClientTeam.ROLE_BUSINESS);

    }

    private static user createUser(string profile, string username) {
        username = Math.random()+ username;
        user newUser;
        try {
            Profile userProfile = [select Name from Profile where Name = : profile];
            newUser = new User(alias = String.valueOf(Math.random()).substring(0,7),
                    email = 'one@testorg.com',
                    emailencodingkey = 'UTF-8',
                    lastname = profile + ' User',
                    languagelocalekey = 'en_US',
                    city = 'Smallville',
                    User_Division__c = 'Client Coverage',
                    Business_Unit__c = 'Client Coverage',
                    User_CIB_Global_Area__c = 'BCC',
                    country = 'South Africa',
                    State = 'Test State',
                    RecieveBirthdayReminderTasks__c = true,
                    Sync_with_Contact__c = false,
                    localesidkey = 'en_US',
                    profileid = userProfile.Id,
                    timezonesidkey = 'Africa/Johannesburg',
                    username = username,
                    ManagerId = [Select Id from User Where Name = 'Salesforce Administration'].Id);
        } Catch(Exception e) {
            system.assertEquals('List has no rows for assignment to SObject', e.getMessage());
        }
        return newUser;
    }

    private static Account createAccount() {
        Account acc = new Account();
        acc.RecordTypeId = UGP_REC_TYPE_ID;
        acc.CRT_Parent_Child__c = 'TP';
        acc.Name = 'Test Client';
        acc.BillingStreet = 'Test street';
        acc.Client_Sector__c = 'Unknown Sector';
        acc.Client_Sub_Sector__c = 'Unknown Sub-Sector';
        acc.Client_Segment__c = 'AB';
        acc.Country_Risk__c = 'India';
        acc.Correspondence_Addr_Line1__c = 'Test Street Line 1';
        acc.Correspondence_City__c = 'City';
        acc.Correspondence_Postal_Code__c = '123456';
        acc.Correspondence_Country__c = 'India';
        acc.BillingCountry = 'South Africa';
        acc.BillingCity = 'Durban';

        acc.CIF__c = '1234';

        return acc;
    }



}