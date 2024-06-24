/**
 * 
 * @description Controller Class for Whats_new.component
 * @author Ankit Kumar
 * @since 
 */
public with sharing class CTRL_MallWhatsNewEmailNotification {
    /**
     * 
     * @description content need to be shown in the component
     */
    public List<MallEmailTemplateContent.MallNewContent> newContents {get;set;}
    /**
     * 
     * @description content formatted to contain data to be shown in a row
     */
    public List<MallEmailTemplateContent> mallNewContentRows{get;set;}
    /**
     * 
     * @description mallNewContentRowsStores
     */
    public List<MallEmailTemplateContent> mallNewContentRowsStores{get;set;}
    /**
     * 
     * @description mallNewContentRowsServices
     */
    public List<MallEmailTemplateContent> mallNewContentRowsServices{get;set;}
    /**
     * 
     * @description mallNewContentRowsPromotions
     */
    public List<MallEmailTemplateContent> mallNewContentRowsPromotions{get;set;}
    /**
     * 
     * @description mallNewContentRowsInsights
     */
    public List<MallEmailTemplateContent> mallNewContentRowsInsights{get;set;}
    /**
     * 
     * @description mallNewContentRowsBusinessEvents
     */
    public List<MallEmailTemplateContent> mallNewContentRowsBusinessEvents{get;set;}
    /**
     * 
     * @description storeHeading
     */
    public String storeHeading {get;set;}
    /**
     * 
     * @description servicesHeading
     */
    public String servicesHeading {get;set;}
    /**
     * 
     * @description promotionHeading
     */
    public String promotionHeading {get;set;}
    /**
     * 
     * @description insightHeading
     */
    public String insightHeading {get;set;}
    /**
     * 
     * @description eventHeading
     */
    public String eventHeading {get;set;}

    /**
     * 
     * @description storesDescription
     */
    public String storesDescription {get;set;}
    /**
     * 
     * @description servicesDescription
     */
    public String servicesDescription{get;set;}
    /**
     * 
     * @description promotionsDescription
     */
    public String promotionsDescription{get;set;}
    /**
     * 
     * @description insightsDescription
     */
    public String insightsDescription{get;set;}
    /**
     * 
     * @description eventsDescription
     */
    public String eventsDescription{get;set;}

    /**
     * 
     * @description contentHeaderImage
     */

    public String contentHeaderImage {get;set;}
    /**
     * 
     * @description backgroundColour
     */
    public String backgroundColour {get;set;}
    /**
     * 
     * @description backgroundColourInverse
     */
    public String backgroundColourInverse {get;set;}

    /**
     * 
     * @description baseUrl
     */
    private String baseUrl {get;set;}

    
    /**
     * 
     * @description CTRL_MallWhatsNewEmailNotification constructor
     */
    public CTRL_MallWhatsNewEmailNotification() {
        initializeContent();
    }

    /**
     * 
     * @description initializeContent
     */
    public void initializeContent() {
        try{
            baseUrl = new MallEmailTemplateContentHelper().getBaseUrl();
            backgroundColour = System.Label.BCB_PLATFORM_WHATS_NEW_EMAIL_BACKGROUND_COLOUR;
            backgroundColourInverse = System.Label.BCB_PLATFORM_WHATS_NEW_EMAIL_BACKGROUND_COLOUR_INV;
            contentHeaderImage = System.Label.BCB_PLATFORM_WHATS_NEW_EMAIL_CONTENT_HEADER_IMAGE;
            processProviders();
            processOfferings();
            processPromotions();
            processBusinessEvents();
        }catch (Exception e) { 
            throw MallExceptionUtil.throwAuraException('CTRL_MallWhatsNewEmailNotification.initializeContent', e);
        }
    }

    /**
     * 
     * @description processProviders
     */
    private void processProviders() {
        try {
            List<String> providerIds = new List<String>();
            List<Tag_Provider__c> tagProviders=new List<Tag_Provider__c>();
            String tagProviderWhereClause=' Tag__r.Parent_Name__c=\'Category\' AND Provider__r.Publishing_Unit__r.Published_from__c= LAST_MONTH AND Provider__r.IsOnline__c=TRUE';
            tagProviders = SEL_TagProviders.newInstance().selectByCustomFilterCondition(tagProviderWhereClause);
    
            for(Tag_Provider__c ts : tagProviders) {
                providerIds.add(ts.Provider__c);
            }
            List<DenormalizedShop> providers = getShopsByIds(providerIds);
            newContents = new List<MallEmailTemplateContent.MallNewContent>();
            Set<String> providerIdsSet = new Set<String>();
            storeHeading = System.Label.MALL_WHATS_NEW_EMAIL_STORE_HEADING;
            storesDescription = System.Label.MALL_WHATS_NEW_EMAIL_STORE_DESCRIPTION;
            for(DenormalizedShop ds: providers) {
                MallEmailTemplateContent.MallNewContent newContent = new MallEmailTemplateContent.MallNewContent();
                if(!providerIdsSet.contains(ds.Id)) {
                    providerIdsSet.add(ds.Id);
                    newContent.name = ds.name;
                    newContent.imageUrl = ds.imageUrl;
                    newContent.title = ds.title;
                    if(String.isNotBlank(newContent.title) && newContent.title.length() > 42) {
                        newContent.title = newContent.title.substring(0,40) + '...';
                    }
                    newContent.description = ds.description;
                    newContent.navUrl = baseUrl + '/mall/s/account/' + ds.id;
                    newContents.add(newContent);
                }
            }
    
            if(newContents.size() > 0) {
                mallNewContentRowsStores = new MallEmailTemplateContentHelper().formatContentForRows(newContents);
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallWhatsNewEmailNotification.processProviders', e);
        }
    }

    /**
     * 
     * @description processOfferings
     */
    private void processOfferings() {
        try {
            List<Tag_Offering__c> tagProducts=new List<Tag_Offering__c>();
            List<String> productIds = new List<String>();

            String tagProductWhereClause=' Tag__r.Parent_Name__c=\'Category\' AND Offering__r.Publishing_Unit__r.Published_from__c = LAST_MONTH AND Offering__r.IsOnline__c=TRUE';
            tagProducts = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(tagProductWhereClause);

            for(Tag_Offering__c tp: tagProducts) {
                productIds.add(tp.Offering__c);
            }

            List<DenormalizedProduct> products = getProductsByIds(productIds);
            newContents = new List<MallEmailTemplateContent.MallNewContent>();
            Set<String> productIdsSet = new Set<String>();
            servicesHeading = System.Label.MALL_WHATS_NEW_EMAIL_SERVICES_HEADING;
            newContents = new List<MallEmailTemplateContent.MallNewContent>();
            for(DenormalizedProduct dp: products) {
                MallEmailTemplateContent.MallNewContent newContent = new MallEmailTemplateContent.MallNewContent();
                if(!productIdsSet.contains(dp.Id)) {
                    productIdsSet.add(dp.Id);
                    newContent.name = dp.name;
                    newContent.imageUrl = dp.imageUrl;
                    newContent.title = dp.title;
                    if(String.isNotBlank(newContent.title) && newContent.title.length() > 42) {
                        newContent.title = newContent.title.substring(0,40) + '...';
                    }
                    newContent.description = dp.description;
                    newContent.navUrl = baseUrl + '/mall/s/account/' + dp.shopId;
                    newContents.add(newContent);
                }
            }

            if(newContents.size() > 0) {
                mallNewContentRowsServices = new MallEmailTemplateContentHelper().formatContentForRows(newContents);
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallWhatsNewEmailNotification.processOfferings', e);
        }
    }

    /**
     * 
     * @description processPromotions
     */
    private void processPromotions() {
        try {
            promotionHeading = System.Label.MALL_WHATS_NEW_EMAIL_PROMOTIONS_HEADING;
            promotionsDescription = System.Label.MALL_WHATS_NEW_EMAIL_PROMOTIONS_DESCRIPTION;

            String promotionWhereClause='Publishing_Unit__r.Published_from__c = THIS_MONTH AND IsOnline__c = TRUE';
            List<Promotion__c> promotions = SEL_Promotions.newInstance().selectByCustomFilterCondition(promotionWhereClause); 

            newContents = new List<MallEmailTemplateContent.MallNewContent>();
            for(Promotion__c promotion: promotions) {
                MallEmailTemplateContent.MallNewContent newContent = new MallEmailTemplateContent.MallNewContent();
                if(String.isNotBlank(promotion.Name) && promotion.Name.length() > 47) {
                    promotion.Name = promotion.Name.substring(0,45) + '...';
                }
                newContent.name = promotion.Name;
                newContent.title = promotion.Name;
                newContent.description = promotion.Name;
                newContent.expiryDate = promotion.Publishing_Unit__r.Published_Until__c;
                if(String.IsNotBlank(promotion.Image_Path_Desktop__c) && !promotion.Image_Path_Desktop__c.startsWith('http')) {
                    promotion.Image_Path_Desktop__c = baseUrl + promotion.Image_Path_Desktop__c;
                }
                newContent.imageUrl = promotion.Image_Path_Desktop__c;
                newContent.navUrl = baseUrl + '/mall/s?promotionId='+promotion.Id;
                newContents.add(newContent);
            }

            if(newContents.size() > 0) {
                mallNewContentRowsPromotions = new MallEmailTemplateContentHelper().formatContentForRows(newContents);
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallWhatsNewEmailNotification.processPromotions', e);
        }
    }


    /**
     * 
     * @description processBusinessEvents
     */
    private void processBusinessEvents() {
        try {
            eventHeading = System.Label.MALL_WHATS_NEW_EMAIL_EVENTS_HEADING;
            eventsDescription = System.Label.MALL_WHATS_NEW_EMAIL_EVENTS_DESCRIPTION;
            String whereClauseEvents = 'Tag__r.Name = \'Business\' AND Business_Event__r.Publishing_Unit__r.Published_from__c = THIS_MONTH AND Business_Event__r.IsOnline__c = TRUE';

            List<Tag_Business_Event__c> tagEvents = SEL_MALL_TagEvents.newInstance().selectByCustomFilterCondition(whereClauseEvents);

            Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslationEvents = new MallEventsDataServiceHelper().prepareEventsForLanguage(tagEvents);
            List<DenormalizedEvent> businessEvents = new MallEventsDataServiceHelper().denormalizeEvents(tagEvents, mapContentTypMapContentUnitTranslationEvents.get(MallDataServiceHandler.CONTENT_UNIT_TRANSLATION));
            newContents = new List<MallEmailTemplateContent.MallNewContent>();

            for(DenormalizedEvent businessEvent: businessEvents) {
                MallEmailTemplateContent.MallNewContent newContent = new MallEmailTemplateContent.MallNewContent();
                newContent.name = businessEvent.title;
                if(String.isNotBlank(newContent.name) && newContent.name.length() > 47) {
                    newContent.name = newContent.name.substring(0,45) + '...';
                }
                newContent.title = businessEvent.description;
                if(String.isNotBlank(newContent.title) && newContent.title.length() > 47) {
                    newContent.title = newContent.title.substring(0,45) + '...';
                }
                newContent.description = businessEvent.description;
                if(String.isNotBlank(newContent.description) && newContent.description.length() > 47) {
                    newContent.description = newContent.description.substring(0,45) + '...';
                }
                newContent.startDate = businessEvent.startDate;
                newContent.imageUrl = businessEvent.imageUrl;
                newContent.navUrl = baseUrl + '/mall/s?evenId='+ businessEvent.Id;
                newContents.add(newContent);
            }

            if(newContents.size() > 0) {
                mallNewContentRowsBusinessEvents = new MallEmailTemplateContentHelper().formatContentForRows(newContents);
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallWhatsNewEmailNotification.processBusinessEvents', e);
        }
    }

    /**
     * 
     * @description getShopsByIds
     * @param shopIds List<String>
     * @return List<DenormalizedShop> 
     */
    public List<DenormalizedShop> getShopsByIds(List<String> shopIds) {
        String whereClause = ' Provider__c IN (\'' + String.join(shopIds, '\',\'') + '\')';
        List<Tag_Provider__c> tagShops = SEL_TagProviders.newInstance().selectByCustomFilterCondition(whereClause);
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallDataServiceHelper().prepareShopsForLanguage(tagShops);
        return new MallDataServiceHelper().denormalizeShop(tagShops, mapContentTypMapContentUnitTranslation.get(MallDataServiceHandler.ICON_CONTENT_UNIT_TRANSLATION), mapContentTypMapContentUnitTranslation.get(MallDataServiceHandler.CONTENT_UNIT_TRANSLATION));
    }

    /**
     * 
     * @description getProductsByIds
     * @param productIds List<String>
     * @return List<DenormalizedProduct> 
     */
    public List<DenormalizedProduct> getProductsByIds(List<String> productIds) {
        String whereClause = ' Offering__c IN (\'' + String.join(productIds, '\',\'') + '\')';
        List<Tag_Offering__c> tagProducts = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(whereClause);
        
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallDataServiceHelper().prepareProductsForLanguage(tagProducts);   
        return new MallDataServiceHelper().denormalizeProducts(tagProducts, mapContentTypMapContentUnitTranslation.get(MallDataServiceHandler.CONTENT_UNIT_TRANSLATION));
    }
}