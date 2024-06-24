/**
 * @description       : 
 * @author            : silva.macaneta@standardbank.co.za
 * @group             : 
 * @last modified on  : 10-03-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
**/
@isTest
public class CIB_FLOW_NormalizeBankAccounts_Test {
  @isTest
  static void testUpdateApplicationLineItems() {
    // Create test data
    Application__c app = new Application__c(      
      CIB_AT_IsCurrentAccount__c = true,
      CIB_AT_IsCurrentAccountPlus__c = true,
      CIB_AT_CurrentAccountCurrencies__c = 'ZA - ZAR;AD - EUR',
      CIB_AT_CurrentAccountPlusCurrencies__c = 'GB - GBP'
    );
    insert app;

    // Call the method being tested
    Test.startTest();
    CIB_FLOW_NormalizeBankAccounts.updateApplicationLineItems(
      new List<Id>{ app.Id }
    );
    Test.stopTest();

    // Verify the results
    List<Application_Line_Item__c> details = [
      SELECT Id, CIB_Currency__c, CIB_AccountType__c
      FROM Application_Line_Item__c
      WHERE Application__c = :app.Id
    ];
    Assert.areEqual(3, details.size(), 'Incorrect number of Application Line Items');
    Set<String> expectedCurrencies = new Set<String>{ 'ZA - ZAR', 'AD - EUR', 'GB - GBP' };
    Set<String> actualCurrencies = new Set<String>();
    for (Application_Line_Item__c detail : details) {
      actualCurrencies.add(detail.CIB_Currency__c);
    }
    Assert.areEqual(expectedCurrencies, actualCurrencies, 'Currencies are not as expected');
  }
}