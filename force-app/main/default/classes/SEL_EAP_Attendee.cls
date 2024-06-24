/**
 * @description       : Selector class for EAP_Attendee__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 11-02-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_EAP_Attendee extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            EAP_Attendee__c.Id,
            EAP_Attendee__c.Name,
            EAP_Attendee__c.EAP_AppEvent__c,
            EAP_Attendee__c.EAP_Contact__c,
            EAP_Attendee__c.EAP_RoleEvent__c,
            EAP_Attendee__c.EAP_ContactName__c,
            EAP_Attendee__c.EAP_Contact_Email__c,
            EAP_Attendee__c.EAP_AttendeeCompany__c
        };
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return EAP_Attendee__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return SEL_EAP_Attendee 
    **/
    public static SEL_EAP_Attendee newInstance() {
        return(SEL_EAP_Attendee) ORG_Application.selector.newInstance(EAP_Attendee__c.SObjectType);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param ids 
    * @return List<EAP_Attendee__c> 
    **/
    public List<EAP_Attendee__c> selectById(Set<Id> ids) {
        return (List<EAP_Attendee__c>) Database.query(
                    newQueryFactory()
                    .setCondition('Id IN: ids')
                    .toSOQL());
    }

        /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param ids 
    * @return List<EAP_Attendee__c> 
    **/
    public List<EAP_Attendee__c> selectByIds(List<Id> ids) {
        return (List<EAP_Attendee__c>) Database.query(
                    newQueryFactory()
                    .setCondition('Id IN: ids')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id 
    * @return List<EAP_Attendee__c> 
    **/
    public List<EAP_Attendee__c> selectByContactId(Set<Id> id) {
        return (List<EAP_Attendee__c>) Database.query(
                    newQueryFactory()
                    .setCondition('EAP_Contact__c =: id')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return List<EAP_Attendee__c> 
    **/
    public List<EAP_Attendee__c> selectByEventId(String eventId) {
        return (List<EAP_Attendee__c>) Database.query(
                    newQueryFactory()
                    .setCondition('EAP_AppEvent__c =: eventId')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @param contactId 
    * @return List<EAP_Attendee__c> 
    **/
    public List<EAP_Attendee__c> selectByEventIdAndContactSync(String eventId, String contactId) {
        return (List<EAP_Attendee__c>) Database.query(
                    newQueryFactory()
                    .setCondition('EAP_AppEvent__c =: eventId AND EAP_Contact__c =: contactId')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param nowDatetime 
    * @param contactId 
    * @return List<EAP_Attendee__c> 
    **/
    public List<EAP_Attendee__c> selectByContactAndEventDate(Datetime nowDatetime, String contactId) {
        return (List<EAP_Attendee__c>) Database.query(
                    newQueryFactory()
                    .setCondition('EAP_AppEvent__r.EAP_EndDate__c >: nowDatetime AND EAP_Contact__c =: contactId')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param nowDatetime 
    * @param contactId 
    * @return List<EAP_Attendee__c> 
    **/
    public List<EAP_Attendee__c> selectByContactAndEventDateAndFormCompleted(Datetime nowDatetime, String contactId) {
        return (List<EAP_Attendee__c>) Database.query(
                    newQueryFactory()
                    .setCondition('(EAP_AppEvent__r.EAP_EndDate__c >: nowDatetime AND EAP_Contact__c =: contactId) AND (EAP_FormCompleted__c = false)')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param nowDatetime 
    * @param contactId 
    * @return List<EAP_Attendee__c> 
    **/
    public List<EAP_Attendee__c> selectByContactAndPastDate(Datetime nowDatetime, String contactId) {
        return (List<EAP_Attendee__c>) Database.query(
                    newQueryFactory()
                    .setCondition('EAP_AppEvent__r.EAP_EndDate__c <=: nowDatetime AND EAP_Contact__c =: contactId')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return List<EAP_Attendee__c> 
    **/
    public List<EAP_Attendee__c> selectCorporatesByEventId(String eventId) {
        String rol = DMN_EAP_Attendee.ROL_CORPORATE;
        return (List<EAP_Attendee__c>) Database.query(
                    newQueryFactory()
                    .setCondition('(EAP_AppEvent__c =: eventId) AND (EAP_RoleEvent__c = :rol)')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return List<EAP_Attendee__c> 
    **/
    public List<EAP_Attendee__c> selectInvestorsByEventId(String eventId) {
        String rol = DMN_EAP_Attendee.ROL_INVESTOR;
        return (List<EAP_Attendee__c>) Database.query(
                    newQueryFactory()
                    .selectField('EAP_ContactName__c')
                    .setCondition('(EAP_AppEvent__c =: eventId) AND (EAP_RoleEvent__c = :rol)')
                    .toSOQL());
    }



    /**
    * @description 
    * 
    * @param ids 
    * @return List<EAP_Attendee__c> 
    **/
    public List<EAP_Attendee__c> selectByAssociatedCorporate(Set<Id> ids) {
        String rol = DMN_EAP_Attendee.ROL_CORPORATE_ASSOCIATED;
        return (List<EAP_Attendee__c>) Database.query(
                    newQueryFactory()
                    .selectField('EAP_CorporateAssociated__c')
                    .setCondition('(EAP_CorporateAssociated__c IN: ids) AND (EAP_RoleEvent__c = :rol)')
                    .addOrdering('EAP_CorporateAssociated__c', fflib_QueryFactory.SortOrder.ASCENDING)
                    .toSOQL());
    }
}