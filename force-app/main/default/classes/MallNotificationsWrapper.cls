/**
 * 
 * @description wrapper classs for notfications
 * @author Manasi Londhe
 * @since 
 */
public class MallNotificationsWrapper {
     public List<User> users;
     public String emailBody;
     public String emailSubject;
     public String emailTemplateName;
     public String batchType;
     public Id targetId;
     public String targetPageRef;
     public String notificationTitle;
     public List<Sobject> contextRecords;
     public String customNotificationBody;
     public Set<String> userIds;

     /**
	* 
	* @description parse
	* @param json String
	* @return MallNotificationsWrapper
	*/
	public static MallNotificationsWrapper parse(String json){
		return (MallNotificationsWrapper) System.JSON.deserialize(json, MallNotificationsWrapper.class);
	}
}