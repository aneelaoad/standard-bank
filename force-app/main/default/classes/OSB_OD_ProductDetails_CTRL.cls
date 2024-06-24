/**
 * @description product details page controller class
 * 
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 */
public without sharing class OSB_OD_ProductDetails_CTRL {
    
    /**
     * @description returns a list that is used to navigate between api and product
     *
     * @param objectId a communityApi id
     * @return a list of product and child api's if required
     */
    @AuraEnabled
    public static List<acm_pkg__CommunityApi__c> getPathForBreadCrumb(Id objectId){
        List<acm_pkg__CommunityApi__c> results = new List<acm_pkg__CommunityApi__c>();
        acm_pkg__CommunityApi__c parentInfo = null;
        acm_pkg__CommunityApi__c productInfo = SEL_CommunityApis.newInstance().selectByIdAndCommunity(new Set<Id>{objectId}, 'OneHub')[0];
        if (productInfo.acm_pkg__AssetType__c == 'rest-api') {
            parentInfo = getParentProduct(objectId);
            results.add(parentInfo);
        }
        results.add(productInfo);
        return results;
    }

    /**
     * @description returns an object with the relationship between products and api's
     *
     * @param assetId a communityApi Id
     * @return acm_pkg__CommunityAssetVersion__c object
     */
    @AuraEnabled(cacheable=true)
    public static acm_pkg__CommunityAssetVersion__c getCommunityAssetVersion(Id assetId){
        acm_pkg__CommunityAssetVersion__c assetVersionObject = SEL_CommunityAssetVersions.newInstance().selectByParentAssetsAndCommunityName(new Set<Id>{assetId}, 'OneHub')[0];
        return assetVersionObject;
    }

    /**
     * @description a method that returns all of a products features from the AnyPoint features page
     *
     * @param productId a product Id
     * @return a list of product feature maps
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<string, string>> getProductFeatures(Id productId) {
        string assetVersionId = generateAssetVersionId(productId);
        string productFeaturePage = '';
        productFeaturePage = SEL_AnypointApiPages.newInstance().selectByAssetVersionIdsAndPageName(new Set<string>{assetVersionId}, 'Product Features')[0].acm_pkg__PageContent__c;
        List<Map<string, string>> results = cleanUpFeatures(productFeaturePage);
        return results;
    }

    /**
     * @description returns apis related to a product that exists within OneHub
     *
     * @param productId a api product's id
     * @return a list of api's related to the product
     */
    @AuraEnabled(cacheable=true)
    public static List<acm_pkg__CommunityApi__c> getRelatedApiList(Id productId){
        Set<Id> apiIdList = new Set<Id>();
        Id productToApi = SEL_CommunityAssetVersions.newInstance().selectByParentAssetsAndCommunityName(new Set<Id>{productId}, 'OneHub')[0].Id;
        List<acm_pkg__CommunityAssetVersion__c> communityAssetVersionList = SEL_CommunityAssetVersions.newInstance().selectByParentGroupVersionIdsAndCommunityName(new Set<Id>{productToApi}, 'OneHub');
        
        for (acm_pkg__CommunityAssetVersion__c a : communityAssetVersionList) {
            apiIdList.add(a.acm_pkg__ParentAsset__c);
        }

        List<acm_pkg__CommunityApi__c> apiList = SEL_CommunityApis.newInstance().selectByIdAndCommunity(apiIdList, 'OneHub');
        return apiList;
    }

    /**
     * @description returns apis related to a product that exists within OneHub
     *
     * @param productId a api product's id
     * @return a list of api's related to the product
     */
    @AuraEnabled
    public static List<acm_pkg__CommunityApi__c> imperativeGetRelatedApiList(Id productId){
        Set<Id> apiIdList = new Set<Id>();
        Id productToApi = SEL_CommunityAssetVersions.newInstance().selectByParentAssetsAndCommunityName(new Set<Id>{productId}, 'OneHub')[0].Id;
        List<acm_pkg__CommunityAssetVersion__c> communityAssetVersionList = SEL_CommunityAssetVersions.newInstance().selectByParentGroupVersionIdsAndCommunityName(new Set<Id>{productToApi}, 'OneHub');
        
        for (acm_pkg__CommunityAssetVersion__c a : communityAssetVersionList) {
            apiIdList.add(a.acm_pkg__ParentAsset__c);
        }

        List<acm_pkg__CommunityApi__c> apiList = SEL_CommunityApis.newInstance().selectByIdAndCommunity(apiIdList, 'OneHub');
        return apiList;
    }

    /**
     * @description a method that will return the asset version of an api's parent
     *
     * @param apiId an api Id
     * @return acm_pkg__CommunityAssetVersion__c object
     */
    @AuraEnabled(cacheable=true)
    public static acm_pkg__CommunityAssetVersion__c getParentAssetVersion(Id apiId){
        Id assetVersionObject = (Id)SEL_CommunityAssetVersions.newInstance().selectByParentAssetsAndCommunityName(new Set<Id>{apiId}, 'OneHub')[0].acm_pkg__ParentGroupVersion__c;
        acm_pkg__CommunityAssetVersion__c parentAssetVersion = SEL_CommunityAssetVersions.newInstance().selectByIds(new Set<Id>{assetVersionObject})[0];
        return parentAssetVersion;
    }

    /**
     * @description a method that can return a page from AnyPoint Exchange
     *
     * @param recordId a record id
     * @param pageName a page name
     * @return returns an anypoint page content as a string
     */
    @AuraEnabled(cacheable=true)
    public static string getAnypointPage(Id recordId, string pageName){
        string anypointId = generateAssetVersionId(recordId);
        string anypointPage = SEL_AnypointApiPages.newInstance().selectByAssetVersionIdsAndPageName(new Set<string>{anypointId}, pageName)[0].acm_pkg__PageContent__c;
        return anypointPage;
    }

    /**
     * @description a helper method that converts a product feature string into a map
     *
     * @param productFeaturePage string a product feature page string
     * @return a list of product feature maps
     */
    private static List<Map<string, string>> cleanUpFeatures(string productFeaturePage) {
        List<string> featuresList = productFeaturePage.split('------');
        List<Map<string, string>> results = new List<Map<string, string>>();
        for (Integer i = 0; i < featuresList.size(); i++) {
            List<string> feature = new List<string>(featuresList[i].split('\n\n'));

            Set<string> cleanUp = new Set<string>(feature);
            cleanUp.remove('');
            feature = new List<string>(cleanUp);
            Map<string, string> featureMap = createFeatureMap();
            featureMap = updateMapKey(featureMap, 'id', String.valueOf(i));
            featureMap = updateMapKey(featureMap, 'heading', feature[0]);
            featureMap = updateMapKey(featureMap, 'body', feature[1]);
            if (feature.size() >= 3) {
                featureMap = updateMapKey(featureMap, 'icon', feature[2]);
                featureMap = updateMapKey(featureMap, 'hasIcon', 'true');
            }

            results.add(featureMap);
        }
        return results;
    }

    /**
     * @description creates an asset version id that can be used to query anypoint pages
     *
     * @param productId a product id
     * @return the correctly formatted asset version id
     */
    private static string generateAssetVersionId(string productId) {
        acm_pkg__CommunityApi__c product = SEL_CommunityApis.newInstance().selectByIdAndCommunity(new Set<Id>{productId}, 'OneHub')[0];
        string anypointId = product.acm_pkg__ApiId__c;
        string anypointVersion = product.acm_pkg__AssetVersion__c;
        string assetVersionId = anypointId + ':' + anypointVersion;
        return assetVersionId;
    }

    /**
     * @description a helper method that will return an api's parent product info
     *
     * @param  apiId an api Id
     * @return a acm_pkg__CommunityApi__c object
     */
    private static acm_pkg__CommunityApi__c getParentProduct(Id apiId) {
        string parentId = SEL_CommunityAssetVersions.newInstance().selectByParentAssetsAndCommunityName(new Set<Id>{apiId}, 'OneHub')[0].acm_pkg__ParentGroupVersion__c;
        string parentCommunityApiId = SEL_CommunityAssetVersions.newInstance().selectByIdsAndCommunityName(new Set<Id>{parentId}, 'OneHub')[0].acm_pkg__ParentAsset__c;
        acm_pkg__CommunityApi__c parentProduct = SEL_CommunityApis.newInstance().selectByIdAndCommunity(new Set<Id>{parentCommunityApiId}, 'OneHub')[0];
        return parentProduct;
    }

    /**
     * @description creates an empty map template for product features
     *
     * @return an empty map of product features
     */
    private static Map<string, string> createFeatureMap() {
        Map<string, string> featureMap = new Map<string, string>{
            'id' => '',
            'heading' => '',
            'body' => '',
            'hasIcon' => 'false',
            'icon' => ''
        };

        return featureMap;
    }

    /**
     * @description safely updates a map by providing the key value pair
     *
     * @param inputMap a input map
     * @param key a map key
     * @param newValue a new value
     * @return if the map contains the key it will return the updated map
     */
    private static Map<string, string> updateMapKey(Map<string, string> inputMap, string key, string newValue) {
        if (inputMap.containsKey(key)) {
            inputMap.put(key, newValue);
            return inputMap;
        }
        return null;
    }
}