/**
 * @description: SFP-25090 - Class used to perform an API call to Get Digital API
 *
 * @author Mthobisi Ndlovu
 *
 * @date May 2023
 */
public with sharing class AOB_SRV_InternalGetDigitalOffer
{
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(AOB_SRV_InternalGetDigitalOffer.class.getName());

	/**
	 * @description Makes a callout to the get digital offer API
	 *
	 * @param applicationId Application record Id
	 *
	 * @return response code string
	 */
	@AuraEnabled
	public static String digitalOfferCallout(String applicationId)
	{
		String response = CMN_UTIL_String.EMPTY;
		try
		{
			AOB_API_InternalGetDigitalOffer digitalOfferCallout = new AOB_API_InternalGetDigitalOffer();
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_InternalGetDigitalOffer.SERVICE_NAME);
			queueItem.CMN_TriggeringObjectId__c = applicationId;
			digitalOfferCallout.process(queueItem);
			CMN_DAL_SObjectDomain.insertDBObject(queueItem);
			response = digitalOfferCallout.callResult.statusCode;
		}
		catch(Exception error)
		{
			LOGGER.error(error.getMessage(), new String[] { AOB_API_InternalGetDigitalOffer.SERVICE_NAME, error.getMessage()}, error);
		}
		return response;
	}
}