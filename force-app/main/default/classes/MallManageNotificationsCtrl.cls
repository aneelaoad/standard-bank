/**
 * @description : MallManageNotificationsCtrl
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallManageNotificationsCtrl {
    /**
    * 
    * @description getNotificationTypes
    * @return  List<Mall_Notification_Management__mdt>
    * @exception AuraHandledException
    */
    @AuraEnabled
    public static List<Mall_Notification_Management__mdt> getNotificationTypes(){
        return Mall_Notification_Management__mdt.getAll().values();
    }

    /**
    * 
    * @description getUserNotificationTypes
    * @return  List<SObject>
    * @exception AuraHandledException
    */
    @AuraEnabled
    public static List<SObject> getUserNotificationTypes(){
        return getNotificationTypes();
    }

    /**
    * 
    * @description getContactsByAccountId
    * @param notifications List<SObject>
    * @return  List<SObject>
    * @exception AuraHandledException
    */
    @AuraEnabled
    public static List<SObject> upsertNotifications(List<SObject> notifications){
        try {
            return notifications;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallManageNotificationsCtrl.upsertNotifications', e);
        }
    }
}