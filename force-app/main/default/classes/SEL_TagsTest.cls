/**
 * @Author Emmanuel Mulea Nocks
 * @date April 2024
 * @description This class contains unit tests for validating the behavior of SEL_Tags
 */
@isTest
private class SEL_TagsTest {


    @IsTest
    private static void shouldSelectRunAllQueryAndReturnTheLast() {

        String whereCluse = 'CreatedDate = THIS_MONTH';
        Test.startTest();
        SEL_Tags.newInstance().selectByCustomFilterCondition(whereCluse);
        SEL_Tags.newInstance().selectTagsByIds(new Set<Id>());
        SEL_Tags.newInstance().selectTagsByNames(new Set<String>());
        SEL_Tags.newInstance().selectTagsByParentNames(new Set<String>());
        SEL_Tags.newInstance().selectTagsByRootNames(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Root_name__c in : rootNames AND IsOnline__c = TRUE'),'Checking the last condition');
    }
}