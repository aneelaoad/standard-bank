/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class BLD_EAP_MeetingAvailability extends ABS_ObjectBuilderBase {

    public static final String DEF_NAME = 'testEAP_Meeting';
    public static final DateTime DEF_START_DATE = Datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().day(), 9, 0, 0);
    public static final DateTime DEF_END_DATE = Datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().day(), 9, 45, 0);
    public static final DateTime DEF_START_DATE_AFTERNOON = Datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().day(), 15, 0, 0);
    public static final DateTime DEF_END_DATE_AFTERNOON = Datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().day(), 15, 45, 0);

    private static Integer counter = 0;

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param uow 
    **/
    public BLD_EAP_MeetingAvailability(fflib_SObjectUnitOfWork uow) {
        super(EAP_MeetingAvailability__c.SObjectType, uow);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    protected override void setDefaultData() {
        setField(EAP_MeetingAvailability__c.Name, counter + DEF_NAME + counter)
        .setField(EAP_MeetingAvailability__c.EAP_StartDate__c, DEF_START_DATE)
        .setField(EAP_MeetingAvailability__c.EAP_EndDate__c, DEF_END_DATE);

        counter++;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_EAP_MeetingAvailability 
    **/
    public BLD_EAP_MeetingAvailability attendee(BLD_EAP_AppEventAttendee eventBuilder) {
        return (BLD_EAP_MeetingAvailability) setRelation(EAP_MeetingAvailability__c.EAP_Attendee__c, eventBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param attendeeId 
    * @return BLD_EAP_MeetingAvailability 
    **/
    public BLD_EAP_MeetingAvailability attendee(String attendeeId) {
        return (BLD_EAP_MeetingAvailability) setField(EAP_MeetingAvailability__c.EAP_Attendee__c, attendeeId);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return BLD_EAP_MeetingAvailability 
    **/
    public BLD_EAP_MeetingAvailability afternoon() {
        return (BLD_EAP_MeetingAvailability) setField(EAP_MeetingAvailability__c.EAP_EndDate__c, DEF_END_DATE_AFTERNOON)
            .setField(EAP_MeetingAvailability__c.EAP_StartDate__c, DEF_START_DATE_AFTERNOON);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return BLD_EAP_MeetingAvailability 
    **/
    public BLD_EAP_MeetingAvailability booked() {
        return (BLD_EAP_MeetingAvailability) setField(EAP_MeetingAvailability__c.EAP_Booked__c, true);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param startDate 
    * @return BLD_EAP_MeetingAvailability 
    **/
    public BLD_EAP_MeetingAvailability startDate(Datetime startDate) {
        return (BLD_EAP_MeetingAvailability) setField(EAP_MeetingAvailability__c.EAP_StartDate__c, startDate);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param endDate 
    * @return BLD_EAP_MeetingAvailability 
    **/
    public BLD_EAP_MeetingAvailability endDate(Datetime endDate) {
        return (BLD_EAP_MeetingAvailability) setField(EAP_MeetingAvailability__c.EAP_EndDate__c, endDate);
    }
}