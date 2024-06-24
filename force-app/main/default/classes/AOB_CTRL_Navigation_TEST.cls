/**
 * @description controller test class
 *
 * @see AOB_CTRL_Navigation
 *
 * @author Mthobisi Ndlovu
 *
 * @date October 2023
 *
 * @Modification Description :SFP-27854
 */
@IsTest
private class AOB_CTRL_Navigation_TEST
{
	@IsTest
	static void testGetSignHubLink()
	{
		Test.startTest();
		String signHubLink = AOB_CTRL_Navigation.getSignHubLink();
		Assert.areNotEqual(signHubLink, CMN_UTIL_String.EMPTY, 'Sign hub link was not generated');
		Test.stopTest();
	}

	@IsTest
	static void testListViewRedirection()
	{
		Test.startTest();
		String listViewId = AOB_CTRL_Navigation.getMyApplicationsListViewId();
		Assert.areNotEqual(listViewId, CMN_UTIL_String.EMPTY, 'List view Id is empty');
		Test.stopTest();
	}
}