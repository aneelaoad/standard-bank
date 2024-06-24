/**
 * Test class for OSB_Congrataulation
 *
 * @author Wayde Fagan
 * @date March 2020
 */
@IsTest(IsParallel=true)
public class OSB_Congratulation_Ctrl_Test {
    private static String TEST_USER_NAME = 'test@test.com';
    private static String TEST_CONTACT_PHONE = '123123123';
    private static String TEST_CONTACT_DIALING_CODE = 'South Africa +27';
    private static String TEST_USER_FIRSTNAME = 'Test';
    private static String TEST_CONTACT_ACCESS_ROLE = 'Authorised Person';
    private static String TEST_CONTACT_FISRT_NAME = 'Test';
    private static String TEST_CONTACT_FISRT_MANAGER = 'Test Manager';
    private static String TEST_CONTACT_LAST_NAME = 'Contact';
    private static String TEST_CONTACT_LAST_NAME_MANAGER = 'Manager';
    private static final String TEST_CONTACT_EMAIL = 'test@Contact.testcom';
    private static final String TEST_CONTACT_EMAIL_MANAGER = 'manager@Contact.testcom';
    private static User testUser {
        get {
            if(testUser == null) {
                testUser = [SELECT Id, ContactId,Email, Phone FROM User WHERE Username = :TEST_USER_NAME LIMIT 1];
            }
            return testUser;
        }
        set;
    }

    @TestSetup
    static void setup() {
        String TEST_CONTACT_PING_ID = '123456789';
        Account a = (Account) new BLD_Account().commitWork().getRecord();

        Contact communityManagerCon = (Contact) new BLD_Contact()
            .accountId(a.Id)
            .name(TEST_CONTACT_FISRT_MANAGER,TEST_CONTACT_LAST_NAME_MANAGER)
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
            .email(TEST_CONTACT_EMAIL_MANAGER)
            .pingId(TEST_CONTACT_PING_ID)
            .commitWork().getRecord();

        Contact con = (Contact) new BLD_Contact()
            .accountId(a.Id)
            .name(TEST_CONTACT_FISRT_NAME,TEST_CONTACT_LAST_NAME)
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
            .communityAccessManager(communityManagerCon.Id)
            .pingId(TEST_CONTACT_PING_ID)
            .email(TEST_CONTACT_EMAIL)
            .commitWork().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            User u = (User) new BLD_USER()
                .profile(DMN_Profile.ONE_HUB_COMMUNITY)
                .userName(TEST_USER_NAME)
                .contactId(con.Id)
                .email(TEST_USER_NAME)
                .firstName(TEST_USER_FIRSTNAME)
                .phone(TEST_CONTACT_PHONE)
                .commitWork().getRecord();
        }
    }
    
 	@IsTest
    static void getContactName() {
        String managerName;
        Test.startTest();
        System.runAs(testUser) {
            managerName = OSB_Congratulation_Ctrl.getContactName();
        }
        Test.stopTest();
        System.assertEquals('Test Manager Manager', managerName);
    }
}