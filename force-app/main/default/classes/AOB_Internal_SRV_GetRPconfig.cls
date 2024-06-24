/**
* @description Class : SFP-25090 - The Class get Related party to be authenticated.
*
* @author Dayakar
*
* @date April 28th 2023
*/
public without sharing class AOB_Internal_SRV_GetRPconfig implements Queueable ,Database.AllowsCallouts {
    
    public set<string> totalRelPartys1;
    Public String applicationId;
    Public String uUID;
    public AOB_Application__c application;
	public Map<String, Object> inflightDataMap;
    /**
    * @description calling the Get RP congfir API
    * @param applicationIds 
    */
    public AOB_Internal_SRV_GetRPconfig(String applicationIds){
        this.applicationId=applicationIds;

        application = new SEL_AOBApplication().selectAppsById(applicationId).iterator()?.next();

        String inflightData = application.AOB_inflightData__c.contains(AOB_API_StaffAssistedOnboarding.NON_BREAK_SPACE) ? application.AOB_inflightData__c.replace(AOB_API_StaffAssistedOnboarding.NON_BREAK_SPACE, CMN_UTIL_String.EMPTY)
					: application.AOB_inflightData__c;

        inflightDataMap = (Map<String, Object>)JSON.deserializeUntyped(inflightData);
    }
    /**
    * @description calling the Get RP congfir API
    * @param context
    */
    public void execute(QueueableContext context){
        set<string> totalRelPartys = new set<string>(); 
        String preappResponse;
        preappResponse=AOB_CTRL_FormCreator.getInflight(applicationId, 'preApplicationResponse');  
        Map<String, Object> preapplresponsefields = (Map<String, object>) JSON.deserializeUntyped(preappResponse);
        String cipcRegisteredDetails=json.serialize(preapplresponsefields.get('cipcRegisteredDetails'));
        Map<String, Object> cipcRegisteredDetailsmap = (Map<String, object>) JSON.deserializeUntyped(cipcRegisteredDetails);
        
        AOB_API_ApplicationProcessData.DTO_ProcessDataResponse processDataResponse = (AOB_API_ApplicationProcessData.DTO_ProcessDataResponse)JSON.deserialize(
				JSON.serialize(inflightDataMap.get('getApplicationProcessDataResponse')),
				AOB_API_ApplicationProcessData.DTO_ProcessDataResponse.class);
        
        String directorDetails=json.serialize(cipcRegisteredDetailsmap.get('businessDetails'));
        Map<String, Object> directorDetailsmap = (Map<String, object>) JSON.deserializeUntyped(directorDetails);
        //String uUID= processDataResponse.directorDetails[0].bpGuid;
        String uUID= (String) directorDetailsmap.get('businessBPGUID');
        AOB_internal_API_GetRpDetails customerServiceCall = new AOB_internal_API_GetRpDetails(uUID);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_internal_API_GetRpDetails.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        
        AOB_DTO_GETRpDetails gerRpconfigWrapper = (AOB_DTO_GETRpDetails) System.JSON.deserialize(customerServiceCall.getResponseBody(),AOB_DTO_GETRpDetails.class);
        for(AOB_DTO_GETRpDetails.MandRelatedPart eachrec : gerRpconfigWrapper.mandRelatedPart){
            for(AOB_DTO_GETRpDetails.RelatedParties eachRelpart : eachrec.relatedParties){
                totalRelPartys.add(eachRelpart.reltyp);
            }
        }
        uUID = processDataResponse.directorDetails[0].bpGuid;
        totalRelPartys1=totalRelPartys;
        if(!test.isRunningTest()){
            System.enqueueJob(new AOB_Internal_SRV_UpdateRPConfig(totalRelPartys1,applicationId,uUID));
        }
    }

}