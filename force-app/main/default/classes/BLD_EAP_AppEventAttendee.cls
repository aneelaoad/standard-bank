/**
 * @description       : Builder class for EAP_Attendee__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   07-29-2021   TCK   Initial Version
**/
public without sharing class BLD_EAP_AppEventAttendee extends ABS_ObjectBuilderBase {

    public static final String DEF_NAME = 'testEAP_Attendee__c';
    public static final String DEF_ROLE_EVENT = 'Participant';

    private static Integer counter = 0;

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param uow 
    **/
    public BLD_EAP_AppEventAttendee(fflib_SObjectUnitOfWork uow) {
        super(EAP_Attendee__c.SObjectType, uow);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    protected override void setDefaultData() {
        setField(EAP_Attendee__c.Name, counter + DEF_NAME + counter)
        .setField(EAP_Attendee__c.EAP_RoleEvent__c, DEF_ROLE_EVENT);

        counter++;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_EAP_AppEventAttendee 
    **/
    public BLD_EAP_AppEventAttendee event(BLD_EAP_AppEvent eventBuilder) {
        return (BLD_EAP_AppEventAttendee) setRelation(EAP_Attendee__c.EAP_AppEvent__c, eventBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return BLD_EAP_AppEventAttendee 
    **/
    public BLD_EAP_AppEventAttendee event(Id eventId) {
        return (BLD_EAP_AppEventAttendee) setField(EAP_Attendee__c.EAP_AppEvent__c, eventId);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id 
    * @return BLD_EAP_AppEventAttendee 
    **/
    public BLD_EAP_AppEventAttendee contactId(String id) {
        return (BLD_EAP_AppEventAttendee) setField(EAP_Attendee__c.EAP_Contact__c, id);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param isComplete 
    * @return BLD_EAP_AppEventAttendee 
    **/
    public BLD_EAP_AppEventAttendee formCompleted(Boolean isComplete) {
        return (BLD_EAP_AppEventAttendee) setField(EAP_Attendee__c.EAP_FormCompleted__c, isComplete);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param rolInEvent 
    * @return BLD_EAP_AppEventAttendee 
    **/
    public BLD_EAP_AppEventAttendee rolInEvent(String rolInEvent) {
        return (BLD_EAP_AppEventAttendee) setField(EAP_Attendee__c.EAP_RoleEvent__c, rolInEvent);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param tierLevel 
    * @return BLD_EAP_AppEventAttendee 
    **/
    public BLD_EAP_AppEventAttendee tierLevel(String tierLevel) {
        return (BLD_EAP_AppEventAttendee) setField(EAP_Attendee__c.EAP_TierLevel__c, tierLevel);
    }
    
}