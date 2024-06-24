/**
 * Test class for OSB_MarketGramPopup_Ctrl
 *
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @date March 2020
 */
@isTest
public class OSB_MarketGramPopup_Ctrl_Test {
	private static String TEST_USER_NAME = 'test@test12345test.com';
    private static String TEST_CONTACT_PHONE = '123123123';
    private static String TEST_CONTACT_ID = '12356467484313';
    private static User testUser {
        get {
            if(testUser == null) {
                testUser = [SELECT Id, ContactId,Email, Phone, Dialing_code__c FROM User WHERE Username = :TEST_USER_NAME LIMIT 1];
            }
            return testUser;
        }
        set;
    }
    
    @TestSetup
    static void setup() {
        String TEST_CONTACT_DIALING_CODE = 'South Africa +27';
        String TEST_USER_FIRSTNAME = 'Test';
        String TEST_CONTACT_FISRT_NAME = 'Test';
        String TEST_CONTACT_ACCESS_ROLE = 'Authorised Person';
        String TEST_CONTACT_LAST_NAME = 'Manager';

        Account a = (Account) new BLD_Account().commitWork().getRecord();

        Contact communityManagerCon = (Contact) new BLD_Contact()
            .accountId(a.Id)
			.name(TEST_CONTACT_FISRT_NAME,TEST_CONTACT_LAST_NAME)
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
            .commitWork().getRecord();

        Contact con = (Contact) new BLD_Contact()
            .accountId(a.Id)
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
			.communityAccessManager(communityManagerCon.Id)
            .email(TEST_USER_NAME)
			.identityNumber(TEST_CONTACT_ID)
            .commitWork().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            User u = (User) new BLD_USER()
                .useOneHub()
                .userName(TEST_USER_NAME)
                .contactId(con.Id)
                .phone(TEST_CONTACT_PHONE)
                .firstName(TEST_USER_FIRSTNAME)
                .dialingCode(TEST_CONTACT_DIALING_CODE)
				.email(TEST_USER_NAME)
                .commitWork().getRecord();
        }
    }
    
    @isTest
    static void testSaveCase(){
       Case MarketGramCase = (Case) new BLD_Case().setOSBData().suppliedEmail(TEST_USER_NAME).getRecord();
            SYSTEM.runAs(testUser){
        		Case result = OSB_MarketGramPopup_Ctrl.saveCase(MarketGramCase,TEST_CONTACT_ID,'');
                System.assertEquals(result.SuppliedEmail, TEST_USER_NAME);
            }
        }
            
}