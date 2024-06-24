/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description test class for SEL_CommunityAssetVersions
 */
@IsTest(IsParallel=true)
private class SEL_CommunityAssetVersions_TEST {
    @IsTest
    static void shouldSelectByIds() {
        Test.startTest();
        SEL_CommunityAssetVersions.newInstance().selectByIds(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN :ids'), 'Query was not created');
    }

    @IsTest
    static void shouldSelectByParentAssetsAndCommunityName() {
        Test.startTest();
        SEL_CommunityAssetVersions.newInstance().selectByParentAssetsAndCommunityName(new Set<Id>(), '');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(
            result.getCondition().containsIgnoreCase('acm_pkg__ParentAsset__c IN :ids AND acm_pkg__CommunityName__c = :communityName'),
            'Query was not created'
        );
    }

    @IsTest
    static void shouldSelectByIdsAndCommunityName() {
        Test.startTest();
        SEL_CommunityAssetVersions.newInstance().selectByIdsAndCommunityName(new Set<Id>(), '');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(
            result.getCondition().containsIgnoreCase('Id IN :ids AND acm_pkg__CommunityName__c = :communityName'),
            'Query was not created'
        );
    }

    @IsTest
    static void shouldSelectByParentGroupVersionIdsAndCommunityName() {
        Test.startTest();
        SEL_CommunityAssetVersions.newInstance().selectByParentGroupVersionIdsAndCommunityName(new Set<Id>(), '');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(
            result.getCondition()
                .containsIgnoreCase('acm_pkg__ParentGroupVersion__c IN :ids AND acm_pkg__CommunityName__c = :communityName'),
            'Query was not created'
        );
    }
}