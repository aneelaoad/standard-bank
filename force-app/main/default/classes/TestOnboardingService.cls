@isTest
private class TestOnboardingService {
	private static String STD_USER_NAME = 'user_test0041@testorg.com';
	private static String CRM_HELPDESK_EMAIL = 'crmhelpdesc@testorg.com';
	private static String GT_REQ_CODE_SBSA = DMN_Account.GT_REQ_CODE_PREFIX+'SBSA';
	private static String GT_MESSAGE_CODE_SA = 'SA';
    
    private static User standardUser {
		get {
			if (standardUser == null) {
				standardUser = [SELECT Id FROM User WHERE UserName = :STD_USER_NAME LIMIT 1];
			}
			return standardUser;
		}
	}
    
	@testsetup static void setupData(){

        User stdUser = (User) new BLD_USER(STD_USER_NAME).useCib().getRecord();
        
        system.runAs(new User(Id = UserInfo.getUserId())){
          insert stdUser;
        }

        system.runAs(stdUser){
			fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

			for (Integer i = 0; i < 2; i++) {
				new BLD_Account(uow)
					.proposedClientCoordinator(stdUser)
					.addContact(
						new BLD_Contact(uow).useClientContact()
					);
			}

			uow.commitWork();
	    }

        List<SFDC2GT_Xml_Stucture__c> xmlStructure = new List<SFDC2GT_Xml_Stucture__c>();

        xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Request',Object_Name__c = '', Field_Name__c = 'Account', Node_Item_Name__c = '', Node_Name__c = 'Request', Default_Value__c='', Order__c = 1, Message_Code__c = GT_MESSAGE_CODE_SA));
        xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Account',Object_Name__c = 'Account', Field_Name__c = '', Node_Item_Name__c = '', Node_Name__c = 'Operation', Default_Value__c='New Customer', Order__c = 5, Message_Code__c = GT_MESSAGE_CODE_SA));
        xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Account.Id',Object_Name__c = 'Account', Field_Name__c = 'Id', Node_Item_Name__c = '', Node_Name__c = 'Salesforce_ID', Default_Value__c='', Order__c = 10, Message_Code__c = GT_MESSAGE_CODE_SA));
        xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Account.Contacts',Object_Name__c = 'Account', Field_Name__c = 'Contacts', Node_Item_Name__c = 'Cust_Contact', Node_Name__c = 'Cust_Contacts', Default_Value__c='', Order__c = 350, Message_Code__c = GT_MESSAGE_CODE_SA));
        xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Contacts.Phone',Object_Name__c = 'Contacts', Field_Name__c = 'Phone', Node_Item_Name__c = '', Node_Name__c = 'Phone_Nume', Default_Value__c='', Order__c = 60, Message_Code__c = GT_MESSAGE_CODE_SA));
		xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Contacts.Account.Id',Object_Name__c = 'Contacts', Field_Name__c = 'Account.Id', Node_Item_Name__c = '', Node_Name__c = 'AccountId', Default_Value__c='', Order__c = 70, Message_Code__c = GT_MESSAGE_CODE_SA));
		xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Account.Custom_Client_Teams__r',Object_Name__c = 'Account', Field_Name__c = 'Custom_Client_Teams__r', Node_Item_Name__c = 'Internal_Contact', Node_Name__c = 'Internal_Contacts', Default_Value__c='', Order__c = 340, Message_Code__c = GT_MESSAGE_CODE_SA));
        xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Team_Member__r.FirstName',Object_Name__c = 'Custom_Client_Teams__r', Field_Name__c = 'Team_Member__r.FirstName', Node_Item_Name__c = '', Node_Name__c = 'First_Name', Default_Value__c='', Order__c = 10, Message_Code__c = GT_MESSAGE_CODE_SA));

        insert xmlStructure;

        List<SB_Parameters__c> clientToGTMessageMapping = new List<SB_Parameters__c>();

        clientToGTMessageMapping.add(new SB_Parameters__c(Name = GT_REQ_CODE_SBSA, Value__c = GT_MESSAGE_CODE_SA));
        insert clientToGTMessageMapping;


	}
	
