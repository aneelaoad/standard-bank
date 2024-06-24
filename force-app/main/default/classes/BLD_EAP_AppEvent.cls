/**
 * @description       : Builder class for EAP_AppEvent__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 10-26-2022
 * @last modified by  : TCK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   07-21-2021   TCK   Initial Version
**/
@IsTest
public without sharing class BLD_EAP_AppEvent extends ABS_ObjectBuilderBase{

    public static final String DEF_NAME = 'testEAP_Event';
    public static final String DEF_TYPE = 'Event';
    public static final String DEF_FORMAT = 'Onsite';
    public static final String DEF_LOCATION = 'testLocation';
    public static final Date DEF_START_DATE = Date.today().addDays(2);
    public static final Date DEF_END_DATE = Date.today().addDays(5);
    public static final Datetime DEF_START_MEETING = DateTime.newInstance(DEF_START_DATE.year(), DEF_START_DATE.month(), DEF_START_DATE.day(), 9, 0, 0);
    public static final Datetime DEF_END_MEETING = DateTime.newInstance(DEF_END_DATE.year(), DEF_END_DATE.month(), DEF_END_DATE.day(), 16, 0, 0);
    public static final Time EVENT_START_TIME = Time.newInstance(1, 2, 3, 4);
    public static final Time EVENT_END_TIME = Time.newInstance(6, 2, 3, 4);
    public static final Integer DEF_DURATION_MEETING = 45;
    public static final Integer DEF_BREAK_BETWEEN = 15;
    public static final Integer DEF_GOLD_MEETING = 1;
    public static final Integer DEF_SILVER_MEETING = 2;
    public static final Integer DEF_BRONZE_MEETING = 3;

    private static Integer counter = 0;

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    public BLD_EAP_AppEvent() {
        this(getNewUnitOfWork());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param uow 
    **/
    public BLD_EAP_AppEvent(fflib_SObjectUnitOfWork uow) {
        super(EAP_AppEvent__c.SObjectType, uow);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param sObj 
    * @param workUnit 
    **/
    public BLD_EAP_AppEvent(EAP_AppEvent__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    protected override void setDefaultData() {
        setField(EAP_AppEvent__c.Name, counter + DEF_NAME + counter)
        .setField(EAP_AppEvent__c.EAP_Type__c,DEF_TYPE)
        .setField(EAP_AppEvent__c.EAP_Format__c, DEF_FORMAT)
        .setField(EAP_AppEvent__c.EAP_Location__c, DEF_LOCATION)
        .setField(EAP_AppEvent__c.EAP_StartDate__c, DEF_START_DATE)
        .setField(EAP_AppEvent__c.EAP_EndDate__c, DEF_END_DATE)
        .setField(EAP_AppEvent__c.EAP_StartMeetingTime__c, DEF_START_MEETING)
        .setField(EAP_AppEvent__c.EAP_EndMeetingTime__c, DEF_END_MEETING)
        .setField(EAP_AppEvent__c.EAP_Start_Meetings_Time__c, EVENT_START_TIME)
        .setField(EAP_AppEvent__c.EAP_End_Meetings_Time__c, EVENT_END_TIME)
        .setField(EAP_AppEvent__c.EAP_MeetingDuration__c, DEF_DURATION_MEETING)
        .setField(EAP_AppEvent__c.EAP_BreakBetweenMeetings__c, DEF_BREAK_BETWEEN)
        .setField(EAP_AppEvent__c.EAP_GoldPerMeeting__c, DEF_GOLD_MEETING)
        .setField(EAP_AppEvent__c.EAP_SilverPerMeeting__c, DEF_SILVER_MEETING)
        .setField(EAP_AppEvent__c.EAP_BronzePerMeeting__c, DEF_BRONZE_MEETING);

        counter++;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_EAP_AppEvent 
    **/
    public BLD_EAP_AppEvent ownerId(String eventBuilder) {
        return (BLD_EAP_AppEvent) setField(EAP_AppEvent__c.OwnerId, eventBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_EAP_AppEvent 
    **/
    public BLD_EAP_AppEvent startDate(Date eventBuilder) {
        return (BLD_EAP_AppEvent) setField(EAP_AppEvent__c.EAP_StartDate__c, eventBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param campaignBuilder 
    * @return BLD_EAP_AppEvent 
    **/
    public BLD_EAP_AppEvent campaign(BLD_Campaign campaignBuilder) {
        return (BLD_EAP_AppEvent) setRelation(EAP_AppEvent__c.EAP_Campaign__c, campaignBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_EAP_AppEvent 
    **/
    public BLD_EAP_AppEvent endDate(Date eventBuilder) {
        return (BLD_EAP_AppEvent) setField(EAP_AppEvent__c.EAP_EndDate__c, eventBuilder);
    }

}