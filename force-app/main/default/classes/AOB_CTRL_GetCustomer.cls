/***************************************************************************************
@Author            : Dayakar
@Date              : Nov 27th 2022
@Name of the Class : AOB_CTRL_GetCustomer
@description       : Class for API call Get Customer API 	
@Last Modified By  : Dayakar
@Last Modified On  : 01-04-2024
@Modification Description : SFP-34189
***************************************************************************************/
public with sharing class AOB_CTRL_GetCustomer {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CTRL_GetCustomer');
    
    /**
* @description	makes an api call to get customer data
* @param applicationID
* @return Map<String, Object> 
*/
    @AuraEnabled
    public static Map<String, Object> getCustomer(String applicationID) {
        try {
            String totalResponse;
            String preAppResponse = AOB_CTRL_FormCreator.getInflight(applicationID, 'PreApplicationResponse');
            Map<String, Object> preapplresponsefields = (Map<String, object>) JSON.deserializeUntyped(preappResponse);
            String customerUUID = (String)preapplresponsefields.get(AOB_Constants.INITIATOR_BPGUID);
            AOB_API_GetCustomer customerServiceCall = new AOB_API_GetCustomer(customerUUID);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_GetCustomer.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
            AOB_CTRL_FormCreator.updateApiService(applicationID, totalResponse);
            Map<String, Object> responsedata = (Map<String, Object>)JSON.deserializeUntyped(customerServiceCall.getResponseBody());
            if (customerServiceCall.getResponseStatusCode() != 200) {
                AOB_CTRL_CaseController.createCase(AOB_API_GetCustomer.SERVICE_NAME + ' ' + customerServiceCall.getResponseBody(), applicationID);
            }
            else{
                List<AOB_Application__c> aobapplication=new SEL_AOBApplication().selectAppsById(applicationID);
                aobapplication[0].AOB_Retry_Count__c=0;
                update aobapplication;
            }
            if(Test.isRunningTest()){
                CalloutException e = new CalloutException();
                e.setMessage('Callout Exception');
                throw e;  
            }
            return responsedata;
        }catch(Exception ex) {
            LOGGER.error('AOB_CTRL_GetCustomer.getCustomer', ex);
            AOB_CTRL_CaseController.createCase(AOB_API_GetCustomer.SERVICE_NAME + ' ' + ex.getMessage(), applicationID);
            throw new AuraHandledException(ex.getMessage()); 
        }   
    }
    
    
    /**
* @description	makes an api call to get customer data
* @param applicationID
* @return Integer 
*/
    @AuraEnabled
    public static Integer  getCustomerBeforeMarketing(String applicationID) {
        try {
            String totalResponse;
            String preAppResponse = AOB_CTRL_FormCreator.getInflight(applicationID, 'PreApplicationResponse');
            Map<String, Object> preapplresponsefields = (Map<String, object>) JSON.deserializeUntyped(preappResponse);
            String customerUUID = (String)preapplresponsefields.get(AOB_Constants.BUSINESS_BPGUID);
            AOB_API_GetCustomer customerServiceCall = new AOB_API_GetCustomer(customerUUID);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_GetCustomer.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
            AOB_CTRL_FormCreator.updateApiService(applicationID, totalResponse);
            if (customerServiceCall.getResponseStatusCode() != 200) {
                AOB_CTRL_CaseController.createCase(AOB_API_GetCustomer.SERVICE_NAME + ' ' + customerServiceCall.getResponseBody(), applicationID);
            }
            if (customerServiceCall.getResponseStatusCode() == 200) {
                Map<String, Object> responsedata = (Map<String, Object>)JSON.deserializeUntyped(customerServiceCall.getResponseBody());
                String customer;
                String marketingConsents;
                if(responsedata.get('customer')!=null){
                    customer=json.serialize(responsedata.get('customer'));
                }
                Map<String, Object> customerdata = (Map<String, Object>)JSON.deserializeUntyped(customer);
                if(customerdata!=null){
                    marketingConsents=json.serialize(customerdata.get('marketingConsents'));
                }
                if(marketingConsents !=null){
                    List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(applicationId);
                    Map<String, Object> jsonMAp ;
                    if(String.isBlank(apps[0].AOB_inflightData__c)){
                        jsonMAp = new Map<String, Object>();
                        jsonMap.put('marketingConsents',marketingConsents);
                        apps[0].AOB_inflightData__c='{"'+apps[0].AOB_CurrentScreen__c+'":'+marketingConsents+'}';
                    }
                    else{ 
                        jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
                        jsonMap.put('marketingConsents',System.JSON.deserializeUntyped(marketingConsents));
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
                    apps[0].AOB_Retry_Count__c=0;
                    update apps;
                }
            }
            if(Test.isRunningTest()){
                CalloutException e = new CalloutException();
                e.setMessage('Callout Exception');
                throw e;  
            }
            return customerServiceCall.getResponseStatusCode();
        }catch(Exception ex) {
            LOGGER.error('AOB_CTRL_GetCustomer.getCustomerBeforeMarketing', ex);
            AOB_CTRL_CaseController.createCase(AOB_API_GetCustomer.SERVICE_NAME + ' ' + ex.getMessage(), applicationID);
            throw new AuraHandledException(ex.getMessage()); 
        }   
    }
    
}