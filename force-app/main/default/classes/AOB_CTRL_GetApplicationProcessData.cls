/**
 * @description Get application process data controller class to make an API callout
 *
 * @see AOB_CTRL_GetApplicationProcessData_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date April 2023
 * * Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */
public with sharing class AOB_CTRL_GetApplicationProcessData
{

	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(AOB_CTRL_GetApplicationProcessData.class.getName());
	/**
	 * @description Performs a callout to the application process data api
	 *
	 * @param applicationId application record Id
	 *
	 * @return string
	 */
	@AuraEnabled
	public static String applicationProcessDataCallout(String applicationId)
	{
		String responseDescription = CMN_UTIL_String.EMPTY;
		try
		{
			AOB_API_ApplicationProcessData applicationDataCallout = new AOB_API_ApplicationProcessData();
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_ApplicationProcessData.SERVICE_NAME);
			queueItem.CMN_TriggeringObjectId__c = applicationId;
			applicationDataCallout.process(queueItem);
			CMN_DAL_SObjectDomain.insertDBObject(queueItem);

			AOB_API_ApplicationProcessData.DTO_Response response = (AOB_API_ApplicationProcessData.DTO_Response)applicationDataCallout.baseResponseDTO;
			List<AOB_API_ApplicationProcessData.DTO_ErrorResponse> errorResponse = response?.getApplicationProcessDataResponse?.orchestrationHeaderResponse?.errorResponse;

			if(applicationDataCallout.callResult.statusCode == String.valueOf(CMN_API_HttpBase.HTTP_OK)
					&& errorResponse == null)
			{
				responseDescription = response.getApplicationProcessDataResponse.orchestrationHeaderResponse.responseStatus?.statusDescription;
			}
			else if(applicationDataCallout.callResult.statusCode == String.valueOf(CMN_API_HttpBase.HTTP_OK)
					&& errorResponse != null)
			{
				String responseMessage = CMN_UTIL_String.isNotBlank(errorResponse[0]?.responseMessage) ? ' : ' + errorResponse[0]?.responseMessage
						: CMN_UTIL_String.EMPTY;
				responseDescription = errorResponse[0].step + responseMessage;
			}
			else
			{
				responseDescription =
						applicationDataCallout.callResult.aborted ? applicationDataCallout.callResult.errors.iterator().next() : AOB_DTO_StaffAssistedOnboarding.UNSUCCESSFUL_CALLOUT_ERROR;
			}
			return responseDescription;
		}
		catch(Exception error)
		{
			LOGGER.error(error.getMessage(), new String[]
			{
					AOB_API_ApplicationProcessData.SERVICE_NAME, error.getMessage()
			}, error);
			throw new AuraHandledException(error.getMessage());
		}
	}
}