/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-03-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_CTRL_WelcomeLetterBankAccounts_Test {
  @isTest
  static void testBankAccounts() {
    // Create test data
    Application__c app = new Application__c();
    insert app;

    RecordType rt = [
      SELECT Id
      FROM RecordType
      WHERE
        SObjectType = 'Application_Line_Item__c'
        AND DeveloperName = 'Bank_Account'
      LIMIT 1
    ];

    Application_Line_Item__c ali1 = new Application_Line_Item__c(
      Application__c = app.Id,
      RecordTypeId = rt.Id,
      CIB_AccountIBAN__c = 'IBAN1',
      CIB_AccountNumber__c = '1234567890',
      CIB_Currency__c = 'AG - XCD',
      CIB_AccountType__c = 'Current Account'
    );
    Application_Line_Item__c ali2 = new Application_Line_Item__c(
      Application__c = app.Id,
      RecordTypeId = rt.Id,
      CIB_AccountIBAN__c = 'IBAN2',
      CIB_AccountNumber__c = '0987654321',
      CIB_Currency__c = 'AG - XCD',
      CIB_AccountType__c = 'Current Account Plus'
    );
    insert new List<Application_Line_Item__c>{ ali1, ali2 };

    // Instantiate the class
    CIB_CTRL_WelcomeLetterBankAccounts controller = new CIB_CTRL_WelcomeLetterBankAccounts();
    controller.appId = app.Id;

    // Test the bankAccounts property
    List<Application_Line_Item__c> bankAccounts = controller.bankAccounts;
    Assert.areEqual(2, bankAccounts.size(), 'There should be 2 bank accounts');
    Assert.areEqual(
      'IBAN1',
      bankAccounts[0].CIB_AccountIBAN__c,
      'The first bank account should have IBAN1'
    );
    Assert.areEqual(
      '1234567890',
      bankAccounts[0].CIB_AccountNumber__c,
      'The first bank account should have 1234567890'
    );
    Assert.areEqual(
      'AG - XCD',
      bankAccounts[0].CIB_Currency__c,
      'The first bank account should have AG - XCD'
    );
  }
}