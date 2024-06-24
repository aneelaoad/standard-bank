/**
 * @description : SFP-25090 - Utility class for staff assisted digital AO
 *
 * @author : Tukelo Moseamo
 *
 * @group :
 * @last modified on  : 08-21-2023
 * @last modified by  : Tukelo Moseamo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-17-2023   Tukelo Moseamo   Initial Version
 */
public class AOB_Internal_Utils
{

	/**
	 * @description gets inflight data as a map
	 *
	 * @param applicationId
	 *
	 * @return Map<String, Object>
	 *
	 * @author Tukelo Moseamo | 07-12-2023
	 */
	public static Map<String, Object> getInflightDataMap(String applicationId)
	{

		List<AOB_Application__c> applications = new SEL_AOBApplication().selectAppsById(applicationId);
		if(applications.size() == 0)
		{
			throw new AuraHandledException(AOB_API_StaffAssistedOnboarding.ERROR_APPLICATION_NOT_FOUND);
		}
		AOB_Application__c application = applications.iterator()?.next();
		String inflightData = application.AOB_inflightData__c.contains(AOB_API_StaffAssistedOnboarding.NON_BREAK_SPACE) ? application.AOB_inflightData__c.replace(AOB_API_StaffAssistedOnboarding.NON_BREAK_SPACE, CMN_UTIL_String.EMPTY)
				: application.AOB_inflightData__c;

		return (Map<String, Object>)JSON.deserializeUntyped(inflightData);
	}


	/**
	 * @description Used to process any errors that occurred
	 *
	 * @param error The exception that should be handled
	 *
	 * @return error message
	 */
	public static String handleException(Exception error)
	{
		String errorMessage;
		if(error instanceof DmlException)
		{
			DmlException dmlException = (DmlException)error;
			errorMessage = dmlException.getMessage();
		}
		else
		{
			errorMessage = error.getMessage();
		}
		return errorMessage;
	}

	/**
	 * @description Method to format the BPID to a 10 character string
	 * 				by pre-fixing it with 0's if it is less then 10 characters long
	 *
	 * @param businessProcessId - business process ID to be formatted
	 *
	 * @return 10 digit BPID
	 */
	public static String formatBPIDLength(String businessProcessId)
	{
		while(businessProcessId.length() < 10)
		{
			businessProcessId = '0' + businessProcessId;
		}
		return businessProcessId;
	}
}