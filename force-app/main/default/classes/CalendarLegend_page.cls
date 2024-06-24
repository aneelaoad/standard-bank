/*************************************************************************
	@ Author 		: Caro Reinecke
	@ Date 		    : 23/11/2012
	@ Test File 	: CalendarLegend_pageTest
	@ Description	: N/A
	@
	@ Last Modified By	    :	Petr Svestka
	@ Last Modified On	    :	22/7/2015 
	@ Last Modified Reason	:	Force.com reviewer - Blocker and Critical issues - 20150608.xlsx
****************************************************************************/

global with sharing class CalendarLegend_page extends ComponentControllerBase {

    public String objectName{get;set;} {objectName = 'Account';} // e.g. 'Account' , 'Contact' , 'Opportunity'
    public String eventObjectName{get;set;} {eventObjectName = 'Event';}
    public String calendarType { get; set; } { calendarType = 'Client'; }

    private Map<String, String> calLegMap = new Map<String, String>();
    private String calContObjectType;
    private Id calContId;
    private List<String> pickListValues = new List<String>();

    public CalendarLegend_page () {
        List<Calendar_Content__c> calendarContent = [SELECT id
                                                           ,Event_Object_Name__c
                                                           ,Event_Legend_Field__c
                                                       FROM Calendar_Content__c
                                                      WHERE Calendar_Type__r.name = :calendarType
                                                        AND Event_Object_Name__c = :eventObjectName
                                                        AND Hierarchy_Object_Name__c = :objectName
                                                      LIMIT 1];

        calContObjectType = calendarContent[0].Event_Object_Name__c;
        calContId = calendarContent[0].Id;

        Map<String, Schema.sObjectType> mapToken_SObjects = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult legendObject = mapToken_SObjects.get(calContObjectType).getDescribe();

        Map<String, Schema.sObjectField> mapToken_Fields = legendObject.fields.getMap();

        Schema.DescribeFieldResult F = mapToken_Fields.get(calendarContent[0].Event_Legend_Field__c).getDescribe();
        for (Schema.PicklistEntry pe: F.getPicklistValues()) {
            pickListValues.add(pe.getLabel());
        }

        for(List<Calendar_Legend__c> calLegs: [SELECT name
                                                     ,Background_Color__c
                                                 FROM Calendar_Legend__c
                                                WHERE Calendar_Content__r.Calendar_Type__r.Name = :calendarType
                                                  AND name IN :pickListValues]) {
            for(Calendar_Legend__c calLeg: calLegs) {
                calLegMap.put(calLeg.name, calLeg.Background_Color__c);
            }
        }
    }

    public List<eventTypeClass> eventType {
        get {
            try {
                Set<String> dbEventTypes = new Set<String>();    //CR: Build list of all event types in DB to add to Legend

                eventType.clear();

                eventTypeClass eventTypeStyleClass = new eventTypeClass();
                eventTypeStyleClass.backgroundColor = 'Black'; //JN Changed to red to avoid conflict with defined colours
                eventTypeStyleClass.color = '#fff';
                eventTypeStyleClass.objectType = calContObjectType;
                eventTypeStyleClass.typeOfEvent = null;
                eventTypeStyleClass.noOfRecords = '';
                eventTypeStyleClass.backgroundColor = getBackgroundColor(eventTypeStyleClass.typeOfEvent);
                eventTypeStyleClass.className = ('fc-'+eventTypeStyleClass.typeOfEvent).replaceAll('\\s+','');
                eventType.add(eventTypeStyleClass);
                dbEventTypes.add(eventTypeStyleClass.typeOfEvent);

                for (String labelVal: pickListValues) {
                    eventTypeStyleClass = new eventTypeClass();
                    eventTypeStyleClass.backgroundColor = 'Black'; //JN Changed to red to avoid conflict with defined colours
                    eventTypeStyleClass.color = '#fff';
                    eventTypeStyleClass.objectType = calContObjectType;
                    eventTypeStyleClass.typeOfEvent = labelVal;
                    eventTypeStyleClass.noOfRecords = '';
                    eventTypeStyleClass.backgroundColor = getBackgroundColor(eventTypeStyleClass.typeOfEvent);
                    eventTypeStyleClass.className = ('fc-'+eventTypeStyleClass.typeOfEvent).replaceAll('\\s+','');
                    eventType.add(eventTypeStyleClass);
                    dbEventTypes.add(eventTypeStyleClass.typeOfEvent);
                }
                eventType.sort();

                for (List<Calendar_Legend__c> legendEventTypes : [SELECT Name
                                                                    FROM Calendar_Legend__c
                                                                   WHERE Calendar_Content__r.Calendar_Type__r.Name = :calendarType
                                                                     AND Calendar_Content__r.Event_Object_Name__c = :eventObjectName
                                                                     AND Calendar_Content__r.Hierarchy_Object_Name__c = :objectName]) {
                    for (Calendar_Legend__c legendEventType: legendEventTypes) {
                        if (dbEventTypes.Contains(legendEventType.Name)) {
                            dbEventTypes.remove(legendEventType.Name);
                        }
                    }
                }
                //  JN Create Calendar Legend Item for New Event Types Changes added for Multiple Calendar Types
                if (dbEventTypes.size() > 0) {
                    List<Calendar_Legend__c> newCalLegItems = new List<Calendar_Legend__c>();

                    for (String newLegendItem : dbEventTypes){
                        if (newLegendItem != null && newLegendItem != '') {
                            Calendar_Legend__c calLegNew = new Calendar_Legend__c();
                            calLegNew.Name = newLegendItem;
                            calLegNew.Calendar_Content__c = calContId;
                            calLegNew.Background_Color__c = 'Black';
                            newCalLegItems.add(calLegNew);
                        }
                    }
                    Database.insert(newCalLegItems);
                }
            } catch (Exception e) {
                   ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()+' thrown in: '+e.getStackTraceString()));
            }
            return eventType;
        }
        private set;
    } {
        eventType = new List<eventTypeClass>();
    }

    global class eventTypeClass implements Comparable {
        public Event e {get; set; }
        public string className {get; set; }
        public string backgroundColor { get; set; }
        public string color { get; set; }
        public string typeOfEvent { get; set; }
        public string noOfRecords {get; set;}
        public string objectType {get; set;}

        global Integer compareTo(Object compareTo) {
            eventTypeClass compareToEventTypeClass  = (eventTypeClass)compareTo;
            if (typeOfEvent == compareToEventTypeClass.typeOfEvent) return 0;
            if (typeOfEvent  > compareToEventTypeClass.typeOfEvent) return 1;
            return -1;
        }
    }

    private String getBackgroundColor(String legendItemName){
        if (!calLegMap.containsKey(legendItemName)) {
            return '#FF0000';
        }
        return calLegMap.get(legendItemName);
    }
}