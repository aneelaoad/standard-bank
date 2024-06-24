/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-02-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class SEL_CIBApplicationParticipant_Test {
  @testSetup
  static void setup() {
    Application__c app = new Application__c();
    insert app;
    // Create test data
    List<Application_Participant__c> participants = new List<Application_Participant__c>();
    participants.add(
      new Application_Participant__c(
        Application__c = app.Id,
        Name = 'Participant 1',
        RecordTypeId = getRecordTypeId('Director')
      )
    );
    participants.add(
      new Application_Participant__c(
        Application__c = app.Id,
        Name = 'Participant 2',
        RecordTypeId = getRecordTypeId('Director')
      )
    );
    participants.add(
      new Application_Participant__c(
        Application__c = app.Id,
        Name = 'Participant 3',
        RecordTypeId = getRecordTypeId('Director')
      )
    );
    insert participants;
  }

  @isTest
  static void testSelectWithoutCondition() {
    // Test selectWithoutCondition method
    List<Application_Participant__c> participants = new SEL_CIBApplicationParticipant()
      .selectWithoutCondition();
    Assert.areNotEqual(0, participants.size(), 'Expected participants');
  }

  @isTest
  static void testSelectAppsById() {
    // Test selectAppsById method
    List<Application_Participant__c> participants = new SEL_CIBApplicationParticipant()
      .selectAppsById(getParticipantId('Participant 1'));
    Assert.areEqual(1, participants.size(), 'Expected 1 participant');
    Assert.areEqual(
      'Participant 1',
      participants[0].Name,
      'Expected participant name to be Participant 1'
    );
  }

  @isTest
  static void testSelectAppsByApplicationId() {
    // Test selectAppsByApplicationId method
    List<Application_Participant__c> participants = new SEL_CIBApplicationParticipant()
      .selectAppsByApplicationId(getApplicationId());
    Assert.areNotEqual(0, participants.size(), 'Expected 3 participants');
  }

  @isTest
  static void testSelectAppsByApplicationIds() {
    // Test selectAppsByApplicationIds method
    List<Application_Participant__c> participants = new SEL_CIBApplicationParticipant()
      .selectAppsByApplicationIds(getApplicationId());
    Assert.areNotEqual(0, participants.size(), 'Expected 3 participants');
  }

  @isTest
  static void testSelectAppsByApplicationIdsRecordId() {
    // Test selectAppsByApplicationIdsRecordId method
    List<Application_Participant__c> participants = new SEL_CIBApplicationParticipant()
      .selectAppsByApplicationIdsRecordId(
        getApplicationId(),
        getRecordTypeId('Director')
      );
    Assert.areNotEqual(0, participants.size(), 'Expected 3 participants');
  }

  @isTest
  static void testSelectAppById() {
    // Test selectAppById method
    Application_Participant__c participant = new SEL_CIBApplicationParticipant()
      .selectAppById(getParticipantId('Participant 1'))
      .get(0);
    Assert.areEqual(
      'Participant 1',
      participant.Name,
      'Expected participant name to be Participant 1'
    );
  }

  @isTest
  static void testSelectAppsByApplicationIdRecordId() {
    // Test selectAppsByApplicationIdRecordId method
    Application_Participant__c participant = new SEL_CIBApplicationParticipant()
      .selectAppsByApplicationIdRecordId(
        getApplicationId(),
        getRecordTypeId('Director')
      )
      .get(0);
    Assert.areEqual(
      'Participant 1',
      participant.Name,
      'Expected participant name to be Participant 1'
    );
  }

  @isTest
  static void testSelectAppByApplicationId() {
    // Test selectAppByApplicationId method
    Application_Participant__c participant = new SEL_CIBApplicationParticipant()
      .selectAppByApplicationId(getApplicationId())
      .get(0);
    Assert.areEqual(
      'Participant 1',
      participant.Name,
      'Expected participant name to be Participant 1'
    );
  }

  @isTest
  static void testSelectAppsByApplicationIdRecordIdmultiple() {
    // Test selectAppsByApplicationIdRecordIdmultiple method
    List<Application_Participant__c> participants = new SEL_CIBApplicationParticipant()
      .selectAppsByApplicationIdRecordIdmultiple(
        getApplicationId(),
        new List<String>{ getRecordTypeId('Director') }
      );
    Assert.areNotEqual(0, participants.size(), 'Expected 3 participants');
  }

  @isTest
  static void testSelectAppsByApplicationIdString() {
    // Test selectAppsByApplicationIdString method
    List<Application_Participant__c> participants = new SEL_CIBApplicationParticipant()
      .selectAppsByApplicationIdString(getApplicationId());
    Assert.areNotEqual(0, participants.size(), 'Expected 3 participants');
  }

  @isTest
  static void testSelectAppsByApplicationIdRecordIdList() {
    // Test selectAppsByApplicationIdRecordIdList method
    List<Application_Participant__c> participants = new SEL_CIBApplicationParticipant()
      .selectAppsByApplicationIdRecordIdList(
        getApplicationId(),
        getRecordTypeId('Director')
      );
    Assert.areNotEqual(0, participants.size(), 'Expected 3 participants');
  }

  private static Id getRecordTypeId(String developerName) {
    // Get record type Id by developer name
    return Schema.SObjectType.Application_Participant__c.getRecordTypeInfosByDeveloperName()
      .get(developerName)
      .getRecordTypeId();
  }

  private static Id getApplicationId() {
    // Get application Id
    return [SELECT Id FROM Application__c LIMIT 1].Id;
  }

  private static Id getParticipantId(String name) {
    // Get participant Id by name
    return [
      SELECT Id
      FROM Application_Participant__c
      WHERE Name = :name
      LIMIT 1
    ]
    .Id;
  }
}