/**
* @description Class 
*
* @author Dayakar
*
* @date April 28th 2023
*
* @modification description: SFP-25088
*/
public without sharing class AOB_Internal_CTRL_RPDetails {
    
    
    /**
    * @description calling the Get RP congfir API
    * @param applicationId
    */ 
    @AuraEnabled
    public static void callGetApplication(String applicationId){
        System.enqueueJob(new AOB_Internal_SRV_GetRPconfig(applicationId));    
    }


}