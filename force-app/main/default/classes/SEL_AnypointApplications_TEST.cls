/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description test class for SEL_AnypointApplications
 */
@IsTest(IsParallel=true)
private class SEL_AnypointApplications_TEST {
    @IsTest
    static void shouldSelectAnypointAppById() {
        Test.startTest();
        SEL_AnypointApplications.newInstance().selectAnypointAppById(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN :ids'), 'Query was not created');
    }

    @IsTest
    static void shouldSelectAnypointAppByExternalId() {
        Test.startTest();
        SEL_AnypointApplications.newInstance().selectAnypointAppByExternalId(new Set<string>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('ExternalId IN :exteralIds'), 'Query was not created');
    }
}