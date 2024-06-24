/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_CTRL_ApplicationParticipant
@ Description       : Controller class for managing Application Participants in the CIB application. Provides methods for retrieving, deleting, and saving Application Participants.                      
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP-23639
***************************************************************************************/
public with sharing class CIB_CTRL_ApplicationParticipant {
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CIB_CTRL_ApplicationParticipant');
  
  /**
   * @description          : Retrieves a list of Application Participants for a given Application Id and Record Type Name.
   * @param applicationId  : The Id of the Application for which to retrieve Participants.
   * @param recordTypeName : The Developer Name of the Record Type for which to retrieve Participants.
   * @return List<Application_Participant__c> : A list of Application Participants.
   **/
  @AuraEnabled
  public static List<Application_Participant__c> getApplicationParticipants(
    Id applicationId,
    String recordTypeName
  ) {
    List<Application_Participant__c> participants = new List<Application_Participant__c>();

    if (recordTypeName == null) {
      return new SEL_CIBApplicationParticipant()
      .selectAppsByApplicationIdString(applicationId);
    }

    Id recordTypeId = Schema.SObjectType.Application_Participant__c
      .getRecordTypeInfosByDeveloperName()
      .get(recordTypeName)
      .getRecordTypeId();

      participants= new SEL_CIBApplicationParticipant()
      .selectAppsByApplicationIdsRecordId(applicationId, recordTypeId);

    return participants;
  }

  /**
   * @description       : Deletes an Application Participant.
   * @param participant : The Application Participant to delete.
   **/
  @AuraEnabled
  public static void deleteApplicationParticipant(
    Application_Participant__c participant
  ) {
    CIB_SEL_Fflib_FrameWork.deletefflibFrameWorkList(
      new List<SObjectType>{ Application_Participant__c.SObjectType },
      new List<Application_Participant__c> { participant }
    );
  }

  /**
   * @description          : Saves a list of Application Participants for a given Record Type Name.
   * @param recordTypeName : The Developer Name of the Record Type for which to save Participants.
   * @param participants   : The list of Application Participants to save.
   * @return List<Application_Participant__c> : The list of saved Application Participants.
   **/
  @AuraEnabled
  public static List<Application_Participant__c> saveApplicationParticipants(
    String recordTypeName,
    List<Application_Participant__c> participants
  ) {
    Id recordTypeId = null;
    
    if (recordTypeName != null) {
      recordTypeId = Schema.SObjectType.Application_Participant__c
      .getRecordTypeInfosByDeveloperName()
      .get(recordTypeName)
      .getRecordTypeId();
    }

    List<Application_Participant__c> insertList = new List<Application_Participant__c>();
    List<Application_Participant__c> updateList = new List<Application_Participant__c>();

    for (Application_Participant__c participant : participants) {
      if(recordTypeId != null) {
        participant.RecordTypeId = recordTypeId;        
      }
      if (participant.Id == null) {
        insertList.add(participant);
      } else {
        updateList.add(participant);
      }
    }

    if (updateList.size() > 0) {
      CIB_SEL_Fflib_FrameWork.updatefflibFrameWorkList(
        new List<SObjectType>{ Application_Participant__c.SObjectType },
        updateList
      );
    }
    if (insertList.size() > 0) {
      CIB_SEL_Fflib_FrameWork.insertfflibFrameWorkList(
        new List<SObjectType>{ Application_Participant__c.SObjectType },
        insertList
      );
    }
    return participants;
  }
}