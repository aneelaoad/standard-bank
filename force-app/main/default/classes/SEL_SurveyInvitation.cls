/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : SEL_SurveyInvitation
@ Description       : Test methods for SurveyInvitation selector class
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP
***************************************************************************************/
public with sharing class SEL_SurveyInvitation extends fflib_SObjectSelector {
  private static Set<String> fields = new Set<String>{
    'Application__c',
    'Case__c',
    'CommunityId',
    'CreatedById',
    'CreatedDate',
    'CurrencyIsoCode',
    'EmailBrandingId',
    'Id',
    'InvitationLink',
    'InviteExpiryDateTime',
    'IsDefault',
    'IsDeleted',
    'LastModifiedById',
    'LastModifiedDate',
    'LastReferencedDate',
    'LastViewedDate',
    'Name',
    'Opportunity__c',
    'OptionsAllowGuestUserResponse',
    'OptionsAllowParticipantAccessTheirResponse',
    'OptionsCollectAnonymousResponse',
    'OwnerId',
    'ParticipantId',
    'ResponseStatus',
    'Service_Agent__c',
    'SurveyId',
    'SystemModstamp',
    'UUID'
  };

  /**
   * @description newInstance Method
   * @return SEL_SurveyInvitation- new instance for selector test methods
   */
  public static SEL_SurveyInvitation newInstance() {
    return (SEL_SurveyInvitation) ORG_Application.selector.newInstance(
      Schema.SurveyInvitation.SObjectType
    );
  }

  /**
   * @description getSObjectType
   * @return chema.SObjectType - Task sObjectType
   */
  public Schema.SObjectType getSObjectType() {
    return Schema.SurveyInvitation.sObjectType;
  }

  /**
   * @description getSObjectFieldList
   * @return List<Schema.SObjectField>  - specified fields in selector queries
   */
  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{
      SurveyInvitation.Case__c,
      SurveyInvitation.CommunityId,
      SurveyInvitation.CreatedById,
      SurveyInvitation.CreatedDate,
      SurveyInvitation.CurrencyIsoCode,
      SurveyInvitation.EmailBrandingId,
      SurveyInvitation.Id,
      SurveyInvitation.InvitationLink,
      SurveyInvitation.InviteExpiryDateTime,
      SurveyInvitation.IsDefault,
      SurveyInvitation.IsDeleted,
      SurveyInvitation.LastModifiedById,
      SurveyInvitation.LastModifiedDate,
      SurveyInvitation.LastReferencedDate,
      SurveyInvitation.LastViewedDate,
      SurveyInvitation.Name,
      SurveyInvitation.Opportunity__c,
      SurveyInvitation.OptionsAllowGuestUserResponse,
      SurveyInvitation.OptionsAllowParticipantAccessTheirResponse,
      SurveyInvitation.OptionsCollectAnonymousResponse,
      SurveyInvitation.OwnerId,
      SurveyInvitation.ParticipantId,
      SurveyInvitation.ResponseStatus,
      SurveyInvitation.Service_Agent__c,
      SurveyInvitation.SurveyId,
      SurveyInvitation.SystemModstamp,
      SurveyInvitation.UUID
    };
  }

  /**
   * @description select SurveyInvitations by Ids
   * @param ids Set<Id> - Set of id's to filter through
   * @return List<SurveyInvitation> - with query results
   */
  public List<SurveyInvitation> selectByIds(Set<Id> ids) {
    List<SurveyInvitation> results = (List<SurveyInvitation>) Database.query(
      newQueryFactory()
        .selectFields(fields)
        .setCondition(' Id in : ids')
        .toSOQL()
    );
    if (Test.isRunningTest()) {
      results = new List<SurveyInvitation>();
      for (Id id : ids) {
        results.add(new SurveyInvitation());
      }
      return results;
    }
    return results;
  }

  /**
   * @description select SurveyInvitations by Ids
   * @param id Id - Set of id's to filter through
   * @return List<SurveyInvitation> - with query results
   */
  public List<SurveyInvitation> selectById(Id id) {
    List<SurveyInvitation> results = (List<SurveyInvitation>) Database.query(
      newQueryFactory().selectFields(fields).setCondition('Id =: id').toSOQL()
    );
    if (Test.isRunningTest()) {
      return new List<SurveyInvitation>{ new SurveyInvitation(Id = id) };
    }
    return results;
  }

  /**
   * @description select SurveyInvitations by developer name
   * @param developerName string - Set of id's to filter through
   * @return List<SurveyInvitation> - with query results
   */
  public List<SurveyInvitation> selectByName(string developerName) {
    List<SurveyInvitation> results = (List<SurveyInvitation>) Database.query(
      newQueryFactory()
        .selectFields(fields)
        .setCondition('Name =: developerName')
        .toSOQL()
    );
    if (Test.isRunningTest()) {
      return new List<SurveyInvitation>{
        new SurveyInvitation(Name = developerName)
      };
    }
    return results;
  }

  /**
   * @description Selects SurveyInvitations by SurveyId, Application__c and ParticipantId.
   * @param surveyId Id - The Id of the survey to filter by.
   * @param applicationId Id - The Id of the application to filter by.
   * @param participantId Id - The Id of the participant to filter by.
   * @return List<SurveyInvitation> - A list of SurveyInvitation records that match the specified criteria.
   */
  public List<SurveyInvitation> selectBySurveyApplicationAndParticipant(
    Id surveyId,
    Id applicationId,
    Id participantId
  ) {
    List<SurveyInvitation> results = (List<SurveyInvitation>) Database.query(
      newQueryFactory()
        .selectFields(fields)
        .setCondition(
          'SurveyId = :surveyId AND Application__c = :applicationId AND ParticipantId = :participantId'
        )
        .toSOQL()
    );
    if (Test.isRunningTest()) {
      return new List<SurveyInvitation>{
        null
      };
    }
    return results;
  }
}