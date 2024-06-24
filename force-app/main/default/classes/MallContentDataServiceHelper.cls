/**
 * 
 * @description Helper Class for MallContentDataService
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallContentDataServiceHelper {


    /**
	 * @description This method dedupes the Contents for the country coming from tagContent
     * @param tagContents List of Tag_Content__c
	 * @return List of Tag_Content__c  
	*/
    public List<Tag_Content__c> dedupeCountriesContents(List<Tag_Content__c> tagContents) {
       Map<String, Tag_Content__c> mapContentIdVsContentTag = new Map<String, Tag_Content__c>();
       for(Tag_Content__c tagContent: tagContents) {
            if(!mapContentIdVsContentTag.containsKey(tagContent.Content__c)) {
                mapContentIdVsContentTag.put(tagContent.Content__c, tagContent);
            }
       }
       return mapContentIdVsContentTag.values();
    } 

    /**
	 * @description This method returns the content unit translation for Contents for the user selected languages 
     * @param tagContents List<Tag_Content__c>
     * @return Map<String,Map<Id,ContentTranslation>>
	*/
    public Map<String,Map<Id,Content_Unit_Translation__c>> prepareContentsForLanguage(List<Tag_Content__c> tagContents) {
        Set<String> contentIds = new Set<String>();
        List<String> contentIdsLst = new List<String>();
        List<String> userLanguages = getUserLanguages();

        for(Tag_Content__c tagContent : tagContents) {
            contentIds.add(tagContent.Content__c);
        } 
        contentIdsLst.addAll(contentIds);

        List<Content_Unit_Translation__c> contentTranslationUnits = new List<Content_Unit_Translation__c>();
        Map<Id,Content_Unit_Translation__c> mapcontentIdAndContentTranslation = new Map<Id,Content_Unit_Translation__c>();
        String whereClause = 'Content__c IN (\'' + String.join(contentIdsLst, '\',\'') + '\')';
        whereClause += ' AND Language_ISO__c IN (\'' + String.join(userLanguages, '\',\'') + '\')';


        contentTranslationUnits = new MallDataServiceHelper().getContentUnitTranslations(whereClause);

        for(Content_Unit_Translation__c contentTranslationUnit: contentTranslationUnits) {     if(mapcontentIdAndContentTranslation.containsKey(contentTranslationUnit.Content__c)) {
            if( mapcontentIdAndContentTranslation.get(contentTranslationUnit.Content__c).Language_ISO__c == MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO  && (contentTranslationUnit.Language_ISO__c != MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO)) {   mapcontentIdAndContentTranslation.put(contentTranslationUnit.Content__c, contentTranslationUnit);  
                MallDataServiceHandler.mallMultiLanguageContent = true; } } else {      mapcontentIdAndContentTranslation.put(contentTranslationUnit.Content__c, contentTranslationUnit);    }      
        }

        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new Map<String,Map<Id,Content_Unit_Translation__c>>();
        mapContentTypMapContentUnitTranslation.put(MallDataServiceHandler.ICON_CONTENT_UNIT_TRANSLATION,null);
        mapContentTypMapContentUnitTranslation.put(MallDataServiceHandler.CONTENT_UNIT_TRANSLATION,mapcontentIdAndContentTranslation);

        return mapContentTypMapContentUnitTranslation;
    }

    /**
     * 
     * @description This method denormalizes the Content based on tagContents and content and icon from CUT
     * @param tagContents List<Tag_Content__c>
     * @param mapcontentIdAndContentTranslation Map<Id, ContentTranslation>
     * @return  List<DenormalizedContent>
     */
    public List<DenormalizedContent> denormalizeContents(List<Tag_Content__c> tagContents, Map<Id, Content_Unit_Translation__c> mapcontentIdAndContentTranslation) {
        List<DenormalizedContent> contentsDenormalized = new List<DenormalizedContent>();
        for(Tag_Content__c tagContent: tagContents) {
            DenormalizedContent contentDenormalized = new DenormalizedContent();
            contentDenormalized.id = tagContent.Content__r.id;
            contentDenormalized.duration = (Integer)tagContent.Content__r.Duration__c;
            contentDenormalized.order = (Integer)tagContent.Content__r.Order__c;
            contentDenormalized.section = tagContent.Content__r.Section__c;
            contentDenormalized.isOnline = tagContent.Content__r.IsOnline__c;
            contentDenormalized.createdDate = tagContent.Content__r.CreatedDate;
            contentDenormalized.publishedFrom = tagContent.Content__r.Publishing_Unit__r.Published_from__c;
            contentDenormalized.tagId=tagContent.Tag__c;
            contentDenormalized.tagName=tagContent.Tag__r.Name;

            if(String.isNotBlank(tagContent.Content__r.Link__c)) {
                contentDenormalized.guestUrl = tagContent.Content__r.Link__r.Guest_url__c;
                contentDenormalized.desktopUrl = tagContent.Content__r.Link__r.Desktop_url__c;
                contentDenormalized.mobileUrl = tagContent.Content__r.Link__r.Mobile_url__c;
            }

            contentDenormalized = addTranslatedContent(tagContent, contentDenormalized, mapcontentIdAndContentTranslation);
            contentsDenormalized.add(contentDenormalized);
        }
        return contentsDenormalized;
    }

    /**
     * 
     * @description addTranslatedContent
     * @param tagContent Tag_Content__c
     * @param contentDenormalized DenormalizedContent
     * @param mapcontentIdAndContentTranslation Map<Id, ContentTranslation>
     * @return  DenormalizedContent
     */
    public DenormalizedContent addTranslatedContent(Tag_Content__c tagContent, DenormalizedContent contentDenormalized, Map<Id, Content_Unit_Translation__c> mapcontentIdAndContentTranslation) {
        if(mapcontentIdAndContentTranslation.containsKey(tagContent.Content__c)) {Content_Unit_Translation__c contentUnitTranslation = mapcontentIdAndContentTranslation.get(tagContent.Content__c);
            if(String.isNotBlank(contentUnitTranslation.Title__c)) { contentDenormalized.title = contentUnitTranslation.Title__c; } if(String.isNotBlank(contentUnitTranslation.Text__c)) {  contentDenormalized.text = contentUnitTranslation.Text__c;   }
            if(String.isNotBlank(contentUnitTranslation.RichText__c)) { contentDenormalized.richText = contentUnitTranslation.RichText__c;  }  if(String.isNotBlank(contentUnitTranslation.Image_Url__c)) {  contentDenormalized.imageUrl = contentUnitTranslation.Image_Url__c; }
        }
        return contentDenormalized;
    }

    /**
	 * @description This method returns the languages the user content should be served based on preferences
	 * @return List<String> : languages
	 */
    public List<String> getUserLanguages() {
        List<String> userLanguages = new List<String>();
        userLanguages.add(MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO);

        if(string.isNotBlank(MallDataServiceHandler.userContentLanguage) && (MallDataServiceHandler.userContentLanguage != MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO)) {  userLanguages.add(MallDataServiceHandler.userContentLanguage);
        }
        return userLanguages;
    }
}