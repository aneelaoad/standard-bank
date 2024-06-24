/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-06-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_CTRL_DocumentUploader_Test {
  final static String TEST_DOCUMENT_NAME = 'Test Document';
  final static String TEST_DOCUMENT_STATUS = 'Uploaded';
  @TestSetup
  static void setup() {
    // Create test data
    final Application__c application = new Application__c();
    application.Status__c = 'Submitted';
    insert application;

    final Application_Participant__c participant = new Application_Participant__c();
    participant.Application__c = application.Id;
    insert participant;

    final Application_Section__c section = [
      SELECT Id
      FROM Application_Section__c
      WHERE
        Application__c = :application.Id
        AND ScreenApiName__c = 'cib_comp_basicInformation'
      LIMIT 1
    ];

    // Create test document
    ContentVersion contentVersion = new ContentVersion();
    contentVersion.ContentLocation = 'S';
    contentVersion.PathOnClient = 'test.pdf';
    contentVersion.Title = TEST_DOCUMENT_NAME;
    contentVersion.VersionData = Blob.valueOf('Test Document Content');
    insert contentVersion;

    contentVersion = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :contentVersion.Id
      LIMIT 1
    ];

    final Application_Document__c appDoc = new Application_Document__c();
    appDoc.Application__c = application.Id;
    appDoc.Application_Participant__c = participant.Id;
    appDoc.Application_Section__c = section.Id;
    appDoc.Document_Type__c = TEST_DOCUMENT_NAME;
    appDoc.Document_Status__c = TEST_DOCUMENT_STATUS;
    appDoc.Document_Label__c = TEST_DOCUMENT_NAME;
    appDoc.FileNet_Id__c = contentVersion.Id;
    insert appDoc;

    final ContentDocumentLink conDocLink = new ContentDocumentLink();
    conDocLink.LinkedEntityId = appDoc.Id;
    conDocLink.ContentDocumentId = contentVersion.ContentDocumentId;
    conDocLink.ShareType = 'V';
    insert conDocLink;
  }

  @isTest
  static void testGetSessionId() {
    Test.startTest();
    String sessionId = CIB_CTRL_DocumentUploader.getSessionId();
    Test.stopTest();
    Assert.areNotEqual(null, sessionId, 'Session Id should not be null');
  }

  @isTest
  static void testGetFile() {
    final Application_Document__c appDoc = [
      SELECT Id, Application__c, Application_Section__c, Document_Type__c
      FROM Application_Document__c
      WHERE Document_Status__c = :TEST_DOCUMENT_STATUS AND Application_Section__c != NULL
      LIMIT 1
    ];

    Test.startTest();
    CIB_CTRL_DocumentUploader.GetFileOutputWrapper file = CIB_CTRL_DocumentUploader.getFile(
      appDoc.Application__c,
      appDoc.Application_Section__c,
      appDoc.Document_Type__c
    );
    Test.stopTest();

    Assert.areNotEqual(null, file, 'File should not be null');
  }

  @isTest
  static void testIsApplication() {
    Test.startTest();
    final Boolean isApplication = CIB_CTRL_DocumentUploader.isApplication(
      [SELECT Id FROM Application__c LIMIT 1].Id
    );
    Test.stopTest();

    Assert.areEqual(true, isApplication, 'Should be true');
  }

  @isTest
  static void testGetApplicationIdFromParticipant() {
    // Get test data
    final Application_Participant__c participant = [
      SELECT Id
      FROM Application_Participant__c
      LIMIT 1
    ];

    Test.startTest();
    final Id applicationId = CIB_CTRL_DocumentUploader.getApplicationIdFromParticipant(
      participant.Id
    );
    Test.stopTest();

    Assert.areNotEqual(
      null,
      applicationId,
      'Application Id should not be null'
    );
  }

  @isTest
  static void testGetApplicationDocument() {
    // Get test data
    final Application__c application = [SELECT Id FROM Application__c LIMIT 1];
    final Application_Participant__c participant = [
      SELECT Id
      FROM Application_Participant__c
      LIMIT 1
    ];
    final Application_Section__c section = [
      SELECT Id
      FROM Application_Section__c
      WHERE
        Application__c = :application.Id
        AND ScreenApiName__c = 'cib_comp_basicInformation'
      LIMIT 1
    ];
    final Id applicationDocumentId = [
      SELECT Id
      FROM Application_Document__c
      LIMIT 1
    ]
    .Id;
    final CIB_CTRL_DocumentUploader.UploadFileInputWrapper input = new CIB_CTRL_DocumentUploader.UploadFileInputWrapper();
    input.sectionId = section.Id;
    input.documentType = TEST_DOCUMENT_NAME;
    input.documentStatus = TEST_DOCUMENT_STATUS;
    input.documentName = TEST_DOCUMENT_NAME;
    input.base64 = EncodingUtil.base64Encode(Blob.valueOf('Test Content'));
    input.documentExtension = 'txt';
    input.documentId = applicationDocumentId;

    Test.startTest();
    final Application_Document__c appDoc = CIB_CTRL_DocumentUploader.getApplicationDocument(
      application.Id,
      participant.Id,
      input
    );
    Test.stopTest();

    Assert.areNotEqual(null, appDoc, 'Application Document should not be null');
  }

  @isTest
  static void testCreateContentVersion() {
    // Get test data
    final Application_Document__c appDoc = [
      SELECT Id, Document_Label__c
      FROM Application_Document__c
      LIMIT 1
    ];
    final ContentDocumentLink conDocLink = [
      SELECT ContentDocumentId, ContentDocument.FileExtension
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :appDoc.Id
      ORDER BY SystemModstamp DESC
      LIMIT 1
    ];

    Test.startTest();
    final ContentVersion contentVersion = CIB_CTRL_DocumentUploader.createContentVersion(
      appDoc.Document_Label__c,
      EncodingUtil.base64Encode(Blob.valueOf('Test Content')),
      conDocLink.ContentDocument.FileExtension
    );
    Test.stopTest();

    Assert.areNotEqual(
      null,
      contentVersion,
      'Content Version should not be null'
    );
  }

  @isTest
  static void testCreateContentDocumentLink() {
    final Application__c application = [SELECT Id FROM Application__c LIMIT 1];
    final Application_Section__c section = [
      SELECT Id
      FROM Application_Section__c
      WHERE
        Application__c = :application.Id
        AND ScreenApiName__c = 'cib_comp_basicInformation'
      LIMIT 1
    ];
    final ContentVersion contentVersion = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      LIMIT 1
    ];
    final Application_Participant__c participant = [
      SELECT Id
      FROM Application_Participant__c
      LIMIT 1
    ];
    final Application_Document__c appDoc = new Application_Document__c();
    appDoc.Application__c = application.Id;
    appDoc.Application_Participant__c = participant.Id;
    appDoc.Application_Section__c = section.Id;
    appDoc.Document_Type__c = TEST_DOCUMENT_NAME;
    appDoc.Document_Status__c = TEST_DOCUMENT_STATUS;
    appDoc.Document_Label__c = TEST_DOCUMENT_NAME;
    appDoc.FileNet_Id__c = contentVersion.Id;
    insert appDoc;

    Test.startTest();
    final List<ContentDocumentLink> links = CIB_CTRL_DocumentUploader.createContentDocumentLink(
      contentVersion,
      appDoc,
      application.Id,
      participant.Id
    );
    Test.stopTest();

    Assert.areNotEqual(null, links, 'Content Document Link should not be null');
  }

  @isTest
  static void testGetRecordTypeId() {
    Test.startTest();
    final Id recordType = CIB_CTRL_DocumentUploader.getRecordTypeId();
    Test.stopTest();
    Assert.areNotEqual(null, recordType, 'Record Type should not be null');
  }

  @isTest
  static void testUploadFile() {
    final Application__c testApplication = new Application__c();
    insert testApplication;

    final Application_Section__c section = [
      SELECT Id
      FROM Application_Section__c
      WHERE
        Application__c = :testApplication.Id
        AND ScreenApiName__c = 'cib_comp_basicInformation'
      LIMIT 1
    ];

    final Application_Document__c testDocument = new Application_Document__c(
      Application__c = testApplication.Id,
      Application_Section__c = section.Id,
      Document_Type__c = 'Test Type',
      Document_Label__c = 'Test Label',
      Document_Status__c = TEST_DOCUMENT_STATUS
    );
    insert testDocument;

    final CIB_CTRL_DocumentUploader.UploadFileInputWrapper testInput = new CIB_CTRL_DocumentUploader.UploadFileInputWrapper();
    testInput.recordId = testApplication.Id;
    testInput.sectionId = section.Id;
    testInput.documentType = 'Test Type';
    testInput.documentName = TEST_DOCUMENT_NAME;
    testInput.base64 = EncodingUtil.base64Encode(Blob.valueOf('Test Content'));
    testInput.documentExtension = 'txt';
    testInput.documentStatus = TEST_DOCUMENT_STATUS;

    Test.startTest();
    final CIB_CTRL_DocumentUploader.UploadFileOutputWrapper testOutput = CIB_CTRL_DocumentUploader.uploadFile(
      testInput
    );
    Test.stopTest();

    final Application_Document__c updatedDocument = [
      SELECT Id, Document_Status__c
      FROM Application_Document__c
      WHERE Id = :testDocument.Id
      LIMIT 1
    ];
    Assert.areEqual(
      TEST_DOCUMENT_STATUS,
      updatedDocument.Document_Status__c,
      'Document Status should be the same'
    );
  }

  @isTest
  static void testUpdateStatus() {
    // Create a test record to use as the parent of the Application_Document__c record
    final Application__c testApplication = new Application__c();
    insert testApplication;

    final Application_Section__c section = [
      SELECT Id
      FROM Application_Section__c
      WHERE
        Application__c = :testApplication.Id
        AND ScreenApiName__c = 'cib_comp_basicInformation'
      LIMIT 1
    ];

    // Create a test Application_Document__c record
    final Application_Document__c testDocument = new Application_Document__c(
      Application__c = testApplication.Id,
      Application_Section__c = section.Id,
      Document_Type__c = 'Test Type',
      Document_Label__c = 'Test Label',
      Document_Status__c = 'Pending'
    );
    insert testDocument;

    // Call the updateStatus method
    Test.startTest();
    CIB_CTRL_DocumentUploader.updateStatus(testDocument.Id, null);
    Test.stopTest();

    // Verify that the Application_Document__c record was updated
    final Application_Document__c updatedDocument = [
      SELECT Id, Document_Status__c
      FROM Application_Document__c
      WHERE Id = :testDocument.Id
      LIMIT 1
    ];
    Assert.areEqual(
      TEST_DOCUMENT_STATUS,
      updatedDocument.Document_Status__c,
      'Document Status should be the same'
    );
  }
}