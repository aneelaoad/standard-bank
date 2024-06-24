/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_CTRL_AOMandateGeneratePdf
@ Description       : This class generates a PDF document for a specific application record and retrieves information about its related contact persons, shareholders, and directors.
@ Last Modified By  : 10-03-2023
@ Last Modified On  : silva.macaneta@standardbank.co.za
@ Modification Description : SFP-21988
***************************************************************************************/
public without sharing class CIB_CTRL_AOMandateGeneratePdf {
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
    .createLogger('CIB_CTRL_AOMandateGeneratePdf');
  public Id applicationId = ApexPages.currentPage()
    .getParameters()
    .get('id')
    .escapeHtml4();
  /**
   * @description : This property returns Application__c record.
   */
  public Application__c applicationRecord { get; set; }

  /**
   * @description : This property returns a list of Application_Participant__c records.
   */
  public List<Application_Participant__c> participants { get; set; }

  /**
   * @description : This property returns the starting number of internal official.
   */
  public Integer officialStartNumber {
    get {
      List<String> items = getRecipients(applicationId);
      return items.size() + 1;
    }
  }

  /**
   * @description : This method retrieves a list of contact persons related to the application record.
   * @return List<Application_Participant__c> - a list of contact persons.
   **/
  public List<Application_Participant__c> contactPersons {
    get {
      Id contactPersonRecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Contact_Person')
        .getRecordTypeId();

      List<Application_Participant__c> contactPersons = new SEL_CIBApplicationParticipant()
        .selectAppsByApplicationIdRecordIdList(
          applicationId,
          contactPersonRecordTypeId
        );
      return contactPersons;
    }
  }

  /**
   * @description : This method retrieves a list of immediate shareholders related to the application record.
   *  List<Application_Participant__c> - a list of immediate shareholders.
   **/
  public List<Application_Participant__c> immediateShareholders {
    get {
      Id contactPersonRecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Immediate_Shareholder')
        .getRecordTypeId();

      List<Application_Participant__c> immediateShareholders = new SEL_CIBApplicationParticipant()
        .selectAppsByApplicationIdRecordIdList(
          applicationId,
          contactPersonRecordTypeId
        );
      return immediateShareholders;
    }
  }

  /**
   * @description : This method retrieves a list of intermediate shareholders related to the application record.
   *  @return List<Application_Participant__c> - a list of intermediate shareholders.
   **/
  public List<Application_Participant__c> intermediateShareholders {
    get {
      Id contactPersonRecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Intermediate_Shareholder')
        .getRecordTypeId();

      List<Application_Participant__c> intermediateShareholders = new SEL_CIBApplicationParticipant()
        .selectAppsByApplicationIdRecordIdList(
          applicationId,
          contactPersonRecordTypeId
        );
      return intermediateShareholders;
    }
  }

  /**
   * @description : This method retrieves a list of ultimate shareholders related to the application record.
   *  List<Application_Participant__c> - a list of ultimate shareholders.
   **/
  public List<Application_Participant__c> ultimateShareholders {
    get {
      Id contactPersonRecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Ultimate_Shareholder')
        .getRecordTypeId();

      List<Application_Participant__c> ultimateShareholders = new SEL_CIBApplicationParticipant()
        .selectAppsByApplicationIdRecordIdList(
          applicationId,
          contactPersonRecordTypeId
        );
      return ultimateShareholders;
    }
  }

  /**
   * @description : This method retrieves a list of individual directors related to the application record.
   *  List<Application_Participant__c> - a list of individual directors.
   **/
  public List<Application_Participant__c> individualDirectors {
    get {
      Id contactPersonRecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Director')
        .getRecordTypeId();

      List<Application_Participant__c> individualDirectors = new SEL_CIBApplicationParticipant()
        .selectAppsByApplicationIdRecordIdList(
          applicationId,
          contactPersonRecordTypeId
        );
      return individualDirectors;
    }
  }

  /**
   * @description : This method retrieves a list of Internet Banking Credentials related to the application record.
   *  List<Application_Participant__c> - a list of Internet Banking Credentials.
   **/
  public List<Application_Participant__c> internetBankingCredentials {
    get {
      Id contactPersonRecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Internet_banking_credential')
        .getRecordTypeId();

      List<Application_Participant__c> internetBankingCredentials = new SEL_CIBApplicationParticipant()
        .selectAppsByApplicationIdRecordIdList(
          applicationId,
          contactPersonRecordTypeId
        );
      return internetBankingCredentials;
    }
  }

  /**
   * @description : This method retrieves a list of corporate directors related to the application record.
   *  List<Application_Participant__c> - a list of corporate directors.
   **/
  public List<Application_Participant__c> corporateDirectors {
    get {
      Id contactPersonRecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Corporate_Director')
        .getRecordTypeId();

      List<Application_Participant__c> corporateDirectors = new SEL_CIBApplicationParticipant()
        .selectAppsByApplicationIdRecordIdList(
          applicationId,
          contactPersonRecordTypeId
        );
      return corporateDirectors;
    }
  }

  /**
   * @description : This method retrieves a list of beneficial owners related to the application record.
   *  List<Application_Participant__c> - a list of beneficial owners.
   **/
  public List<Application_Participant__c> beneficialOwners {
    get {
      Id contactPersonRecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Beneficial_Owner')
        .getRecordTypeId();

      List<Application_Participant__c> beneficialOwners = new SEL_CIBApplicationParticipant()
        .selectAppsByApplicationIdRecordIdList(
          applicationId,
          contactPersonRecordTypeId
        );
      return beneficialOwners;
    }
  }

  /**
   * @description : This method retrieves a list of beneficial owners related to the application record.
   *  List<Application_Participant__c> - a list of beneficial owners.
   **/
  public List<Application_Participant__c> controllingPersons {
    get {
      Id contactPersonRecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Controlling_person')
        .getRecordTypeId();

      List<Application_Participant__c> controllingPersons = new SEL_CIBApplicationParticipant()
        .selectAppsByApplicationIdRecordIdList(
          applicationId,
          contactPersonRecordTypeId
        );
      return controllingPersons;
    }
  }

  /**
   * @description : This method retrieves a list of beneficial owners related to the application record.
   *  List<Application_Participant__c> - a list of beneficial owners.
   **/
  public List<Application_Participant__c> seniorManagers {
    get {
      Id contactPersonRecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Senior_management_official')
        .getRecordTypeId();

      List<Application_Participant__c> seniorManagers = new SEL_CIBApplicationParticipant()
        .selectAppsByApplicationIdRecordIdList(
          applicationId,
          contactPersonRecordTypeId
        );
      return seniorManagers;
    }
  }

  /**
   * @description This property returns a list of authorised signatories for a given application.
   * @return List<Application_Participant__c> - a list of authorised signatories for a given application.
   */
  public List<Application_Participant__c> authorisedSignatories {
    get {
      Id contactPersonRecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Authorised_Signatory')
        .getRecordTypeId();

      List<Application_Participant__c> authorisedSignatories = new SEL_CIBApplicationParticipant()
        .selectAppsByApplicationIdRecordIdList(
          applicationId,
          contactPersonRecordTypeId
        );
      for (
        Application_Participant__c authorisedSignatory : authorisedSignatories
      ) {
        authorisedSignatory.CIB_Sequence__c += 2;
      }

      return authorisedSignatories;
    }
  }

  public List<List<Application_Participant__c>> twoRowAuthorisedSignatories {
    get {
      List<List<Application_Participant__c>> twoRowAuthorisedSignatories = new List<List<Application_Participant__c>>();
      for (Integer i = 0; i < authorisedSignatories.size(); i += 2) {
        List<Application_Participant__c> row = new List<Application_Participant__c>();
        row.add(authorisedSignatories[i]);
        if (i + 1 < authorisedSignatories.size()) {
          row.add(authorisedSignatories[i + 1]);
        }
        twoRowAuthorisedSignatories.add(row);
      }
      return twoRowAuthorisedSignatories;
    }
    set;
  }

  /**
   * @description This getter method returns a list of Application_Line_Item__c records that represent tax jurisdictions for a specific Application__c record.
   * @return List<Application_Line_Item__c> - A list of Application_Line_Item__c records representing tax jurisdictions.
   */
  public List<Application_Line_Item__c> taxJuristictions {
    get {
      Id taxResidenceRecordTypeId = Schema.SObjectType.Application_Line_Item__c
        .getRecordTypeInfosByDeveloperName()
        .get('Tax_Residence')
        .getRecordTypeId();

      List<Application_Line_Item__c> taxJuristictions = new SEL_CIBApplicationLineItem()
        .selectLineItemsByApplicationIdRecordType(
          applicationId,
          taxResidenceRecordTypeId
        );
      return taxJuristictions;
    }
  }

  /**
   * @description Returns a list of Application_Line_Item__c records with the record type 'Annual_Turnover' for the current page's Application__c record.
   * If no records are found, returns an empty list.
   */
  public List<Application_Line_Item__c> annualTurnovers {
    get {
      Id annualTurnOverRecordTypeId = Schema.SObjectType.Application_Line_Item__c
        .getRecordTypeInfosByDeveloperName()
        .get('Annual_Turnover')
        .getRecordTypeId();

      List<Application_Line_Item__c> annualTurnovers = new SEL_CIBApplicationLineItem()
        .selectLineItemsByApplicationIdRecordType(
          applicationId,
          annualTurnOverRecordTypeId
        );
      return annualTurnovers;
    }
  }

  /**
   * @description Returns a list of Application_Line_Item__c records that have a record type of 'Nature_Of_Business' and are associated with the current page's Application__c record.
   * @return List<Application_Line_Item__c> - a list of Application_Line_Item__c records that have a record type of 'Nature_Of_Business' and are associated with the current page's Application__c record.
   */
  public List<Application_Line_Item__c> businessNatures {
    get {
      Id businessNatureRecordTypeId = Schema.SObjectType.Application_Line_Item__c
        .getRecordTypeInfosByDeveloperName()
        .get('Nature_Of_Business')
        .getRecordTypeId();

      List<Application_Line_Item__c> businessNatures = new SEL_CIBApplicationLineItem()
        .selectLineItemsByApplicationIdRecordType(
          applicationId,
          businessNatureRecordTypeId
        );
      return businessNatures;
    }
  }
  /**
   * @description Returns a list of Application_Line_Item__c records that have a record type of 'Business_Activity' and are associated with the current page's Application__c record.
   */
  public Boolean negateValue { get; set; }
  /**
   * @description Returns a list of Application_Line_Item__c records that have a record type of 'Business_Activity' and are associated with the current page's Application__c record.
   */
  public string dateFormat {
    get {
      return '{0, date, MMMM d\',\'  yyyy}';
    }
  }

  /**
   * @description constructor method for class CIB_CTRL_AOMandateGeneratePdf.
   */
  public CIB_CTRL_AOMandateGeneratePdf() {
    applicationId = ApexPages.currentPage()
      .getParameters()
      .get('id')
      .escapeHtml4();
    List<Application__c> applications = new SEL_CIBApplication()
      .selectAppsById(applicationId);

    if (applications != null && applications.size() > 0) {
      applicationRecord = applications[0];
      negateValue = !applicationRecord.CIB_ACI_IsTradingWithRegisteredName__c;
    }
  }

  /**
   * @description Returns a list of email addresses for the contact associated with the given application ID,
   * as well as all authorised signatories associated with the application.
   * @param applicationId The ID of the application to retrieve recipients for.
   * @return A list of email addresses for the contact associated with the given application ID,
   * as well as all authorised signatories associated with the application.
   */
  public static List<String> getRecipients(Id applicationId) {
    Application__c app = [
      SELECT
        Id,
        Contact__r.Email,
        (
          SELECT
            Id,
            Name,
            CIB_PermanentResidentialAddress__c,
            CIB_IncorportationNumber__c,
            CIB_IncorporationDate__c,
            CIB_CountryOfIncorporation__c,
            CIB_MobileNumber__c,
            TelephoneNumber__c,
            Email__c,
            CIB_Sequence__c
          FROM Application_Participants__r
          WHERE RecordType.DeveloperName = 'Authorised_Signatory'
        )
      FROM Application__c
      WHERE Id = :applicationId
      LIMIT 1
    ];
    List<String> recipients = new List<String>();
    recipients.add(app.Contact__r.Email);
    for (
      Application_Participant__c participant : app.Application_Participants__r
    ) {
      recipients.add(participant.Email__c);
    }
    return recipients;
  }

  /**
   * @description This method generates a PDF file for a given application ID, creates a new echosign_dev1__SIGN_Agreement__c record,
   * and inserts a new ContentVersion record with the PDF file as its content. It also creates echosign_dev1__SIGN_Recipients__c
   * records for each recipient of the agreement and sends the agreement for signature.
   * @param applicationId The ID of the Application__c record for which the PDF file is generated.
   * @return The ID of the echosign_dev1__SIGN_Agreement__c record that was created.
   * @throws AuraHandledException If an exception occurs while executing the method.
   */
  @AuraEnabled
  public static String generatePdf(String applicationId) {
    try {
      PageReference objPagePdf = Page.CIB_PDF_BasicCompanyInformation;
      objPagePdf.getParameters().put('Id', applicationId);

      Blob pdfContent = Test.isRunningTest()
        ? Blob.valueOf('Test PDF')
        : objPagePdf.getContentAsPDF();

      return EncodingUtil.base64Encode(pdfContent);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<String> generateMandateAgreement(
    string applicationId,
    string agreementName
  ) {
    List<Application__c> applications = new SEL_CIBApplication()
      .selectAppsById(applicationId);

    if (applications == null || applications.size() == 0) {
      throw new AuraHandledException(
        'No application record found for ID ' + applicationId
      );
    }

    Application__c objApplication = applications.get(0);
    Application_Document__c appDoc = new Application_Document__c();
    appDoc.Application__c = applicationId;
    appDoc.Document_Type__c = 'Mandate Agreement';
    appDoc.FileNet_Id__c = agreementName;
    appDoc.Document_Label__c = agreementName;

    CIB_SEL_Fflib_FrameWork.insertfflibFrameWorkList(
      new List<Schema.SObjectType>{ Application_Document__c.SObjectType },
      new List<Application_Document__c>{ appDoc }
    );

    String filename =
      'Application ' +
      objApplication.Name +
      ' - ' +
      objApplication.Client__r.Name +
      '.pdf';

    DateTime now = System.now();
    echosign_dev1__SIGN_Agreement__c agreementRec = new echosign_dev1__SIGN_Agreement__c();
    agreementRec.Name =
      filename.replace('.pdf', '-') +
      ' ' +
      now.format('MM/dd/yyyy HH:mm:ss');
    agreementRec.echosign_dev1__SignatureType__c = 'e-Signature';
    agreementRec.echosign_dev1__SignatureOrder__c = 'Sequential';

    agreementRec.echosign_dev1__Account__c = objApplication.Client__c;
    agreementRec.echosign_dev1__Enable_Hosted_Signing__c = true;
    agreementRec.echosign_dev1__Signing_Deadline__c = System.today()
      .addDays(14);
    agreementRec.echosign_dev1__Enable_Automatic_Reminders__c = true;
    agreementRec.echosign_dev1__RemindRecipient__c = 'Every Day, Until Signed';
    agreementRec.application__c = applicationId;

    insert agreementRec;

    List<echosign_dev1__SIGN_Recipients__c> recipients = new List<echosign_dev1__SIGN_Recipients__c>();

    Integer index = 1;
    for (string recipient : getRecipients(applicationId)) {
      echosign_dev1__SIGN_Recipients__c recipientRec = new echosign_dev1__SIGN_Recipients__c();
      recipientRec.echosign_dev1__Agreement__c = agreementRec.Id;
      recipientRec.echosign_dev1__Email_Address__c = recipient;
      recipientRec.echosign_dev1__Recipient_Role__c = 'Signer';
      recipientRec.echosign_dev1__Recipient_Type__c = 'Email';
      recipientRec.echosign_dev1__Order_Number__c = index;
      recipientRec.echosign_dev1__Participant_Set_Order_Number__c = index;
      recipients.add(recipientRec);
      index++;
    }

    index++;
    echosign_dev1__SIGN_Recipients__c recipientRec = new echosign_dev1__SIGN_Recipients__c();
    recipientRec.echosign_dev1__Agreement__c = agreementRec.Id;
    recipientRec.echosign_dev1__Email_Address__c = UserInfo.getUserEmail();
    recipientRec.echosign_dev1__Recipient_Role__c = 'Signer';
    recipientRec.echosign_dev1__Recipient_Type__c = 'Email';
    recipientRec.echosign_dev1__Order_Number__c = index;
    recipientRec.echosign_dev1__Participant_Set_Order_Number__c = index;
    recipients.add(recipientRec);

    if (recipients.size() > 0) {
      insert recipients;
    }
    // agreementRec.echosign_dev1__Background_Action__c = 'Send';
    // update agreementRec;

    return new List<String>{ agreementRec.Id, appDoc.Id };
  }

  /**
   * @description Wrapper class for application documents.
   */
  public class ApplicationDocumentWrapper {
    /**
     * @description The title of the document.
     */
    @AuraEnabled
    public string title { get; set; }

    /**
     * @description The type of the document.
     */
    @AuraEnabled
    public string type { get; set; }

    /**
     * @description The documentId of the document.
     */
    @AuraEnabled
    public string documentId { get; set; }

    /**
     * @description The name of the participant associated with the document.
     */
    @AuraEnabled
    public string participantName { get; set; }
  }

  /**
   * @description Returns a list of ApplicationDocumentWrapper objects for a given application ID.
   * Each ApplicationDocumentWrapper object contains information about a certification document
   * associated with the application, including the document title, participant name, type, and body.
   *
   * @param applicationId The ID of the application for which to generate certification documents.
   * @return List<List<ApplicationDocumentWrapper>> A list of ApplicationDocumentWrapper objects.
   * @throws AuraHandledException If an exception occurs while generating the certification documents.
   */
  @AuraEnabled
  public static Map<Id, List<ApplicationDocumentWrapper>> generateCertificationDocuments(
    String applicationId
  ) {
    try {
      List<Application__c> applications = new SEL_CIBApplication()
        .selectAppsById(applicationId);
      if (applications == null || applications.size() == 0) {
        throw new AuraHandledException(
          'No application record found for ID ' + applicationId
        );
      }
      Application__c application = applications[0];

      Map<Id, List<ApplicationDocumentWrapper>> appDocWrappers = new Map<Id, List<ApplicationDocumentWrapper>>();
      Id relatedCertOfficerId = application.CIB_IsCertOfficialRelatedParty__c
        ? application.CIB_RelatedCertOfficer__c
        : null;

      List<Application_Document__c> appDocs = new SEL_ApplicationDocuments()
        .selectByApplicationIdWithSection(applicationId);

      for (Application_Document__c appDoc : appDocs) {
        if (appDoc.CertifyingOfficial__c == null) {
          System.debug(
            '@@ Skipped appDoc.CertifyingOfficial__c: ' +
            JSON.serializePretty(appDoc.CertifyingOfficial__c)
          );
          continue;
        }

        ApplicationDocumentWrapper doc = new ApplicationDocumentWrapper();
        doc.title = appDoc.Document_Type__c;
        doc.participantName = appDoc.Application_Participant__r != null
          ? appDoc.Application_Participant__r.Name
          : application.Client__r.Name;
        for (
          ContentDocumentLink contentDocumentLink : appDoc.ContentDocumentLinks
        ) {
          doc.type = contentDocumentLink.ContentDocument.LatestPublishedVersion.FileExtension;
          doc.documentId = contentDocumentLink.ContentDocumentId;
          if (!appDocWrappers.containsKey(appDoc.CertifyingOfficial__c)) {
            appDocWrappers.put(
              appDoc.CertifyingOfficial__c,
              new List<ApplicationDocumentWrapper>()
            );
          }
          List<ApplicationDocumentWrapper> temp = appDocWrappers.get(
            appDoc.CertifyingOfficial__c
          );
          temp.add(doc);
          appDocWrappers.put(appDoc.CertifyingOfficial__c, temp);
        }
      }

      return appDocWrappers;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Returns the body of a file for a given ContentDocument ID.
   * @param contentDocumentId The ID of the ContentDocument record.
   * @return The body of the file.
   */
  @AuraEnabled
  public static String getFileBody(String contentDocumentId) {
    ContentVersion cv = [
      SELECT VersionData
      FROM ContentVersion
      WHERE ContentDocumentId = :contentDocumentId
      LIMIT 1
    ];
    return EncodingUtil.base64Encode(cv.VersionData);
  }

  /**
   * @description Returns a list of authorized signatories for a given application ID.
   * @param applicationId The ID of the application.
   * @return List of Application_Participant__c records representing authorized signatories.
   * @AuraEnabled
   */
  @AuraEnabled
  public static List<Application_Participant__c> getAutorisedSignatories(
    String applicationId
  ) {
    try {
      Id contactPersonRecordTypeId = Schema.SObjectType.Application_Participant__c
        .getRecordTypeInfosByDeveloperName()
        .get('Authorised_Signatory')
        .getRecordTypeId();

      List<Application_Participant__c> authorisedSignatories = new SEL_CIBApplicationParticipant()
        .selectAppsByApplicationIdRecordIdList(
          applicationId,
          contactPersonRecordTypeId
        );
      return authorisedSignatories;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description This method saves a certification agreement and generates a PDF document for the agreement using Echosign.
   * @param applicationId The ID of the application record.
   * @param isCertifyingOfficer A Boolean value indicating whether the certifying officer is signing the agreement.
   * @param signatoryId The ID of the signatory participant record.
   * @param certificationDocument The base64-encoded string representation of the certification document.
   * @return List<Id> The echosign_dev1__SIGN_Agreement__c record for the saved agreement and Application Document record Id.
   * @throws AuraHandledException if an exception occurs during the execution of the method.
   */
  @AuraEnabled
  public static List<Id> saveCertificationAgreement(
    String applicationId,
    String agreementName,
    Id appParticipantId
  ) {
    List<Application__c> applications = new SEL_CIBApplication()
      .selectAppsById(applicationId);

    if (applications == null || applications.size() == 0) {
      throw new AuraHandledException(
        'No application record found for ID ' + applicationId
      );
    }
    Application__c objApplication = applications[0];

    echosign_dev1__SIGN_Agreement__c agreementRec = new echosign_dev1__SIGN_Agreement__c();
    agreementRec.Name =
      agreementName.replace('.pdf', '-');
    agreementRec.echosign_dev1__SignatureType__c = 'e-Signature';
    agreementRec.echosign_dev1__SignatureOrder__c = 'Sequential';

    agreementRec.echosign_dev1__Account__c = objApplication.Client__c;
    agreementRec.echosign_dev1__Enable_Hosted_Signing__c = true;
    agreementRec.echosign_dev1__Signing_Deadline__c = System.today()
      .addDays(14);
    agreementRec.echosign_dev1__Enable_Automatic_Reminders__c = true;
    agreementRec.echosign_dev1__RemindRecipient__c = 'Every Day, Until Signed';
    agreementRec.application__c = applicationId;

    insert agreementRec;

    List<Application_Participant__c> relatedCertOfficer = new SEL_CIBApplicationParticipant()
      .selectAppById(appParticipantId);

    Application_Document__c appDoc = new Application_Document__c();
    appDoc.Application__c = applicationId;
    appDoc.Document_Type__c = agreementName;
    appDoc.FileNet_Id__c = agreementName;

    CIB_SEL_Fflib_FrameWork.insertfflibFrameWorkList(
      new List<Schema.SObjectType>{ Application_Document__c.SObjectType },
      new List<Application_Document__c>{ appDoc }
    );

    echosign_dev1__SIGN_Recipients__c recipientRec = new echosign_dev1__SIGN_Recipients__c();
    recipientRec.echosign_dev1__Agreement__c = agreementRec.Id;
    recipientRec.echosign_dev1__Email_Address__c = relatedCertOfficer[0].Email__c;
    recipientRec.echosign_dev1__Recipient_Role__c = 'Signer';
    recipientRec.echosign_dev1__Recipient_Type__c = 'Email';
    recipientRec.echosign_dev1__Order_Number__c = 1;
    recipientRec.echosign_dev1__Participant_Set_Order_Number__c = 1;
    insert recipientRec;

    return new List<Id>{ agreementRec.Id, appDoc.Id };
  }
}