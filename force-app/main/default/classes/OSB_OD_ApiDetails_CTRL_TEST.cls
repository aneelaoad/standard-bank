/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description test class for OSB_OD_ApiDetails_CTRL
 *
 * @LastModified February 2023
 * @UserStory SFP-21061
 * @LastModifiedReason Added shouldGetApiBaseUrl to cover new method
 */
@IsTest
private class OSB_OD_ApiDetails_CTRL_TEST {
    private static final string PRODUCT_NAME = 'Test Product';
    private static final string API_NAME = 'Test Api';
    private static final string COMMUNITY_NAME = 'TestCommunity';
    private static final string ASSET_VERSION = '1.0.0';
    private static final string API_ASSET_TYPE = 'rest-api';
    private static final string PRODUCT_ASSET_TYPE = 'api-group';
    private static final string PAGE_NAME = 'test page';
    private static final string PAGE_CONTENT = 'test page content';
    public static final String VERSION_GROUP = 'v1';
    public static final String PACKAGE_VERSION = '1.0.0';
    public static final string BASE_URL = 'test/baseurl';

    @IsTest
    static void shouldGetParentApiPage() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_AnypointApiPages anypointApiPageSel = (SEL_AnypointApiPages) mocks.mock(
            SEL_AnypointApiPages.class
        );
        SEL_CommunityAssetVersions communityAssetVersionSel = (SEL_CommunityAssetVersions) mocks.mock(
            SEL_CommunityAssetVersions.class
        );
        SEL_CommunityApis communityApiSel = (SEL_CommunityApis) mocks.mock(
            SEL_CommunityApis.class
        );

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

        acm_pkg__AnypointApiPages__x anypointApiPageMock = (acm_pkg__AnypointApiPages__x) new BLD_AnypointApiPage()
            .assetVersionId(
                communityApiMockProduct.acm_pkg__ApiId__c +
                ':' +
                communityApiMockProduct.acm_pkg__AssetVersion__c
            )
            .pageContent(PAGE_CONTENT)
            .pageName(PAGE_NAME)
            .mock();

        mocks.startStubbing();
        mocks.when(communityAssetVersionSel.sObjectType())
            .thenReturn(acm_pkg__CommunityAssetVersion__c.SObjectType);
        mocks.when(
                communityAssetVersionSel.selectByParentAssetsAndCommunityName(
                    (Set<Id>) fflib_Match.anyObject(),
                    fflib_Match.anyString()
                )
            )
            .thenReturn(
                new List<acm_pkg__CommunityAssetVersion__c>{
                    communityAssetVersionMockApi
                }
            );
        mocks.when(
                communityAssetVersionSel.selectByIdsAndCommunityName(
                    (Set<Id>) fflib_Match.anyObject(),
                    fflib_Match.anyString()
                )
            )
            .thenReturn(
                new List<acm_pkg__CommunityAssetVersion__c>{
                    communityAssetVersionMockProduct
                }
            );
        mocks.when(communityApiSel.sObjectType())
            .thenReturn(acm_pkg__CommunityApi__c.SObjectType);
        mocks.when(
                communityApiSel.selectByIdAndCommunity(
                    (Set<Id>) fflib_Match.anyObject(),
                    fflib_Match.anyString()
                )
            )
            .thenReturn(
                new List<acm_pkg__CommunityApi__c>{ communityApiMockProduct }
            );
        mocks.when(anypointApiPageSel.sObjectType())
            .thenReturn(acm_pkg__AnypointApiPages__x.SObjectType);
        mocks.when(
                anypointApiPageSel.selectByAssetVersionIdsAndPageName(
                    (Set<string>) fflib_Match.anyObject(),
                    fflib_Match.anyString()
                )
            )
            .thenReturn(
                new List<acm_pkg__AnypointApiPages__x>{ anypointApiPageMock }
            );
        mocks.stopStubbing();

        ORG_Application.selector.setMock(communityAssetVersionSel);
        ORG_Application.selector.setMock(communityApiSel);
        ORG_Application.selector.setMock(anypointApiPageSel);

