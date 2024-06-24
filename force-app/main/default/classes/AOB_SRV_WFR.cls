/***************************************************************************************
@Author            : Maryem BOURHI(mbourhi @salesforce.com)
@Date              : Nov 27th 2020
@Name of the Class : AOB_SRV_WFR
@description       : Class for API call personal details indentification section	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
public with sharing class AOB_SRV_WFR {
  @TestVisible private static final String IDV_ACTION_CANCEL = 'CANCEL';
  @TestVisible private static final String IDV_ACTION_UPDATE = 'UPDATE';
  private static final String IDV_DESC_UPDEFAULT = 'Updating the IDV Session';
  private static final String IDV_DESC_CADEFAULT = 'Cancelling the IDV Session to start a new one';
  private static final String IDV_VERIFICATION_STATUS = 'Started';
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_WFR');
  public static final String SERVICE_NAME = AOB_SRV_WFR.class.getName();
 
    /**
   * @description Calls the AOB_API_WFRGetIdentifiiToken API
   * @param idNumber
   * @param correlationId
   * @param applicationId
   * @return string containing the token for the WFR
   */
    public static String callOrchestrateIDV( String idNumber, String correlationId, String applicationId) {

        try {
            String totalResponse;
            AOB_API_OrchestrateIDV customerServiceCall = new AOB_API_OrchestrateIDV(idNumber, correlationId, applicationId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_OrchestrateIDV.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
            AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
            AOB_API_OrchestrateIDV.DTO_Response result = (AOB_API_OrchestrateIDV.DTO_Response) customerServiceCall.baseResponseDTO;
            Integer status = customerServiceCall.getResponseStatusCode();
            if(status == 409){
                return 'Error409';
            }else{
                if(status == 200){
                    createVerificationforIDV(result.correlationId, applicationId);
                } else {
                    AOB_CTRL_CaseController.createCase(AOB_API_OrchestrateIDV.SERVICE_NAME + ' ' + customerServiceCall.getResponseBody(), applicationId);
                }
                return result.contextId;
            }

        } catch (Exception ex) {
           LOGGER.error(ex.getMessage(), new String[] {SERVICE_NAME,ex.getMessage()}, ex);
            AOB_CTRL_CaseController.createCase(AOB_API_OrchestrateIDV.SERVICE_NAME + ' ' + ex.getMessage(), applicationId);
            throw new AuraHandledException(ex.getMessage());       
        }
    }
    
    /**
    * @description Calls the AOB_API_StartIDV API
    * @param idNumber
    * @param applicationId
    * @return 	the response of the API
    */
    public static AOB_API_StartIDV.DTO_Response callStartIDV(
        String idNumber,
        String applicationId
    ) {
        AOB_API_StartIDV customerServiceCall = new AOB_API_StartIDV(
            idNumber,
            applicationId
        );
        String totalResponse;
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_StartIDV.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
        AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
        AOB_API_StartIDV.DTO_Response result = (AOB_API_StartIDV.DTO_Response) customerServiceCall.baseResponseDTO;
        return result;
    }

    /**
    * @description Calls the AOB_API_NotifyIDV API
    * @param correlationId
    * @param applicationId
    * @return AOB_API_notifyIDV.DTO_Response
    */
    public static AOB_API_notifyIDV.DTO_Response callNotifyIDV(
        string correlationId,String applicationId
    ) {
        AOB_API_notifyIDV customerServiceCall = new AOB_API_notifyIDV(
            correlationId,
            IDV_ACTION_UPDATE,
            IDV_DESC_UPDEFAULT,applicationId
        );
        String totalResponse;
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_notifyIDV.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
        AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
        AOB_API_notifyIDV.DTO_Response result = (AOB_API_notifyIDV.DTO_Response) customerServiceCall.baseResponseDTO;
        return result;
    }

  /**
   * @description Calls the AOB_API_NotifyIDV API
   * @param correlationId
   * @param applicationId
   * @return AOB_API_notifyIDV.DTO_Response
   */
    public static AOB_API_notifyIDV.DTO_Response cancelIDV(string correlationId,String applicationId) {
        AOB_API_notifyIDV customerServiceCall = new AOB_API_notifyIDV(
            correlationId,
            IDV_ACTION_CANCEL,
            IDV_DESC_UPDEFAULT,
            applicationId
        );
        String totalResponse;
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_notifyIDV.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
        AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
        AOB_API_notifyIDV.DTO_Response result = (AOB_API_notifyIDV.DTO_Response) customerServiceCall.baseResponseDTO;
        return result;
    }

    /**
    * @description Calls the AOB_API_GetIDV API
    * @param idNumber
    * @param applicationId
    * @return AOB_API_GetIDVStatus.DTO_Response
    */
    public static AOB_API_GetIDVStatus.DTO_Response callGetIDV(String idNumber,String applicationId) {
        AOB_API_GetIDVStatus customerServiceCall = new AOB_API_GetIDVStatus(
            idNumber
        );
        String totalResponse;
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_GetIDVStatus.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
        AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
        AOB_API_GetIDVStatus.DTO_Response result = (AOB_API_GetIDVStatus.DTO_Response) customerServiceCall.baseResponseDTO;
        return result;
    }

    /**
   * @description creates the verification record when orchestrate IDV is successfull 
   * @param correlationId
   * @param applicationId
   */
    public static void createVerificationforIDV(String correlationId, String applicationId ) {
        Verification__c[] verList=[SELECT Id from Verification__c WHERE Application__c = : applicationId];
        if(verList.size() <= 2){
            Verification__c verification=new Verification__c();
            verification.Correlation_ID__c=correlationId;
            verification.AOB_WFR_Status__c=AOB_SRV_WFR.IDV_VERIFICATION_STATUS;
            verification.Application__c=applicationId;
            Insert verification;
        }
        
    }

}