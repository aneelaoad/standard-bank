/**
 * @description       : US: SFP-11066 - Generate agenda from a button
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_Shortcuts extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Shortcut__c.Id,
            Shortcut__c.Name,
            Shortcut__c.Link__c,
            Shortcut__c.Provider__c,
            Shortcut__c.User__c
        };
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Shortcut__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return SEL_Shortcuts 
    **/
    public static SEL_Shortcuts newInstance() {
        return(SEL_Shortcuts) ORG_Application.selector.newInstance(Shortcut__c.SObjectType);
    }

    /**
     * @description select shortcuts based on custom filter condition
     * @param condition
     * @return List<Shortcut__c> - with query results
     */
    public List<Shortcut__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .setCondition(condition)
            .toSOQL()
        );
    }
}