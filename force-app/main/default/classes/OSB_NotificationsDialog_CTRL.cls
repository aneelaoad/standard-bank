/**
* Controller class for NotificationsDialog component, 
* used to interact with user in notifications panel
* <br/>
*
* @author Denys Yelchaninov (dyelchaninov@deloittece.com)
* @date January 2021
*/
public with sharing class OSB_NotificationsDialog_CTRL {
    /**
     * map of user names and ids
     *
     * @return Map<Id, String> containing user ID as key and user name as value
     **/
    @AuraEnabled(Cacheable=true)
    public static Map<Id, String> getAvailableUsers() {
        List<User> userList = SEL_Users.newInstance().selectByIsActiveAndProfileNameWoSharing(new Set<String>{DMN_Profile.ONE_HUB_COMMUNITY});
        Map<Id, String> userMap = new Map<Id, String>();
        for(User u:userList){
            userMap.put(u.Id,u.Name);
        }
        return userMap;
    }

    /**
     * Users for the a specific Notification
     *
     * @param notificationId id of notification
     *
     * @return String
     **/
    @AuraEnabled(Cacheable=true)
    public static String getAssignedUsers(Id notificationId){
        return SEL_Notifications.newInstance().selectById(new Set<Id>{notificationId})[0].Users__c;
    }
}