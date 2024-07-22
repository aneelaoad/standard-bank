/**
 * @description : This class acts as data layer for mall services and UI
 * Shops, Products and Tags are returned in denormalized format based on the parameters passed
 * @author Maham Hasan
 * @since 
 */
public with sharing class MallDataService {
  /**
   * 
   * @description : Get All Active Root Tags 
   *  @return : List<DenormalizedTag>
   */ 
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedTag> getActiveRootTags () {
    try {
      return new MallDataServiceHandler().getActiveRootTags(); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getActiveRootTags', e); 
    }
  }

   /**
     * @description This method queries all the Tags for Category tree
     * @return list<DenormalizedTag>
     */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedTag> getActiveRootCategories () {
    try {
      return new MallDataServiceHandler().getActiveRootCategories(); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getActiveRootCategories', e); 
    }
  }

  /**
     * @description This method queries all the Tags from Segment Tree
     * @return list of DenormalizedTag
     */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedTag> getSegmentTags () {
    try {
      return new MallDataServiceHandler().getSegmentTags(); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getSegmentTags', e); 
    }
  }

  /**
   * @description This method queries all the Tags from Segment Tree
   * @param mallContext String
   * @return list of DenormalizedTag
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedTag> getSegmentTagsByMallContext (String mallContext) {
    try {
      return new MallDataServiceHandler(mallContext).getSegmentTags(); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getSegmentTags', e); 
    }
  }

  /**
   * @description : Get Child Tags Based on Parent Tag Ids
   * @param parentIds List<String>
   * @return : List<DenormalizedTag>
  */
  @AuraEnabled(Cacheable=true) 
  public static List<DenormalizedTag> getChildTagsByParentId(List<String> parentIds) {
    try {
      return  new MallDataServiceHandler().getChildTagsByParentId(parentIds); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getChildTagsByParentId', e); 
    }
  }

  /**
   * 
   * @description :Get Child Tags Based on Parent Tag Names
   * @param parentNames List<String>
   * @return  List<DenormalizedTag>
   */
  @AuraEnabled(Cacheable=true) 
  public static List<DenormalizedTag> getChildTagsByParentName(List<String> parentNames) {
    try {
      return  new MallDataServiceHandler().getChildTagsByParentName(parentNames); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getChildTagsByParentName', e); 
    } 
  }

  /**
   * 
   * @description : Get Tags Based on Parent Tag Ids
   * @param ids List<String>
   * @return  List<DenormalizedTag>
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedTag> getTagsByIds(List<String> ids){
    try {
      return new MallDataServiceHandler().getTagsByIds(ids); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getTagsByIds', e); 
    }
  }

  /**
   * 
   * @description : Get Tags Based on Parent Tag Ids
   * @param mallContext String
   * @param ids List<String>
   * @return  List<DenormalizedTag>
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedTag> getTagsByIdsByContext(String mallContext, List<String> ids){
    try {
      return new MallDataServiceHandler(mallContext).getTagsByIds(ids); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getTagsByIds', e); 
    }
  }

  /**
   * 
   * @description : Get Tags Based on Parent Tag Names
   * @param names List<String>
   * @return  List<DenormalizedTag>
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedTag> getTagsByNames(List<String> names){
    try {
      return new MallDataServiceHandler().getTagsByNames(names); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getTagsByNames', e); 
    }
  }

  /**
   * 
   * @description : Get Products for the Selected TagIds 
   * @param tags List<String>
   * @return  List<DenormalizedProduct>
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedProduct> getProductsByTagIds(List<String> tags) {
    try {
      return new MallDataServiceHandler().getProductsByTagIds(tags); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getProductsByTagIds', e); 
    } 
  }

  /**
   * 
   * @description : Get Products for the Selected Tag Names
   * @param tagNames List<String>
   * @return  List<DenormalizedProduct>
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedProduct> getProductsByTagNames(List<String> tagNames) {
    try {
      return new MallDataServiceHandler().getProductsByTagNames(tagNames); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getProductsByTagNames', e); 
    }
  }

  /**
   * 
   * @description :get Products By  Country
   * @param mallContext String
   * @param countries List<String>
   * @return  List of DenormalizedProduct
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedProduct> getProductsByCountryNames(String mallContext,List<String> countries){
    try {
      return new MallDataServiceHandler(mallContext).getProductsByCountryNames(countries); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getProductsByCountryNames', e); 
    }
  }

  /**
   * 
   * @description :get Products By  Parent Tag Ids
   * @param parentTagIds List of String
   * @return  List of DenormalizedProduct
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedProduct> getProductsByParentTagIds(List<String> parentTagIds) {
    try {
      return new MallDataServiceHandler().getProductsByParentTagIds( parentTagIds); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getProductsByParentTagIds', e); 
    }
  }

  /**
   * 
   * @description :get Shops By tagIds
   * @param mallContext String
   * @param tagIds List of String
   * @return  List of DenormalizedShop
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedShop> getShopsByTagIds(String mallContext, List<String> tagIds) {
    try {
      return new MallDataServiceHandler(mallContext).getShopsByTagIds(tagIds); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getShopsByTagIds', e); 
    }
  }

  /**
   * 
   * @description :getShopsByCountryNames
   * @param countries List of String
   * @return  List of DenormalizedShop
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedShop> getShopsByCountryNames( List<String> countries){
    try {
      return new MallDataServiceHandler().getShopsByCountries( countries);  
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getShopsByCountryNames', e); }
  }

  /**
   * 
   * @description :getShopsByCountryNamesWithContext
   * @param mallContext String
   * @param countries List<String>
   * @return  List of DenormalizedShop
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedShop> getShopsByCountryNamesWithContext(String mallContext, List<String> countries){
    try {
      return new MallDataServiceHandler(mallContext).getShopsByCountries(countries); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getShopsByCountryNamesWithContext', e); 
    }
  }

  /**
   * 
   * @description :getAllShops
   * @param mallContext String
   * @return  List of DenormalizedShop
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedShop> getAllShops(String mallContext) {
    try {
      return new MallDataServiceHandler(mallContext).getAllShops(); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getAllShops', e); 
    }
  }

  /**
   * 
   * @description get Shops By Parent Tag Ids
   * @param parentTagIds List of String
   * @return  List<DenormalizedShop>
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedShop> getShopsByParentTagIds(List<String> parentTagIds) {
    try {
      return new MallDataServiceHandler().getShopsByParentTagIds( parentTagIds); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getShopsByParentTagIds', e); 
    }
  }

  /**
   * 
   * @description get Shops By Parent Tag Ids
   * @param mallContext String
   * @param searchString String
   * @return  List of DenormalizedShop
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedShop> getShopsWhereNameStartsWith(String mallContext, String searchString) {
    try {
      return new MallDataServiceHandler(mallContext).getShopsWhereNameStartsWith(searchString); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getShopsWhereNameStartsWith', e); 
    }
  }

  /**
   * 
   * @description getShopsBySegmentAndCategoryIds
   * @param mallContext String
   * @param segmentIds List of String
   * @param categoryIds List of String
   * @return  List of DenormalizedShop
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedShop> getShopsBySegmentAndCategoryIds(String mallContext, List<String> segmentIds, List<String> categoryIds) {
    try {
      return new MallDataServiceHandler(mallContext).getShopsBySegmentAndCategoryIds(segmentIds, categoryIds); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getShopsBySegmentAndCategoryIds', e); 
    }
  }

  /**
   * 
   * @description getProductsBySegmentAndCategoryIds
   * @param mallContext String
   * @param segmentIds List of String
   * @param categoryIds List of String
   * @return  List of DenormalizedProduct
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedProduct> getProductsBySegmentAndCategoryIds(String mallContext, List<String> segmentIds, List<String> categoryIds) {
    try {
      return new MallDataServiceHandler(mallContext).getProductsBySegmentAndCategoryIds(segmentIds, categoryIds);  
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getProductsBySegmentAndCategoryIds', e); 
    }
  }

  /**
   * 
   * @description getPromotionsBySegmentAndCategoryIds
   * @param mallContext String
   * @param segmentIds List<String>
   * @param categoryIds List<String>
   * @return  List<DenormalizedPromotion>
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedPromotion> getPromotionsBySegmentAndCategoryIds(String mallContext, List<String> segmentIds, List<String> categoryIds) {
    try {
      return new MallDataServiceHandler(mallContext).getPromotionsBySegmentAndCategoryIds(segmentIds, categoryIds);  
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getPromotionsBySegmentAndCategoryIds', e); 
    }
  }

  /**
   * 
   * @description getEventsBySegmentAndCategoryIds
   * @param mallContext String
   * @param segmentIds List<String>
   * @param categoryIds List<String>
   * @return  List<DenormalizedEvent>
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedEvent> getEventsBySegmentAndCategoryIds(String mallContext, List<String> segmentIds, List<String> categoryIds) {
    try {
      return new MallDataServiceHandler(mallContext).getEventsBySegmentAndCategoryIds(segmentIds, categoryIds);  
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getPromotionsBySegmentAndCategoryIds', e); 
    }
  }


  /**
   * 
   * @description initialization
   * @param mallContext String
   * @return  DenormalizedMallState
   */
  @AuraEnabled(Cacheable=true)
  public static DenormalizedMallState initialization(String mallContext) {
    try {
      return new MallDataServiceHandler(mallContext).initialization(); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.initialization', e); 
    }
  }

  /**
   * 
   * @description refreshMallState
   * @param segments List of DenormalizedTag
   * @param selectedSegments List of DenormalizedTag
   * @return  DenormalizedMallState
   */
  @AuraEnabled(Cacheable=true)
  public static DenormalizedMallState refreshMallState(List<DenormalizedTag> segments, List<DenormalizedTag> selectedSegments) {
    try {
      return new MallDataServiceHandler().refreshMallState(segments, selectedSegments); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.refreshMallState', e); 
    }
  }

  /**
   * 
   * @description initializationStore
   * @param mallContext String
   * @return  DenormalizedMallState
   */
  @AuraEnabled(Cacheable=true)
  public static DenormalizedMallState initializationStore(String mallContext) {
    try {
      return new MallDataServiceHandler(mallContext).initializationStore(); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.initializationStore', e); 
    }
  }

  /**
   * 
   * @description getShopsByIds
   * @param mallContext String
   * @param shopIds List of String
   * @return  List of DenormalizedSop
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedShop> getShopsByIds(String mallContext ,List<String> shopIds) {
    try {
      return new MallDataServiceHandler(mallContext).getShopsByIds(shopIds); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getShopsByIds', e); 
    }
  }

  /**
   * @description getProductsByShopIds
   * @param mallContext String
   * @param shopIds List of String 
   * @return  List of DenormalizedProduct
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedProduct> getProductsByShopIds(String mallContext, List<String> shopIds) {
    try {
      return new MallDataServiceHandler(mallContext).getProductsByShopIds(shopIds); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getProductsByShopIds', e); 
    }
  }

  /**
   * 
   * @description getProductsByIds
   * @param mallContext String
   * @param productIds List of String
   * @return  List of DenormalizedProduct
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedProduct> getProductsByIds(String mallContext ,List<String> productIds) {
    try {
      return new MallDataServiceHandler(mallContext).getProductsByIds(productIds); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getProductsByIds', e); 
    }
  }

  /**
   * 
   * @description getOfferingsBySolutionIds
   * @param mallContext String
   * @param solutionIds List<String>
   * @param recordTypeName String
   * @return  List<DenormalizedProduct>
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedProduct> getOfferingsBySolutionIds(String mallContext ,List<String> solutionIds, String recordTypeName) {
    try {
      return new MallDataServiceHandler(mallContext).getOfferingsBySolutionIds(solutionIds, recordTypeName); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getProductsByIds', e); 
    }
  }

  /**
   * 
   * @description getContentsByTagIdsRootNamesAndRecordTypeNames
   * @param mallContext String
   * @param rootTagNames List<String>
   * @param tagIds List<String>
   * @param recordTypes List<String>
   * @return  List<DenormalizedContent>
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedContent> getContentsByTagIdsRootNamesAndRecordTypeNames(String mallContext ,List<String> rootTagNames, List<String> tagIds, List<String> recordTypes) {
    try {
      return new MallDataServiceHandler(mallContext).getContentsByTagIdsRootNamesAndRecordTypeNames(rootTagNames, tagIds, recordTypes); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getContentsByTagIdsRootNamesAndRecordTypeNames', e); 
    }
  }

  /**
   * 
   * @description getContactUsEmailByCountry
   * @param countryName String
   * @return  String
   */
  @AuraEnabled(Cacheable=true)
  public static String getContactUsEmailByCountry(String countryName) {
    try {
      return new MallDataServiceHandler().getContactUsEmailByCountry(countryName); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getContactUsEmailByCountry', e); 
    }
  }

  /**
   * 
   * @description getLegalInfo
   * @param mallContext String
   * @return  List of DenormalizedContent
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedContent> getLegalInfo(String mallContext) {
    try {
      return new MallDataServiceHandler(mallContext).getLegalInfo(); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getLegalInfo', e); 
    }
  }

  /**
   * 
   * @description getSuccessStoriesByCountryNames
   * @param mallContext String
   * @param countries List<String>
   * @return  List of DenormalizedSuccessStory
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedSuccessStory> getSuccessStoriesByCountryNames(String mallContext, List<String> countries) {
    try {
      return new MallDataServiceHandler(mallContext).getSuccessStoriesByCountryNames(countries); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getSuccessStoriesByCountryNames', e); 
    }
  }

    /**
   * 
   * @description getSuccessStoriesByIds
   * @param mallContext String
   * @param successStoryIds List<String>
   * @return  List of DenormalizedSuccessStory
   */
  @AuraEnabled(Cacheable=true)
  public static List<DenormalizedSuccessStory> getSuccessStoriesByIds(String mallContext, List<String> successStoryIds) {
    try {
      return new MallDataServiceHandler(mallContext).getSuccessStoriesByIds(successStoryIds); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getSuccessStoriesByIds', e); 
    }
  }

  /**
   * 
   * @description getORGId
   * @return  String
   */
  @AuraEnabled(Cacheable=true)
  public static String getORGId() {
    try {
      return UserInfo.getOrganizationId(); 
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getORGId', e); 
    }
  }

  /**
   * 
   * @description getSolutionsBySegmentAndCategories
   * @param mallContext String
   * @param segmentIds List of String
   * @param categoryIds List of String
   * @return  List of DenormalizedProduct
   */
  @AuraEnabled(Cacheable=true)
  public static List<MallDataServiceHandler.SolutionResponse> getSolutionsBySegmentAndCategories(String mallContext, List<String> segmentIds, List<String> categoryIds) {
    try {
      return new MallDataServiceHandler(mallContext).getSolutionsBySegmentAndCategories(segmentIds, categoryIds);  
    } catch (Exception e) { 
      throw MallExceptionUtil.throwAuraException('MallDataService.getProductsBySegmentAndCategoryIds', e); 
    }
  }



  @AuraEnabled(cacheable=true)
    public static List<DenormalizedProduct> getTagOfferingsByCategoryNames() {
      try {
        return new MallDataServiceHandler().getTagOfferingsByCategoryNames();
      } catch (Exception e) { 
        throw MallExceptionUtil.throwAuraException('MallDataService.getTagOfferingsByCategoryNames', e); 
      }
    }

}