/**
* Test class for CB_GM_CaseController_Test
* SFP-4835 
*
* @author Sharath Chandra (sharath.chintalapati@standardbank.co.za)
* @date October 2021
*/

@isTest
public class CB_GM_CaseController_Test {
    
    @testsetup 
    static void createTestData() {
        Case newCase = new Case();
        newCase.Status = 'New';
        newCase.Origin = 'Web';
        newCase.ChatKey__c = 'testkey';
        insert newCase;
        
        Account acct = new Account();
        acct.Name = 'testAcct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        cont.Outlook_Exchange_System_ID__c ='test';
        insert cont;
        
        Profile userProfile = [select Name from Profile where Name = : DCN_Profile.SYS_ADMIN];
        
        User usr = new User(
            firstName = 'testUsrF',
            LastName = 'testUsrL',
            Alias = 'tstUsr',
            Email = 'testy.test@test.com',
            UserName='test'+ Math.random().format()+'user99@test.com',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            ProfileId = userProfile.Id,
            IsActive=true,
            Contact_Sync_ID__c = cont.id,
            Outlook_Exchange_System_ID__c = 'test',
            user_CIB_Global_area__c = 'CIBSA',
            user_division__c = 'Business Enablers',
            business_unit__C = 'CRM',
            country = 'South Africa',
            state = 'South Africa',
            City = 'Johannesburg'
        );
        insert usr;
        entitlement e = new entitlement(name = 'FR240mins : Mon - Fri (8h00 - 17h00)',
                                       accountId = acct.id);
        insert e;
        
    }
    
    @isTest 
    static void testCaseController() {
        user usr=[select id from user where email = 'testy.test@test.com'];
        system.runAs(usr){
            Test.startTest();
            string caseNum = CB_GM_CaseController.createCase('subject', 'description');
            system.assert(caseNum != null);
            Test.stopTest();    
        }
        
    }
}