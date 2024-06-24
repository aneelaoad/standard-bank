/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-02-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_CTRL_Dashboard_Test {
  @isTest
  static void testGetDashboardDetails() {
    Account testAccount = new Account(Name = 'Test Account', Type = 'Client');
    insert testAccount;

    Application__c testApplication = new Application__c(
      Client__c = testAccount.Id,
      Status__c = 'Submitted'
    );
    insert testApplication;
    Application_Section__c testSection = new Application_Section__c(
      Application__c = testApplication.Id,
      Title__c = 'Test',
      ScreenApiName__c = 'Test',
      Order__c = 1,
      Screen_Type__c = 'Pre-Application',
      Status__c = 'Revision Requested'
    );
    insert testSection;

    Test.startTest();
    List<Application__c> applications = CIB_CTRL_Dashboard.getDashboardDetails();
    Test.stopTest();
 
    Assert.areNotEqual(
      null,
      applications,
      'Expected non-null list of applications'
    );
  }

  @isTest
  static void testGetLoggedInUserDetail() {
    // Call the method being tested
    Test.startTest();
    User loggedInUser = CIB_CTRL_Dashboard.getLoggedInUserDetail();
    Test.stopTest();

    // Verify the results
    Assert.areEqual(
      UserInfo.getUserId(),
      loggedInUser.Id,
      'Expected matching Id'
    );
    Assert.areEqual(
      UserInfo.getName(),
      loggedInUser.Name,
      'Expected matching Name'
    );
  }
}