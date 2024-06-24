/***************************************************************************************
  @ Author            : silva.macaneta@standardbank.co.za
  @ Date              : 10-04-2023
  @ Name of the Class : SEL_ContactPointEmails
  @ Description       : Selector class for ContactPointEmail
  @ Last Modified By  : silva.macaneta@standardbank.co.za
  @ Last Modified On  : 10-04-2023
  @ Modification Description : SFP-23639, SFP-23580
***************************************************************************************/
public with sharing class SEL_ContactPointEmails extends fflib_SObjectSelector {
  /**
   * @description fields
   */
  private static Set<String> fields = new Set<String>{
    'Id',
    'Name',
    'ParentId',
    'EmailAddress'
  };

  /**
   * @description getSObjectFieldList
   * @return List<Schema.SObjectField>
   */
  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{
      ContactPointEmail.Id,
      ContactPointEmail.Name,
      ContactPointEmail.ParentId,
      ContactPointEmail.EmailAddress
    };
  }

  /**
   * @description Creates a new instance of the selector via the class selectById
   * @return Schema.SObjectType
   */
  public Schema.SObjectType getSObjectType() {
    return ContactPointEmail.sObjectType;
  }

  /**
   * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
   * and inject a mock instead of this class or to switch out this class for a new version.
   * @return SEL_ContactPointEmails
   */
  public static SEL_ContactPointEmails newInstance() {
    return (SEL_ContactPointEmails) ORG_Application.selector.newInstance(
      ContactPointEmail.SObjectType
    );
  }
  /**
   * @description Select without conditions
   * @return List<ContactPointEmail>
   */
  public List<ContactPointEmail> selectWithoutCondition() {
    return (List<ContactPointEmail>) Database.query(newQueryFactory().toSOQL());
  }

  /**
   * @description Select by Id
   *  @param ids
   * @return List<ContactPointEmail>
   */
  public List<ContactPointEmail> selectById(Set<Id> ids) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('id IN :ids');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by Parent Id
   *  @param ids
   * @return List<ContactPointEmail>
   */
  public List<ContactPointEmail> selectByParentId(Set<Id> ids) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('ParentId IN :ids');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }
}