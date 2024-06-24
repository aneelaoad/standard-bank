/***************************************************************************************
@ Author            : Ridhima Saxena
@ Date              : 10-03-2023
@ Name of the Class : CIB_CTRL_HubScreen
@ Description       : This class contains methods to retrieve and update Application_Section__c records for the CIB Hub Screen 
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP-24729
***************************************************************************************/
public with sharing class CIB_CTRL_HubScreen {
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
    .createLogger('CIB_CTRL_HubScreen');
  /**
   * @description : This method is used for retrieving the records with status = 'Revision Requested' and for Notification section
   * @param applicationId : used to store id of the record of Application__c object
   * @return List<Application_Section__c> : list of Application_Section__c records with status = 'Revision Requested' and non-blank Comment__c field
   */
  @AuraEnabled(cacheable=true)
  public static List<Application_Section__c> getNotifiedOnRevisionRequested(
    ID applicationId
  ) {
    List<Application_Section__c> getNotificationRecords = new List<Application_Section__c>();
    getNotificationRecords = new SEL_CIBApplicationSection()
      .selectByApplicationAndStatus(
        applicationId,
        CIB_Constants.APPLICATION_SECTION_STATUS_REVISION_REQUESTED
      );

    List<Application_Section__c> filteredRecords = new List<Application_Section__c>();
    for (Application_Section__c record : getNotificationRecords) {
      if (!String.isBlank(record.Comment__c)) {
        filteredRecords.add(record);
      }
    }
    return filteredRecords;
  }

  /**
   * @description : This method is used for retrieving the records with status != 'Completed' & 'Submitted' and for TO DO section
   * @param applicationId : used to store id of the record of Application__c object
   * @return List<Application_Section__c> : list of Application_Section__c records with status != 'Completed' & 'Submitted' and Screen_Type__c = 'Application Section' or 'Pre-Application'
   */
  @AuraEnabled(cacheable=true)
  public static List<Application_Section__c> getInProgressSection(
    ID applicationId
  ) {
    List<Application_Section__c> getToDoRecords = new List<Application_Section__c>();
    getToDoRecords = new SEL_CIBApplicationSection()
      .selectByApplicationInProgress(applicationId);
    return getToDoRecords;
  }

  /**
   * @description : This method is used for retrieving the records with status = 'Completed' & 'Submitted' and for completed section
   * @param applicationId : used to store id of the record of Application__c object
   * @return List<Application_Section__c> : list of Application_Section__c records with status = 'Completed' & 'Submitted' and Screen_Type__c = 'Application Section' or 'Pre-Application'
   */
  @AuraEnabled(cacheable=true)
  public static List<Application_Section__c> getCompletedSection(
    ID applicationId
  ) {
    List<Application_Section__c> getCompletedRecords = new List<Application_Section__c>();
    getCompletedRecords = new SEL_CIBApplicationSection()
      .selectByApplicationCompleted(applicationId);
    return getCompletedRecords;
  }

  /**
   * @description : This method is used for updating the status of Application_Section__c records with screenApiName = 'cib_comp_hubScreen' to 'Submitted'
   * @param applicationId : applicationId, used to store id of the record of Application__c object
   * @return String : applicationId
   */
  @AuraEnabled
  public static String updateHubScreen(String applicationId) {
    List<Application_Section__c> appSectionList = new SEL_CIBApplicationSection()
      .selectSectionsByApplicationscreenAPIName(
        applicationId,
        CIB_Constants.CIB_COMP_HUB_SCREEN
      );

    List<Application_Section__c> appSectionUpdateList = new List<Application_Section__c>();

    if (appSectionList.size() > 0) {
      for (Application_Section__c appsec : appSectionList) {
        appsec.Status__c = CIB_Constants.APPLICATION_SECTION_STATUS_SUBMITTED;
        appSectionUpdateList.add(appsec);
      }
    }

    if (appSectionUpdateList.size() > 0) {
      CIB_SEL_Fflib_FrameWork.updatefflibFrameWorkList(
        new List<SObjectType>{ Application_Section__c.SObjectType },
        appSectionUpdateList
      );
    }
    return applicationId;
  }

  /**
   * @description : This method is used for updating the status of Application_Section__c records with screenApiName = 'cib_comp_thankYou' to 'Submitted'
   * @param applicationId : applicationId, used to store id of the record of Application__c object
   * @return String : applicationId
   */
  @AuraEnabled
  public static String updateThankScreen(String applicationId) {
    List<Application_Section__c> appSectionList = new SEL_CIBApplicationSection()
      .selectSectionsByApplicationscreenAPIName(
        applicationId,
        CIB_Constants.CIB_COMP_THANK_YOU
      );

    List<Application_Section__c> appSectionUpdateList = new List<Application_Section__c>();

    if (appSectionList.size() > 0) {
      for (Application_Section__c appsec : appSectionList) {
        appsec.Status__c = CIB_Constants.APPLICATION_SECTION_STATUS_SUBMITTED;
        appSectionUpdateList.add(appsec);
      }
    }
    if (appSectionUpdateList.size() > 0) {
      CIB_SEL_Fflib_FrameWork.updatefflibFrameWorkList(
        new List<SObjectType>{ Application_Section__c.SObjectType },
        appSectionUpdateList
      );
    }
    return applicationId;
  }
}