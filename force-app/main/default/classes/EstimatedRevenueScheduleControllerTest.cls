/**
 * Created by khonology on 26/07/2018.
 */
@isTest
private class EstimatedRevenueScheduleControllerTest {

    @isTest static void testfetchLimitedSchedule(){

        Account acc1 = new Account(name='Test Fetch Limited Schedule');
        insert acc1;

        Opportunity opp = new Opportunity(AccountId = acc1.id, Name = 'Test Fetch Limited Schedule',LeadSource='Client Plan',
                Is_Opportunity_part_of_Client_Budget__c='No',Description='This is a description in testing',
                StageName='2 - Develop',Start_Date__c=Date.today(),Probability=10,CloseDate=Date.today()+7,
                CurrencyIsoCode='ZAR');
        insert opp;

        SB_Product__c prod = new SB_Product__c(Opportunity__c=opp.id,Grand_Parent_Product__c='Advisory Fees',Product_Division__c='Investment Banking',
                Country_of_Underlying_Risk__c='Belgium',Balance_Sheet_of_Booking__c='South Africa - The Standard Bank of South Africa Limited',
                Billing_Start_Date__c=Date.today(),Billing_End_Date__c=Date.today()+180,Fee_Amount__c=150,
                Fee_Frequency__c='Monthly',Risk_Weighted_Value__c=10);
        insert prod;

        List<Estimated_Revenue_Schedule__c> ersList = [select id, Name, Fee_Amount__c, Estimated_Revenue_Date__c, Product__c, Risk_Weighted_Value__c, Show_Estimated_Revenue_Schedule__c
        from Estimated_Revenue_Schedule__c
        where Product__c =: prod.Id LIMIT 3];
        List<Estimated_Revenue_Schedule__c> ersListTest = EstimatedRevenueScheduleController.fetchLimitedSchedule(prod.id,3);
        system.assertEquals(ersListTest.size(),ersList.size());
    }

    @isTest static void testfetchSchedule(){
        Account acc1 = new Account(name='Test Fetch Limited Schedule');
        insert acc1;
        Opportunity opp = new Opportunity(AccountId = acc1.id, Name = 'Test Fetch Schedule',LeadSource='Client Plan',
                Is_Opportunity_part_of_Client_Budget__c='No',Description='This is a description in testing',
                StageName='2 - Develop',Start_Date__c=Date.today(),Probability=10,CloseDate=Date.today()+7,
                CurrencyIsoCode='ZAR');
        insert opp;

        SB_Product__c prod = new SB_Product__c(Opportunity__c=opp.id,Grand_Parent_Product__c='Advisory Fees',Product_Division__c='Investment Banking',
                Country_of_Underlying_Risk__c='Belgium',Balance_Sheet_of_Booking__c='South Africa - The Standard Bank of South Africa Limited',
                Billing_Start_Date__c=Date.today(),Billing_End_Date__c=Date.today()+180,Fee_Amount__c=150,
                Fee_Frequency__c='Monthly',Risk_Weighted_Value__c=10);
        insert prod;

        List<Estimated_Revenue_Schedule__c> ersList = [select id, Name, Fee_Amount__c, Estimated_Revenue_Date__c, Product__c, Risk_Weighted_Value__c, Show_Estimated_Revenue_Schedule__c
        from Estimated_Revenue_Schedule__c
        where Product__c =: prod.Id ];
        List<Estimated_Revenue_Schedule__c> ersListTest = EstimatedRevenueScheduleController.fetchSchedule(prod.id);
        system.assertEquals(ersListTest.size(),ersList.size());
    }

    @isTest static void testgetCurrentYearFees(){
        Account acc1 = new Account(name='Test Get Current Year Fees');
        insert acc1;

        Opportunity opp = new Opportunity(AccountId = acc1.id, Name = 'Test Get Current Year Fees',LeadSource='Client Plan',
                Is_Opportunity_part_of_Client_Budget__c='No',Description='This is a description in testing',
                StageName='2 - Develop',Start_Date__c=Date.today(),Probability=10,CloseDate=Date.today()+7,
                CurrencyIsoCode='ZAR');
        insert opp;

        SB_Product__c prod = new SB_Product__c(Opportunity__c=opp.id,Grand_Parent_Product__c='Advisory Fees',Product_Division__c='Investment Banking',
                Country_of_Underlying_Risk__c='Belgium',Balance_Sheet_of_Booking__c='South Africa - The Standard Bank of South Africa Limited',
                Billing_Start_Date__c=Date.today(),Billing_End_Date__c=Date.today()+100,Fee_Amount__c=150,
                Fee_Frequency__c='Monthly',Risk_Weighted_Value__c=10);
        insert prod;

        double fees = 0;
        integer currentYear = System.today().Year();
        List<Estimated_Revenue_Schedule__c> ersList = [select Fee_Amount__c, Estimated_Revenue_Date__c
        from Estimated_Revenue_Schedule__c
        where Product__c =: prod.Id and CALENDAR_YEAR(Estimated_Revenue_Date__c) =: currentYear ];
        for (Estimated_Revenue_Schedule__c sch: ersList) {
            fees = fees + sch.Fee_Amount__c;
        }
        Double currentYearFeesTest = EstimatedRevenueScheduleController.getCurrentYearFees(prod.id);
        system.assertEquals(currentYearFeesTest,fees);
    }

