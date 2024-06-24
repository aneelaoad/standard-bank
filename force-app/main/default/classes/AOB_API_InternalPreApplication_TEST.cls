/**
 * @description Pre Application outbound webservice API test class
 *
 * @see AOB_API_InternalPreApplication
 *
 * @author Mthobisi Ndlovu
 *
 * @date March 2023
 * 
 * @Modification Description : SFP-25088
 */
@IsTest
private class AOB_API_InternalPreApplication_TEST
{

	/**
	 * @description test the pre application callout
	 */
	@IsTest
	static void testPreApplicationCallout()
	{
		Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());

		AOB_DTO_StaffAssistedOnboarding.DTO_InflightData newInflightData = new AOB_DTO_StaffAssistedOnboarding.DTO_InflightData();
		newInflightData.PreApplication = AOB_DAL_TestFactory.generateApplicationInflightData();

		AOB_Application__c application = new AOB_Application__c();
		application.AOB_ExpiryDate__c = System.today().addDays(7);
		application.AOB_inflightData__c = JSON.serialize(newInflightData);
		application.AOB_Status__c = AOB_Constants.IN_PROGRESS;
		application.Name = CMN_DAL_SObjectDomain.generateRandomName();
		insert application;

		Product2 product = AOB_DAL_TestFactory.createProduct(newInflightData.PreApplication.appName, newInflightData.PreApplication.productNumber);

		AOB_DAL_TestFactory.createApplicationLineItem(product.Id, application.Id);

		Test.startTest();
		AOB_API_InternalPreApplication preApplicationCallout = new AOB_API_InternalPreApplication(application.Id, AOB_DAL_TestFactory.generateBusinessRegNumber());
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_InternalPreApplication.SERVICE_NAME, application.Id);
		preApplicationCallout.process(queueItem);
		insert queueItem;

		Test.stopTest();
		Assert.isNotNull(preApplicationCallout.callResult.responseBody, 'pre application callout response is null');

		AOB_API_InternalPreApplication.DTO_Response response = (AOB_API_InternalPreApplication.DTO_Response)preApplicationCallout.baseResponseDTO;
		AOB_DTO_StaffAOResponse.DTO_BusinessDetail businessDetail = response.preApplicationResponse?.cipcRegisteredDetails?.businessDetails;

		List<Account> clients = new SEL_Accounts().selectWithoutCondition();
		Account client = clients.size() > 0 ? clients.iterator().next() : null;
		Assert.areEqual(client.BPID__c, businessDetail.businessBPID, 'Client record was not updated');

		AOB_Application__c updatedApplication = new SEL_AOBApplication().selectWithoutCondition()?.iterator().next();
		Assert.areEqual(client.Id, updatedApplication.AOB_Client__c, 'Application not update with data from the API response');

		List<Contact> directors = new SEL_Contacts().selectWithoutCondition(10);
		Assert.isNotNull(directors, 'Director records were not created via the api response ');

		Map<Id, Contact> directorByClientIdMap = new Map<Id, Contact>();
		for(Contact director : directors)
		{
			Assert.areEqual(director.AccountId, client.Id, 'Contact not related to client record');
			directorByClientIdMap.put(director.AccountId, director);
		}

		List<CMN_Account_Contact_Relationship_Detail__c> relationshipDetails = new SEL_CMN_AccountContactRelationshipDetail().selectByAccountIds(new Set<Id> {client.Id});
		Assert.isNotNull(relationshipDetails, 'Client director relationship records were not created via api response');

		for(CMN_Account_Contact_Relationship_Detail__c relationshipDetail : relationshipDetails)
		{
			Assert.areEqual(relationshipDetail.Contact__c, directorByClientIdMap.get(client.Id).Id, 'Match not found for client and director relationship');
		}

	}

	/**
	 * @description This method tests an aborted pre application callout
	 */
	@IsTest
	static void testNullInflightData()
	{
		AOB_Application__c application = new AOB_Application__c();
		application.AOB_ExpiryDate__c = System.today().addDays(7);
		application.AOB_inflightData__c = null;
		application.AOB_Status__c = AOB_Constants.IN_PROGRESS;
		application.Name = CMN_DAL_SObjectDomain.generateRandomName();
		CMN_DAL_SObjectDomain.insertDBObject(application);
		Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());

		Test.startTest();
		String response = AOB_CTRL_InternalPreApplication.preApplicationCallout(application.Id, AOB_DAL_TestFactory.generateBusinessRegNumber());
		Test.stopTest();
		Assert.areEqual(AOB_API_StaffAssistedOnboarding.ERROR_INFLIGHT_DATA_NOT_FOUND, response, 'Inflight Data field is not null');
	}

}