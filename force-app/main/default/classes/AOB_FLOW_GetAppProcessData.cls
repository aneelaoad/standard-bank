/**
*  Class used to call AOB_API_GetApplicationProcessData API from Flow
*
* @author  Dayakar
*
* @date Jan 25th 2023
* 
* ACTION        DATE       OWNER            COMMENT
* created     25-01-2023   Dayakar          created
*/
public class AOB_FLOW_GetAppProcessData {
   @InvocableMethod(label='Call Get Application Process Data API')
   public static void isBPGUIDOnPing(List<String> appIds){
       Integer responseCode = AOB_SRV_GetApplicationProcess.getApplicationProcessedData(appIds[0]);
       if(responseCode!=200){
           AOB_CTRL_CaseController.createCase(AOB_API_GetApplicationProcessData.SERVICE_NAME + ' ' + responseCode, appIds[0]);
       }
   }
}