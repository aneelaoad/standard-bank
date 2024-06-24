/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description test class for SEL_AcmSubscribers
 */
@IsTest(IsParallel=true)
private class SEL_AcmSubscribers_TEST {
    @IsTest
    static void shouldSelectSubscriptionsByUserContactId() {
        Test.startTest();
        SEL_AcmSubscribers.newInstance().selectSubscriptionsByUserContactId(new Set<string>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('ACM_Subscriber__c = :userContactId'), 'Query was not created');
    }
    @IsTest
    static void shouldSelectSubscriptionsByAnypointAppId() {
        Test.startTest();
        SEL_AcmSubscribers.newInstance().selectSubscriptionsByAnypointAppId(new Set<string>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Application_T__c = :anypointAppId'), 'Query was not created');
    }
}