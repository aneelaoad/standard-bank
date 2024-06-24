/**
 * Test class for TRH_Investor_Participation class.
 * <br/>SGPRT-624
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date March 2021
 */
@IsTest
public with sharing class TRH_Investor_Participation_Test {

    @testSetup static void setupData() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
                .addOpportunity(
                new BLD_Opportunity(uow)
                        .addProduct(
                        new BLD_Product(uow)
                                .grandParentProduct(DMN_SB_Product.GPP_ADVISORY_FEES)
                                .addProductDistribution(
                                new BLD_Product_Distribution(uow)
                        )
                )
        );
        uow.commitWork();

    }

    @isTest
    public static void concatenateFieldsFromInvestorParticipationOnProductDistributionInsertTest(){
        SEL_ProductDistributions selProductsDistr = SEL_ProductDistributions.newInstance();
        Product_Distribution__c productDistr = selProductsDistr.selectWithoutCondition().get(0);
        SEL_Accounts selAccount = SEL_Accounts.newInstance();
        Account acc = selAccount.selectWithoutCondition().get(0);
        Test.startTest();
        Investor_Participation__c invPart = new Investor_Participation__c();
        invPart.Distribution__c = productDistr.Id;
        invPart.Distribution_Party_Status__c = DMN_Investor_Participation.STATUS_TRANSFERRED;
        invPart.Distribution_Party_Bid_Price__c = 100;
        invPart.Distribution_Party__c = acc.Id;
        insert invPart;
        Test.stopTest();
        Product_Distribution__c productDistr2 = selProductsDistr.selectWithoutCondition().get(0);
        System.assertEquals('testAccount', productDistr2.All_Distribution_Parties__c);
        System.assertEquals('100.000', productDistr2.All_Distribution_Parties_Bid_Prices__c);
        System.assertEquals(DMN_Investor_Participation.STATUS_TRANSFERRED, productDistr2.All_Distribution_Parties_Status__c);
    }

    @isTest
    public static void concatenateFieldsFromInvestorParticipationOnProductDistributionUpdateTest(){
        SEL_ProductDistributions selProductsDistr = SEL_ProductDistributions.newInstance();
        Product_Distribution__c productDistr = selProductsDistr.selectWithoutCondition().get(0);
        SEL_Accounts selAccount = SEL_Accounts.newInstance();
        Account acc = selAccount.selectWithoutCondition().get(0);

        Investor_Participation__c invPart = new Investor_Participation__c();
        invPart.Distribution__c = productDistr.Id;
        invPart.Distribution_Party_Status__c = DMN_Investor_Participation.STATUS_TRANSFERRED;
        invPart.Distribution_Party_Bid_Price__c = 100;
        invPart.Distribution_Party__c = acc.Id;
        insert invPart;
        Test.startTest();
        SEL_InvestorParticipations selInvestorParticipations = SEL_InvestorParticipations.newInstance();
        Investor_Participation__c invPart1 = selInvestorParticipations.selectWithoutCondition().get(0);
        invPart1.Distribution_Party_Status__c = 'Initial Engagement';
        invPart1.Distribution_Party_Bid_Price__c = 900;
        update invPart1;
        Test.stopTest();
        Product_Distribution__c productDistr2 = selProductsDistr.selectWithoutCondition().get(0);
        System.assertEquals('testAccount', productDistr2.All_Distribution_Parties__c);
        System.assertEquals('900.000', productDistr2.All_Distribution_Parties_Bid_Prices__c);
        System.assertEquals('Initial Engagement', productDistr2.All_Distribution_Parties_Status__c);

    }

    @isTest
    public static void concatenateFieldsFromInvestorParticipationOnProductDistributionDeleteTest(){
        SEL_ProductDistributions selProductsDistr = SEL_ProductDistributions.newInstance();
        Product_Distribution__c productDistr = selProductsDistr.selectWithoutCondition().get(0);
        SEL_Accounts selAccount = SEL_Accounts.newInstance();
        Account acc = selAccount.selectWithoutCondition().get(0);

        Investor_Participation__c invPart = new Investor_Participation__c();
        invPart.Distribution__c = productDistr.Id;
        invPart.Distribution_Party_Status__c = DMN_Investor_Participation.STATUS_TRANSFERRED;
        invPart.Distribution_Party_Bid_Price__c = 100;
        invPart.Distribution_Party__c = acc.Id;
        insert invPart;
        Test.startTest();
        SEL_InvestorParticipations selInvestorParticipations = SEL_InvestorParticipations.newInstance();
        Investor_Participation__c invPart1 = selInvestorParticipations.selectWithoutCondition().get(0);
        delete invPart1;
        Test.stopTest();
        Product_Distribution__c productDistr2 = selProductsDistr.selectWithoutCondition().get(0);
        System.assertEquals(null, productDistr2.All_Distribution_Parties__c);
        System.assertEquals(null, productDistr2.All_Distribution_Parties_Bid_Prices__c);
        System.assertEquals(null, productDistr2.All_Distribution_Parties_Status__c);
    }

}