/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-01-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_CTRL_ApplicationParticipant_Test {
  @isTest
  static void testGetApplicationParticipants() {
    // Create test data
    Application__c app = new Application__c();
    insert app;
    Id recordTypeId = Schema.SObjectType.Application_Participant__c
      .getRecordTypeInfosByDeveloperName()
      .get(CIB_Constants.APPLICATION_PARTICIPANT_RECORD_TYPE_DIRECTOR)
      .getRecordTypeId();
    Application_Participant__c participant = new Application_Participant__c(
      Application__c = app.Id,
      Name = 'Test Participant',
      RecordTypeId = recordTypeId
    );
    insert participant;

    // Call the method being tested
    List<Application_Participant__c> participants = CIB_CTRL_ApplicationParticipant.getApplicationParticipants(
      app.Id,
      CIB_Constants.APPLICATION_PARTICIPANT_RECORD_TYPE_DIRECTOR
    );

    // Verify the results
    Assert.areEqual(1, participants.size(), 'Should have 1 participant');
    Assert.areEqual(
      participant.Id,
      participants[0].Id,
      'Should have the same Id'
    );
  }

  @isTest
  static void testDeleteApplicationParticipant() {
    // Create test data
    Application__c app = new Application__c();
    insert app;
    Application_Participant__c participant = new Application_Participant__c(
      Application__c = app.Id,
      Name = 'Test Participant'
    );
    insert participant;

    // Call the method being tested
    Test.startTest();
    CIB_CTRL_ApplicationParticipant.deleteApplicationParticipant(participant);
    Test.stopTest();

    // Verify the results
    List<Application_Participant__c> participants = [
      SELECT Id
      FROM Application_Participant__c
      WHERE Id = :participant.Id
    ];
    Assert.areEqual(0, participants.size(), 'Should have 0 participants');
  }

  @isTest
  static void testSaveApplicationParticipants() {
    // Create test data
    Application__c app = new Application__c();
    insert app;
    Id recordTypeId = Schema.SObjectType.Application_Participant__c
      .getRecordTypeInfosByDeveloperName()
      .get(CIB_Constants.APPLICATION_PARTICIPANT_RECORD_TYPE_DIRECTOR)
      .getRecordTypeId();
    Application_Participant__c participant1 = new Application_Participant__c(
      Application__c = app.Id,
      Name = 'Test Participant 1',
      RecordTypeId = recordTypeId
    );
    Application_Participant__c participant2 = new Application_Participant__c(
      Application__c = app.Id,
      Name = 'Test Participant 2',
      RecordTypeId = recordTypeId
    );

    // Call the method being tested
    Test.startTest();
    List<Application_Participant__c> participants = CIB_CTRL_ApplicationParticipant.saveApplicationParticipants(
      CIB_Constants.APPLICATION_PARTICIPANT_RECORD_TYPE_DIRECTOR,
      new List<Application_Participant__c>{ participant1, participant2 }
    );
    Test.stopTest();

    // Verify the results
    Assert.areEqual(2, participants.size(), 'Should have 2 participants');
    Assert.areEqual(
      recordTypeId,
      participants[0].RecordTypeId,
      'Should have the same record type'
    );
    Assert.areEqual(
      recordTypeId,
      participants[1].RecordTypeId,
      'Should have the same record type'
    );
    Assert.areNotEqual(null, participants[0].Id, 'Shoud have an Id');
    Assert.areNotEqual(null, participants[1].Id, 'Shoud have an Id');
  }
}