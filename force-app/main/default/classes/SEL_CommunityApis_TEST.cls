/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description test class for SEL_CommunityApis
 */
@IsTest(IsParallel=true)
private class SEL_CommunityApis_TEST {
    @IsTest
    static void shouldSelectById() {
        Test.startTest();
        SEL_CommunityApis.newInstance().selectById(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN :ids'), 'Query was not created');
    }

    @IsTest
    static void shouldSelectByIdAndCommunity() {
        Test.startTest();
        SEL_CommunityApis.newInstance().selectByIdAndCommunity(new Set<Id>(), '');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(
            result.getCondition().containsIgnoreCase('Id IN :ids AND acm_pkg__CommunityName__c = :community'),
            'Query was not created'
        );
    }

    @IsTest
    static void shouldSelectByAssetType() {
        Test.startTest();
        SEL_CommunityApis.newInstance().selectByAssetType('');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('acm_pkg__AssetType__c = :assetType'), 'Query was not created');
    }

    @IsTest
    static void shouldSelectByAssetTypeAndCommunity() {
        Test.startTest();
        SEL_CommunityApis.newInstance().selectByAssetTypeAndCommunity('', '');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(
            result.getCondition().containsIgnoreCase('acm_pkg__AssetType__c = :assetType AND acm_pkg__CommunityName__c = :community'),
            'Query was not created'
        );
    }
}