/**
 * @description Controller class used for retrieving account onboarding navigation settings
 *
 * @see AOB_CTRL_Navigation_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date October 2023
 * @Modification SFP-27854
 */
public without sharing class AOB_CTRL_Navigation
{
	@TestVisible
	private static final String SIGN_HUB_URL = 'AOB_SigningHubLink';
	@TestVisible
	private static final String MY_APPLICATIONS_LIST_VIEW = 'AOB_MyApplicationsListView';

	/**
	 * @description Method to retrieve the sign hub link from custom metadata setting
	 *
	 * @return url string
	 */
	@AuraEnabled
	public static String getSignHubLink()
	{
		String signHubLink = getNavigationSetting(SIGN_HUB_URL)?.AOB_URL__c;
		return String.isNotBlank(signHubLink) ? signHubLink : CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description Method to retrieve the My Applications list view Id from custom metadata setting
	 *
	 * @return string
	 */
	@AuraEnabled
	public static String getMyApplicationsListViewId()
	{
		String listViewId = getNavigationSetting(MY_APPLICATIONS_LIST_VIEW)?.AOB_ListViewId__c;
		return String.isNotBlank(listViewId) ? listViewId : CMN_UTIL_String.EMPTY;
	}
	/**
	 * @description Retrieves navigation settings by developer name
	 * @param developerName setting developer name
	 *
	 * @return AOB_AccountOnboardingNavigationSetting__mdt
	 */
	private static AOB_AccountOnboardingNavigationSetting__mdt getNavigationSetting(String developerName)
	{
		return AOB_AccountOnboardingNavigationSetting__mdt.getInstance(developerName);
	}
}