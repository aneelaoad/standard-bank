/**
 * 
 * @description Helper Class for MallDataService
 * @author Maham Hasan
 * @since 
 */
public with sharing class MallDataServiceHelper {

    /**
     * 
     * @description This method denormalizes the product based on tagproducts and content and icon from CUT
     * @param tagProducts List<Tag_Offering__c>
     * @param mapProductIdAndContentTranslation Map<Id, Content_Unit_Translation__c>
     * @return   List of DenormalizedProduct
     */
    public List<DenormalizedProduct> denormalizeProducts (List<Tag_Offering__c> tagProducts, 
        Map<Id, Content_Unit_Translation__c> mapProductIdAndContentTranslation) {
        List<DenormalizedProduct> productsDenormalized = new List<DenormalizedProduct>();
        for(Tag_Offering__c tagProduct: tagProducts) {
            DenormalizedProduct productDenormalized = new DenormalizedProduct();
            productDenormalized.tagId=tagProduct.Tag__c;
            productDenormalized.tagName=tagProduct.Tag__r.Name;
            productDenormalized.id = tagProduct.Offering__r.id;
            productDenormalized.name = tagProduct.Offering__r.Name;
            if(String.isNotBlank(tagProduct.Offering__r.RecordTypeId)) {
                productDenormalized.offeringType = tagProduct.Offering__r.RecordType.Name;
            }
            productDenormalized.createdDate = tagProduct.Offering__r.CreatedDate;
            productDenormalized.isPublished = tagProduct.Offering__r.Publishing_Unit__r.isPublished__c;
            productDenormalized.publishedFrom = tagProduct.Offering__r.Publishing_Unit__r.published_From__c;
            productDenormalized.publishedUntil = tagProduct.Offering__r.Publishing_Unit__r.published_Until__c;
            productDenormalized.isOnline = (tagProduct.Offering__r.Publishing_Unit__r.published_Until__c > tagProduct.Offering__r.Publishing_Unit__r.Published_From__c) ? TRUE : FALSE;
            productDenormalized.shopId = tagProduct.Offering__r.Provider__c;
            productDenormalized.shopName = tagProduct.Offering__r.Provider__r.Name;
            productDenormalized.shopImageUrl = (tagProduct.Offering__r.Provider__r.Default_Translation__c != NULL) ? tagProduct.Offering__r.Provider__r.Default_Translation__r.Image_URL__c : NULL;

            if(String.isNotBlank(tagProduct.Offering__r.Link__c)) {
                productDenormalized.guestUrl = tagProduct.Offering__r.Link__r.Guest_url__c;
                productDenormalized.desktopUrl = tagProduct.Offering__r.Link__r.Desktop_url__c;
                productDenormalized.mobileUrl = tagProduct.Offering__r.Link__r.Mobile_url__c;
            }

            if(mapProductIdAndContentTranslation.containsKey(tagProduct.Offering__c)) {
                Content_Unit_Translation__c contentUnitTranslation = mapProductIdAndContentTranslation.get(tagProduct.Offering__c);
                if(String.isNotBlank(contentUnitTranslation.Title__c)) {
                    productDenormalized.title = contentUnitTranslation.Title__c;
                }
                if(String.isNotBlank(contentUnitTranslation.Text__c)) {
                    productDenormalized.text = contentUnitTranslation.Text__c;
                }
                if(String.isNotBlank(contentUnitTranslation.RichText__c)) {
                    productDenormalized.description = contentUnitTranslation.RichText__c;
                }
                if(String.isNotBlank(contentUnitTranslation.Image_Url__c)) {
                productDenormalized.imageUrl = contentUnitTranslation.Image_Url__c;
                }
            }
            productsDenormalized.add(productDenormalized);
        }
        return productsDenormalized;
    }


    /**
     * @description This method returns the content unit translation for prodcts for the user selected languages 
     * @param tagProducts List<Tag_Offering__c>
     * @return Map<String,Map<Id,Content_Unit_Translation__c>>
    */
    public Map<String,Map<Id,Content_Unit_Translation__c>> prepareProductsForLanguage(List<Tag_Offering__c> tagProducts) {
        Set<String> productIds = new Set<String>();
        List<String> productIdsLst = new List<String>();
        List<String> userLanguages = getUserLanguages();

        for(Tag_Offering__c tagProduct : tagProducts) {
            productIds.add(tagProduct.Offering__c);
        } 
        productIdsLst.addAll(productIds);

        List<Content_Unit_Translation__c> contentTranslationUnits = new List<Content_Unit_Translation__c>();
        Map<Id,Content_Unit_Translation__c> mapProductIdAndContentTranslation = new Map<Id,Content_Unit_Translation__c>();
        String whereClause = 'Product__c IN (\'' + String.join(productIdsLst, '\',\'') + '\')';
        whereClause += ' AND Language_ISO__c IN (\'' + String.join(userLanguages, '\',\'') + '\')';


        contentTranslationUnits = getContentUnitTranslations(whereClause);

        for(Content_Unit_Translation__c contentTranslationUnit: contentTranslationUnits) {

            if(mapProductIdAndContentTranslation.containsKey(contentTranslationUnit.Product__c)) {
            if( mapProductIdAndContentTranslation.get(contentTranslationUnit.Product__c).Language_ISO__c == MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO
                    && (contentTranslationUnit.Language_ISO__c != MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO)) {
                mapProductIdAndContentTranslation.put(contentTranslationUnit.Product__c, contentTranslationUnit);  
                MallDataServiceHandler.mallMultiLanguageContent = true;
             }
        } else {
            mapProductIdAndContentTranslation.put(contentTranslationUnit.Product__c, contentTranslationUnit);  
             }      
        }

        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new Map<String,Map<Id,Content_Unit_Translation__c>>();
        mapContentTypMapContentUnitTranslation.put(MallDataServiceHandler.ICON_CONTENT_UNIT_TRANSLATION,null);
        mapContentTypMapContentUnitTranslation.put(MallDataServiceHandler.CONTENT_UNIT_TRANSLATION,mapProductIdAndContentTranslation);

        return mapContentTypMapContentUnitTranslation;
    }

    /**
     * @description This method prepares the Products for the country
     * @param tagProducts List<Tag_Offering__c>
     * @return List of Tag_Offering__c
    */
    public List<Tag_Offering__c> prepareProductsForCountry(List<Tag_Offering__c> tagProducts) {
        List<String> tagIds = new List<String>();
        List<String> categoryTagIds = new List<String>();
        for(Tag_Offering__c tagProductVar : tagProducts) {

            if(tagProductVar.Tag__r.Parent_Name__c!='Country') {
                tagIds.add(tagProductVar.Tag__c);
            }
            if(tagProductVar.Tag__r.Parent_Name__c =='Category') {
                categoryTagIds.add(tagProductVar.Tag__c);
            }
        }
        List<Tag_Offering__c> tagProductsForCountry = new List<Tag_Offering__c>();
        Map<Id, List<Tag_Offering__c>> mapProductIdTagProducts = new Map<Id, List<Tag_Offering__c>>();
        for(Tag_Offering__c tagProduct : tagProducts) {
            if(!mapProductIdTagProducts.containsKey(tagProduct.Offering__c)) {
                mapProductIdTagProducts.put(tagProduct.Offering__c, new List<Tag_Offering__c>{tagProduct});
            } else {
                List<Tag_Offering__c> tagProductsLst = mapProductIdTagProducts.get(tagProduct.Offering__c);
                tagProductsLst.add(tagProduct);
                mapProductIdTagProducts.put(tagProduct.Offering__c, tagProductsLst);
            }
        }

        for(String productId: mapProductIdTagProducts.KeySet()) {
            List<Tag_Offering__c> tagProductsTemp = mapProductIdTagProducts.get(productId);
            if(tagProductsTemp.size() >= 1 ) {
                Boolean countryProductExists = FALSE;
                Boolean tagProductExists = FALSE;
                Integer categoryIndex = 0;
                for(Integer row=0; row < tagProductsTemp.size(); row++) {
                    if(tagProductsTemp[row].Tag__r.Name == MallDataServiceHandler.userCountry) {
                        countryProductExists = TRUE;
                    }
                    if(tagIds.contains(tagProductsTemp[row].Tag__c) && categoryTagIds.contains(tagProductsTemp[row].Tag__c)) {
                        tagProductExists = TRUE;
                        categoryIndex = row;
                    }
                }
                if(countryProductExists && tagProductExists) {
                    tagProductsForCountry.add(tagProductsTemp[categoryIndex]);
                }
            } 
        }

        return tagProductsForCountry;
    }  

    /**
     * @description preapres the provider for language by adding content based on language from CUT
     * @param tagProviders List<Tag_Provider__c>
     * @return List of Provider__c
    */    
    public Map<String,Map<Id,Content_Unit_Translation__c>> prepareShopsForLanguage(List<Tag_Provider__c> tagProviders) {

        Set<String> providerIdsSet = new Set<String>();
        List<String> providerIdslst = new List<String>();
        set<String> iconContentUnitIdsSet = new Set<String>();
        List<String> iconContentUnitIdslst = new List<String>();

        for(Tag_Provider__c tagProvider : tagProviders) {
            if(String.isNotBlank(tagProvider.Provider__c)) {
                providerIdsSet.add(tagProvider.Provider__c);
            }
            if(String.isNotBlank(tagProvider.Provider__r.Icon__c)) {
                iconContentUnitIdsSet.add(tagProvider.Provider__r.Icon__c);
            }
        }
        providerIdslst.addAll(providerIdsSet);
        iconContentUnitIdslst.addAll(iconContentUnitIdsSet);

        List<String> userLanguages = getUserLanguages();
        

        Map<Id, Content_Unit_Translation__c> mapProviderIdAndContentTranslation = new Map<Id, Content_Unit_Translation__c>();
        List<Content_Unit_Translation__c> contentTranslationUnits = new List<Content_Unit_Translation__c>();


        List<Content_Unit_Translation__c> iconContentTranslationUnits = new List<Content_Unit_Translation__c>();
        Map<Id, Content_Unit_Translation__c> mapContentIdAndContentTranslation = new Map<Id, Content_Unit_Translation__c>();

        String whereClause = ' ( Provider__c IN (\'' + String.join(providerIdslst, '\',\'') + '\')';
        whereClause += ' OR ( Content_Unit__c IN (\'' + String.join(iconContentUnitIdslst, '\',\'') + '\')' + ' AND Content_Unit__r.hasImage__c = TRUE )) ';
        whereClause += ' AND Language_ISO__c IN (\'' + String.join(userLanguages, '\',\'') + '\')';


        List<Content_Unit_Translation__c> contentUnitTranslationsForTags = getContentUnitTranslations(whereClause);
        for(Content_Unit_Translation__c cut : contentUnitTranslationsForTags) {
            if(String.isNotBlank(cut.Provider__c) && providerIdslst.contains(cut.Provider__c)) {
                contentTranslationUnits.add(cut);
            }
            if(String.isNotBlank(cut.Content_Unit__c) && iconContentUnitIdslst.contains(cut.Content_Unit__c)) {
                iconContentTranslationUnits.add(cut);
            }
        }


        for(Content_Unit_Translation__c contentTranslationUnit: contentTranslationUnits) {
            if(mapProviderIdAndContentTranslation.containsKey(contentTranslationUnit.Provider__c)) {
                if( mapProviderIdAndContentTranslation.get(contentTranslationUnit.Provider__c).Language_ISO__c == MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO
                        && (contentTranslationUnit.Language_ISO__c != MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO)) {
                            mapProviderIdAndContentTranslation.put(contentTranslationUnit.Provider__c, contentTranslationUnit);  
                            MallDataServiceHandler.mallMultiLanguageContent = true;
                }
            } else {
                mapProviderIdAndContentTranslation.put(contentTranslationUnit.Provider__c, contentTranslationUnit);  
            }      
        }


        for(Content_Unit_Translation__c iconContentTranslationUnit: iconContentTranslationUnits ) {
            if(mapContentIdAndContentTranslation.containsKey(iconContentTranslationUnit.Content_Unit__c)) {
                if( mapContentIdAndContentTranslation.get(iconContentTranslationUnit.Content_Unit__c).Language_ISO__c == MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO
                        && (iconContentTranslationUnit.Language_ISO__c != MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO)) {
                            mapContentIdAndContentTranslation.put(iconContentTranslationUnit.Content_Unit__c, iconContentTranslationUnit );
                 }
            } else {
                mapContentIdAndContentTranslation.put(iconContentTranslationUnit.Content_Unit__c, iconContentTranslationUnit );
            }   
        }

        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new Map<String,Map<Id,Content_Unit_Translation__c>>();
        mapContentTypMapContentUnitTranslation.put(MallDataServiceHandler.ICON_CONTENT_UNIT_TRANSLATION,mapContentIdAndContentTranslation);
        mapContentTypMapContentUnitTranslation.put(MallDataServiceHandler.CONTENT_UNIT_TRANSLATION,mapProviderIdAndContentTranslation);

        return mapContentTypMapContentUnitTranslation;
    }

    /**
     * @description this method prepares the providers for the country of the user 
     * @param tagProviders List<Tag_Provider__c> 
     * @return List of Tag_Provider__c
    */    
    public List<Tag_Provider__c> prepareShopsForCountry(List<Tag_Provider__c> tagProviders) {
        List<String> tagIds = new List<String>();
        List<String> categoryTagIds = new List<String>();
        for(Tag_Provider__c tagProviderVar : tagProviders) {

            if(tagProviderVar.Tag__r.Parent_Name__c!='Country') {
                tagIds.add(tagProviderVar.Tag__c);
            }
            if(tagProviderVar.Tag__r.Parent_Name__c=='Category') {
                categoryTagIds.add(tagProviderVar.Tag__c);
            }
        }
        
        List<Tag_Provider__c> tagProvidersForCountry = new List<Tag_Provider__c>();
        Map<Id, List<Tag_Provider__c>> mapProviderIdTagProviders = new Map<Id, List<Tag_Provider__c>>();
        for(Tag_Provider__c tagProvider : tagProviders) {
            if(!mapProviderIdTagProviders.containsKey(tagProvider.Provider__c)) {
                mapProviderIdTagProviders.put(tagProvider.Provider__c, new List<Tag_Provider__c>{tagProvider});
            } else {
                List<Tag_Provider__c> tagProvidersLst = mapProviderIdTagProviders.get(tagProvider.Provider__c);
                tagProvidersLst.add(tagProvider);
                mapProviderIdTagProviders.put(tagProvider.Provider__c, tagProvidersLst);
            }
        }
        for(String providerId: mapProviderIdTagProviders.KeySet()) {
            List<Tag_Provider__c> tagProvidersTemp = mapProviderIdTagProviders.get(providerId);
            if(tagProvidersTemp.size() > 1 ) {
                Boolean countryProviderExists = FALSE;
                Boolean tagProviderExists = FALSE;
                Integer categoryIndex= 0;

                for(Integer row=0;  row < tagProvidersTemp.size() ; row++) {
                    if(tagProvidersTemp[row].Tag__r.Name == MallDataServiceHandler.userCountry) {
                        countryProviderExists = TRUE;
                    }
                    if(tagIds.contains(tagProvidersTemp[row].Tag__c) && categoryTagIds.contains(tagProvidersTemp[row].Tag__c)) {
                        tagProviderExists = TRUE;
                        categoryIndex = row;
                    }
                }
                if(countryProviderExists && tagProviderExists) {
                    tagProvidersForCountry.add(tagProvidersTemp[categoryIndex]);
                }
            }
        }

        return tagProvidersForCountry;
    }

    /**
     * @description This Method denormalizes the Providers Data for Front End Based on Tag Provider Records 
     * @param tagProviders List<Tag_Provider__c>
     * @param mapContentIdAndContentTranslation Map<Id, Content_Unit_Translation__c>
     * @param mapProviderIdAndContentTranslation Map<Id, Content_Unit_Translation__c>
     * @return List of DenormalizedShop
    */   
    public List<DenormalizedShop> denormalizeShop(List<Tag_Provider__c> tagProviders,
                                                            Map<Id, Content_Unit_Translation__c> mapContentIdAndContentTranslation,
                                                            Map<Id, Content_Unit_Translation__c> mapProviderIdAndContentTranslation) {
        
        List<DenormalizedShop> denormalizedProviders = new List<DenormalizedShop>();
        for(Tag_Provider__c tagProvider: tagProviders) {
            DenormalizedShop provider = new DenormalizedShop();
            provider.tagId= tagProvider.Tag__c;
            provider.tagName = tagProvider.Tag__r.Name;
            provider.id = tagProvider.Provider__c;
            provider.name = tagProvider.Provider__r.Name;
            provider.parentTagId=tagProvider.Tag__r.Parent__c;
            provider.createdDate = tagProvider.Provider__r.CreatedDate;
            provider.shopLink = '/mall/s/tag/' + tagProvider.Provider__c;
            if(String.isNotBlank(tagProvider.Provider__r.Publishing_Unit__c)) {
                provider.isPublished = tagProvider.Provider__r.Publishing_Unit__r.isPublished__c;
                provider.publishedFrom = tagProvider.Provider__r.Publishing_Unit__r.published_From__c;
                provider.publishedUntil = tagProvider.Provider__r.Publishing_Unit__r.published_Until__c;
                provider.isNew=(tagProvider.Provider__r.Publishing_Unit__r.published_From__c) > System.today().addDays(-5)?true:false;
            }
            provider.isOnline = (tagProvider.Provider__r.Publishing_Unit__r.published_Until__c > tagProvider.Provider__r.Publishing_Unit__r.Published_From__c) ? TRUE : FALSE;


            if(mapContentIdAndContentTranslation.containsKey(tagProvider.Provider__r.Icon__c)) {
                provider.iconUrl = mapContentIdAndContentTranslation.get(tagProvider.Provider__r.Icon__c).Image_Url__c;
            }

                  if(tagProvider.Provider__r.Link__c != NULL) {
                provider.guestUrl = tagProvider.Provider__r.Link__r.Guest_url__c;
                provider.desktopUrl = tagProvider.Provider__r.Link__r.Desktop_url__c;
                provider.mobileUrl = tagProvider.Provider__r.Link__r.Mobile_url__c;
            }

      
            Content_Unit_Translation__c contentUnitTranslationRec = new Content_Unit_Translation__c();
            if( mapProviderIdAndContentTranslation.containskey(tagProvider.Provider__c)) {
                contentUnitTranslationRec = mapProviderIdAndContentTranslation.get(tagProvider.Provider__c);
            }
            if( String.isNotBlank(contentUnitTranslationRec.Title__c)) {
                provider.title = contentUnitTranslationRec.Title__c;
            }
            if( String.isNotBlank(contentUnitTranslationRec.Text__c)) {
                provider.text = contentUnitTranslationRec.Text__c;
            }
            if( String.isNotBlank(contentUnitTranslationRec.RichText__c)) {
                provider.description = contentUnitTranslationRec.RichText__c;
            }
            if( String.isNotBlank(contentUnitTranslationRec.Image_Url__c)) {
                provider.imageUrl = contentUnitTranslationRec.Image_Url__c;
            }
            denormalizedProviders.add(provider);
        }
        return denormalizedProviders;
    }

    /**
     * @description this returns the links in denormalized format 
     * @param links List<Link__c>
     * @return List of DenormalizedLink
    */  
    public List<DenormalizedLink> denormalizeLink(List<Link__c> links) {
        List<DenormalizedLink> denormalizedLinks = new List<DenormalizedLink>();
        for(Link__c link: links) {
            DenormalizedLink denormalizedLink = new DenormalizedLink();
            denormalizedLink.id = link.Id;
            denormalizedLink.name = link.Name;
            denormalizedLink.guestUrl = link.Guest_url__c;
            denormalizedLink.desktopUrl = link.Desktop_url__c;
            denormalizedLink.mobileUrl = link.Mobile_Url__c;
            denormalizedLink.isPublished = link.Publishing_Unit__r.isPublished__c;
            denormalizedLink.publishedFrom = link.Publishing_Unit__r.Published_From__c;
            denormalizedLink.publishedUntil = link.Publishing_Unit__r.Published_Until__c;
            denormalizedLink.isOnline = (denormalizedLink.publishedUntil > denormalizedLink.publishedFrom) ? TRUE : FALSE;
            denormalizedLinks.add(denormalizedLink);
        }
        return denormalizedLinks;
    }

     /**
     * @description Denormalizes the links into DenormalizedProduct.
     * @param tagLinks List of Tag Links.
     * @param contentUnitTranslations Map of content unit translations.
     * @return List of DenormalizedProduct.
     */
    public List<DenormalizedLink> denormalizeLinks(List<Tag_Link__c> tagLinks) {
        List<DenormalizedLink> linksDenormalized = new List<DenormalizedLink>();
        for(Tag_Link__c tagLink : tagLinks) {
            DenormalizedLink linkDenormalized = new DenormalizedLink();
            linkDenormalized.tagId = tagLink.Tag__c;
            linkDenormalized.tagName = tagLink.Tag__r.Name;
           
            linkDenormalized.tagLinkName = tagLink.Link__r.Name;

            
            linksDenormalized.add(linkDenormalized);
        }
        return linksDenormalized;
    }

/**
     * @description Prepares links for country.
     * @param tagLinks List of Tag Links.
     * @return List<Tag_Link__c> - List of prepared Tag Links.
     */
    public List<Tag_Link__c> prepareLinksForCountry(List<Tag_Link__c> tagLinks) {
        List<String> tagIds = new List<String>();
        List<String> categoryTagIds = new List<String>();
        for(Tag_Link__c tagLink : tagLinks) {
            if(tagLink.Tag__r.Parent__r.Name != 'Country') {
                tagIds.add(tagLink.Tag__c);
            }
            if(tagLink.Tag__r.Parent__r.Name == 'Category') {
                categoryTagIds.add(tagLink.Tag__c);
            }
        }

        List<Tag_Link__c> tagLinksForCountry = new List<Tag_Link__c>();
        Map<Id, List<Tag_Link__c>> mapProductIdTagLinks = new Map<Id, List<Tag_Link__c>>();
        for(Tag_Link__c tagLink : tagLinks) {
            if(!mapProductIdTagLinks.containsKey(tagLink.Link__c)) {
                mapProductIdTagLinks.put(tagLink.Link__c, new List<Tag_Link__c>{tagLink});
            } else {
                List<Tag_Link__c> tagLinksLst = mapProductIdTagLinks.get(tagLink.Link__c);
                tagLinksLst.add(tagLink);
                mapProductIdTagLinks.put(tagLink.Link__c, tagLinksLst);
            }
        }

        

        return tagLinksForCountry;
    }

    /**
     * @description Prepares links for language.
     * @param tagLinks List of Tag Links.
     * @return Map<String, Map<Id, Content_Unit_Translation__c>> - Map of content type to content unit translations.
     */
    public Map<String, Map<Id, Content_Unit_Translation__c>> prepareLinksForLanguage(List<Tag_Link__c> tagLinks) {
        Set<String> linkIds = new Set<String>();
        List<String> linkIdsLst = new List<String>();
        List<String> userLanguages = getUserLanguages();

        for(Tag_Link__c tagLink : tagLinks) {
            linkIds.add(tagLink.Link__c);
        }
        linkIdsLst.addAll(linkIds);

        List<Content_Unit_Translation__c> contentTranslationUnits = new List<Content_Unit_Translation__c>();
        Map<Id, Content_Unit_Translation__c> mapLinkIdAndContentTranslation = new Map<Id, Content_Unit_Translation__c>();
        String whereClause = 'Link__c IN (\'' + String.join(linkIdsLst, '\',\'') + '\')';
        whereClause += ' AND Language_ISO__c IN (\'' + String.join(userLanguages, '\',\'') + '\')';

        contentTranslationUnits = getContentUnitTranslations(whereClause);

        for(Content_Unit_Translation__c contentTranslationUnit : contentTranslationUnits) {
            if(mapLinkIdAndContentTranslation.containsKey(contentTranslationUnit.Link__c)) {
                if(mapLinkIdAndContentTranslation.get(contentTranslationUnit.Link__c).Language_ISO__c == MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO
                    && contentTranslationUnit.Language_ISO__c != MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO) {
                    mapLinkIdAndContentTranslation.put(contentTranslationUnit.Link__c, contentTranslationUnit);
                    MallDataServiceHandler.mallMultiLanguageContent = true;
                }
            } else {
                mapLinkIdAndContentTranslation.put(contentTranslationUnit.Link__c, contentTranslationUnit);
            }
        }

        Map<String, Map<Id, Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new Map<String, Map<Id, Content_Unit_Translation__c>>();
        mapContentTypMapContentUnitTranslation.put(MallDataServiceHandler.CONTENT_UNIT_TRANSLATION, mapLinkIdAndContentTranslation);

        return mapContentTypMapContentUnitTranslation;
    }













    /**
     * @description this method prepares the tags for the user selected language
     * @param tags List<Tag__c>
     * @return 
    */  
    public Map<String,Map<Id,Content_Unit_Translation__c>> prepareTagsForLanguage (List<Tag__c> tags) {
        List<String> userLanguages = getUserLanguages();
        Set<String> iconContentUntiIds = new Set<String>();
        List<String> iconContentUntiIdsLst = new List<String>();
        Set<String> tagIds = new Set<String>();
        List<String> tagIdsLst = new List<String>();


        for(Tag__c tag: tags ) {
            tagIds.add(tag.Id);
            if(String.isNotBlank(tag.Tag_Icon__c)) {
                iconContentUntiIds.add(tag.Tag_Icon__c);
            }
        }
        iconContentUntiIdsLst.addAll(iconContentUntiIds);
        tagIdsLst.addAll(tagIds);

        List<Content_Unit_Translation__c> iconContentTranslationUnits = new List<Content_Unit_Translation__c>();
        Map<Id, Content_Unit_Translation__c> mapContentIdAndContentTranslation = new Map<Id, Content_Unit_Translation__c>();
        
        List<Content_Unit_Translation__c> contentTranslationUnits = new List<Content_Unit_Translation__c>();
        Map<Id, Content_Unit_Translation__c> mapTagIdAndContentTranslation = new Map<Id, Content_Unit_Translation__c>();
        
        String whereClause = ' ( Tag__c IN (\'' + String.join(tagIdsLst, '\',\'') + '\')';
        whereClause += ' OR ( Content_Unit__c IN (\'' + String.join(iconContentUntiIdsLst, '\',\'') + '\')' + ' AND Content_Unit__r.hasImage__c = TRUE )) ';
        whereClause += ' AND Language_ISO__c IN (\'' + String.join(userLanguages, '\',\'') + '\')';

        List<Content_Unit_Translation__c> contentUnitTranslationsForTags = getContentUnitTranslations(whereClause);
        for(Content_Unit_Translation__c cut : contentUnitTranslationsForTags) {
            if(String.isNotBlank(cut.Tag__c) && tagIdsLst.contains(cut.Tag__c)) {
                contentTranslationUnits.add(cut);
            }
            if(String.isNotBlank(cut.Content_Unit__c) && iconContentUntiIdsLst.contains(cut.Content_Unit__c)) {
                iconContentTranslationUnits.add(cut);
            }
        }

        for(Content_Unit_Translation__c iconContentTranslationUnit: iconContentTranslationUnits) {
            if(mapContentIdAndContentTranslation.containsKey(iconContentTranslationUnit.Content_Unit__c)) {
                if( mapContentIdAndContentTranslation.get(iconContentTranslationUnit.Content_Unit__c).Language_ISO__c == MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO
                        && (iconContentTranslationUnit.Language_ISO__c != MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO)) {
                            mapContentIdAndContentTranslation.put(iconContentTranslationUnit.Content_Unit__c, iconContentTranslationUnit);  
                 }
            } else {
                mapContentIdAndContentTranslation.put(iconContentTranslationUnit.Content_Unit__c, iconContentTranslationUnit);  
            }      
        }
        for(Content_Unit_Translation__c contentTranslationUnit: contentTranslationUnits) {

            if(mapTagIdAndContentTranslation.containsKey(contentTranslationUnit.Tag__c)) {
            if( mapTagIdAndContentTranslation.get(contentTranslationUnit.Tag__c).Language_ISO__c == MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO
                    && (contentTranslationUnit.Language_ISO__c != MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO)) {
                        mapTagIdAndContentTranslation.put(contentTranslationUnit.Tag__c, contentTranslationUnit);  
             }
        } else {
            mapTagIdAndContentTranslation.put(contentTranslationUnit.Tag__c, contentTranslationUnit);  
             }      
        }

        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new Map<String,Map<Id,Content_Unit_Translation__c>>();
        mapContentTypMapContentUnitTranslation.put(MallDataServiceHandler.ICON_CONTENT_UNIT_TRANSLATION,mapContentIdAndContentTranslation);
        mapContentTypMapContentUnitTranslation.put(MallDataServiceHandler.CONTENT_UNIT_TRANSLATION,mapTagIdAndContentTranslation);


        return mapContentTypMapContentUnitTranslation;
    }

    /**
     * @description this method denormalizes tags with information from tag Icon and translated content
     *
     * @param tags List<Tag__c>
     * @param mapContentIdAndContentTranslation Map<Id, Content_Unit_Translation__c>
     * @param mapTagIdAndContentTranslation Map<Id, Content_Unit_Translation__c>
     * @return List of DenormalizedTag
    */      
    public List<DenormalizedTag> denormalizeTags (List<Tag__c> tags, 
                        Map<Id, Content_Unit_Translation__c> mapContentIdAndContentTranslation,
                        Map<Id, Content_Unit_Translation__c> mapTagIdAndContentTranslation) {
        List<DenormalizedTag> denormalizedTags = new List<DenormalizedTag>();
        
        
        for(Tag__c tag: tags ) {
            DenormalizedTag denormalizedTag = new DenormalizedTag();
            denormalizedTag.id = tag.id;
            denormalizedTag.name = tag.name;
            denormalizedTag.isRootTag = tag.IsRoot_Tag__c;
            denormalizedTag.parentId = tag.Parent__c;
            denormalizedTag.parentName = tag.Parent__r.Name;
            denormalizedTag.isPublished = tag.Publishing_Unit__r.isPublished__c;
            denormalizedTag.publishedFrom = tag.Publishing_Unit__r.Published_From__c;
            denormalizedTag.publishedUntil = tag.Publishing_Unit__r.published_Until__c;
            denormalizedTag.isOnline = (tag.Publishing_Unit__r.published_Until__c > tag.Publishing_Unit__r.Published_From__c) ? TRUE : FALSE;
            denormalizedTag.position = (Integer)tag.Position__c;
            
            if(mapContentIdAndContentTranslation != null && mapContentIdAndContentTranslation.containsKey(tag.Tag_Icon__c)) {
                denormalizedTag.iconUrl = mapContentIdAndContentTranslation.get(tag.Tag_Icon__c).Image_Url__c;
            }

            Content_Unit_Translation__c contentUnitTranslationRec = new Content_Unit_Translation__c();
            if( mapTagIdAndContentTranslation != null && mapTagIdAndContentTranslation.containskey(denormalizedTag.id)) {
                contentUnitTranslationRec = mapTagIdAndContentTranslation.get(denormalizedTag.id);
            }
            if(String.isNotBlank(contentUnitTranslationRec.Title__c)) {
                denormalizedTag.title = contentUnitTranslationRec.Title__c;
            }
            if(String.isNotBlank(contentUnitTranslationRec.Text__c)) {
                denormalizedTag.text = contentUnitTranslationRec.Text__c;
            }
            if(String.isNotBlank(contentUnitTranslationRec.RichText__c)) {
                denormalizedTag.description = contentUnitTranslationRec.RichText__c;
            }
            if(String.isNotBlank(contentUnitTranslationRec.Image_Url__c)) {
                denormalizedTag.imageUrl = contentUnitTranslationRec.Image_Url__c;
            }
            denormalizedTags.add(denormalizedTag);
        }
        return denormalizedTags;
    }

    /**
     * @description This method returns the languages the user content should be served based on preferences
     * @return List of String for language
     */
    public List<String> getUserLanguages() {
        List<String> userLanguages = new List<String>();

        userLanguages.add(MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO);


        if(string.isNotBlank(MallDataServiceHandler.userContentLanguage) && (MallDataServiceHandler.userContentLanguage != MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO)) {
            userLanguages.add(MallDataServiceHandler.userContentLanguage);
        }
        return userLanguages;
    }

    /**
     * @description getContentUnitTranslations
     * @param whereClause String     
     * @return List<Content_Unit_Translation__c>
    */   
    public List<Content_Unit_Translation__c> getContentUnitTranslations(String whereClause) {
        return SEL_ContentUnitTranslations.newInstance().selectByCustomFilterCondition(whereClause);
    }
}