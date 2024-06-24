/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
*
* Test Class for AOB_ClientResource class.
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Caro Reinecke
* @version        1.0
* @created        2018/09/25
* @systemLayer    Test ( Choose from: Invocation | Service | Utility | Selector | Domain | Test )
*
* Scenarios:
* Get: (Search for a Client)
* based on Registration Number - Find 0; 1; >1
* based on Registered Name - Find 0; 1; >1
*
* Post: (Submit new Entity)
* not found in salesforce - new onboarding request
* found in salesforce - new CIB / commB migration request
* found in salesforce - new hierarchy change request (CIB / commB)
* exception handling
* @description Test class for AOB_ClientResource
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@IsTest
private class AOB_ClientResource_Test {

    private static final String
            GT_MESSAGE_CODE_SA      = 'SA',
            API_USER_NAME           = 'h5enimmarrifi-1815@yopmail.com',
            CC_CIB_USER_NAME        = 'h6enimmarrifi-1816@yopmail.com',
            TB_CIB_USER_NAME        = 'h7enimmarrifi-1817@yopmail.com',
            CC_CIB_CHILD_USER_NAME  = 'h8enimmarrifi-1816@yopmail.com',
            TB_CIB_CHILD_USER_NAME  = 'h9enimmarrifi-1817@yopmail.com',
            CC_COMMB_USER_NAME      = 'h0enimmarrifi-1817@yopmail.com',
            DEF_ACC_NAME            = 'Def Name for CIB Acc',
            PARENT_DEF_ACC_NAME     = 'Def Name for CIB Parent Acc',
            CIF_NUMBER              = '654321',
            PARENT_CIF_NUMBER       = '654322',
            CHILD_CIF_NUMBER        = '524634',
            CHILD_BP_NUMBER         = '500195884',
            PARENT_BP_NUMBER        = '600195884',
            PARENT_COMMB_NAME       = 'Def Name for CommB Parent',
            CHILD_COMMB_NAME        = 'Def Name for CommB Child',
            CHILD_ACC_NAME          = 'Def Name for CIB Child';

    @TestVisible
    private static User
            sysAdmin
            ,topParentTB
            ,topParentCC
            ,topParentCommB
            ,childTB
            ,childCC;

    private static ABS_ObjectBuilderBase
            topParentTBM,
            topParentCCM;

    @TestVisible
    private static User aobUser {
        get {
            if (aobUser == null) {
            aobUser = [SELECT Id FROM User WHERE UserName = :API_USER_NAME];
            }
            return aobUser;
        }
    }

    @TestSetup
    static void prepareData() {

        TEST_DataFactory.generateConfiguration();
        // SysAdmin
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            sysAdmin = (User) new BLD_USER(uow).useSysAdmin().syncContact().getRecord();
            topParentCC = (User) new BLD_USER(uow).userName(CC_CIB_USER_NAME).useCib().syncContact().getRecord();
            topParentTB = (user) new BLD_USER(uow).userName(TB_CIB_USER_NAME).useCib().syncContact().getRecord();
            childCC = (User) new BLD_USER(uow).userName(CC_CIB_CHILD_USER_NAME).useCib().syncContact().getRecord();
            childTB = (user) new BLD_USER(uow).userName(TB_CIB_CHILD_USER_NAME).useCib().syncContact().getRecord();
            topParentCommB = (User) new BLD_USER(uow).userName(CC_COMMB_USER_NAME).useCommB().syncContact().getRecord();
            aobUser = (User) new BLD_USER(uow).userName(API_USER_NAME).useAPIUser().getRecord();
            uow.commitWork();

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

        }

