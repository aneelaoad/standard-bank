/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description test class for OSB_OD_ProductDetails_CTRL
 */
@IsTest
private class OSB_OD_ProductDetails_CTRL_TEST {
    private static final string PRODUCT_NAME = 'Test Product';
    private static final string COMMUNITY_NAME = 'TestCommunity';
    private static final string ASSET_VERSION = '1.0.0';
    private static final string API_ASSET_TYPE = 'rest-api';
    private static final string PRODUCT_ASSET_TYPE = 'api-group';
    private static final string PAGE_NAME = 'test page';
    public static final String VERSION_GROUP = 'v1';
    public static final String PACKAGE_VERSION = '1.0.0';
    public static final String PAGE_CONTENT = 'test page content';
    final static string PRODUCT_FEATURES =
        'test feature one\n\n' +
        'test feature one description\n\n' +
        '![resources/test-img.png](resources/test-img.png)\n\n' +
        '------' +
        'test feature two\n\n' +
        'test feature two description\n\n' +
        '![resources/test-img-two.png](resources/test-img-two.png)\n\n' +
        '------';

    @IsTest
    static void shouldGetPathForBreadCrumb() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_CommunityAssetVersions communityAssetVersionSel = (SEL_CommunityAssetVersions) mocks.mock(SEL_CommunityAssetVersions.class);
        SEL_CommunityApis communityApiSel = (SEL_CommunityApis) mocks.mock(SEL_CommunityApis.class);

