/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_CTRL_ApplicationZipFileDownload
@ Description       : This class provides functionality to retrieve a list of ContentVersion Ids for a given Application record Id.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP
***************************************************************************************/
public without sharing class CIB_CTRL_ApplicationZipFileDownload {
  /**
   * @description : The logger for this class.
   * @var sbg.rflib_Logger
   */
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
    .createLogger('CIB_CTRL_ApplicationZipFileDownload');

  /**
   * @description : This method retrieves a list of ContentVersion Ids for a given Application record Id.
   * @param recordId : The Id of the Application record.
   * @return List<GetFileIdOutputWrapper> : A list of ContentVersion Ids.
   */
  @AuraEnabled
  public static List<GetFileIdOutputWrapper> getfileIds(String recordId) {
    Set<Id> contDocIds = new Set<Id>();
    Set<id> documentIds = new Set<Id>();
    Map<Id, GetFileIdOutputWrapper> output = new Map<Id, GetFileIdOutputWrapper>();
    Map<Id, Id> appDocIdToConVerId = new Map<Id, Id>();

    if (String.isBlank(recordId)) {
      return new List<GetFileIdOutputWrapper>();
    }

    List<Application_Document__c> appdoclistdata = new SEL_ApplicationDocuments()
      .selectByApplicationIdWithSection(recordId);

    for (Application_Document__c s : appdoclistdata) {
      documentIds.add(s.id);
      GetFileIdOutputWrapper doc = new GetFileIdOutputWrapper();
      doc.documentType = s.Document_Type__c;
      if (s.Application_Participant__r != null) {
        doc.participantName =
          s.Application_Participant__r.Name +
          ' - ' +
          s.Application_Participant__r.RecordType.Name;
      }
      doc.sectionName = s.Application_Section__r.Title__c;
      output.put(s.Id, doc);
    }

    for (
      ContentDocumentLink cdl : new SEL_ContentDocumentLink()
        .selectByLinkedEntityId(documentIds)
    ) {
      appDocIdToConVerId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
    }

    for (
      ContentVersion cdv : new SEL_ContentVersion()
        .selectByContentDocumentId(appDocIdToConVerId.keySet())
    ) {
      Id linkedEntityId = appDocIdToConVerId.get(cdv.ContentDocumentId);
      GetFileIdOutputWrapper doc = output.get(linkedEntityId);
      doc.documentId = cdv.Id;
      doc.documentType += '.' + cdv.FileType.toLowerCase();
    }

    return output.values();
  }

  /**
   * @description : This class is a wrapper class for the output of a list of ContentVersion Ids with related information.
   */
  public class GetFileIdOutputWrapper {
    /**
     * @description : The Id of the ContentVersion record.
     */
    @AuraEnabled
    public string documentId;

    /**
     * @description : The document type of the application document.
     */
    @AuraEnabled
    public string documentType;

    /**
     * @description : Name of the related participant.
     */
    @AuraEnabled
    public string participantName;

    /**
     * @description : Name of the related section.
     */
    @AuraEnabled
    public string sectionName;
  }

  /**
   * @description : This method is used to get api capable session id;
   * @return String : sessionId
   */
  @AuraEnabled
  public static String getSessionId() {
    try {
      final String content = Page.CIB_APISessionIdHelper.getContent()
        .toString();
      Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(
        content
      );
      return (String) jsonMap.get('sessionId');
    } catch (Exception error) {
      return UserInfo.getSessionId();
    }
  }
}