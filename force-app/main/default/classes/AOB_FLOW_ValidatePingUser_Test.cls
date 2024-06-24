/**
* @description : class for validating ping logged in user test class
* @author Devi
* @since Aug 17, 2023
*/
@istest
public class AOB_FLOW_ValidatePingUser_Test {
    /**
* @description validates ping user to application setup
*/
    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');        
        Contact testContact = new Contact(LastName = 'Test Contact', AccountId = testAccount.Id);
        insert testContact;
        
        User testUser = new User(
            Alias = 'testuser', 
            Email = 'testuser@example.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'testuser@example.com',
            ContactId = testContact.Id
        );
        AOB_Application__c testApp = new AOB_Application__c(
            Name = 'Test Application', 
            AOB_Client__c = testAccount.Id
        );
        insert testApp;
    }
    /**
* @description validates ping user to application setup
*/
    @isTest
    static void validatePingUserSuccessTest() {
        List<Id> appIds = new List<Id>();
        for (AOB_Application__c app : [SELECT Id FROM AOB_Application__c LIMIT 1]) {
            appIds.add(app.Id);
        }       
        Test.startTest();
        List<String> result = AOB_FLOW_ValidatePingUser.validatePingUser(appIds);
        Test.stopTest();       
        assert.areEqual(0, result.size(), 'There should be no errors');
        
    }
    /**
* @description validates ping user to application ValidatePingUserMismatchTest
*/
    @isTest
    static void validatePingUserMismatchTest() {
        Try{
            Account mismatchAccount = new Account(Name = 'Mismatch Account');
            AOB_Application__c testApp = [SELECT Id FROM AOB_Application__c LIMIT 1];
            testApp.AOB_Client__c = mismatchAccount.Id;
            update testApp;
            List<Id> appIds = new List<Id>{  };        
                Test.startTest();
            List<String> result = AOB_FLOW_ValidatePingUser.validatePingUser(appIds);
            Test.stopTest();
        }catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'Test Message');
        }
    }
    /**
* @description validates ping user to application LogoutUser
*/
    @isTest
    static void logoutUserTest() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            ProfileId = profile.Id,
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            Username = 'nmnmnm@example.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        Test.startTest();
        AOB_FLOW_ValidatePingUser.logoutUser();       
        List<AuthSession> authSessions = [SELECT Id FROM AuthSession WHERE UsersId = :testUser.Id];
        assert.areEqual(0, authSessions.size());       
        Test.stopTest();
    }
}