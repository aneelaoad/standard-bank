/**
 * @description  : Test Class for Partner Portal Registration From Controller
 * User Story :
 *
 * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
 * @date July 2021
 */
@IsTest
private class PP_RegistrationForm_CTRL_TEST {

    private static final String TEST_USER_NAME = 'testsgfdgds646@test.com';
    private static final String TEST_ADMIN_NAME = 'testgfdgsd335dssfs@test.com';
    private static final String TEST_CONTACT_EMAIL = 'test@Contact.testcom';
    private static final String TEST_USER_FIRSTNAME = 'User';
    private static final String TEST_CONTACT_ACCESS_ROLE = 'Authorised Person';
    private static final String TEST_CONTACT_FIRST_NAME = 'Test';
    private static final String TEST_CONTACT_LAST_NAME = 'Manager';

    private static User testUser {
        get {
            if (testUser == null) {
                testUser = [SELECT Id, ContactId, Email, Phone, Name FROM User WHERE Username = :TEST_USER_NAME LIMIT 1];
            }
            return testUser;
        }
        set;
    }
    private static Contact testContact {
        get {
            if (testContact == null) {
                testContact = [SELECT Id, FirstName, LastName, Name, Email FROM Contact WHERE Email = :TEST_CONTACT_EMAIL LIMIT 1];
            }
            return testContact;
        }
        set;
    }

    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWorkWithKnowledge();
        new BLD_Contact(uow)
            .name(TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME)
            .communityAccessManager(new BLD_Contact(uow).communityAccessRole(TEST_CONTACT_ACCESS_ROLE))
            .email(TEST_CONTACT_EMAIL)
            .ownerId(UserInfo.getUserId())
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
            .account(new BLD_Account(uow))
            .getRecord();
        uow.commitWork();
        Permissionset pset = [SELECT Id FROM Permissionset WHERE Name = 'Community_Access_Partner_Portal' LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User communityUser = (User) new BLD_USER(uow)
                .profile(DMN_Profile.CUSTOM_BASE_CUSTOMER_COMMUNITY_PLUS_LOGIN_USER)
                .userName(TEST_USER_NAME)
                .email(testContact.Email)
                .firstName(TEST_CONTACT_FIRST_NAME)
                .lastName(TEST_CONTACT_LAST_NAME)
                .contactId(testContact.Id)
                .getRecord();
            uow.commitWork();

            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = pset.Id, AssigneeId = communityUser.Id);
            insert psa;
        }
    }

    @IsTest
    static void savePartnerApplication() {
        PP_PartnerApplication__c partner = new BLD_PartnerApplication().getPartner();

        Test.startTest();
        string result = PP_RegistrationForm_CTRL.partnershipRegistration(partner);
        Test.stopTest();
        Assert.areNotEqual(result, '', 'partnershipRegistration did not return id.');
    }

    @IsTest
    static void partnershipRegistrationUpdateTest() {
        PP_PartnerApplication__c partner = new BLD_PartnerApplication().getPartner();
        insert partner;
        Test.startTest();
        string result = PP_RegistrationForm_CTRL.partnershipRegistrationUpdate(partner);
        Test.stopTest();

        Assert.areNotEqual(result, '', 'partnershipRegistrationUpdate did not get passed.');
    }

    @IsTest
    static void getPartnerTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Contacts contactMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        Contact userContact = (Contact) new BLD_Contact().mock();

        SEL_PartnerApplication partnerMock = (SEL_PartnerApplication) mocks.mock(SEL_PartnerApplication.class);
        PP_PartnerApplication__c partner = (PP_PartnerApplication__c) new BLD_PartnerApplication().setPartnerData().setPrimaryContact(userContact.Id).mock();

        User userMock = (User) new BLD_USER().contactId(userContact.Id).mock();

        mocks.startStubbing();
        mocks.when(contactMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactMock.selectByUserId(new Set<Id>{ testUser.Id })).thenReturn(new List<Contact>{ userContact });
        mocks.when(partnerMock.sObjectType()).thenReturn(PP_PartnerApplication__c.SObjectType);
        mocks.when(partnerMock.selectByPrimaryContactId((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<PP_PartnerApplication__c>{ partner });
        mocks.stopStubbing();

        ORG_Application.selector.setMock(contactMock);
        ORG_Application.selector.setMock(partnerMock);

        Test.startTest();
        System.runAs(testUser) {
            PP_PartnerApplication__c result = PP_RegistrationForm_CTRL.getPartnerDetails();
            Assert.areEqual(result.name, 'Test Company', 'Name should match.');
        }
        Test.stopTest();
    }

    @IsTest
    static void updatePartnerTest() {
        PP_PartnerApplication__c partner = new BLD_PartnerApplication().getPartner();
        insert partner;

        string filename = 'Test.pdf';
        string base64 = 'JVBERi0xLjUKJYCBgoMKMSAwIG9iago8PC9GaWx0ZXIvRmxhdGVEZWNvZGUvRmlyc3QgMTQxL04gMjAvTGVuZ3==';
        partner.name = 'Testing';
        Test.startTest();
        String result = PP_RegistrationForm_CTRL.partnershipUpdate(partner, base64, filename);
        Test.stopTest();
        Assert.areEqual(result, 'Success', 'partnershipUpdate did not get passed.');
    }

    @IsTest
    static void initialiseOTPCodeTestPass() {
        PP_PartnerApplication__c partner = new BLD_PartnerApplication().getPartner();
        insert partner;
        Test.startTest();
        SRV_OTP.Response res = PP_RegistrationForm_CTRL.initialiseOTPCode(partner.id);
        Test.stopTest();
        Assert.areEqual(res.issuccess, true, 'initialiseOTPCode did not return true.');
    }

    @IsTest
    static void initialiseOTPCodeTestFail() {
        try {
            Test.startTest();
            SRV_OTP.Response res = PP_RegistrationForm_CTRL.initialiseOTPCode('abc');
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areEqual('Invalid id: abc', ex.getMessage(), 'Please enter correct Id.');
        }
    }

    @IsTest
    static void validateOTPCodeTestPass() {
        PP_PartnerApplication__c partner = new BLD_PartnerApplication().getPartner();
        insert partner;

        PP_RegistrationForm_CTRL.initialiseOTPCode(partner.id);
        OTPRequest__c req = [SELECT id, code__c FROM OTPRequest__c WHERE RelatedRecordID__c = :partner.id];

        Test.startTest();
        SRV_OTP.Response res = PP_RegistrationForm_CTRL.validateOTPCode(req.code__c, partner.id);
        Test.stopTest();
        Assert.areEqual(res.isSuccess, true, 'Code did not get validated.');
    }
}