/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
@isTest
public without sharing class BLD_EAP_Attendance extends ABS_ObjectBuilderBase {

    public static final String DEF_NAME = 'testEAP_Attendance';

    private static Integer counter = 0;

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    public BLD_EAP_Attendance() {
        this(getNewUnitOfWork());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param uow 
    **/
    public BLD_EAP_Attendance(fflib_SObjectUnitOfWork uow) {
        super(EAP_Attendance__c.SObjectType, uow);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param sObj 
    * @param workUnit 
    **/
    public BLD_EAP_Attendance(EAP_Attendance__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    protected override void setDefaultData() {
        setField(EAP_Attendance__c.Name, counter + DEF_NAME + counter);

        counter++;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_EAP_Attendance 
    **/
    public BLD_EAP_Attendance meeting(BLD_EAP_Meeting eventBuilder) {
        return (BLD_EAP_Attendance) setRelation(EAP_Attendance__c.EAP_Meeting__c, eventBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param meetingId 
    * @return BLD_EAP_Attendance 
    **/
    public BLD_EAP_Attendance meeting(Id meetingId) {
        return (BLD_EAP_Attendance) setField(EAP_Attendance__c.EAP_Meeting__c, meetingId);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param attendeeBuilder 
    * @return BLD_EAP_Attendance 
    **/
    public BLD_EAP_Attendance attendee(BLD_EAP_AppEventAttendee attendeeBuilder) {
        return (BLD_EAP_Attendance) setRelation(EAP_Attendance__c.EAP_Attendee__c, attendeeBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param attendeeBuilder 
    * @return BLD_EAP_Attendance 
    **/
    public BLD_EAP_Attendance requestFrom(BLD_EAP_AppEventAttendee attendeeBuilder) {
        return (BLD_EAP_Attendance) setRelation(EAP_Attendance__c.EAP_RequestFrom__c, attendeeBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param attendeeBuilder 
    * @return BLD_EAP_Attendance 
    **/
    public BLD_EAP_Attendance targetAttendee(BLD_EAP_AppEventAttendee attendeeBuilder) {
        return (BLD_EAP_Attendance) setRelation(EAP_Attendance__c.EAP_TargetAttendee__c, attendeeBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param attendeeId 
    * @return BLD_EAP_Attendance 
    **/
    public BLD_EAP_Attendance attendee(String attendeeId) {
        return (BLD_EAP_Attendance) setField(EAP_Attendance__c.EAP_Attendee__c, attendeeId);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param attendeeId 
    * @return BLD_EAP_Attendance 
    **/
    public BLD_EAP_Attendance requestFrom(String attendeeId) {
        return (BLD_EAP_Attendance) setField(EAP_Attendance__c.EAP_RequestFrom__c, attendeeId);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param attendeeId 
    * @return BLD_EAP_Attendance 
    **/
    public BLD_EAP_Attendance targetAttendee(String attendeeId) {
        return (BLD_EAP_Attendance) setField(EAP_Attendance__c.EAP_TargetAttendee__c, attendeeId);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param preference 
    * @return BLD_EAP_Attendance 
    **/
    public BLD_EAP_Attendance preference(Integer preference) {
        return (BLD_EAP_Attendance) setField(EAP_Attendance__c.EAP_PreferenceSelection__c, preference);
    }
}