/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 11-13-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_CTRL_AOMandateGeneratePdf_Test {
  @isTest
  static void testProperties() {
    Account Acc = new Account(Name = 'Test Account');
    insert Acc;

    Application__c app = new Application__c();
    app.Client__c = Acc.Id;
    insert app;

    PageReference pageRef = Page.CIB_PDF_BasicCompanyInformation;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('Id', app.id);
    CIB_CTRL_AOMandateGeneratePdf ctrl = new CIB_CTRL_AOMandateGeneratePdf();

    Assert.areEqual(app.Id, ctrl.applicationId, 'Application Id should match');
    Assert.areNotEqual(
      null,
      ctrl.contactPersons,
      'Contact Persons should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.beneficialOwners,
      'beneficial Owners should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.immediateShareholders,
      'Immediate Shareholders should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.intermediateShareholders,
      'Intermediate Shareholders should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.ultimateShareholders,
      'Ultimate Shareholders should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.individualDirectors,
      'Individual Directors should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.controllingPersons,
      'Controlling Persons should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.seniorManagers,
      'Senior Managers should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.corporateDirectors,
      'Corporate Directors should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.authorisedSignatories,
      'Authorised Signatories should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.taxJuristictions,
      'Tax Juristictions should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.annualTurnovers,
      'Annual Turnovers should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.twoRowAuthorisedSignatories,
      'Two Row Authorised Signatories should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.businessNatures,
      'Business Natures should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.internetBankingCredentials,
      'internet Banking Credentials should not be null'
    );
    Assert.areNotEqual(
      null,
      ctrl.officialStartNumber,
      'official Start Number should not be null'
    );
  }

  @isTest
  static void testGenerateCertificationDocuments() {
    // Create test data
    Account Acc = new Account(Name = 'Test Account');
    insert Acc;

    Application__c app = new Application__c();
    app.Client__c = Acc.Id;
    insert app;

    Application_Participant__c participant = new Application_Participant__c(
      Application__c = app.Id,
      Name = 'Test Participant'
    );
    insert participant;
    Application_Participant__c participant2 = new Application_Participant__c(
      Application__c = app.Id,
      Name = 'Test Participant Certifier'
    );
    insert participant2;
    ContentVersion contentVersion = new ContentVersion(
      Title = 'Test Document',
      VersionData = Blob.valueOf('Test document content'),
      PathOnClient = 'TestDocument.pdf',
      FirstPublishLocationId = app.Id,
      ContentLocation = 'S'
    );
    insert contentVersion;

    Application_Document__c appDoc = new Application_Document__c(
      Application__c = app.Id,
      Application_Participant__c = participant.Id,
      CertifyingOfficial__c = participant2.Id,
      Document_Type__c = 'Test Document Type'
    );
    insert appDoc;

    ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
      ContentDocumentId = [
        SELECT ContentDocumentId
        FROM ContentVersion
        WHERE Id = :contentVersion.Id
      ]
      .ContentDocumentId,
      LinkedEntityId = appDoc.Id
    );
    insert contentDocumentLink;

    // Call the method being tested
    Map<Id, List<CIB_CTRL_AOMandateGeneratePdf.ApplicationDocumentWrapper>> result = CIB_CTRL_AOMandateGeneratePdf.generateCertificationDocuments(
      app.Id
    );

    // Verify the results
    Assert.areEqual(1, result.size(), 'Result should have 1 item');
    CIB_CTRL_AOMandateGeneratePdf.ApplicationDocumentWrapper wrapper = result.values()
      .get(0)
      .get(0);
    Assert.areEqual('Test Document Type', wrapper.title, 'Title should match');
    Assert.areEqual(
      'Test Participant',
      wrapper.participantName,
      'Participant Name should match'
    );
    Assert.areEqual('pdf', wrapper.type, 'Type should match');
  }

  @isTest
  static void testGetAuthorisedSignatories() {
    Account Acc = new Account(Name = 'Test Account');
    insert Acc;

    Application__c app = new Application__c();
    app.Client__c = Acc.Id;
    insert app;

    Application_Participant__c authSignatory = new Application_Participant__c(
      Application__c = app.Id,
      RecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Authorised_Signatory')
        .getRecordTypeId(),
      Name = 'Test Signatory',
      CIB_Sequence__c = 1
    );
    insert authSignatory;
    List<Application_Participant__c> result = CIB_CTRL_AOMandateGeneratePdf.getAutorisedSignatories(
      app.Id
    );
    List<string> recipients = CIB_CTRL_AOMandateGeneratePdf.getRecipients(
      app.Id
    );
    Assert.areEqual(
      authSignatory.Id,
      result[0].Id,
      'Result should match expected value'
    );
    Assert.areNotEqual(null, recipients, 'Recipients should not be null');
  }

  @isTest
  static void testgeneratePdf() {
    Account Acc = new Account(Name = 'Test Account');
    insert Acc;

    Application__c app = new Application__c();
    app.Client__c = Acc.Id;
    insert app;

    String document = CIB_CTRL_AOMandateGeneratePdf.generatePdf(
      String.valueOf(app.Id)
    );

    Assert.areNotEqual(null, document, 'Document should be generated');
  }
  @isTest
  static void testSaveCertificationAgreement() {
    Account acc = new Account(Name = 'Test Account');
    insert acc;
    Application__c app = new Application__c(
      Client__c = acc.Id,
      CIB_CertOfficerEmail__c = 'test@example.com'
    );
    insert app;
    Application_Participant__c signatory = new Application_Participant__c(
      Application__c = app.Id,
      RecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Authorised_Signatory')
        .getRecordTypeId(),
      Name = 'Test Signatory',
      Email__c = 'test@example.com'
    );
    insert signatory;
    String pdfBody = EncodingUtil.base64Encode(Blob.valueOf('Test PDF'));

    Test.startTest();
    CIB_CTRL_AOMandateGeneratePdf.generateMandateAgreement(
      String.valueOf(app.id),
      'test agreement'
    );

    List<String> result = CIB_CTRL_AOMandateGeneratePdf.saveCertificationAgreement(
      String.valueOf(app.Id),
      'Test Agreement',
      signatory.Id
    );
    Test.stopTest();

    Assert.areNotEqual(null, result[0], 'Result Id should not be null');
    Assert.areNotEqual(null, result[1], 'Result Id should not be null');
  }
}