        Test.startTest();
        string apiPage = OSB_OD_ApiDetails_CTRL.getParentApiPage(
            communityApiMockApi.Id,
            PAGE_NAME
        );
        Test.stopTest();

        System.assertEquals(
            PAGE_CONTENT,
            apiPage,
            'did not fetch the correct api page'
        );
    }

    @IsTest
    static void shouldGetSiblingApis() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_CommunityAssetVersions communityAssetVersionSel = (SEL_CommunityAssetVersions) mocks.mock(
            SEL_CommunityAssetVersions.class
        );
        SEL_CommunityApis communityApiSel = (SEL_CommunityApis) mocks.mock(
            SEL_CommunityApis.class
        );

        acm_pkg__CommunityApi__c communityApiMockProduct = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .packageName(PRODUCT_NAME)
            .assetType(PRODUCT_ASSET_TYPE)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityApi__c communityApiMockApi = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .packageName(PRODUCT_NAME)
            .assetType(API_ASSET_TYPE)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityAssetVersion__c communityAssetVersionMockProduct = (acm_pkg__CommunityAssetVersion__c) new BLD_CommunityAssetVersion()
            .parentAsset(communityApiMockProduct.Id)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityAssetVersion__c communityAssetVersionMockApi = (acm_pkg__CommunityAssetVersion__c) new BLD_CommunityAssetVersion()
            .parentAsset((Id) communityApiMockApi.Id)
            .communityName(COMMUNITY_NAME)
            .parentGroupVersion((string) communityAssetVersionMockProduct.Id)
            .mock();

        mocks.startStubbing();
        mocks.when(communityAssetVersionSel.sObjectType())
            .thenReturn(acm_pkg__CommunityAssetVersion__c.SObjectType);
        mocks.when(
                communityAssetVersionSel.selectByParentAssetsAndCommunityName(
                    (Set<Id>) fflib_Match.anyObject(),
                    fflib_Match.anyString()
                )
            )
            .thenReturn(
                new List<acm_pkg__CommunityAssetVersion__c>{
                    communityAssetVersionMockApi
                }
            );
        mocks.when(
                communityAssetVersionSel.selectByIdsAndCommunityName(
                    (Set<Id>) fflib_Match.anyObject(),
                    fflib_Match.anyString()
                )
            )
            .thenReturn(
                new List<acm_pkg__CommunityAssetVersion__c>{
                    communityAssetVersionMockProduct
                }
            );
        mocks.when(communityApiSel.sObjectType())
            .thenReturn(acm_pkg__CommunityApi__c.SObjectType);
        mocks.when(
                communityApiSel.selectByIdAndCommunity(
                    (Set<Id>) fflib_Match.anyObject(),
                    fflib_Match.anyString()
                )
            )
            .thenReturn(
                new List<acm_pkg__CommunityApi__c>{ communityApiMockProduct }
            );
        mocks.when(
                communityAssetVersionSel.selectByParentGroupVersionIdsAndCommunityName(
                    (Set<Id>) fflib_Match.anyObject(),
                    fflib_Match.anyString()
                )
            )
            .thenReturn(
                new List<acm_pkg__CommunityAssetVersion__c>{
                    communityAssetVersionMockApi
                }
            );
        mocks.stopStubbing();

        ORG_Application.selector.setMock(communityAssetVersionSel);
        ORG_Application.selector.setMock(communityApiSel);

        Test.startTest();
        List<acm_pkg__CommunityApi__c> apis = OSB_OD_ApiDetails_CTRL.getSiblingApis(
            communityApiMockApi.Id
        );
        Test.stopTest();

        System.assertEquals(1, apis.size(), 'did not fetch correct apis');
    }

    @IsTest
    static void shouldGetParentAssetVersion() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_CommunityAssetVersions communityAssetVersionSel = (SEL_CommunityAssetVersions) mocks.mock(
            SEL_CommunityAssetVersions.class
        );

        acm_pkg__CommunityAssetVersion__c communityAssetVersionMockProduct = (acm_pkg__CommunityAssetVersion__c) new BLD_CommunityAssetVersion()
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__CommunityAssetVersion__c communityAssetVersionMockApi = (acm_pkg__CommunityAssetVersion__c) new BLD_CommunityAssetVersion()
            .communityName(COMMUNITY_NAME)
            .parentGroupVersion((string) communityAssetVersionMockProduct.Id)
            .mock();

        mocks.startStubbing();
        mocks.when(communityAssetVersionSel.sObjectType())
            .thenReturn(acm_pkg__CommunityAssetVersion__c.SObjectType);
        mocks.when(
                communityAssetVersionSel.selectByParentAssetsAndCommunityName(
                    (Set<Id>) fflib_Match.anyObject(),
                    fflib_Match.anyString()
                )
            )
            .thenReturn(
                new List<acm_pkg__CommunityAssetVersion__c>{
                    communityAssetVersionMockApi
                }
            );
        mocks.when(
                communityAssetVersionSel.selectByIds(
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(
                new List<acm_pkg__CommunityAssetVersion__c>{
                    communityAssetVersionMockProduct
                }
            );
        mocks.stopStubbing();

        ORG_Application.selector.setMock(communityAssetVersionSel);

        Test.startTest();
        acm_pkg__CommunityAssetVersion__c parentAsset = OSB_OD_ApiDetails_CTRL.getParentAssetVersion(
            communityAssetVersionMockApi.Id
        );
        Test.stopTest();

        System.assertEquals(
            COMMUNITY_NAME,
            parentAsset.acm_pkg__CommunityName__c,
            'did not fetch the correct parent asset'
        );
    }

    @IsTest
    static void shouldGetApiBaseUrl() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_CommunityApis communityApiSel = (SEL_CommunityApis) mocks.mock(
            SEL_CommunityApis.class
        );
        SEL_AnypointApiInstances apiInstanceSel = (SEL_AnypointApiInstances) mocks.mock(
            SEL_AnypointApiInstances.class
        );

        acm_pkg__CommunityApi__c communityApiMockApi = (acm_pkg__CommunityApi__c) new BLD_CommunityApi()
            .packageName(PRODUCT_NAME)
            .assetType(PRODUCT_ASSET_TYPE)
            .assetVersion(ASSET_VERSION)
            .communityName(COMMUNITY_NAME)
            .mock();

        acm_pkg__AnypointApiInstances__x anypointApiInstanceMock = (acm_pkg__AnypointApiInstances__x) new BLD_AnypointApiInstance()
            .endpoint(BASE_URL)
            .environment(COMMUNITY_NAME)
            .mock();

        mocks.startStubbing();
        mocks.when(communityApiSel.sObjectType())
            .thenReturn(acm_pkg__CommunityApi__c.SObjectType);
        mocks.when(
                communityApiSel.selectById((Set<Id>) fflib_Match.anyObject())
            )
            .thenReturn(
                new List<acm_pkg__CommunityApi__c>{ communityApiMockApi }
            );
        mocks.when(apiInstanceSel.sObjectType())
            .thenReturn(acm_pkg__AnypointApiInstances__x.SObjectType);
        mocks.when(
                apiInstanceSel.selectByAssetVersionId(
                    (Set<string>) fflib_Match.anyObject()
                )
            )
            .thenReturn(
                new List<acm_pkg__AnypointApiInstances__x>{
                    anypointApiInstanceMock
                }
            );
        mocks.stopStubbing();

        ORG_Application.selector.setMock(communityApiSel);
        ORG_Application.selector.setMock(apiInstanceSel);

        Test.startTest();
        List<acm_pkg__AnypointApiInstances__x> baseUrl = OSB_OD_ApiDetails_CTRL.getApiBaseUrl(
            communityApiMockApi.id
        );
        Test.stopTest();

        Assert.areEqual(
            BASE_URL,
            baseUrl[0].acm_pkg__Endpoint__c,
            'did not fetch the correct base url'
        );
    }
}