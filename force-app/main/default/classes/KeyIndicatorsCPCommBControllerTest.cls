/*************************************************************************
    @ Author        : psvestka
    @ Date          : 11. 1. 2016
    @ Description   : EN-927
****************************************************************************/

@IsTest
private class KeyIndicatorsCPCommBControllerTest {
    private static Map<String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    private final static Id ugpRecTypeId = mapAccountRecordTypes.get('Ultimate Group Parent').getRecordTypeId();

    @TestSetup
    private static void prepareData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getErrorMessages()
        });
        User userCC;

        System.runas(new User(Id = UserInfo.getUserId())) {
            userCC = createUser(DCN_Profile.CUSTOM_STD_MOBILE, 'user_test0041_cc@testorg.com');
            insert userCC;
        }

        Account acc = createAccount();
        acc.client_Co_ordinator__c = userCC.id;

        system.runAs(userCC) {
            insert acc;
        }
    }

    private static user createUser(string profile, string username) {
        String randomString = ''+Math.random();
		username = randomString+ username;
        user newUser;
        try {
            Profile userProfile = [select Name from Profile where Name = : profile];
            newUser = new User(alias = randomString.substring(0,7),
                    email = 'one@testorg.com',
                    emailencodingkey = 'UTF-8',
                    lastname = profile + ' User',
                    languagelocalekey = 'en_US',
                    city = 'Smallville',
                    User_Division__c = 'Client Coverage',
                    Business_Unit__c = 'Client Coverage',
                    User_CIB_Global_Area__c = 'CIBSA',
                    country = 'South Africa',
                    //UserRoleId=dcmCdrMgtRoleId,
                    State = 'Test State',
                    RecieveBirthdayReminderTasks__c = true,
                    Sync_with_Contact__c = false,
                    localesidkey = 'en_US',
                    profileid = userProfile.Id,
                    timezonesidkey = 'Africa/Johannesburg',
                    username = username,
                    currencyIsoCode = 'ZAR',
                    ManagerId = [Select Id from User Where Name = 'Salesforce Administration'].Id);
        } Catch(Exception e) {
            system.assertEquals('List has no rows for assignment to SObject', e.getMessage());
        }
        return newUser;
    }

    private static Account createAccount() {
        Account acc = new Account();
        acc.RecordTypeId = ugpRecTypeId;
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

    private static Revenue_and_Profitability__c createRP(Account acc) {
        if (acc == null || acc.id == null || acc.name == null) {
            return new Revenue_and_Profitability__c();
        }

        Revenue_and_Profitability__c rp = new Revenue_and_Profitability__c();
        rp.client_name__c = acc.id;
        rp.roe__c = 25.0;
        rp.pmt_extract_date__c = Date.newInstance(2015, 1, 1); // Jan 1, 2015
        rp.operating_income__c = 10000.0;
        rp.non_interest_revenue__c = 10000.0;
        rp.net_interest_income__c = 10000.0;
        rp.headline_earnings__c = 10000.0;
        rp.cost__c = 33.0;
        rp.currencyIsoCode = 'ZAR';

        return rp;
    }

    //--------

    static testMethod void testHappyDay() {
        Account acc = [SELECT id, name, client_Co_ordinator__c  FROM Account WHERE name = 'Test Client' LIMIT 1];
        User userCC = new User(id = acc.client_Co_ordinator__c);

        Test.startTest();

        Revenue_and_Profitability__c rp = createRP(acc); // Jan 1, 2015
        insert rp;
        system.assert(rp.id != null);

        Test.stopTest();

        system.runAs(userCC) {

            PageReference pageRef = Page.ClientPlanCommB;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', acc.id);

            KeyIndicatorsCPCommBController con = new KeyIndicatorsCPCommBController();
            con.clientId = acc.id;
            con.currencyIsoCode = 'ZAR';

            // check date
            system.assertEquals(Date.newInstance(2015, 1, 1), con.pmtExtractDate);

            // check values
            system.assertEquals(25.0, con.pfa.roe);
            system.assertEquals(10000.0, Math.round(con.pfa.operatingIncome));
            system.assertEquals(10000.0, Math.round(con.pfa.nonInterestRevenue));
            system.assertEquals(10000.0, Math.round(con.pfa.netInterestIncome));
            system.assertEquals(10000.0, Math.round(con.pfa.headlineEarnings));
            system.assertEquals(33.0, con.pfa.cost);
        }
    }

    static testMethod void testNoRP() {
        Account acc = [SELECT id, name, client_Co_ordinator__c  FROM Account WHERE name = 'Test Client' LIMIT 1];
        User userCC = new User(id = acc.client_Co_ordinator__c);

        // no Revenue_and_Profitability__c is created

        system.runAs(userCC) {

            PageReference pageRef = Page.ClientPlanCommB;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', acc.id);

            KeyIndicatorsCPCommBController con = new KeyIndicatorsCPCommBController();
            con.clientId = acc.id;
            con.currencyIsoCode = 'ZAR';

            // check date
            system.assertEquals(null, con.pmtExtractDate);

            // check values
            system.assertEquals(0.0, con.pfa.roe);
            system.assertEquals(0.0, con.pfa.operatingIncome);
            system.assertEquals(0.0, con.pfa.nonInterestRevenue);
            system.assertEquals(0.0, con.pfa.netInterestIncome);
            system.assertEquals(0.0, con.pfa.headlineEarnings);
            system.assertEquals(0.0, con.pfa.cost);
        }
    }

    static testMethod void testMultipleRPs() {
        Account acc = [SELECT id, name, client_Co_ordinator__c  FROM Account WHERE name = 'Test Client' LIMIT 1];
        User userCC = new User(id = acc.client_Co_ordinator__c);

        Test.startTest();

        Revenue_and_Profitability__c rp1 = createRP(acc); // Jan 1, 2015
        insert rp1;
        system.assert(rp1.id != null);

        Revenue_and_Profitability__c rp2 = createRP(acc);
        rp2.pmt_extract_date__c = Date.newInstance(2015, 2, 1); // Feb 1, 2015
        insert rp2;
        system.assert(rp2.id != null);

        Test.stopTest();

        system.runAs(userCC) {

            PageReference pageRef = Page.ClientPlanCommB;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', acc.id);

            KeyIndicatorsCPCommBController con = new KeyIndicatorsCPCommBController();
            con.clientId = acc.id;
            con.currencyIsoCode = 'ZAR';

            // check date
            system.assertEquals(Date.newInstance(2015, 1, 1), con.pmtExtractDate);

            // check values: if more values exist, the latest should be returned
            system.assertEquals(rp2.roe__c, con.pfa.roe);
            system.assertEquals(rp2.operating_income__c, con.pfa.operatingIncome);
            system.assertEquals(rp2.non_interest_revenue__c, con.pfa.nonInterestRevenue);
            system.assertEquals(rp2.net_interest_income__c, con.pfa.netInterestIncome);
        }
    }
}