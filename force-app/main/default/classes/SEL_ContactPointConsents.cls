/***************************************************************************************
  @ Author            : silva.macaneta@standardbank.co.za
  @ Date              : 10-04-2023
  @ Name of the Class : SEL_ContactPointConsents
  @ Description       : Selector class for ContactPointConsent
  @ Last Modified By  : silva.macaneta@standardbank.co.za
  @ Last Modified On  : 10-04-2023
  @ Modification Description : SFP-23639, SFP-23580
***************************************************************************************/
public with sharing class SEL_ContactPointConsents extends fflib_SObjectSelector {
  /**
   * @description fields
   */
  private static Set<String> fields = new Set<String>{
    'Id',
    'Name',
    'ContactPointId',
    'PrivacyConsentStatus'
  };

  /**
   * @description getSObjectFieldList
   * @return List<Schema.SObjectField>
   */
  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{
      ContactPointConsent.Id,
      ContactPointConsent.Name,
      ContactPointConsent.ContactPointId,
      ContactPointConsent.PrivacyConsentStatus
    };
  }

  /**
   * @description Creates a new instance of the selector via the class selectById
   * @return Schema.SObjectType
   */
  public Schema.SObjectType getSObjectType() {
    return ContactPointConsent.sObjectType;
  }

  /**
   * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
   * and inject a mock instead of this class or to switch out this class for a new version.
   * @return SEL_ContactPointConsents
   */
  public static SEL_ContactPointConsents newInstance() {
    return (SEL_ContactPointConsents) ORG_Application.Selector.newInstance(
      ContactPointConsent.SObjectType
    );
  }

  /**
   * @description Select without conditions
   * @return List<ContactPointConsent>
   */
  public List<ContactPointConsent> selectWithoutCondition() {
    return (List<ContactPointConsent>) Database.query(
      newQueryFactory().toSOQL()
    );
  }

  /**
   * @description Select by Id
   * @param ids
   * @return List<ContactPointConsent>
   */
  public List<ContactPointConsent> selectById(Set<Id> ids) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('id IN :ids');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by Contact Point Id
   * @param ids
   * @return List<ContactPointConsent>
   */
  public List<ContactPointConsent> selectByContactPointId(Set<Id> ids) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('ContactPointId IN :ids');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }
}