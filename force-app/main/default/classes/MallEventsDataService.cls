/**
 * @description MallEventsDataService
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallEventsDataService {

    /**
     * 
     * @description This method queries the Tag/Event by Country
     * @param countries List of Country Names
     * @return  List DenormalizedEvent
     */
    public List<DenormalizedEvent> getEventsByCountryNames(List<String> countries) {
        Set<String> countriesSet = new Set<String>();
        countriesSet.addAll(countries);
        List<Tag_Business_Event__c> tagEvents = SEL_MALL_TagEvents.newInstance().selectByTagNames(countriesSet);        
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallEventsDataServiceHelper().prepareEventsForLanguage(tagEvents);   
        return new MallEventsDataServiceHelper().denormalizeEvents(tagEvents, mapContentTypMapContentUnitTranslation.get(MallDataServiceHandler.CONTENT_UNIT_TRANSLATION));
    } 

    /**
     * 
     * @description getEventsBySegmentAndCategoryIds
     * @param segmentIds List of String Ids
     * @param categoryIds  List of String Ids
     * @return  List of DenormalizedEvent
     */
    public List<DenormalizedEvent> getEventsBySegmentAndCategoryIds(List<String> segmentIds, List<String> categoryIds) {
        List<String> allTagIds = new List<String>();
        allTagIds.addAll(segmentIds);
        allTagIds.addAll(categoryIds);
        Set<Id> allTagIdsSet = new Set<Id>();
        allTagIdsSet.addAll((List<Id>)allTagIds);
        List<Tag_Business_Event__c> tagEvents = SEL_MALL_TagEvents.newInstance().selectByTagIds(allTagIdsSet);

        Map<String, List<Tag_Business_Event__c>> mapEventIdTagEvents =  new Map<String, List<Tag_Business_Event__c>>();
        List<Tag_Business_Event__c> tagEventsConsolidated = new List<Tag_Business_Event__c>();
        List<String> eventIds = new List<String>();


        for(Tag_Business_Event__c tagEvent : tagEvents) {
            if(!mapEventIdTagEvents.containsKey(tagEvent.Business_Event__c)) {
                mapEventIdTagEvents.put(tagEvent.Business_Event__c, new List<Tag_Business_Event__c>{tagEvent});
            } else {
                List<Tag_Business_Event__c> tagEventsTemp = mapEventIdTagEvents.get(tagEvent.Business_Event__c);
                tagEventsTemp.add(tagEvent);
                mapEventIdTagEvents.put(tagEvent.Business_Event__c, tagEventsTemp);
            }
        }

        for(String eventId : mapEventIdTagEvents.KeySet()) {
            List<Tag_Business_Event__c> tEvents = mapEventIdTagEvents.get(eventId);
            Boolean segmentEventExists = FALSE;
            Boolean categoryEventExists = FALSE;
            Integer categoryIndex = 0;
            for(Integer row=0;  row < tEvents.size() ; row++) {
                if(tEvents[row].Tag__r.Root_Name__c == 'Segment') {
                    segmentEventExists = TRUE;
                }
                if(tEvents[row].Tag__r.Root_Name__c == 'Category') {
                    categoryEventExists = TRUE;
                    categoryIndex = row;
                }
            }
            if(segmentEventExists && categoryEventExists) {
                tagEventsConsolidated.add(tEvents[categoryIndex]);
                eventIds.add(tEvents[categoryIndex].Business_Event__c);
            }
        }

        String whereClause = ' Business_Event__c IN (\'' + String.join(eventIds, '\',\'') + '\')';
        whereClause += ' AND Tag__r.Name =' + '\''+ MallDataServiceHandler.userCountry + '\'';
        List<Tag_Business_Event__c> tagEventsForCountry = SEL_MALL_TagEvents.newInstance().selectByCustomFilterCondition(whereClause);
        //consolidate all tag shops
        tagEventsConsolidated.addAll(tagEventsForCountry);
        return prepareEventsForCountryAndLanguage(tagEventsConsolidated);
    }

    /**
     * 
     * @description This method prepares the Events for country and language
     * @param tagEvents List of Tag Events
     * @return  List of DenormalizedEvent
     */
    public List<DenormalizedEvent> prepareEventsForCountryAndLanguage(List<Tag_Business_Event__c> tagEvents) {
        //De-duplicate the Products since there will be tagproduct for country as well as tag itself
        tagEvents = new MallEventsDataServiceHelper().prepareEventsForCountry(tagEvents);
        //get the content translation based on user language
        Map<String,Map<Id,Content_Unit_Translation__c>> mapContentTypMapContentUnitTranslation = new MallEventsDataServiceHelper().prepareEventsForLanguage(tagEvents);
        
        return new MallEventsDataServiceHelper().denormalizeEvents(tagEvents, mapContentTypMapContentUnitTranslation.get(MallDataServiceHandler.CONTENT_UNIT_TRANSLATION));
    } 
}