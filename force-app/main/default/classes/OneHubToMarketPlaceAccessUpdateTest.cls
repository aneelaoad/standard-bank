/**
 * @author  Mathew Hunter
 * @date    2022/04/05
 * @description Test class for the OneHubToMarketPlaceAccessUpdate batch
 */
@isTest
private class OneHubToMarketPlaceAccessUpdateTest {

    private static Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    private static Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    private static UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Corporate_Investment_Banking' LIMIT 1];
    private static UserRole userRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'StandardBankEmployeesCustomerUser' LIMIT 1];
    private static Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'OneHub Community User Login' LIMIT 1];
    private static Profile wrongProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
    @TestSetup
    static void setupData() {       

		User testAdminUser;
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<User> positiveTest = new List<User>();
        List<User> negativeTest;
        List<User> testUsers = new List<User>();

        try {

            testAdminUser = createUser(1).get(0);
            testAdminUser.ProfileId = adminProfile.Id;
            testAdminUser.UserRoleId = adminRole.Id;

            insert testAdminUser;

            System.runAs(testAdminUser) {
            
                for (Integer i = 0; i < 10; i++) {

                    Account portalAccount = new Account(Name = 'TestAccount');
                    accountList.add(portalAccount);
        
                }
        
                insert accountList;

                for (Account a : [SELECT Id FROM Account WHERE Name = 'TestAccount']) {

                    Contact contact = new Contact(
        
                        FirstName = 'Test',
                        Lastname = 'McTesty',
                        Email = System.now().millisecond() + 'test@test.com',
                        AccountId = a.Id
        
                    );
        
                    contactList.add(contact);
        
                }
        
                insert contactList;

                for (Contact c : [SELECT Id FROM Contact WHERE FirstName = 'Test' AND LastName = 'McTesty']) {
                
                    User u = createUser(testProfile.Id, c, userRole.Id);
                    positiveTest.add(u);
        
                }

                negativeTest = createUser(10);

                insert positiveTest;
                insert negativeTest;

            }

        } catch (DmlException e) {

            System.debug('An unexpected error has occurred: ' + e.getMessage());
            
        } 

    }

    @isTest
    static void assignPermissionSet() {
        
        Test.startTest();

        OneHubToMarketPlaceAccessUpdate permAssignmentBatch = new OneHubToMarketPlaceAccessUpdate();
        Id result = Database.executeBatch(permAssignmentBatch);

        Test.stopTest();

        Integer psa = [

            SELECT 
                COUNT() 
            FROM 
                PermissionSetAssignment 
            WHERE 
                AssigneeId IN (

                    SELECT 
                        Id 
                    FROM 
                        User 
                    WHERE 
                        Email = 'testUser@test123.com'
                ) AND 
                PermissionSet.Name = 'API_Marketplace_Member'

        ];

        System.assertEquals(10, psa, 'Users were not assigned the correct permission');

    }

    @isTest
    static void wrongProfileTest() {

        Test.startTest();

        OneHubToMarketPlaceAccessUpdate permAssignmentBatchNegative = new OneHubToMarketPlaceAccessUpdate();
        Id result = Database.executeBatch(permAssignmentBatchNegative);

        Test.stopTest(); 

        Integer psa = [

            SELECT 
                COUNT() 
            FROM 
                PermissionSetAssignment 
            WHERE 
                AssigneeId IN (

                    SELECT 
                        Id 
                    FROM 
                        User 
                    WHERE 
                        Email = 'testStandardUser@test123.com'
                        
                ) AND 
                PermissionSet.Name = 'API_Marketplace_Member'

        ];
        
        System.assertEquals(0, psa, 'Users were assigned incorrect permissions');

    }

    private static User createUser(Id profileId, Contact contact, Id userRoleId) {

        User testUser = new User(

            FirstName = 'Test',
            LastName = String.valueOf(Crypto.getRandomInteger()).left(4) + 'Test',
            Username = String.valueOf(Crypto.getRandomInteger()).left(4) + 'testUser@test.com',
            Email ='testUser@test123.com',
            TimeZoneSidKey = 'Africa/Johannesburg',
            Alias = String.valueOf(Crypto.getRandomInteger()).left(4) + 'Test',
            IsActive = true,
            ProfileId = profileId,
            ContactId = contact.Id,
            User_CIB_Global_Area__c = 'Africa Regions',
            User_Division__c = 'Credit',
            Business_Unit__c = 'Agriculture',
            Country = 'South Africa',
            City = 'Rosebank',
            State = 'Gauteng',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'

        );

        return testUser;

    }

    public static List<User> createUser(Integer numberOfUsers) {
        
        List<User> userList = new List<User>();

        for (Integer i = 0; i < numberOfUsers; i++) {

            User testUser = new User(

                FirstName = 'Test',
                LastName = 'Test' + i,
                Username = i +'testUser' + i +'@test' + i + '.com',
                Email ='testStandardUser@test123.com',
                TimeZoneSidKey = 'Africa/Johannesburg',
                Alias = 'Te' + i + 'st',
                IsActive = true,
                ProfileId = standardUserProfile.Id,
                User_CIB_Global_Area__c = 'Africa Regions',
                User_Division__c = 'Credit',
                Business_Unit__c = 'Agriculture',
                Country = 'South Africa',
                City = 'Rosebank',
                State = 'Gauteng',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'

            );

            userList.add(testUser);

        }
        
        return userList;

    }

}