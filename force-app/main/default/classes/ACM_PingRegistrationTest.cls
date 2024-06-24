/**
* 
* Test Class for ACM_PingRegistration
* @author Swapnil Walse (swapnil.walse@tetrad.co.za)
* @date October 2019
*/
@isTest
public class ACM_PingRegistrationTest {
    
    private static final String TEST_FIRST_CONTACT_LONGNAME = 'testuserlong@example.org';
    private static final String TEST_SFDC_NETWORK_ID = 'test';
    private static final String TEST_FIRST_CONTACT_FIRSTNAME = 'testFirst';
    private static final String TEST_FIRST_CONTACT_LASTNAME = 'testLast';
    private static String TEST_FIRST_CONTACT_EMAIL = 'testuser@13example.org';
    private static String TEST_FIRST_PING_ID = 'samplePingId';
    private static final String TEST_LANGUAGE = 'en_US';
    private static final String TEST_AUTH_PROVIDER_NAME = 'ping';
    private static final String TEST_SUFFIX = '.onehub';
    private static final String TEST_NEW_USER_EMAIL = 'testnewuser@example.org';
    private static final String TEST_NEW_USER_FIRST_NAME = 'testNewFirst';
    private static final String TEST_NEW_USER_LAST_NAME = 'testNewLast';
    private static final String TEST_NEW_USER_LONG_NAME = 'testnewuserlong';
    private static final String TEST_FIRST_USER_ALIAS = 'testFirs';
    private static final String TEST_USER_NULL_CHECK = 'User should be null for internal user';
    private static final String TEST_KEY_LANGUAGE = 'language';
    private static final String TEST_KEY_NETWORK = 'sfdc_networkid';
    private static final String TEST_KEY_FIRST_NAME = 'first_name';
    private static final String TEST_KEY_LAST_NAME = 'last_name';
    private static final String TEST_KEY_EMAIL = 'email';
    private static final String TEST_KEY_CELL = 'cellphonenumber';
    private static final String TEST_KEY_SUB = 'sub';
    private static final String TEST_KEY_ID = 'id';
    private static final String TEST_USER_NAME = 'test@test.com';
    private static final String TEST_CONTACT_FIRST_NAME = 'Test';
    private static final String TEST_CONTACT_LAST_NAME = 'Contact';
    private static final String KEY_GENDER = 'gender';
    private static final String KEY_CELLPHONE = 'phone_number';
    private static final String KEY_EMAIL_VERIFIED = 'emailverificationstatus';
    private static final String KEY_NICKNAME = 'nickname';
    private static final String KEY_CELLPHONE_VERIFIED = 'phone_number_verified';
    
    @TestSetup
    static void setup() {
        
        User adminUser = new User(
            ProfileID = [Select Id From Profile Where Name='System Administrator'].id,
            EmailEncodingKey = 'ISO-8859-1',
            UserRoleId = [Select Id From UserRole Where DeveloperName='Standard_Bank_Group'].id,
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            FirstName = 'first',
            LastName = 'last',
            Username = 'ACMpingtest@standardbank.co.za', 
            CommunityNickname = 'testUser123',
            Alias = 't1',
            Email = 'no@email.com',
            IsActive = true,
            User_CIB_Global_Area__c = 'CIBSA',
            User_Division__c = 'Credit',
            Business_Unit__c = 'CRM',
            Country = 'South Africa',
            State = 'Gauteng',
            City = 'Johannesburg');
        
        Database.insert(adminUser);
        
        System.runAs(adminUser){
            Account ACMAccount = new Account(
                Name = ACM_PingRegistration.DEFAULT_ACCOUNT_NAME,
                OwnerId = adminUser.Id
            );
            insert ACMAccount;
             Account ACMAccount1 = new Account(
                Name ='Standard Bank Employees',
                OwnerId = adminUser.Id
            );
            insert ACMAccount1;
            Contact newContact = new Contact(
                AccountId = ACMAccount.Id,
                OwnerId = adminUser.Id,
                FirstName = TEST_FIRST_CONTACT_FIRSTNAME,
                LastName = TEST_FIRST_CONTACT_LASTNAME,
                email = TEST_FIRST_CONTACT_EMAIL,
                RecordTypeId = UTL_RecordType.getRecordTypeId('Contact', ACM_PingRegistration.DEFAULT_CONTACT_RECORD_TYPE),
                Ping_Id__c = ACM_PingRegistration.PING_START_VALUE + TEST_FIRST_PING_ID + ACM_PingRegistration.PING_END_VALUE
            );
            insert newContact;
        }
    }
    
