/***************************************************************************************
@Author            : Dayakar Deekonda 
@Date              : Nov 23th 2022
@Name of the Class : AOB_API_BusinessLead_CTRL
@description       : Class used to call external business lead API.	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP-27748
***************************************************************************************/

public without sharing class AOB_API_BusinessLead_CTRL {
    
    public static final String SERVICE_NAME = AOB_SRV_OTP.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_API_BusinessLead_CTRL');

    /**
    * @description method used to call business lead API
    * @param applicationId 
    * @param leadReason 
    * @return Response Status Code 
    */
    @AuraEnabled
    public static Integer callBusinessLead(String applicationId, String leadReason){
        try{
        String preApplication;
        String totalResponse;
        preApplication=getInflight(applicationId, AOB_Constants.PREAPPLICATION);
        AOB_API_BusinessLead customerServiceCall = new AOB_API_BusinessLead(applicationId,preApplication,leadReason);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_BusinessLead.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
        updateApiService(applicationId, totalResponse);
        if(customerServiceCall.getResponseStatusCode() == 200){
              List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
              if(!apps.isEmpty()){
                  apps[0].AOB_Retry_Count__c=0;
                  apps[0].Lead_Created__c = TRUE;
                  update apps;
              }
        }
        else{
            AOB_CTRL_CaseController.createCase(AOB_API_PreApplication.SERVICE_NAME + ' ' + customerServiceCall.getResponseBody(), applicationId);

        }
        return customerServiceCall.getResponseStatusCode();
        }Catch(exception ex){
            LOGGER.error('AOB_API_BusinessLead_CTRL.callBusinessLead', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /**
    * @description method used to get the inflight based on Screen Name
    * @param appId 
    * @param screenName 
    * @return inflight Data 
    */
    @AuraEnabled
    public static String getInflight(string appId, string screenName){
        String inflightData;
        List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(appId);
        Map<String, Object> jsonData = (Map<String, Object>)system.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
        for(string screen : jsonData.keyset()){
            if(screen == screenName){
                inflightData = System.JSON.serialize(jsonData.get(screen));
            }
        }
        return inflightData;
    }
 
    /**
    * @description method to update the API service and response code in application
    * @param applicationId id
    * @param totalResponse API_Response
    */
     public static void updateApiService(String applicationId, String  totalResponse){
        try{
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
            apps[0].Recent_API_Service__c = totalResponse;
            update apps;
        }catch(Exception ex) {
            LOGGER.error('AOB_API_BusinessLead_CTRL.updateApiService', ex);
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