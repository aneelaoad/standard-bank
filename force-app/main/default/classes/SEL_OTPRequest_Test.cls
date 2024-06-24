/**
 * @description       :
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             :
 * @last modified on  : 03-10-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
 **/
@isTest
public class SEL_OTPRequest_Test {
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
    public static void selectByRelatedRecordIdTest() {
        PP_PartnerApplication__c partner = new BLD_PartnerApplication().getPartner();
        insert partner;
        insert new List<OTPRequest__c>{ new OTPRequest__c(code__c = CMN_UTIL_Random.randomAlphanumeric(Integer.valueOf(6)).toUpperCase(), RelatedRecordID__c = partner.id) };
        test.startTest();
        List<OTPRequest__c> otpRecord = SEL_OTPRequest.newInstance().selectByRelatedRecordId(partner.id);
        test.stopTest();

        Assert.isTrue(otpRecord.size() > 0, 'Specified "relatedRecordId" record was not found.');
    }
}