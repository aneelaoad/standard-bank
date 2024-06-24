/**
 * @Author Emmanuel Mulea Nocks
 * @date April 2024
 * @description This class contains unit tests for validating the behavior of SEL_UserPreferences
 */
@isTest
private class SEL_UserPreferencesTest {

    @IsTest
    private static void shouldSelectRunAllQueryAndReturnTheLast() {

        Test.startTest();
        SEL_UserPreferences.newInstance().selectByUserIds(new Set<Id>());
        SEL_UserPreferences.newInstance().selectByRootNamesAndUserId(new Set<String>(),'');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Tag__r.Root_Name__c in : rootNames AND User__c =: userId'),'Checking the last condition');
    }
}