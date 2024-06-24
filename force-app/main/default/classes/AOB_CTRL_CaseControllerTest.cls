/**
* Test class for AOB_CTRL_CaseController
* SFP-4835 
*
* @author Narendra
* @date October 2021
*/

@isTest
public class AOB_CTRL_CaseControllerTest {
    
    /**
    * @description test data setup for AOB_CTRL_CaseController
    */
    @testsetup 
    static void createTestData() {
         Case newCase = new Case();
        newCase.Status = 'New';
        newCase.Origin = 'Web';
        newCase.ChatKey__c = 'testkey';
        newCase.description= 'description';
        insert newCase;
        Account acct = new Account();
        acct.Name = 'testAcct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        cont.Outlook_Exchange_System_ID__c = 'test';
        insert cont;
        String EXTERNAL_USER_PROFILE = 'AOB_Authenticated Customer Community Plus Login';
        Profile userProfile = [select Name from Profile where Name = : DCN_Profile.SYS_ADMIN];
        User usr = new User(
            firstName = 'testUsrF',
            LastName = 'testUsrl',
            Alias = 'tstUsr',
            Email = 'testy.test@test.com',
            UserName='test'+ Math.random().format()+'user99@test.com',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey =  'en_US',
            ProfileId = userProfile.Id,
            IsActive=true,
            Contact_Sync_ID__c = cont.id,
            Outlook_Exchange_System_ID__c ='test',
            user_CIB_Global_area__c = 'CIBSA',
            user_division__c = 'Business Enablers',
            business_unit__C = 'CRM',
            country ='South Africa',
            state = 'South Africa',
            City = 'Johannesburg'
        );
        insert usr;
        entitlement e = new entitlement(name = 'FR240mins : Mon - Fri (8h00 - 17h00)',
                                       accountId = acct.id);
        insert e;
    }
    
    /**
    * @description test method for AOB_CTRL_CaseController.createCase 
    */
    @isTest 
    static void testCaseController() {
        try{
            user usr=[select id from user where email = 'testy.test@test.com' limit 1];
            System.runAs(usr){
                Test.startTest();
                string caseNum = AOB_CTRL_CaseController.createCase( 'description', 'applicationId');
                System.assert(caseNum != null);
                Test.stopTest();    
            }
        }Catch(Exception e){
            Assert.areNotEqual(null, e);
        }   
    }
    
    /**
    * @description test method for AOB_CTRL_CaseController.createCase Negative Scenario 
    */
    @isTest 
    static void testCaseControllerNegative1() {
        try{  
        user usr=[select id from user where email = 'testy.test@test.com'];
        System.runAs(usr){
            Test.startTest();
            string caseNum = AOB_CTRL_CaseController.createCase('description1', 'applicationId');
            Test.stopTest();   
        }
        }Catch(Exception e){
            Assert.areNotEqual(null, e);
        }
    }
    
    /**
    * @description test method for AOB_CTRL_CaseController.createCase Negative Scenario with case deletetion
    */
    @isTest 
    static void testCaseControllerNegative2() {
        try{  
        Case[] caseList=[select Id from Case];
        Delete caseList;
        user usr=[select id from user where email = 'testy.test@test.com'];
        System.runAs(usr){
            Test.startTest();
            string caseNum = AOB_CTRL_CaseController.createCase( 'description1', 'applicationId');
            Test.stopTest();   
        }
        }Catch(Exception e){
            Assert.areNotEqual(null, e);
        }
    }
}