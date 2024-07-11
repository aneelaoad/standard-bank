/**
 * 
 * @description MallDataServiceHandler
 * @author Maham Hasan
 * @since 
 */
public with sharing class MallDataServiceHandler {

    public static final String DEFAULT_CONTENT_LANGUAGE_ISO = 'en';
    public static final String DEFAULT_USER_COUNTRY = 'South Africa';
    public static final String ICON_CONTENT_UNIT_TRANSLATION = 'iconCUT';
    public static final String CONTENT_UNIT_TRANSLATION = 'translationCUT';
    public static MallUserContext mallUserContext = new MallUserContext();
    public static Boolean mallMultiLanguageContent = false;
    //UserContext Setup Variables
    public static String userContentLanguage = '';
    public static String userCountry = '';
    public static User currentUser;

    /**
     * 
     * @description MallUserContext Class
     */
    public class MallUserContext {
        public String mallUserSelectedCountry;
        public String mallUserSelectedLanguage;
        public List<String> selectedSegmentNames;
        public List<String> selectedSegmentIds;
        public List<String> selectedCategoryNames;
        public List<String> selectedCategoryIds;
    }

    /**
     * 
     * @description MallDataServiceHandler
     */
    public MallDataServiceHandler() {
        //sets the user context based on the stored database information
        MallDataServiceHandler.setUserContext();
    } 

    /**
     * 
     * @description  MallDataServiceHandler Constructor
     * @param mallContext String
     */
    public MallDataServiceHandler(String mallContext) {
        //sets the user context based on the stored database information
        MallDataServiceHandler.setUserContext();
        //sets the user context based on the parameters passed
        MallDataServiceHandler.processMallUserState(mallContext);
    }

    /**
     * 
     * @description processMallUserState
     * @param mallContext String
     */
    public static void processMallUserState(String mallContext) {
        if(String.isNotBlank(mallContext)) {
            mallUserContext = (MallUserContext)System.JSON.deserialize(mallContext, MallUserContext.class);
            userCountry = mallUserContext.mallUserSelectedCountry;
            userContentLanguage = mallUserContext.mallUserSelectedLanguage;
        }
    }

    /**
     * 
     * @description setUserContext
     */
    public static void setUserContext() {
        String currentUserId = UserInfo.getUserId();
        if(currentUser == NULL && !Auth.CommunitiesUtil.isGuestUser()) {
            List<User> users = SEL_Users.newInstance().selectById(new Set<Id>{(Id)currentUserId});
            if(users.size() > 0 ) {
                currentUser = users[0];
            }
            String userLanguageISOCode = MallUserPreferencesManagement.getUserPreferences().userLanguage;
            if(String.isNotBlank(userLanguageISOCode)) {
                userContentLanguage = userLanguageISOCode;
            } else {
                userContentLanguage = DEFAULT_CONTENT_LANGUAGE_ISO; 
            }
            if(String.isNotBlank(currentUser.User_Franco__c)) {
                userCountry = currentUser.User_Franco__c;
            } else {
                userCountry = DEFAULT_USER_COUNTRY; 
            }
        }
    }

    /**
     * 
     * @description Mall State initialization
     * @return   DenormalizedMallState 
     */
    public DenormalizedMallState initialization() {
        List<String> selectedSegmentNames = mallUserContext.selectedSegmentNames;
        List<DenormalizedTag> segments = getSegmentTags ();
        List<DenormalizedTag> defaultSegment = new List<DenormalizedTag>();
        if(selectedSegmentNames == null || selectedSegmentNames.size() == 0) {
            for(DenormalizedTag segment : segments) {
                if(segment.name == System.Label.MALL_DEFAULT_SEGMENT){
                    defaultSegment.add(segment);
                    break;
                } 
            }
        } else if(selectedSegmentNames != null && selectedSegmentNames.size() > 0) {
            for(DenormalizedTag segment : segments) {
                if(selectedSegmentNames.contains(segment.name.toLowerCase())) {
                    defaultSegment.add(segment);
                    break;
                }
            } 
        }
        return refreshMallState(segments, defaultSegment);
    }

    /**
     * 
     * @description refreshMallState
     * @param segments List of Denormalized Tags
     * @param selectedSegments List of Denormalized Tags
     * @return   DenormalizedMallState 
     */
    public DenormalizedMallState refreshMallState(List<DenormalizedTag> segments, List<DenormalizedTag> selectedSegments) {
        List<DenormalizedTag> activeCategories = getActiveRootCategories();
        List<String> activeCategoryIds = new List<String>();
        List<String> segmentIds = new List<String>();
        for(DenormalizedTag selectedSegment : selectedSegments) {
            segmentIds.add(selectedSegment.Id);
        }
        for(DenormalizedTag activeCategory : activeCategories) {
            activeCategoryIds.add(activeCategory.id);
        }

        List<DenormalizedTag> solutions= getChildTagsByParentName(new List<String>{'Solutions'});

        //get shops by segments and categories
        List<DenormalizedShop> shops = getShopsBySegmentAndCategoryIds(segmentIds, activeCategoryIds);
        Set<String> tagWithShopsIdsSet = new Set<String>();
        List<String> tagWithShopsIdsLst = new List<String>();
        for(DenormalizedShop shop : shops ) {
            tagWithShopsIdsSet.add(shop.tagId);
        }
        tagWithShopsIdsLst.addAll(tagWithShopsIdsSet);
        
        //get promotions by segments and categories
        List<DenormalizedPromotion> promotions = getPromotionsBySegmentAndCategoryIds(segmentIds, activeCategoryIds);
        Set<String> tagWithPromotionsIdsSet = new Set<String>();
        List<String> tagWithPromotionsIdsLst = new List<String>();
        for(DenormalizedPromotion promotion : promotions ) {
            tagWithPromotionsIdsSet.add(promotion.tagId);
        }
        tagWithPromotionsIdsLst.addAll(tagWithPromotionsIdsSet);

        List<DenormalizedTag> categoriesWithShopsOrProductsOrPromotions = new List<DenormalizedTag>();
        //Add Categories From Shop Results
        for(DenormalizedTag activeCategory : activeCategories) {
            if(tagWithShopsIdsLst.contains(activeCategory.id) 
                || tagWithPromotionsIdsLst.contains(activeCategory.id)
                ) {
                categoriesWithShopsOrProductsOrPromotions.add(activeCategory);
            }
        }

        //Create the DenormalizedMallState 
        DenormalizedMallState denormalizedMallState = new DenormalizedMallState();
        denormalizedMallState.segments = segments;
        denormalizedMallState.categories = categoriesWithShopsOrProductsOrPromotions;
        denormalizedMallState.shops = shops;
        denormalizedMallState.promotions = promotions;
        denormalizedMallState.mallMultiLanguageContent = MallDataServiceHandler.mallMultiLanguageContent;

        return denormalizedMallState;
    }

    /**
     * 
     * @description Mall State initializationStore
     * @return   DenormalizedMallState 
     */
    public DenormalizedMallState initializationStore() {
        List<String> selectedSegmentNames = mallUserContext.selectedSegmentNames;
        List<DenormalizedTag> segments = getSegmentTags ();
        List<DenormalizedTag> defaultSegment = new List<DenormalizedTag>();
        if(selectedSegmentNames == null || selectedSegmentNames.size() == 0) {
            for(DenormalizedTag segment : segments) {
                if(segment.name == System.Label.MALL_DEFAULT_SEGMENT){
                    defaultSegment.add(segment);
                    break;
                } 
            }
        } else if(selectedSegmentNames != null && selectedSegmentNames.size() > 0) {
            for(DenormalizedTag segment : segments) {
                if(selectedSegmentNames.contains(segment.name.toLowerCase())) {
                    defaultSegment.add(segment);
                    break;
                }
            } 
        }
        return refreshMallStoreState(segments, defaultSegment);
    }

    /**
     * 
     * @description refreshMallStoreState
     * @param segments List of Denormalized Tags
     * @param selectedSegments List of Denormalized Tags
     * @return   DenormalizedMallState 
     */
    public DenormalizedMallState refreshMallStoreState(List<DenormalizedTag> segments, List<DenormalizedTag> selectedSegments) {
        List<DenormalizedTag> activeCategories = getActiveRootCategories();
        List<String> activeCategoryIds = new List<String>();
        List<String> segmentIds = new List<String>();
        for(DenormalizedTag selectedSegment : selectedSegments) {
            segmentIds.add(selectedSegment.Id);
        }
        for(DenormalizedTag activeCategory : activeCategories) {
            activeCategoryIds.add(activeCategory.id);
        }
        //get shops by segments and categories
        List<DenormalizedShop> shops = getShopsBySegmentAndCategoryIds(segmentIds, activeCategoryIds);
        DenormalizedMallState denormalizedMallState = new DenormalizedMallState();
        denormalizedMallState.segments = segments;
        denormalizedMallState.categories = activeCategories;
        denormalizedMallState.shops = shops;
        return denormalizedMallState;
    }

    /**
     * 
     * @description This method queries all the Active Root Tags configured in the Mall_Root_Tag__mdt metatdata
     * @return   List of DenormalizedTag
     */
    public List<DenormalizedTag> getActiveRootTags () {
        List<Mall_Root_Tag__mdt> mallRootTagsConfig = Mall_Root_Tag__mdt.getAll().values();
        List<String> activeRootTags = new List<String>();
        for(Mall_Root_Tag__mdt mrt : mallRootTagsConfig) {
            if(mrt.IsActive__c){
                activeRootTags.add(mrt.DeveloperName);
            }
        }

        String whereClause = 'Name IN (\'' + String.join(activeRootTags, '\',\'') + '\')';
        whereClause += ' AND IsRoot__c = TRUE';
        whereClause += ' AND IsOnline__c = TRUE';
        List<Tag__c> tagsLst =  SEL_Tags.newInstance().selectByCustomFilterCondition(whereClause);
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallDataServiceHelper().prepareTagsForLanguage(tagsLst);
        return new MallDataServiceHelper().denormalizeTags(tagsLst, mapContentTypMapContentUnitTranslation.get(ICON_CONTENT_UNIT_TRANSLATION), mapContentTypMapContentUnitTranslation.get(CONTENT_UNIT_TRANSLATION));
    }

    /**
     * 
     * @description This method queries all the Tags for Category tree
     * @return   List of DenormalizedTag 
     */
    public List<DenormalizedTag> getActiveRootCategories () {
       List<DenormalizedTag> activeRootTags = getActiveRootTags();
       List<String> activeRootTagIds = new List<String>();
       for(DenormalizedTag activeRootTag : activeRootTags) {
        activeRootTagIds.add(activeRootTag.id);
       }
       return getChildTagsByParentId(activeRootTagIds);
    }

    /**
     * 
     * @description This method queries all the Tags for Segment Tree
     * @return   List of DenormalizedTag
     */
    public List<DenormalizedTag> getSegmentTags () {
        return getChildTagsByParentName(new List<String>{'Segment'});
    }
    
    /**
     * 
     * @description This method queries all the Tags By Ids
     * @param ids List of Tag Ids
     * @return   List of DenormalizedTag
     */
    public List<DenormalizedTag> getTagsByIds(List<String> ids) {
        Set<Id> idsSet = new Set<Id>();
        idsSet.addAll((List<Id>)ids);
        List<Tag__c> tagsLst = SEL_Tags.newInstance().selectTagsByIds(idsSet);
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallDataServiceHelper().prepareTagsForLanguage(tagsLst);
        return new MallDataServiceHelper().denormalizeTags(tagsLst, mapContentTypMapContentUnitTranslation.get(ICON_CONTENT_UNIT_TRANSLATION), mapContentTypMapContentUnitTranslation.get(CONTENT_UNIT_TRANSLATION));
    }

    /**
     * 
     * @description This method queries all the Tags By Names
     * @param names List of tag names
     * @return   List of DenormalizedTag 
     */
    public List<DenormalizedTag> getTagsByNames(List<String> names) {
        Set<String> namesSet = new Set<String>();
        namesSet.addAll(names);
        List<Tag__c> tagsLst = SEL_Tags.newInstance().selectTagsByNames(namesSet);
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallDataServiceHelper().prepareTagsForLanguage(tagsLst);
        return new MallDataServiceHelper().denormalizeTags(tagsLst, mapContentTypMapContentUnitTranslation.get(ICON_CONTENT_UNIT_TRANSLATION), mapContentTypMapContentUnitTranslation.get(CONTENT_UNIT_TRANSLATION));
    }

    /**
     * 
     * @description This method queries the tags by Parent Tag Ids
     * @param parentIds List of Ids
     * @return   List of DenormalizedTag
     */
    public List<DenormalizedTag> getChildTagsByParentId(List<String> parentIds) {
        List<Tag__c> tagsLst = SEL_Tags.newInstance().selectByCustomFilterCondition('Parent__c IN (\'' + String.join(parentIds, '\',\'') + '\') AND IsOnline__c = TRUE');
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallDataServiceHelper().prepareTagsForLanguage(tagsLst);
        return new MallDataServiceHelper().denormalizeTags(tagsLst, mapContentTypMapContentUnitTranslation.get(ICON_CONTENT_UNIT_TRANSLATION), mapContentTypMapContentUnitTranslation.get(CONTENT_UNIT_TRANSLATION));    
    }

    /**
     * 
     * @description This method queries the tags by Parent Tag Names
     * @param parentNames List of Names
     * @return   List of DenormalizedTag
     */
    public List<DenormalizedTag> getChildTagsByParentName(List<String> parentNames) {
        List<Tag__c> tagsLst = SEL_Tags.newInstance().selectByCustomFilterCondition('Parent__r.Name IN (\'' + String.join(parentNames, '\',\'') + '\') AND IsOnline__c = TRUE');
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallDataServiceHelper().prepareTagsForLanguage(tagsLst);
        return new MallDataServiceHelper().denormalizeTags(tagsLst, mapContentTypMapContentUnitTranslation.get(ICON_CONTENT_UNIT_TRANSLATION), mapContentTypMapContentUnitTranslation.get(CONTENT_UNIT_TRANSLATION));    
    }
    
    /**
     * 
     * @description This method queries the Tag/Product by TagIds
     * @param tags List of tags
     * @return   List of DenormalizedProduct
     */
    public List<DenormalizedProduct> getProductsByTagIds(List<String> tags) {
        String whereClause = '(Tag__c IN (\'' + String.join(tags, '\',\'') + '\')';
        whereClause += ' OR Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\')';

        List<Tag_Offering__c> tagProducts = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(whereClause);
        return prepareProductsForCountryAndLanguage(tagProducts);
    } 

    /**
     * 
     * @description This method queries the Tag/Product by TagNames
     * @param tagNames List of tag names
     * @return   List of DenormalizedProduct 
     */
    public List<DenormalizedProduct> getProductsByTagNames(List<String> tagNames) {
        String whereClause = '(Tag__r.Name IN (\'' + String.join(tagNames, '\',\'') + '\')';
        whereClause += ' OR Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\')';
        
        List<Tag_Offering__c> tagProducts = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(whereClause);
        return prepareProductsForCountryAndLanguage(tagProducts);
    } 
    
    /**
     * 
     * @description This method queries the Tag/Product by Country
     * @param countries List of Country Names
     * @return  List of DenormalizedProduct
     */
    public List<DenormalizedProduct> getProductsByCountryNames(List<String> countries) {
        Set<String> countriesSet = new Set<String>();
        countriesSet.addAll(countries);
        List<Tag_Offering__c> tagProducts = SEL_TagOfferings.newInstance().selectByTagNames(countriesSet);
        
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallDataServiceHelper().prepareProductsForLanguage(tagProducts);   
        return new MallDataServiceHelper().denormalizeProducts(tagProducts, mapContentTypMapContentUnitTranslation.get(CONTENT_UNIT_TRANSLATION));

    } 

    /**
     * 
     * @description This method queries the Tag/Product by parentTagIds
     * @param parentTagIds List of Parent tag Ids
     * @return   List of DenormalizedProduct 
     */
    public List<DenormalizedProduct> getProductsByParentTagIds(List<String> parentTagIds) {
        String whereClause = ' Tag__r.Parent__c IN (\'' + String.join(parentTagIds, '\',\'') + '\')';
        whereClause += ' OR Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\'';
        List<Tag_Offering__c> tagProducts = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(whereClause);
        return prepareProductsForCountryAndLanguage(tagProducts);
    } 

    /**
     * 
     * @description This method queries the Tag/Product by productIds
     * @param productIds List of Product ids
     * @return   List of DenormalizedProduct 
     */
    public List<DenormalizedProduct> getProductsByIds(List<String> productIds) {
        String whereClause = ' Offering__c IN (\'' + String.join(productIds, '\',\'') + '\')';
        whereClause += ' AND Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\'';
        List<Tag_Offering__c> tagProducts = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(whereClause);
        
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallDataServiceHelper().prepareProductsForLanguage(tagProducts);   
        return new MallDataServiceHelper().denormalizeProducts(tagProducts, mapContentTypMapContentUnitTranslation.get(CONTENT_UNIT_TRANSLATION));
    }

    /**
     * 
     * @description This method prepares the product for country and language
     * @param tagProducts List of Tag Products
     * @return   List of DenormalizedProduct 
     */
    public List<DenormalizedProduct> prepareProductsForCountryAndLanguage(List<Tag_Offering__c> tagProducts) {
        
        //De-duplicate the Products since there will be tagproduct for country as well as tag itself
        tagProducts = new MallDataServiceHelper().prepareProductsForCountry(tagProducts);
        //get the content translation based on user language
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallDataServiceHelper().prepareProductsForLanguage(tagProducts);
        
        return new MallDataServiceHelper().denormalizeProducts(tagProducts, mapContentTypMapContentUnitTranslation.get(CONTENT_UNIT_TRANSLATION));
    } 

    /**
     * 
     * @description This method returns the shops for tagIds provided
     * @param tagIds List of Tag Ids
     * @return   List of DenormalizedShops 
     */
    public List<DenormalizedShop> getShopsByTagIds(List<String> tagIds) {
        String whereClause = ' Tag__c IN (\'' + String.join(tagIds, '\',\'') + '\')';
        whereClause += ' OR Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\'';
        List<Tag_Provider__c> tagProviders = SEL_TagProviders.newInstance().selectByCustomFilterCondition(whereClause);
        return prepareShopsForCountryAndLanguage(tagProviders);
    }

    /**
     * 
     * @description This method returns the shops for parentTagIds provided
     * @param parentTagIds List of Parent Ids
     * @return   List of DenormalizedShops  
     */
    public List<DenormalizedShop> getShopsByParentTagIds(List<String> parentTagIds) {
        String whereClause = ' Tag__r.Parent__c IN (\'' + String.join(parentTagIds, '\',\'') + '\')';
        whereClause += ' OR Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\'';
        List<Tag_Provider__c> tagProviders = SEL_TagProviders.newInstance().selectByCustomFilterCondition(whereClause);
        return prepareShopsForCountryAndLanguage(tagProviders);
    }

    /**
     * 
     * @description This method returns the shops for countries provided
     * @param countries List of Country Names
     * @return   List of DenormalizedShops  
     */
    public List<DenormalizedShop> getShopsByCountries(List<String> countries) {
        Set<String> cointriesSet = new Set<String>();
        cointriesSet.addAll(cointriesSet);
        List<Tag_Provider__c> tagProviders = SEL_TagProviders.newInstance().selectByTagNames(cointriesSet);
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallDataServiceHelper().prepareShopsForLanguage(tagProviders);
        return new MallDataServiceHelper().denormalizeShop(tagProviders, mapContentTypMapContentUnitTranslation.get(ICON_CONTENT_UNIT_TRANSLATION), mapContentTypMapContentUnitTranslation.get(CONTENT_UNIT_TRANSLATION));
    } 

    /**
     * 
     * @description This method queries the Tag/Shops by shopIds
     * @param providerIds List<String>
     * @return List<DenormalizedShops> 
     */
    public List<DenormalizedShop> getShopsByIds(List<String> providerIds) {
        String whereClause = ' Provider__c IN (\'' + String.join(providerIds, '\',\'') + '\')';
        whereClause += ' AND Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\'';
        List<Tag_Provider__c> tagProviders = SEL_TagProviders.newInstance().selectByCustomFilterCondition(whereClause);
        
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallDataServiceHelper().prepareShopsForLanguage(tagProviders);
        return new MallDataServiceHelper().denormalizeShop(tagProviders, mapContentTypMapContentUnitTranslation.get(ICON_CONTENT_UNIT_TRANSLATION), mapContentTypMapContentUnitTranslation.get(CONTENT_UNIT_TRANSLATION));
    }

    /**
     * 
     * @description This method queries the Tag/Product by productIds
     * @param shopIds List of Shop Ids
     * @return   List of DenormalizedShops 
     */
    public List<DenormalizedProduct> getProductsByShopIds(List<String> shopIds) {
        String whereClause = ' Offering__r.Provider__c IN (\'' + String.join(shopIds, '\',\'') + '\')';
        whereClause += ' AND Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\'';
        List<Tag_Offering__c> tagProducts = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(whereClause);
        
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallDataServiceHelper().prepareProductsForLanguage(tagProducts);   
        return new MallDataServiceHelper().denormalizeProducts(tagProducts, mapContentTypMapContentUnitTranslation.get(CONTENT_UNIT_TRANSLATION));
    }

    /**
     * 
     * @description This method returns the shops for countries provided
     * @param searchString Search text
     * @return   List of DenormalizedShops 
     */
    public List<DenormalizedShop> getShopsWhereNameStartsWith(String searchString) {
        String whereClause = ' Provider__r.Name LIKE ' + + '\'' + searchString + '%\'';
        whereClause += ' OR Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\'';
        List<Tag_Provider__c> tagProviders = SEL_TagProviders.newInstance().selectByCustomFilterCondition(whereClause);
        return prepareShopsForCountryAndLanguage(tagProviders);
    }

    /**
     * 
     * @description This method return list of all shops 
     * @return   List of DenormalizedShops 
     */
    public List<DenormalizedShop> getAllShops() {
        String whereClause = ' Provider__r.Name != NULL OR Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\'';
        List<Tag_Provider__c> tagProviders = SEL_TagProviders.newInstance().selectByCustomFilterCondition(whereClause);
        return prepareShopsForCountryAndLanguage(tagProviders);
    }

    /**
     * 
     * @description getProductsBySegmentAndCategoryIds
     * @param segmentIds List of String Ids
     * @param categoryIds  List of String Ids
     * @return   List of Denormalized Products
     */
    public List<DenormalizedProduct> getProductsBySegmentAndCategoryIds(List<String> segmentIds, List<String> categoryIds) {
        List<String> allTagIds = new List<String>();
        allTagIds.addAll(segmentIds);
        allTagIds.addAll(categoryIds);
        String whereClause = ' Tag__c IN (\'' + String.join(allTagIds, '\',\'') + '\')';
        whereClause += ' OR Tag__r.Root_name__c IN (\'' + String.join(new List<String>{'Solutions'}, '\',\'') + '\')';
        List<Tag_Offering__c> tagProducts = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(whereClause);

        Map<String, List<Tag_Offering__c>> mapProductIdTagProducts =  new Map<String, List<Tag_Offering__c>>();
        List<Tag_Offering__c> tagProductsConsolidated = new List<Tag_Offering__c>();
        List<String> productIds = new List<String>();
        Map<String, Tag_Offering__c> mapServeIdVsSoltionTag = new Map<String, Tag_Offering__c>();
        

        for(Tag_Offering__c tagProduct : tagProducts) {
            if(!mapProductIdTagProducts.containsKey(tagProduct.Offering__c)) {
                mapProductIdTagProducts.put(tagProduct.Offering__c, new List<Tag_Offering__c>{tagProduct});
            } else {
                List<Tag_Offering__c> tagProductsTemp = mapProductIdTagProducts.get(tagProduct.Offering__c);
                tagProductsTemp.add(tagProduct);
                mapProductIdTagProducts.put(tagProduct.Offering__c, tagProductsTemp);
            }
        }

        for(String productId : mapProductIdTagProducts.KeySet()) {
            List<Tag_Offering__c> tProducts = mapProductIdTagProducts.get(productId);
            Boolean segmentProductExists = FALSE;
            Boolean categoryProductExists = FALSE;
            Boolean solutionsProductExists = FALSE;

            Integer categoryIndex = 0;
            for(Integer row=0;  row < tProducts.size() ; row++) {
                if(tProducts[row].Tag__r.Root_Name__c == 'Segment') {
                    segmentProductExists = TRUE;
                }
                if(tProducts[row].Tag__r.Root_Name__c == 'Category') {
                    CategoryProductExists = TRUE;
                    categoryIndex = row;
                }
                if(tProducts[row].Tag__r.Root_Name__c == 'Solutions') {
                    solutionsProductExists = TRUE;
                    mapServeIdVsSoltionTag.put(tProducts[row].Offering__c, tProducts[row]);
                }
            }
            if(segmentProductExists && CategoryProductExists && solutionsProductExists) {
                tagProductsConsolidated.add(tProducts[categoryIndex]);
                productIds.add(tProducts[categoryIndex].Offering__c);
            }
        }

        whereClause = ' Offering__c IN (\'' + String.join(productIds, '\',\'') + '\')';
        whereClause += ' AND Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\'';
        List<Tag_Offering__c> tagProductsForCountry = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(whereClause);
        //consolidate all tag shops
        tagProductsConsolidated.addAll(tagProductsForCountry);
        List<DenormalizedProduct> denormalizedProductsProcessed = prepareProductsForCountryAndLanguage(tagProductsConsolidated);

        for(DenormalizedProduct denormalizedProductProcessed : denormalizedProductsProcessed) {
            if(mapServeIdVsSoltionTag.containsKey(denormalizedProductProcessed.id)) {
                denormalizedProductProcessed.solutionId = mapServeIdVsSoltionTag.get(denormalizedProductProcessed.id).Tag__c;
            }
        }
        return denormalizedProductsProcessed;
    }

    /**
     * 
     * @description getShopsBySegmentAndCategoryIds
     * @param segmentIds List of String
     * @param categoryIds List of String
     * @return   List of Denormalized Shops 
     */
    public List<DenormalizedShop> getShopsBySegmentAndCategoryIds(List<String> segmentIds, List<String> categoryIds) {
        List<String> allTagIds = new List<String>();
        allTagIds.addAll(segmentIds);
        allTagIds.addAll(categoryIds);
        String whereClause = ' Tag__c IN (\'' + String.join(allTagIds, '\',\'') + '\')';
        List<Tag_Provider__c> tagProviders = SEL_TagProviders.newInstance().selectByCustomFilterCondition(whereClause);

        Map<String, List<Tag_Provider__c>> mapProviderIdtagProviders =  new Map<String, List<Tag_Provider__c>>();
        List<Tag_Provider__c> tagProvidersConsolidated = new List<Tag_Provider__c>();
        List<String> providerIds = new List<String>();


        for(Tag_Provider__c tagProvider : tagProviders) {
            if(!mapProviderIdtagProviders.containsKey(tagProvider.Provider__c)) {
                mapProviderIdtagProviders.put(tagProvider.Provider__c, new List<Tag_Provider__c>{tagProvider});
            } else {
                List<Tag_Provider__c> tagProvidersTemp = mapProviderIdtagProviders.get(tagProvider.Provider__c);
                tagProvidersTemp.add(tagProvider);
                mapProviderIdtagProviders.put(tagProvider.Provider__c, tagProvidersTemp);
            }
        }

        for(String providerId : mapProviderIdtagProviders.KeySet()) {
            List<Tag_Provider__c> tProviders = mapProviderIdtagProviders.get(providerId);
            Boolean segmentProviderExists = FALSE;
            Boolean categoryProviderExists = FALSE;
            Integer categoryIndex = 0;
            for(Integer row=0;  row < tProviders.size() ; row++) {
                if(tProviders[row].Tag__r.Root_Name__c == 'Segment') {
                    segmentProviderExists = TRUE;
                }
                if(tProviders[row].Tag__r.Root_Name__c == 'Category') {
                    categoryProviderExists = TRUE;
                    categoryIndex = row;
                }
            }
            if(segmentProviderExists && categoryProviderExists) {
                tagProvidersConsolidated.add(tProviders[categoryIndex]);
                providerIds.add(tProviders[categoryIndex].Provider__c);
            }
        }

        whereClause = ' Provider__c IN (\'' + String.join(providerIds, '\',\'') + '\')';
        whereClause += ' AND Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\'';
        List<Tag_Provider__c> tagProvidersForCountry = SEL_TagProviders.newInstance().selectByCustomFilterCondition(whereClause);

        //consolidate all tag shops
        tagProvidersConsolidated.addAll(tagProvidersForCountry);
        return prepareShopsForCountryAndLanguage(tagProvidersConsolidated);
    }

    /**
     * 
     * @description This method prepares the shops for country and language 
     * @param tagProviders List of Tag Providers
     * @return   List of DenormalizedShop 
     */
    public List<DenormalizedShop> prepareShopsForCountryAndLanguage(List<Tag_Provider__c> tagProviders) {
        
        //De-duplicate the Products since there will be tagproduct for country as well as tag itself
        tagProviders = new MallDataServiceHelper().prepareShopsForCountry(tagProviders);
        //get the content translation based on user language
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallDataServiceHelper().prepareShopsForLanguage(tagProviders);
        
        return new MallDataServiceHelper().denormalizeShop(tagProviders, mapContentTypMapContentUnitTranslation.get(ICON_CONTENT_UNIT_TRANSLATION), mapContentTypMapContentUnitTranslation.get(CONTENT_UNIT_TRANSLATION));
    } 

    /**
     * 
     * @description getContactUsEmailByCountry
     * @param countryName Country Name
     * @return   String 
     */
    public String getContactUsEmailByCountry(String countryName) {
        String countryContactUsEmail;
        Map<String,Country_Information__mdt> countryInfoMap = Country_Information__mdt.getAll();
        for(Country_Information__mdt country: countryInfoMap.values()) {
            if(country.Country_Name__c == countryName) {
                countryContactUsEmail = country.Contact_Us_Email__c;
                break;
            }
        }
        return countryContactUsEmail;
    }

    /**
     * 
     * @description getLegalInfo
     * @return   List of DenormalizedContent
     */
    public List<DenormalizedContent> getLegalInfo(){
        return new MallContentDataService().getContentsByCountryNamesAndRecordTypes(new List<String>{userCountry}, new List<String>{'Legal'}); 
    }

    /**
     * 
     * @description getFAQsInfo
     * @param tagIds List<String>
     * @return   List<DenormalizedContent>
     */
    public List<DenormalizedContent> getFAQsInfo(List<String> tagIds){
        return new MallContentDataService().getContentsByTagIdsRootNamesAndRecordTypeNames(new List<String>{'FAQ'},tagIds,new List<String>{'FAQ'});
    }

    /**
     * 
     * @description getPromotionsBySegmentAndCategoryIds
     * @param segmentIds List<String>
     * @param categoryIds List<String>
     * @return  List<DenormalizePromotion>
     */
    public List<DenormalizedPromotion> getPromotionsBySegmentAndCategoryIds(List<String> segmentIds, List<String> categoryIds) {
        return new MallPromotionsDataService().getPromotionsBySegmentAndCategoryIds(segmentIds, categoryIds); 
    }

    /**
     * 
     * @description getEventsBySegmentAndCategoryIds
     * @param segmentIds List<String>
     * @param categoryIds List<String>
     * @return  List<DenormalizedEvent>
     */
    public List<DenormalizedEvent> getEventsBySegmentAndCategoryIds(List<String> segmentIds, List<String> categoryIds) {
        return new MallEventsDataService().getEventsBySegmentAndCategoryIds(segmentIds, categoryIds); 
    }

     /**
     * 
     * @description getContentsByCountryNamesAndRecordTypes
     * @param countries List<String>
     * @param recordTypes List<String>
     * @return  List<DenormalizedContent>
     */
    public  List<DenormalizedContent> getContentsByCountryNamesAndRecordTypes(List<String> countries, List<String> recordTypes) {
        return new MallContentDataService().getContentsByCountryNamesAndRecordTypes(countries, recordTypes); 
    }

    /**
     * 
     * @description getSuccessStoriesByCountryNames
     * @param countries List<String>
     * @return  List<DenormalizedSuccessStory>
     */
    public  List<DenormalizedSuccessStory> getSuccessStoriesByCountryNames(List<String> countries) {
        return new MallSuccessStoriesCtrl().getSuccessStoriesByCountryNames(countries); 
    }

        /**
     * 
     * @description getSuccessStoriesByIds
     * @param successStoryIds List<String>
     * @return  List<DenormalizedSuccessStory>
     */
    public List<DenormalizedSuccessStory> getSuccessStoriesByIds(List<String> successStoryIds) {
        return new MallSuccessStoriesCtrl().getSuccessStoriesByIds(successStoryIds); 
    }

    /**
     * 
     * @description getContentsByTagsRootTagsAndRecordTypeNames
     * @param rootTagNames List<String>
     * @param tagNames List<String>
     * @param recordTypes List<String>
     * @return  List<DenormalizedContent>
     */
    public List<DenormalizedContent> getContentsByTagsRootTagsAndRecordTypeNames(List<String> rootTagNames, List<String> tagNames, List<String> recordTypes) {
        return new MallContentDataService().getContentsByTagsRootTagsAndRecordTypeNames(rootTagNames, tagNames, recordTypes); 
    }

    /**
     * 
     * @description getContentsByTagIdsRootNamesAndRecordTypeNames
     * @param rootTagNames List<String>
     * @param tagIds List<String>
     * @param recordTypes List<String>
     * @return  List<DenormalizedContent>
     */
    public  List<DenormalizedContent> getContentsByTagIdsRootNamesAndRecordTypeNames(List<String> rootTagNames, List<String> tagIds, List<String> recordTypes) {
        return new MallContentDataService().getContentsByTagIdsRootNamesAndRecordTypeNames(rootTagNames, tagIds, recordTypes); 
    }

    /**
     * 
     * @description getSolutionsBySegmentAndCategories
     * @param segmentIds List of String Ids
     * @param categoryIds  List of String Ids
     * @return   List of Denormalized Products
     */
    public List<SolutionResponse> getSolutionsBySegmentAndCategories(List<String> segmentIds, List<String> categoryIds) {
        String tagNameSolutions = 'Solutions';
        List<String> allTagIds = new List<String>();
        allTagIds.addAll(segmentIds);
        allTagIds.addAll(categoryIds);
        String whereClause = ' Tag__c IN (\'' + String.join(allTagIds, '\',\'') + '\')';
        whereClause += ' OR Tag__r.Root_Name__c =\''+tagNameSolutions+'\'';
        whereClause += ' OR Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\'';

        List<Tag_Offering__c> tagProducts = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(whereClause);

        Map<String, List<Tag_Offering__c>> mapProductIdTagProducts =  new Map<String, List<Tag_Offering__c>>();

        for(Tag_Offering__c tagProduct : tagProducts) {
            if(!mapProductIdTagProducts.containsKey(tagProduct.Offering__c)) {
                mapProductIdTagProducts.put(tagProduct.Offering__c, new List<Tag_Offering__c>{tagProduct});
            } else {
                List<Tag_Offering__c> tagProductsTemp = mapProductIdTagProducts.get(tagProduct.Offering__c);
                tagProductsTemp.add(tagProduct);
                mapProductIdTagProducts.put(tagProduct.Offering__c, tagProductsTemp);
            }
        }

        Map<String, Set<String>> mapCategoryVsSolutionIds = new Map<String, Set<String>>();
        List<SolutionResponse> solutions = new List<SolutionResponse>();
        Set<String> allTagIdsNeeded = new Set<String>();
        for(String productId : mapProductIdTagProducts.KeySet()) {
            List<Tag_Offering__c> tProducts = mapProductIdTagProducts.get(productId);
            Boolean segmentProductExists = FALSE;
            Boolean categoryProductExists = FALSE;
            Boolean solutionsProductExists = FALSE;
            Boolean countryProductExists = FALSE;
            Set<String> tProductsSolutions = new Set<String>();
            Set<String> tProductsCategories = new Set<String>();

            for(Integer row=0;  row < tProducts.size() ; row++) {
                if(tProducts[row].Tag__r.Root_Name__c == 'Segment') {
                    segmentProductExists = TRUE;
                }
                if(tProducts[row].Tag__r.Root_Name__c == 'Country') {
                    countryProductExists = TRUE;
                }
                if(tProducts[row].Tag__r.Root_Name__c == 'Category') {
                    categoryProductExists = TRUE;
                    tProductsCategories.add(tProducts[row].Tag__c);
                }
                if(tProducts[row].Tag__r.Root_Name__c == tagNameSolutions) {
                    solutionsProductExists = TRUE;
                    tProductsSolutions.add(tProducts[row].Tag__c);
                }

                if(row == (tProducts.size()-1) && segmentProductExists && categoryProductExists && solutionsProductExists && countryProductExists) {
                    for(String tProductCategories : tProductsCategories) {
                        if(mapCategoryVsSolutionIds.containsKey(tProductCategories)) {
                            Set<String> solutionTemp = mapCategoryVsSolutionIds.get(tProductCategories);
                            solutionTemp.addAll(tProductsSolutions);
                            mapCategoryVsSolutionIds.put(tProductCategories, solutionTemp);
                        } else {
                            mapCategoryVsSolutionIds.put(tProductCategories, tProductsSolutions);
                        }
                        allTagIdsNeeded.addAll(tProductsCategories);
                        allTagIdsNeeded.addAll(tProductsSolutions);
                    }
                }
            }

        }

        List<String> allTagIdsLst = new List<String>();

        allTagIdsLst.addAll(allTagIdsNeeded);
        if(allTagIdsLst.size() > 0) {
            List<DenormalizedTag> denormalizedTagsLst = getTagsByIds(allTagIdsLst);

            Map<String, DenormalizedTag> tagIdVsTagMap = new Map<String, DenormalizedTag>();
            for(DenormalizedTag denormalizedTag: denormalizedTagsLst) {
                tagIdVsTagMap.put(denormalizedTag.id, denormalizedTag);
            }

            for(String categoryId : mapCategoryVsSolutionIds.KeySet()) {
                Set<String> solutionsAssociated = mapCategoryVsSolutionIds.get(categoryId);
                List<DenormalizedTag> solutionsForCategory = new List<DenormalizedTag>();
                SolutionResponse solutionTemp = new SolutionResponse();
                solutionTemp.category = tagIdVsTagMap.get(categoryId);
                if(solutionsAssociated != NULL && solutionsAssociated.size() > 0) {
                    for(String solutionAssociated : solutionsAssociated) {
                        solutionsForCategory.add(tagIdVsTagMap.get(solutionAssociated));
                    }
                    solutionTemp.solutions = solutionsForCategory;
                    solutions.add(solutionTemp);
                }
            }

        }
        return solutions;
    }

    /**
     * 
     * @description getOfferingsBySolutionIds
     * @param solutionIds List of String Ids
     * @param recordTypeName String
     * @return List of Denormalized Products
     */
    public List<DenormalizedProduct> getOfferingsBySolutionIds(List<String> solutionIds, String recordTypeName) {
        List<String> rootTagNames = new List<String>();
        rootTagNames.add('Solutions');
        rootTagNames.add('Category');
        rootTagNames.add('Segment');
        rootTagNames.add('Country');

        String whereClause = ' Tag__c IN (\'' + String.join(solutionIds, '\',\'') + '\')';
        whereClause += ' AND Offering__r.RecordType.Name =\''+recordTypeName+'\'';

        List<Tag_Offering__c> tagProducts = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(whereClause);

        Set<String> offeringIdsSet = new Set<String>();
        List<String> offeringIdsLst = new List<String>();
        for(Tag_Offering__c tagProduct: tagProducts) {
            offeringIdsSet.add(tagProduct.Offering__c);
        }

        offeringIdsLst.addAll(offeringIdsSet);
        whereClause = ' Offering__c IN (\'' + String.join(offeringIdsLst, '\',\'') + '\')';
        whereClause += ' AND Tag__r.Root_Name__c IN (\'' + String.join(rootTagNames, '\',\'') + '\')';

        tagProducts = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(whereClause);

        Map<String, List<Tag_Offering__c>> mapProductIdTagProducts =  new Map<String, List<Tag_Offering__c>>();
        List<Tag_Offering__c> tagProductsConsolidated = new List<Tag_Offering__c>();
        List<String> productIds = new List<String>();


        for(Tag_Offering__c tagProduct : tagProducts) {
            if(!mapProductIdTagProducts.containsKey(tagProduct.Offering__c)) {
                mapProductIdTagProducts.put(tagProduct.Offering__c, new List<Tag_Offering__c>{tagProduct});
            } else {
                List<Tag_Offering__c> tagProductsTemp = mapProductIdTagProducts.get(tagProduct.Offering__c);
                tagProductsTemp.add(tagProduct);
                mapProductIdTagProducts.put(tagProduct.Offering__c, tagProductsTemp);
            }
        }

        for(String productId : mapProductIdTagProducts.KeySet()) {
            List<Tag_Offering__c> tProducts = mapProductIdTagProducts.get(productId);
            Boolean segmentProductExists = FALSE;
            Boolean categoryProductExists = FALSE;
            Boolean solutionsProductExists = FALSE;
            Boolean countryProductExists = FALSE;

            Integer categoryIndex = 0;
            for(Integer row=0;  row < tProducts.size() ; row++) {
                if(tProducts[row].Tag__r.Root_Name__c == 'Country') {
                    countryProductExists = TRUE;
                }
                if(tProducts[row].Tag__r.Root_Name__c == 'Segment') {
                    segmentProductExists = TRUE;
                }
                if(tProducts[row].Tag__r.Root_Name__c == 'Category') {
                    CategoryProductExists = TRUE;
                    categoryIndex = row;
                }
                if(tProducts[row].Tag__r.Root_Name__c == 'Solutions') {
                    solutionsProductExists = TRUE;
                }
            }
            if(segmentProductExists && CategoryProductExists && solutionsProductExists && countryProductExists) {
                tagProductsConsolidated.add(tProducts[categoryIndex]);
                productIds.add(tProducts[categoryIndex].Offering__c);
            }
        }

        whereClause = ' Offering__c IN (\'' + String.join(productIds, '\',\'') + '\')';
        whereClause += ' AND Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\'';
        List<Tag_Offering__c> tagProductsForCountry = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(whereClause);
        //consolidate all tag shops
        tagProductsConsolidated.addAll(tagProductsForCountry);
        return prepareProductsForCountryAndLanguage(tagProductsConsolidated);    
    }

    /**
     * 
     * @description SolutionResponse
     */
    public class SolutionResponse {
        @AuraEnabled
        public DenormalizedTag category;
        @AuraEnabled
        public List<DenormalizedTag> solutions;
    }
}