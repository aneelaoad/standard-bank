/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : SEL_CIBApplicationSection
@ Description       : Selector class for Application Section custom object.
                      Provides methods to query Application Section records based on various criteria.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP-24725
***************************************************************************************/
public with sharing class SEL_CIBApplicationSection extends fflib_SObjectSelector {
  /**
   * @description This private static Set contains the API names of fields that are used in the SEL_CIBApplicationSection class.
   * These fields are: Id, Name, Application__c, Comment__c, CompletionPercentage__c, Order__c, Screen_Type__c, ScreenApiName__c, Status__c, and Title__c.
   */
  private static Set<String> fields = new Set<String>{
    'Id',
    'Name',
    'Application__c',
    'Comment__c',
    'CompletionPercentage__c',
    'Order__c',
    'Screen_Type__c',
    'ScreenApiName__c',
    'Status__c',
    'Title__c',
    'LastModifiedDate',
    'CreatedDate'
  };

  /**
   * @description Returns a list of all fields for the Application_Section__c object
   * @return List<Schema.SObjectField>
   */
  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{
      Application_Section__c.Id,
      Application_Section__c.Name,
      Application_Section__c.Application__c,
      Application_Section__c.Comment__c,
      Application_Section__c.CompletionPercentage__c,
      Application_Section__c.Order__c,
      Application_Section__c.Screen_Type__c,
      Application_Section__c.ScreenApiName__c,
      Application_Section__c.Status__c,
      Application_Section__c.Title__c,
      Application_Section__c.LastModifiedDate,
      Application_Section__c.CreatedDate
    };
  }

  /**
   * @description Creates a new instance of the selector via the class selectById
   * @return Schema.SObjectType
   */
  public Schema.SObjectType getSObjectType() {
    return Application_Section__c.sObjectType;
  }

  /**
   * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
   * and inject a mock instead of this class or to switch out this class for a new version.
   * @return SEL_CIBApplicationSection
   */
  public static SEL_CIBApplicationSection newInstance() {
    return (SEL_CIBApplicationSection) ORG_Application.selector.newInstance(
      Application_Section__c.SObjectType
    );
  }

  /**
   * @description Select without conditions
   * @return List<Application_Section__c>
   */
  public List<Application_Section__c> selectWithoutCondition() {
    return (List<Application_Section__c>) Database.query(
      newQueryFactory().toSOQL()
    );
  }

  /**
   * @description Select by Id
   * @param sectionId The Id of the Application_Section__c record to select
   * @return List<Application_Section__c>
   */
  public List<Application_Section__c> selectSectionsById(String sectionId) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('id = :sectionId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by Application Id
   * @param appId The Id of the Application__c record to select Application_Section__c records for
   * @return List<Application_Section__c>
   */
  public List<Application_Section__c> selectSectionsByApplicationId(
    String appId
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('Application__c = :appId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by Application Id and Screen API Name
   * @param appId The Id of the Application__c record to select Application_Section__c records for
   * @param screenAPIName The API Name of the Screen__c record to select Application_Section__c records for
   * @return List<Application_Section__c>
   */
  public List<Application_Section__c> selectSectionsByApplicationscreenAPIName(
    String appId,
    String screenAPIName
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition(
      'Application__c = :appId AND ScreenApiName__c=:screenAPIName'
    );
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by Application Id and Status
   * @param appId The Id of the Application__c record to select Application_Section__c records for
   * @param status The Status__c value to select Application_Section__c records for
   * @return List<Application_Section__c>
   */
  public List<Application_Section__c> selectByApplicationAndStatus(
    String appId,
    String status
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition(
      'Application__c = :appId AND Status__c=:status'
    );
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select Application_Section__c records for an Application__c record that are in progress
   * @param appId The Id of the Application__c record to select Application_Section__c records for
   * @return List<Application_Section__c>
   */
  public List<Application_Section__c> selectByApplicationInProgress(
    String appId
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition(
      'Status__c != \'Submitted\' AND Status__c != \'Completed\' AND (Screen_Type__c = \'Application Section\' OR Screen_Type__c = \'Pre-Application\') AND Application__c = :appId'
    );
    fieldQueryFactory.addOrdering(
      'Order__c',
      fflib_QueryFactory.SortOrder.ASCENDING
    );
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select Application_Section__c records for an Application__c record that are completed
   * @param appId The Id of the Application__c record to select Application_Section__c records for
   * @return List<Application_Section__c>
   */
  public List<Application_Section__c> selectByApplicationCompleted(
    String appId
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition(
      '(Status__c = \'Submitted\' OR Status__c = \'Completed\') AND (Screen_Type__c = \'Application Section\' OR Screen_Type__c = \'Pre-Application\') AND Application__c = :appId'
    );
    fieldQueryFactory.addOrdering(
      'Order__c',
      fflib_QueryFactory.SortOrder.ASCENDING
    );
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select Application_Section__c records for a record Id that are not the Welcome screen or the Home or Final Section screens
   * @param recordId The Id of the record to select Application_Section__c records for
   * @return List<Application_Section__c>
   */
  public List<Application_Section__c> selectHubScreenSections(String recordId) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.selectFields(fields);
    fieldQueryFactory.setCondition(
      'Application__c = :recordId AND (NOT Title__c LIKE \'Welcome%\') AND (NOT Screen_Type__c IN(\'Home\', \'Final Section\'))'
    );
    fieldQueryFactory.addOrdering(
      'Order__c',
      fflib_QueryFactory.SortOrder.ASCENDING
    );
    return Database.query(fieldQueryFactory.toSOQL());
  }
}