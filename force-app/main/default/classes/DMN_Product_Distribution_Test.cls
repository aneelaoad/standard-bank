/**
 * Test class for DMN_Product_Distribution class.
 * <br/>SGPRT-624
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date March 2021
 */
@IsTest
public with sharing class DMN_Product_Distribution_Test {

    @testSetup static void setupData() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
                .addOpportunity(
                new BLD_Opportunity(uow)
                        .addProduct(
                        new BLD_Product(uow)
                                .grandParentProduct(DMN_SB_Product.GPP_ADVISORY_FEES)
                                .bankRole(DMN_Product_Distribution.BANK_ROLE_TRANSFERRED)
                        )

        );
        uow.commitWork();

    }
    @isTest
    public static void populateBankRoleTest(){
        SEL_Products selProducts = SEL_Products.newInstance();
        SB_Product__c product = selProducts.selectWithoutCondition().get(0);
        Test.startTest();
        Product_Distribution__c prodDistr = new Product_Distribution__c();
        prodDistr.Product__c = product.Id;
        insert prodDistr;
        Test.stopTest();
        SEL_ProductDistributions selProductsDistr = SEL_ProductDistributions.newInstance();
        Product_Distribution__c productDistr2 = selProductsDistr.selectWithoutCondition().get(0);
        System.assertEquals(DMN_Product_Distribution.BANK_ROLE_TRANSFERRED, productDistr2.Bank_Role__c);
    }


}