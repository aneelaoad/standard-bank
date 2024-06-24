/*************************************************************************\
    @ Author        :     Petr Roubal
    @ Date          :     17 Apr 2016
    @ Description   :     Test Class for Game Changer anf Opportunity Updates.
    
    @Last ModifiedBy : Manoj Gupta
    @Date            : 28 June 2016
    @Description     : Test Class updated for US:1391
*************************************************************************/

@IsTest(SeeAllData=false)
private class GameChanger_Test {

    private static Map<String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    private final static Id childRecTypeId = mapAccountRecordTypes.get('Child').getRecordTypeId();

    private static Account createChildAccount() {
        Account acc = new Account();
        acc.RecordTypeId = childRecTypeId;
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
        acc.CIF_Client_Active_Code__c = 'A';

        return acc;
    }


    private static Opportunity getOpportunity(Account client) {

        Opportunity opp = new Opportunity();
        opp.AccountId=client.Id;
        opp.Name= 'Opportunity_'+ client.Name;
        opp.CloseDate=System.today();
        opp.StageName='1 - Lead';
        opp.Short_Summary__c = 'test opportunity';
        opp.CurrencyIsoCode = 'ZAR';

        return opp;

    }

    private static SB_Product__c getProduct(Opportunity opp){

        SB_Product__c prod = new SB_Product__c();
        prod.Opportunity__c = opp.id;
        prod.Grand_Parent_Product__c = 'Advisory Fees';
        prod.SA_Current_known_conflict_of_interest__c = 'test';
        prod.Country_of_Underlying_Risk__c = 'Belarus';
        prod.Balance_Sheet_of_Booking__c = 'Angola - Standard Bank de Angola S.A.';
        prod.Loan_Profile__c = 'Bullet Term Loan';
        prod.SB_Gross_Participation__c = 12;
        prod.Term_Tenor__c = 1;
        prod.CurrencyIsoCode = 'ZAR';
        prod.Current_Year_Fees__c = 10;
        prod.Total_Fees__c = 20;
        prod.Current_Year_CommB_Revenue__c = 10000;
        prod.total_revenue_amount__c = 10000;

        return prod;
    }


    private static Game_Changer__c getGameChanger(){
        Game_Changer__c gc = new Game_Changer__c();
        gc.Name = 'Test game Changer';
        gc.Year__c = String.valueOf(Date.today().year());
        gc.CurrencyIsoCode = 'ZAR';
        return gc;
    }

