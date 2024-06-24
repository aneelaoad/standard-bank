/**
 * @description Provides Query methods related to CMN_WebserviceSetting__mdt Custom Metadata object
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_WebserviceSetting
{
	private static final String TEST_SETTING = 'CMN_API_RestOutboundExample';

	/**
	 * @description This method is use to get the list of metadata
	 *
	 * @param serviceName The web service for which we want to retrieve metadata
	 *
	 * @return relevant service settings
	 */
	public static CMN_WebserviceSetting__mdt getMetadata(String serviceName)
	{
		List<CMN_WebserviceSetting__mdt> settings;

		if(String.isNotBlank(serviceName))
		{
			settings =
			[
					SELECT
							CMN_AddStackTraceToExceptions__c,
							CMN_ApiKey__c,
							CMN_BackoffPeriod__c,
							CMN_Client_Secret__c,
							CMN_ClientID__c,
                			AOB_DefaultChannel__c, 
							CMN_CompanyID__c,
							CMN_MaxRetriesNo__c,
							CMN_NamedCredential__c,
							CMN_Password__c,
							CMN_Path__c,
							CMN_Username__c,
                            AOB_Channel__c,
							AOB_ClientCertificate__c,
							AOB_UserId__c
					FROM
							CMN_WebserviceSetting__mdt
					WHERE DeveloperName = :serviceName
			];
		}

		CMN_WebserviceSetting__mdt setting = settings.isEmpty() ? null : settings[0];

		setting = setting == null && Test.isRunningTest() ? getMetadata(TEST_SETTING) : setting;

		return setting;
	}
}