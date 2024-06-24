/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_CTRL_DocumentContainer
@ Description       : This class represents a container for documents component. It provides methods to manage and retrieve documents to be deplayed dynamically in the UI.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP
***************************************************************************************/
public with sharing class CIB_CTRL_DocumentContainer {
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
    .createLogger('CIB_CTRL_DocumentContainer');
  /**
   * @description This method groups documents per application section
   * @param applicationId - string
   * @param sectionId - string
   * @param isParticipant - Boolean
   * @return List<GetDocumentOutputWrapper>
   */
  @AuraEnabled
  public static List<GetDocumentOutputWrapper> getContainerDocuments(
    String applicationId,
    String sectionId,
    Boolean isParticipant
  ) {
    try {
      Application__c applicationRecord = new SEL_CIBApplication()
        .selectApplicationById(applicationId);
      Application_Section__c sectionRecord = new SEL_CIBApplicationSection()
        .selectSectionsById(sectionId)
        .get(0);

      String type = isParticipant
        ? CIB_Constants.APPLICATION_DOCUMENT_TYPE_PARTICIPANT
        : CIB_Constants.APPLICATION_DOCUMENT_TYPE_ENTITY;

      // Fetch data from Salesforce database
      List<Application_Document_Setting__mdt> records = [
        SELECT
          Label,
          Document_Type__c,
          Document_Label__c,
          Guidelines__c,
          Is_Required__c,
          IsHidden__c,
          Type__c
        FROM Application_Document_Setting__mdt
        WHERE
          ApplicationSectionSetting__r.Screen_Api_Name__c = :sectionRecord.ScreenApiName__c
          AND Type__c = :type
          AND Entity_Type__c = :applicationRecord.CIB_BAI_EntityType__c
        WITH SECURITY_ENFORCED
      ];

      List<GetDocumentOutputWrapper> outputList = new List<GetDocumentOutputWrapper>();

      for (Application_Document_Setting__mdt record : records) {
        GetDocumentOutputWrapper item = new GetDocumentOutputWrapper();
        if(record.Document_Type__c == null || record.Document_Label__c == null) {
          continue;
        }
        item.key = record.Document_Label__c;
        item.label = record.Document_Label__c;
        item.type = record.Document_Type__c;
        item.guidelines = record.Guidelines__c;
        item.isRequired = record.Is_Required__c;
        item.isHidden = record.IsHidden__c;
        item.isParticipantDocument = isParticipant;
        outputList.add(item);
      }
      return outputList;
    } catch (Exception error) {
      LOGGER.error('Error: ' + error.getMessage());
      throw new AuraHandledException('Error: ' + error.getMessage());
    }
  }

  /**
   * @description  : Wrapper class for the output of the GetDocument method in the CIB_CTRL_DocumentContainer class.
   */
  public class GetDocumentOutputWrapper {
    /**
     * @description  : The key of the document.
     */
    @AuraEnabled
    public string key { get; set; }
    /**
     * @description  : The label of the document.
     */
    @AuraEnabled
    public string label { get; set; }
    /**
     * @description  : The type of the document.
     */
    @AuraEnabled
    public string type { get; set; }
    /**
     * @description  : The guidelines for the document.
     */
    @AuraEnabled
    public string guidelines { get; set; }
    /**
     * @description  : Indicates whether the document is required.
     */
    @AuraEnabled
    public Boolean isRequired { get; set; }
    /**
     * @description  : Indicates whether the document is hidden.
     */
    @AuraEnabled
    public Boolean isHidden { get; set; }
    /**
     * @description  : Indicates whether the document is a participant document.
     */
    @AuraEnabled
    public Boolean isParticipantDocument { get; set; }
  }
}