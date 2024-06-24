/**
* 
* @description Test Class for Mall_PingRegistrationHandler
* @author Ankit Kumar
* @date June 2023
*/
@isTest
private class Mall_PingRegistrationHandler_Test {
    
    private static final String TEST_FIRST_CONTACT_LONGNAME = 'testuserlong@example.org';
    private static final String TEST_SFDC_NETWORK_ID = 'test';
    private static final String TEST_FIRST_CONTACT_FIRSTNAME = 'testFirst';
    private static final String TEST_FIRST_CONTACT_LASTNAME = 'testLast';
    private static String testFirstContactEmail = 'testuser@13example.org';
    private static String testFirstPingId = 'samplePingId';
    private static final String TEST_LANGUAGE = 'en_US';
    private static final String TEST_AUTH_PROVIDER_NAME = 'ping';
    private static final String TEST_SUFFIX = '.bcb';
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
    private static final String KEY_CELLPHONE = 'cellnumber';
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
            Account defaultAccount = new Account(
                Name = Mall_PingRegistrationHandler.BCB_PLATFORM_DEFAULT_ACCOUNT_NAME,
                OwnerId = adminUser.Id
            );
            insert defaultAccount;
           Account partnerAccount = new Account(
                Name = 'Partner Account',
                OwnerId = adminUser.Id
            );
            insert partnerAccount;
            
            Contact newContact = new Contact(
                AccountId = partnerAccount.Id,
                OwnerId = adminUser.Id,
                FirstName = TEST_FIRST_CONTACT_FIRSTNAME,
                LastName = TEST_FIRST_CONTACT_LASTNAME,
                email = testFirstContactEmail,
                RecordTypeId = UTL_RecordType.getRecordTypeId('Contact', Mall_PingRegistrationHandler.DEFAULT_CONTACT_RECORD_TYPE),
                Ping_Id__c = Mall_PingRegistrationHandler.PING_START_VALUE + testFirstPingId + Mall_PingRegistrationHandler.PING_END_VALUE
            );
            insert newContact;
            
        }
    }
    
    @IsTest
    public static void testCreateUser() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Mall_PingRegistrationHandler handler = new Mall_PingRegistrationHandler();
            Auth.UserData sampleData = new Auth.UserData(
                testFirstContactEmail,
                TEST_FIRST_CONTACT_FIRSTNAME,
                TEST_FIRST_CONTACT_LASTNAME,
                TEST_FIRST_CONTACT_FIRSTNAME + ' ' + TEST_FIRST_CONTACT_LASTNAME,
                testFirstContactEmail,
                null,
                TEST_FIRST_CONTACT_LONGNAME,
                TEST_LANGUAGE,
                TEST_AUTH_PROVIDER_NAME,
                null,
                new Map < String, String >{
                    TEST_KEY_LANGUAGE => TEST_LANGUAGE,
                        TEST_KEY_FIRST_NAME => TEST_FIRST_CONTACT_FIRSTNAME,
                        TEST_KEY_LAST_NAME => TEST_FIRST_CONTACT_LASTNAME,
                        TEST_KEY_SUB => testFirstContactEmail,
                        TEST_KEY_ID => testFirstPingId,
                        TEST_KEY_EMAIL => testFirstContactEmail,
                        TEST_KEY_CELL => '777888999',
                        KEY_CELLPHONE=> '77735345888999',
                        KEY_GENDER => 'Female',
                        KEY_EMAIL_VERIFIED => 'true',
                        KEY_NICKNAME => 'nicknametest',
                        KEY_CELLPHONE_VERIFIED => 'true'
                        }
            );
            Test.startTest();
            User u = handler.createUser(null, sampleData);
            u.email = 'test@test.com';
            insert u;
            User user = [Select ID, ContactId FROM User where Id = : u.Id];
            Assert.areEqual(user.Id, u.Id, 'should be equal');
            Contact c = new Contact ();
            c.Id = u.ContactId;
            update c;
            handler.updateUser(u.Id, null, sampleData);
            sampleData.attributeMap.put(TEST_KEY_EMAIL, testFirstContactEmail);
            u = handler.createUser(null, sampleData);
            handler.updateUser(u.Id, null, sampleData); 
            testFirstContactEmail = 'testuser@14example.org';
            testFirstPingId = 'samplePingId1';
            Auth.UserData sampleData1 = new Auth.UserData(
                testFirstContactEmail,
                TEST_FIRST_CONTACT_FIRSTNAME,
                TEST_FIRST_CONTACT_LASTNAME,
                TEST_FIRST_CONTACT_FIRSTNAME + ' ' + TEST_FIRST_CONTACT_LASTNAME,
                testFirstContactEmail,
                null,
                TEST_FIRST_CONTACT_LONGNAME,
                TEST_LANGUAGE,
                TEST_AUTH_PROVIDER_NAME,
                null,
                new Map < String, String >{
                    TEST_KEY_LANGUAGE => TEST_LANGUAGE,
                        TEST_KEY_FIRST_NAME => TEST_FIRST_CONTACT_FIRSTNAME,
                        TEST_KEY_LAST_NAME => TEST_FIRST_CONTACT_LASTNAME,
                        TEST_KEY_SUB => testFirstContactEmail,
                        TEST_KEY_ID => testFirstPingId,
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
            List<User> userRecords = SEL_Users.newInstance().selectByEmail(new Set<String>{'test@standardbank.co.za'});
            Assert.isTrue(userRecords != null, 'should not be null');
        }
    }
}