        System.runAs(topParentCC) {

            //fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            BLD_Account existingDifferentTopParentCIBAccount =  (BLD_Account) new BLD_Account(uow)
                    .name(PARENT_DEF_ACC_NAME)
                    .CIF(PARENT_CIF_NUMBER)
                    .useCib()
                    .useGroupParent()
                    .setField(Account.CIF_Client_Active_Code__c,'Active')
                    .setField(Account.CRT_Parent_Child__c,'TP')
                    .setField(Account.Onboarded_in_SFDC__c,true)
                    .setField(Account.OwnerId, topParentCC.Id)
                    .setField(Account.BillingCountry, 'South Africa')
                    .setField(Account.Industry_Code__c,'65990')
                    .setField(Account.Primary_Relationship_Holder__c, 'Corporate and Investment Banking')
                    .setField(Account.CIF_Client_Type__c, 'W');

            BLD_Account existingTopParentCIBAccount =  (BLD_Account) new BLD_Account(uow)
                    .name(DEF_ACC_NAME)
                    .CIF(CIF_NUMBER)
                    .useCib()
                    .useGroupParent()
                    .setField(Account.CIF_Client_Active_Code__c,'Active')
                    .setField(Account.CRT_Parent_Child__c,'TP')
                    .setField(Account.Onboarded_in_SFDC__c,true)
                    .setField(Account.OwnerId, topParentCC.Id)
                    .setField(Account.BillingCountry, 'South Africa')
                    .setField(Account.Industry_Code__c,'65990')
                    .setField(Account.Primary_Relationship_Holder__c, 'Corporate and Investment Banking')
                    .setField(Account.CIF_Client_Type__c, 'W');

            BLD_Account existingTopParentCommBAccount =  (BLD_Account) new BLD_Account(uow)
                    .name(PARENT_COMMB_NAME)
                    .CIF(PARENT_BP_NUMBER)
                    .useCommB()
                    .useGroupParent()
                    .setField(Account.OwnerId, topParentCC.Id)
                    .setField(Account.BillingCountry, 'South Africa')
                    .setField(Account.Industry_Code__c,'65990');

            topParentTBM   = new BLD_ClientTeam(uow)
                    .account(existingTopParentCIBAccount)
                    .role(DMN_ClientTeam.ROLE_TRANSACTIONAL_BANKER)
                    .user(topParentTB.Id);


            topParentCCM   = new BLD_ClientTeam(uow)
                    .account(existingTopParentCIBAccount)
                    .role(DMN_ClientTeam.ROLE_MANAGER_CLIENT_COVERAGE)
                    .user(topParentCC.Id);

            uow.commitWork();

            BLD_Account existingChildCIBAccount =  (BLD_Account) new BLD_Account(uow)
                    .name(CHILD_ACC_NAME)
                    .CIF(CHILD_CIF_NUMBER)
                    .useCib()
                    .useImmediateParent(existingTopParentCIBAccount.getRecordId())
                    .setField(Account.Registration_Number__c, '2006/020522/08')
                    .setField(Account.OwnerId, topParentCC.Id)
                    .setField(Account.BillingCountry, 'South Africa')
                    .setField(Account.Industry_Code__c,'65990')
                    .setField(Account.Primary_Relationship_Holder__c, 'Corporate and Investment Banking')
                    .setField(Account.CIF_Client_Type__c, 'W')
                    .commitWork();

            topParentTBM   = new BLD_ClientTeam(uow)
                    .account(existingChildCIBAccount)
                    .role(DMN_ClientTeam.ROLE_TRANSACTIONAL_BANKER)
                    .user(childTB.Id);


            topParentCCM   = new BLD_ClientTeam(uow)
                    .account(existingChildCIBAccount)
                    .role(DMN_ClientTeam.ROLE_MANAGER_CLIENT_COVERAGE)
                    .user(childCC.Id);



            BLD_Account existingChildCommBAccount =  (BLD_Account) new BLD_Account(uow)
                    .name(CHILD_COMMB_NAME)
                    .CIF(CHILD_BP_NUMBER)
                    .useCommB()
                    .useImmediateParent(existingTopParentCommBAccount.getRecordId())
                    .setField(Account.OwnerId, topParentCommB.Id)
                    .setField(Account.BillingCountry, 'South Africa')
                    .setField(Account.Industry_Code__c,'65990')
                    .commitWork();

            uow.commitWork();
        }
    }

    @IsTest
    static void testGetPositiveSearchByNumber() {

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/services/apexrest/LegalEntity';
        request.addParameter('registrationNumber', '2006/020522/08');
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        List<Account> returnedAccountList = AOB_ClientResource.doGet();
        Test.stopTest();
        System.assertEquals(1, returnedAccountList.size());
    }

    @IsTest
    static void testGetPositiveSearchByName() {

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/services/apexrest/LegalEntity';
        request.addParameter('registeredName', DEF_ACC_NAME);
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        List<Account> returnedAccountList = AOB_ClientResource.doGet();
        Test.stopTest();
        System.assertEquals(1, returnedAccountList.size());
    }


    @IsTest
    static void testPostPositiveNewEApp() {

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        List<Account> parentAccounts = new SEL_Accounts().selectByCIFNumber( new Set<String>{CIF_NUMBER});
        Account topParentAccount = parentAccounts[0];

        request.requestUri ='/services/apexrest/LegalEntity';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"createdAt": "2018-09-04 12:14:29", "modifiedAt": "2018-09-04 12:17:13", "id": 12, "username": null, "status": "kyc", "description": "New Test", ' +
                '"legalEntity": {"salesforceId": null, "cif": null, "typeOfEntity": "Private Company (Pty LTD)", "tradingAs": "TEst", "registrationNumber": "2007/020522/08", "registeredCountry": "ZA", ' +
                '"registeredName": "ICT and Financial Consultants CC", "telephoneNumber": "012312121", "vatNumber": "12121", "annualTurnover": 10000, "sic": null, "natureOfBusiness": "Other", ' +
                '"businessClassification": "Central Bank", "clientType": "Bank", "countryOfRevenue": "South Africa", "entityActive": true, "parentEntityName": null, "parentEntityCif": "'+topParentAccount.CIF__c +
                '", "relationshipRole": "Client", "countryOfOperation": "South Africa", "kycLocation": "SBSA - Standard Bank of South Africa Ltd", "primaryDataSource": "Public", "kycContact": ' +
                '{"firstName": "Test", "lastName": "Test", "email": "test@test.com", "contactNumber": "0123112121"}, "registeredAddress": ' +
                '{"street": "425 Niewenhuyzen Street", "suburb": "Waterkloof", "province": "Gauteng", "city": "Pretoria", "postalCode": "1886", "country": "South Africa"}, "physicalAddress": ' +
                '{"street": "425 Niewenhuyzen Street", "suburb": "Erasmuskloof Ext", "province": "Gauteng", "city": "Pretoria", "postalCode": "1886", "country": "South Africa"}, "authorisers": ' +
                '[{"idNumber": "8404095770083", "firstName": "SIYABONGA", "lastName": "KHANYILE", "contactNumber": "0112828000", "emailAddress": null, "address": ' +
                '{"street": "30 LANGEVELDT STREET", "suburb": "Test", "province": null, "city": null, "postalCode": null, "country": null }, "authoriserDocuments": ' +
                '[{"documentType": "ID Document", "name": "ID", "verified": false, "documentId": "idd_C7E076FC-46D1-4ADB-A205-D48AD69AFC7C", "createdAt": null, "modifiedAt": null, "id": 0 } ] } ], "relatedParties": ' +
                '[{"createdAt": null, "modifiedAt": null, "id": 0, "businessType": "Juristic Entity", "identityNumber": null, "sharePercentage": 100, "firstName": null, "lastName": null, "registrationNumber": "1998/014669/06", ' +
                '"registeredName": "EOH", "contactNumber": "012312121", "capacity": null, "emailAddress": null, "registeredAddress": "12 Test", "headOfficeAddress": "12 Test", "physicalAddress": "12 Test", "actionType": null, "relatedPartyDocuments": ' +
                '[{"documentType": "CIPC Document", "name": "CIPC Document: ICT and Financial Consultants CC", "verified": false, "documentId": "idd_C7E076FC-46D1-4ADB-A205-D48AD69AFC7C", "createdAt": null, "modifiedAt": null, "id": 0 } ] } ], "entityDocuments": ' +
                '[{"documentType": "CIPC Document", "name": "CIPC Document: ICT and Financial Consultants CC", "verified": false, "documentId": "idd_C7E076FC-46D1-4ADB-A205-D48AD69AFC7C", "createdAt": null, "modifiedAt": null, "id": 0 }, ' +
                '{"documentType": "Resolution", "name": "Resolution: ICT and Financial Consultants CC", "verified": false, "documentId": "idd_6C5DB2B9-0780-4465-A0C9-D3ED0F784995", "createdAt": null, "modifiedAt": null, "id": 0 }, {"documentType": "Ownership Structure", "name": "Ownership Structure: ICT and Financial Consultants CC", "verified": false, "documentId": "idd_BBD827D8-444C-4C64-B10E-B3B202D47BBC", "createdAt": null, "modifiedAt": null, "id": 0 } ] }, "requester": {"requestedBy": "Riaan Erasmus", "requesterNumber": "27842069536"} }');

        RestContext.request = request;
        RestContext.response = response;
        Boolean hasErrors = false;
        Test.startTest();
        String mockBody = '<?xml version="1.0" encoding="UTF-8"?>'	+
                + 	'<Response>'	+
                +		'<Operation>New Customer</Operation>'	+
                +		'<Success>true</Success>'	+
                +	'</Response>';
        SingleRequestMock singleMock = new SingleRequestMock(200, 'OK',mockBody, null);
        Test.setMock(HttpCalloutMock.class, singleMock);
        System.runAs(aobUser) {
            try{
                AOB_ClientResource.doPost();
            }catch(OnboardingService.OnboardingServiceException e){
                hasErrors = true;
            }
            System.assertEquals(hasErrors,false);
            response.addHeader('Content-Type', 'application/json');
            response.responseBody = Blob.valueOf('{"Mock Response":"Mock Values"}');
        }
        List<Onboarding_Application__c> testOnboardingApp = new SEL_OnboardingApplications().selectByApplicationId(new Set<Integer> {12});
        System.assertEquals(1,testOnboardingApp.size(),'The On-boarding Application does not exist');
        testOnboardingApp = new SEL_OnboardingApplications().selectById(new Set<id> {testOnboardingApp[0].Id});
        List<Account> testProspect = new SEL_Accounts().selectByRegistrationNumber(new Set<String> {'2007/020522/08'});
        System.assertEquals(1,testProspect.size(),'The Prospect was not created!');
        testProspect = new SEL_Accounts().selectById(new Set<id> {testProspect[0].Id});
        List<Contact> testKYCContacts = new SEL_Contacts().selectKYCContactByAccountId(new Set<Id> {testProspect[0].Id});
        System.assertEquals(1,testKYCContacts.size(),'The KYC Contact was not created');
        List<Contact> testAuthorisedPersons = new SEL_Contacts().selectAuthorisedPersonByAccountId(new Set<Id> {testProspect[0].Id});
        System.assertEquals(1,testAuthorisedPersons.size(),'The Authorised Persons were not created');
        testKYCContacts = new SEL_Contacts().selectById(new Set<Id> {testKYCContacts[0].Id});

        System.Test.stopTest();
    }

    @IsTest
    static void testPostPositiveHierarchyChange() {

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        List<Account> parentAccounts = new SEL_Accounts().selectByCIFNumber( new Set<String>{PARENT_CIF_NUMBER});
        Account topParentAccount = parentAccounts[0];

        List<Account> existingChildCIBAccounts = new SEL_Accounts().selectByCIFNumber( new Set<String>{CHILD_CIF_NUMBER});
        Account existingChildCIBAccount = existingChildCIBAccounts[0];

        request.requestUri ='/services/apexrest/LegalEntity';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"createdAt": "2018-09-04 12:14:29", "modifiedAt": "2018-09-04 12:17:13", "id": 12, "username": null, "status": "kyc", "description": "New Test", ' +
                '"legalEntity": {"salesforceId": "'+ existingChildCIBAccount.Id +'", "cif": null, "typeOfEntity": "Private Company (Pty LTD)", "tradingAs": "TEst", "registrationNumber": "'+existingChildCIBAccount.Registration_Number__c+'", "registeredCountry": "ZA", ' +
                '"registeredName": "ICT and Financial Consultants CC", "telephoneNumber": "012312121", "vatNumber": "12121", "annualTurnover": 10000, "sic": null, "natureOfBusiness": "Other", ' +
                '"businessClassification": "Central Bank", "clientType": "Bank", "countryOfRevenue": "South Africa", "entityActive": true, "parentEntityName": null, "parentEntityCif": "'+ topParentAccount.CIF__c +
                '", "relationshipRole": "Client", "countryOfOperation": "South Africa", "kycLocation": "SBSA - Standard Bank of South Africa Ltd", "primaryDataSource": "Public", "kycContact": ' +
                '{"firstName": "Test", "lastName": "Test", "email": "test@test.com", "contactNumber": "0123112121"}, "registeredAddress": ' +
                '{"street": "425 Niewenhuyzen Street", "suburb": "Waterkloof", "province": "Gauteng", "city": "Pretoria", "postalCode": "1886", "country": "South Africa"}, "physicalAddress": ' +
                '{"street": "425 Niewenhuyzen Street", "suburb": "Erasmuskloof Ext", "province": "Gauteng", "city": "Pretoria", "postalCode": "1886", "country": "South Africa"}, "authorisers": ' +
                '[{"idNumber": "8404095770083", "firstName": "SIYABONGA", "lastName": "KHANYILE", "contactNumber": "0112828000", "emailAddress": null, "address": ' +
                '{"street": "30 LANGEVELDT STREET", "suburb": "Test", "province": null, "city": null, "postalCode": null, "country": null }, "authoriserDocuments": ' +
                '[{"documentType": "ID Document", "name": "ID", "verified": false, "documentId": "idd_C7E076FC-46D1-4ADB-A205-D48AD69AFC7C", "createdAt": null, "modifiedAt": null, "id": 0 } ] } ], "relatedParties": ' +
                '[{"createdAt": null, "modifiedAt": null, "id": 0, "businessType": "Juristic Entity", "identityNumber": null, "sharePercentage": 100, "firstName": null, "lastName": null, "registrationNumber": "1998/014669/06", ' +
                '"registeredName": "EOH", "contactNumber": "012312121", "capacity": null, "emailAddress": null, "registeredAddress": "12 Test", "headOfficeAddress": "12 Test", "physicalAddress": "12 Test", "actionType": null, "supportingDocuments": ' +
                '[{"documentType": "CIPC Document", "name": "CIPC Document: ICT and Financial Consultants CC", "verified": false, "documentId": "idd_C7E076FC-46D1-4ADB-A205-D48AD69AFC7C", "createdAt": null, "modifiedAt": null, "id": 0 } ] } ], "entityDocuments": ' +
                '[{"documentType": "CIPC Document", "name": "CIPC Document: ICT and Financial Consultants CC", "verified": false, "documentId": "idd_C7E076FC-46D1-4ADB-A205-D48AD69AFC7C", "createdAt": null, "modifiedAt": null, "id": 0 }, ' +
                '{"documentType": "Resolution", "name": "Resolution: ICT and Financial Consultants CC", "verified": false, "documentId": "idd_6C5DB2B9-0780-4465-A0C9-D3ED0F784995", "createdAt": null, "modifiedAt": null, "id": 0 }, {"documentType": "Ownership Structure", "name": "Ownership Structure: ICT and Financial Consultants CC", "verified": false, "documentId": "idd_BBD827D8-444C-4C64-B10E-B3B202D47BBC", "createdAt": null, "modifiedAt": null, "id": 0 } ] }, "requester": {"requestedBy": "Riaan Erasmus", "requesterNumber": "27842069536"} }');

        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        System.runAs(aobUser) {
            AOB_ClientResource.doPost();
            response.addHeader('Content-Type', 'application/json');
            response.responseBody = Blob.valueOf('{"Mock Response":"Mock Values"}');
        }
        List<Onboarding_Application__c> testOnboardingApp = new SEL_OnboardingApplications().selectByApplicationId(new Set<Integer> {12});
        System.assertEquals(1,testOnboardingApp.size(),'The On-boarding Application does not exist');
        testOnboardingApp = new SEL_OnboardingApplications().selectById(new Set<id> {testOnboardingApp[0].Id});
        System.assertEquals(OnboardingApplicationService.REQUEST_TYPE_HIERARCHY_CHANGE,testOnboardingApp[0].Request_Type__c);
        List<AccountTeamMember> testTeamMembers = new SEL_AccountTeams().selectByAccountIdAndTeamMemberRole(new Set<Id> {existingChildCIBAccount.Id },new Set<String> {DMN_ClientTeam.ROLE_TRANSACTIONAL_BANKER});
        System.assertEquals(1,testTeamMembers.size(),'The Team member was not created!');
        testTeamMembers = new SEL_AccountTeams().selectById(new Set<Id> {testTeamMembers[0].Id});
        System.assertEquals(DMN_ClientTeam.ROLE_TRANSACTIONAL_BANKER,testTeamMembers[0].TeamMemberRole);

        Test.stopTest();
    }

    @IsTest
    static void testPostNegativeNoApp() {

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri ='/services/apexrest/LegalEntity';
        request.httpMethod = 'POST';

        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        System.runAs(aobUser) {
            AOB_ClientResource.doPost();
            response.addHeader('Content-Type', 'application/json');
            response.responseBody = Blob.valueOf('{"Unable to process request. No Onboarding Application supplied."}');
            response.statusCode = 400;
        }

        System.assertEquals(400,response.statusCode,'The On-boarding Application does not exist');
        System.Test.stopTest();
    }

    @IsTest
    static void testPostNegativeNoSalesforceAccount() {

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        List<Account> parentAccounts = new SEL_Accounts().selectByCIFNumber( new Set<String>{CIF_NUMBER});
        Account topParentAccount = parentAccounts[0];

        request.requestUri ='/services/apexrest/LegalEntity';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"createdAt": "2018-09-04 12:14:29", "modifiedAt": "2018-09-04 12:17:13", "id": 12, "username": null, "status": "kyc", "description": "New Test", ' +
                '"legalEntity": {"salesforceId": "0011q000001MQFA", "cif": null, "typeOfEntity": "Private Company (Pty LTD)", "tradingAs": "TEst", "registrationNumber": "2007/020522/08", "registeredCountry": "ZA", ' +
                '"registeredName": "ICT and Financial Consultants CC", "telephoneNumber": "012312121", "vatNumber": "12121", "annualTurnover": 10000, "sic": null, "natureOfBusiness": "Other", ' +
                '"businessClassification": "Central Bank", "clientType": "Bank", "countryOfRevenue": "South Africa", "entityActive": true, "parentEntityName": null, "parentEntityCif": "'+topParentAccount.CIF__c +
                '", "relationshipRole": "Client", "countryOfOperation": "South Africa", "kycLocation": "SBSA - Standard Bank of South Africa Ltd", "primaryDataSource": "Public", "kycContact": ' +
                '{"firstName": "Test", "lastName": "Test", "email": "test@test.com", "contactNumber": "0123112121"}, "registeredAddress": ' +
                '{"street": "425 Niewenhuyzen Street", "suburb": "Waterkloof", "province": "Gauteng", "city": "Pretoria", "postalCode": "1886", "country": "South Africa"}, "physicalAddress": ' +
                '{"street": "425 Niewenhuyzen Street", "suburb": "Erasmuskloof Ext", "province": "Gauteng", "city": "Pretoria", "postalCode": "1886", "country": "South Africa"}, "authorisers": ' +
                '[{"idNumber": "8404095770083", "firstName": "SIYABONGA", "lastName": "KHANYILE", "contactNumber": "0112828000", "emailAddress": null, "address": ' +
                '{"street": "30 LANGEVELDT STREET", "suburb": "Test", "province": null, "city": null, "postalCode": null, "country": null }, "authoriserDocuments": ' +
                '[{"documentType": "ID Document", "name": "ID", "verified": false, "documentId": "idd_C7E076FC-46D1-4ADB-A205-D48AD69AFC7C", "createdAt": null, "modifiedAt": null, "id": 0 } ] } ], "relatedParties": ' +
                '[{"createdAt": null, "modifiedAt": null, "id": 0, "businessType": "Juristic Entity", "identityNumber": null, "sharePercentage": 100, "firstName": null, "lastName": null, "registrationNumber": "1998/014669/06", ' +
                '"registeredName": "EOH", "contactNumber": "012312121", "capacity": null, "emailAddress": null, "registeredAddress": "12 Test", "headOfficeAddress": "12 Test", "physicalAddress": "12 Test", "actionType": null, "supportingDocuments": ' +
                '[{"documentType": "CIPC Document", "name": "CIPC Document: ICT and Financial Consultants CC", "verified": false, "documentId": "idd_C7E076FC-46D1-4ADB-A205-D48AD69AFC7C", "createdAt": null, "modifiedAt": null, "id": 0 } ] } ], "entityDocuments": ' +
                '[{"documentType": "CIPC Document", "name": "CIPC Document: ICT and Financial Consultants CC", "verified": false, "documentId": "idd_C7E076FC-46D1-4ADB-A205-D48AD69AFC7C", "createdAt": null, "modifiedAt": null, "id": 0 }, ' +
                '{"documentType": "Resolution", "name": "Resolution: ICT and Financial Consultants CC", "verified": false, "documentId": "idd_6C5DB2B9-0780-4465-A0C9-D3ED0F784995", "createdAt": null, "modifiedAt": null, "id": 0 }, {"documentType": "Ownership Structure", "name": "Ownership Structure: ICT and Financial Consultants CC", "verified": false, "documentId": "idd_BBD827D8-444C-4C64-B10E-B3B202D47BBC", "createdAt": null, "modifiedAt": null, "id": 0 } ] }, "requester": {"requestedBy": "Riaan Erasmus", "requesterNumber": "27842069536"} }');

        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        System.runAs(aobUser) {
            AOB_ClientResource.doPost();
            response.addHeader('Content-Type', 'application/json');
            response.responseBody = Blob.valueOf('{"Mock Response":"Mock Values"}');
        }
        System.assertEquals(500,response.statusCode,'The On-boarding Application does not exist');
        System.Test.stopTest();
    }

    @IsTest
    static void testPostNegativeRequestFailed() {

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();


        request.requestUri ='/services/apexrest/LegalEntity';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        System.runAs(aobUser) {
            AOB_ClientResource.doPost();
            response.addHeader('Content-Type', 'application/json');
            response.responseBody = Blob.valueOf('{"Onboarding request failed. Requested Entity was successfully processed but not stored."}');
            response.statusCode = 500;
        }

        System.assertEquals(500,response.statusCode,'The On-boarding Application does not exist');
        System.Test.stopTest();
    }
}