/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_CTRL_ApplicationLineItem
@ Description       : This class provides methods to retrieve, delete, and save Application Line Items.
                      It uses the SEL_CIBApplicationLineItem class to retrieve line items by application ID and record type,
                      and the CIB_SEL_Fflib_FrameWork class to delete and save line items.
@ Last Modified By  : 10-03-2023
@ Last Modified On  : silva.macaneta@standardbank.co.za
@ Modification Description : SFP-23639
***************************************************************************************/
public with sharing class CIB_CTRL_ApplicationLineItem {
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
    .createLogger('CIB_CTRL_ApplicationLineItem');

  /**
   * @description Retrieves a list of Application Line Items based on the provided Application Id and Record Type Name.
   * @param applicationId The Id of the Application.
   * @param recordTypeName The Developer Name of the Record Type.
   * @return A list of Application Line Items.
   */
  @AuraEnabled
  public static List<Application_Line_Item__c> getApplicationLineItems(
    Id applicationId,
    String recordTypeName
  ) {
    Id recordTypeId = Schema.SObjectType.Application_Line_Item__c
      .getRecordTypeInfosByDeveloperName()
      .get(recordTypeName)
      .getRecordTypeId();

    List<Application_Line_Item__c> lineitems = new SEL_CIBApplicationLineItem()
      .selectLineItemsByApplicationIdRecordType(applicationId, recordTypeId);

    return lineitems;
  }

  /**
   * @description Deletes an Application Line Item.
   * @param lineItem The Application Line Item to be deleted.
   */
  @AuraEnabled
  public static void deleteApplicationLineItem(
    Application_Line_Item__c lineItem
  ) {
    CIB_SEL_Fflib_FrameWork.deletefflibFrameWork(
      new List<SObjectType>{ Application_Line_Item__c.SObjectType },
      lineItem
    );
  }

  /**
   * @description Saves a list of Application Line Items based on the provided Record Type Name.
   * @param recordTypeName The Developer Name of the Record Type.
   * @param lineitems A list of Application Line Items to be saved.
   * @return The saved list of Application Line Items.
   */
  @AuraEnabled
  public static List<Application_Line_Item__c> saveApplicationLineItems(
    String recordTypeName,
    List<Application_Line_Item__c> lineitems
  ) {
    Id recordTypeId = Schema.SObjectType.Application_Line_Item__c
      .getRecordTypeInfosByDeveloperName()
      .get(recordTypeName)
      .getRecordTypeId();

    List<Application_Line_Item__c> insertList = new List<Application_Line_Item__c>();
    List<Application_Line_Item__c> updateList = new List<Application_Line_Item__c>();

    for (Application_Line_Item__c lineitem : lineitems) {
      lineitem.RecordTypeId = recordTypeId;
      if (lineitem.Id == null) {
        insertList.add(lineitem);
      } else {
        updateList.add(lineitem);
      }
    }

    if (updateList.size() > 0) {
      CIB_SEL_Fflib_FrameWork.updatefflibFrameWorkList(
        new List<SObjectType>{ Application_Line_Item__c.SObjectType },
        updateList
      );
    }
    if (insertList.size() > 0) {
      CIB_SEL_Fflib_FrameWork.insertfflibFrameWorkList(
        new List<SObjectType>{ Application_Line_Item__c.SObjectType },
        insertList
      );
    }
    return lineitems;
  }
}