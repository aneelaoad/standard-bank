/**
 * @description       :
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             :
 * @last modified on  : 03-10-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
 **/
@IsTest(seeAllData=false)
public class SRV_OTP_Test {
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
    public static void initialisePass() {
        PP_PartnerApplication__c partner = new BLD_PartnerApplication().getPartner();
        insert partner;

        SRV_OTP service = (SRV_OTP) SRV_OTP.newInstance();
        service.initialise('Partner_Connect', partner.id);
        SRV_OTP.Response res = service.requestCode();
        Assert.areEqual(res.isSuccess, true, 'Response class returned false.');
    }

    @IsTest
    static void initialiseFail() {
        try {
            Test.startTest();
            SRV_OTP service = (SRV_OTP) SRV_OTP.newInstance();
            service.initialise('Partner_Connect', '123');
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areEqual('Invalid id: 123', ex.getMessage(), 'initialiseFail failed');
        }
    }
    @IsTest
    static void notInitialise() {
        try {
            Test.startTest();
            SRV_OTP service = (SRV_OTP) SRV_OTP.newInstance();
            service.requestCode();
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areEqual('Service not initialised. Please call the "initialise" method first.', ex.getMessage(), 'notInitialise failed');
        }
    }

    @IsTest
    static void initialiseSettingNameNull() {
        PP_PartnerApplication__c partner = new BLD_PartnerApplication().getPartner();
        insert partner;
        SRV_OTP service = (SRV_OTP) SRV_OTP.newInstance();
        try {
            Test.startTest();
            service.initialise('', partner.id);
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areEqual('Invalid parameters, you must specify a "settingName", "relatedRecordId".', ex.getMessage(), 'initialiseSettingNameNull failed.');
        }
    }

    @IsTest
    static void validateOTPCodeTestPass() {
        PP_PartnerApplication__c partner = new BLD_PartnerApplication().getPartner();
        insert partner;

        SRV_OTP service = (SRV_OTP) SRV_OTP.newInstance();
        service.initialise('Partner_Connect', partner.id);
        service.requestCode();
        OTPRequest__c req = [SELECT id, code__c FROM OTPRequest__c WHERE RelatedRecordID__c = :partner.id];

        Test.startTest();
        SRV_OTP.Response res = service.validateCode(req.code__c);
        Test.stopTest();
        Assert.areEqual(res.isSuccess, true, 'Response class has returned false.');
    }

    @IsTest
    static void validateOTPCodeTestOTPRequestNull() {
        PP_PartnerApplication__c partner = new BLD_PartnerApplication().getPartner();
        insert partner;

        SRV_OTP service = (SRV_OTP) SRV_OTP.newInstance();
        service.initialise('Partner_Connect', partner.id);
        Test.startTest();
        SRV_OTP.Response res = service.validateCode('hnjkikjj');
        Test.stopTest();
        Assert.areEqual('Invalid code, request a new code.', res.message, 'Code is valid.');
    }

    @IsTest
    static void initialiseOTPRequestLimit() {
        PP_PartnerApplication__c partner = new BLD_PartnerApplication().getPartner();
        insert partner;

        SRV_OTP service = (SRV_OTP) SRV_OTP.newInstance();
        service.initialise('Partner_Connect', partner.id);
        SRV_OTP.Response res;
        Test.startTest();
        for (Integer i = 0; i < 6; i++) {
            res = service.requestCode();
        }

        Test.stopTest();
        Assert.areEqual('Number of requests exceeded, please try again later.', res.message, 'Number of requests did not get exceeded.');
    }

    @IsTest
    static void initialiseOTPAttemptLimit() {
        PP_PartnerApplication__c partner = new BLD_PartnerApplication().getPartner();
        insert partner;
        SRV_OTP.Response res;
        SRV_OTP service = (SRV_OTP) SRV_OTP.newInstance();
        service.initialise('Partner_Connect', partner.id);
        service.requestCode();
        Test.startTest();
        for (Integer i = 0; i < 6; i++) {
            res = service.validateCode('kmjiikkj');
        }

        Test.stopTest();
        Assert.areEqual('Number of attempts exceeded, please try again later.', res.message, 'Number of attempts did not get exceeded.');
    }
    @IsTest
    static void initialiseOTPRecordLock() {
        PP_PartnerApplication__c partner = new BLD_PartnerApplication().getPartner();
        insert partner;
        SRV_OTP.Response res;
        SRV_OTP service = (SRV_OTP) SRV_OTP.newInstance();
        service.initialise('Partner_Connect', partner.id);
        service.requestCode();
        Test.startTest();
        for (Integer i = 0; i < 7; i++) {
            res = service.validateCode('kmjiikkj');
        }

        Test.stopTest();
        Assert.areEqual('Access locked temporarily, please try again later.', res.message, 'Locked functionality is not working properly.');
    }
}