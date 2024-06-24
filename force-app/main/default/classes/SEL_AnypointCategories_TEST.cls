/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description test class for SEL_AnypointCategories
 */
@IsTest(IsParallel=true)
private class SEL_AnypointCategories_TEST {
    @IsTest
    static void shouldSelectByAssetIdAndDisplayName() {
        Test.startTest();
        SEL_AnypointCategories.newInstance().selectByAssetIdAndDisplayName(new Set<string>(), '');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(
            result.getCondition().containsIgnoreCase('acm_pkg__AssetId__c IN :assetIds AND acm_pkg__DisplayName__c = :displayName'),
            'Query was not created'
        );
    }
}