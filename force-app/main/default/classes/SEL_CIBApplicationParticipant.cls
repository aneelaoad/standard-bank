/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : SEL_CIBApplicationParticipant
@ Description       : Application Participant Selector class
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP-23639
***************************************************************************************/
public with sharing class SEL_CIBApplicationParticipant extends fflib_SObjectSelector {
  private static Set<String> fields = new Set<String>{
    'Id',
    'Name',
    'Application__c',
    'Contact__c',
    'Email__c',
    'OwnerId',
    'PassportIdNumber__c',
    'RecordTypeId',
    'SystemModstamp',
    'TelephoneNumber__c',
    'Title__c',
    'CIB_AccessRights__c',
    'CIB_AD_AccountNumber__c',
    'CIB_AD_CustomerName__c',
    'CIB_AD_CustomerSignatureAuthority__c',
    'CIB_AD_CustomerSignatureDate__c',
    'CIB_AD_CustomerSignatureName__c',
    'CIB_AD_CustomPassword__c',
    'CIB_AD_IsNewSubscription__c',
    'CIB_CDeclaration_Date__c',
    'CIB_CDeclaration_Designation__c',
    'CIB_CDeclaration_FullName__c',
    'CIB_CorporateDirector__c',
    'CIB_CountryOfIncorporation__c',
    'CIB_DateSigned__c',
    'CIB_EffectivePercentageOwnership__c',
    'CIB_Exchange__c',
    'CIB_IncorporationDate__c',
    'CIB_IncorportationNumber__c',
    'CIB_Limit__c',
    'CIB_MobileNumber__c',
    'CIB_PermanentResidentialAddress__c',
    'CIB_PhysicalTradingAddress__c',
    'CIB_RegisteredOfficeAddress__c',
    'CIB_Regulator__c',
    'CIB_VotingRights__c',
    'CIB_EII_DulySignedAsBoard__c',
    'CIB_Sequence__c',
    'CIB_CD_ContactSalutation__c',
    'IsCertifyingOfficial__c',
    'RecordType.Name'    
  };

  /**
   * @description getSObjectFieldList
   * @return List<Schema.SObjectField>
   */
  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{
      Application_Participant__c.Id,
      Application_Participant__c.Name,
      Application_Participant__c.Application__c,
      Application_Participant__c.Contact__c,
      Application_Participant__c.Email__c,
      Application_Participant__c.OwnerId,
      Application_Participant__c.PassportIdNumber__c,
      Application_Participant__c.RecordTypeId,
      Application_Participant__c.SystemModstamp,
      Application_Participant__c.TelephoneNumber__c,
      Application_Participant__c.Title__c,
      Application_Participant__c.CIB_AccessRights__c,
      Application_Participant__c.CIB_AD_AccountNumber__c,
      Application_Participant__c.CIB_AD_CustomerName__c,
      Application_Participant__c.CIB_AD_CustomerSignatureAuthority__c,
      Application_Participant__c.CIB_AD_CustomerSignatureDate__c,
      Application_Participant__c.CIB_AD_CustomerSignatureName__c,
      Application_Participant__c.CIB_AD_CustomPassword__c,
      Application_Participant__c.CIB_AD_IsNewSubscription__c,
      Application_Participant__c.CIB_CDeclaration_Date__c,
      Application_Participant__c.CIB_CDeclaration_Designation__c,
      Application_Participant__c.CIB_CDeclaration_FullName__c,
      Application_Participant__c.CIB_CorporateDirector__c,
      Application_Participant__c.CIB_CountryOfIncorporation__c,
      Application_Participant__c.CIB_DateSigned__c,
      Application_Participant__c.CIB_EffectivePercentageOwnership__c,
      Application_Participant__c.CIB_Exchange__c,
      Application_Participant__c.CIB_IncorporationDate__c,
      Application_Participant__c.CIB_IncorportationNumber__c,
      Application_Participant__c.CIB_Limit__c,
      Application_Participant__c.CIB_MobileNumber__c,
      Application_Participant__c.CIB_PermanentResidentialAddress__c,
      Application_Participant__c.CIB_PhysicalTradingAddress__c,
      Application_Participant__c.CIB_RegisteredOfficeAddress__c,
      Application_Participant__c.CIB_Regulator__c,
      Application_Participant__c.CIB_VotingRights__c,
      Application_Participant__c.CIB_EII_DulySignedAsBoard__c,
      Application_Participant__c.CIB_Sequence__c,
      Application_Participant__c.CIB_CD_ContactSalutation__c,
      Application_Participant__c.IsCertifyingOfficial__c
    };
  }

  /**
   * @description Creates a new instance of the selector via the class selectById
   * @return Schema.SObjectType
   */
  public Schema.SObjectType getSObjectType() {
    return Application_Participant__c.sObjectType;
  }

  /**
   * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
    /**
     * @description Create a new instance of SEL_CIBApplicationParticipant
     * and inject a mock instead of this class or to switch out this class for a new version.
     * @return SEL_Accounts
     */
  public static SEL_CIBApplicationParticipant newInstance() {
    return (SEL_CIBApplicationParticipant) ORG_Application.selector.newInstance(
      Application_Participant__c.SObjectType
    );
  }

  /**
   * @description Select without conditions
   *
   * @return List<Account>
   */
  public List<Application_Participant__c> selectWithoutCondition() {
    return (List<Application_Participant__c>) Database.query(
      newQueryFactory().toSOQL()
    );
  }

  /**
   * @description Select by section
   * @param appId The application ID
   * @return List<Application_Participant__c>
   */
  public List<Application_Participant__c> selectAppsById(String appId) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('id = :appId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by application Id
   * @param appId The application ID
   * @return List<Application_Participant__c>
   */
  public List<Application_Participant__c> selectAppsByApplicationId(Id appId) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('Application__c = :appId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by application Id
   * @param appId The application ID
   * @return List<Application_Participant__c>
   */
  public List<Application_Participant__c> selectAppsByApplicationIds(Id appId) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('Application__c = :appId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by application Id and record type ID
   * @param appId The application ID
   * @param recordTypeId The record type ID
   * @return List<Application_Participant__c>
   */
  public List<Application_Participant__c> selectAppsByApplicationIdsRecordId(
    String appId,
    String recordTypeId
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition(
      'Application__c = :appId AND RecordTypeId=:recordTypeId'
    );
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by section
   * @param appId The application ID
   * @return Application_Participant__c
   */
  public List<Application_Participant__c> selectAppById(String appId) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('id = :appId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by application Id and record type ID
   * @param appId The application ID
   * @param recordTypeId The record type ID
   * @return List<Application_Participant__c>
   */
  public List<Application_Participant__c> selectAppsByApplicationIdRecordId(
    String appId,
    String recordTypeId
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition(
      'Application__c = :appId AND RecordTypeId=:recordTypeId'
    );
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by application Id
   * @param appId The application ID
   * @return Application_Participant__c
   */
  public List<Application_Participant__c> selectAppByApplicationId(Id appId) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('Application__c = :appId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by application Id and record type ID
   * @param appId The application ID
   * @param recordTypeId The record type ID
   * @return List<Application_Participant__c>
   */
  public List<Application_Participant__c> selectAppsByApplicationIdRecordIdmultiple(
    String appId,
    List<String> recordTypeId
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition(
      'Application__c = :appId AND RecordTypeId IN:recordTypeId'
    );
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by application Id
   * @param appId The application ID
   * @return List<Application_Participant__c>
   */
  public List<Application_Participant__c> selectAppsByApplicationIdString(
    String appId
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('Application__c = :appId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by application Id and record type ID
   * @param appId The application ID
   * @param recordTypeId The record type ID
   * @return List<Application_Participant__c>
   */
  public List<Application_Participant__c> selectAppsByApplicationIdRecordIdList(
    String appId,
    String recordTypeId
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition(
      'Application__c = :appId AND RecordTypeId=:recordTypeId'
    );
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }
}