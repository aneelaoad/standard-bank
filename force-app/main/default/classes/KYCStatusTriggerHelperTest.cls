/* @Class Name   : KYCStatusTriggerHelperTest
 * @Description  : Test class for KYCStatusTriggerHelper
 * @Created By   : Vishnu Teja V
 * @Created On   : 22 April 2015
 * @Modification Log:  
 * --------------------------------------------------------------------------------------------------
 * @Developer                Date                   Description
 * --------------------------------------------------------------------------------------------------
 * @Vishnu Teja V         22 April 2015     Created - Test Class for KYCTriggerHelper Class
 * @Abhishek V            07 July 2015      Modified - Included values for Client_Contact_Date__c, X1st_Client_follow_up__c, X2nd_Client_follow_up__c, X3rd_Client_follow_up__c inorder to avoid validation errors
 *
 * --------------------------------------------------------------------------------------------------- 
 * @Last Modified By  :   Petr Roubal        
 * @Last Modified On  :   Aug 2015
 * @Last Modified Reason  : EN-738, Onboarding: Integration back from CIF into SF 
 * ---------------------------------------------------------------------------------------------------
*/

@SuppressWarnings('PMD.AvoidHardcodingId')
@isTest(SeeAllData=false)
private class KYCStatusTriggerHelperTest {

    @IsTest
    static void testNotificationOfTasks(){
        
        List<Account> lstTestAccount = new List<Account> {
            (Account) new BLD_Account().useChild().getRecord()
        };
        insert lstTestAccount ;
        
        // create standard user 
        User user01 = (User) new BLD_USER().useCib().getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
        	insert user01;
        }

        Boolean isExceptionThrown = false;
        try {
            List<KYC_Status__c> lstKYCToInsert = new list<KYC_Status__c>();

            KYC_Status__c kyc = new KYC_Status__c();
            kyc.Client__c = lstTestAccount[0].id ;
            kyc.Escalated_to_Business__c = user01.id;
            kyc.Escalation_Date__c = date.today();
            kyc.Client_Contact_Date__c = date.today().addDays(-12);
            kyc.X1st_Client_follow_up__c = date.today().addDays(-9);
            kyc.X2nd_Client_follow_up__c = date.today().addDays(-6);
            kyc.X3rd_Client_follow_up__c  = date.today().addDays(-3);
            lstKYCToInsert.add(kyc);

            KYC_Status__c kyc2 = new KYC_Status__c();
            kyc2.Client__c = lstTestAccount[0].id ;
            lstKYCToInsert.add(kyc2);

            insert lstKYCToInsert;

            kyc2.Escalated_to_Business__c = user01.id;
            kyc2.Escalation_Date__c = date.today();
            kyc2.Client_Contact_Date__c = date.today().addDays(-12);
            kyc2.X1st_Client_follow_up__c = date.today().addDays(-9);
            kyc2.X2nd_Client_follow_up__c = date.today().addDays(-6);
            kyc2.X3rd_Client_follow_up__c  = date.today().addDays(-3);

            update kyc2;
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        System.assert(!isExceptionThrown);
    }

    @IsTest
    static void testKYCRejection(){
      
      EmailAddress__c oEmailVariable = new EmailAddress__c();
        oEmailVariable.Name = 'CDG Data Mailbox';
        oEmailVariable.Email__c = 'cdg@test.com';
        insert oEmailVariable;
        
        oEmailVariable = new EmailAddress__c();
        oEmailVariable.Name = 'CRM Data Mailbox';
        oEmailVariable.Email__c = 'crm@test.com';
        insert oEmailVariable;
        
        insert TEST_DataFactory.getCcSettings();

      List<Account> lstTestAccount = new List<Account> {
          (Account) new BLD_Account().useChild().name(DMN_Account.STANDARD_BANK_EMPLOYEES).withoutSfId(true).getRecord(),
          (Account) new BLD_Account().useChild().withoutSfId(true).getRecord()
      };
            
        insert lstTestAccount;

        // create Api User
        User user = (User) new BLD_USER().useSysAdmin().getRecord();
        
        system.runAs(new User(Id = UserInfo.getUserId())){
        	insert user;
        }
        
        Contact c1;
        system.runAs(user) {
            c1 = new Contact(FirstName = 'Joe', LastName = 'Root', Salutation = 'Mr.',
                    RecordTypeId = GlobalCache.getRecordTypeId('Contact', 'Bank Contact Record Type'),
                    Contact_Category__c = 'Manager',
                    Email = 'joe.root@test.com',
                    Phone = '123',
                    AccountId = lstTestAccount[0].Id,
                    User_CIB_Global_Area_Sync__c = 'CIBSA',
                    User_Division_Sync__c = 'Business Enablers',
                    User_Business_Unit_Sync__c = 'CRM IT',
                    User_Team_Sync__c = 'Developer',
                    User_Country_Sync__c = 'South Africa'
            );

            insert c1;
        }

        CaseConfiguration__c oCaseConfiguration = new CaseConfiguration__c();
        oCaseConfiguration.Name = 'CaseKYCConfiguration';
        oCaseConfiguration.RecordTypeId__c =
                (String)UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_USER_CASE).substring(0,15);
        oCaseConfiguration.MainCategory__c = 'Client On boarding';
        oCaseConfiguration.SubCategory__c = 'CIF Rejection';
        oCaseConfiguration.OwnerId__c = '00Gw0000001C2pd';
        oCaseConfiguration.CaseOrigin__c = 'Email';
        oCaseConfiguration.CasePriority__c = 'Medium';
        oCaseConfiguration.ContactId__c =  (c1.Id + '').substring(0,15); // '003g000000Rpe1x';
        insert oCaseConfiguration;
        
        // create Api User 
        User user01 = (User) new BLD_USER().useAPIUser().getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
        	insert user01;
        }
        

      System.runAs(user01) {
        Test.startTest();
        KYC_Status__c kyc = new KYC_Status__c();
          kyc.Client__c = lstTestAccount[0].id ;
          kyc.Entity_Code__c = 'SALL';
          insert kyc;
                   
          KYC_Status__c kyc2 = new KYC_Status__c();
          kyc2.Client__c = lstTestAccount[1].id ;
          kyc2.Entity_Code__c = 'SBSA';
          insert kyc2;
          Test.stopTest();
          
          KYC_Status__c[] nLstKYC = [select Id from KYC_Status__c where Client__c = :lstTestAccount[0].id ];
          system.assertNotEquals(nLstKYC.size(), 0);
          
          KYC_Status__c[] nLstKYC2 = [select Id from KYC_Status__c where Client__c = :lstTestAccount[1].id ];
          system.assertEquals(nLstKYC2.size(), 0);
      }

    }
}