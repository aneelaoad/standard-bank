/**
 * @description a controller class for the product catalogue page on OneHub
 *
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 */
public without sharing class OSB_OD_ProductCatalogue_CTRL {
    /**
     * @description returns a product map that contains the product info as well as the category
     *
     * @return a list of product maps that contain product info and category
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<string, string>> getProductMap() {
        List<Map<string, string>> result = new List<Map<string, string>>();
        Map<string, Map<string, string>> productIdMap = new Map<string, Map<string, string>>();
        Map<string, string> productToAssetversionId = new Map<string, string>();
        Map<string, string> productPageMap = new Map<string, string>();
        Set<Id> productIdSet = new Set<Id>();

        List<acm_pkg__CommunityApi__c> products = getProducts();
        Set<acm_pkg__CommunityApi__c> productSet = new Set<acm_pkg__CommunityApi__c>();
        productSet.addAll(products);
        Set<string> productAnypointIds = getAnypointIds(products);
        for (acm_pkg__CommunityApi__c p : products) {
            productIdSet.add(p.Id);
        }
        productToAssetversionId = generateAssetVersionId(productIdSet);
        productPageMap = getAnypointPages(productToAssetversionId);
        List<acm_pkg__AnypointAssetCategories__x> categories = getCategories(productAnypointIds);
        for (acm_pkg__CommunityApi__c p : products) {
            Map<string, string> productMap = createProductMap(p);
            productIdMap.put(p.acm_pkg__ApiId__c, productMap);
            if (productPageMap.get(p.Id) != null) {
                updateMapKey(productMap, 'Icon', productPageMap.get(p.Id).substringBetween('(', ')'));
            }
        }

        for (acm_pkg__AnypointAssetCategories__x c : categories) {
            if (productIdMap.containsKey(c.acm_pkg__AssetId__c)) {
                Map<string, string> product = productIdMap.get(c.acm_pkg__AssetId__c);
                productIdMap.remove(c.acm_pkg__AssetId__c);
                updateMapKey(product, 'Category', c.acm_pkg__Category__c.split(':')[1]);
                result.add(product);
            }
        }
        return result;
    }

    /**
     * @description a helper method that fetches a products categories
     *
     * @param assetIds a list of AnyPoint asset Id's
     * @return a list of multiple product's categories
     */
    private static List<acm_pkg__AnypointAssetCategories__x> getCategories(Set<string> assetIds) {
        List<acm_pkg__AnypointAssetCategories__x> categories = SEL_AnypointCategories.newInstance()
            .selectByAssetIdAndDisplayName(assetIds, 'Category');
        return categories;
    }

    /**
     * @description returns a list of api products that exist in OneHub
     *
     * @return a list of api products that exist in OneHub
     */
    private static List<acm_pkg__CommunityApi__c> getProducts() {
        List<acm_pkg__CommunityApi__c> products = SEL_CommunityApis.newInstance().selectByAssetTypeAndCommunity('api-group', 'OneHub');
        return products;
    }

    /**
     * @description returns a set of acm_pkg__ApiId__c
     *
     * @param products a list of acm_pkg__CommunityApi__c
     *
     * @return a set of ids as string
     */
    private static Set<string> getAnypointIds(List<acm_pkg__CommunityApi__c> products) {
        Set<string> productAnypointIds = new Set<string>();
        for (acm_pkg__CommunityApi__c p : products) {
            productAnypointIds.add(p.acm_pkg__ApiId__c);
        }
        return productAnypointIds;
    }

    /**
     * @description creates an asset version id that can be used to query anypoint pages
     *
     * @param productIds a list of product id
     * @return the correctly formatted asset version id
     */
    private static Map<string, string> generateAssetVersionId(Set<Id> productIds) {
        Map<string, string> productToAssetVersionMap = new Map<string, string>();
        List<acm_pkg__CommunityApi__c> products = SEL_CommunityApis.newInstance().selectByIdAndCommunity(productIds, 'OneHub');
        for (acm_pkg__CommunityApi__c p : products) {
            string anypointId = p.acm_pkg__ApiId__c;
            string anypointVersion = p.acm_pkg__AssetVersion__c;
            string assetVersionId = anypointId + ':' + anypointVersion;
            productToAssetVersionMap.put(assetVersionId, p.Id);
        }
        return productToAssetVersionMap;
    }

    /**
     * @description a method that can return pages from AnyPoint Exchange
     *
     * @param productToAssetVersionId a map of product id and anypoint asset version ids
     * @return returns a map of product id and anypoint icons
     */
    private static Map<string, string> getAnypointPages(Map<string, string> productToAssetVersionId) {
        Map<string, string> productPageMap = new Map<string, string>();
        Set<string> anypointIds = new Set<string>();
        anypointIds = productToAssetVersionId.keySet();
        List<acm_pkg__AnypointApiPages__x> anypointPages = SEL_AnypointApiPages.newInstance()
            .selectByAssetVersionIdsAndPageName(anypointIds, 'Icon');
        for (acm_pkg__AnypointApiPages__x page : anypointPages) {
            string productId = productToAssetVersionId.get(page.acm_pkg__AssetVersionId__c);
            productPageMap.put(productId, page.acm_pkg__PageContent__c);
        }
        return productPageMap;
    }

    /**
     * @description returns a map of products
     *
     * @param product a acm_pkg__CommunityApi__c object
     *
     * @return a map of product objects
     */
    private static Map<string, string> createProductMap(acm_pkg__CommunityApi__c product) {
        Map<string, string> productMap = createEmptyProductMap();
        updateMapKey(productMap, 'Id', product.Id);
        updateMapKey(productMap, 'Name', product.acm_pkg__Name__c);
        if (product.acm_pkg__Description__c != null) {
            updateMapKey(productMap, 'Description', product.acm_pkg__Description__c);
        }
        if (product.acm_pkg__Icon__c != null) {
            updateMapKey(productMap, 'Icon', product.acm_pkg__Icon__c);
        }
        return productMap;
    }

    /**
     * @description a helper method that creates the product map
     *
     * @return an empty map template for a product map
     */
    private static Map<string, string> createEmptyProductMap() {
        Map<string, string> product = new Map<string, string>{
            'Id' => '',
            'AssetVersionId' => '',
            'Name' => '',
            'Description' => '',
            'Icon' => '',
            'Category' => '',
            'IsExternal' => ''
        };
        return product;
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