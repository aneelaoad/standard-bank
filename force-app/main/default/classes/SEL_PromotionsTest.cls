/**
 * @Author Emmanuel Mulea Nocks
 * @date April 2024
 * @description This class contains unit tests for validating the behavior of SEL_Promotions
 */
@isTest
private class SEL_PromotionsTest {

    @IsTest
    private static void shouldSelectRunAllQueryAndReturnTheLast() {
        String promotionWhereClause = 'Publishing_Unit__r.Published_from__c = THIS_MONTH AND IsOnline__c = TRUE';
        Test.startTest();
        SEL_Promotions.newInstance().selectByCustomFilterCondition(promotionWhereClause);
        SEL_Promotions.newInstance().selectByIds(new List<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Id in : ids'),'Checking the last condition');
    }
}