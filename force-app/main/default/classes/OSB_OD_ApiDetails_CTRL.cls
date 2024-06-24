/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description A controller for the OneDeveloper api details page
 *
 * @LastModified January 2023
 * @UserStory SFP-21061
 * @LastModifiedReason Updated class to cater for fetching api base url, product name and documents
 */
public without sharing class OSB_OD_ApiDetails_CTRL {
    /**
     * @description a method that can return a page from AnyPoint Exchange
     *
     * @param apiId a api id
     * @param pageName a page name
     * @return returns an anypoint page content as a string
     */
    @AuraEnabled(cacheable=true)
    public static string getParentApiPage(Id apiId, string pageName) {
        acm_pkg__CommunityApi__c parentProduct = getParentProduct(apiId);
        string parentId = generateAssetVersionId(parentProduct);
        string parentPage = SEL_AnypointApiPages.newInstance()
                .selectByAssetVersionIdsAndPageName(
                    new Set<string>{ parentId },
                    pageName
                )[0]
            .acm_pkg__PageContent__c;
        return parentPage;
    }

    /**
     * @description returns all api's related to an api
     *
     * @param apiId a api id
     * @return a list of api's related to the api
     */
    @AuraEnabled(cacheable=true)
    public static List<acm_pkg__CommunityApi__c> getSiblingApis(Id apiId) {
        acm_pkg__CommunityApi__c parentProduct = getParentProduct(apiId);
        List<acm_pkg__CommunityApi__c> siblingApis = getRelatedApiList(
            parentProduct.Id
        );
        return siblingApis;
    }

    /**
     * @description a method that will return the asset version of an api's parent
     *
     * @param apiId an api Id
     * @return acm_pkg__CommunityAssetVersion__c object
     */
    @AuraEnabled(cacheable=true)
    public static acm_pkg__CommunityAssetVersion__c getParentAssetVersion(
        Id apiId
    ) {
        Id assetVersionObject = (Id) SEL_CommunityAssetVersions.newInstance()
                .selectByParentAssetsAndCommunityName(
                    new Set<Id>{ apiId },
                    'OneHub'
                )[0]
            .acm_pkg__ParentGroupVersion__c;
        acm_pkg__CommunityAssetVersion__c parentAssetVersion = SEL_CommunityAssetVersions.newInstance()
            .selectByIds(new Set<Id>{ assetVersionObject })[0];
        return parentAssetVersion;
    }

    /**
     * @description a helper method that will return an api's parent product info
     *
     * @param  apiId an api Id
     * @return a acm_pkg__CommunityApi__c object
     */
    @AuraEnabled(cacheable=true)
    public static acm_pkg__CommunityApi__c getParentProduct(Id apiId) {
        string parentId = (SEL_CommunityAssetVersions.newInstance()
                .selectByParentAssetsAndCommunityName(
                    new Set<Id>{ apiId },
                    'OneHub'
                )[0])
            .acm_pkg__ParentGroupVersion__c;
        string parentCommunityApiId = SEL_CommunityAssetVersions.newInstance()
                .selectByIdsAndCommunityName(
                    new Set<Id>{ parentId },
                    'OneHub'
                )[0]
            .acm_pkg__ParentAsset__c;
        acm_pkg__CommunityApi__c parentProduct = SEL_CommunityApis.newInstance()
            .selectByIdAndCommunity(
                new Set<Id>{ parentCommunityApiId },
                'OneHub'
            )[0];
        return parentProduct;
    }

    /**
     * @description returns apis related to a product that exists within OneHub
     *
     * @param productId a api product's id
     * @return a list of api's related to the product
     */
    private static List<acm_pkg__CommunityApi__c> getRelatedApiList(
        Id productId
    ) {
        Set<Id> apiIdList = new Set<Id>();
        Id productToApi = SEL_CommunityAssetVersions.newInstance()
                .selectByParentAssetsAndCommunityName(
                    new Set<Id>{ productId },
                    'OneHub'
                )[0]
            .Id;
        List<acm_pkg__CommunityAssetVersion__c> communityAssetVersionList = SEL_CommunityAssetVersions.newInstance()
            .selectByParentGroupVersionIdsAndCommunityName(
                new Set<Id>{ productToApi },
                'OneHub'
            );

        for (acm_pkg__CommunityAssetVersion__c a : communityAssetVersionList) {
            apiIdList.add(a.acm_pkg__ParentAsset__c);
        }

        List<acm_pkg__CommunityApi__c> apiList = SEL_CommunityApis.newInstance()
            .selectByIdAndCommunity(apiIdList, 'OneHub');
        return apiList;
    }

    /**
     * @description creates an asset version id that can be used to query anypoint pages
     *
     * @param product a acm_pkg__CommunityApi__c object
     * @return the correctly formatted asset version id
     */
    private static string generateAssetVersionId(
        acm_pkg__CommunityApi__c product
    ) {
        string anypointId = product.acm_pkg__ApiId__c;
        string anypointVersion = product.acm_pkg__AssetVersion__c;
        string assetVersionId = anypointId + ':' + anypointVersion;
        return assetVersionId;
    }

    /**
     * @description fetch api base url
     *
     * @param api asset version id
     * @return the base urls and environments
     */
    @AuraEnabled(cacheable=true)
    public static List<acm_pkg__AnypointApiInstances__x> getApiBaseUrl(
        Id apiId
    ) {
        List<acm_pkg__CommunityApi__c> apiInstance = SEL_CommunityApis.newInstance()
            .selectById(new Set<Id>{ apiId });
        String assetVersionId = generateAssetVersionId(apiInstance[0]);
        List<acm_pkg__AnypointApiInstances__x> apiInstances = SEL_AnypointApiInstances.newInstance()
            .selectByAssetVersionId(new Set<string>{ assetVersionId });
        return apiInstances;
    }
}