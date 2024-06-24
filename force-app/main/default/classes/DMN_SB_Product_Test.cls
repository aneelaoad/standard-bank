/**
 * @description Test class for DMN_SB_Product class
 * @author jmilosz@deloittece.com
 * @date Jan 2020
 * 
 * @last modified by  : Augustine Chirombo
 * @last modified on  : Sep 13, 2023
 * @modification description : Change the static reference of Record types to new labels 
 * 
 * @last modified by  : Augustine Chirombo
 * @last modified on  : Nov 14, 2023
 * @modification description : Change the field references of Profit Centre Field to Franchise Country
 *
 * @last modified by  : Maksim Dziamisik
 * @last modified on  : Apr 2024
 * @description       : SFP-37196 added coverage for "prepopulation" logic
*/
@isTest
private class DMN_SB_Product_Test {

    private static String msg = 'test'+ Date.today();
    
	/**
	 * @description Test data setup 
	 */ 
    @testSetup 
    public static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getProductFeeRecClientSectorMap()});

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        for(Integer i = 0; i < 5; i++) {
            new BLD_Account(uow)
                    .addOpportunity(
                    new BLD_Opportunity(uow)
                            .addProduct(
                            new BLD_Product(uow)
                    )
            );
        }
        BLD_Account bAccount0 = new BLD_Account(uow)
                .name('acc0')
                .useGroupParent();
        BLD_Opportunity bOpp0 = new BLD_Opportunity(uow)
                .gccrStatus('gccr0')
                .develop()
                .client(bAccount0)
                .currency(UTL_Currency.corporateIsoCode);
        new BLD_Product(uow)
                .linkToOpp(bOpp0)
                .notionalValueCurrency(10)
                .bankRole('Advisor')
                .notionalValue(600000)
                .sbHold(5)
                .sbSellDown(5)
                .transactionType('Debt advisory only')
                .balanceSheetOfBooking('Uganda - Stanbic Bank Uganda Limited')
                .currency(UTL_Currency.corporateIsoCode);

        uow.commitWork();
    }
    @isTest
    public static void validateOpportunityNegativeTest(){
        DmlException unexpectedException;
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        for (Opportunity opp : opps){
            opp.StageName = DMN_Opportunity.ST_CLOSED_LOST;
            opp.ReasonForWinLossPickList__c = 'Legal';
            opp.Reason_Won_Lost_Detail__c = 'Legal Terms Unfavourable';
            opp.Reason_Won_Lost_Comments__c = 'test';
        }
        update opps;
        List<SB_Product__c> products = [SELECT Id, ExchangeRate__c, Subsidiary_of_target_Client__c FROM SB_Product__c WHERE Opportunity__c IN :opps];
        Test.startTest();
        for (SB_Product__c prod : products){
            prod.Subsidiary_of_target_Client__c = msg;
        }
        try {
            update products;
        } catch (System.DmlException ex){
            unexpectedException = ex;
        }

        Integer numOfProds = [SELECT Id FROM SB_Product__c WHERE Subsidiary_of_target_Client__c = :msg].size();
        Assert.areEqual(0, numOfProds, 'Success');
        Assert.areEqual(true, unexpectedException.getMessage().contains(DMN_SB_Product.ERROR), 'Success');
        Test.stopTest();

    }
    
    @isTest
    public static void validateOpportunityPositiveTest(){
        DmlException unexpectedException;

        List<SB_Product__c> products = [SELECT Id, ExchangeRate__c, Subsidiary_of_target_Client__c FROM SB_Product__c WHERE Opportunity__c IN (SELECT Id FROM Opportunity)];
        Test.startTest();
        for (SB_Product__c prod : products){
            prod.Subsidiary_of_target_Client__c = msg;
        }
        try {
            update products;
        } catch (System.DmlException ex){
            unexpectedException = ex;
        }
        Test.stopTest();
        Integer numOfProds = [SELECT Id FROM SB_Product__c WHERE Subsidiary_of_target_Client__c = :msg].size();
        Assert.areEqual(products.size(), numOfProds, 'Success');
        Assert.areEqual(null, unexpectedException, 'No exceptions handled');


    }

    @isTest
    public static void recalculateExchangeRateTest(){
        Id oppIdTest = [SELECT Id FROM Opportunity LIMIT 1].Id;
        List<SB_Product__c> products = [SELECT Id, ExchangeRate__c, Subsidiary_of_target_Client__c FROM SB_Product__c WHERE Opportunity__c = :oppIdTest];

        Test.startTest();
        for (SB_Product__c prod : products){
            prod.CurrencyIsoCode = 'AOA';
        }

        update products;

        Decimal expectedExchangeRate = [SELECT ConversionRate FROM CurrencyType WHERE IsoCode = 'AOA'][0].ConversionRate;
        Decimal actualExchangeRate = [SELECT ExchangeRate__c FROM SB_Product__c WHERE Id IN:products][0].ExchangeRate__c;
        Assert.areEqual(expectedExchangeRate, actualExchangeRate, 'Success');
        Test.stopTest();

    }

    @isTest
    public static void shouldDefaultFinanceApprovedFeeRecognition() {
        Account accountWithProducts = [
                SELECT Id,(
                        SELECT Id, Client__c,
                                Finance_Approved_Fee_Recognition__c,
                                RecordTypeId, Client__r.Client_Sector__c
                        FROM Products2__r)
                FROM Account LIMIT 1];

        accountWithProducts.Client_Sector__c = 'Oil and Gas';
        update accountWithProducts;

        List<SB_Product__c> prods = accountWithProducts.Products2__r;
        Id capitalMarketsRecId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_CAPITAL_MARKETS);
        Integer j = prods.size();
        for (Integer i = 0; i < j; i++) {
            prods[i].RecordTypeId = capitalMarketsRecId;
            prods[i].Grand_Parent_Product__c = DMN_SB_Product.GPP_LOANS;
            prods[i].Term_Tenor__c = 1;
        }
        update prods;
        List<SB_Product__c> newProds = [
                SELECT Id, Client__c,
                        Finance_Approved_Fee_Recognition__c,
                        RecordTypeId, Client__r.Client_Sector__c,
                        Grand_Parent_Product__c, SA_Net_P_L_Amount_in_R__c,
                        SA_Gross_P_L_Amount_in_R__c, Parent_Product__c
                FROM SB_Product__c
                WHERE Client__c = :accountWithProducts.Id
        ];

        Test.startTest();
        DMN_SB_Product.defaultFinanceApprovedFeeRecognition(newProds);
        Test.stopTest();
        j = newProds.size();
        for (Integer i = 0; i < j; i++) {
            Assert.areEqual(50, newProds[i].Finance_Approved_Fee_Recognition__c, 'Success');
        }
    }

    @isTest
    public static void shouldCalculateCYFeesAndMargin() {
        Id capitalMarketsRecId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_CAPITAL_MARKETS);
        SB_Product__c prod = [
                SELECT Id,Total_Fees__c, Total_Margin__c,
                        Finance_Approved_Fee_Recognition__c,
                        Term_Tenor__c, Opportunity__c,
                        CurrencyIsoCode, SA_Net_P_L_Amount_in_R__c,
                        SA_Gross_P_L_Amount_in_R__c,
                        Current_Year_Fees__c, Current_Year_Margin__c
                FROM SB_Product__c
                LIMIT 1
        ];
        prod.RecordTypeId = capitalMarketsRecId;
        prod.Term_Tenor__c = 4 ;
        SB_Product__c oldProd = prod.clone();

        prod.Total_Fees__c = 34;
        prod.Total_Margin__c = 23;
        prod.Term_Tenor__c = 2;
        prod.Finance_Approved_Fee_Recognition__c = 10;
        update prod;

        SB_Product__c newProd = [
                SELECT Id,Total_Fees__c, Total_Margin__c,
                        Finance_Approved_Fee_Recognition__c,
                        Term_Tenor__c, Opportunity__c,
                        CurrencyIsoCode, SA_Net_P_L_Amount_in_R__c,
                        SA_Gross_P_L_Amount_in_R__c, RecordTypeId,
                        Current_Year_Fees__c, Current_Year_Margin__c
                FROM SB_Product__c
                WHERE Id = :prod.Id
                LIMIT 1
        ];

        Test.startTest();
        DMN_SB_Product.calculateCYFeesAndMargin(new List<SB_Product__c>{newProd}, new Map<Id, SB_Product__c>{oldProd.Id => oldProd});
        Test.stopTest();

        Assert.areNotEqual(prod.Current_Year_Fees__c, newProd.Current_Year_Fees__c, 'Current year fees updated');
        Assert.areNotEqual(prod.Current_Year_Margin__c, newProd.Current_Year_Margin__c, 'Current year margin updated');

        if (System.today().addDays(1).month() < 12) {
            Assert.areEqual(prod.Total_Fees__c, newProd.Current_Year_Fees__c, 'Success');
            Assert.areEqual(prod.Total_Margin__c, newProd.Current_Year_Margin__c, 'Success');
        } else {
            Assert.areEqual(prod.Total_Fees__c * (prod.Finance_Approved_Fee_Recognition__c/100), newProd.Current_Year_Fees__c, 'Success');
            Assert.areEqual(prod.Total_Margin__c/prod.Term_Tenor__c, newProd.Current_Year_Margin__c, 'Success');
        }
    }

    @isTest
    public static void shouldCreateEstimatedRevenueSchedule() {
        Id capitalMarketsRecId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_CAPITAL_MARKETS);
        Opportunity opp = [
                SELECT Id, CloseDate
                FROM Opportunity
                LIMIT 1
        ];
        opp.StageName = DMN_Opportunity.ST_DEVELOP;
        opp.CloseDate = System.today().addDays(5);
        update opp;

        SB_Product__c prod = [
                SELECT Id, CurrencyIsoCode, Term_Tenor__c,
                        Total_Fees__c,
                (SELECT Id
                FROM Estimated_Revenue_Schedules__r)
                FROM SB_Product__c
                WHERE Opportunity__c = :opp.Id
                LIMIT 1
        ];
        Integer numberOfErsBefore = prod.Estimated_Revenue_Schedules__r.size();

        prod.RecordTypeId = capitalMarketsRecId;
        prod.Total_Fees__c = 3400000;
        prod.Total_Margin__c = 230000;
        prod.Term_Tenor__c = 12;
        prod.Finance_Approved_Fee_Recognition__c = 50;
        update prod;

        Test.startTest();
        DMN_SB_Product.createEstimatedRevenueSchedule(new Set<Id>{prod.Id});
        Test.stopTest();

        List<Estimated_Revenue_Schedule__c> resultERS = [
                SELECT Id, Product__c, Estimated_Revenue_Date__c,
                        CurrencyIsoCode, RecordTypeId, Fee_Amount__c,
                        Updated_by_LEX__c
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c = :prod.Id
        ];

        Assert.areNotEqual(numberOfErsBefore, resultERS.size(), 'Success');
        Assert.areEqual(prod.Term_Tenor__c, resultERS.size(), 'Success');
        Date oppDate = opp.CloseDate.addDays(1);
        Assert.areEqual(oppDate, resultERS[0].Estimated_Revenue_Date__c, 'Success');
        Id cibErsRecordTypeId = UTL_RecordType.getRecordTypeId(DMN_EstimatedRevenueSchedule.OBJ_NAME,
                DMN_EstimatedRevenueSchedule.RT_ESR_NII_NIR);
        Integer j = resultERS.size();
        for (Integer i = 1; i < j; i++) {
            oppDate = oppDate.addMonths(1);
            Assert.areEqual(prod.CurrencyIsoCode, resultERS[i].CurrencyIsoCode, 'Success');
            Assert.areEqual(oppDate, resultERS[i].Estimated_Revenue_Date__c, 'Success');
            Assert.areEqual(cibErsRecordTypeId, resultERS[i].RecordTypeId, 'Success');
            Assert.isTrue(!resultERS[i].Updated_by_LEX__c, 'Success');
            Assert.isTrue(resultERS[i].Fee_Amount__c <= prod.Total_Fees__c, 'Success');
        }
    }

    @isTest
    public static void shouldUpdateEstimatedRevenueSchedule() {
        Id capitalMarketsRecId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_CAPITAL_MARKETS);
        Opportunity opp = [
                SELECT Id, CloseDate
                FROM Opportunity
                LIMIT 1
        ];
        opp.StageName = DMN_Opportunity.ST_DEVELOP;
        opp.CloseDate = System.today().addDays(5);
        update opp;

        SB_Product__c prod = [
                SELECT Id,Total_Fees__c, Total_Margin__c,
                        Finance_Approved_Fee_Recognition__c,
                        Term_Tenor__c, Opportunity__c,
                        CurrencyIsoCode, SA_Net_P_L_Amount_in_R__c,
                        SA_Gross_P_L_Amount_in_R__c,
                        Current_Year_Fees__c, Current_Year_Margin__c,
                (SELECT Id
                FROM Estimated_Revenue_Schedules__r)
                FROM SB_Product__c
                WHERE Opportunity__c = :opp.Id
                LIMIT 1
        ];
        Integer numberOfErsBefore = prod.Estimated_Revenue_Schedules__r.size();

        prod.RecordTypeId = capitalMarketsRecId;
        prod.Term_Tenor__c = 4 ;
        SB_Product__c oldProd = prod.clone();

        prod.Total_Fees__c = 3400000;
        prod.Total_Margin__c = 230000;
        prod.Term_Tenor__c = 12;
        prod.Finance_Approved_Fee_Recognition__c = 50;
        update prod;

        SB_Product__c newProd = [
                SELECT Id,Total_Fees__c, Total_Margin__c,
                        Finance_Approved_Fee_Recognition__c,
                        Term_Tenor__c, Opportunity__c,
                        CurrencyIsoCode, SA_Net_P_L_Amount_in_R__c,
                        SA_Gross_P_L_Amount_in_R__c,
                        Current_Year_Fees__c, Current_Year_Margin__c,
                (SELECT Id
                FROM Estimated_Revenue_Schedules__r)
                FROM SB_Product__c
                WHERE Id = :prod.Id
                LIMIT 1
        ];

        Test.startTest();
        DMN_SB_Product.updateEstimatedRevenueSchedule(new Map<Id, SB_Product__c>{oldProd.Id => oldProd}, new List<SB_Product__c>{newProd});
        Test.stopTest();

        List<Estimated_Revenue_Schedule__c> resultERS = [
                SELECT Id, Product__c, Estimated_Revenue_Date__c,
                        CurrencyIsoCode, RecordTypeId, Fee_Amount__c,
                        Updated_by_LEX__c
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c = :prod.Id
        ];

        Assert.areNotEqual(numberOfErsBefore, resultERS.size(), 'Success');
        Assert.areEqual(prod.Term_Tenor__c, resultERS.size(), 'Success');
        Date oppDate = opp.CloseDate.addDays(1);
        Assert.areEqual(oppDate, resultERS[0].Estimated_Revenue_Date__c, 'Success');
        Id cibErsRecordTypeId = UTL_RecordType.getRecordTypeId(DMN_EstimatedRevenueSchedule.OBJ_NAME,
                DMN_EstimatedRevenueSchedule.RT_ESR_NII_NIR);
        Integer j = resultERS.size();
        for (Integer i = 1; i < j; i++) {
            oppDate = oppDate.addMonths(1);
            Assert.areEqual(prod.CurrencyIsoCode, resultERS[i].CurrencyIsoCode, 'Success');
            Assert.areEqual(oppDate, resultERS[i].Estimated_Revenue_Date__c, 'Success');
            Assert.areEqual(cibErsRecordTypeId, resultERS[i].RecordTypeId, 'Success');
            Assert.isTrue(!resultERS[i].Updated_by_LEX__c, 'Success');
            Assert.isTrue(resultERS[i].Fee_Amount__c <= prod.Total_Fees__c, 'Success');
        }
    }

    @isTest
    public static void shouldLockFinanceApprovedFeeRecognition() {
        Map<Id, SB_Product__c> id2Prods = new Map<Id, SB_Product__c>([
                SELECT Id, Locked_Fee_Recognition__c,
                        Finance_Approved_Fee_Recognition__c,
                        RecordTypeId, SA_Net_P_L_Amount_in_R__c,
                        SA_Gross_P_L_Amount_in_R__c
                FROM SB_Product__c
        ]);
        List<SB_Product__c> oldProds = id2Prods.values().clone();

        List<SB_Product__c> newProds = id2Prods.values().deepClone(true);
        Id capitalMarketsRecId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_CAPITAL_MARKETS);
        for (SB_Product__c newP : newProds) {
            if (newP.Finance_Approved_Fee_Recognition__c != null) {
                newP.Finance_Approved_Fee_Recognition__c = newP.Finance_Approved_Fee_Recognition__c + 1;
            }
            else {
                newP.Finance_Approved_Fee_Recognition__c = 10;
            }
            newP.RecordTypeId = capitalMarketsRecId;
        }
        Test.startTest();
        DMN_SB_Product.lockFinanceApprovedFeeRecognition(newProds, new Map<Id, SB_Product__c>(oldProds));
        Test.stopTest();

        for (SB_Product__c prod : newProds) {
            Assert.isTrue(prod.Locked_Fee_Recognition__c, 'Success');
        }

    }

    @isTest
    public static void shouldUpdateFinanceApprovedFeeRecognition() {
        Map<Id, SB_Product__c> id2Prods = new Map<Id, SB_Product__c>([
                SELECT Id, Finance_Approved_Fee_Recognition__c,
                        RecordTypeId, Grand_Parent_Product__c,
                        Term_Tenor__c, SA_Net_P_L_Amount_in_R__c,
                        SA_Gross_P_L_Amount_in_R__c, Client__c,
                        Locked_Fee_Recognition__c, Parent_Product__c
                FROM SB_Product__c
        ]);
        List<SB_Product__c> oldProds = id2Prods.values().clone();

        List<SB_Product__c> newProds = id2Prods.values().deepClone(true);

        Id capitalMarketsRecordTypeId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_CAPITAL_MARKETS);

        for (SB_Product__c newP : newProds) {
            if (newP.Term_Tenor__c != null) {
                newP.Term_Tenor__c = newP.Term_Tenor__c + 1;
            }
            else {
                newP.Term_Tenor__c = 10;
            }
            newP.Grand_Parent_Product__c = DMN_SB_Product.GPP_CASH_MANAGEMENT;
            newP.RecordTypeId = capitalMarketsRecordTypeId;
        }
        Test.startTest();
        DMN_SB_Product.updateFinanceApprovedFeeRecognition(newProds, new Map<Id, SB_Product__c>(oldProds));
        Test.stopTest();

        for (SB_Product__c prod : newProds) {
            Assert.areEqual((1/prod.Term_Tenor__c)*100, prod.Finance_Approved_Fee_Recognition__c, 'Success');
        }

    }

    @IsTest
    private static void shouldUpdateBusinessAssessmentOnProductInsert(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'acc0'];
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
                .client(acc.Id);
        BLD_Assessment_Opportunity bAssOpp = new BLD_Assessment_Opportunity(uow);
        Opportunity bOpp0 = [SELECT Id FROM Opportunity WHERE Account.Name = 'acc0' LIMIT 1];
        bAssOpp.businessAssessment(bAsessment)
                .opportunity(bOpp0);
        uow.commitWork();

        bAsessment.refreshFullFromDB();

        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 'Success');
        Assert.areEqual(600000, ((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 'Success');
        Assert.areEqual('Debt advisory only', ((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, 'Correct Transaction type');
        Assert.areEqual('Advisor', ((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, 'Correct Bank Role');

        fflib_SObjectUnitOfWork uow2 = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Product(uow2)
                .linkToOpp(bOpp0.Id)
                .notionalValueCurrency(10)
                .bankRole('Advisor')
                .notionalValue(600000)
                .sbHold(5)
                .sbSellDown(5)
                .transactionType('Debt advisory only')
                .balanceSheetOfBooking('Uganda - Stanbic Bank Uganda Limited')
                .currency(UTL_Currency.corporateIsoCode);

        Test.startTest();
        uow2.commitWork();
        Test.stopTest();

        bAsessment.refreshFullFromDB();
        Assert.areEqual(20, ((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 'Success');
        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 'Success');
        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 'Success');
        Assert.areEqual(1200000, ((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 'Success');
        Assert.areEqual('Debt advisory only', ((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, 'Correct Transaction type');
        Assert.areEqual('Advisor', ((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, 'Correct Bank role');
    }

    @IsTest
    private static void shouldUpdateBusinessAssessmentOnProductUpdate() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'acc0'];
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
                .client(acc.Id);
        BLD_Assessment_Opportunity bAssOpp = new BLD_Assessment_Opportunity(uow);
        Opportunity bOpp0 = [SELECT Id FROM Opportunity WHERE Account.Name = 'acc0' LIMIT 1];
        bAssOpp.businessAssessment(bAsessment)
                .opportunity(bOpp0);
        uow.commitWork();

        bAsessment.refreshFullFromDB();

        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 'Success');
        Assert.areEqual(600000, ((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 'Success');
        Assert.areEqual('Debt advisory only', ((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, 'Success');
        Assert.areEqual('Advisor', ((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, 'Success');

        SB_Product__c prodToUpdate = [
                SELECT Id, Bank_Role__c, Transaction_Type__c, Facility_Size__c, SB_Gross_Participation__c, SB_Hold__c, SB_Sell_Down__c
                FROM SB_Product__c
                WHERE Opportunity__c = :bOpp0.Id
        ];
        prodToUpdate.SB_Gross_Participation__c += 20;
        prodToUpdate.SB_Sell_Down__c += 10;
        prodToUpdate.SB_Hold__c += 10;
        prodToUpdate.Facility_Size__c += 10000;
        prodToUpdate.Transaction_Type__c = 'Bi-Lateral';

        Test.startTest();
        update prodToUpdate;
        Test.stopTest();

        bAsessment.refreshFullFromDB();
        Assert.areEqual(30, ((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 'Success');
        Assert.areEqual(15, ((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 'Success');
        Assert.areEqual(15, ((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 'Success');
        Assert.areEqual(610000, ((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 'Success');
        Assert.areEqual('Bi-Lateral', ((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, 'Success');
        Assert.areEqual('Advisor', ((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, 'Success');
    }

    @IsTest
    private static void shouldNotUpdateBusinessAssessmentOnProductUpdateWhenIrrelevantProductFieldsAreModified(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'acc0'];
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
                .client(acc.Id);
        BLD_Assessment_Opportunity bAssOpp = new BLD_Assessment_Opportunity(uow);
        Opportunity bOpp0 = [SELECT Id FROM Opportunity WHERE Account.Name = 'acc0' LIMIT 1];
        bAssOpp.businessAssessment(bAsessment)
                .opportunity(bOpp0);
        uow.commitWork();

        bAsessment.refreshFullFromDB();

        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 'Success');
        Assert.areEqual(600000, ((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 'Success');
        Assert.areEqual('Debt advisory only', ((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, 'Success');
        Assert.areEqual('Advisor', ((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, 'Success');

        SB_Product__c prodToUpdate = [
                SELECT Id, Bank_Role__c, Transaction_Type__c, Facility_Size__c, SB_Gross_Participation__c, SB_Hold__c, SB_Sell_Down__c
                FROM SB_Product__c
                WHERE Opportunity__c = :bOpp0.Id
        ];
        prodToUpdate.SA_Amount__c = 20;

        Test.startTest();
        update prodToUpdate;
        Test.stopTest();

        bAsessment.refreshFullFromDB();
        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 'Success');
        Assert.areEqual(600000, ((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 'Success');
        Assert.areEqual('Debt advisory only', ((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, 'Success');
        Assert.areEqual('Advisor', ((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, 'Success');
    }

    @IsTest
    private static void shouldUpdateBusinessAssessmentOnProductDelete(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'acc0'];
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
                .client(acc.Id);
        BLD_Assessment_Opportunity bAssOpp = new BLD_Assessment_Opportunity(uow);
        Opportunity bOpp0 = [SELECT Id FROM Opportunity WHERE Account.Name = 'acc0' LIMIT 1];
        bAssOpp.businessAssessment(bAsessment)
                .opportunity(bOpp0);
        uow.commitWork();

        bAsessment.refreshFullFromDB();

        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 'Success');
        Assert.areEqual(600000, ((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 'Success');
        Assert.areEqual('Debt advisory only', ((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, 'Success');
        Assert.areEqual('Advisor', ((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, 'Success');

        fflib_SObjectUnitOfWork uow2 = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Product productBuilder = new BLD_Product(uow2)
                .linkToOpp(bOpp0.Id)
                .notionalValueCurrency(10)
                .bankRole('Advisor')
                .notionalValue(600000)
                .sbHold(5)
                .sbSellDown(5)
                .transactionType('Debt advisory only')
                .balanceSheetOfBooking('Uganda - Stanbic Bank Uganda Limited')
                .currency(UTL_Currency.corporateIsoCode);

        Test.startTest();
        uow2.commitWork();

        bAsessment.refreshFullFromDB();
        Assert.areEqual(20, ((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 'Success');
        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 'Success');
        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 'Success');
        Assert.areEqual(1200000, ((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 'Success');
        Assert.areEqual('Debt advisory only', ((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, 'Success');
        Assert.areEqual('Advisor', ((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, 'Success');


        delete (SB_Product__c)productBuilder.refreshFullFromDB().getRecord();
        Test.stopTest();

        bAsessment.refreshFullFromDB();
        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 'Success');
        Assert.areEqual(600000, ((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 'Success');
        Assert.areEqual('Debt advisory only', ((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, 'Success');
        Assert.areEqual('Advisor', ((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, 'Success');
    }

    @IsTest
    private static void shouldUpdateBusinessAssessmentOnProductUndelete(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'acc0'];
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
                .client(acc.Id);
        BLD_Assessment_Opportunity bAssOpp = new BLD_Assessment_Opportunity(uow);
        Opportunity bOpp0 = [SELECT Id FROM Opportunity WHERE Account.Name = 'acc0' LIMIT 1];
        bAssOpp.businessAssessment(bAsessment)
                .opportunity(bOpp0);
        uow.commitWork();

        bAsessment.refreshFullFromDB();

        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 'Success');
        Assert.areEqual(600000, ((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 'Success');
        Assert.areEqual('Debt advisory only', ((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, 'Success');
        Assert.areEqual('Advisor', ((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, 'Success');

        fflib_SObjectUnitOfWork uow2 = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Product productBuilder = new BLD_Product(uow2)
                .linkToOpp(bOpp0.Id)
                .notionalValueCurrency(10)
                .bankRole('Advisor')
                .notionalValue(600000)
                .sbHold(5)
                .sbSellDown(5)
                .transactionType('Debt advisory only')
                .balanceSheetOfBooking('Uganda - Stanbic Bank Uganda Limited')
                .currency(UTL_Currency.corporateIsoCode);

        Test.startTest();
        uow2.commitWork();

        bAsessment.refreshFullFromDB();
        Assert.areEqual(20, ((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 'Success');
        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 'Success');
        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 'Success');
        Assert.areEqual(1200000, ((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 'Success');
        Assert.areEqual('Debt advisory only', ((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, 'Success');
        Assert.areEqual('Advisor', ((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, 'Success');


        delete (SB_Product__c)productBuilder.refreshFullFromDB().getRecord();

        bAsessment.refreshFullFromDB();
        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 'Success');
        Assert.areEqual(5, ((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 'Success');
        Assert.areEqual(600000, ((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 'Success');
        Assert.areEqual('Debt advisory only', ((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, 'Success');
        Assert.areEqual('Advisor', ((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, 'Success');


        undelete (SB_Product__c)productBuilder.getRecord();
        Test.stopTest();

        bAsessment.refreshFullFromDB();
        Assert.areEqual(20, ((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 'Success');
        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 'Success');
        Assert.areEqual(10, ((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 'Success');
        Assert.areEqual(1200000, ((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 'Success');
        Assert.areEqual('Debt advisory only', ((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, 'Success');
        Assert.areEqual('Advisor', ((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, 'Success');
    }

    @isTest
    public static void shouldCreateEstimatedRevenueScheduleForIBProducts() {
        Id capitalMarketsRecId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_LENDING_COMMIT);

        Opportunity opp = [
                SELECT Id, CloseDate
                FROM Opportunity
                LIMIT 1
        ];

        opp.StageName = DMN_Opportunity.ST_DEVELOP;
        opp.CloseDate = System.today().addDays(5);
        update opp;

        SB_Product__c prod = [
                SELECT Id, CurrencyIsoCode, Term_Tenor__c,
                        Total_Fees__c,
                (SELECT Id
                FROM Estimated_Revenue_Schedules__r)
                FROM SB_Product__c
                WHERE Opportunity__c = :opp.Id
                LIMIT 1
        ];

        prod.RecordTypeId = capitalMarketsRecId;
        prod.Total_Fees__c = 3400000;
        prod.Total_Margin__c = 230000;
        prod.Term_Tenor__c = 12;
        prod.Finance_Approved_Fee_Recognition__c = 50;
        prod.Product_Division__c = 'Investment Banking';
        update prod;


        Test.startTest();
        Draw_Down_Profile__c ddProfiles = new Draw_Down_Profile__c(
                Product__c = prod.Id,
                Draw_Date__c = system.today(),
                Funding_Required__c = 7000
        );
        INSERT ddProfiles;
        DMN_SB_Product.createEstimatedRevenueSchedule(new Set<Id>{prod.Id});

        prod.Term_Tenor__c = 1;
        prod.Finance_Approved_Fee_Recognition__c = 55;
        prod.Product_Division__c = 'Investment Banking';
        update prod;

        DMN_SB_Product.createEstimatedRevenueSchedule(new Set<Id>{prod.Id});
        Test.stopTest();

        List<Estimated_Revenue_Schedule__c> resultERS = [
                SELECT Id, Product__c, Estimated_Revenue_Date__c,
                        CurrencyIsoCode, RecordTypeId, Fee_Amount__c,
                        Updated_by_LEX__c
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c = :prod.Id
        ];
        Assert.areEqual(prod.Term_Tenor__c, 1,'Product Tenor is 1');
        Assert.isTrue(!resultERS[0].Updated_by_LEX__c,'Product is not lexi updated');
    }

    @isTest
    public static void shouldCalculateCYFeesAndMarginForIBProducts() {
        Id capitalMarketsRecId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_LENDING_COMMIT);
        SB_Product__c prod = [
                SELECT Id,Total_Fees__c, Total_Margin__c,
                        Finance_Approved_Fee_Recognition__c,
                        Term_Tenor__c, Opportunity__c,
                        CurrencyIsoCode, SA_Net_P_L_Amount_in_R__c,
                        SA_Gross_P_L_Amount_in_R__c,
                        Current_Year_Fees__c, Current_Year_Margin__c
                FROM SB_Product__c
                LIMIT 1
        ];
        prod.RecordTypeId = capitalMarketsRecId;
        prod.Term_Tenor__c = 4 ;
        SB_Product__c oldProd = prod.clone();

        prod.Total_Fees__c = 34;
        prod.Total_Margin__c = 23;
        prod.Term_Tenor__c = 2;
        prod.Finance_Approved_Fee_Recognition__c = 10;
        update prod;

        SB_Product__c newProd = [
                SELECT Id,Total_Fees__c, Total_Margin__c,
                        Finance_Approved_Fee_Recognition__c,
                        Term_Tenor__c, Opportunity__c,
                        CurrencyIsoCode, SA_Net_P_L_Amount_in_R__c,
                        SA_Gross_P_L_Amount_in_R__c, RecordTypeId,
                        Current_Year_Fees__c, Current_Year_Margin__c
                FROM SB_Product__c
                WHERE Id = :prod.Id
                LIMIT 1
        ];

        Test.startTest();
        Draw_Down_Profile__c ddProfiles = new Draw_Down_Profile__c(
                Product__c = prod.Id,
                Draw_Date__c = system.today(),
                Funding_Required__c = 7000
        );
        INSERT ddProfiles;
        DMN_SB_Product.calculateCYFeesAndMargin(new List<SB_Product__c>{newProd}, new Map<Id, SB_Product__c>{oldProd.Id => oldProd});
        Test.stopTest();

        Assert.areNotEqual(prod.Current_Year_Fees__c, newProd.Current_Year_Fees__c,'Previous and new current year fees are same');
        Assert.areNotEqual(prod.Current_Year_Margin__c, newProd.Current_Year_Margin__c,'Previous and new current year margin are same');
    }

    @isTest
    public static void testProfitCenterCountry(){
        Schema.DescribeFieldResult schemaProduct = SB_Product__c.Franchise_Country__c.getDescribe();
        List<Schema.PicklistEntry> schemaProfitCentreValues = schemaProduct.getPicklistValues();
        String country = DMN_SB_Product.getProfitCenterCountry('South Africa - The Standard Bank of South Africa Limited', schemaProfitCentreValues);
        Assert.areEqual('South Africa', country, 'Success');
    }

    @IsTest
    public static void testPrepopulateLogic() {
        Opportunity testOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Assert.isTrue(testOpp != null, 'There has to be a test Opportunity');
        Product2 agencyFeesProduct2 = new Product2(
                IsActive = true,
                Name = 'Security Agent Fee',
                Grand_Parent_Product__c = 'Agency Fees',
                Parent_Product__c = 'Agency Fees',
                Product_Division__c = 'Investment Banking',
                Non_Advisory_IB_Fees_Product__c = true,
                Risk_Weighted_Value__c = 50
        );
        insert agencyFeesProduct2;

        SB_Product__c agencyFeesSbProduct = new SB_Product__c(
                Product2__c = agencyFeesProduct2.Id,
                SA_Product__c = agencyFeesProduct2.Name,
                Product_Division__c = agencyFeesProduct2.Product_Division__c,
                Grand_Parent_Product__c = agencyFeesProduct2.Grand_Parent_Product__c,
                Parent_Product__c = agencyFeesProduct2.Parent_Product__c,
                RecordTypeId = Schema.SObjectType.SB_Product__c.getRecordTypeInfosByDeveloperName().get(DMN_SB_Product.RT_ADVISORY).getRecordTypeId(),
                Client__c = testOpp.AccountId,
                Opportunity__c = testOpp.Id
        );
        Test.startTest();
        insert agencyFeesSbProduct;
        Test.stopTest();
        SB_Product__c testSbProduct = [SELECT Id, Risk_Weighted_Value__c, Non_Advisory_IB_Fees_Product__c FROM SB_Product__c WHERE Id =: agencyFeesSbProduct.Id];
        Assert.areEqual(testSbProduct.Risk_Weighted_Value__c, agencyFeesProduct2.Risk_Weighted_Value__c, 'Has to be the same');
        Assert.areEqual(testSbProduct.Non_Advisory_IB_Fees_Product__c, agencyFeesProduct2.Non_Advisory_IB_Fees_Product__c, 'Has to be the same');
    }
}