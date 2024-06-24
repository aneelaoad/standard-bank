/**
 * @description SFP-33456: Controller class used for retrieving account onboarding application settings
 *
 * @see AOB_CTRL_ApplicationSettings_TEST
 *
 * @author Mahlatse Tjale
 *
 * @date 13 November 2023
 */
public without sharing class AOB_CTRL_ApplicationSettings
{
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CTRL_ApplicationSettings');
	/**
	 * @description get a map of application settings
	 *
	 * @param teams List of teams
	 *
	 * @return Map<String, String>
	 *
	 * @author Mahlatse Tjale | 11-13-2023
	 */
	@AuraEnabled(cacheable=true)
	public static Map<String, String> getApplicationSettings(List<String> teams)
	{
		Map<String, String> filteredAppSettings = new Map<String, String>();
		try
		{
			Map<String, AOB_AccountOnboardingApplicationSetting__mdt> allAppSettings = AOB_AccountOnboardingApplicationSetting__mdt.getAll();
			for(String key : allAppSettings.keySet())
			{
				AOB_AccountOnboardingApplicationSetting__mdt value = allAppSettings.get(key);
				if(value != null && value.AOB_Team__c != null && teams.contains(value.AOB_Team__c))
				{
					filteredAppSettings.put(key, value.AOB_Description__c);
				}
			}

		}
		catch(Exception ex)
		{
			LOGGER.error(ex.getMessage(), new String[] {'An error occurred at: AOB_CTRL_ApplicationSettings', ex.getMessage()}, ex);
			throw new AuraHandledException(ex.getMessage());
		}
		return filteredAppSettings;
	}

}