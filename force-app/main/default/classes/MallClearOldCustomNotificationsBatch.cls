/**
 * @description MallClearOldCustomNotificationsBatch
 * @author Maham Hassan
 * @since 
 */
public class MallClearOldCustomNotificationsBatch implements Database.Batchable<sObject>,   Database.AllowsCallouts {    
    public static Integer nuberOfMonthsOldNotifications = 3;
    /**
     * 
     * @description start
     * @param bc Database.BatchableContext
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String runningUser = UserInfo.getUserId();
        String query ='SELECT Id ,Name, Email, Profile.Name From USER ';
        String whereClause = ' WHERE Id IN (\'' + String.join(new List<String>{runningUser}, '\',\'') + '\')';
        query = query + whereClause;
        return Database.getQueryLocator(query);
    }  

    /**
     * 
     * @description execute
     * @param bc Database.BatchableContext
     * @param users List<User> users
     */
    public void execute(Database.BatchableContext bc, List<User> users) {
        DateTime threeMonthsOldDate = Datetime.now().addMonths(-nuberOfMonthsOldNotifications);
        String threeMonthsOldDateString = threeMonthsOldDate.format( 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String jsonBody = '{"before": ' + '"' + threeMonthsOldDateString + '"' + ',  "read": "true"}';  
        jsonBody = '{"before": ' + '"' + threeMonthsOldDateString + '"' + ',  "seen": "true", "read": "false"}';  
        try{
            Boolean updateSuccessful = MallNotificationsController.updateNotifications(jsonBody);
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('MallClearOldCustomNotificationsBatch.execute', e);
        }
    }

    /**
     * 
     * @description finish
     * @param info Database.BatchableContext
     */
    public void finish(Database.BatchableContext info){ 
            
    }
}