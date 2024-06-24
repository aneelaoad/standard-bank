/**
 * @description       : Selector class for EAP_EventVenue__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_EAP_EventVenue extends fflib_SObjectSelector  {
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            EAP_EventVenue__c.Id,
            EAP_EventVenue__c.EAP_Venue__c,
            EAP_EventVenue__c.EAP_AppEvent__c
        };
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return EAP_EventVenue__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return SEL_EAP_EventVenue 
    **/
    public static SEL_EAP_EventVenue newInstance() {
        return(SEL_EAP_EventVenue) ORG_Application.selector.newInstance(EAP_EventVenue__c.SObjectType);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return List<EAP_EventVenue__c> 
    **/
    public List<EAP_EventVenue__c> selectByEventId(String eventId) {
        return (List<EAP_EventVenue__c>) Database.query(
            newQueryFactory()
            .setCondition('EAP_AppEvent__c =: eventId')
            .toSOQL());
    }

}