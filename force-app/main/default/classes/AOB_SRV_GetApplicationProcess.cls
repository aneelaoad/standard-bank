/***************************************************************************************
@Author            : Dayakar Deekonda 
@Date              : Oct 29th 2021
@Name of the Class : AOB_SRV_GetApplicationProcess
@description       : API GET App Process 	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
public without sharing class AOB_SRV_GetApplicationProcess{
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_CreateContract');
   /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param applicationId
    * @return Integer
    */
    public static Integer getApplicationProcessedData(String applicationId){
        try{  
            String totalResponse;   
            AOB_API_GetApplicationProcessData customerServiceCall = new AOB_API_GetApplicationProcessData(applicationId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_GetApplicationProcessData.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
            AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
            if(customerServiceCall.getResponseStatusCode()==200){
                GetAppdataResponsWrapper getappdatta=(GetAppdataResponsWrapper)System.JSON.deserialize(customerServiceCall.getResponseBody(), GetAppdataResponsWrapper.class);
                String appData;
                if(getappdatta.processTasks!=null){
                  appData=JSON.serialize(getappdatta.processTasks);
                }
                if(!String.isEmpty(appData)){
                List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
                Map<String, Object> jsonMAp ;
                if(String.isBlank(apps[0].AOB_inflightData__c)){
                    jsonMAp = new Map<String, Object>();
                    jsonMap.put(AOB_Constants.PROCESS_DATA,appData);
                    apps[0].AOB_inflightData__c='{"'+apps[0].AOB_CurrentScreen__c+'":'+appData+'}';
                }
                else{ 
                    jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
                    jsonMap.put(AOB_Constants.PROCESS_DATA,System.JSON.deserializeUntyped(appData));
                    apps[0].AOB_inflightData__c='';
                    for(String screen:jsonMAp.keyset()){
                        if(String.isblank(apps[0].AOB_inflightData__c)){
                            apps[0].AOB_inflightData__c='{"'+screen+'":'+System.JSON.serialize(jsonMAp.get(screen))+'}';
                        }
                        else {
                            String str=apps[0].AOB_inflightData__c.SubStringAfter('{');
                            apps[0].AOB_inflightData__c='{"'+screen+'":'+System.JSON.serialize(jsonMAp.get(screen))+','+str;
                        }
                    }
                } 
                
                
                update apps;
                }
            }
            return customerServiceCall.getResponseStatusCode();
        }Catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_SRV_GetApplicationProcess',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}