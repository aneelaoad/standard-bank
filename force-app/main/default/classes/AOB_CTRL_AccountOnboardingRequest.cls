/**
 * @description Complete application origination controller class makes a callout to the
 * 				complete application api
 *
 * @see AOB_CTRL_AccountOnboardingRequest_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date May 2023
 */
public with sharing class AOB_CTRL_AccountOnboardingRequest
{
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(AOB_CTRL_AccountOnboardingRequest.class.getName());
	/**
	 * @description Performs a callout to the account onboarding api
	 *
	 * @param applicationId application record Id
	 *
	 * @return string
	 */
	@AuraEnabled
	public static String executeAccountOnboarding(String applicationId)
	{
		String responseDescription = CMN_UTIL_String.EMPTY;
		try
		{
			AOB_API_AccountOnboardingRequest completeApplicationCallout = new AOB_API_AccountOnboardingRequest();
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_AccountOnboardingRequest.SERVICE_NAME);
			queueItem.CMN_TriggeringObjectId__c = applicationId;
			completeApplicationCallout.process(queueItem);
			CMN_DAL_SObjectDomain.insertDBObject(queueItem);

			AOB_API_AccountOnboardingRequest.DTO_Response response = (AOB_API_AccountOnboardingRequest.DTO_Response)completeApplicationCallout.baseResponseDTO;
			List<AOB_API_AccountOnboardingRequest.DTO_ErrorResponse> errorResponse = response?.executeAccountOnboardingResponse?.orchestrationHeaderResponse?.errorResponse;
			AOB_API_AccountOnboardingRequest.DTO_ResponseStatus responseStatus = response?.executeAccountOnboardingResponse?.orchestrationHeaderResponse?.responseStatus;
			if(completeApplicationCallout.callResult.statusCode == String.valueOf(CMN_API_HttpBase.HTTP_OK)
					&& responseStatus != null)
			{
				responseDescription = response.executeAccountOnboardingResponse.orchestrationHeaderResponse.responseStatus?.statusDescription;
			}
			else if(completeApplicationCallout.callResult.statusCode == String.valueOf(CMN_API_HttpBase.HTTP_OK)
					&& errorResponse != null)
			{
				responseDescription = errorResponse[0]?.responseMessage;
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
					AOB_API_AccountOnboardingRequest.SERVICE_NAME, error.getMessage()
			}, error);
			throw new AuraHandledException(error.getMessage());
		}
	}

}