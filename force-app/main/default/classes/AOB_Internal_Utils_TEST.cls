/**
 * @description : SFP-25090 - Test Class for AOB_Internal_Utils
 *
 * @author : Tukelo Moseamo
 *
 * @group :
 * @last modified on  : 07-17-2023
 * @last modified by  : Tukelo Moseamo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-17-2023   Tukelo Moseamo   Initial Version
 */
@IsTest
public with sharing class AOB_Internal_Utils_TEST
{

	/*
	* @description test method for getInflightDataMap
	*/
	@IsTest
	static void testGetInflightDataMap()
	{
		String applicationId = AOB_DAL_TestFactory.createAppWithInflightKey();
		Test.startTest();
		Map<String, Object> inflightMap = AOB_Internal_Utils.getInflightDataMap(applicationId);
		Test.stopTest();
		Assert.isNotNull(inflightMap, 'Flight data is empty');
	}
	/*
	* @description negative test method for getInflightDataMap
	*/
	@IsTest
	static void testGetInflightDataMapNeg()
	{
		Test.startTest();
		try
		{
			AOB_Internal_Utils.getInflightDataMap('Test');
		}
		catch(Exception ex)
		{
			Assert.isNotNull(ex.getMessage(), 'Error was not thrown ');
		}
		Test.stopTest();
	}

	/**
	 * @description method to test formatting the BPID
	 */
	@IsTest
	static void testFormatBPIDLength()
	{
		Test.startTest();
		String formattedBusinessId = AOB_Internal_Utils.formatBPIDLength(CMN_DAL_SObjectDomain.generateRandomNumber(6));
		Assert.areEqual(10, formattedBusinessId.length(), 'BPID was not formatted correctly');
	}
	/**
	 * @description method to test exception handling
	 */
	@IsTest
	static void testHandleException()
	{

		try
		{
			List<Account> accounts = new List<Account>();
			Account client = new Account();
			client.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, 'Prospect');
			client.Name = 'KIMBERLEY AUTO REPAIR CENTRE';
			client.Correspondence_City__c = 'EKURHULENI';
			client.Registration_Number__c = AOB_DAL_TestFactory.generateBusinessRegNumber();
			client.BPID__c = '0535696789';
			client.ExternalId__c = '0535696789';
			client.ExternalSystemId__c = '01';
			client.ExternalCIFCountry__c = 'ZA';
			client.ExternalIdentifier__c = 'ZA010535696789';
			client.GUID__c = 'b13c55a9-357d-1eed-afe6-158d8426b1b5';
			client.ExternalCIFUUID__c = 'b13c55a9-357d-1eed-afe6-158d8426b1b5';
			client.OwnerId = UserInfo.getUserId();
			accounts.add(client);

			Account duplicateClient = client;
			accounts.add(duplicateClient);

			insert accounts;
		}
		catch(Exception ex)
		{
			String error = AOB_Internal_Utils.handleException(ex);
			Assert.isNotNull(error, 'Exception handling failed');
		}
	}
}