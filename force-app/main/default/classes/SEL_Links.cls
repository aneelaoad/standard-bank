/**
 * @description       : US: SFP-11066 - Generate agenda from a button
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_Links extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Link__c.Id,
            Link__c.Name,
            Link__c.DeskTop_Url__c,
            Link__c.Mobile_Url__c,
            Link__c.Guest_url__c,
            Link__c.Offering__c,
            Link__c.IsOnline__c,
            Link__c.Provider__c,
            Link__c.Publishing_Unit__c,
            Link__c.Status__c,
            Link__c.Icon__c
        };
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Link__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Link__c 
    **/
    public static SEL_Links newInstance() {
        return(SEL_Links) ORG_Application.selector.newInstance(Link__c.SObjectType);
    }

    /**
     * @description select Links based on custom filter condition
     * @param condition
     * @return List<Link__c> - with query results
     */
    public List<Link__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .setCondition(condition)
            .toSOQL()
        );
    }

    /**
     * @description select Links by Ids
     * @param ids Set<Id> - Set of id's to filter through
     * @return List<Link__c> - with query results
     */
    public List<Link__c> selectById(Set<Id> ids) {
        return Database.query(
            newQueryFactory(false, false, true)  
            .setCondition(' Id IN : ids')
            .toSOQL());
    }
}