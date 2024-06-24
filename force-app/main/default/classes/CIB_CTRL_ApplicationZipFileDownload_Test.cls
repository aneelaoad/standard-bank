/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 11-15-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_CTRL_ApplicationZipFileDownload_Test {
  @isTest
  static void testGetfileIds() {
    // Create test data
    Account acc = new Account(Name = 'Test');
    insert acc;

    Application__c app = new Application__c();
    app.Client__c = acc.Id;
    insert app;

    Application_Section__c appSection = new Application_Section__c(
      Application__c = app.Id,
      ScreenApiName__c = 'Test',
      Screen_Type__c = 'Home',
      Order__c = 2,
      Title__c = 'Test'
    );
    insert appSection;

    Application_Participant__c appParticipant = new Application_Participant__c(
      Application__c = app.Id,
      Name = 'Test',
      RecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Authorised_Signatory')
        .getRecordTypeId()
    );
    insert appParticipant;

    Application_Document__c appDoc = new Application_Document__c(
      Document_Type__c = 'Test',
      Application__c = app.Id,
      Application_Section__c = appSection.Id,
      Application_Participant__c = appParticipant.Id
    );
    insert appDoc;

    ContentVersion cv = new ContentVersion(
      Title = 'Test',
      PathOnClient = 'Test',
      VersionData = Blob.valueOf('Test')
    );
    insert cv;

    cv = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cv.Id
      LIMIT 1
    ];

    ContentDocumentLink cdl = new ContentDocumentLink(
      ContentDocumentId = cv.ContentDocumentId,
      LinkedEntityId = appDoc.Id,
      ShareType = 'V'
    );
    insert cdl;

    // Call the method being tested
    List<CIB_CTRL_ApplicationZipFileDownload.GetFileIdOutputWrapper> result = CIB_CTRL_ApplicationZipFileDownload.getfileIds(
      app.Id
    );

    // Verify the results
    Assert.areNotEqual(null, result, 'Result should not be null');
  }
}