    @IsTest
    public static void testCreateUser() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            ACM_PingRegistration handler = new ACM_PingRegistration();
            Auth.UserData sampleData = new Auth.UserData(
                TEST_FIRST_CONTACT_EMAIL,
                TEST_FIRST_CONTACT_FIRSTNAME,
                TEST_FIRST_CONTACT_LASTNAME,
                TEST_FIRST_CONTACT_FIRSTNAME + ' ' + TEST_FIRST_CONTACT_LASTNAME,
                TEST_FIRST_CONTACT_EMAIL,
                null,
                TEST_FIRST_CONTACT_LONGNAME,
                TEST_LANGUAGE,
                TEST_AUTH_PROVIDER_NAME,
                null,
                new Map < String, String >{
                    TEST_KEY_LANGUAGE => TEST_LANGUAGE,
                        TEST_KEY_FIRST_NAME => TEST_FIRST_CONTACT_FIRSTNAME,
                        TEST_KEY_LAST_NAME => TEST_FIRST_CONTACT_LASTNAME,
                        TEST_KEY_SUB => TEST_FIRST_CONTACT_EMAIL,
                        TEST_KEY_ID => TEST_FIRST_PING_ID,
                        TEST_KEY_EMAIL => 'test1@test.com',
                        TEST_KEY_CELL => '777888999',
                        KEY_CELLPHONE=> '77735345888999',
                        KEY_GENDER => 'Female',
                        KEY_EMAIL_VERIFIED => 'true',
                        KEY_NICKNAME => 'nicknametest',
                        KEY_CELLPHONE_VERIFIED => 'true'
                        }
            );
            Test.startTest();
            DMN_Profile testProfile = new DMN_Profile();
            User u = handler.createUser(null, sampleData);
            u.email = 'test@test.com';
            insert u;
            handler.updateUser(u.Id, null, sampleData);
            sampleData.attributeMap.put(TEST_KEY_EMAIL, TEST_FIRST_CONTACT_EMAIL);
            u = handler.createUser(null, sampleData);
            handler.updateUser(u.Id, null, sampleData); 
            TEST_FIRST_CONTACT_EMAIL = 'testuser@14example.org';
            TEST_FIRST_PING_ID = 'samplePingId1';
            Auth.UserData sampleData1 = new Auth.UserData(
                TEST_FIRST_CONTACT_EMAIL,
                TEST_FIRST_CONTACT_FIRSTNAME,
                TEST_FIRST_CONTACT_LASTNAME,
                TEST_FIRST_CONTACT_FIRSTNAME + ' ' + TEST_FIRST_CONTACT_LASTNAME,
                TEST_FIRST_CONTACT_EMAIL,
                null,
                TEST_FIRST_CONTACT_LONGNAME,
                TEST_LANGUAGE,
                TEST_AUTH_PROVIDER_NAME,
                null,
                new Map < String, String >{
                    TEST_KEY_LANGUAGE => TEST_LANGUAGE,
                        TEST_KEY_FIRST_NAME => TEST_FIRST_CONTACT_FIRSTNAME,
                        TEST_KEY_LAST_NAME => TEST_FIRST_CONTACT_LASTNAME,
                        TEST_KEY_SUB => TEST_FIRST_CONTACT_EMAIL,
                        TEST_KEY_ID => TEST_FIRST_PING_ID,
                        TEST_KEY_EMAIL => 'test2@test.com',
                        TEST_KEY_CELL => '777888999',
                        KEY_CELLPHONE=> '77735345888999',
                        KEY_GENDER => 'Female',
                        KEY_EMAIL_VERIFIED => 'true',
                        KEY_NICKNAME => 'nickname165_test',
                        KEY_CELLPHONE_VERIFIED => 'true'
                        }
            );
            User u1 = handler.createUser(null, sampleData1);
            u1.email = 'test@standardbank.co.za';
            insert u1;
            Test.stopTest();
        }
    }
}