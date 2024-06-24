/**
*
* @author Emmanuel Mulea Nocks(BlueSky)
* @date June 2020
* @description Test class for DigiSignConsent
*/
@isTest
public class DigiSignConsent_Test {

    private static final String     TEST_USER_NAME          = 'stdBank@nbac.com';
    private static final String   DEF_ACC_NAME            = 'Def Name for Acc';
    private static final String    GEN_ACC_NAME			= 'General PTY';
    private static final String     CIF_NUMBER            = '654321';
    private static final String     SIGNATORY_ID            = '654322';
    public static final String DEF_FIRST_NAME = 'testFirstName';
    public static final String MOBILE_PHONE = '0722344321';
    private static final List<String> CLIENT_ROLES = new List<String>{'KYC Contact','Authorised Person','Direct Shareholder','Indirect Shareholder'};
    private static final String SCOPE = 'retail customer prod';
    private static final String REQUEST_TYPE = 'Request Consent';
    private static final String RT_COMMB_REQUEST_CONSENT = 'CommB_Request_Consent';
    private static User usrOwner;
    @TestSetup
    private static void prepareData() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        System.runAs(new User(Id = UserInfo.getUserId())){

            usrOwner = (User)new BLD_USER(uow).userName(TEST_USER_NAME+'1').useCommB().email(TEST_USER_NAME).syncContact().getRecord();

            uow.commitWork();
        }
        Test.startTest();
        Test.stopTest();

        System.runAs(usrOwner){
            BLD_Account ugpClientBld	= (BLD_Account) new BLD_Account(uow)
                    .name(DEF_ACC_NAME)
                    .CIF(CIF_NUMBER)
                    .useCommB()
                    .riskRating(DMN_Account.RISK_RATING_D1)
                    .useGroupParent();

            BLD_Contact con = (BLD_Contact) new BLD_Contact(uow)
                    .useClientContact()
                    .account(ugpClientBld)
                    .ownerId(usrOwner.id)
                    .mobilePhone(MOBILE_PHONE)
                    .roleAtClient(CLIENT_ROLES[0]);
            BLD_Contact con2 = (BLD_Contact) new BLD_Contact(uow)
                    .useClientContact()
                    .account(ugpClientBld)
                    .ownerId(usrOwner.id)
                    .mobilePhone(MOBILE_PHONE)
                    .roleAtClient(CLIENT_ROLES[1]);
            uow.commitwork();
        }

