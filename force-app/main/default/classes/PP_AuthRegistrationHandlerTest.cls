/**
 * @description       : Test class for PP_AuthRegistrationHandler
 * @author            : Jaco de Lange
 * @last modified on  : 01-29-2024
 * @last modified by  : Jaco de Lange
**/
@isTest
public class PP_AuthRegistrationHandlerTest {

    private static final string ID_TEST_KEY = 'testId';
    private static final string FIRST_NAME_TEST_KEY = 'testFirst';
    private static final string LAST_NAME_TEST_KEY = 'testLast';
    private static final string FIRST_NAME_LAST_NAME_TEST_KEY = FIRST_NAME_TEST_KEY+''+LAST_NAME_TEST_KEY;
    private static final string EMAIL_TEST_KEY = 'testuser@pc.co.za';
    private static final string USERNAME_TEST_KEY = 'testuserlong';
    private static final string EMAIL_ENCODING_TEST_KEY = 'en_US';
    private static final String AUTH_PROVIDER_NAME_TEST_KEY = 'ping';

    @TestSetup
    static void setupData(){
        User adminUser = new User(
            ProfileID = [Select Id From Profile Where Name='System Administrator'].id,
            EmailEncodingKey = 'ISO-8859-1',
            UserRoleId = [Select Id From UserRole Where DeveloperName='Standard_Bank_Group'].id,
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            FirstName = 'first',
            LastName = 'last',
            Username = 'partnerconnect@standardbank.co.za', 
            CommunityNickname = 'testUser123',
            Alias = 't1',
            Email = 'test@email.com',
            IsActive = true,
            User_CIB_Global_Area__c = 'CIBSA',
            User_Division__c = 'Credit',
            Business_Unit__c = 'CRM',
            Country = 'South Africa',
            State = 'Gauteng',
            Ping_UUID__c = 'testId',
            City = 'Johannesburg');
        insert adminUser;

        System.runAs(adminUser){
        
                Account acc = new Account (
                    Name = 'partner connect account',
                    OwnerId = adminUser.Id
                );
                insert acc;

                Contact con = new Contact (
                    AccountId = acc.id,
                    FirstName = 'john',
                    LastName = 'small',
                    Email = 'testuser@pp.co.za',
                    OwnerId = adminUser.Id,
                    RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Client Contact Record Type').getRecordTypeId()
                );
                insert con;  

                Contact con1 = new Contact (
                    AccountId = acc.id,
                    FirstName = 'john',
                    LastName = 'small',
                    Email = 'testuser@pc.co.za',
                    OwnerId = adminUser.Id,
                    RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Client Contact Record Type').getRecordTypeId()
                );
                insert con1;  

                PP_PartnerApplication__c pca = new PP_PartnerApplication__c (
                    PP_PrimaryContact__c = con1.Id,
                    OwnerId = adminUser.Id,
                    PP_Account__c = acc.Id,
                    PP_ApplicationStatus__c = 'Approved'
                );
                insert pca;

                PP_PartnerApplication__c pca1 = new PP_PartnerApplication__c (
                    PP_PrimaryContact__c = con.Id,
                    OwnerId = adminUser.Id,
                    PP_Account__c = acc.Id,
                    PP_ApplicationStatus__c = 'Approved'
                );
                insert pca1;
        }
    }
    @isTest
    public static void testCreateUser(){
        PP_AuthRegistrationHandler handler = new PP_AuthRegistrationHandler();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            //Existing User
            Auth.UserData sampleDataExist = new Auth.UserData(
                                                ID_TEST_KEY, 
                                                FIRST_NAME_TEST_KEY, 
                                                LAST_NAME_TEST_KEY,
                                                FIRST_NAME_LAST_NAME_TEST_KEY,
                                                EMAIL_TEST_KEY, 
                                                null, 
                                                USERNAME_TEST_KEY,
                                                EMAIL_ENCODING_TEST_KEY, 
                                                AUTH_PROVIDER_NAME_TEST_KEY, 
                                                null, 
                                                new Map<String, String>{
                                                    'language'=>'en_US', 
                                                    'email'=>'testuser@pc.co.za',
                                                    'first_name'=>'testFirstName',
                                                    'last_name'=>'testLastName',
                                                    'cellphonenumber'=>'1111111111',
                                                    'emailverificationstatus'=>'true',
                                                    'phone_number_verified'=>'true',
                                                    'sub'=>'testSub',
                                                    'id'=>'testId'});
                                                    
            Test.startTest();
                User u = handler.createUser(null, sampleDataExist);  
                handler.updateUser(u.Id, null, sampleDataExist);  
                PP_AuthRegistrationHandler.removePermissionSetsFromUser(u.Id);
            Test.stopTest();
                                    
            Assert.areEqual('testuser@pc.co.za', u.Email, 'Email expected to be testuser@pc.co.za');
            Assert.areEqual('testLastName', u.LastName, 'Last name expected to be testLastName');
            Assert.areEqual('testFirstName', u.FirstName, 'First name expected to be testFirstName');                                       
            }  
    }
}