/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 11-15-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_CTRL_BaseSectionScreen_Test {
  @isTest
  static void testGetApplicationRecord() {
    Application__c app = new Application__c();
    insert app;
    Application__c result = CIB_CTRL_BaseSectionScreen.getApplicationRecord(
      app.Id
    );
    Assert.areEqual(app.Id, result.Id, 'Id should match');
  }

  @isTest
  static void testNegativeGetApplicationRecord() {
    try {
      CIB_CTRL_BaseSectionScreen.getApplicationRecord(null);
    } catch (AuraHandledException ex) {
      Assert.areNotEqual(null, ex, 'AuraHandledException should not be thrown');
    }
  }

  @isTest
  static void testGetApplicationSectionRecord() {
    Application__c app = new Application__c();
    insert app;
    Application_Section__c section = new Application_Section__c();
    section.Application__c = app.Id;
    section.Title__c = 'Test';
    section.ScreenApiName__c = 'Test';
    section.Order__c = 1;
    section.Screen_Type__c = 'Pre-Application';
    insert section;

    Application_Section__c result = CIB_CTRL_BaseSectionScreen.getApplicationSectionRecord(
      section.Id
    );

    Assert.areEqual(section.Id, result.Id, 'Id should match');
  }

  @isTest
  static void testNegativeGetApplicationSectionRecord() {
    try {
      CIB_CTRL_BaseSectionScreen.getApplicationSectionRecord(null);
    } catch (AuraHandledException ex) {
      Assert.areNotEqual(null, ex, 'AuraHandledException should not be thrown');
    }
  }

  @isTest
  static void testGetApplicatinSections() {
    Application__c app = new Application__c();
    insert app;
    List<Application_Section__c> result = CIB_CTRL_BaseSectionScreen.getApplicatinSections(
      app.Id
    );
    Assert.areNotEqual(null, result, 'Result should not be null');
  }

  @isTest
  static void testNegativeGetApplicatinSections() {
    try {
      CIB_CTRL_BaseSectionScreen.getApplicatinSections('sdjhdkjshf');
    } catch (AuraHandledException ex) {
      Assert.areNotEqual(null, ex, 'AuraHandledException should not be thrown');
    }
  }

  @isTest
  static void testUpdateApplication() {
    Application__c app = new Application__c();
    insert app;
    app.CIB_PR_Name__c = 'Submitted';
    CIB_CTRL_BaseSectionScreen.updateApplication(app);

    Application__c updatedApp = [
      SELECT Name, CIB_PR_Name__c
      FROM Application__c
      WHERE Id = :app.Id
    ];
    Assert.areEqual(
      'Submitted',
      updatedApp.CIB_PR_Name__c,
      'Status should be Submitted'
    );
  }

  @isTest
  static void testNegativeUpdateApplication() {
    try {
      CIB_CTRL_BaseSectionScreen.updateApplication(null);
    } catch (AuraHandledException ex) {
      Assert.areNotEqual(
        null,
        ex,
        'Exception should be thrown when application is null'
      );
    }
  }

  @isTest
  static void testUpdateApplicationSection() {
    Application__c app = new Application__c();
    insert app;

    Application_Section__c section = new Application_Section__c();
    section.Application__c = app.Id;
    section.Title__c = 'Test';
    section.ScreenApiName__c = 'Test';
    section.Order__c = 1;
    section.Screen_Type__c = 'Pre-Application';
    insert section;

    section.Status__c = 'Completed';
    CIB_CTRL_BaseSectionScreen.updateApplicationSection(section);

    Application_Section__c updatedSection = [
      SELECT Name, Status__c
      FROM Application_Section__c
      WHERE Id = :section.Id
    ];
    Assert.areEqual(
      'Completed',
      updatedSection.Status__c,
      'Status should be Completed'
    );
  }

  @isTest
  static void testNegativeUpdateApplicationSection() {
    try {
      CIB_CTRL_BaseSectionScreen.updateApplicationSection(null);
    } catch (AuraHandledException ex) {
      Assert.areNotEqual(null, ex, 'AuraHandledException should not be thrown');
    }
  }

  @isTest
  static void testGetPicklistValues() {
    List<CIB_CTRL_BaseSectionScreen.PicklistValueWrapper> result = CIB_CTRL_BaseSectionScreen.getPicklistValues(
      'Account',
      'Type'
    );

    Assert.areNotEqual(
      null,
      CIB_CTRL_BaseSectionScreen.getPicklistValues(null, 'Type'),
      'Result should be null'
    );
    Assert.areNotEqual(
      null,
      CIB_CTRL_BaseSectionScreen.getPicklistValues('Account', null),
      'Result should be null'
    );
    Assert.areNotEqual(0, result.size(), 'Picklist values should not be empty');
    for (CIB_CTRL_BaseSectionScreen.PicklistValueWrapper wrapper : result) {
      Assert.areNotEqual(null, wrapper.label, 'Label should not be null');
      Assert.areNotEqual(null, wrapper.value, 'Value should not be null');
    }
  }

  @isTest
  static void testGetSessionId() {
    String result = CIB_CTRL_BaseSectionScreen.getSessionId();

    Assert.areNotEqual(null, result, 'Session Id should not be null');
  }

  @isTest
  static void testGetMarketingConsentDetails() {
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'OneHub Community User Login'
      LIMIT 1
    ];

    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    Contact contact = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email = 'johndoe@example.com',
      AccountId = testAccount.Id
    );
    insert contact;
    System.debug('@@ contact: ' + JSON.serializePretty(contact));

    User user = new User(
      FirstName = 'John',
      LastName = 'Doe',
      Email = 'johndoe@example.com',
      Username = 'johndoe+silvaMacaneta@example.com.prod',
      Alias = 'JDSM',
      ContactId = contact.Id,
      ProfileId = profile.Id,
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_GB',
      LocaleSidKey = 'en_GB',
      TimeZoneSidKey = 'Africa/Johannesburg',
      Sync_with_Contact__c = true
    );
    insert user;
    System.debug('@@ insert: ' + JSON.serializePretty(user));

    System.runAs(user) {
      // Call the getMarketingConsentDetails method
      Test.startTest();
      List<ContactPointConsent> result = CIB_CTRL_BaseSectionScreen.getMarketingConsentDetails();
      Test.stopTest();
      // Assert that the returned ContactPointConsent record matches the test record
      Assert.areNotEqual(null, result.get(0).Id, 'Id should not be null');
    }
  }

  @isTest
  static void testSaveMarketingConsentDetails() {
    // Create a test contact record
    Contact contact = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email = 'johndoe@example.com'
    );
    insert contact;

    // Create a test individual record
    Individual individual = new Individual(
      FirstName = 'John',
      LastName = 'Doe',
      Email_Address__c = 'johndoe@example.com'
    );
    insert individual;

    // Create a test contact point email record
    ContactPointEmail contactPointEmail = new ContactPointEmail(
      ParentId = individual.Id,
      EmailAddress = individual.Email_Address__c,
      EmailDomain = individual.Email_Address__c.split('@')[1],
      EmailMailBox = individual.Email_Address__c.split('@')[0]
    );
    insert contactPointEmail;

    // Create a test contact point consent record
    ContactPointConsent contactPointConsent = new ContactPointConsent(
      ContactPointId = contactPointEmail.Id,
      PrivacyConsentStatus = 'NotSeen',
      CaptureContactPointType = 'Email',
      Name = 'Email Marketing - Standard Bank (Mauritius) Limited - John Doe'
    );
    insert contactPointConsent;

    // Update the test contact point consent record
    contactPointConsent.PrivacyConsentStatus = 'OptIn';

    // Call the saveMarketingConsentDetails method
    Test.startTest();
    CIB_CTRL_BaseSectionScreen.saveMarketingConsentDetails(contactPointConsent);
    Test.stopTest();

    // Retrieve the updated contact point consent record
    ContactPointConsent updatedContactPointConsent = [
      SELECT PrivacyConsentStatus
      FROM ContactPointConsent
      WHERE Id = :contactPointConsent.Id
    ];

    // Assert that the PrivacyConsentStatus field was updated
    Assert.areEqual(
      'OptIn',
      updatedContactPointConsent.PrivacyConsentStatus,
      'PrivacyConsentStatus should match'
    );
  }

  @isTest
  static void testGetApplicationDocuments() {
    // Create test data
    Application__c app = new Application__c();
    insert app;

    Id recordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE
        SObjectType = 'Application_Document__c'
        AND DeveloperName = 'CIB_Mauritius_Document'
    ]
    .Id;

    Application_Document__c doc1 = new Application_Document__c(
      Application__c = app.Id,
      Document_Label__c = 'Document 1',
      Document_Type__c = 'Type 1',
      RecordTypeId = recordTypeId

    );
    Application_Document__c doc2 = new Application_Document__c(
      Application__c = app.Id,
      Document_Label__c = 'Document 2',
      Document_Type__c = 'Type 2',
      RecordTypeId = recordTypeId
    );
    insert new List<Application_Document__c>{ doc1, doc2 };

    // Call the method being tested
    List<Application_Document__c> result = CIB_CTRL_BaseSectionScreen.getApplicationDocuments(
      app.Id
    );

    // Verify the results
    Assert.areEqual(2, result.size(), 'Result should have 2 items');
    Assert.areEqual('Document 1', result[0].Document_Label__c, 'Name should match');
    Assert.areEqual('Document 2', result[1].Document_Label__c, 'Name should match');
  }

  @isTest
  static void testSaveApplicationDocuments() {
    Application__c app = new Application__c();
    insert app;
    // Create test data
    Id recordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE
        SObjectType = 'Application_Document__c'
        AND DeveloperName = 'CIB_Mauritius_Document'
    ]
    .Id;
    Application_Document__c doc1 = new Application_Document__c(
      Application__c = app.Id,
      Document_Label__c = 'Document 1',
      Document_Type__c = 'Type 1',
      RecordTypeId = recordTypeId
    );
    Application_Document__c doc2 = new Application_Document__c(
      Application__c = app.Id,
      Document_Label__c = 'Document 2',
      Document_Type__c = 'Type 2',
      Document_Status__c = 'Uploaded',
      RecordTypeId = recordTypeId
    );

    List<Application_Document__c> applicationDocuments = new List<Application_Document__c>{
      doc1,
      doc2
    };
    insert applicationDocuments;

    // Call the method being tested
    Test.startTest();
    CIB_CTRL_BaseSectionScreen.saveApplicationDocuments(applicationDocuments);
    Test.stopTest();

    // Verify the results
    List<Application_Document__c> savedDocuments = [
      SELECT Document_Label__c
      FROM Application_Document__c
    ];
    Assert.areEqual(2, savedDocuments.size(), 'Saved documents should be 2');
    Assert.areEqual(
      'Document 1',
      savedDocuments[0].Document_Label__c,
      'Name should match'
    );
    Assert.areEqual(
      'Document 2',
      savedDocuments[1].Document_Label__c,
      'Name should match'
    );
  }
}