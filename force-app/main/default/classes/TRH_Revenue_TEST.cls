/**
* @description  : Trigger Handler for Revenue Trigger
* User Story : SFP-7503
*
* @author Michal Pesko (mpesko@deloittece.com)
* @date October 2021
*/
@IsTest
public with sharing class TRH_Revenue_TEST {
    @IsTest
    public static void shouldCalculateRevenuesAndBalances(){
        String CurrYear = String.valueof(System.today().year());
        String pastYear = String.valueof(System.today().addYears(-1).year());
        double currencyVal = double.valueOf(432443);
        BLD_Account bldAccount = new BLD_Account().CIF('12345');
        bldAccount.commitWork();
        BLD_GlobalClientRevenue bldGlobalClientRevenue = new BLD_GlobalClientRevenue().client(bldAccount);
        bldGlobalClientRevenue.commitWork();
        BLD_Revenue bldRevenue = new BLD_Revenue().amount(10)
                .actualRevenueZar(20)
                .actualRevenueLcy(30)
                .reportingYear(CurrYear)
                .reportingMonth(10)
            	.productDrCrIndicator('DR')
            	.reportingMonth(10)
            	.crtLocalCurrLcy('ZAR')
                .avgBalanceZar(currencyVal)
                .avgBalanceLcy(currencyVal)
                .date(Date.today())
                .client(bldAccount.getRecordId())
                .globalClient(bldGlobalClientRevenue.getRecordId());
        BLD_Revenue bldRevenue2= new BLD_Revenue().amount(10)
                .actualRevenueZar(30)
                .actualRevenueLcy(40)
                .reportingYear(pastYear)
                .reportingMonth(10)
            	.productDrCrIndicator('CR')
            	.reportingMonth(10)
            	.crtLocalCurrLcy('ZAR')
                .avgBalanceZar(currencyVal)
                .avgBalanceLcy(currencyVal)
                .date(Date.today())
                .client(bldAccount.getRecordId())
                .globalClient(bldGlobalClientRevenue.getRecordId());
        Test.startTest();
        bldRevenue.commitWork();
        bldRevenue2.commitWork();
        Test.stopTest();
        FinServ__Revenue__c revenue1 = (FinServ__Revenue__c) bldRevenue.getRecord();
        FinServ__Revenue__c revenue2 = (FinServ__Revenue__c) bldRevenue2.getRecord();

        Global_Client_Revenue__c globalClientRevenue = [
                SELECT Id, CRT_ActualRevenueYTDZAR__c, CRT_ActualRevenueYTDLCY__c
                FROM Global_Client_Revenue__c];

        System.assertEquals(20, globalClientRevenue.CRT_ActualRevenueYTDZAR__c);

        System.assertEquals(30, globalClientRevenue.CRT_ActualRevenueYTDLCY__c);

    }
    
    @IsTest
    public static void shouldCalculateRevenuesAndBalancesMethod(){
        String CurrYear = String.valueof(System.today().year());
        String pastYear = String.valueof(System.today().addYears(-1).year());
        double currencyVal = double.valueOf(432443);
        BLD_Account bldAccount = new BLD_Account().CIF('12345');
        bldAccount.commitWork();
        BLD_GlobalClientRevenue bldGlobalClientRevenue = new BLD_GlobalClientRevenue().client(bldAccount);
        bldGlobalClientRevenue.commitWork();
        BLD_Revenue bldRevenue = new BLD_Revenue().amount(10)
                .actualRevenueZar(20)
                .actualRevenueLcy(30)
                .reportingYear(CurrYear)
                .reportingMonth(10)
            	.productDrCrIndicator('CR')
            	.reportingMonth(10)
            	.crtLocalCurrLcy('USD')
                .avgBalanceZar(currencyVal)
                .avgBalanceLcy(currencyVal)
                .date(Date.today())
                .client(bldAccount.getRecordId())
                .globalClient(bldGlobalClientRevenue.getRecordId());
        BLD_Revenue bldRevenue2= new BLD_Revenue().amount(10)
                .actualRevenueZar(30)
                .actualRevenueLcy(40)
                .reportingYear(pastYear)
                .reportingMonth(10)
            	.productDrCrIndicator('DR')
            	.reportingMonth(10)
            	.crtLocalCurrLcy('ZAR')
                .avgBalanceZar(currencyVal)
                .avgBalanceLcy(currencyVal)
                .date(Date.today())
                .client(bldAccount.getRecordId())
                .globalClient(bldGlobalClientRevenue.getRecordId());
        Test.startTest();
        bldRevenue.commitWork();
        bldRevenue2.commitWork();
        Test.stopTest();
        FinServ__Revenue__c revenue1 = (FinServ__Revenue__c) bldRevenue.getRecord();
        FinServ__Revenue__c revenue2 = (FinServ__Revenue__c) bldRevenue2.getRecord();

        Global_Client_Revenue__c globalClientRevenue = [
                SELECT Id, CRT_ActualRevenueYTDZAR__c, CRT_ActualRevenueYTDLCY__c
                FROM Global_Client_Revenue__c];

        System.assertEquals(20, globalClientRevenue.CRT_ActualRevenueYTDZAR__c);

        System.assertEquals(30, globalClientRevenue.CRT_ActualRevenueYTDLCY__c);

    }
}