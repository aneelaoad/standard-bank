/**
 * @description : Application settings controller unit test class
 *
 * @author : Sibonelo Ngcobo
 * @see AOB_CTRL_ApplicationSettings
 * @last modified on  : 12-01-2023
 * @last modified by  : Mahlatse Tjale
 * Modifications Log
 * Ver   Date         Author            Modification : SFP-33456
 * 1.0   12-01-2023   Sibonelo Ngcobo   Initial Version
 */
@IsTest
public class AOB_CTRL_ApplicationSettings_TEST
{
	/**
	 * @description Test get application settings
	 */
	@IsTest
	static void testGetApplicationSettings()
	{
		List<String> teams = new List<String> {AOB_Internal_Constants.SELF_ASSIST, AOB_Internal_Constants.STAFF_ASSIST};
		Test.startTest();
		Map<String, String> result = AOB_CTRL_ApplicationSettings.getApplicationSettings(teams);
		Test.stopTest();
		Assert.isTrue(result.size() > 0, 'Custom metadata records not found');
	}

	/**
	 * @description Test get application settings exception
	 */
	@IsTest
	static void testGetApplicationSettingsException()
	{
		Test.startTest();
		try
		{
			AOB_CTRL_ApplicationSettings.getApplicationSettings(null);
		}
		catch(Exception ex)
		{
			Assert.areEqual('Script-thrown exception',ex.getMessage(), 'Exception was not thrown');
		}
		Test.stopTest();
	}
}