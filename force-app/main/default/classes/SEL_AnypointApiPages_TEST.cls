/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description test class for SEL_AnypointApiPages
 */
@IsTest(IsParallel=true)
private class SEL_AnypointApiPages_TEST {
    @IsTest
    static void shouldSelectByAssetVersionIdsAndPageName() {
        Test.startTest();
        SEL_AnypointApiPages.newInstance().selectByAssetVersionIdsAndPageName(new Set<string>(), '');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(
            result.getCondition().containsIgnoreCase('acm_pkg__AssetVersionId__c IN :assetVersionIds AND acm_pkg__PageName__c = :pageName'),
            'Query was not created'
        );
    }
}