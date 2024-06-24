/**
 * @author Emmanuel Nocks (BlueSky)
 * @date August 2020
 * @description Test class for SEL_ApplicationDocuments.
 */
@IsTest(IsParallel=true)
public class SEL_ApplicationDocuments_Test {
  @IsTest
  static void shouldSelectByAccountApplicationId() {
    Test.startTest();
    SEL_ApplicationDocuments.newInstance()
      .selectByAccountApplicationId(new Set<Id>());
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.isTrue(
      result.getCondition()
        .containsIgnoreCase('Account_Application__c in :IdSet'),
      'Should select by Account_Application__c'
    );
  }

  @IsTest
  static void shouldSelectByOnboardApplicationId() {
    Test.startTest();
    SEL_ApplicationDocuments.newInstance()
      .selectByOnboardApplicationId(new Set<Id>());
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.isTrue(
      result.getCondition()
        .containsIgnoreCase('Onboarding_Application__c in :IdSet'),
      'Should select by Onboarding_Application__c'
    );
  }
  @IsTest
  static void shouldSelectByOnboardAppWherePending() {
    Test.startTest();
    SEL_ApplicationDocuments.newInstance()
      .selectByOnboardAppWherePending(new Set<Id>());
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.isTrue(
      result.getCondition()
        .containsIgnoreCase('Onboarding_Application__c IN:onBoardid'),
      'Should select by Onboarding_Application__c'
    );
  }

  @IsTest
  static void shouldSelectByApplicationId() {
    Test.startTest();
    SEL_ApplicationDocuments.newInstance().selectByApplicationId('');
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.isTrue(
      result.getCondition().containsIgnoreCase('Application__c = :appId'),
      'Should select by Application__c'
    );
  }

  @IsTest
  static void shouldSelectUploadedByApplicationPraticipantAndType() {
    Test.startTest();
    SEL_ApplicationDocuments.newInstance()
      .selectUploadedByApplicationPraticipantAndType(null, null, null, null);
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.isTrue(
      result.getCondition()
        .containsIgnoreCase(
          '(Application__c = :applicationId AND Application_Participant__c = null)'
        ),
      'Should select by Application__c'
    );
  }

  @IsTest
  static void shouldSelectByApplicationAndSectionAndType() {
    Test.startTest();
    SEL_ApplicationDocuments.newInstance()
      .selectByApplicationAndSectionAndType(null, null, null);
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.isTrue(
      result.getCondition()
        .containsIgnoreCase(
          '(Application__c = :recordId OR Application_Participant__c = :recordId)'
        ),
      'Should select by Application__c or participant'
    );
  }

  @IsTest
  static void shouldSelectByApplicationIdWithSection() {
    Test.startTest();
    SEL_ApplicationDocuments.newInstance()
      .selectByApplicationIdWithSection(null);
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.isTrue(
      result.getCondition().containsIgnoreCase('Application__c = :appId'),
      'Should select Document By Related Party'
    );
  }
  @IsTest
  static void shouldSelectSectionsBydocumentId() {
    Test.startTest();
    SEL_ApplicationDocuments.newInstance().selectSectionsBydocumentId(null);
    Test.stopTest();
    fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
    Assert.isTrue(
      result.getCondition().containsIgnoreCase('id = :documentId'),
      'Should select Document By Related Party'
    );
  }
}