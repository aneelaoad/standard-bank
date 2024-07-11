/**
 *
 * @author Eldrin Shikwambana (eldrin.shikwambana@standardbank.co.za)
 * @description  Test class for OSB_OtpManagement_CTRL
 * @UserStory SFP-38763
 * @date May 2024
 *
 */
@isTest
public class OSB_OtpManagement_CTRL_Test {
    private static final String inputCode = 'WHCN7';
    private static final String otpReason = 'Device Addition';

    @TestSetup
    static void setup() {
        List<SObject> customMetadataList = new List<SObject>();
        customMetadataList.addAll(TEST_DataFactory.getOsbUrls());

        OTP_Request_Setting__mdt settings = new OTP_Request_Setting__mdt();
        settings.AttemptLimit__c = 20;
        settings.CodeCharacterLength__c = 5;
        settings.DeveloperName = 'OneHub';
        settings.CodeDurationSeconds__c = 120;
        insert customMetadataList;
    }

    @isTest
    public static void testCustomMetadataRecord() {
        OTP_Request_Setting__mdt record = OSB_OtpManagement_CTRL.getCustomMetadataRecord();
        Assert.areEqual(
            'OneHub',
            record.MasterLabel,
            'OneHub metadata record was returned'
        );
    }

    private static Contact createTestContact() {
        Contact testContact = new Contact();
        testContact.FirstName = 'Tester';
        testContact.LastName = 'TesterSur';
        testContact.Email = 'testuser@example.com';
        insert testContact;
        return testContact;
    }

    private static OTPRequest__c createTestOtpRequest(Id relatedRecordId) {
        OTPRequest__c testOtpRequest = new OTPRequest__c();
        testOtpRequest.RelatedRecordID__c = relatedRecordId;
        testOtpRequest.Code__c = 'TEST1';
        testOtpRequest.Requests__c = 1;
        insert testOtpRequest;
        return testOtpRequest;
    }

    @isTest
    public static void testInitialiseOTP() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);

        Contact testContact = createTestContact();

        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Contact>{ testContact });
        mocks.stopStubbing();
        ORG_Application.selector.setMock(contactsSel);

        Test.startTest();
        SRV_OTP.Response otpResponse = OSB_OtpManagement_CTRL.initialiseOTP(otpReason);
        Test.stopTest();
        Assert.areEqual(
            true,
            otpResponse.isSuccess,
            'OTP successfully created'
        );
    }

    @isTest
    public static void testIfOTPRecordExist() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_OTPRequest selectorMock = (SEL_OTPRequest) mocks.mock(
            SEL_OTPRequest.class
        );
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(
            SEL_Contacts.class
        );
        Contact testContact = createTestContact();

        OTPRequest__c testOtpRequest = createTestOtpRequest(testContact.Id);

        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId((Set<Id>) fflib_Match.anyObject())) .thenReturn(new List<Contact>{ testContact });
        mocks.when(selectorMock.sObjectType()).thenReturn(OTPRequest__c.SObjectType);
        mocks.when(selectorMock.selectByRelatedRecordId((String) fflib_Match.anyString())).thenReturn(new List<OTPRequest__c>{ testOtpRequest });
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);
        ORG_Application.selector.setMock(contactsSel);

        Test.startTest();
        SRV_OTP.Response otpResponse = OSB_OtpManagement_CTRL.initialiseOTP(otpReason);
        OSB_OtpManagement_CTRL.sendOutMailOTP(otpReason);
        Test.stopTest();
        Assert.areEqual(
            true,
            otpResponse.isSuccess,
            'Should return an existing OTP Record'
        );
    }

    @isTest
    public static void testValidateWrongOTPCode() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_OTPRequest selectorMock = (SEL_OTPRequest) mocks.mock(SEL_OTPRequest.class);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);

        Contact testContact = createTestContact();

        OTPRequest__c testOtpRequest = createTestOtpRequest(testContact.Id);

        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Contact>{ testContact });
        mocks.when(selectorMock.sObjectType()).thenReturn(OTPRequest__c.SObjectType);
        mocks.when(selectorMock.selectByRelatedRecordId( (String) fflib_Match.anyString())).thenReturn(new List<OTPRequest__c>{ testOtpRequest });
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);
        ORG_Application.selector.setMock(contactsSel);

        SRV_OTP service = (SRV_OTP) SRV_OTP.newInstance();
        service.initialise('OneHub', testContact.Id);
        service.requestCode();
        Test.startTest();
        SRV_OTP.Response res = OSB_OtpManagement_CTRL.validateOTPCode(inputCode);
        Test.stopTest();
        Assert.areEqual(false, res.isSuccess, 'Invalid code.');
    }

    @isTest
    static void shouldCreateCase() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        SEL_Entitlement entitlementSelector = (SEL_Entitlement) mocks.mock( SEL_Entitlement.class);
        Contact testContact = createTestContact();

        Case newCase = new Case();

        Entitlement testEntitlement = new Entitlement();
        testEntitlement.Name = DMN_Entitlement.DEFAULT_ENTITLEMENT_NAME;

        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Contact>{ testContact });
        mocks.when(entitlementSelector.sObjectType()).thenReturn(Entitlement.sObjectType);
        mocks.when(entitlementSelector.selectByNameWithoutSharing((String) fflib_Match.anyString())).thenReturn(new List<Entitlement>{ testEntitlement });
        mocks.stopStubbing();
        ORG_Application.selector.setMock(contactsSel);
        ORG_Application.selector.setMock(entitlementSelector);

        Test.startTest();
        newCase = OSB_OtpManagement_CTRL.createCase();
        Test.stopTest();
        Assert.areEqual(
            'Suspicious activity detected',
            newCase.Subject,
            'Case for suspicious activity was created'
        );
    }
}