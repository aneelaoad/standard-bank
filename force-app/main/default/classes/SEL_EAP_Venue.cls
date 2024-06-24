/**
 * @description       : Selector class for EAP_Venue__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_EAP_Venue extends fflib_SObjectSelector {
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            EAP_Venue__c.Id,
            EAP_Venue__c.Name,
            EAP_Venue__c.EAP_Description__c,
            EAP_Venue__c.EAP_BuildingName__c,
            EAP_Venue__c.EAP_Address__c,
            EAP_Venue__c.EAP_Website__c,
            EAP_Venue__c.EAP_ContactPhone__c,
            EAP_Venue__c.EAP_ServiceCapability__c,
            EAP_Venue__c.EAP_Parking__c,
            EAP_Venue__c.EAP_TravelAdvice__c
        };
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return EAP_Venue__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return SEL_EAP_Venue 
    **/
    public static SEL_EAP_Venue newInstance() {
        return(SEL_EAP_Venue) ORG_Application.selector.newInstance(EAP_Venue__c.SObjectType);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param ids 
    * @return List<EAP_Venue__c> 
    **/
    public List<EAP_Venue__c> selectById(Set<Id> ids) {
        return (List<EAP_Venue__c>) Database.query(
            newQueryFactory()
            .setCondition('Id IN: ids')
            .toSOQL());
    }
}