        acm_pkg__CommunityApi__c communityApiMockProduct = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .packageName(PRODUCT_NAME)
            .assetType(PRODUCT_ASSET_TYPE)
            .assetVersion(ASSET_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityApi__c communityApiMockApi = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .packageName(PRODUCT_NAME)
            .assetType(API_ASSET_TYPE)
            .assetVersion(ASSET_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityAssetVersion__c communityAssetVersionMockProduct = (acm_pkg__CommunityAssetVersion__c) new BLD_CommunityAssetVersion()
            .parentAsset(communityApiMockProduct.Id)
            .versionGroup(VERSION_GROUP)
            .packageVersion(PACKAGE_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityAssetVersion__c communityAssetVersionMockApi = (acm_pkg__CommunityAssetVersion__c) new BLD_CommunityAssetVersion()
            .parentAsset(communityApiMockApi.Id)
            .versionGroup(VERSION_GROUP)
            .packageVersion(PACKAGE_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        mocks.startStubbing();
        mocks.when(communityApiSel.sObjectType()).thenReturn(acm_pkg__CommunityApi__c.SObjectType);
        mocks.when(communityAssetVersionSel.sObjectType()).thenReturn(acm_pkg__CommunityAssetVersion__c.SObjectType);
        mocks.when(communityApiSel.selectByIdAndCommunity((Set<Id>) fflib_Match.anyObject(), fflib_Match.anyString()))
            .thenReturn(new List<acm_pkg__CommunityApi__c>{ communityApiMockApi })
            .thenReturn(new List<acm_pkg__CommunityApi__c>{ communityApiMockProduct });
        mocks.when(
                communityAssetVersionSel.selectByParentAssetsAndCommunityName((Set<Id>) fflib_Match.anyObject(), fflib_Match.anyString())
            )
            .thenReturn(new List<acm_pkg__CommunityAssetVersion__c>{ communityAssetVersionMockApi });
        mocks.when(communityAssetVersionSel.selectByIdsAndCommunityName((Set<Id>) fflib_Match.anyObject(), fflib_Match.anyString()))
            .thenReturn(new List<acm_pkg__CommunityAssetVersion__c>{ communityAssetVersionMockProduct });
        mocks.stopStubbing();

        ORG_Application.selector.setMock(communityAssetVersionSel);
        ORG_Application.selector.setMock(communityApiSel);

        Test.startTest();
        List<acm_pkg__CommunityApi__c> breadcrumbPath = OSB_OD_ProductDetails_CTRL.getPathForBreadCrumb(communityApiMockApi.Id);
        Test.stopTest();

        System.assertEquals(2, breadcrumbPath.size(), 'Did not get the full path');
    }

    @IsTest
    static void shouldGetCommunityAssetVersion() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_CommunityAssetVersions communityAssetVersionSel = (SEL_CommunityAssetVersions) mocks.mock(SEL_CommunityAssetVersions.class);

        acm_pkg__CommunityApi__c communityApiMockProduct = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .packageName(PRODUCT_NAME)
            .assetType(PRODUCT_ASSET_TYPE)
            .assetVersion(ASSET_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityAssetVersion__c communityAssetVersionMockProduct = (acm_pkg__CommunityAssetVersion__c) new BLD_CommunityAssetVersion()
            .parentAsset(communityApiMockProduct.Id)
            .versionGroup(VERSION_GROUP)
            .packageVersion(PACKAGE_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        mocks.startStubbing();
        mocks.when(communityAssetVersionSel.sObjectType()).thenReturn(acm_pkg__CommunityAssetVersion__c.SObjectType);
        mocks.when(
                communityAssetVersionSel.selectByParentAssetsAndCommunityName((Set<Id>) fflib_Match.anyObject(), fflib_Match.anyString())
            )
            .thenReturn(new List<acm_pkg__CommunityAssetVersion__c>{ communityAssetVersionMockProduct });
        mocks.stopStubbing();

        ORG_Application.selector.setMock(communityAssetVersionSel);

        Test.startTest();
        acm_pkg__CommunityAssetVersion__c communityAssetVersion = OSB_OD_ProductDetails_CTRL.getCommunityAssetVersion(
            communityApiMockProduct.Id
        );
        Test.stopTest();

        System.assertEquals(communityApiMockProduct.Id, communityAssetVersion.acm_pkg__ParentAsset__c, 'Fetched the wrong community api');
    }

    @IsTest
    static void shouldGetProductFeatures() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_AnypointApiPages anypointApiPageSel = (SEL_AnypointApiPages) mocks.mock(SEL_AnypointApiPages.class);
        SEL_CommunityApis communityApiSel = (SEL_CommunityApis) mocks.mock(SEL_CommunityApis.class);

        acm_pkg__CommunityApi__c communityApiMockProduct = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .packageName(PRODUCT_NAME)
            .assetType(PRODUCT_ASSET_TYPE)
            .assetVersion(ASSET_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__AnypointApiPages__x anypointApiPageMock = (acm_pkg__AnypointApiPages__x) new BLD_AnypointApiPage()
            .assetVersionId(communityApiMockProduct.acm_pkg__ApiId__c + ':' + communityApiMockProduct.acm_pkg__AssetVersion__c)
            .pageContent(PRODUCT_FEATURES)
            .pageName(PAGE_NAME)
            .mock();

        mocks.startStubbing();
        mocks.when(communityApiSel.sObjectType()).thenReturn(acm_pkg__CommunityApi__c.SObjectType);
        mocks.when(anypointApiPageSel.sObjectType()).thenReturn(acm_pkg__AnypointApiPages__x.SObjectType);
        mocks.when(communityApiSel.selectByIdAndCommunity((Set<Id>) fflib_Match.anyObject(), fflib_Match.anyString()))
            .thenReturn(new List<acm_pkg__CommunityApi__c>{ communityApiMockProduct });
        mocks.when(anypointApiPageSel.selectByAssetVersionIdsAndPageName((Set<string>) fflib_Match.anyObject(), fflib_Match.anyString()))
            .thenReturn(new List<acm_pkg__AnypointApiPages__x>{ anypointApiPageMock });
        mocks.stopStubbing();

        ORG_Application.selector.setMock(communityApiSel);
        ORG_Application.selector.setMock(anypointApiPageSel);

        Test.startTest();
        List<Map<string, string>> productFeatures = OSB_OD_ProductDetails_CTRL.getProductFeatures(communityApiMockProduct.Id);
        Test.stopTest();

        System.assertEquals(2, productFeatures.size(), 'Did not fetch all the features');
    }

    @IsTest
    static void shouldGetRelatedApiList() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_CommunityAssetVersions communityAssetVersionSel = (SEL_CommunityAssetVersions) mocks.mock(SEL_CommunityAssetVersions.class);
        SEL_CommunityApis communityApiSel = (SEL_CommunityApis) mocks.mock(SEL_CommunityApis.class);

        acm_pkg__CommunityApi__c communityApiMockProduct = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .packageName(PRODUCT_NAME)
            .assetType(PRODUCT_ASSET_TYPE)
            .assetVersion(ASSET_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityApi__c communityApiMockApi = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .packageName(PRODUCT_NAME)
            .assetType(API_ASSET_TYPE)
            .assetVersion(ASSET_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityAssetVersion__c communityAssetVersionMockProduct = (acm_pkg__CommunityAssetVersion__c) new BLD_CommunityAssetVersion()
            .parentAsset(communityApiMockProduct.Id)
            .versionGroup(VERSION_GROUP)
            .packageVersion(PACKAGE_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityAssetVersion__c communityAssetVersionMockApi = (acm_pkg__CommunityAssetVersion__c) new BLD_CommunityAssetVersion()
            .parentAsset(communityApiMockApi.Id)
            .versionGroup(VERSION_GROUP)
            .packageVersion(PACKAGE_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        mocks.startStubbing();
        mocks.when(communityApiSel.sObjectType()).thenReturn(acm_pkg__CommunityApi__c.SObjectType);
        mocks.when(communityAssetVersionSel.sObjectType()).thenReturn(acm_pkg__CommunityAssetVersion__c.SObjectType);
        mocks.when(
                communityAssetVersionSel.selectByParentAssetsAndCommunityName((Set<Id>) fflib_Match.anyObject(), fflib_Match.anyString())
            )
            .thenReturn(new List<acm_pkg__CommunityAssetVersion__c>{ communityAssetVersionMockProduct });
        mocks.when(
                communityAssetVersionSel.selectByParentGroupVersionIdsAndCommunityName(
                    (Set<Id>) fflib_Match.anyObject(),
                    fflib_Match.anyString()
                )
            )
            .thenReturn(new List<acm_pkg__CommunityAssetVersion__c>{ communityAssetVersionMockApi });
        mocks.when(communityApiSel.selectByIdAndCommunity((Set<Id>) fflib_Match.anyObject(), fflib_Match.anyString()))
            .thenReturn(new List<acm_pkg__CommunityApi__c>{ communityApiMockApi });

        mocks.stopStubbing();

        ORG_Application.selector.setMock(communityAssetVersionSel);
        ORG_Application.selector.setMock(communityApiSel);

        Test.startTest();
        List<acm_pkg__CommunityApi__c> communityApi = OSB_OD_ProductDetails_CTRL.getRelatedApiList(communityApiMockProduct.Id);
        Test.stopTest();

        System.assertEquals(PRODUCT_NAME, communityApi[0].acm_pkg__Name__c, 'did not get the correct api');
    }

    @IsTest
    static void shouldImperativeGetRelatedApiList() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_CommunityAssetVersions communityAssetVersionSel = (SEL_CommunityAssetVersions) mocks.mock(SEL_CommunityAssetVersions.class);
        SEL_CommunityApis communityApiSel = (SEL_CommunityApis) mocks.mock(SEL_CommunityApis.class);

        acm_pkg__CommunityApi__c communityApiMockProduct = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .packageName(PRODUCT_NAME)
            .assetType(PRODUCT_ASSET_TYPE)
            .assetVersion(ASSET_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityApi__c communityApiMockApi = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .packageName(PRODUCT_NAME)
            .assetType(API_ASSET_TYPE)
            .assetVersion(ASSET_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityAssetVersion__c communityAssetVersionMockProduct = (acm_pkg__CommunityAssetVersion__c) new BLD_CommunityAssetVersion()
            .parentAsset(communityApiMockProduct.Id)
            .versionGroup(VERSION_GROUP)
            .packageVersion(PACKAGE_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityAssetVersion__c communityAssetVersionMockApi = (acm_pkg__CommunityAssetVersion__c) new BLD_CommunityAssetVersion()
            .parentAsset(communityApiMockApi.Id)
            .versionGroup(VERSION_GROUP)
            .packageVersion(PACKAGE_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        mocks.startStubbing();
        mocks.when(communityApiSel.sObjectType()).thenReturn(acm_pkg__CommunityApi__c.SObjectType);
        mocks.when(communityAssetVersionSel.sObjectType()).thenReturn(acm_pkg__CommunityAssetVersion__c.SObjectType);
        mocks.when(
                communityAssetVersionSel.selectByParentAssetsAndCommunityName((Set<Id>) fflib_Match.anyObject(), fflib_Match.anyString())
            )
            .thenReturn(new List<acm_pkg__CommunityAssetVersion__c>{ communityAssetVersionMockProduct });
        mocks.when(
                communityAssetVersionSel.selectByParentGroupVersionIdsAndCommunityName(
                    (Set<Id>) fflib_Match.anyObject(),
                    fflib_Match.anyString()
                )
            )
            .thenReturn(new List<acm_pkg__CommunityAssetVersion__c>{ communityAssetVersionMockApi });
        mocks.when(communityApiSel.selectByIdAndCommunity((Set<Id>) fflib_Match.anyObject(), fflib_Match.anyString()))
            .thenReturn(new List<acm_pkg__CommunityApi__c>{ communityApiMockApi });

        mocks.stopStubbing();

        ORG_Application.selector.setMock(communityAssetVersionSel);
        ORG_Application.selector.setMock(communityApiSel);

        Test.startTest();
        List<acm_pkg__CommunityApi__c> communityApi = OSB_OD_ProductDetails_CTRL.imperativeGetRelatedApiList(communityApiMockProduct.Id);
        Test.stopTest();

        System.assertEquals(PRODUCT_NAME, communityApi[0].acm_pkg__Name__c, 'did not get the correct api');
    }

    @IsTest
    static void shouldGetParentAssetVersion() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_CommunityAssetVersions communityAssetVersionSel = (SEL_CommunityAssetVersions) mocks.mock(SEL_CommunityAssetVersions.class);

        acm_pkg__CommunityApi__c communityApiMockProduct = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .packageName(PRODUCT_NAME)
            .assetType(PRODUCT_ASSET_TYPE)
            .assetVersion(ASSET_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityApi__c communityApiMockApi = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .packageName(PRODUCT_NAME)
            .assetType(API_ASSET_TYPE)
            .assetVersion(ASSET_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityAssetVersion__c communityAssetVersionMockProduct = (acm_pkg__CommunityAssetVersion__c) new BLD_CommunityAssetVersion()
            .parentAsset(communityApiMockProduct.Id)
            .versionGroup(VERSION_GROUP)
            .packageVersion(PACKAGE_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityAssetVersion__c communityAssetVersionMockApi = (acm_pkg__CommunityAssetVersion__c) new BLD_CommunityAssetVersion()
            .parentAsset(communityApiMockApi.Id)
            .versionGroup(VERSION_GROUP)
            .packageVersion(PACKAGE_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        mocks.startStubbing();
        mocks.when(communityAssetVersionSel.sObjectType()).thenReturn(acm_pkg__CommunityAssetVersion__c.SObjectType);
        mocks.when(
                communityAssetVersionSel.selectByParentAssetsAndCommunityName((Set<Id>) fflib_Match.anyObject(), fflib_Match.anyString())
            )
            .thenReturn(new List<acm_pkg__CommunityAssetVersion__c>{ communityAssetVersionMockApi });
        mocks.when(communityAssetVersionSel.selectByIds((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<acm_pkg__CommunityAssetVersion__c>{ communityAssetVersionMockProduct });
        mocks.stopStubbing();

        ORG_Application.selector.setMock(communityAssetVersionSel);

        Test.startTest();
        acm_pkg__CommunityAssetVersion__c parentAsset = OSB_OD_ProductDetails_CTRL.getParentAssetVersion(communityApiMockApi.Id);
        Test.stopTest();

        System.assertEquals(communityApiMockProduct.Id, parentAsset.acm_pkg__ParentAsset__c, 'did not get the correct parent asset');
    }

    @IsTest
    static void shouldGetAnypointPage() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_AnypointApiPages anypointApiPageSel = (SEL_AnypointApiPages) mocks.mock(SEL_AnypointApiPages.class);
        SEL_CommunityApis communityApiSel = (SEL_CommunityApis) mocks.mock(SEL_CommunityApis.class);

        acm_pkg__CommunityApi__c communityApiMockProduct = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .packageName(PRODUCT_NAME)
            .assetType(PRODUCT_ASSET_TYPE)
            .assetVersion(ASSET_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__AnypointApiPages__x anypointApiPageMock = (acm_pkg__AnypointApiPages__x) new BLD_AnypointApiPage()
            .assetVersionId(communityApiMockProduct.acm_pkg__ApiId__c + ':' + communityApiMockProduct.acm_pkg__AssetVersion__c)
            .pageContent(PAGE_CONTENT)
            .pageName(PAGE_NAME)
            .mock();

        mocks.startStubbing();
        mocks.when(anypointApiPageSel.sObjectType()).thenReturn(acm_pkg__AnypointApiPages__x.SObjectType);
        mocks.when(communityApiSel.sObjectType()).thenReturn(acm_pkg__CommunityApi__c.SObjectType);
        mocks.when(anypointApiPageSel.selectByAssetVersionIdsAndPageName((Set<string>) fflib_Match.anyObject(), fflib_Match.anyString()))
            .thenReturn(new List<acm_pkg__AnypointApiPages__x>{ anypointApiPageMock });
        mocks.when(communityApiSel.selectByIdAndCommunity((Set<Id>) fflib_Match.anyObject(), fflib_Match.anyString()))
            .thenReturn(new List<acm_pkg__CommunityApi__c>{ communityApiMockProduct });
        mocks.stopStubbing();

        ORG_Application.selector.setMock(anypointApiPageSel);
        ORG_Application.selector.setMock(communityApiSel);

        Test.startTest();
        string anypointPage = OSB_OD_ProductDetails_CTRL.getAnypointPage(communityApiMockProduct.Id, PAGE_NAME);
        Test.stopTest();

        System.assertEquals(PAGE_CONTENT, anypointPage, 'did not fetch the correct anypoint page');
    }
}