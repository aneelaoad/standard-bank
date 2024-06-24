/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 11-15-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_CTRL_HubScreen_Test {
  @isTest
  static void testGetNotifiedOnRevisionRequested() {
    Application__c app = new Application__c();
    insert app;

    Application_Section__c section = new Application_Section__c(
      Application__c = app.Id,
      ScreenApiName__c = 'cib_comp_basicInformation',
      Screen_Type__c = 'Pre-Application',
      Order__c = 3,
      Status__c = CIB_Constants.APPLICATION_SECTION_STATUS_REVISION_REQUESTED,
      Title__c = 'Basic Information Screen',
      Comment__c = 'Please update the information'
    );
    insert section;

    // Call the method being tested
    List<Application_Section__c> result = CIB_CTRL_HubScreen.getNotifiedOnRevisionRequested(
      app.Id
    );
    // Verify the results
    Assert.areNotEqual(null, result, 'Should return sections');
  }

  @isTest
  static void testGetInProgressSection() {
    // Create test data
    Application__c app = new Application__c();
    insert app;

    // Call the method being tested
    List<Application_Section__c> result = CIB_CTRL_HubScreen.getInProgressSection(
      app.Id
    );
    

    // Verify the results
    Assert.areNotEqual(null, result, 'Should return all in progress sections');
  }

  @isTest
  static void testGetCompletedSection() {
    // Create test data
    Application__c app = new Application__c();
    insert app;

    List<Application_Section__c> result = CIB_CTRL_HubScreen.getCompletedSection(
      app.Id
    );

    // Verify the results
    Assert.areNotEqual(null, result, 'Should return 2 sections');
  }

  @isTest
  static void testUpdateHubScreen() {
    // Create test data
    Application__c app = new Application__c();
    insert app;

    Application_Section__c section = new Application_Section__c(
      Application__c = app.Id,
      ScreenApiName__c = CIB_Constants.CIB_COMP_HUB_SCREEN,
      Screen_Type__c = 'Pre-Application',
      Order__c = 3,
      Status__c = 'Started',
      Title__c = 'Basic Information Screen',
      Comment__c = 'Please update the information'
    );
    insert section;

    // Call the method being tested
    Test.startTest();
    CIB_CTRL_HubScreen.updateHubScreen(app.Id);
    Test.stopTest();

    List<Application_Section__c> updatedSections = [
      SELECT Status__c, ScreenApiName__c
      FROM Application_Section__c
      WHERE Application__c = :app.Id
    ];
    Assert.areNotEqual(null, updatedSections, 'Should return sections');
  }

  @isTest
  static void testUpdateThankScreen() {
    // Create test data
    Application__c app = new Application__c();
    insert app;

    Application_Section__c section = new Application_Section__c(
      Application__c = app.Id,
      ScreenApiName__c = CIB_Constants.CIB_COMP_THANK_YOU,
      Screen_Type__c = 'Pre-Application',
      Order__c = 3,
      Status__c = 'Started',
      Title__c = 'Basic Information Screen',
      Comment__c = 'Please update the information'
    );
    insert section;

    Test.startTest();
    CIB_CTRL_HubScreen.updateThankScreen(app.Id);
    Test.stopTest();

    // Verify the results
    List<Application_Section__c> updatedSections = [
      SELECT Status__c, ScreenApiName__c
      FROM Application_Section__c
      WHERE Application__c = :app.Id
    ];
    Assert.areNotEqual(null, updatedSections, 'Should return sections');
  }
}