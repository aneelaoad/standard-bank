/**
 * @description MallPromotionsDataService
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallPromotionsDataService {

    /**
     * 
     * @description This method queries the Tag/Promotion by Country
     * @param countries List of Country Names
     * @return  List DenormalizedPromotion
     */
    public List<DenormalizedPromotion> getPromotionsByCountryNames(List<String> countries) {
        Set<String> countriesSet = new Set<String>();
        countriesSet.addAll(countries);
        List<Tag_Promotion__c> tagPromotions = SEL_TagPromotions.newInstance().selectByTagNames(countriesSet);
        Map<Id,Promotion_Translation__c> mapContentTypMapContentUnitTranslation = new MallPromotionsDataServiceHelper().preparePromotionsForLanguage(tagPromotions);   
        return new MallPromotionsDataServiceHelper().denormalizePromotions(tagPromotions, mapContentTypMapContentUnitTranslation);
    } 

    /**
     * 
     * @description getPromotionsBySegmentAndCategoryIds
     * @param segmentIds List of String Ids
     * @param categoryIds  List of String Ids
     * @return  List of DenormalizedPromotion
     */
    public List<DenormalizedPromotion> getPromotionsBySegmentAndCategoryIds(List<String> segmentIds, List<String> categoryIds) {
        List<String> allTagIds = new List<String>();
        allTagIds.addAll(segmentIds);
        allTagIds.addAll(categoryIds);

        Set<Id> allTagIdsSet = new Set<Id>();
        allTagIdsSet.addAll((List<Id>)allTagIds);
        List<Tag_Promotion__c> tagPromotions = SEL_TagPromotions.newInstance().selectByTagIds(allTagIdsSet);

        Map<String, List<Tag_Promotion__c>> mapPromotionIdTagPromotions =  new Map<String, List<Tag_Promotion__c>>();
        List<Tag_Promotion__c> tagPromotionsConsolidated = new List<Tag_Promotion__c>();
        List<String> promotionIds = new List<String>();


        for(Tag_Promotion__c tagPromotion : tagPromotions) {
            if(!mapPromotionIdTagPromotions.containsKey(tagPromotion.Promotion__c)) {
                mapPromotionIdTagPromotions.put(tagPromotion.Promotion__c, new List<Tag_Promotion__c>{tagPromotion});
            } else {
                List<Tag_Promotion__c> tagPromotionsTemp = mapPromotionIdTagPromotions.get(tagPromotion.Promotion__c);
                tagPromotionsTemp.add(tagPromotion);
                mapPromotionIdTagPromotions.put(tagPromotion.Promotion__c, tagPromotionsTemp);
            }
        }

        for(String promotionId : mapPromotionIdTagPromotions.KeySet()) {
            List<Tag_Promotion__c> tPromotions = mapPromotionIdTagPromotions.get(promotionId);
            Boolean segmentPromotionExists = FALSE;
            Boolean categoryPromotionExists = FALSE;
            Integer categoryIndex = 0;
            for(Integer row=0;  row < tPromotions.size() ; row++) {
                if(tPromotions[row].Tag__r.Root_Name__c == 'Segment') {
                    segmentPromotionExists = TRUE;
                }
                if(tPromotions[row].Tag__r.Root_Name__c == 'Category') {
                    categoryPromotionExists = TRUE;
                    categoryIndex = row;
                }
            }
            if(segmentPromotionExists && categoryPromotionExists) {
                tagPromotionsConsolidated.add(tPromotions[categoryIndex]);
                promotionIds.add(tPromotions[categoryIndex].Promotion__c);
            }
        }

        String whereClause = ' Promotion__c IN (\'' + String.join(promotionIds, '\',\'') + '\')';
        whereClause += ' AND Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\'';
        List<Tag_Promotion__c> tagPromotionsForCountry = SEL_TagPromotions.newInstance().selectByCustomFilterCondition(whereClause);
        //consolidate all tag shops
        tagPromotionsConsolidated.addAll(tagPromotionsForCountry);
        return preparePromotionsForCountryAndLanguage(tagPromotionsConsolidated);
    }

    /**
     * 
     * @description This method prepares the promotions for country and language
     * @param tagPromotions List of Tag Promotions
     * @return  List of DenormalizedPromotion
     */
    public List<DenormalizedPromotion> preparePromotionsForCountryAndLanguage(List<Tag_Promotion__c> tagPromotions) {
        
        //De-duplicate the Promotions since there will be tagPromotion for country as well as tag itself
        tagPromotions = new MallPromotionsDataServiceHelper().preparePromotionsForCountry(tagPromotions);
        //get the content translation based on user language
        Map<Id,Promotion_Translation__c> mapContentTypMapContentUnitTranslation = new MallPromotionsDataServiceHelper().preparePromotionsForLanguage(tagPromotions);
        
        return new MallPromotionsDataServiceHelper().denormalizePromotions(tagPromotions, mapContentTypMapContentUnitTranslation);
    } 
}