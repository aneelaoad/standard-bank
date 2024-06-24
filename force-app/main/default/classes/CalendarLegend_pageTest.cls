/*************************************************************************
    @ Author        : Petr Svestka
    @ Date          : 21/7/2015
    @ Description   : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx
****************************************************************************/

@isTest
public with sharing class CalendarLegend_pageTest {

    @testSetup
    public static void setUp() {
        Calendar_Type__c testCalType = new Calendar_Type__c();
        testCalType.Name = 'Client';
        insert testCalType;

        List<Calendar_Content__c> calCons = new List<Calendar_Content__c>();

        Calendar_Content__c testCalContent1 = new Calendar_Content__c();
        testCalContent1.Name = 'Client Events';
        testCalContent1.Event_Start_Field__c = 'Start';
        testCalContent1.Event_Title_Field__c = 'Subject';
        testCalContent1.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent1.Event_Object_Name__c = 'Event';
        testCalContent1.Hierarchy_Object_Name__c = 'Account';
        testCalContent1.Hierarchy_Relation_Field__c = 'ParentId';
        testCalContent1.Calendar_Type__c = testCalType.Id;
        calCons.add(testCalContent1);

        insert calCons;

        List<Calendar_Legend__c> calLegs = new List<Calendar_Legend__c>();

        Calendar_Legend__c calLegend1 = new Calendar_Legend__c();
        calLegend1.Name = 'Day To Day Meeting';
        calLegend1.Background_Color__c = 'gray';
        calLegend1.Calendar_Content__c = testCalContent1.Id;
        calLegs.add(calLegend1);

        Calendar_Legend__c calLegend2 = new Calendar_Legend__c();
        calLegend2.Name = 'Core Client Team Meeting';
        calLegend2.Background_Color__c = 'green';
        calLegend2.Calendar_Content__c = testCalContent1.Id;
        calLegs.add(calLegend2);

        insert calLegs;
    }

    public static testMethod void test() {
        CalendarLegend_page cont = new CalendarLegend_page();

        // fetch pick-list values for Event.Meeting_Purpose__c
        Map<String, Schema.sObjectType> mapToken_SObjects = Schema.getGlobalDescribe();
        Map<String, Schema.sObjectField> mapToken_Fields = mapToken_SObjects.get('Event').getDescribe().fields.getMap();
        Schema.DescribeFieldResult F = mapToken_Fields.get('Meeting_Purpose__c').getDescribe();

        List<Schema.PicklistEntry> meetingTypeValues = F.getPicklistValues();

        // expected pairs
        Map<String, String> expectedColors = new Map<String, String>{
            null => '#FF0000'
        };
        for (Schema.PicklistEntry meetingType: meetingTypeValues) {
            if (meetingType.getLabel() != 'Day To Day Meeting' && meetingType.getLabel() != 'Core Client Team Meeting') {
                expectedColors.put(meetingType.getLabel(), '#FF0000');
            }
        }
        expectedColors.put('Day To Day Meeting', 'gray');
        expectedColors.put('Core Client Team Meeting', 'green');

        Test.startTest();

        List<CalendarLegend_page.eventTypeClass> eventTypes = cont.eventType;

        system.assertEquals(expectedColors.keySet().size(), eventTypes.size(), 'Unexpected number of background color items');

        for (CalendarLegend_page.eventTypeClass et: eventTypes) {
            system.assert(expectedColors.containsKey(et.typeOfEvent), 'Unexpected meeting type returned');
            system.assertEquals(expectedColors.get(et.typeOfEvent), et.backgroundColor, 'Unexpected background color returned for ' + et.typeOfEvent);
        }

        Map<String, String> expectedColorsInDb = new Map<String, String>{
            'Day To Day Meeting' => 'gray',
            'Core Client Team Meeting' => 'green'
        };
        for (Schema.PicklistEntry meetingType: meetingTypeValues) { // without null
            if (!expectedColorsInDb.containsKey(meetingType.getLabel())) {
                expectedColorsInDb.put(meetingType.getLabel(), 'Black');
            }
        }

        for (List<Calendar_Legend__c> pairs: [SELECT name
                                                    ,Background_Color__c
                                                FROM Calendar_Legend__c
                                               WHERE name IN :expectedColorsInDb.keySet()]) {
            for (Calendar_Legend__c pair: pairs) {
                system.assertEquals(expectedColorsInDb.get(pair.name), pair.Background_Color__c, 'Unexpected background color found in database for ' + pair.name);
            }
        }

        Test.stopTest();
    }
}