/***************************************************************************************
@Author            : Devi Ravuri and Dayakar
@Date              : Jan 25th 2023
@Name of the Class : AOB_FLOW_CheckBPGUIDOnPingToken
@description       : Class used to check if BPGUID is on Ping Token and call CompleteAO_IDV API  if necessary	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
public without sharing class AOB_FLOW_CheckBPGUIDOnPingToken {
    /**
    * @description method to call check if ping token contains bpguid
    * @param appIds
    * @return List<String> result
    */
    @InvocableMethod(label='Check BPGUID On Ping Token')
    public static List<String> isBPGUIDOnPing(List<String> appIds){
        List<String> result = new List<String>();
        String decodedJWT = AOB_Utils.parseJWT(AOB_Utils.getAccessToken());
		if (String.isNotBlank(decodedJWT)) {
            Map<String, Object> jsonMAp = (Map<String, Object>) System.JSON.deserializeUntyped(decodedJWT);
            if (jsonMAp.containsKey(AOB_Constants.PING_BPGUID)) {
                result.add(AOB_Constants.IDV_DONE);
                callCompleteAOIDV(appIds[0]);
            }
            else{
                result.add(AOB_Constants.IDV_NOT_DONE);
            }
        }
        return result;
    }
    
    /**
    * @description method to call AOB_API_CompleteAO_IDV 
    * @param applicationId String
    */
    @AuraEnabled
    public static void callCompleteAOIDV(String applicationId){
        String totalResponse;
        AOB_API_CompleteAO_IDV customerServiceCall = new AOB_API_CompleteAO_IDV(applicationId);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_CompleteAO_IDV.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
        AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
    }    
}