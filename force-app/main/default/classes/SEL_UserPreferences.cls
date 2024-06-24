/**
 * @description       : SEL_UserPreferences
 * @author            : Ankit Kumar
 * @group             : 
 * @last modified on  : 04-16-2024
 * @last modified by  : Ankit Kumar
**/
public without sharing class SEL_UserPreferences extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 04-16-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            User_Preference__c.Id,
            User_Preference__c.Name,
            User_Preference__c.Tag__c,
            User_Preference__c.User__c
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 04-16-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return User_Preference__c.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 04-16-2024 
    * @return SEL_UserPreferences 
    **/
    public static SEL_UserPreferences newInstance() {
        return(SEL_UserPreferences) ORG_Application.selector.newInstance(User_Preference__c.SObjectType);
    }

    /**
     * @description select user prefernces by  userIds
     * @param userIds Set<Id> - Set of id's to filter through
     * @return List<User_Preference__c> - with query results
     */
    public List<User_Preference__c> selectByUserIds(Set<Id> userIds) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Root_Name__c')
            .setCondition('User__c in : userIds')
            .toSOQL());
    } 

    /**
     * @description select tags by  ids
     * @param rootNames Set<String> - Set of id's to filter through
     * @param userId String - userId
     * @return List<User_Preference__c> - with query results
     */
    public List<User_Preference__c> selectByRootNamesAndUserId(Set<String> rootNames, String userId) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Root_Name__c')
            .setCondition('Tag__r.Root_Name__c in : rootNames AND User__c =: userId')
            .toSOQL());
    } 
}