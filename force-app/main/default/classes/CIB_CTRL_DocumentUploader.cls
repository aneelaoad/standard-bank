/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_CTRL_DocumentUploader
@ Description       : Contains functionality for uploading documents and relating them to an application or application participant.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP-24726
***************************************************************************************/
@RestResource(urlMapping='/CIB_CTRL_DocumentUploader')
global without sharing class CIB_CTRL_DocumentUploader {
  public static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
    .createLogger('CIB_CTRL_DocumentUploader');

  /**
   * @description  : This class contains a wrapper for input parameters when uploading a file.
   */
  global class UploadFileInputWrapper {
    /**
     * @description  : The record ID associated with the uploaded file.
     */
    public Id recordId { get; set; }

    /**
     * @description  : The section ID associated with the uploaded file.
     */
    public Id sectionId { get; set; }

    /**
     * @description  : The document ID associated with the uploaded file.
     */
    public Id documentId { get; set; }

    /**
     * @description  : The type of document being uploaded.
     */
    public String documentType { get; set; }

    /**
     * @description  : The name of the uploaded document.
     */
    public String documentName { get; set; }

    /**
     * @description  : The base64-encoded content of the uploaded document.
     */
    public String base64 { get; set; }

    /**
     * @description  : The ID of the content document associated with the uploaded document.
     */
    public String contentDocumentId { get; set; }

    /**
     * @description  : The file extension of the uploaded document.
     */
    public String documentExtension { get; set; }

    /**
     * @description  : The status of the uploaded document.
     */
    public String documentStatus { get; set; }
  }

  /**
   * @description  : Wrapper class for output parameters when uploading a file.
   */
  global class UploadFileOutputWrapper {
    /**
     * @description  : The ID of the document.
     */
    @AuraEnabled
    public Id documentId { get; set; }
    /**
     * @description  : The URL of the document.
     */
    @AuraEnabled
    public string documentUrl { get; set; }
  }

  /**
   * @description  : Wrapper class for file output data.
   */
  global class GetFileOutputWrapper {
    /**
     * @description  : The ID of the document.
     */
    @AuraEnabled
    public Id documentId { get; set; }
    /**
     * @description  : The type of the document.
     */
    @AuraEnabled
    public String documentType { get; set; }
    /**
     * @description  : The name of the document.
     */
    @AuraEnabled
    public String documentName { get; set; }
    /**
     * @description  : The base64-encoded content of the document.
     */
    @AuraEnabled
    public String base64 { get; set; }
    /**
     * @description  : The extension of the document.
     */
    @AuraEnabled
    public String documentExtension { get; set; }
    /**
     * @description  : The URL of the document.
     */
    @AuraEnabled
    public string documentUrl { get; set; }
  }

  /**
   * @description  : This method is used to upload a file and link it to an application or application participant.
   * @param input - An instance of the UploadFileInputWrapper class containing the file information.
   * @return An instance of the UploadFileOutputWrapper class containing the uploaded file information.
   */
  @HttpPost
  global static UploadFileOutputWrapper uploadFile(
    UploadFileInputWrapper input
  ) {
    Id applicationId;
    Id applicationParticipantId;

    if (isApplication(input.recordId)) {
      applicationId = Id.valueOf(input.recordId);
    } else {
      applicationParticipantId = Id.valueOf(input.recordId);
      applicationId = getApplicationIdFromParticipant(applicationParticipantId);
    }

    final Application_Document__c appDoc = getApplicationDocument(
      applicationId,
      applicationParticipantId,
      input
    );

    // final ContentVersion cVersion = createContentVersion(
    //   input.documentName,
    //   input.base64,
    //   input.documentExtension
    // );

    createContentDocumentLink(
      input.contentDocumentId,
      appDoc,
      applicationId,
      applicationParticipantId
    );

    final UploadFileOutputWrapper output = new UploadFileOutputWrapper();
    output.documentId = appDoc.Id;
    output.documentUrl = input.contentDocumentId;

    return output;
  }

  /**
   * @description  : Updates the status of a document and optionally assigns it to a participant.
   * @param documentId The ID of the document to update.
   * @param participantId The ID of the participant to assign the document to (optional).
   */
  @AuraEnabled
  public static void updateStatus(Id documentId, Id participantId) {
    try {
      final List<Application_Document__c> documents = new SEL_ApplicationDocuments()
        .selectById(new Set<Id>{ documentId });

      if (documents.size() == 0) {
        return;
      }

      final Application_Document__c document = documents[0];
      document.Document_Status__c = 'Uploaded';
      if (participantId != null) {
        document.Application_Participant__c = participantId;
      }

      CIB_SEL_Fflib_FrameWork.updatefflibFrameWork(
        new List<SObjectType>{ Application_Document__c.SObjectType },
        document
      );
    } catch (Exception e) {
      LOGGER.error('An error occurred while updating the document status.');
    }
  }

  /**
   * @description  : Returns the session ID of the current user.
   * @return The session ID of the current user.
   */
  @AuraEnabled
  public static String getSessionId() {
    return UserInfo.getSessionId();
  }

  /**
   * @description  : Returns a wrapper containing the file information for a given record, section, and document type.
   * @param recordId The ID of the record to retrieve the file for.
   * @param sectionId The ID of the section to retrieve the file for.
   * @param documentType The type of document to retrieve.
   * @return A wrapper containing the file information, or null if no document is found.
   */
  @AuraEnabled
  public static CIB_CTRL_DocumentUploader.GetFileOutputWrapper getFile(
    Id recordId,
    Id sectionId,
    String documentType
  ) {
    final List<Application_Document__c> applicationDocuments = new SEL_ApplicationDocuments()
      .selectByApplicationAndSectionAndType(recordId, sectionId, documentType);

    if (applicationDocuments.size() == 0) {
      return null;
    }

    final Application_Document__c appDoc = applicationDocuments[0];

    final List<ContentDocumentLink> conDocLinks = new SEL_ContentDocumentLink()
      .selectByLinkedEntityId(new Set<id>{ appDoc.Id });

    if (conDocLinks.size() == 0) {
      return null;
    }

    final ContentDocumentLink contentDocumentLink = conDocLinks[0];

    // Get the ContentVersion record associated with the ContentDocumentLink record
    final ContentVersion versionData = [
      SELECT VersionData
      FROM ContentVersion
      WHERE Id = :contentDocumentLink.ContentDocument.LatestPublishedVersionId
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    final GetFileOutputWrapper output = new GetFileOutputWrapper();
    output.documentType = documentType;
    output.documentId = appDoc.Id;
    output.documentName = appDoc.Document_Label__c;
    output.base64 = EncodingUtil.base64Encode(versionData.VersionData);
    output.documentExtension = contentDocumentLink.ContentDocument.FileExtension;

    return output;
  }

  /**
   * @description  : Returns the record type ID for the 'CIB_Mauritius_Document' record type of the 'Application_Document__c' object.
   * @return The ID of the 'CIB_Mauritius_Document' record type.
   */
  public static Id getRecordTypeId() {
    return Schema.getGlobalDescribe()
      .get('Application_Document__c')
      .getDescribe()
      .getRecordTypeInfosByDeveloperName()
      .get('CIB_Mauritius_Document')
      .getRecordTypeId();
  }

  /**
   * @description  : Returns a Boolean value indicating whether the given record ID belongs to an Application__c object.
   * @param recordId The ID of the record to check.
   * @return True if the record ID belongs to an Application__c object, false otherwise.
   */
  public static Boolean isApplication(String recordId) {
    return Id.valueOf(recordId).getSobjectType().getDescribe().getName() ==
      'Application__c';
  }

  /**
   * @description  : Returns the Application Id associated with the given participant Id.
   * @param participantId The Id of the participant.
   * @return The Application Id associated with the participant.
   */
  public static Id getApplicationIdFromParticipant(Id participantId) {
    return [
      SELECT Application__c
      FROM Application_Participant__c
      WHERE Id = :participantId
      LIMIT 1
    ]
    .Application__c;
  }

  /**
   * @description  : Returns an Application_Document__c record for the given application, application participant, and document type. If a matching record already exists, it is returned. Otherwise, a new record is created and returned.   *
   * @param applicationId The ID of the application.
   * @param applicationParticipantId The ID of the application participant.
   * @param input An UploadFileInputWrapper object containing information about the uploaded file.
   * @return An Application_Document__c record.
   */
  public static Application_Document__c getApplicationDocument(
    string applicationId,
    string applicationParticipantId,
    UploadFileInputWrapper input
  ) {
    final List<Application_Document__c> existingDocuments = new SEL_ApplicationDocuments()
      .selectUploadedByApplicationPraticipantAndType(
        applicationId,
        applicationParticipantId,
        input.sectionId,
        input.documentType
      );
    Application_Document__c document;
    if (existingDocuments.size() > 0) {
      document = existingDocuments[0];
    } else {
      document = new Application_Document__c();
      document.Application__c = applicationId;
      document.Application_Participant__c = applicationParticipantId;
      document.RecordTypeId = getRecordTypeId();
      document.Document_Status__c = input.documentStatus;
      document.Document_Type__c = input.documentType;
      document.Application_Section__c = input.sectionId;
      document.Document_Label__c = input.documentName;

      CIB_SEL_Fflib_FrameWork.insertfflibFrameWorkList(
        new List<SObjectType>{ Application_Document__c.SObjectType },
        new List<Application_Document__c>{ document }
      );
    }
    return document;
  }

  /**
   * @description  : Creates a new ContentVersion record with the specified document name, base64-encoded file content, and document extension. Inserts the new ContentVersion record into the database and returns the inserted record.
   * @param documentName The name of the document to be created.
   * @param base64 The base64-encoded content of the document.
   * @param documentExtension The extension of the document (e.g. "pdf", "docx", etc.).
   * @return The newly created ContentVersion record.
   */
  public static ContentVersion createContentVersion(
    String documentName,
    String base64,
    String documentExtension
  ) {
    ContentVersion cVersion = new ContentVersion();
    cVersion.ContentLocation = 'S';
    cVersion.PathOnClient = documentName + '.' + documentExtension;
    cVersion.Title = documentName + '.' + documentExtension;
    cVersion.VersionData = EncodingUtil.base64Decode(base64);

    insert cVersion;

    cVersion = [
      SELECT Id, ContentDocumentId, PathOnClient, VersionDataUrl
      FROM ContentVersion
      WHERE Id = :cVersion.Id
      LIMIT 1
    ];

    return cVersion;
  }

  /**
   * @description  : Creates a list of ContentDocumentLink records for a given ContentVersion and Application_Document__c record.
   * @param cVersion The ContentVersion record to link to the Application_Document__c record.
   * @param appDoc The Application_Document__c record to link to the ContentVersion record.
   * @param applicationId The Id of the Application record associated with the Application_Document__c record.
   * @param applicationParticipantId The Id of the Application_Participant__c record associated with the Application record.
   * @return A list of ContentDocumentLink records created for the given ContentVersion and Application_Document__c record.
   */
  public static List<ContentDocumentLink> createContentDocumentLink(
    String contentDocumentId,
    Application_Document__c appDoc,
    Id applicationId,
    Id applicationParticipantId
  ) {
    final List<ContentDocumentLink> links = new List<ContentDocumentLink>();

    ContentDocumentLink link = new ContentDocumentLink();
    link.LinkedEntityId = appDoc.Id;
    link.ContentDocumentId = contentDocumentId;
    link.ShareType = 'V';
    links.add(link);

    CIB_SEL_Fflib_FrameWork.insertfflibFrameWorkList(
      new List<SObjectType>{ ContentDocumentLink.SObjectType },
      links
    );
    return links;
  }
}