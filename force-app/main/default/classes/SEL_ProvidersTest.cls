/**
 * @Author Lulu
 * @date April 2024
 * @description This class contains unit tests for validating the behavior of SEL_Providers
 */
@isTest
private class SEL_ProvidersTest {

    @isTest
    private static void shouldSelectRunAllQueryAndReturnTheLast() {
        String condition = 'CreatedDate = THIS_MONTH';
        Test.startTest();
        SEL_Providers.newInstance().selectByCustomFilterCondition(condition);
        SEL_Providers.newInstance().selectByIds(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Id in : ids'),'Checking the last condition');
    }
}