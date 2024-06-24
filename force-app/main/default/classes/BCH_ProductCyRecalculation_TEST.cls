/**
 * Test class for BCH_ProductCyRecalculation
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		March 2021
 *
 * @Last Modified By   : Dzianisik Maksim
 * @Last Modified on   : Feb. 2022
 * @description        : SFP-9856 Updated test after Batch fixing
*/
@IsTest
private class BCH_ProductCyRecalculation_TEST {

    @TestSetup
    static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getProductFeeRecClientSectorMap()});

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account acc = new BLD_Account(uow)
                .useCib()
                .CIF('0')
                .CIFActiveCode('A');
        new BLD_Opportunity(uow)
                        .client(acc)
                        .stage(DMN_Opportunity.ST_DEVELOP)
                        .addProduct(
                        new BLD_Product(uow)
                                .useCapitalMarkets()
                                .grandParentProduct(DMN_SB_Product.GPP_CASH_MANAGEMENT)
                                .termTenor(9)
                                .totalFees(250));
        BLD_Opportunity oppToClose = new BLD_Opportunity(uow)
                        .client(acc)
                        .stage(DMN_Opportunity.ST_DEVELOP)
                        .addProduct(
                        new BLD_Product(uow)
                                .useCapitalMarkets()
                                .grandParentProduct(DMN_SB_Product.GPP_CASH_MANAGEMENT)
                                .termTenor(9)
                                .totalFees(250));
        new BLD_Opportunity(uow)
                    .client(acc)
                    .stage(DMN_Opportunity.ST_DEVELOP)
                    .name(DMN_SB_Product.RT_ADVISORY)
                    .addProduct(
                    new BLD_Product(uow)
                            .useAdvisory()
                            .grandParentProduct(DMN_SB_Product.GPP_ADVISORY_FEES)
                            .feeAmount(250)
                            .feeFrequency(DMN_SB_Product.FREQ_MONTHLY)
                            .billingStartDate(Date.newInstance(System.today().year() - 1, 1, 1))
                            .billingEndDate(Date.newInstance(System.today().year() - 1, 6, 1))
                            .riskWeightedValue(10)
            );
        uow.commitWork();

        oppToClose.actualCloseDate(System.today());
        oppToClose.closedWon();
        oppToClose.registerDirty();
        uow.commitWork();
    }

    @IsTest
    static void shouldUpdateProducts() {

        List<SB_Product__c> products = SEL_Products.newInstance().selectByOpportunityStages(new Set<String> {DMN_Opportunity.ST_DEVELOP});
        Id capMarketProdId;
        Decimal capMarketCyFee;

        for(SB_Product__c tempProd : products) {
            if(tempProd.RecordTypeId == UTL_RecordType.getRecordTypeId(String.valueOf(SB_Product__c.getSObjectType()), DMN_SB_Product.RT_CAPITAL_MARKETS)) {
                capMarketProdId = tempProd.Id;
                capMarketCyFee = tempProd.Current_Year_Fees__c.round(System.RoundingMode.HALF_EVEN);
                tempProd.Current_Year_Fees__c = 0;
            }
        }

        System.assertNotEquals(0, capMarketCyFee, 'Has not to be blank');
        update products;

        SB_Product__c updatedProd = SEL_Products.newInstance().selectById(new Set<Id>{capMarketProdId})[0];
        System.assertEquals(0, updatedProd.Current_Year_Fees__c, 'Current Year Fees has to be 0');


        Test.startTest();
        Database.executeBatch(new BCH_ProductCyRecalculation());
        Test.stopTest();

        List<Estimated_Revenue_Schedule__c> relatedCurrentYearErs = [
                SELECT Fee_Amount__c,
                        Product__c
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c = :capMarketProdId
                AND Estimated_Revenue_Date__c = THIS_YEAR
        ];

        Decimal actualCapitalMarketCyFees = 0;

        for (Estimated_Revenue_Schedule__c tempErs : relatedCurrentYearErs) {
            actualCapitalMarketCyFees += tempErs.Fee_Amount__c;
        }
        actualCapitalMarketCyFees = actualCapitalMarketCyFees.round(System.RoundingMode.HALF_EVEN);

        SB_Product__c updatedByBatchProd = SEL_Products.newInstance().selectById(new Set<Id>{capMarketProdId})[0];
        System.assertEquals(actualCapitalMarketCyFees, updatedByBatchProd.Current_Year_Fees__c.round(System.RoundingMode.HALF_EVEN), 'Has to be equal with Fees SUM from ERS');
        System.assertNotEquals(0, updatedByBatchProd.Current_Year_Fees__c, 'Has not to be zero');

    }

    @IsTest
    static void shouldUpdateProdWithoutErsInCurYear() {
        List<SB_Product__c> products = SEL_Products.newInstance().selectByOpportunityStages(new Set<String> {DMN_Opportunity.ST_DEVELOP});
        SB_Product__c advisoryProd;
        Decimal advisoryCyFee;

        for(SB_Product__c tempProd : products) {
            if(tempProd.RecordTypeId == UTL_RecordType.getRecordTypeId(String.valueOf(SB_Product__c.getSObjectType()), DMN_SB_Product.RT_ADVISORY)) {
                advisoryProd = tempProd;
            }
        }
        advisoryCyFee = advisoryProd.Current_Year_Fees__c.round(System.RoundingMode.HALF_EVEN);
        advisoryProd.Current_Year_Fees__c = 100;
        update advisoryProd;

        System.assertEquals(0, advisoryCyFee, 'Has to be 0');

        SB_Product__c updatedProd = SEL_Products.newInstance().selectById(new Set<Id>{advisoryProd.Id})[0];
        System.assertNotEquals(0, updatedProd.Current_Year_Fees__c, 'Should be updated with value');

        Test.startTest();
        Database.executeBatch(new BCH_ProductCyRecalculation());
        Test.stopTest();

        SB_Product__c updatedByBatchProd = SEL_Products.newInstance().selectById(new Set<Id>{advisoryProd.Id})[0];
        System.assertEquals(0, updatedByBatchProd.Current_Year_Fees__c, 'Has to be 0');

    }

    @IsTest
    static void shouldNotUpdateProducts() {

        SB_Product__c prod = SEL_Products.newInstance().selectByOpportunityStages(new Set<String> {DMN_Opportunity.ST_CLOSED_WON}).get(0);

        System.assertNotEquals(0, prod.Current_Year_Fees__c, 'Has not to be zero');

        prod.Current_Year_Fees__c = 0;
        update prod;

        Test.startTest();
        Database.executeBatch(new BCH_ProductCyRecalculation());
        Test.stopTest();

        SB_Product__c updatedProd = SEL_Products.newInstance().selectById(new Set<Id>{prod.Id}).get(0);
        System.assertEquals(0, updatedProd.Current_Year_Fees__c, 'Has to be zero');
    }

    @IsTest
    static void sendEmailTest() {

        SB_Parameters__c param = new SB_Parameters__c();
        param.Name = BCH_ProductCyRecalculation.CRM_HELPDESK_SB_PARAMETER_NAME;
        param.Value__c = 'test@example.com';
        insert param;

        SB_Product__c product = SEL_Products.newInstance().selectByOpportunityStages(new Set<String> {DMN_Opportunity.ST_DEVELOP})[0];

        Test.startTest();
        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent');

        BCH_ProductCyRecalculation  bch = new BCH_ProductCyRecalculation();
        bch.failedRecId2ErrorMessage.put(product.Id, 'testErrorMessage');
        bch.sendEmails();

        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');
        Test.stopTest();

    }
}