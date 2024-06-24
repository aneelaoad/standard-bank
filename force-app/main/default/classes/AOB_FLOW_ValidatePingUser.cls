/**
 * @description : class for validating ping logged in user
 * @author Devi
 * @since Aug 17, 2023
 */
public  without sharing class AOB_FLOW_ValidatePingUser {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CTRL_FormCreator');

    /**
    * @description validates ping user to application
    * @param appIds
    * @return List<String> 
    */
    @InvocableMethod(label='Validate Ping User to Application')
    public static List<String> validatePingUser(List<Id> appIds){
        try{
            List<String> result = new List<String>();
            Id applicationId = appIds[0];
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            List<User> user = new SEL_Users().selectById(new Set<Id> {UserInfo.getUserId()});
            if(apps[0].AOB_Client__c != user[0].AccountId){
                result.add('PingUserMismatch');
            }
            return result;
        }
        catch(Exception ex){
            LOGGER.error('AOB_FLOW_ValidatePingUser.validatePingUser', ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }

    /**
    * @description logouts the current logged in user
    */
    @AuraEnabled
    public static void logoutUser(){
        try{
            List<AuthSession> authSessions = [Select Id from AuthSession WHERE UsersId =: UserInfo.getUserId()];
            if(authSessions.size()>0){
                delete authSessions;
            }
        }
        catch(Exception ex){ 
            LOGGER.error('AOB_FLOW_ValidatePingUser.logoutUser', ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }


}