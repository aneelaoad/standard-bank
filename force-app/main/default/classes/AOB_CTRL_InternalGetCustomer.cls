/**
 * @description Get customer API controller class
 *
 * @see AOB_CTRL_InternalGetCustomer_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date June 2023
 * * Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */
public with sharing class AOB_CTRL_InternalGetCustomer
{
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(AOB_CTRL_InternalGetCustomer.class.getName());
	/**
	 * @description Performs a callout to the pre application api
	 *
	 * @param preApplicationId application record Id
	 *
	 * @return pre application callout response
	 */
	@AuraEnabled
	public static String getCustomerCallout(String preApplicationId)
	{

		String responseDescription;
		try
		{
			AOB_API_GetCustomerByUUID digitalOfferCallout = new AOB_API_GetCustomerByUUID();
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_GetCustomerByUUID.SERVICE_NAME);
			queueItem.CMN_TriggeringObjectId__c = preApplicationId;
			digitalOfferCallout.process(queueItem);
			CMN_DAL_SObjectDomain.insertDBObject(queueItem);

			if(digitalOfferCallout.getResponseStatusCode() == CMN_API_HttpBase.HTTP_OK)
			{
				responseDescription = AOB_API_StaffAssistedOnboarding.SUCCESSFUL;
			}
			else
			{
				responseDescription = digitalOfferCallout.callResult.aborted ? digitalOfferCallout.callResult.errors.iterator().next() :
						digitalOfferCallout.callResult.responseBody;
			}

			return responseDescription;
		}
		catch(Exception ex)
		{
			LOGGER.error(ex.getMessage(), new String[]
			{AOB_API_GetCustomerByUUID.class.getName(), ex.getMessage()}, ex);
			throw new AuraHandledException(ex.getMessage());
		}
	}

}