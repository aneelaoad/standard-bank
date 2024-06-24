/**
 * @description       : SEL_MallNotificationPreferences
 * @author            : Ankit Kumar
 * @group             : 
 * @last modified on  : 02-27-2024
**/
public without sharing class SEL_MallNotificationPreferences extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Mall_Notification_Preference__c.Id,
            Mall_Notification_Preference__c.Name,
            Mall_Notification_Preference__c.Email__c,
            Mall_Notification_Preference__c.In_App__c,
            Mall_Notification_Preference__c.SMS__c,
            Mall_Notification_Preference__c.User__c,
            Mall_Notification_Preference__c.Contact__c
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Mall_Notification_Preference__c.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return SEL_MallNotificationPreferences 
    **/
    public static SEL_MallNotificationPreferences newInstance() {
        return(SEL_MallNotificationPreferences) ORG_Application.selector.newInstance(Mall_Notification_Preference__c.SObjectType);
    }

    /**
     * @description select mall notification preferences based on custom filter condition
     * @param userIds Set<Id>
     * @return List<Mall_Notification_Preference__c> - with query results
     */
    public List<Mall_Notification_Preference__c> selectByUserIds(Set<Id> userIds) {
        return Database.query(
            newQueryFactory(false, false, true)
            .setCondition(' User__c in : userIds')
            .toSOQL()
        );
    }
}