	@isTest static void testClientOnboardingFailed() {

		String mockBody = '<?xml version="1.0" encoding="UTF-8"?>'	+
				+ 	'<Response>'	+
				+		'<Operation>New Customer</Operation>'	+
				+		'<Success>false</Success>'	+
				+		'<ErrorMessage>Error Message</ErrorMessage>'	+
				+	'</Response>';

		SingleRequestMock singleMock = new SingleRequestMock(200, 'OK',mockBody, null);
		Test.setMock(HttpCalloutMock.class, singleMock);
		Boolean hasErrors = false;

		//User standardUser = [SELECT Id FROM User WHERE username = :username limit 1];
		Account clientForOnboarding = [SELECT Id FROM ACCOUNT LIMIT 1];
		Test.startTest();
		system.runAs(standardUser){
		
			try{
				(new OnboardingService(clientForOnboarding.Id,GT_MESSAGE_CODE_SA)).sendClientsData();
			}catch(OnboardingService.OnboardingServiceException e){
				hasErrors = true;
			}
			System.assertEquals(hasErrors,true);

		}
		Test.stopTest();


	}
	
	@isTest static void testClientOnboardingSucceed() {

		String mockBody = '<?xml version="1.0" encoding="UTF-8"?>'	+
				+ 	'<Response>'	+
				+		'<Operation>New Customer</Operation>'	+
				+		'<Success>true</Success>'	+
				+	'</Response>';
		SingleRequestMock singleMock = new SingleRequestMock(200, 'OK',mockBody, null);
		Test.setMock(HttpCalloutMock.class, singleMock);

		//User standardUser = [SELECT Id FROM User WHERE username = :('%'+username) limit 1];
		Account clientForOnboarding = [SELECT Id FROM ACCOUNT LIMIT 1];
		Boolean hasErrors = false;
		Test.startTest();
		system.runAs(standardUser){
			try{
				(new OnboardingService(clientForOnboarding.Id,GT_MESSAGE_CODE_SA)).sendClientsData();
			}catch(OnboardingService.OnboardingServiceException e){
				hasErrors = true;
			}
			System.assertEquals(hasErrors,false);
		}
		Test.stopTest();
	}

	@isTest static void testReaquestFailed() {
		
		SingleRequestMock singleMock = new SingleRequestMock(500, 'Internal Server Error','', null);
		Test.setMock(HttpCalloutMock.class, singleMock);
		
		//User standardUser = [SELECT Id FROM User WHERE username = :username limit 1];
		Account clientForOnboarding = [SELECT Id FROM ACCOUNT LIMIT 1];
		Boolean hasErrors = false;
		Test.startTest();
		system.runAs(standardUser){
		
			try{
				(new OnboardingService(clientForOnboarding.Id,GT_MESSAGE_CODE_SA)).sendClientsData();
			}catch(OnboardingService.OnboardingServiceException e){
				hasErrors = true;
			}
			System.assertEquals(hasErrors,true);

		}
		Test.stopTest();

	}

	@isTest static void testBadResponse() {

		String mockBody = '<?xml version="1.0" encoding="UTF-8"?>'	+
				+ 	'<Response>'	+
				+		'<Operation>New Customer</Operation>'	+
				+		'<Succes>true</Succes>'	+
				+	'</Response>';
		SingleRequestMock singleMock = new SingleRequestMock(200, 'OK',mockBody, null);
		Test.setMock(HttpCalloutMock.class, singleMock);

		//User standardUser = [SELECT Id FROM User WHERE username = :('%'+username) limit 1];
		Account clientForOnboarding = [SELECT Id FROM ACCOUNT LIMIT 1];
		Boolean hasErrors = false;
		Test.startTest();
		system.runAs(standardUser){
			try{
				(new OnboardingService(clientForOnboarding.Id,GT_MESSAGE_CODE_SA)).sendClientsData();
			}catch(OnboardingService.OnboardingServiceException e){
				hasErrors = true;
			}
			System.assertEquals(hasErrors,true);
		}
		Test.stopTest();
	}

