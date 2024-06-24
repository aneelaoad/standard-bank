/**
 * @description The class for CompleteAoIDv API call
 * 
 * @author Ramadevi
 *
 * @date May 2023
 */
public class AOB_DTO_CompleteAOIDV {

    public static final String WFR_SUCCESS = 'SUCCESS';
    /**
     * @description An override of the initialise base method
     * @param applicationId
     * @return Aob_Complete_ao_idvBody
    */
    public static Aob_Complete_ao_idvBody completeAOIDVRequest(String applicationId){
        AOB_Application__c aobapplication=[select id, AOB_inflightData__c,AOB_Client__r.Name,AOB_ProcessId__c,AOB_SalesObjectId__c,AOB_InflightDataID__c from AOB_Application__c where id =:applicationId];    
        String processData=AOB_CTRL_FormCreator.getInflight(applicationId,'ProcessData');
        List<GetAppdataResponsWrapper.ProcessTasks> processtask=(List<GetAppdataResponsWrapper.ProcessTasks>)System.JSON.deserialize(processData, List<GetAppdataResponsWrapper.ProcessTasks>.class); 
        Map<String, Object> responseDataProcessTask;
        String taskidentefier;
        for(GetAppdataResponsWrapper.ProcessTasks processsTask:processtask){
            if(processsTask.taskName==AOB_Constants.Step_Await_IDV_Callback){
                responseDataProcessTask=(Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(processsTask.processTaskDetail));
                taskidentefier=processsTask.taskID;
            }
        }
        Aob_Complete_ao_idvBody aobidv= new Aob_Complete_ao_idvBody();
        aobidv.processIdentifier=aobapplication.AOB_ProcessId__c;
        if(!String.isEmpty(taskidentefier)){
            aobidv.taskIdentifier=taskidentefier;
        }else{
            aobidv.taskIdentifier=null;   
        }
        aobidv.webFacialRecognitionStatus=WFR_SUCCESS; 
        if(!String.isEmpty((String)responseDataProcessTask.get(AOB_Constants.WFR_RETRY_ALLOWED))){
            aobidv.webFacialRecognitionRetryAllowed=Boolean.valueOf(responseDataProcessTask.get(AOB_Constants.WFR_RETRY_ALLOWED));
        }else{
            
            aobidv.webFacialRecognitionRetryAllowed=null;
        }
        if(String.isEmpty((String)responseDataProcessTask.get(AOB_Constants.WFR_FAILURE_REASON))){
            aobidv.webFacialRecognitionFailureReason=(String)responseDataProcessTask.get(AOB_Constants.WFR_FAILURE_REASON);
        }else{
            
            aobidv.webFacialRecognitionFailureReason=null;
        }
        return aobidv;
    }

    /**
     * @description An override of the initialise base method
    */
    public class Aob_Complete_ao_idvBody{
        /** @description processIdentifier */
        public String processIdentifier;
        /** @description taskIdentifier */
        public String taskIdentifier;
        /** @description webFacialRecognitionStatus */
        public String webFacialRecognitionStatus;
        /** @description webFacialRecognitionRetryAllowed */
        public Boolean webFacialRecognitionRetryAllowed;
        /** @description webFacialRecognitionFailureReason */
        public String webFacialRecognitionFailureReason;
        
    }
    
}