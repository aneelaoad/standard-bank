/**
 * @description : SFP-25090 - Service class for digital offer Specific logic
 *
 * @author : Tukelo Moseamo (inherited from self)
 *
 * @group : StandardBank BCC
 * @last modified on  : 07-17-2023
 * @last modified by  : Tukelo Moseamo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   05-10-2023   Tukelo Moseamo   Initial Version
 */
public inherited sharing class AOB_Internal_SRV_SetDigital
{

	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_Internal_SRV_SetDigital');

	/**
	 * @description service method used to call setDigital API
	 *
	 * @param applicationId application Id
	 *
	 * @return Integer status code
	 */
	@AuraEnabled
	public static Integer callStaffAssistSetDigitalAPI(String applicationId)
	{
		try
		{
			AOB_Internal_API_SetDigital customerServiceCall = new AOB_Internal_API_SetDigital(applicationId);
			CMN_WebserviceCallQueue__c calloutQueue = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_Internal_API_SetDigital.SERVICE_NAME);
			calloutQueue.CMN_TriggeringObjectId__c = applicationId;
			customerServiceCall.process(calloutQueue);
			insert calloutQueue;

			if(customerServiceCall.getResponseStatusCode() == 200)
			{
				List<AOB_Application__c> aobApplication = new SEL_AOBApplication().selectAppsById(applicationId);
				aobApplication[0].AOB_Retry_Count__c = 0;
				update aobApplication;
			}
			return customerServiceCall.getResponseStatusCode();
		}
		catch(Exception ex)
		{
			LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_SRV_SetDigital', ex.getMessage()}, ex);
			throw new AuraHandledException(ex.getMessage());
		}
	}
}