/**
 * @Author Emmanuel Mulea Nocks
 * @date April 2024
 * @description This class contains unit tests for validating the behavior of SEL_LoginHistories
 */
@isTest
private class SEL_LoginHistoriesTest {


    @IsTest
    private static void shouldSelectRunAllQueryAndReturnTheLast() {

        Test.startTest();
        SEL_LoginHistories.newInstance().selectByUserIds(new Set<Id>(),10);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('UserId in : userIds'),'Checking the last condition');
    }
}