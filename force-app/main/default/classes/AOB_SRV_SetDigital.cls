/***************************************************************************************
@Author            : Dayakar Deekonda 
@Date              : 11-12-2022 
@Name of the Class : AOB_SRV_SetDigital
@description       : Class for Calling Set Digital API	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
public without sharing class AOB_SRV_SetDigital{
    /**
    * @description	used to Call the set digital API
    * @param applicationId
    * @return Set digital response Status code
    */
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_SetDigital');

    @AuraEnabled
    public static Integer callSetDigitalAPI(String applicationId){
        try{
            String totalResponse;
            AOB_API_SetDigital customerServiceCall = new AOB_API_SetDigital(applicationId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_SetDigital.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
            AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
            if(customerServiceCall.getResponseStatusCode()==200){
                List<AOB_Application__c> aobapplication=new SEL_AOBApplication().selectAppsById(applicationId);
                aobapplication[0].AOB_Retry_Count__c=0;
                update aobapplication;
            }
            if (customerServiceCall.getResponseStatusCode() != 200) {
                AOB_CTRL_CaseController.createCase(AOB_API_CompanyDetails.SERVICE_NAME + ' ' + customerServiceCall.getResponseBody(), applicationId);
            }
            return customerServiceCall.getResponseStatusCode();
        }Catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_SRV_SetDigital',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
       
    }
}