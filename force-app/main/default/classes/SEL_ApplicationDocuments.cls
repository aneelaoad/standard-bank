/**
 * @description Application Document Selector Layer class.
 * @author Caro Reinecke (caro@khonology.com)
 * @date 2018-01-08
 */
/***************************************************************************************
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 2023-10-04
@ Modification Description : SFP
***************************************************************************************/
public with sharing class SEL_ApplicationDocuments extends fflib_SObjectSelector {
  private static Set<String> fields = new Set<String>{
    'Name',
    'Id',
    'Account_Application__c',
    'Document_Status__c',
    'Document_Type__c',
    'FileNet_Id__c',
    'Onboarding_Application__c',
    'Application__c',
    'Application_Participant__c',
    'Application_Section__c',
    'Document_Label__c',
    'CertifyingOfficial__c'
  };

  /**
   * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
   * and inject a mock instead of this class or to switch out this class for a new version.
   * @return SEL_ApplicationDocuments
   */
  public static SEL_ApplicationDocuments newInstance() {
    return (SEL_ApplicationDocuments) ORG_Application.selector.newInstance(
      Application_Document__c.SObjectType
    );
  }

  /**
   * @description get SObject Field List
   * @return  List<Schema.SObjectField>
   */
  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{
      Application_Document__c.Name,
      Application_Document__c.Id,
      Application_Document__c.Account_Application__c,
      Application_Document__c.Document_Status__c,
      Application_Document__c.Document_Type__c,
      Application_Document__c.FileNet_Id__c,
      Application_Document__c.Onboarding_Application__c,
      Application_Document__c.Application__c,
      Application_Document__c.Application_Participant__c,
      Application_Document__c.Application_Section__c,
      Application_Document__c.Document_Label__c
    };
  }
  /**
   * @description Gets SObject Type
   * @return Schema.SObjectType
   */
  public Schema.SObjectType getSObjectType() {
    return Application_Document__c.sObjectType;
  }
  /**
   * @description Get records by Id
   * @param  idSet Set of IDs
   * @return List<Application_Document__c>
   */
  public List<Application_Document__c> selectById(Set<ID> idSet) {
    return (List<Application_Document__c>) selectSObjectsById(idSet);
  }
  /**
   * @description Get records by AccountApplicationId
   * @param  idSet Set of IDs
   * @return List<Application_Document__c>
   */
  public List<Application_Document__c> selectByAccountApplicationId(
    Set<Id> idSet
  ) {
    return (List<Application_Document__c>) Database.query(
      newQueryFactory()
        .setCondition('Account_Application__c in :IdSet')
        .toSOQL()
    );
  }
  /**
   * @description Get records by OnboardApplicationId
   * @param  idSet Set of IDs
   * @return List<Application_Document__c>
   */
  public List<Application_Document__c> selectByOnboardApplicationId(
    Set<Id> idSet
  ) {
    return (List<Application_Document__c>) Database.query(
      newQueryFactory()
        .selectField('Authorised_Person__r.Id')
        .selectField('Authorised_Person__r.Name')
        .selectField('Authorised_Person__r.Email')
        .selectField('Authorised_Person__r.FirstName')
        .selectField('Authorised_Person__r.LastName')
        .selectField('Authorised_Person__r.Phone')
        .selectField('Authorised_Person__r.Contact_Role_s_at_Client__c')
        .setCondition('Onboarding_Application__c in :IdSet')
        .toSOQL()
    );
  }
  /**
   * @description Get records by OnboardApplicationId and Where Document_Status__c is pending
   * @param  onBoardid Set of IDs
   * @return List<Application_Document__c>
   */
  public List<Application_Document__c> selectByOnboardAppWherePending(
    Set<Id> onBoardid
  ) {
    return (List<Application_Document__c>) Database.query(
      newQueryFactory()
        .selectField('Authorised_Person__r.Id')
        .selectField('Authorised_Person__r.Name')
        .selectField('Authorised_Person__r.Email')
        .selectField('Authorised_Person__r.Contact_Role_s_at_Client__c')
        .setCondition('Onboarding_Application__c IN:onBoardid')
        .toSOQL()
    );
  }

  /**
   * @description documentId by Id
   *  @param documentId
   * @return List<Application_Document__c>
   */
  public List<Application_Document__c> selectSectionsBydocumentId(
    String documentId
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('id = :documentId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description document by appId
   *  @param appId
   * @return List<Application_Document__c>
   */
  public List<Application_Document__c> selectByApplicationId(String appId) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('Application__c = :appId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description document by appId
   *  @param appId
   * @return List<Application_Document__c>
   */
  public List<Application_Document__c> selectByApplicationIdWithSection(
    String appId
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('Application__c = :appId');
    fieldQueryFactory.selectFields(
      new List<String>{
        'Id',
        'Application__c',
        'Application_Section__c',
        'Application_Section__r.Title__c',
        'Application_Participant__c',
        'Application_Participant__r.Name',
        'Application_Participant__r.RecordType.Name',
        'Document_Status__c',
        'Document_Type__c',
        'Document_Label__c',
        'CertifyingOfficial__c'
      }
    );
    new SEL_ContentDocumentLink()
      .addQueryFactorySubselect(fieldQueryFactory, 'ContentDocumentLinks')
      .selectFields(
        new List<String>{
          'Id',
          'ContentDocumentId',
          'ContentDocument.Title',
          'ContentDocument.LatestPublishedVersion.FileExtension'
        }
      )
      .setOrdering('SystemModstamp', fflib_QueryFactory.SortOrder.DESCENDING)
      .setLimit(1);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Returns a list of Application_Document__c records that match the specified criteria.
   * @param applicationId The ID of the Application__c record to match.
   * @param applicationParticipantId The ID of the Application_Participant__c record to match.
   * @param sectionId The ID of the Application_Section__c record to match.
   * @param documentType The Document_Type__c value to match.
   * @return A list of Application_Document__c records that match the specified criteria.
   */
  public List<Application_Document__c> selectUploadedByApplicationPraticipantAndType(
    Id applicationId,
    Id applicationParticipantId,
    Id sectionId,
    String documentType
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.selectFields(
      new List<String>{
        'Id',
        'Application__c',
        'Application_Participant__c',
        'RecordTypeId',
        'FileNet_Id__c',
        'Document_Status__c',
        'Document_Type__c',
        'Application_Section__c'
      }
    );
    String condition = '(Application__c = :applicationId AND Application_Participant__c = null) ';
    if (applicationParticipantId != null) {
      condition = '(Application__c = :applicationId AND Application_Participant__c = :applicationParticipantId) ';
    }
    fieldQueryFactory.setCondition(
      condition +
        'AND Application_Section__c = :sectionId ' +
        'AND Document_Type__c = :documentType ' +
        'AND Document_Status__c = \'Uploaded\''
    );
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description document by appId
   *  @param recordId
   *  @param sectionId
   *  @param documentType
   * @return List<Application_Document__c>
   */
  public List<Application_Document__c> selectByApplicationAndSectionAndType(
    String recordId,
    String sectionId,
    String documentType
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition(
      '(Application__c = :recordId OR Application_Participant__c = :recordId) AND Application_Section__c = :sectionId AND Document_Type__c = :documentType AND Document_Status__c = \'Uploaded\''
    );
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }
}