    @isTest static void testgetTotalFees(){
        Account acc1 = new Account(name='Test Get Total Fees');
        insert acc1;

        Opportunity opp = new Opportunity(AccountId = acc1.id, Name = 'Test Get Total Fees',LeadSource='Client Plan',
                Is_Opportunity_part_of_Client_Budget__c='No',Description='This is a description in testing',
                StageName='2 - Develop',Start_Date__c=Date.today(),Probability=10,CloseDate=Date.today()+7,
                CurrencyIsoCode='ZAR');
        insert opp;

        SB_Product__c prod = new SB_Product__c(Opportunity__c=opp.id,Grand_Parent_Product__c='Advisory Fees',Product_Division__c='Investment Banking',
                Country_of_Underlying_Risk__c='Belgium',Balance_Sheet_of_Booking__c='South Africa - The Standard Bank of South Africa Limited',
                Billing_Start_Date__c=Date.today(),Billing_End_Date__c=Date.today()+50,Fee_Amount__c=150,
                Fee_Frequency__c='Monthly',Risk_Weighted_Value__c=10);
        insert prod;

        double fees = 0;
        List<Estimated_Revenue_Schedule__c> ersList = [select Fee_Amount__c, Estimated_Revenue_Date__c
        from Estimated_Revenue_Schedule__c
        where Product__c =: prod.Id ];
        for (Estimated_Revenue_Schedule__c sch: ersList) {
            fees = fees + sch.Fee_Amount__c;
        }
        Double currentYearFeesTest = EstimatedRevenueScheduleController.getTotalFees(prod.id);
        system.assertEquals(currentYearFeesTest,fees);
    }

    @isTest static void testgetRiskWeightedValue(){
        Account acc1 = new Account(name='Test Get Total Fees');
        insert acc1;

        Opportunity opp = new Opportunity(AccountId = acc1.id, Name = 'Test Get Total Fees',LeadSource='Client Plan',
                Is_Opportunity_part_of_Client_Budget__c='No',Description='This is a description in testing',
                StageName='2 - Develop',Start_Date__c=Date.today(),Probability=10,CloseDate=Date.today()+7,
                CurrencyIsoCode='ZAR');
        insert opp;

        SB_Product__c prod = new SB_Product__c(Opportunity__c=opp.id,Grand_Parent_Product__c='Advisory Fees',Product_Division__c='Investment Banking',
                Country_of_Underlying_Risk__c='Belgium',Balance_Sheet_of_Booking__c='South Africa - The Standard Bank of South Africa Limited',
                Billing_Start_Date__c=Date.today(),Billing_End_Date__c=Date.today()+60,Fee_Amount__c=150,
                Fee_Frequency__c='Monthly',Risk_Weighted_Value__c=10);
        insert prod;

        Double riskWeightedValue = EstimatedRevenueScheduleController.getRiskWeightedValue(prod.id);
        system.assertEquals(riskWeightedValue,10);
    }

    @isTest static void testgetProductURL(){
        Account acc1 = new Account(name='Test Get Total Fees');
        insert acc1;

        Opportunity opp = new Opportunity(AccountId = acc1.id, Name = 'Test Get Total Fees',LeadSource='Client Plan',
                Is_Opportunity_part_of_Client_Budget__c='No',Description='This is a description in testing',
                StageName='2 - Develop',Start_Date__c=Date.today(),Probability=10,CloseDate=Date.today()+14,
                CurrencyIsoCode='ZAR');
        insert opp;

        SB_Product__c prod = new SB_Product__c(Opportunity__c=opp.id,Grand_Parent_Product__c='Advisory Fees',Product_Division__c='Investment Banking',
                Country_of_Underlying_Risk__c='Belgium',Balance_Sheet_of_Booking__c='South Africa - The Standard Bank of South Africa Limited',
                Billing_Start_Date__c=Date.today(),Billing_End_Date__c=Date.today()+90,Fee_Amount__c=150,
                Fee_Frequency__c='Monthly',Risk_Weighted_Value__c=10);
        insert prod;

        List<SB_Product__c> ersList = [select Show_SB_Product__c
        from SB_Product__c
        where id =: prod.Id];
        String pURL;
        for (SB_Product__c sch: ersList) {
            pURL = sch.Show_SB_Product__c;
        }
        string productURL = EstimatedRevenueScheduleController.getProductURL(prod.id);
        system.assertEquals(productURL,pURL);
    }

    @isTest static void testgetProductName(){
        Account acc1 = new Account(name='Test Get Total Fees');
        insert acc1;

        Opportunity opp = new Opportunity(AccountId = acc1.id, Name = 'Test Get Total Fees',LeadSource='Client Plan',
                Is_Opportunity_part_of_Client_Budget__c='No',Description='This is a description in testing',
                StageName='2 - Develop',Start_Date__c=Date.today(),Probability=10,CloseDate=Date.today()+14,
                CurrencyIsoCode='ZAR');
        insert opp;

        SB_Product__c prod = new SB_Product__c(Opportunity__c=opp.id,Grand_Parent_Product__c='Advisory Fees',Product_Division__c='Investment Banking',
                Country_of_Underlying_Risk__c='Belgium',Balance_Sheet_of_Booking__c='South Africa - The Standard Bank of South Africa Limited',
                Billing_Start_Date__c=Date.today(),Billing_End_Date__c=Date.today()+120,Fee_Amount__c=150,
                Fee_Frequency__c='Monthly',Risk_Weighted_Value__c=10);
        insert prod;

        List<SB_Product__c> ersList = [select Name
        from SB_Product__c
        where id =: prod.Id];
        String pURL;
        for (SB_Product__c sch: ersList) {
            pURL = sch.Name;
        }
        string productName = EstimatedRevenueScheduleController.getProductName(prod.id);
        system.assertEquals(productName,pURL);
    }
}