/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description test class for OSB_OD_ProductCatalogue_CTRL
 */
@IsTest
private class OSB_OD_ProductCatalogue_CTRL_TEST {
    private static final string CATEGORY = 'Category:testCategory';
    private static final string DISPLAY_CATEGORY = 'testCategory';
    private static final string ANYPOINT_PAGE = '(testIcon)';
    private static final String PACKAGE_VERSION = '1.0.0';
    private static final String PAGE_NAME = 'Icon';

    @IsTest
    static void shouldGetProductMap() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_CommunityApis communityApiSel = (SEL_CommunityApis) mocks.mock(SEL_CommunityApis.class);
        SEL_AnypointCategories anypointCategorySel = (SEL_AnypointCategories) mocks.mock(SEL_AnypointCategories.class);
        SEL_AnypointApiPages anypointPageSel = (SEL_AnypointApiPages) mocks.mock(SEL_AnypointApiPages.class);

        acm_pkg__CommunityApi__c communityApiMockProduct = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .assetVersion(PACKAGE_VERSION)
            .mock();

        acm_pkg__AnypointAssetCategories__x categoryMock = (acm_pkg__AnypointAssetCategories__x) new BLD_AnypointCategory()
            .category(CATEGORY)
            .assetId(communityApiMockProduct.acm_pkg__ApiId__c)
            .mock();

        acm_pkg__AnypointApiPages__x anypointApiPageMock = (acm_pkg__AnypointApiPages__x) new BLD_AnypointApiPage()
            .assetVersionId(communityApiMockProduct.acm_pkg__ApiId__c + ':' + communityApiMockProduct.acm_pkg__AssetVersion__c)
            .pageContent(ANYPOINT_PAGE)
            .pageName(PAGE_NAME)
            .mock();

        mocks.startStubbing();
        mocks.when(communityApiSel.sObjectType()).thenReturn(acm_pkg__CommunityApi__c.SObjectType);
        mocks.when(anypointCategorySel.sObjectType()).thenReturn(acm_pkg__AnypointAssetCategories__x.SObjectType);
        mocks.when(anypointPageSel.sObjectType()).thenReturn(acm_pkg__AnypointApiPages__x.SObjectType);
        mocks.when(communityApiSel.selectByAssetTypeAndCommunity(fflib_Match.anyString(), fflib_Match.anyString()))
            .thenReturn(new List<acm_pkg__CommunityApi__c>{ communityApiMockProduct });
        mocks.when(communityApiSel.selectByIdAndCommunity((Set<Id>) fflib_Match.anyObject(), fflib_Match.anyString()))
            .thenReturn(new List<acm_pkg__CommunityApi__c>{ communityApiMockProduct })
            .thenReturn(new List<acm_pkg__CommunityApi__c>{ communityApiMockProduct });
        mocks.when(anypointCategorySel.selectByAssetIdAndDisplayName((Set<string>) fflib_Match.anyObject(), fflib_Match.anyString()))
            .thenReturn(new List<acm_pkg__AnypointAssetCategories__x>{ categoryMock });
        mocks.when(anypointPageSel.selectByAssetVersionIdsAndPageName((Set<string>) fflib_Match.anyObject(), fflib_Match.anyString()))
            .thenReturn(new List<acm_pkg__AnypointApiPages__x>{ anypointApiPageMock });
        mocks.stopStubbing();

        ORG_Application.selector.setMock(communityApiSel);
        ORG_Application.selector.setMock(anypointCategorySel);

        Test.startTest();
        List<Map<string, string>> productMap = OSB_OD_ProductCatalogue_CTRL.getProductMap();
        Test.stopTest();

        System.assertEquals(productMap[0].get('Category'), DISPLAY_CATEGORY, 'Did not get the correct category from the product map');
    }
}