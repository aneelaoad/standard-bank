/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-03-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_FLOW_NormalizeApplicationSectio_Test {
  @isTest
  static void testProcessApplicationSections() {
    // Create test data
    Application__c app = new Application__c();
    insert app;
    // Call the method being tested
    Test.startTest();
    CIB_FLOW_NormalizeApplicationSections.processApplicationSections(
      new List<Id>{ app.Id }
    );
    Test.stopTest();

    // Verify the results
    List<Application_Section__c> sections = [
      SELECT Id, Title__c, ScreenApiName__c, Screen_Type__c, Order__c
      FROM Application_Section__c
      WHERE Application__c = :app.Id
      ORDER BY Order__c
    ];
    Assert.areEqual('Account Type Screen', sections[1].Title__c, 'Title should be Account Type Screen');
    Assert.areEqual('cib_comp_accountType', sections[1].ScreenApiName__c, 'ScreenApiName should be cib_comp_accountType');
    Assert.areEqual('Pre-Application', sections[1].Screen_Type__c, 'Screen_Type should be Pre-Application'); 
  }
}