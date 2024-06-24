/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 11-15-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class SEL_CIBApplicationSection_Test {
  @testSetup
  static void setup() {
    // Create test data
    Application__c app = new Application__c();
    insert app;
  }

  @isTest
  static void testSelectWithoutCondition() {
    List<Application_Section__c> sections = new SEL_CIBApplicationSection()
      .selectWithoutCondition();
    Assert.areNotEqual(null, sections, 'Expected to retrieve sections');
  }

  @isTest
  static void testSelectSectionsById() {
    Test.startTest();
    new SEL_CIBApplicationSection()
      .selectSectionsById(null);
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      result.getCondition()
        .containsIgnoreCase(
          'id = :sectionId'
        ),
      'Expected to retrieve sections for the application'
    );
  }

  @isTest
  static void testSelectSectionsByApplicationId() {
    Test.startTest();
    new SEL_CIBApplicationSection()
      .selectSectionsByApplicationId(null);
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      result.getCondition()
        .containsIgnoreCase(
          'Application__c = :appId'
        ),
      'Expected to retrieve sections for the application'
    );
  }

  @isTest
  static void testSelectSectionsByApplicationscreenAPIName() {
    Test.startTest();
    new SEL_CIBApplicationSection()
      .selectSectionsByApplicationscreenAPIName(null, null);
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      result.getCondition()
        .containsIgnoreCase(
          'Application__c = :appId AND ScreenApiName__c=:screenAPIName'
        ),
      'Expected to retrieve sections for the application'
    );
  }

  @isTest
  static void testSelectHubScreenSections() {
    Test.startTest();
    new SEL_CIBApplicationSection()
      .selectHubScreenSections(null);
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      result.getCondition()
        .containsIgnoreCase(
          'Application__c = :recordId AND (NOT Title__c LIKE \'Welcome%\') AND (NOT Screen_Type__c IN(\'Home\', \'Final Section\'))'
        ),
      'Expected to retrieve sections for the application'
    );
  }
  @isTest
  static void testSelectByApplicationInProgress() {
    Test.startTest();
    new SEL_CIBApplicationSection()
      .selectByApplicationInProgress(null);
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      result.getCondition()
        .containsIgnoreCase(
          'Status__c != \'Submitted\' AND Status__c != \'Completed\' AND (Screen_Type__c = \'Application Section\' OR Screen_Type__c = \'Pre-Application\')'
        ),
      'Expected to retrieve sections for the application'
    );
  }
  @isTest
  static void testSelectByApplicationCompleted() {
    Test.startTest();
    new SEL_CIBApplicationSection()
      .selectByApplicationCompleted(null);
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      result.getCondition()
        .containsIgnoreCase(
          '(Status__c = \'Submitted\' OR Status__c = \'Completed\') AND (Screen_Type__c = \'Application Section\' OR Screen_Type__c = \'Pre-Application\')'
        ),
      'Expected to retrieve sections for the application'
    );
  }
}