/*************************************************************************
    @Author        : psvestka
    @Date          : 11. 8. 2015
    @description   : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx
    
    @Last Modified By   : Abhishek V
    @Last Modified on   : 18/11/2015
    @Last Modified Reason: Due to a validation inclusion for EN - 0916, it is not possible to add products for a closed opportunity. 

	@Last Modified By  : Augustine Chirombo
    @Last Modified On  : Sep 13, 2023
    @Modification Description : Change the static reference of Record types to new labels 
****************************************************************************/

@IsTest
private class ProductTriggerUtilityTest {

    private static Map<String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id prospectRecTypeId = mapAccountRecordTypes.get('Child').getRecordTypeId();

    private static Map<String, Schema.RecordTypeInfo> mapProdRecordTypes = SB_Product__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id multiRecTypeId = mapProdRecordTypes.get('CIB GM Multi-Risk').getRecordTypeId();
    private static Id advisoryRecTypeId = mapProdRecordTypes.get('Advisory').getRecordTypeId();

    private static List<Account> prepareAccounts(Id recordTypeId, Integer numberOfAccounts) {
        List<Account> lstAccount = new List<Account> ();

        for (Integer i = 0; i < numberOfAccounts; i++) {
            Account oTestClient = new Account();
            oTestClient.RecordTypeId = recordTypeId;
            oTestClient.Name = 'Test Client' + i;
            oTestClient.BillingStreet = 'Test street' + i;
            oTestClient.Client_Sector__c = 'Unknown Sector';
            oTestClient.Client_Sub_Sector__c = 'Unknown Sub-Sector';
            oTestClient.Client_Segment__c = 'AB';
            oTestClient.Country_Risk__c = 'India';
            oTestClient.Correspondence_Addr_Line1__c = 'Test Street Line 1' + i;
            oTestClient.Correspondence_City__c = 'City';
            oTestClient.Correspondence_Postal_Code__c = '123456';
            oTestClient.Correspondence_Country__c = 'India';
            oTestClient.BillingCountry = 'South Africa';
            oTestClient.BillingCity = 'Durban';

            lstAccount.add(oTestClient);
        }

        return lstAccount;
    }

    private static List<Opportunity> prepareOpportunities(List<Account> clientList, Integer numOfOpps) {
        List<Opportunity> listOpportunity = new List<Opportunity>();

        for (integer i = 0; i < numOfOpps; i++) {
            Opportunity opp = new Opportunity();
            opp.AccountId = clientList[i].Id;
            opp.Name = 'Opportunity_' + clientList[i].Name;
            opp.CloseDate = System.today();
            opp.StageName = '2 - Develop';
            opp.Short_Summary__c = 'test opportunity';
            opp.CurrencyIsoCode = 'ZAR';

            listOpportunity.add(opp);
        }

        return listOpportunity;
    }

    private static List<SB_Product__c> prepareProducts(List<Opportunity> oppList, Integer numOfProducts) {
        List<SB_Product__c> lstProduct = new List<SB_Product__c>();

        for(Integer i = 0; i < numOfProducts; i++){
            SB_Product__c prod = new SB_Product__c();
            prod.Opportunity__c = oppList[i].id;
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
            lstProduct.add(prod);
        }

        return lstProduct;
     }

    @TestSetup
    private static void prepareData() {
        List<Account> accounts = prepareAccounts(prospectRecTypeId, 2);
        insert accounts;

        List<Opportunity> opps = prepareOpportunities(accounts, 2); // accounts now have Ids
        opps[0].StageName = '4 - Closed Lost';
        opps[0].ReasonForWinLossPickList__c = 'Legal';
        opps[0].Reason_Won_Lost_Detail__c = 'Legal Terms Unfavourable';
        opps[0].Reason_Won_Lost_Comments__c = 'required comment why lost';
        insert opps;

        List<SB_Product__c> prods = prepareProducts(opps, 2);
        // modifed for EN - 916
        prods[0].RecordTypeId = multiRecTypeId;
        prods[0].Maturity_Date_Reminder__c = true;
        prods[0].SA_Maturity_Date__c = System.today().addDays(10);
        // modifed for EN - 916
        prods[0].Opportunity__c = opps[1].Id;
                
        prods[1].RecordTypeId = advisoryRecTypeId;
        
        insert prods;
                              
        insert new Environment_Variable__c(Skip_Workflow__c = true); // used by a WR "Notify Client Owner If Opportunity Owner Different" fired from a before-insert trigger on Opp
    }

    @isTest
    public static void testBehavior() {
        Test.startTest();

        List<SB_Product__c> tradingProds = [
            SELECT Id, RecordTypeId, Opportunity__r.Id, Opportunity__r.OwnerId, SA_Maturity_Date__c,Maturity_Date_Reminder__c
            FROM SB_Product__c
            WHERE RecordTypeId = :multiRecTypeId];
        
        List<Opportunity> opps = new List<Opportunity>([
            SELECT Id, StageName, ReasonForWinLossPickList__c, Reason_Won_Lost_Detail__c, Reason_Won_Lost_Comments__c
            FROM Opportunity 
            WHERE Id =: tradingProds[0].Opportunity__r.Id
        ]); 
        opps[0].StageName = '4 - Closed Lost';
        opps[0].ReasonForWinLossPickList__c = 'Legal';
        opps[0].Reason_Won_Lost_Detail__c = 'Legal Terms Unfavourable';
        opps[0].Reason_Won_Lost_Comments__c = 'required comment why lost';
        update opps;
        
        Map<Id, SB_Product__c> mapProducts = new Map<Id, SB_Product__c>([
            SELECT Id, RecordTypeId, Opportunity__r.Id, Opportunity__r.OwnerId, SA_Maturity_Date__c,Maturity_Date_Reminder__c
            FROM SB_Product__c
            WHERE RecordTypeId = :multiRecTypeId]);
        
        ProductTriggerUtility.handleProductAfterInsertTrigger(tradingProds, mapProducts); 
        
        Assert.areEqual(1, tradingProds.size(), 'There should be only one record for RecType Trading');
        Test.stopTest();
    }

    @isTest
    public static void negativeTest() {
        Test.startTest();

        List<SB_Product__c> advisoryProds = [
            SELECT Id, RecordTypeId, Opportunity__r.OwnerId, SA_Maturity_Date__c
            FROM SB_Product__c
            WHERE RecordTypeId = :advisoryRecTypeId];

        Assert.areEqual(1, advisoryProds.size(), 'There should be only one record for RecType Advisory');

        List<Task> tasks = [
            SELECT Id, WhatId, ActivityDate, OwnerId
            FROM Task
            WHERE WhatId = :(advisoryProds[0].Opportunity__r.Id)];

        Assert.areEqual(0, tasks.size(), 'There should not be any Task record for RecType Advisory');

        Test.stopTest();
    }
}