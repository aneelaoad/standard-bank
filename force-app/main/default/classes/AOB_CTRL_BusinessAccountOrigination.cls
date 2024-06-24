/**
 * @description Business account origination controller class
 *
 * @see AOB_CTRL_BusinessAccountOrigination_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date April 2023
 * * Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */
public with sharing class AOB_CTRL_BusinessAccountOrigination
{
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(AOB_CTRL_BusinessAccountOrigination.class.getName());
	/**
	 * @description Performs a callout to the business account origination api
	 *
	 * @param applicationId application record Id
	 *
	 * @return string
	 */
	@AuraEnabled
	public static String businessAccOriginationCallout(String applicationId)
	{
		String responseDescription = CMN_UTIL_String.EMPTY;
		try
		{
			AOB_API_BusinessAccountOrigination businessAccOriginationCallout = new AOB_API_BusinessAccountOrigination();
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_BusinessAccountOrigination.SERVICE_NAME);
			queueItem.CMN_TriggeringObjectId__c = applicationId;
			businessAccOriginationCallout.process(queueItem);
			CMN_DAL_SObjectDomain.insertDBObject(queueItem);

			AOB_API_BusinessAccountOrigination.DTO_Response response = (AOB_API_BusinessAccountOrigination.DTO_Response)businessAccOriginationCallout.baseResponseDTO;
			if(businessAccOriginationCallout.callResult.statusCode == String.valueOf(CMN_API_HttpBase.HTTP_OK)
					&& response.businessAOResponse != null)
			{
				responseDescription = response.businessAOResponse.orchestrationHeaderResponse.responseStatus?.statusDescription;
			}
			else
			{
				responseDescription =
						businessAccOriginationCallout.callResult.aborted ? businessAccOriginationCallout.callResult.errors.iterator().next() : AOB_DTO_StaffAssistedOnboarding.UNSUCCESSFUL_CALLOUT_ERROR;
			}
			return responseDescription;
		}
		catch(Exception error)
		{
			LOGGER.error(error.getMessage(), new String[]
			{
					AOB_API_BusinessAccountOrigination.SERVICE_NAME, error.getMessage()
			}, error);
			throw new AuraHandledException(error.getMessage());
		}
	}

}