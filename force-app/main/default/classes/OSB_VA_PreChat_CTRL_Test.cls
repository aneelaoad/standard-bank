/**
 *
 * Test class for OSB_VA_PreChat_CTRL
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 */
@IsTest
public with sharing class OSB_VA_PreChat_CTRL_Test {
    private static final String TEST_USER_NAME = 'randomname3562@test.com';
    private static final String TEST_USER_EMAIL = 'randomname3533@test.com';
    private static final String OTHER_USER_NAME = 'random3562@test.com'; //SFP-5036 -Changes 
    private static final String OTHER_USER_EMAIL = 'random3533@test.com'; //SFP-5036 -Changes 
    private static final String NEW_USER_NAME = 'random35@test.com'; //SFP-5036 -Changes 
    private static final String NEW_USER_EMAIL = 'random35@test.com'; //SFP-5036 -Changes 
    private static final String TEST_CONTACT_PHONE = '123123123';
    private static final String TEST_USER_FIRST_NAME = 'Random5';
    private static final String TEST_USER_LAST_NAME = 'Name9';
    private static User testUser {
        get {
            if(testUser == null) {
                testUser = [SELECT Id, ContactId,Email, Phone FROM User WHERE Username = :TEST_USER_NAME LIMIT 1];
            }
            return testUser;
        }
        set;
    }
    //SFP-5036 -Changes START
    private static User otherUser {
        get {
            if(otherUser == null) {
                otherUser = [SELECT Id, Contact_Sync_Id__c, Email, Phone FROM User WHERE Username = :OTHER_USER_NAME LIMIT 1];
            }
            return OtherUser;
        }
        set;
    }
    
    private static User newUser {
        get {
            if(newUser == null) {
                newUser = [SELECT Id, Email, Phone FROM User WHERE Username = :NEW_USER_NAME LIMIT 1];
            }
            return newUser;
        }
        set;
    }
    //SFP-5036 -Changes END

    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Contact con = (Contact) new BLD_Contact(uow)
                .name(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME)
                .email(TEST_USER_EMAIL)
                .ownerId(UserInfo.getUserId())
                .communityAccessRole(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP)
                .account(
                        new BLD_Account(uow)
                )
                .getRecord();
        uow.commitWork();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            User u = (User) new BLD_USER()
                    .profile(DMN_Profile.ONE_HUB_COMMUNITY)
                    .userName(TEST_USER_NAME)
                    .contactId(con.Id)
                    .phone(TEST_CONTACT_PHONE)
                    .firstName(TEST_USER_FIRST_NAME)
                    .lastName(TEST_USER_LAST_NAME)
                    .email(TEST_USER_EMAIL)
                    .commitWork().getRecord();
            
            //SFP-5036 -Changes START
            user otherUser = (User) new BLD_USER()
                    .profile(DMN_Profile.SYSTEM_ADMINISTRATOR)
                    .userName(OTHER_USER_NAME)
                    .contactSyncId(con.Id)
                    .phone(TEST_CONTACT_PHONE)
                    .firstName(TEST_USER_FIRST_NAME)
                    .lastName(TEST_USER_LAST_NAME)
                    .email(OTHER_USER_EMAIL)
                    .commitWork().getRecord();
            
            user newUser = (User) new BLD_USER()
                    .profile(DMN_Profile.SYSTEM_ADMINISTRATOR)
                    .userName(NEW_USER_NAME)
                    .phone(TEST_CONTACT_PHONE)
                    .firstName(TEST_USER_FIRST_NAME)
                    .lastName(TEST_USER_LAST_NAME)
                    .email(NEW_USER_EMAIL)
                    .commitWork().getRecord();
            
            //SFP-5036 -Changes END
        }
    }

    @IsTest
    public static void testGetUserContactInfo() {
        System.runAs(testUser) {
            Test.startTest();
            Map<String, String> resultObj = OSB_VA_PreChat_CTRL.getCurrentUser();
            Test.stopTest();
            System.assertEquals(TEST_USER_EMAIL, resultObj.get('email'));
            System.assertEquals(testUser.Id, resultObj.get('userId'));
            System.assertEquals(TEST_USER_FIRST_NAME, resultObj.get('firstName'));
            System.assertEquals(TEST_USER_LAST_NAME, resultObj.get('lastName'));
        }
    }
    
    //SFP-5036 -Changes START
    @IsTest
    public static void testGetPreChatInfo(){
        Test.startTest();
        system.runAs(otherUser){
            Map<String, String> resultObj = CB_GM_PreChatCmpCnt.getCurrentUser(); 
            System.assertEquals(OTHER_USER_EMAIL, resultObj.get('email'));
            System.assertEquals(otherUser.Id, resultObj.get('userId'));
            System.assertEquals(TEST_USER_FIRST_NAME, resultObj.get('firstName'));
            System.assertEquals(TEST_USER_LAST_NAME, resultObj.get('lastName'));
            
        }
        
        system.runAs(newUser){
            Map<String, String> resultObj1 = CB_GM_PreChatCmpCnt.getCurrentUser(); 
            System.assertEquals(NEW_USER_EMAIL, 'random35@test.com');
        }
        Test.stopTest();
    }
    //SFP-5036 -Changes END
}