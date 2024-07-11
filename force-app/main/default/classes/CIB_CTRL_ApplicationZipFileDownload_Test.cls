/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 11-07-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_CTRL_ApplicationZipFileDownload_Test {
  final static string TEST_STR = 'Test';
  @isTest
  static void testGetfileIds() {
    // Create test data
    final Account testAccount = new Account(Name = TEST_STR);
    insert testAccount;

    final Application__c applicationRecord = new Application__c();
    applicationRecord.Client__c = testAccount.Id;
    insert applicationRecord;

    final Application_Section__c appSection = new Application_Section__c(
      Application__c = applicationRecord.Id,
      ScreenApiName__c = TEST_STR,
      Screen_Type__c = 'Home',
      Order__c = 2,
      Title__c = TEST_STR
    );
    insert appSection;

    final Application_Participant__c appParticipant = new Application_Participant__c(
      Application__c = applicationRecord.Id,
      Name = TEST_STR,
      RecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Authorised_Signatory')
        .getRecordTypeId()
    );
    insert appParticipant;

    final Application_Document__c appDoc = new Application_Document__c(
      Document_Type__c = TEST_STR,
      Application__c = applicationRecord.Id,
      Application_Section__c = appSection.Id,
      Application_Participant__c = appParticipant.Id
    );
    insert appDoc;

    ContentVersion contentVersion = new ContentVersion(
      Title = TEST_STR,
      PathOnClient = TEST_STR,
      VersionData = Blob.valueOf(TEST_STR)
    );
    insert contentVersion;

    contentVersion = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :contentVersion.Id
      LIMIT 1
    ];

    final ContentDocumentLink contentLink = new ContentDocumentLink(
      ContentDocumentId = contentVersion.ContentDocumentId,
      LinkedEntityId = appDoc.Id,
      ShareType = 'V'
    );
    insert contentLink;

    // Call the method being tested
    final List<CIB_CTRL_ApplicationZipFileDownload.GetFileIdOutputWrapper> result = CIB_CTRL_ApplicationZipFileDownload.getfileIds(
      applicationRecord.Id
    );

    // Verify the results
    Assert.areEqual(1, result.size(), 'Expected 1 file ID');
    Assert.areNotEqual(
      null,
      result[0],
      'Expected file to not be equal to null'
    );
  }

  @isTest
  static void testGetSessionId() {
    string sessionId = CIB_CTRL_ApplicationZipFileDownload.getSessionId();
    Assert.areNotEqual(
      null,
      sessionId,
      'Expected sessionId to not be equal to null'
    );
  }
}