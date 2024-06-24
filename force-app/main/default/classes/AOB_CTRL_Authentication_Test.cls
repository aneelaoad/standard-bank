/****************************************************************************
* @author       Nakedi Mashapa
* @date         08/03/2023
* @description  Test class for AOB_CTRL_Authentication class that authenticate the Contact.
Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
*
****************************************************************************/

@IsTest
private class AOB_CTRL_Authentication_Test
{

	@TestSetup
	static void setup()
	{
		Account acc = AOB_DAL_TestFactory.createClient();
		AOB_Application__c application = AOB_DAL_TestFactory.createAOBApplication(acc.Id);
		AOB_DAL_TestFactory.createVerification(application, CMN_DAL_SObjectDomain.generateRandomName(), AOB_CTRL_Authentication.AUTHENTICATED, acc.Id);
	}

	@IsTest
	static void testAobCtrlAuthentication()
	{
		AOB_Application__c application =
		[
				SELECT Id
				FROM AOB_Application__c
				LIMIT 1
		];
		Contact con =
		[
				SELECT Id
				FROM Contact
				LIMIT 1
		];
		Verification__c ver = new SEL_Verification().selectByApplication(new Set<Id> {application.Id})[0];
		ver.Contact__c = con.Id;
		update ver;

		Test.startTest();
		AOB_CTRL_Authentication.updateAuthentication(CMN_DAL_SObjectDomain.generateRandomName(), AOB_CTRL_Authentication.AUTHENTICATED, '', application.Id, con.Id);
		Verification__c verification = new SEL_Verification().selectByApplication(new Set<Id> {application.Id})[0];
		Test.stopTest();
		Assert.areEqual(verification.Authentication_Status__c, AOB_CTRL_Authentication.AUTHENTICATED, 'Authentication failed');
	}
	@IsTest
	static void testUpdateSignedContract()
	{
		AOB_Application__c application =
		[
				SELECT Id
				FROM AOB_Application__c
				LIMIT 1
		];
		Contact con =
		[
				SELECT Id
				FROM Contact
				LIMIT 1
		];
		Test.startTest();
		AOB_CTRL_Authentication.updateSignedContract(application.Id, con.Id);
		Verification__c verification = new SEL_Verification().selectByApplication(new Set<Id> {application.Id})[0];
		Test.stopTest();
		Assert.areNotEqual(verification.AOB_Signed__c, System.Label.AOB_Yes, 'Signing failed');
	}

	@IsTest
	static void testGetContactsByApplicationId()
	{
		AOB_Application__c application =
		[
				SELECT Id,
						AOB_Client__c
				FROM AOB_Application__c
				LIMIT 1
		];
		Test.startTest();
		List<Contact> contacts = AOB_CTRL_Authentication.getAllContactsByApplicationId(application.Id);
		Test.stopTest();

		Assert.areEqual(1, contacts.size(), 'more than 1 or less than 1 contacts was return');
	}
	@IsTest
	static void testGetAllContactsToSign()
	{
		AOB_Application__c application =
		[
				SELECT Id,
						AOB_Client__c
				FROM AOB_Application__c
				LIMIT 1
		];
		Test.startTest();
		List<Contact> contacts = AOB_CTRL_Authentication.getAllContactsToSign(application.Id);
		Test.stopTest();

		Assert.areEqual(1, contacts.size(), 'more than 1 or less than 1 contacts was return');
	}

	@IsTest
	static void testGetShareholderStatus()
	{
		Test.startTest();
		AOB_DTO_StaffAssistedOnboarding.DTO_InflightData newInflightData = new AOB_DTO_StaffAssistedOnboarding.DTO_InflightData();
		newInflightData.PreApplication = AOB_DAL_TestFactory.generateApplicationInflightData();

		AOB_Application__c application =
		[
				SELECT Id,
						AOB_inflightData__c,
						AOB_Client__c
				FROM AOB_Application__c
				LIMIT 1
		];
		application.AOB_inflightData__c = JSON.serialize(newInflightData);
		update application;

		String applicantEmail = 'applicant@testing.info';
		Contact mainApplicantContact = SEL_Contacts.newInstance().selectByClientId(new Set<Id> {application.AOB_Client__c})[0];
		mainApplicantContact.Email = applicantEmail;
		mainApplicantContact.Identity_Number__c = newInflightData.PreApplication.IdNum;
		update mainApplicantContact;

		List<AOB_CTRL_Authentication.DTO_Contact> resultContacts = AOB_CTRL_Authentication.getShareholderStatus(application.Id);
		Test.stopTest();

		for(AOB_CTRL_Authentication.DTO_Contact cont : resultContacts)
		{
			if(cont.idNumber == newInflightData.PreApplication.IdNum)
			{
				Assert.areEqual(cont.email, mainApplicantContact.Email, 'Contact email does not match DTO contact email');
				Assert.areEqual(cont.shareholder, AOB_Constants.YES, 'The pre application contact is not the main shareholder');
			}
			else
			{
				Assert.areEqual(cont.shareholder, AOB_Constants.NO, 'all other contacts are not main shareholders');
			}
		}

	}
}