/**
 * Test class for SEL_ProductDistributions
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date 2021-04-21
 */
@IsTest(IsParallel=true)
private class SEL_ProductDistributions_TEST {
    @IsTest
    static void shouldSelectWithoutCondition() {
        List<Product_Distribution__c> result = SEL_ProductDistributions.newInstance().selectWithoutCondition();
        System.assertNotEquals(null, result);
    }

    @IsTest
    static void shouldSelectByProductId() {
        List<Product_Distribution__c> result= SEL_ProductDistributions.newInstance().selectByProductId(new Set<Id>());
        System.assertNotEquals(null, result);
    }
}