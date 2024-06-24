/**
 * 
 * @description  custom notification helper class
 * @author Manasi Londhe
 * @since 
 */
public class MallCustomNotifications implements MallNotifications{

     /*
    * @description : sendNotifications 
    * @param MallNotificationsWrapper: notification
    * @return : void
    */
    public void sendNotifications(MallNotificationsWrapper notification){
        Set<String> userIds=new Set<String>();
        List<CustomNotificationType > notificationTypes=new List<CustomNotificationType>();
        if(notification.batchType != NULL){
            String notificationType = notification.batchType;
            notificationTypes = SEL_CustomNotificationTypes.newInstance().selectByDeveloperName(new Set<String>{notificationType});
        }

        if(notification.users != NULL) {
            for(User u:notification.users){
                userIds.add(u.Id);
            }
        }
        if(userIds.isEmpty()){        
            userIds = notification.userIds;
        }
        if(!userIds.isEmpty()){
            Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
            currNotification.setTitle(notification.notificationTitle);
            if(!notificationTypes.isEmpty()){
                currNotification.setNotificationTypeId(notificationTypes[0].Id);
            }
            currNotification.setTargetId(notification.targetId);
            if(notification.customNotificationBody!=null){
                currNotification.setBody(notification.customNotificationBody);
            }
            currNotification.send(userIds);
        }
    }
}