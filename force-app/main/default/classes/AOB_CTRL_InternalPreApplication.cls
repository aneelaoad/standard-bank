/**
 * @description Pre Application controller class
 *
 * @see AOB_CTRL_InternalPreApplication_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date March 2023
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088,SFP-28318
 */
public without sharing class AOB_CTRL_InternalPreApplication
{
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(AOB_CTRL_InternalPreApplication.class.getName());
	/**
	 * @description Performs a callout to the pre application api
	 *
	 * @param preApplicationId application record Id
	 * @param registrationNumber Business registration number
	 *
	 * @return pre application callout response
	 */
	@AuraEnabled
	public static String preApplicationCallout(String preApplicationId, String registrationNumber)
	{
		String responseDescription = CMN_UTIL_String.EMPTY;
		try
		{
			AOB_API_InternalPreApplication preApplicationCallout = new AOB_API_InternalPreApplication(preApplicationId, registrationNumber);
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_InternalPreApplication.SERVICE_NAME);
			queueItem.CMN_TriggeringObjectId__c = preApplicationId;
			preApplicationCallout.process(queueItem);
			CMN_DAL_SObjectDomain.insertDBObject(queueItem);

			AOB_API_InternalPreApplication.DTO_Response response = (AOB_API_InternalPreApplication.DTO_Response)preApplicationCallout.baseResponseDTO;
			if(preApplicationCallout.getResponseStatusCode() == CMN_API_HttpBase.HTTP_OK
					&& response.preApplicationResponse != null)
			{
				responseDescription = response.preApplicationResponse.orchestrationHeaderResponse.responseStatus?.statusDescription;
			}
			else if(preApplicationCallout.getResponseStatusCode() == AOB_API_StaffAssistedOnboarding.HTTP_GATEWAY_TIMEOUT)
			{
				responseDescription = AOB_API_StaffAssistedOnboarding.ERR_GATEWAY_TIMEOUT;
			}
			else if(preApplicationCallout.callResult.aborted)
			{
				responseDescription = preApplicationCallout.callResult.errors.iterator().next();
			}
			return responseDescription;
		}
		catch(Exception error)
		{
			LOGGER.error(error.getMessage(), new String[] {AOB_CTRL_InternalPreApplication.class.getName(), error.getMessage()}, error);
			throw new AuraHandledException(AOB_Internal_Utils.handleException(error));
		}
	}
}