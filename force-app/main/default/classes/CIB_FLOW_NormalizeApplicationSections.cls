/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_FLOW_NormalizeApplicationSections
@ Description       : This class provides functionality to normalize the application sections for the given application.
                      It retrieves the application section settings from the Application_Section_Setting__mdt metadata type and
                      compares them with the existing application sections for the given application. If a section does not exist,
                      it creates a new section with the settings from the metadata type.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP
***************************************************************************************/
public without sharing class CIB_FLOW_NormalizeApplicationSections {
  /**
   * @description       : Invocable method that normalizes the application sections for the given application.
   * @param applicationIds : List of application Ids to process.
   * @return
   **/
  @InvocableMethod(
    Label='Normalize Application Sections'
    Description='Will normalize the application sections for the given application.'
  )
  public static void processApplicationSections(List<Id> applicationIds) {
    List<Application_Section_Setting__mdt> applicationSectionSetting = [
      SELECT
        Id,
        DeveloperName,
        Screen_Api_Name__c,
        Order__c,
        Screen_Type__c,
        Label
      FROM Application_Section_Setting__mdt
      WHERE DeveloperName LIKE 'cib_%'
      WITH SECURITY_ENFORCED
    ];

    Map<String, Application_Section_Setting__mdt> settingMap = new Map<String, Application_Section_Setting__mdt>();
    for (Application_Section_Setting__mdt setting : applicationSectionSetting) {
      settingMap.put(
        setting.Screen_Api_Name__c + setting.Screen_Type__c,
        setting
      );
    }

    List<Application__c> applications = [
      SELECT
        Id,
        Name,
        (
          SELECT Id, Name, Order__c, ScreenApiName__c, Screen_Type__c
          FROM Application_Sections__r
        )
      FROM Application__c
      WHERE Id IN :applicationIds
      WITH SECURITY_ENFORCED
    ];

    List<Application_Section__c> sectionsToInsert = new List<Application_Section__c>();

    for (Application__c app : applications) {
      Map<String, Application_Section__c> sectionMap = new Map<String, Application_Section__c>();
      for (Application_Section__c section : app.Application_Sections__r) {
        sectionMap.put(
          section.ScreenApiName__c + section.Screen_Type__c,
          section
        );
      }
      for (Application_Section_Setting__mdt setting : settingMap.values()) {
        if (
          !sectionMap.containsKey(
            setting.Screen_Api_Name__c + setting.Screen_Type__c
          )
        ) {
          Application_Section__c newSection = new Application_Section__c();
          newSection.Application__c = app.Id;
          newSection.Title__c = setting.Label;
          newSection.ScreenApiName__c = setting.Screen_Api_Name__c;
          newSection.Screen_Type__c = setting.Screen_Type__c;
          newSection.Order__c = setting.Order__c;
          sectionsToInsert.add(newSection);
        }
      }
    }

    CIB_SEL_Fflib_FrameWork.insertfflibFrameWorkList(
      new List<Schema.SObjectType>{ Application_Section__c.SObjectType },
      sectionsToInsert
    );
  }
}