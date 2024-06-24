/**
 * @description MallEventsDataServiceHelper
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallEventsDataServiceHelper {

    /**
	 * @description This method prepares the events for the country
     * @param tagEvents List of Tag_Business_Event__c
	 * @return List of Tag_Business_Event__c  
	*/
    public List<Tag_Business_Event__c> prepareEventsForCountry(List<Tag_Business_Event__c> tagEvents) {
        List<String> tagIds = new List<String>();
        List<String> categoryTagIds = new List<String>();
        for(Tag_Business_Event__c tagEventVar : tagEvents) {
            //List of TagIds from which should not be including country tags
            if(tagEventVar.Tag__r.Parent_Name__c!='Country') {
                tagIds.add(tagEventVar.Tag__c);
            }
            if(tagEventVar.Tag__r.Parent_Name__c =='Category') {
                categoryTagIds.add(tagEventVar.Tag__c);
            }
        }
        List<Tag_Business_Event__c> tagEventsForCountry = new List<Tag_Business_Event__c>();
        Map<Id, List<Tag_Business_Event__c>> mapEventIdTagEvents = new Map<Id, List<Tag_Business_Event__c>>();
        for(Tag_Business_Event__c tagEvent : tagEvents) {
            if(!mapEventIdTagEvents.containsKey(tagEvent.Business_Event__c)) {
                mapEventIdTagEvents.put(tagEvent.Business_Event__c, new List<Tag_Business_Event__c>{tagEvent});
            } else {
                List<Tag_Business_Event__c> tagEventsLst = mapEventIdTagEvents.get(tagEvent.Business_Event__c);
                tagEventsLst.add(tagEvent);
                mapEventIdTagEvents.put(tagEvent.Business_Event__c, tagEventsLst);
            }
        }

        for(String eventId: mapEventIdTagEvents.KeySet()) {
            List<Tag_Business_Event__c> tagEventsTemp = mapEventIdTagEvents.get(eventId);
            if(tagEventsTemp.size() >= 1 ) {
                Boolean countryEventExists = FALSE;
                Boolean tagEventExists = FALSE;
                Integer categoryIndex = 0;
                for(Integer row=0; row < tagEventsTemp.size(); row++) {
                    if(tagEventsTemp[row].Tag__r.Name == MallDataServiceHandler.userCountry) {
                        countryEventExists = TRUE;
                    }
                    if(tagIds.contains(tagEventsTemp[row].Tag__c) && categoryTagIds.contains(tagEventsTemp[row].Tag__c)) {
                        tagEventExists = TRUE;
                        categoryIndex = row;
                    }
                }
                if(countryEventExists && tagEventExists) {
                    tagEventsForCountry.add(tagEventsTemp[categoryIndex]);
                }
            } 
        }

        return tagEventsForCountry;
    }  

    /**
	 * @description This method returns the content unit translation for Events for the user selected languages 
     * @param tagEvents List<Tag_Business_Event__c>
     * @return Map<String,Map<Id,ContentTranslation>>
	*/
    public Map<String,Map<Id,Content_Unit_Translation__c>> prepareEventsForLanguage(List<Tag_Business_Event__c> tagEvents) {
        Set<String> eventIds = new Set<String>();
        List<String> eventIdsLst = new List<String>();
        List<String> userLanguages = getUserLanguages();

        for(Tag_Business_Event__c tagEvent : tagEvents) {
            eventIds.add(tagEvent.Business_Event__c);
        } 
        eventIdsLst.addAll(eventIds);

        List<Content_Unit_Translation__c> contentTranslationUnits = new List<Content_Unit_Translation__c>();
        Map<Id,Content_Unit_Translation__c> mapEventIdAndContentTranslation = new Map<Id,Content_Unit_Translation__c>();
        String whereClause = 'Business_Event__c IN (\'' + String.join(eventIdsLst, '\',\'') + '\')';
        whereClause += ' AND Language_ISO__c IN (\'' + String.join(userLanguages, '\',\'') + '\')';


        contentTranslationUnits = new MallDataServiceHelper().getContentUnitTranslations(whereClause);

        for(Content_Unit_Translation__c contentTranslationUnit: contentTranslationUnits) {
        //Check if default and userSelected Translations both exist then use UserLanguage
        if(mapEventIdAndContentTranslation.containsKey(contentTranslationUnit.Business_Event__c)) {
            if( mapEventIdAndContentTranslation.get(contentTranslationUnit.Business_Event__c).Language_ISO__c == MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO
                    && (contentTranslationUnit.Language_ISO__c != MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO)) {
                mapEventIdAndContentTranslation.put(contentTranslationUnit.Business_Event__c, contentTranslationUnit);  
                MallDataServiceHandler.mallMultiLanguageContent = true;
             }
        } else {
            mapEventIdAndContentTranslation.put(contentTranslationUnit.Business_Event__c, contentTranslationUnit);  
             }      
        }

        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new Map<String,Map<Id,Content_Unit_Translation__c>>();
        mapContentTypMapContentUnitTranslation.put(MallDataServiceHandler.ICON_CONTENT_UNIT_TRANSLATION,null);
        mapContentTypMapContentUnitTranslation.put(MallDataServiceHandler.CONTENT_UNIT_TRANSLATION,mapEventIdAndContentTranslation);

        return mapContentTypMapContentUnitTranslation;
    }

    /**
     * 
     * @description This method denormalizes the Event based on tagEvents and content and icon from CUT
     * @param tagEvents List<Tag_Business_Event__c>
     * @param mapEventIdAndContentTranslation Map<Id, ContentTranslation>
     * @return  List<DenormalizedEvent>
     */
    public List<DenormalizedEvent> denormalizeEvents(List<Tag_Business_Event__c> tagEvents, Map<Id, Content_Unit_Translation__c> mapEventIdAndContentTranslation) {
        List<DenormalizedEvent> eventsDenormalized = new List<DenormalizedEvent>();
        for(Tag_Business_Event__c tagEvent: tagEvents) {
            DenormalizedEvent eventDenormalized = new DenormalizedEvent();
            eventDenormalized.tagId=tagEvent.Tag__c;
            eventDenormalized.tagName=tagEvent.Tag__r.Name;
            eventDenormalized.id = tagEvent.Business_Event__r.id;
            eventDenormalized.name = tagEvent.Business_Event__r.Name;
            eventDenormalized.startDate = tagEvent.Business_Event__r.Start_Date__c;
            eventDenormalized.endDate = tagEvent.Business_Event__r.End_Date__c;
            eventDenormalized.createdDate = tagEvent.Business_Event__r.CreatedDate;
            eventDenormalized.isOnline = tagEvent.Business_Event__r.IsOnline__c;
            
            if(String.isNotBlank(tagEvent.Business_Event__r.Provider__c)) {
                eventDenormalized.shopId = tagEvent.Business_Event__r.Provider__c;
                eventDenormalized.shopName = tagEvent.Business_Event__r.Provider__r.Name;
            }

            if(String.isNotBlank(tagEvent.Business_Event__r.Offering__c)) {
                eventDenormalized.offeringId = tagEvent.Business_Event__r.Offering__c;
            }

            if(String.isNotBlank(tagEvent.Business_Event__r.Link__c)) {
                eventDenormalized.guestUrl = tagEvent.Business_Event__r.Link__r.Guest_url__c;
                eventDenormalized.desktopUrl = tagEvent.Business_Event__r.Link__r.Desktop_url__c;
                eventDenormalized.mobileUrl = tagEvent.Business_Event__r.Link__r.Mobile_url__c;
            }

            if(mapEventIdAndContentTranslation.containsKey(tagEvent.Business_Event__c)) {
                Content_Unit_Translation__c contentUnitTranslation = mapEventIdAndContentTranslation.get(tagEvent.Business_Event__c);
                if(String.isNotBlank(contentUnitTranslation.Title__c)) {
                    eventDenormalized.title = contentUnitTranslation.Title__c;
                }
                if(String.isNotBlank(contentUnitTranslation.Text__c)) {
                    eventDenormalized.text = contentUnitTranslation.Text__c;
                }
                if(String.isNotBlank(contentUnitTranslation.RichText__c)) {
                    eventDenormalized.description = contentUnitTranslation.RichText__c;
                }
                if(String.isNotBlank(contentUnitTranslation.Image_Url__c)) {
                    eventDenormalized.imageUrl = contentUnitTranslation.Image_Url__c;
                }
            }
            eventsDenormalized.add(eventDenormalized);
        }
        return eventsDenormalized;
    }

    /**
	 * @description This method returns the languages the user content should be served based on preferences
	 * @return List<String> : languages
	 */
    public List<String> getUserLanguages() {
        List<String> userLanguages = new List<String>();
        //ADD DEFAULT LANGUAGE
        userLanguages.add(MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO);

        //ADD User Language If it's not blank and not equal to default language
        if(string.isNotBlank(MallDataServiceHandler.userContentLanguage) && (MallDataServiceHandler.userContentLanguage != MallDataServiceHandler.DEFAULT_CONTENT_LANGUAGE_ISO)) {
            userLanguages.add(MallDataServiceHandler.userContentLanguage);
        }
        return userLanguages;
    }
}