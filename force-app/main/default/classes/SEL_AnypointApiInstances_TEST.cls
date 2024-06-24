/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date February 2023
 * @description test class for SEL_AnypointApiInstances
 *
 * @LastModified February 2023
 * @UserStory SFP-21061
 * @LastModifiedReason Create class for SEL_AnypointApiInstances
 */
@IsTest(IsParallel=true)
private class SEL_AnypointApiInstances_TEST {
    @IsTest
    static void shouldSelectByAssetVersionId() {
        Test.startTest();
        SEL_AnypointApiInstances.newInstance()
            .selectByAssetVersionId(new Set<string>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('acm_pkg__AssetVersionId__c IN :assetVersionId'),
            'Query was not created');
    }
}