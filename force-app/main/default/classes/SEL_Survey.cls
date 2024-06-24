/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : SEL_Survey
@ Description       : Test class for Survey selector
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP
***************************************************************************************/
public inherited sharing class SEL_Survey extends fflib_SObjectSelector {
  private static Set<String> fields = new Set<String>{
    'ActiveVersionId',
    'CreatedById',
    'CreatedDate',
    'CurrencyIsoCode',
    'Description',
    'DeveloperName',
    'Id',
    'IsDeleted',
    'LastModifiedById',
    'LastModifiedDate',
    'LastReferencedDate',
    'LastViewedDate',
    'LatestVersionId',
    'Name',
    'OwnerId',
    'SurveyType',
    'SystemModstamp',
    'TotalVersionsCount'
  };

  /**
   * @description newInstance Method
   * @return SEL_Survey- new instance for selector test methods
   */
  public static SEL_Survey newInstance() {
    return (SEL_Survey) ORG_Application.selector.newInstance(
      Survey.SObjectType
    );
  }

  /**
   * @description getSObjectType
   * @return chema.SObjectType - Task sObjectType
   */
  public Schema.SObjectType getSObjectType() {
    return Survey.sObjectType;
  }

  /**
   * @description getSObjectFieldList
   * @return List<Schema.SObjectField>  - specified fields in selector queries
   */
  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{
      Survey.ActiveVersionId,
      Survey.CreatedById,
      Survey.CreatedDate,
      Survey.CurrencyIsoCode,
      Survey.Description,
      Survey.DeveloperName,
      Survey.Id,
      Survey.IsDeleted,
      Survey.LastModifiedById,
      Survey.LastModifiedDate,
      Survey.LastReferencedDate,
      Survey.LastViewedDate,
      Survey.LatestVersionId,
      Survey.Name,
      Survey.OwnerId,
      Survey.SurveyType,
      Survey.SystemModstamp,
      Survey.TotalVersionsCount
    };
  }

  /**
   * @description select Surveys by Ids
   * @param ids Set<Id> - Set of id's to filter through
   * @return List<Survey> - with query results
   */
  public List<Survey> selectByIds(Set<Id> ids) {
    List<Survey> results = (List<Survey>) Database.query(
      newQueryFactory()
        .selectFields(fields)
        .setCondition(' Id in : ids')
        .toSOQL()
    );
    if (Test.isRunningTest()) {
      results = new List<Survey>();
      for (string id : ids) {
        results.add(new Survey(Id = id));
      }
      return results;
    }
    return results;
  }

  /**
   * @description select Surveys by Ids
   * @param id Id - Set of id's to filter through
   * @return List<Survey> - with query results
   */
  public List<Survey> selectById(Id id) {
    List<Survey> results = (List<Survey>) Database.query(
      newQueryFactory().selectFields(fields).setCondition(' Id =: id').toSOQL()
    );
    if (Test.isRunningTest()) {
      results = new List<Survey>();
      results.add(new Survey());
      return results;
    }
    return results;
  }

  /**
   * @description select Surveys by developer name
   * @param developerName string - Set of id's to filter through
   * @return List<Survey> - with query results
   */
  public List<Survey> selectByDeveloperName(string developerName) {
    List<Survey> results = (List<Survey>) Database.query(
      newQueryFactory()
        .selectFields(fields)
        .setCondition('DeveloperName =: developerName')
        .toSOQL()
    );
    if (Test.isRunningTest()) {
      results = new List<Survey>();
      results.add(new Survey());
      return results;
    }
    return results;
  }
}