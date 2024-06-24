/***************************************************************************************
@Author            :  Dayakar
@Date              : 23 November 2022
@Name of the Class : AOB_SRV_UpdateRPConfig
@description       : Class used to perform an API call to update RP confoguration	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
public without sharing class AOB_SRV_UpdateRPConfig{
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_UpdateRPConfig');

    /**
    * @description callUpdateRP
    * @param relparty
    * @param applicationId 
    * @param uuid 
    * @return Integer 
    */
    @AuraEnabled
    public Static Integer callUpdateRP(List<String> relparty,String applicationId,String uuid){
        try{
            String totalResponse;
            set<string> relpartydata = new  set<string>();
            for(String rs:relparty){
                relpartydata.add(rs);
            }
        
            AOB_API_UpdateRpDetailsInformation customerServiceCall = new AOB_API_UpdateRpDetailsInformation(relpartydata,applicationId,uuid);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_UpdateRpDetailsInformation.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
            AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
            return customerServiceCall.getResponseStatusCode();
        } catch(Exception ex){
            LOGGER.error('AOB_SRV_UpdateRPConfig.callUpdateRP', ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
       
    }
    
}