/**
 * @description Controller class used to call the Update Customer API callout
 *
 * @see AOB_CTRL_UpdateCustomer_TEST
 *
 * @author Mthobisi Ndlovu(mthobisi.ndlovu@standardbank.co.za)
 *
 * @date June 2023
 * * Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */
public with sharing class AOB_CTRL_UpdateCustomer
{

	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(AOB_CTRL_UpdateCustomer.class.getName());

	/**
	 * @description Method used to invoke the update customer API
	 * @param applicationId application record Id
	 *
	 * @return 'Successful' or an error message
	 */
	@AuraEnabled
	public static String updateCustomerCallout(String applicationId)
	{
		String calloutResponse = CMN_UTIL_String.EMPTY;
		try
		{
			AOB_API_UpdateCustomer callout = new AOB_API_UpdateCustomer();
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_UpdateCustomer.SERVICE_NAME);
			queueItem.CMN_TriggeringObjectId__c = applicationId;
			callout.process(queueItem);
			CMN_DAL_SObjectDomain.insertDBObject(queueItem);

			AOB_API_UpdateCustomer.DTO_Response response = (AOB_API_UpdateCustomer.DTO_Response)callout.baseResponseDTO;
			if(callout.getResponseStatusCode() == CMN_API_HttpBase.HTTP_OK
					&& response.triggerUpdateCustomerResponse.maintenanceOfferSuccess)
			{
				calloutResponse = response.triggerUpdateCustomerResponse.orchestrationHeaderResponse?.responseStatus?.statusDescription;
			}
			else if(callout.getResponseStatusCode() == CMN_API_HttpBase.HTTP_OK
					&& !response.triggerUpdateCustomerResponse.maintenanceOfferSuccess)
			{
				calloutResponse = response.triggerUpdateCustomerResponse.orchestrationHeaderResponse?.errorResponse[0]?.responseMessage;
			}
			else
			{
				calloutResponse = callout.callResult.aborted ? callout.callResult.errors.iterator().next() : AOB_API_StaffAssistedOnboarding.UNSUCCESSFUL_CALLOUT_ERROR;
			}

			return calloutResponse;
		}
		catch(Exception error)
		{
			LOGGER.error(error.getMessage(), new String[] {AOB_API_UpdateCustomer.class.getName(), error.getMessage()}, error);
			throw new AuraHandledException(error.getMessage());
		}

	}
}