	@isTest static void testNonExistingAccountIdsField() {

		SFDC2GT_Xml_Stucture__c xmlStructureItem = new SFDC2GT_Xml_Stucture__c(
			Name = 'Account.Ids',Object_Name__c = 'Account', Field_Name__c = 'Ids',
			 Node_Item_Name__c = '', Node_Name__c = 'AccountIds', Default_Value__c='', Order__c = 7, Message_Code__c = GT_MESSAGE_CODE_SA);
		
		insert xmlStructureItem;

		//User standardUser = [SELECT Id FROM User WHERE username = :('%'+username) limit 1];
		Account clientForOnboarding = [SELECT Id FROM ACCOUNT LIMIT 1];
		Boolean hasErrors = false;
		Test.startTest();
		system.runAs(standardUser){
			try{
				(new OnboardingService(clientForOnboarding.Id,GT_MESSAGE_CODE_SA)).sendClientsData();
			}catch(OnboardingService.OnboardingServiceException e){
				hasErrors = true;
			}
			System.assertEquals(hasErrors,true);
		}
		Test.stopTest();
	}

	@isTest static void testKYCContactAttached() {
		
		Account[] clients = [SELECT Id, (SELECT Id FROM Contacts) FROM ACCOUNT LIMIT 2];
		Account clientForOnboarding = clients[0];
		clientForOnboarding.KYC_Contact__c = clients[1].Contacts[0].Id;
		update clientForOnboarding;

	    String mockBody = '<?xml version="1.0" encoding="UTF-8"?>'	+
				+ 	'<Response>'	+
				+		'<Operation>New Customer</Operation>'	+
				+		'<Success>true</Success>'	+
				+	'</Response>';
		SingleRequestMock singleMock = new SingleRequestMock(200, 'OK',mockBody, null);
		Test.setMock(HttpCalloutMock.class, singleMock);

		Boolean hasErrors = false;
		OnboardingService os;
		Test.startTest();
		system.runAs(standardUser){
			try{
				os = new OnboardingService(clientForOnboarding.Id,GT_MESSAGE_CODE_SA);
				os.sendClientsData();
			}catch(OnboardingService.OnboardingServiceException e){
				hasErrors = true;
			}
			
		}
		Test.stopTest();

		List<Contact> kycConatcts = os.getClientData().getRelatedRecords().get('Contacts');
		System.assertEquals(kycConatcts.size(),2);
		System.assertEquals(hasErrors,false);
	}

	@isTest static void shouldNotSendEmailDueToLackOfData(){
		Id clientId;
		Test.startTest();

		system.runAs(standardUser){
			(new OnboardingService(clientId,GT_MESSAGE_CODE_SA)).sendCalloutExceptionEmail();
			System.assertEquals(0,Limits.getEmailInvocations());

			clientId = [SELECT Id FROM ACCOUNT LIMIT 1].Id;

			(new OnboardingService(clientId,GT_MESSAGE_CODE_SA)).sendCalloutExceptionEmail();
			System.assertEquals(0,Limits.getEmailInvocations());

		}

		Test.stopTest();
		
	}

	@isTest static void shouldSendEmail(){
		Id clientId = [SELECT Id FROM ACCOUNT LIMIT 1].Id;
		SB_Parameters__c crmHelpdeskEmail = new SB_Parameters__c(Name=OnboardingService.CRM_HELPDESK_PARAMETER_NAME, Value__c = CRM_HELPDESK_EMAIL);
		insert crmHelpdeskEmail;

		Test.startTest();

		system.runAs(standardUser){
			(new OnboardingService(clientId,GT_MESSAGE_CODE_SA)).sendCalloutExceptionEmail();
		}
		
		System.assertEquals(1,Limits.getEmailInvocations());
		Test.stopTest();
	}
	
}