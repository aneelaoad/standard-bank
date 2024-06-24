/***************************************************************************************
@Author            : Dayakar
@Date              : 23 November 2022
@Name of the Class : AOB_SRV_GetRPconfig
@description       : Class used to perform an API call to GET RP confoguration Controller	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
public without sharing class AOB_SRV_GetRPconfig{
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_GetRPconfig');

    /**
    * @description callGetRP
    * @param applicationId
    * @return String
    */
    @AuraEnabled
    public static String callGetRP(String applicationId){
        try{
            set<string> totalRelPartys = new set<string>(); 
            String preappResponse;
            String totalResponse;
            preappResponse=AOB_CTRL_FormCreator.getInflight(applicationId, AOB_Constants.PRE_APP_RESPONSE);  
            Map<String, Object> preapplresponsefields = (Map<String, object>) JSON.deserializeUntyped(preappResponse);
            String uuid=(String)preapplresponsefields.get(AOB_Constants.INITIATOR_BPGUID);
            String businesscustomerUUID= (String)preapplresponsefields.get('businessBPGUID');
            AOB_API_GetRpConfig customerServiceCall = new AOB_API_GetRpConfig(businesscustomerUUID);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_GetRpConfig.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
            AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
            AOB_DTO_GetRP gp= new AOB_DTO_GetRP();
            if(customerServiceCall.getResponseStatusCode()==200){
            AOB_DTO_GETRpDetails gerRpconfigWrapper = (AOB_DTO_GETRpDetails) System.JSON.deserialize(customerServiceCall.getResponseBody(),AOB_DTO_GETRpDetails.class);
            for(AOB_DTO_GETRpDetails.MandRelatedPart eachrec : gerRpconfigWrapper.mandRelatedPart){
                for(AOB_DTO_GETRpDetails.RelatedParties eachRelpart : eachrec.relatedParties){
                    totalRelPartys.add(eachRelpart.reltyp);
                }
            }
            gp.totalRelPartys=totalRelPartys;
            gp.statusCode=customerServiceCall.getResponseStatusCode();
            gp.uuid=uuid;
            }
            return json.serialize(gp);
        }catch(Exception ex){
            LOGGER.error('AOB_SRV_GetRPconfig.callGetRP', ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    }
    
    /**
    * @description AOB_DTO_GetRP
    */
    public class AOB_DTO_GetRP{
        set<string> totalRelPartys;
        Integer statusCode;
        String uuid;
    }
}