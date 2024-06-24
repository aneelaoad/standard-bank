/**
 * @description Complete application origination controller class makes a callout to the
 * 				complete application api
 *
 * @see AOB_CTRL_CompleteApplication_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date April 2023
 * 
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */
public with sharing class AOB_CTRL_InternalCompleteApplication
{
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(AOB_CTRL_InternalPreApplication.class.getName());
	/**
	 * @description Performs a callout to the complete application api
	 *
	 * @param applicationId application record Id
	 *
	 * @return string
	 */
	@AuraEnabled
	public static String completeApplicationCallout(String applicationId)
	{
		String responseDescription = CMN_UTIL_String.EMPTY;
		try
		{
			AOB_API_InternalCompleteApplication completeApplicationCallout = new AOB_API_InternalCompleteApplication();
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_InternalCompleteApplication.SERVICE_NAME);
			queueItem.CMN_TriggeringObjectId__c = applicationId;
			completeApplicationCallout.process(queueItem);
			CMN_DAL_SObjectDomain.insertDBObject(queueItem);

			AOB_API_InternalCompleteApplication.DTO_Response response = (AOB_API_InternalCompleteApplication.DTO_Response)completeApplicationCallout.baseResponseDTO;
			List<AOB_API_InternalCompleteApplication.DTO_ErrorResponse> errorResponse = response?.completeApplicationResponse?.orchestrationHeaderResponse?.errorResponse;
			AOB_API_InternalCompleteApplication.DTO_ResponseStatus responseStatus = response?.completeApplicationResponse?.orchestrationHeaderResponse?.responseStatus;
			if(completeApplicationCallout.callResult.statusCode == String.valueOf(CMN_API_HttpBase.HTTP_OK)
					&& responseStatus != null)
			{
				responseDescription = response.completeApplicationResponse.orchestrationHeaderResponse.responseStatus?.statusDescription;
			}
			else if(completeApplicationCallout.callResult.statusCode == String.valueOf(CMN_API_HttpBase.HTTP_OK)
					&& errorResponse != null)
			{
				String responseMessage = CMN_UTIL_String.isNotBlank(errorResponse[0]?.responseMessage) ? ' : ' + errorResponse[0]?.responseMessage : CMN_UTIL_String.EMPTY;
				responseDescription = errorResponse[0].step + responseMessage;
			}
			else
			{
				responseDescription =
						completeApplicationCallout.callResult.aborted ? completeApplicationCallout.callResult.errors.iterator().next() : AOB_DTO_StaffAssistedOnboarding.UNSUCCESSFUL_CALLOUT_ERROR;
			}
			return responseDescription;
		}
		catch(Exception error)
		{
			LOGGER.error(error.getMessage(), new String[]
			{
					AOB_API_InternalCompleteApplication.SERVICE_NAME, error.getMessage()
			}, error);
			throw new AuraHandledException(error.getMessage());
		}
	}
}