    static testMethod void testGameChanger1() {
        Game_Changer__c gc = getGameChanger();

        Account acc = createChildAccount();
        insert new List<SObject>{gc, acc};

        Opportunity opp = getOpportunity(acc);
        opp.Game_Changer__c = gc.id;
        opp.StageName='2 - Develop';
        insert opp;

        SB_Product__c prod = getProduct(opp);
        insert prod;

        gc = [SELECT Id, Clients_and_Opportunities_Identified__c,Execution__c, CurrencyIsoCode FROM Game_Changer__c WHERE Id = :gc.Id];
        opp = [SELECT Id, Current_Year_Revenue__c,Current_Year_Revenue_Currency__c, CurrencyIsoCode FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals(gc.Clients_and_Opportunities_Identified__c, opp.Current_Year_Revenue_Currency__c);
    }
    
    static testMethod void testGameChanger2() {
        Game_Changer__c gc = getGameChanger();

        Account acc = createChildAccount();
        insert new List<SObject>{gc, acc};

        Opportunity opp = getOpportunity(acc);
        opp.Game_Changer__c = gc.id;
        opp.StageName='2 - Develop';
        insert opp;

        SB_Product__c prod = getProduct(opp);
        insert prod;

        Test.startTest();
        opp.StageName='3 - Closed Won';
        opp.ReasonForWinLossPickList__c = 'Pricing Competitive';
        opp.Reason_Won_Lost_Detail__c = 'Pricing Competitive';
        opp.Reason_Won_Lost_Comments__c = 'Won';
        update opp;
        Test.stopTest();

        gc = [SELECT Id, Opportunity_Current_Year_Won_Revenue__c,Execution__c, CurrencyIsoCode FROM Game_Changer__c WHERE Id = :gc.Id];
        opp = [SELECT Id, Current_Year_Revenue__c,Current_Year_Revenue_Currency__c, CurrencyIsoCode FROM Opportunity WHERE Id = :opp.Id];

        // 2
        System.assertEquals(opp.Current_Year_Revenue_Currency__c, gc.Opportunity_Current_Year_Won_Revenue__c);
        System.assertEquals(gc.Execution__c, opp.Current_Year_Revenue_Currency__c);
    }

    static testMethod void testGameChanger3() {
        Game_Changer__c gc = getGameChanger();

        Account acc = createChildAccount();
        insert new List<SObject>{gc, acc};

        Opportunity opp = getOpportunity(acc);
        opp.Game_Changer__c = gc.id;
        opp.StageName='2 - Develop';
        insert opp;

        SB_Product__c prod = getProduct(opp);
        insert prod;


        opp.StageName='3 - Closed Won';
        opp.ReasonForWinLossPickList__c = 'Pricing Competitive';
        opp.Reason_Won_Lost_Detail__c = 'Pricing Competitive';
        opp.Reason_Won_Lost_Comments__c = 'Won';
        update opp;


        Opportunity opp3 = getOpportunity(acc);
        opp3.Game_Changer__c = gc.id;
        opp3.StageName='2 - Develop';
        insert opp3;

        SB_Product__c prod1 = getProduct(opp3);
        insert prod1;

        Test.startTest();
        opp3.StageName='3 - Closed Won';
        opp3.ReasonForWinLossPickList__c = 'Pricing Competitive';
        opp3.Reason_Won_Lost_Detail__c = 'Pricing Competitive';
        opp3.Reason_Won_Lost_Comments__c = 'Won';
        update opp3;

        delete opp3;
        gc = [SELECT Id, Opportunity_Current_Year_Won_Revenue__c,Execution__c, CurrencyIsoCode FROM Game_Changer__c WHERE Id = :gc.Id];
        opp = [SELECT Id, Current_Year_Revenue__c,Current_Year_Revenue_Currency__c, CurrencyIsoCode FROM Opportunity WHERE Id = :opp.Id];

        Test.stopTest();

        // 3
        System.assertEquals(opp.Current_Year_Revenue_Currency__c, gc.Opportunity_Current_Year_Won_Revenue__c);
        System.assertEquals(gc.Execution__c, opp.Current_Year_Revenue_Currency__c);
    }

    static testMethod void testGameChanger4() {

        Game_Changer__c gc = getGameChanger();

        Account acc = createChildAccount();
        insert new List<SObject>{gc, acc};

        Opportunity opp = getOpportunity(acc);
        opp.Game_Changer__c = gc.id;
        opp.StageName='2 - Develop';
        insert opp;

        SB_Product__c prod = getProduct(opp);
        insert prod;


        opp.StageName='3 - Closed Won';
        opp.ReasonForWinLossPickList__c = 'Pricing Competitive';
        opp.Reason_Won_Lost_Detail__c = 'Pricing Competitive';
        opp.Reason_Won_Lost_Comments__c = 'Won';
        update opp;

        Test.startTest();
        delete opp;
        Test.stopTest();

        gc = [SELECT Id, Opportunity_Current_Year_Won_Revenue__c,Execution__c,Clients_and_Opportunities_Identified__c, CurrencyIsoCode FROM Game_Changer__c WHERE Id = :gc.Id];

        // 4
        System.assertEquals(gc.Opportunity_Current_Year_Won_Revenue__c,0);
        System.assertEquals(gc.Clients_and_Opportunities_Identified__c,0);
        System.assertEquals(gc.Execution__c,0);
    }

}