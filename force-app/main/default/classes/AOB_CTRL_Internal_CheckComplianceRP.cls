/**
 * @description       : Controller class for AOB_API_Internal_CheckComplianceRP
 * @author            : Tukelo Moseamo
 * @group             : 
 * @last modified on  : 07-20-2023
 * @last modified by  : Tukelo Moseamo
 
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
**/
public with sharing class AOB_CTRL_Internal_CheckComplianceRP {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CTRL_Internal_CheckComplianceRP');

	/**
	* @description method to use from @wire lightning component 
	* @author Tukelo Moseamo | 07-03-2023 
	* @param  applicationId 
	* @return AOB_API_Internal_CheckComplianceRP.DTO_CheckComplianceRPResponse 
	**/
	@AuraEnabled
	public static AOB_API_Internal_CheckComplianceRP.DTO_CheckComplianceRPResponse checkComplianceRPFromWire(String applicationId) {
		return checkComplianceRP(applicationId);
	}
    /**
    * @description run the check compliance API
    * @author Tukelo Moseamo | 06-22-2023 
    * @param  applicationId 
    * @return AOB_API_Internal_CheckComplianceRP.DTO_CheckComplianceRPResponse 
    **/	
    public static AOB_API_Internal_CheckComplianceRP.DTO_CheckComplianceRPResponse checkComplianceRP(String applicationId) {

        AOB_API_Internal_CheckComplianceRP.DTO_CheckComplianceRPResponse responseDescription = new AOB_API_Internal_CheckComplianceRP.DTO_CheckComplianceRPResponse();
        try {
            AOB_API_Internal_CheckComplianceRP checkComplianceCallout = new AOB_API_Internal_CheckComplianceRP(applicationId);
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_Internal_CheckComplianceRP.SERVICE_NAME);
			queueItem.CMN_TriggeringObjectId__c = applicationId;
			checkComplianceCallout.process(queueItem);
			CMN_DAL_SObjectDomain.insertDBObject(queueItem);
            AOB_API_Internal_CheckComplianceRP.DTO_Response response = (AOB_API_Internal_CheckComplianceRP.DTO_Response)checkComplianceCallout.baseResponseDTO;
            if(checkComplianceCallout.callResult.statusCode == String.valueOf(CMN_API_HttpBase.HTTP_OK)
					&& response.checkComplianceRPandShareholderResponse != null) {
				responseDescription = response.checkComplianceRPandShareholderResponse;
				responseDescription.customerFirstURL = getCustomerFirstURL(applicationId);
			}
			else {
                responseDescription.sysError = !checkComplianceCallout?.callResult?.errors.isEmpty() && checkComplianceCallout?.callResult?.errors != null? 
                    checkComplianceCallout.callResult?.errors[0] : AOB_API_StaffAssistedOnboarding.UNSUCCESSFUL_CALLOUT_ERROR;
			}			

			return responseDescription;
        }
        catch(Exception error) {
			LOGGER.error(error.getMessage(), new String[]
			{
					AOB_CTRL_Internal_CheckComplianceRP.class.getName(), error.getMessage()
			}, error);
			throw new AuraHandledException(error.getMessage());
		}
    }

	/**
	* @description gets and create customer first link using BPGUID
	* @author Tukelo Moseamo | 06-22-2023 
	* @param  applicationId 
	* @return String 
	**/
	private static String getCustomerFirstURL(String applicationId) {

		AOB_Application__c application = new SEL_AOBApplication().selectAppsById(applicationId).iterator()?.next();
		String url = Label.Customer1st_link + application.AOB_Client__r.GUID__c;

		return url;
	}
}