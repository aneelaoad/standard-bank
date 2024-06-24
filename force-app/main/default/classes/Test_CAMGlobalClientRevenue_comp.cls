/*****************************************************************************************************
    @ Func Area     : Client Plan
    @ Author        : Nitish Kumar
    @ Date          :  24/02/2014
    @description   :Test Class for CAMGlobalClientRevenue_comp class

    @ Last Modified By  : Petr Svestka 
    @ Last Modified On  : Aug 11, 2015
    @ Modification Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Sep 4, 2015
    @ Modification Description : Using a single Opportunity record to avoid the CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY error
                                 Limited the scope of the runAs() block to avoid failing test (sharing)
                                 
    @ Last Modified By:     Abhishek Vaideeswaran
    @ Last Modified On:     February 2016
    @ Last Modified Reason: EN - 686 : Assigned CIF__c number to all clients for which GCR records are created
    
******************************************************************************************************/
@isTest
public  class Test_CAMGlobalClientRevenue_comp {
    
    @IsTest
    static void testClientRevenueComp(){

        User cibUser = (User) new BLD_USER().useCib().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())){
        	insert cibUser;
            insert TEST_DataFactory.getCcSettings();
        }

        BLD_Account accBld;

        System.runAs(cibUser) {
            accBld = (BLD_Account) new BLD_Account().usePbb()
                .CIF('12341')
                .commitWork();
        }

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        new BLD_Opportunity(uow)
            .client(accBld)
            .stage(DMN_Opportunity.ST_LEAD);

        new BLD_ShareWallet(uow)
            .client(accBld);

        new BLD_Contact(uow).useClientContact()
            .account(accBld);

        new BLD_GlobalClientRevenue(uow).client(accBld).tradingDivision(DMN_GlobalClientRevenue.TRADING_DIVISION_GLOBAL_MARKET)
            .snapshotDate(Date.today())
            .reportingCountry(DMN_GlobalClientRevenue.REPORTING_COUNTRY_SA).clientValueZarCurrentYear(1000000).clientValueZarPreviousYear(1000000);
        new BLD_GlobalClientRevenue(uow).client(accBld).tradingDivision(DMN_GlobalClientRevenue.TRADING_DIVISION_INVESTMENT_BANKING)
            .reportingCountry(DMN_GlobalClientRevenue.REPORTING_COUNTRY_SA).clientValueZarCurrentYear(1000000).clientValueZarPreviousYear(1000000);
        new BLD_GlobalClientRevenue(uow).client(accBld).tradingDivision(DMN_GlobalClientRevenue.TRADING_DIVISION_RANSACTIONAL_PRODUCTS_AND_SERVICES)
            .reportingCountry(DMN_GlobalClientRevenue.REPORTING_COUNTRY_SA).clientValueZarCurrentYear(1000000).clientValueZarPreviousYear(1000000);
        new BLD_GlobalClientRevenue(uow).client(accBld).tradingDivision(DMN_GlobalClientRevenue.TRADING_DIVISION_OTHER)
            .reportingCountry(DMN_GlobalClientRevenue.REPORTING_COUNTRY_SA).clientValueZarCurrentYear(1000000).clientValueZarPreviousYear(1000000);
        uow.commitWork();

        Test.startTest();
        try {
            CAMGlobalClientRevenue_comp testGlobalRevenue = new CAMGlobalClientRevenue_comp();
            testGlobalRevenue.overviewClientId = accBld.getRecordId();
            MAP<String,CAMGlobalClientRevenue_comp.globalClientRevenueCountry> testMAP = testGlobalRevenue.globalClientRevenue;
            List<CAMGlobalClientRevenue_comp.globalClientRevenueCountry> testglobalClientRevenueCountry = new List <CAMGlobalClientRevenue_comp.globalClientRevenueCountry>();

            CAMGlobalClientRevenue_comp.globalClientRevenueCountry  testItem = new CAMGlobalClientRevenue_comp.globalClientRevenueCountry();
            testItem.totalTPSCurrentYearUSD  = 210;
            testItem.totalTPSCurrentYearZAR  = 210;
            testItem.totalTPSPreviousYearUSD = 210;
            testItem.totalTPSPreviousYearZAR = 210;
            testItem.totalIBCurrentYearUSD  = 210;
            testItem.totalIBCurrentYearZAR  = 210;
            testItem.totalIBPreviousYearUSD = 210;
            testItem.totalIBPreviousYearZAR = 210;
            testItem.totalOtherCurrentYearUSD = 210;
            testItem.totalOtherCurrentYearZAR = 210;
            testItem.totalOtherPreviousYearUSD = 210;
            testItem.totalOtherPreviousYearZAR = 210;
            testItem.totalGMCurrentYearUSD  = 210;
            testItem.totalGMCurrentYearZAR  = 210;
            testItem.totalGMPreviousYearUSD = 210;
            testItem.totalGMPreviousYearZAR = 210;
            testItem.totalBudgetZAR  = 10;
            testItem.totalBudgetUSD  = 10;
            testItem.reportingCountryName = 'SA';
            testItem.globalClientRevenueCountry();
            testglobalClientRevenueCountry.add(testItem);

            CAMGlobalClientRevenue_comp.globalClientRevenueCountry  testItem2 = new CAMGlobalClientRevenue_comp.globalClientRevenueCountry();
            testItem2.totalTPSCurrentYearUSD  = 110;
            testItem2.totalTPSCurrentYearZAR  = 110;
            testItem2.totalTPSPreviousYearUSD = 110;
            testItem2.totalTPSPreviousYearZAR = 110;
            testItem2.totalIBCurrentYearUSD  = 110;
            testItem2.totalIBCurrentYearZAR  = 110;
            testItem2.totalIBPreviousYearUSD = 110;
            testItem2.totalIBPreviousYearZAR = 110;
            testItem2.totalOtherCurrentYearUSD = 110;
            testItem2.totalOtherCurrentYearZAR = 110;
            testItem2.totalOtherPreviousYearUSD = 110;
            testItem2.totalOtherPreviousYearZAR = 110;
            testItem2.totalGMCurrentYearUSD  = 110;
            testItem2.totalGMCurrentYearZAR  = 110;
            testItem2.totalGMPreviousYearUSD = 110;
            testItem2.totalGMPreviousYearZAR = 110;
            testItem2.totalBudgetZAR  = 110;
            testItem2.totalBudgetUSD  = 110;
            testItem2.reportingCountryName = 'USA';
            testItem2.globalClientRevenueCountry();
            testglobalClientRevenueCountry.add(testItem2);

            testglobalClientRevenueCountry.sort();

            Decimal testTotalCountryCYZAR = testGlobalRevenue.totalCountryCurrentYearZAR;
            Decimal testTotalCountryPYZAR = testGlobalRevenue.totalCountryPreviousYearZAR;
            Decimal testTotalCountryCYUSD = testGlobalRevenue.totalCountryCurrentYearUSD;
            Decimal testTotalCountryPYUSD = testGlobalRevenue.totalCountryPreviousYearUSD;
            Date testSnapShotDate = testGlobalRevenue.snapshotDate;

            Decimal testTotalCountryCY2ZAR = testItem2.totalCountryCurrentYearZAR;
            Decimal testTotalCountryPY2ZAR = testItem2.totalCountryPreviousYearZAR;
            Decimal testTotalCountryCY2USD = testItem2.totalCountryCurrentYearUSD;
            Decimal testTotalCountryPY2USD = testItem2.totalCountryPreviousYearUSD;

            ApexPages.StandardController controller = new ApexPages.StandardController(accBld.getRecord());
            CAMGlobalClientRevenue_comp testRevenue = new CAMGlobalClientRevenue_comp(controller);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
  }
}