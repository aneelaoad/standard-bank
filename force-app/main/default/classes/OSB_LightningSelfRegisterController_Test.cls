/**
 * @description Test class for the OSB_LightningSelfRegisterController class
 *
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @date April 2020
 * 
 * @LastModified August 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-29123
 * @LastModifiedReason Increase test coverage and update to meet standards.
 *
 * @LastModified November 2023
 * @author Lyné Keet (lyne.keet@standardbank.co.za)
 * @UserStory SFP-31863
 * @LastModifiedReason Update to test classes and new test method to accomodate flagging halt registration.
 **/
@IsTest
public with sharing class OSB_LightningSelfRegisterController_Test {

    private static final String TEST_PASSWORD = 'Popcorn*963';
    private static final String TEST_DUMMY_ID = '0039E000010KurFQAS';
    private static final String TEST_IDENTITYNUM = '124578235689';
    private static final String TEST_COMMUNITY_ROLE = 'Designated Person';
    private static final String TEST_DOCUMENT = 'Test Document';
    private static final String TEST_LOCKOUT_VALUE = 'Halt Registration';
    private static final String TEST_MFA_VALUE = 'Hide MFA'; 
    private static fflib_ApexMocks mocks = new fflib_ApexMocks();
    private static fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
    

    @TestSetup
    static void setup() {
        List<OSB_URLs__c> osbUrls = TEST_DataFactory.getOsbUrls();
        insert osbUrls;
    }
    
    @IsTest 
    static void testIsValidPassword() {
        String testConfirmPassword = 'dummyPassword?@12334';
        User testUser = new user();
        OSB_LightningSelfRegisterController.validatePassword(testUser, TEST_PASSWORD, testConfirmPassword);
        Assert.areEqual(true, OSB_LightningSelfRegisterController.isValidPassword(TEST_PASSWORD, TEST_PASSWORD), 'Passwords provided do match');
        Assert.areEqual(false, OSB_LightningSelfRegisterController.isValidPassword(TEST_PASSWORD, testConfirmPassword), 'Passwords provided do not match');
        Assert.areEqual(false, OSB_LightningSelfRegisterController.isValidPassword(TEST_PASSWORD, null), 'Passwords provided do not match');
        Assert.areEqual(false, OSB_LightningSelfRegisterController.isValidPassword(null, testConfirmPassword), 'Passwords provided do not match');
    }

    @IsTest
    static void testSiteAsContainerEnabled() {
        Site site = [SELECT Id, Name FROM Site WHERE Name = 'Onehub' LIMIT 1];
        String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
        Test.startTest();
        Boolean result = OSB_LightningSelfRegisterController.siteAsContainerEnabled(communityUrl);
        Test.stopTest();
        Assert.areNotEqual(null, result, 'Community using site as container is enabled');
    }

    @IsTest
    static void testSendDataToPing() {
        Contact idContact = initializeContact();
        Contact notInsertedContact = initializeContactNotMock();

        OSB_SRV_PingIntegration serviceMock = (OSB_SRV_PingIntegration) mocks.mock(OSB_SRV_PingIntegration.class);
        ORG_Application.service.setMock(OSB_SRV_PingIntegration.IService.class, serviceMock);
		SEL_Contacts contactsSelector = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        
        mocks.startStubbing();
        mocks.when(serviceMock.getUser(fflib_Match.anyString())).thenReturn(null);
        mocks.when(serviceMock.createUser((Map<String, Object>) fflib_Match.anyObject())).thenReturn(TEST_DUMMY_ID);
        mocks.when(contactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSelector.selectByIdWoSharing(new Set<Id> {idContact.Id})).thenReturn(new List<Contact> {idContact});
        mocks.when(contactsSelector.selectByIdentityNumberWoSharing(new Set<String> {TEST_IDENTITYNUM})).thenReturn(new List<Contact> {notInsertedContact});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(contactsSelector);
        ORG_Application.unitOfWork.setMock(uowMock);
        
        Test.startTest();
        Object result = OSB_LightningSelfRegisterController.sendDataToPing(idContact, TEST_PASSWORD, TEST_IDENTITYNUM);
        Object resultNoId = OSB_LightningSelfRegisterController.sendDataToPing(notInsertedContact, TEST_PASSWORD, TEST_IDENTITYNUM);
        Test.stopTest();

        
        ((OSB_SRV_PingIntegration) mocks.verify(serviceMock, 1))
                .getUser(idContact.Email);
        ((OSB_SRV_PingIntegration) mocks.verify(serviceMock, 2))
                .createUser((Map<String, Object>) fflib_Match.anyObject());
        Assert.areEqual(TEST_DUMMY_ID, result, 'Ping Id is returned.');
        Assert.areEqual(TEST_DUMMY_ID, resultNoId, 'Ping Id is returned.');
    }

    @IsTest
    static void shouldUpdateContactExistingContact(){
        Contact idContact = initializeContact();

		SEL_Contacts contactsSelector = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        OSB_SRV_EmailSender emailSenderMock = (OSB_SRV_EmailSender) mocks.mock(OSB_SRV_EmailSender.class);
        
        mocks.startStubbing();
        mocks.when(contactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSelector.selectByIdWoSharing(new Set<Id> {idContact.Id})).thenReturn(new List<Contact> {idContact});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(contactsSelector);
        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(OSB_SRV_EmailSender.IService.class, emailSenderMock);
        
        Test.startTest();
        Object resultUpdate = OSB_LightningSelfRegisterController.updateContact(idContact, TEST_IDENTITYNUM, TEST_DUMMY_ID);
        Test.stopTest();
 
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
        ((OSB_SRV_EmailSender) mocks.verify(emailSenderMock, 1)).sendApAccessApprovedEmail(new List<Contact>{idContact}, uowMock);

        Assert.areEqual(idContact.Id, resultUpdate, 'Contact record exists.');
    }

    @IsTest
    static void shouldUpdateContactNewRecord() {
        Contact notInsertedContact = initializeContactNotMock();

		SEL_Contacts contactsSelector = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        OSB_SRV_EmailSender emailSenderMock = (OSB_SRV_EmailSender) mocks.mock(OSB_SRV_EmailSender.class);
        
        mocks.startStubbing();
        mocks.when(contactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSelector.selectByIdentityNumberWoSharing(new Set<String> {TEST_IDENTITYNUM})).thenReturn(new List<Contact> {notInsertedContact});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(contactsSelector);
        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(OSB_SRV_EmailSender.IService.class, emailSenderMock);
        
        Test.startTest();
        Object resultUpdateNoId = OSB_LightningSelfRegisterController.updateContact(notInsertedContact, TEST_IDENTITYNUM, TEST_DUMMY_ID);
        Test.stopTest();
 
        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty((Contact) argument.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
        ((OSB_SRV_EmailSender) mocks.verify(emailSenderMock, 1)).sendApAccessApprovedEmail(new List<Contact>{notInsertedContact}, uowMock);

        Assert.areEqual(notInsertedContact.Id, resultUpdateNoId, 'Contact record is updated.');
    }
    
    @IsTest
    static void shouldUpdateContactDp() {
        Contact idContact = initializeContact();
        Contact idContactDp = initializeContact(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_DP,idContact.Id);

		SEL_Contacts contactsSelector = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        OSB_SRV_EmailSender emailSenderMock = (OSB_SRV_EmailSender) mocks.mock(OSB_SRV_EmailSender.class);
        
        mocks.startStubbing();
        mocks.when(contactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSelector.selectByIdWoSharing(new Set<Id> {idContact.Id})).thenReturn(new List<Contact> {idContact});
        mocks.when(contactsSelector.selectByIdWoSharing(new Set<Id> {idContactDp.Id})).thenReturn(new List<Contact> {idContactDp});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(contactsSelector);
        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(OSB_SRV_EmailSender.IService.class, emailSenderMock);
        
        Test.startTest();
        Object resultUpdateDp = OSB_LightningSelfRegisterController.updateContact(idContactDp, TEST_IDENTITYNUM, TEST_DUMMY_ID);
        Test.stopTest();
 
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
        ((OSB_SRV_EmailSender) mocks.verify(emailSenderMock, 1)).sendSignUpEmails(new List<Contact>{idContactDp}, uowMock);

        Assert.areEqual(idContactDp.Id, resultUpdateDp, 'Contact record with Designated Persona is updated.');
    }
    
    @IsTest
    static void testGetterMethod() {
        Contact testContact = initializeContact();
        Contact testLightContact = initializeContact(TEST_COMMUNITY_ROLE,testContact.Id);
        SEL_Contacts contactsSelector = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        mocks.startStubbing();
        mocks.when(contactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSelector.selectByIdWoSharing(new Set<Id> {testContact.Id})).thenReturn(new List<Contact> {testContact});
        mocks.when(contactsSelector.selectByIdForRegistration(new Set<Id> {testLightContact.Id})).thenReturn(new List<Contact> {testLightContact});
        mocks.stopStubbing();
        
        ORG_Application.selector.setMock(contactsSelector);
		
        Object resultIndustry = OSB_LightningSelfRegisterController.getIndustryValues();
        Assert.areNotEqual(null, resultIndustry, 'Industry values do not return as null.');

        Object resultCountryCodes = OSB_LightningSelfRegisterController.getCountryCodes();
        Assert.areNotEqual(null, resultCountryCodes, 'Country Code values do not return as null.');

        List<Contact> resultContact = OSB_LightningSelfRegisterController.getRecord(testContact.Id);
        Assert.areEqual(testContact, resultContact[0], 'Retrieve contact record.');

        List<Contact> resultContactLight = OSB_LightningSelfRegisterController.getLightContact(testLightContact.Id, false);
        Assert.areEqual(testLightContact, resultContactLight[0], 'Retrieve light contact record.');

        Object resultUrls = OSB_LightningSelfRegisterController.getCustomURLS();
        Assert.areNotEqual(null, resultUrls, 'Custom url values do not return as null.');
    }

    @IsTest
    static void lightningSelfRegisterControllerInstantiation() {
        OSB_LightningSelfRegisterController controller = new OSB_LightningSelfRegisterController();
        Assert.areNotEqual(null, controller, 'OSB_LightningSelfRegisterController controller is not null.');
    }

    @isTest
    static void shouldGetDocumentUrl(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        mocks.startStubbing();
        mocks.when(serviceMock.getDocumentLink(fflib_Match.anyString())).thenReturn(TEST_DOCUMENT);
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);

        Test.startTest();
        String result = OSB_LightningSelfRegisterController.getOSBDocumentURL(TEST_DOCUMENT);
        Test.stopTest();
        ((SRV_Document) mocks.verify(serviceMock, 1))
                .getDocumentLink(TEST_DOCUMENT);
        Assert.areEqual(TEST_DOCUMENT, result, 'Correct document retrieved.');
    }

    private static Contact initializeContact() {
        Contact con = (Contact) new BLD_Contact()
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .manageSiteFeature(TEST_MFA_VALUE)
            .mock();
        return con;
    }

    private static Contact initializeContact(String osbCommunityAccessRoleDp, Id accessManagerId) {
        Contact con = (Contact) new BLD_Contact()
            .communityAccessManager(accessManagerId)
            .setOSBDefaultData(osbCommunityAccessRoleDp, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .mock();
        return con;
    }

    private static Contact initializeContactNotMock() {
        String defFirstName = 'testFirstName';
        String defLastName = 'testLastName';
        Contact con = (Contact) new BLD_Contact()
            .identityNumber(TEST_IDENTITYNUM)
            .name(defFirstName,defLastName)
            .getRecord();
        return con;
    }

    @IsTest
    static void shouldCheckForUser() {
        Contact testerContact = initializeContact();
        OSB_SRV_PingIntegration serviceMock = (OSB_SRV_PingIntegration) mocks.mock(
            OSB_SRV_PingIntegration.class
        );

        mocks.startStubbing();
        mocks.when(serviceMock.getUser(fflib_Match.anyString())).thenReturn(TEST_DUMMY_ID);
        mocks.stopStubbing();

        ORG_Application.service.setMock(
            OSB_SRV_PingIntegration.IService.class,
            serviceMock
        );

        Test.startTest();
        Boolean result = OSB_LightningSelfRegisterController.checkForUser(testerContact.Email);
        Test.stopTest();

        ((OSB_SRV_PingIntegration) mocks.verify(serviceMock, 1)).getUser(testerContact.Email);
        Assert.areEqual(true, result, 'Check for user returned true.');

    }

    @isTest
    static void shouldFlagHaltRegistrationOnContact(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Contacts contactsSelector = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        ORG_Application.selector.setMock(contactsSelector);
        ORG_Application.unitOfWork.setMock(uowMock);

        Contact testContact = initializeContact();

        mocks.startStubbing();
        mocks.when(contactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSelector.selectByIdWoSharing(new Set<Id> {testContact.Id})).thenReturn(new List<Contact> {testContact});
        mocks.stopStubbing();
          
        ORG_Application.selector.setMock(contactsSelector);

        Test.startTest();
        OSB_LightningSelfRegisterController.flagRegistration(testContact.Id);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty((Contact) argument.capture());
        Contact resultContact = (Contact) argument.getValue();
        Assert.areEqual(true,resultContact.Manage_Site_Features__c.contains(TEST_LOCKOUT_VALUE), 'Contact has their registration on hold');        
    }
}