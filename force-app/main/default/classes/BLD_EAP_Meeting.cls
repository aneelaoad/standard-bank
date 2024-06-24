/**
 * @description       : Builder class for EAP_Meeting__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   07-21-2021   TCK   Initial Version
**/
@IsTest
public without sharing class BLD_EAP_Meeting extends ABS_ObjectBuilderBase{
    
    public static final String DEF_NAME = 'testEAP_Meeting';
    public static final String DEF_DESCRIPTION = 'testDescription';
    public static final String DEF_MEETING_LINK = 'testLocation';
    public static final Date DEF_START_DATE = Date.today().addDays(2);
    public static final Date DEF_END_DATE = Date.today().addDays(3);

    private static Integer counter = 0;

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    public BLD_EAP_Meeting() {
        this(getNewUnitOfWork());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param uow 
    **/
    public BLD_EAP_Meeting(fflib_SObjectUnitOfWork uow) {
        super(EAP_Meeting__c.SObjectType, uow);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    protected override void setDefaultData() {
        setField(EAP_Meeting__c.Name, counter + DEF_NAME + counter)
        .setField(EAP_Meeting__c.EAP_Description__c,DEF_DESCRIPTION)
        .setField(EAP_Meeting__c.EAP_MeetingLink__c, DEF_MEETING_LINK)
        .setField(EAP_Meeting__c.EAP_StartDate__c, DEF_START_DATE)
        .setField(EAP_Meeting__c.EAP_EndDate__c, DEF_END_DATE);

        counter++;
    }
    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_EAP_Meeting 
    **/
    public BLD_EAP_Meeting event(BLD_EAP_AppEvent eventBuilder) {
        return (BLD_EAP_Meeting) setRelation(EAP_Meeting__c.EAP_AppEvent__c, eventBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return BLD_EAP_Meeting 
    **/
    public BLD_EAP_Meeting event(String eventId) {
        return (BLD_EAP_Meeting) setField(EAP_Meeting__c.EAP_AppEvent__c, eventId);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_EAP_Meeting 
    **/
    public BLD_EAP_Meeting meeting(BLD_EAP_Meeting eventBuilder) {
        return (BLD_EAP_Meeting) setRelation(EAP_Meeting__c.EAP_Meeting__c, eventBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param corporateId 
    * @return BLD_EAP_Meeting 
    **/
    public BLD_EAP_Meeting corporate(BLD_EAP_AppEventAttendee corporateId) {
        return (BLD_EAP_Meeting) setRelation(EAP_Meeting__c.EAP_CorporateID__c, corporateId);
    }
    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param startDate 
    * @return BLD_EAP_Meeting 
    **/
    public BLD_EAP_Meeting startDate(Datetime startDate) {
        return (BLD_EAP_Meeting) setField(EAP_Meeting__c.EAP_StartDate__c, startDate);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param endDate 
    * @return BLD_EAP_Meeting 
    **/
    public BLD_EAP_Meeting endDate(Datetime endDate) {
        return (BLD_EAP_Meeting) setField(EAP_Meeting__c.EAP_EndDate__c, endDate);
    }
}