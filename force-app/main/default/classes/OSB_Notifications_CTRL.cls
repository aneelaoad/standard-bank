/**
* Controller class for notifications component, used to
* show and maintain notifications
* <br/>
*
* @author Denys Yelchaninov (dyelchaninov@deloittece.com)
* @date January 2021
*/
public without sharing class OSB_Notifications_CTRL {

    private static final String ALL_USERS = 'All Users';

    /**
     * Returns a list of notifications for user
     *
     * @return List<object> feedItems
     **/
    @AuraEnabled(Cacheable=true)
    public static List<Object> getFeedItemsForUser() {
        List<Object> feedItems = SEL_Notifications.newInstance().getFeedItemsForUser();
        return feedItems;
    }

    @AuraEnabled
    public static List<Object> getFeedItemsSearched(String searchKeyword){
        List<Object> feedItems = new List<Object>();
        String searchString = '*' + searchKeyword + '*';
        List<List<Notification__c>> notificationSearch = [Find :searchString IN ALL FIELDS RETURNING  Notification__c(Title__c,Subtitle__c,Content__c)];
        Notification__c [] notificationSearchList = ((List<Notification__c>)notificationSearch[0]);
        Set<Id> notificationSearchResults = (new Map<Id,SObject>(notificationSearchList)).keySet();
        feedItems =  SEL_Notifications.newInstance().getFeedItemsForUserSearch(notificationSearchResults);
        return feedItems;
    }

    /**
     * Updates the notification as read
     *
     * @param recordId of Notification__c
     * @return error message if update fails
     **/
    @AuraEnabled(Cacheable=false)
    public static String markReadNotification(Id recordId) {      
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        Notification__c notif = new Notification__c(Id =  recordId, Is_Unread__c = false);
        try {
            uow.registerDirty(notif);
            uow.commitWork();
        } catch(Exception ex) {
            return ex.getMessage();
        }
        return '';
    }

    /**
     * Updates the notification as read
     *
     * @param recordId of Notification__c
     * @return error message if update fails
     **/
    @AuraEnabled(Cacheable=false)
    public static void removeNotification(Id recordId, Boolean deleteAll) { 
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        try {
            if(deleteAll){
                List<Notification__c> allUserNotifications = SEL_Notifications.newInstance().getFeedItemsForUser();
                uow.registerDeleted(allUserNotifications);
            }else{
                Notification__c notif = new Notification__c(Id =  recordId);
                uow.registerDeleted(notif);  
            }   
        uow.commitWork();
        } catch(Exception ex) {
                OSB_SRV_ActionFailureHandler.newInstance().handleError(ex, OSB_Notifications_CTRL.class.getName());
        }
    }
}