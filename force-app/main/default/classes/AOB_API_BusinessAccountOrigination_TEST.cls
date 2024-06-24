/**
 * @description Business account origination outbound webservice API test class
 *
 * @see AOB_API_BusinessAccountOrigination
 *
 * @author Mthobisi Ndlovu
 *
 * @date March 2023
 * 
 * @Modification Description : SFP-25088
 * 
 */
@IsTest
private class AOB_API_BusinessAccountOrigination_TEST
{
	/**
	 * @description sets up test data
	 */
	@TestSetup
	static void testSetup()
	{
		AOB_DTO_StaffAssistedOnboarding.DTO_InflightData newInflightData = new AOB_DTO_StaffAssistedOnboarding.DTO_InflightData();
		newInflightData.preApplicationResponse = AOB_DAL_TestFactory.generatePreApplicationResponse();
		newInflightData.PreApplication = AOB_DAL_TestFactory.generateApplicationInflightData();

		AOB_Application__c application = new AOB_Application__c();
		application.AOB_ExpiryDate__c = System.today().addDays(30);
		application.AOB_inflightData__c = JSON.serialize(newInflightData);
		application.AOB_Status__c = AOB_Constants.IN_PROGRESS;
		application.Name = CMN_DAL_SObjectDomain.generateRandomName();
		insert application;

		Product2 product = AOB_DAL_TestFactory.createProduct(newInflightData.PreApplication.appName, newInflightData.PreApplication.productNumber);
		AOB_DAL_TestFactory.createApplicationLineItem(product.Id, application.Id);
	}
	/**
	 * @description Method tests the account origination callout
	 */
	@IsTest
	static void testBusinessAccountOriginationCallout()
	{

		Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
		AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();

		Test.startTest();
		AOB_API_BusinessAccountOrigination businessAccountOriginationCallout = new AOB_API_BusinessAccountOrigination();
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_BusinessAccountOrigination.SERVICE_NAME);
		queueItem.CMN_TriggeringObjectId__c = application.Id;
		businessAccountOriginationCallout.process(queueItem);
		insert queueItem;

		Test.stopTest();
		Assert.isNotNull(businessAccountOriginationCallout.callResult.responseBody, 'business account origination callout response is null');
		String response = businessAccountOriginationCallout.callResult.responseBody;
		Map<String, Object> inflightDataMap = (Map<String, Object>)JSON.deserializeUntyped(response);

		AOB_API_BusinessAccountOrigination.DTO_BusinessAOResponse businessAOResponse =
				(AOB_API_BusinessAccountOrigination.DTO_BusinessAOResponse)JSON.deserialize(
						JSON.serialize(inflightDataMap.get(AOB_DTO_BusinessAccountOrigination.BUSINESS_ORIGINATION_RESPONSE)),
						AOB_API_BusinessAccountOrigination.DTO_BusinessAOResponse.class);
		Assert.isInstanceOfType(businessAOResponse, AOB_API_BusinessAccountOrigination.DTO_BusinessAOResponse.class, 'Incorrect instance class');
	}
}