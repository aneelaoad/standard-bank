/**
 * @description MallPromotionsDataServiceHelper
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallPromotionsDataServiceHelper {

    /**
	 * @description This method prepares the Promotions for the country
     * @param tagPromotions List of Tag_Promotion__c
	 * @return List of Tag_Promotion__c  
	*/
    public List<Tag_Promotion__c> preparePromotionsForCountry(List<Tag_Promotion__c> tagPromotions) {
        List<String> tagIds = new List<String>();
        List<String> categoryTagIds = new List<String>();
        for(Tag_Promotion__c tagPromotionVar : tagPromotions) {
            if(tagPromotionVar.Tag__r.Parent_Name__c!='Country') {
                tagIds.add(tagPromotionVar.Tag__c);
            }
            if(tagPromotionVar.Tag__r.Parent_Name__c =='Category') {
                categoryTagIds.add(tagPromotionVar.Tag__c);
            }
        }
        List<Tag_Promotion__c> tagPromotionsForCountry = new List<Tag_Promotion__c>();
        Map<Id, List<Tag_Promotion__c>> mapPromotionIdTagPromotions = new Map<Id, List<Tag_Promotion__c>>();
        for(Tag_Promotion__c tagPromotion : tagPromotions) {
            if(!mapPromotionIdTagPromotions.containsKey(tagPromotion.Promotion__c)) {
                mapPromotionIdTagPromotions.put(tagPromotion.Promotion__c, new List<Tag_Promotion__c>{tagPromotion});
            } else {
                List<Tag_Promotion__c> tagPromotionsLst = mapPromotionIdTagPromotions.get(tagPromotion.Promotion__c);
                tagPromotionsLst.add(tagPromotion);
                mapPromotionIdTagPromotions.put(tagPromotion.Promotion__c, tagPromotionsLst);
            }
        }

        for(String promotionId: mapPromotionIdTagPromotions.KeySet()) {
            List<Tag_Promotion__c> tagPromotionsTemp = mapPromotionIdTagPromotions.get(promotionId);
            if(tagPromotionsTemp.size() >= 1 ) {
                Boolean countryPromotionExists = FALSE;
                Boolean tagPromotionExists = FALSE;
                Integer categoryIndex = 0;
                for(Integer row=0; row < tagPromotionsTemp.size(); row++) {
                    if(tagPromotionsTemp[row].Tag__r.Name == MallDataServiceHandler.userCountry) {
                        countryPromotionExists = TRUE;
                    }
                    if(tagIds.contains(tagPromotionsTemp[row].Tag__c) && categoryTagIds.contains(tagPromotionsTemp[row].Tag__c)) {
                        tagPromotionExists = TRUE;
                        categoryIndex = row;
                    }
                }
                if(countryPromotionExists && tagPromotionExists) {
                    tagPromotionsForCountry.add(tagPromotionsTemp[categoryIndex]);
                }
            } 
        }

        return tagPromotionsForCountry;
    }  

    /**
	 * @description This method returns the content unit translation for promotions for the user selected languages 
     * @param tagPromotions List<Tag_Promotion__c>
     * @return Map<String,Map<Id,ContentTranslation>>
	*/
    public Map<Id,Promotion_Translation__c> preparePromotionsForLanguage(List<Tag_Promotion__c> tagPromotions) {
        Set<String> promotionIds = new Set<String>();
        List<String> promotionIdsLst = new List<String>();
        List<String> userLanguages = getUserLanguages();

        for(Tag_Promotion__c tagPromotion : tagPromotions) {
            promotionIds.add(tagPromotion.Promotion__c);
        } 
        promotionIdsLst.addAll(promotionIds);

        Map<Id,Promotion_Translation__c> mapPromotionIdAndContentTranslation = new Map<Id,Promotion_Translation__c>();
        String whereClause = 'Promotion__c IN (\'' + String.join(promotionIdsLst, '\',\'') + '\')';
        whereClause += ' AND Language_ISO__c IN (\'' + String.join(userLanguages, '\',\'') + '\')';

        List<Promotion_Translation__c> contentTranslations = new List<Promotion_Translation__c>();
        contentTranslations = SEL_PromotionTranslations.newInstance().selectByCustomFilterCondition(whereClause);

        for(Promotion_Translation__c contentTranslation: contentTranslations) {
        if(mapPromotionIdAndContentTranslation.containsKey(contentTranslation.Promotion__c)) {
            if( mapPromotionIdAndContentTranslation.get(contentTranslation.Promotion__c).Language_ISO__c == MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO
                    && (contentTranslation.Language_ISO__c != MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO)) {
                mapPromotionIdAndContentTranslation.put(contentTranslation.Promotion__c, contentTranslation);  
                MallDataServiceHandler.mallMultiLanguageContent = true;
             }
        } else {
            mapPromotionIdAndContentTranslation.put(contentTranslation.Promotion__c, contentTranslation);  
             }      
        }
        return mapPromotionIdAndContentTranslation;
    }

    /**
     * 
     * @description This method denormalizes the Promotion based on tagPromotions and content and icon from CUT
     * @param tagPromotions List<Tag_Promotion__c>
     * @param mapPromotionIdAndContentTranslation Map<Id, ContentTranslation>
     * @return  List<DenormalizedPromotion>
     */
    public List<DenormalizedPromotion> denormalizePromotions(List<Tag_Promotion__c> tagPromotions, Map<Id, Promotion_Translation__c> mapPromotionIdAndContentTranslation) {
        List<DenormalizedPromotion> promotionsDenormalized = new List<DenormalizedPromotion>();
        for(Tag_Promotion__c tagPromotion: tagPromotions) {
            DenormalizedPromotion promotionDenormalized = new DenormalizedPromotion();
            promotionDenormalized.tagId=tagPromotion.Tag__c;
            promotionDenormalized.tagName=tagPromotion.Tag__r.Name;
            promotionDenormalized.id = tagPromotion.Promotion__r.id;
            promotionDenormalized.name = tagPromotion.Promotion__r.Name;
            promotionDenormalized.isOnline = tagPromotion.Promotion__r.Publishing_Unit__r.isPublished__c;
            if(String.isNotBlank(tagPromotion.Promotion__r.Provider__c)) {
                promotionDenormalized.shopId = tagPromotion.Promotion__r.Provider__c;
                promotionDenormalized.shopName = tagPromotion.Promotion__r.Provider__r.Name;
            }
            promotionDenormalized.heading = tagPromotion.Promotion__r.Small_Title__c;
            promotionDenormalized.description = tagPromotion.Promotion__r.Large_Title__c;
            promotionDenormalized.subText = tagPromotion.Promotion__r.SubText__c;
            promotionDenormalized.buttonLabel = tagPromotion.Promotion__r.Button_Label__c;
            promotionDenormalized.buttonTitle = tagPromotion.Promotion__r.Button_Title__c;
            promotionDenormalized.action = tagPromotion.Promotion__r.Action__c;
            promotionDenormalized.variant = tagPromotion.Promotion__r.Variant__c;
            promotionDenormalized.wClass = tagPromotion.Promotion__r.WClass__c;
            promotionDenormalized.disabled = tagPromotion.Promotion__r.Disabled__c;
            promotionDenormalized.showButton = tagPromotion.Promotion__r.Show_Button__c;
            promotionDenormalized.isCarousel = tagPromotion.Promotion__r.IsCarousel__c;
            promotionDenormalized.customBannerStyles = tagPromotion.Promotion__r.Custom_Banner_Styles__c;
            promotionDenormalized.applyColourContrastInversion = tagPromotion.Promotion__r.Apply_Colour_Contrast_Inversion__c;
            promotionDenormalized.customBackgroundColour = tagPromotion.Promotion__r.Custom_Background_Colour__c;
            promotionDenormalized.rank = (Integer)tagPromotion.Promotion__r.Rank__c;
            promotionDenormalized.imagePath = tagPromotion.Promotion__r.Image_Path__c;
            promotionDenormalized.imagePathDesktop = tagPromotion.Promotion__r.Image_Path_Desktop__c;
            promotionDenormalized.imagePathTablet = tagPromotion.Promotion__r.Image_Path_Tablet__c;
            promotionDenormalized.destinationUrl = tagPromotion.Promotion__r.Destination_Url__c;
            promotionDenormalized.promotionType = tagPromotion.Promotion__r.Promotion_Type__c;
            promotionDenormalized.isDefaultCategoryBanner = tagPromotion.Promotion__r.Is_Default_Category_Banner__c;
            if(mapPromotionIdAndContentTranslation.containsKey(tagPromotion.Promotion__c)) {
                Promotion_Translation__c contentUnitTranslation = mapPromotionIdAndContentTranslation.get(tagPromotion.Promotion__c);
                if(String.isNotBlank(contentUnitTranslation.Button_Label__c)) {
                    promotionDenormalized.buttonLabel = contentUnitTranslation.Button_Label__c;
                }
                if(String.isNotBlank(contentUnitTranslation.Button_Title__c)) {
                    promotionDenormalized.buttonTitle = contentUnitTranslation.Button_Title__c;
                }
                if(String.isNotBlank(contentUnitTranslation.Button_Title__c)) {
                    promotionDenormalized.heading = contentUnitTranslation.Small_Title__c;
                }
                if(String.isNotBlank(contentUnitTranslation.Button_Title__c)) {
                    promotionDenormalized.subText = contentUnitTranslation.SubText__c;
                }
                if(String.isNotBlank(contentUnitTranslation.Button_Title__c)) {
                    promotionDenormalized.description = contentUnitTranslation.Large_Title__c;
                }
            }
            promotionsDenormalized.add(promotionDenormalized);
        }
        return promotionsDenormalized;
    }

    /**
	 * @description This method returns the languages the user content should be served based on preferences
	 * @return List<String> : languages
	 */
    public List<String> getUserLanguages() {
        List<String> userLanguages = new List<String>();
        userLanguages.add(MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO);

        if(string.isNotBlank(MallDataServiceHandler.userContentLanguage) && (MallDataServiceHandler.userContentLanguage != MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO)) {
            userLanguages.add(MallDataServiceHandler.userContentLanguage);
        }
        return userLanguages;
    }

}