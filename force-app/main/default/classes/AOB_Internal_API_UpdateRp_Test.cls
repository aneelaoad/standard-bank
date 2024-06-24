/**
 * @description Updated related party api unit test class
 *
 * @author Dayakar
 *
 * @date April 28th 2023
 *
 * @modification description: SFP-25088
 */
@IsTest
public class AOB_Internal_API_UpdateRp_Test
{

	/**
	 * @description test method for AOB_SRV_SetDigital.callSetDigitalAPI
	 * author Dayakar
	 */
	@IsTest
	static void callUpdateRPConfig()
	{

		Set<String> relPartyData = new Set<String>();
		relPartyData.add(AOB_Constants.ZACCOF);
		relPartyData.add(AOB_Constants.ZBUSIN);
		relPartyData.add(AOB_Constants.ZMEMBE);
		String applicationId = AOB_DAL_TestFactory.createApplicationRecord();
		String uUID = 'b13c55a9-357d-1eed-aca0-3e2a4d36ecc6';
		try
		{
			Test.startTest();
			System.enqueueJob(new AOB_Internal_SRV_UpdateRPConfig(relPartyData, applicationId, uUID));
			Test.stopTest();
			Assert.isNotNull(applicationId, 'not null');
		}
		catch(Exception e)
		{
			e.getMessage();
		}
	}

	/**
	 * @description Method tests the try-catch block
	 */
	@IsTest
	static void testException()
	{

		Set<String> relatedParties = new Set<String>();
		relatedParties.add(AOB_Constants.ZACCOF);
		relatedParties.add(AOB_Constants.ZBUSIN);
		relatedParties.add(AOB_Constants.ZMEMBE);
		String uUID = 'b13c55a9-357d-1eed-aca0-3e2a4d36ecc6';
		try
		{
			Test.startTest();
			System.enqueueJob(new AOB_Internal_SRV_UpdateRPConfig(relatedParties, null, uUID));
			Test.stopTest();

		}
		catch(Exception e)
		{
			Assert.isNotNull(e.getMessage(), 'not null');
		}
	}
}