        createOnboardingData();
    }

    private static void mockAuthenticationAndRequestProviderResponse() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OAuth_ESB_Gateway mockProvider  = (OAuth_ESB_Gateway) mocks.mock(OAuth_ESB_Gateway.class);
        OAuth_ESB_Gateway.IService requestOauth = DigiSignConsent.REQUEST_OAUTH;
        OAuth_ESB_Gateway.RequestBuilder reqBuild = new OAuth_ESB_Gateway.RequestBuilder();
        mocks.startStubbing();
        mocks.when(mockProvider.getRequestWithToken(SCOPE, requestOauth)).thenReturn(reqBuild);
        mocks.stopStubbing();
        ORG_Application.service.setMock(OAuth_ESB_Gateway.IService.class, mockProvider);
    }

    @IsTest
    static void testCreateConsent() {
        String  data;
        Account account = SEL_Accounts.newInstance().selectByRegisteredName(new Set<String>{DEF_ACC_NAME})[0];
        String selectedContacts = getSelectedContacts(false,account);
        System.runAs(testUser){
            Test.startTest();
            data = DigiSignConsent.createRequestConsent(selectedContacts,account.id,REQUEST_TYPE);
			List<DigiSignRequestData.SignatoryContact> wrapperList = (List<DigiSignRequestData.SignatoryContact>) JSON.deserialize(data, List<DigiSignRequestData.SignatoryContact>.class);
            System.assertEquals(2, wrapperList.size());
            System.assertNotEquals(null,wrapperList[0].onboardingAppId);
            Test.stopTest();
        }
    }

    @IsTest
    static void testRequestConsentCallout() {
        string resp = '{"digitalSignatureResponse": [{"taskIdentifier": "0011xi7800vVeJ2mu89:470362"},{"taskIdentifier": "0011xi7800vVeJ2Ni67:470363"}],"instanceIdentifier": "96982"}';
        String res;
        Account account = SEL_Accounts.newInstance().selectByRegisteredName(new Set<String>{DEF_ACC_NAME})[0];
        String selectedContacts = getSelectedContacts(true,account);
		mockAuthenticationAndRequestProviderResponse();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'SUCCESS', resp, null));
        System.runAs(testUser){
            Test.startTest();
            res = DigiSignConsent.requestConsentCallout(selectedContacts,account.id);
            Test.stopTest();
        }
        System.assertEquals('SUCCESS',res);
    }


    @IsTest
    static void testNegRequestConsentCallout() {
        Account account = SEL_Accounts.newInstance().selectByRegisteredName(new Set<String>{DEF_ACC_NAME})[0];
        String selectedContacts = getSelectedContacts(true,account);
        List<DigiSignRequestData.SignatoryContact> wrapperList = (List<DigiSignRequestData.SignatoryContact>) JSON.deserialize(selectedContacts, List<DigiSignRequestData.SignatoryContact>.class);
        String res;
        testReportSelector();
        System.runAs(testUser){
            Test.startTest();
            res = DigiSignConsent.requestConsentCallout(selectedContacts,account.id);
            Test.stopTest();
        }
        system.assertNotEquals('SUCCESS',res);
    }

    @IsTest
    static void testGetSignatoryStatus() {
        Account account = SEL_Accounts.newInstance().selectByRegisteredName(new Set<String>{GEN_ACC_NAME})[0];
        Onboarding_Application__c onboardApp = SEL_OnboardingApplications.newInstance().selectByClientId(new Set<Id>{account.Id})[0];
        Application_Document__c appDoc = SEL_ApplicationDocuments.newInstance().selectByOnboardApplicationId(new Set<Id>{onboardApp.Id})[0];
        string resp = '{"searchApproverResponse":{"taskInformation":[{"uniqueInstanceIdentifier":"96755","subjectOfTask":"14785236:a2F1x000001aoCIEAY","digiSignInformation":{"signatoryInformation":{"signatory":[{"signatoryApprovalStatus":"Approved","signatoryFirstName":"Time","signatoryLastName":"Lang","signatoryIdentificationDocumentType":"NATIONAL IDENTITY DOCUMENT","signatoryIdentificationDocumentNumber":"14785236","originatorIndicator":false,"signatoryGuid":"'+appDoc.Id+'","typeOfApproval":"PRE"}]}},"unqiueTaskIdentifier":"468479"}]}}';


        mockAuthenticationAndRequestProviderResponse();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'SUCCESS', resp, null));
        System.runAs(testUser){
            Test.startTest();
            DigiSignConsent.getSignatoryStatus(account.id);
            Test.stopTest();
        }
        appDoc = SEL_ApplicationDocuments.newInstance().selectByOnboardApplicationId(new Set<Id>{onboardApp.Id})[0];
        System.assertEquals('Approved',appDoc.Document_status__c);
    }


    @IsTest
    static void testResendInvite() {
        Integer statusCode;
        Account account = SEL_Accounts.newInstance().selectByRegisteredName(new Set<String>{GEN_ACC_NAME})[0];
        mockAuthenticationAndRequestProviderResponse();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'SUCCESS', '{}', null));
        System.runAs(testUser){
            Test.startTest();
            statusCode = DigiSignConsent.resendInvite(SIGNATORY_ID,account.Id,REQUEST_TYPE);
            Test.stopTest();
        }
        System.assertEquals(200,statusCode);
    }
    @IsTest
    static void testGetContactsByClientNotConsent() {
        Account account = SEL_Accounts.newInstance().selectByRegisteredName(new Set<String>{DEF_ACC_NAME})[0];
        List<Contact> contactList;

        Test.startTest();
        contactList = DigiSignConsent.getContactsByClientIdAndRoles(account.id,REQUEST_TYPE);
        Test.stopTest();
        System.assertEquals(2, contactList.size());
    }

    @IsTest
    static void testGetContactsByClientWithConsent() {
        Account account = SEL_Accounts.newInstance().selectByRegisteredName(new Set<String>{GEN_ACC_NAME})[0];
        List<Contact> contactList;
        List<DigiSignConsent.OnboardWrapper>  onBoardData;

        Test.startTest();
        contactList = DigiSignConsent.getContactsByClientIdAndRoles(account.id,REQUEST_TYPE);
        onBoardData = DigiSignConsent.getOnboardingWithRelatedRec(account.id);
        Test.stopTest();
        System.assertEquals(1, contactList.size());
        System.assertEquals(1, onBoardData.size());
    }

    private static void createOnboardingData(){

        System.runAs(testUser){
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            BLD_Account ugpClientBld	= new BLD_Account(uow)
                    .name(GEN_ACC_NAME)
                    .CIF('5677879')
                    .useCommB()
                    .riskRating(DMN_Account.RISK_RATING_D1)
                    .useGroupParent();

            BLD_Contact con =  new BLD_Contact(uow)
                    .useClientContact()
                    .email('nocksTest@com.com')
                    .name('Mock','Miller')
                	.mobilePhone(MOBILE_PHONE)
                    .account(ugpClientBld)
                    .ownerId(testUser.id)
                    .roleAtClient(CLIENT_ROLES[0]);

            BLD_Onboarding_Application onboardRec = new BLD_Onboarding_Application(uow)
                    .requestType(REQUEST_TYPE)
                    .requestedBy(DEF_FIRST_NAME)
                    .client(ugpClientBld)
                    .useRequestConsentRT(RT_COMMB_REQUEST_CONSENT);

            BLD_Application_Document appDoc =  new BLD_Application_Document(uow)
                    .authorisedPerson(con)
                    .onboardingApplication(onboardRec);
            uow.commitWork();

        }

    }
    private static void testReportSelector(){
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Report reportSelectorMock = (SEL_Report) mocks.mock(SEL_Report.class);
        mocks.startStubbing();
        List<Report> testReportList = new List<Report> {
                new Report(Id = fflib_IDGenerator.generate(Report.SObjectType))
        };
        mocks.when(reportSelectorMock.sObjectType()).thenReturn(Report.SObjectType);
        mocks.when(reportSelectorMock.selectByDevName(new Set<string>{'API_Request_Consent_Errors_JyU'})).thenReturn(testReportList);
        mocks.stopStubbing();
        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.selector.setMock(reportSelectorMock);
    }
    private static String getSelectedContacts(Boolean withGuid,Account account){

        List<Contact> conList = SEL_Contacts.newInstance().selectByClientId(new Set<Id>{account.id});
        Integer idGen=0;

        List<DigiSignRequestData.SignatoryContact> signList = new List<DigiSignRequestData.SignatoryContact>();
        for(Contact con:conList){
            DigiSignRequestData.SignatoryContact signatory = new DigiSignRequestData.SignatoryContact();

            signatory.Id = con.id;
            signatory.signatoryGuid = withGuid? fflib_IDGenerator.generate(Application_Document__c.SObjectType): null;
            signatory.onboardingAppId = withGuid? fflib_IDGenerator.generate(Onboarding_Application__c.SObjectType):null;
            signatory.Email = con.Email;
            signatory.id_number = SIGNATORY_ID+String.ValueOf(idGen);
            signatory.firstName = con.FirstName;
            signatory.lastName = con.LastName;
            signatory.mobileNumber = con.MobilePhone;
            signatory.contactRoleClient = con.Contact_Role_s_at_Client__c;
            signatory.isIdValid ='true';
            signatory.checked = 'true';
            IdGen++;
            signList.add(signatory);
        }
        return JSON.serialize(signList);
    }
    private static User testUser {
        set;
        get {
            if (testUser == null) {
                testUser = SEL_Users.newInstance().selectByEmail(new Set<String>{TEST_USER_NAME})[0];
            }
            return testUser;
        }
    }
}