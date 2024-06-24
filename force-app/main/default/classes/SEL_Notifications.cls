/**
 * Selector class for Notification__c custom SObject
 *
 * <br>US-4523
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date March 2020
 */
public with sharing class SEL_Notifications extends fflib_SObjectSelector {
    private static final String ALL_USERS = 'All Users';
    /**
     * Updates the notification as read
     * @return new instance of this selector
     **/
    public static SEL_Notifications newInstance() {
        return (SEL_Notifications) ORG_Application.selector.newInstance(Notification__c.SObjectType);
    }

    /**
     * Updates the notification as read
     * @return type of sObject this selector works with
     **/
    public SObjectType getSObjectType() {
        return Notification__c.SObjectType;
    }

    /**
     * Updates the notification as read
     * @return sObjectfields that are being querried by this selector
     **/
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Notification__c.Title__c,
                Notification__c.Is_Unread__c,
                Notification__c.Users__c
        };
    }

    /**
     * @description Updates the notification as read
     * @param Set<Id> set of ids to be selected
     * @return list of notifications
     **/
    public List<Notification__c> selectById(Set<Id> ids) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .setCondition('Id IN :ids')
                        .toSOQL()
        );
    }

    /**
     * Updates the notification as read
     * @return list of notifications
     **/
    public List<Notification__c> getFeedItemsForUser(){
        Id userId=UserInfo.getUserId();
        return Database.query(
                newQueryFactory(false, false, true)
            		    .selectField('Content__c')
                        .selectField('CreatedDate')
                        .selectField('Subtitle__c')
                        .setCondition('OwnerId = :userId OR Users__c INCLUDES(:userId, :ALL_USERS)')
                        .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
                        .toSOQL()
        );
    }

    /**
     * Updates the notification as read
     * @return list of notifications
     **/
    public List<Notification__c> getFeedItemsForUserSearch(Set<Id> notificationIds){
        Id userId=UserInfo.getUserId();
        return Database.query(
                newQueryFactory(false, false, true)
                        .selectField('Content__c')
                        .selectField('CreatedDate')
                        .selectField('Subtitle__c')
                        .setCondition('Id IN :notificationIds AND Users__c INCLUDES(:userId, :ALL_USERS)')
                        .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
                        .toSOQL()
        );
    }
}