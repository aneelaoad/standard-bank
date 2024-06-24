/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : SEL_CIBApplicationLineItem
@ Description       : To retrieve the Application Line Item records
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP-23639
***************************************************************************************/
public with sharing class SEL_CIBApplicationLineItem extends fflib_SObjectSelector {
  private static Set<String> fields = new Set<String>{
    'Id',
    'Name',
    'AmountEnd__c',
    'AmountStart__c',
    'Application__c',
    'CIB_Currency__c',
    'CIB_AccountIBAN__c',
    'CIB_AccountNumber__c',
    'CIB_AccountType__c',
    'CIB_EntityName__c',
    'CIB_HasTINNumber__c',
    'CIB_Industry__c',
    'CIB_TaxResidenceJuristiction__c',
    'CIB_TIN_Number__c',
    'CIB_TurnoverPercentage__c',
    'CurrencyStart__c',
    'CurrencyEnd__c',
    'RecordTypeId',
    'YearEnd__c', //NOTE: Change to text field
    'YearStart__c', //NOTE: Change to text field
    'CIB_Sequence__c'
  };

  /**
   * @description getSObjectFieldList
   * @return List<Schema.SObjectField>
   */
  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{
      Application_Line_Item__c.Id,
      Application_Line_Item__c.Name,
      Application_Line_Item__c.AmountEnd__c,
      Application_Line_Item__c.AmountStart__c,
      Application_Line_Item__c.Application__c,
      Application_Line_Item__c.CIB_EntityName__c,
      Application_Line_Item__c.CIB_HasTINNumber__c,
      Application_Line_Item__c.CIB_Industry__c,
      Application_Line_Item__c.CIB_TaxResidenceJuristiction__c,
      Application_Line_Item__c.CIB_TIN_Number__c,
      Application_Line_Item__c.CIB_TurnoverPercentage__c,
      Application_Line_Item__c.CurrencyStart__c,
      Application_Line_Item__c.CurrencyEnd__c,
      Application_Line_Item__c.RecordTypeId,
      Application_Line_Item__c.YearEnd__c, //NOTE: Change to text field
      Application_Line_Item__c.YearStart__c, //NOTE: Change to text field
      Application_Line_Item__c.CIB_Sequence__c,
      Application_Line_Item__c.CIB_AccountIBAN__c,
      Application_Line_Item__c.CIB_AccountNumber__c,
      Application_Line_Item__c.CIB_AccountType__c,
      Application_Line_Item__c.CIB_Currency__c
    };
  }

  /**
   * @description Creates a new instance of the selector via the class selectById
   * @return Schema.SObjectType
   */
  public Schema.SObjectType getSObjectType() {
    return Application_Line_Item__c.sObjectType;
  }

  /**
   * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
   * and inject a mock instead of this class or to switch out this class for a new version.
   * @return SEL_Accounts
   */
  public static SEL_CIBApplicationSection newInstance() {
    return (SEL_CIBApplicationSection) ORG_Application.selector.newInstance(
      Application_Line_Item__c.SObjectType
    );
  }
  /**
   * @description Select without conditions
   *
   * @return List<Account>
   */
  public List<Application_Line_Item__c> selectWithoutCondition() {
    return (List<Application_Line_Item__c>) Database.query(
      newQueryFactory().toSOQL()
    );
  }

  /**
   * @description Select by Id
   *  @param detailId
   * @return List<Application_Line_Item__c>
   */
  public List<Application_Line_Item__c> selectApplicationLineItemById(
    String detailId
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('id = :detailId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by Id
   *  @param detailId
   * @return Application_Line_Item__c
   */
  public Application_Line_Item__c selectApplicationLineItemId(String detailId) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('id = :detailId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by Id Set
   *  @param ids
   * @return List<Application_Line_Item__c>
   */
  public List<Application_Line_Item__c> selectApplicationLineItemBySetIds(
    set<id> ids
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('id IN :ids');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by Application Id
   * @param appId
   * @return List<Application_Line_Item__c>
   */
  public List<Application_Line_Item__c> selectLineItemByApplicationId(
    String appId
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('Application__c = :appId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(FieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by Application Id
   * @param appId
   * @param recordTypeId
   * @return List<Application_Line_Item__c>
   */
  public List<Application_Line_Item__c> selectLineItemsByApplicationIdRecordType(
    String appId,
    String recordTypeId
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition(
      'Application__c = :appId AND RecordTypeId=:recordTypeId'
    );
    fieldQueryFactory.selectFields(fields);
    return Database.query(FieldQueryFactory.toSOQL());
  }
}