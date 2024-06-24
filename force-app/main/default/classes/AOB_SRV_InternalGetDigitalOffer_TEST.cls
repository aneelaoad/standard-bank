/**
 * @description:SFP-25090 - Get digital offer service test class
 *
 * @see AOB_SRV_InternalGetDigitalOffer
 *
 * @author Mthobisi Ndlovu
 *
 * @date May 2023
 */
@IsTest
private class AOB_SRV_InternalGetDigitalOffer_TEST
{

	/**
	 * @description Method test the get digital offer callout
	 */
	@IsTest
	public static void testGetDigitalOfferCallout()
	{
		Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());

		String applicationId = AOB_DAL_TestFactory.createAppWithInflightKey();
		AOB_Application__c application = new AOB_Application__c(Id = applicationId);
		application.AOB_SalesObjectId__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		update application;

		Test.startTest();
		String response = AOB_SRV_InternalGetDigitalOffer.digitalOfferCallout(applicationId);
		Test.stopTest();
		Assert.areEqual(String.valueOf(CMN_API_HttpBase.HTTP_OK),response ,'callout was not successful');
	}

	/**
	 * @description This method tests the exception handling
	 */
	@IsTest
	static void testException()
	{
		try
		{
			AOB_SRV_InternalGetDigitalOffer.digitalOfferCallout(CMN_DAL_SObjectDomain.generateRandomEmail());
		}
		catch(Exception ex)
		{
			Assert.isNotNull(ex.getMessage(),'Exception was not thrown');
		}
	}
}