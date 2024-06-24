/**
 * @description       : Selector class for Relationship_Manager__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 08-30-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_Relationship_Manager extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Relationship_Manager__c.Id,
            Relationship_Manager__c.Name,
            Relationship_Manager__c.EAP_Contact__c,
            Relationship_Manager__c.EAP_Relationship_Manager_Email__c,
            Relationship_Manager__c.EAP_User__c
        };
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Relationship_Manager__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return SEL_Relationship_Manager 
    **/
    public static SEL_Relationship_Manager newInstance() {
        return(SEL_Relationship_Manager) ORG_Application.selector.newInstance(Relationship_Manager__c.SObjectType);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param contactId 
    * @return List<Relationship_Manager__c> 
    **/
    public List<Relationship_Manager__c> selectByContactId(String contactId) {
        return (List<Relationship_Manager__c>) Database.query(
                        newQueryFactory()
                        .selectField('EAP_User__r.Name')
                        .setCondition('EAP_Contact__c =: contactId')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param contactId 
    * @return List<Relationship_Manager__c> 
    **/
    public List<Relationship_Manager__c> selectByContactId(Set<Id> contactId) {
        return (List<Relationship_Manager__c>) Database.query(
                        newQueryFactory()
                        .selectField('EAP_User__r.Name')
                        .setCondition('EAP_Contact__c IN: contactId')
                        .toSOQL());
    }
}