/***************************************************************************************
@Author            : Dayakar Deekonda 
@Date              : 20-12-2022 
@Name of the Class : AOB_SRV_CompleteApplication
@description       : Class for Calling Complete Application API	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
public without sharing class AOB_SRV_CompleteApplication{
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_CompleteApplication');

    /**
    * @description	used to Call the Complete Application API
    * @param applicationId
    * @return String Set digital response Status code
    */
    @AuraEnabled
    public static String callCompleteApplicationAPI(String applicationId){
        try{
        String jsonbody;
        String totalResponse;
        AOB_Application__c aobapp= [select id,AOB_ProcessId__c from AOB_Application__c where id=:applicationId];
        AOB_DTO_CompleteApplication res= new AOB_DTO_CompleteApplication();
        res.processIdentifier=aobapp.AOB_ProcessId__c;
        jsonbody=JSON.serialize(res);
        AOB_API_CompleteApplication customerServiceCall = new AOB_API_CompleteApplication(jsonbody);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_CompleteApplication.SERVICE_NAME);
        customerServiceCall.process(obj);
        Insert obj;
        totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
        AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
        Map<String, Object> responsedata = (Map<String, Object>)JSON.deserializeUntyped(customerServiceCall.getResponseBody());
        return (String)responsedata.get('status');
        }catch(exception ex){
            
            LOGGER.error(ex.getMessage(), new String[] {'AOB_SRV_CompleteApplication',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage()); 
        }
        
    }
    
     /**
    * @description	wrapper to form completeApplication
    */
    public class AOB_DTO_CompleteApplication{
        
        
        public string processIdentifier;
        
    }

}