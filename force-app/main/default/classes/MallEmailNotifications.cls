/**
 * 
 * @description  Email notification helper class
 * @author Manasi Londhe
 * @since 
 */
public class MallEmailNotifications implements MallNotifications {

   /*
    * @description : sendNotifications 
    * @param MallNotificationsWrapper: notification
    * @return : void
    */
    public void sendNotifications(MallNotificationsWrapper notification){
        if(notification != NULL) {
            List<String> userIdsLst = new List<String>();
            userIdsLst.addAll(notification.userIds);
            MallSendEmailService.createEmailsForUsersBasedOnEmailTemplate(
                userIdsLst,
                notification.emailTemplateName
            );
        }
    }
}