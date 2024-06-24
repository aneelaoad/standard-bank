/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_FLOW_NormalizeBankAccounts
@ Description       : This class is responsible for normalizing bank accounts for CIB applications.
@ Last Modified By  : 10-03-2023
@ Last Modified On  : silva.macaneta@standardbank.co.za
@ Modification Description : SFP
***************************************************************************************/
public without sharing class CIB_FLOW_NormalizeBankAccounts {
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
    .createLogger('CIB_FLOW_NormalizeBankAccounts');

  /**
   * @description       : Invocable method to update or create Application Details based on Application record state.
   * @param applicationIds : List of Application__c record Ids.
   **/
  @InvocableMethod(
    label='Update Application Bank Accounts'
    description='Update or create Application Details based on Application record state'
  )
  public static void updateApplicationLineItems(List<Id> applicationIds) {
    List<Application__c> applications = new SEL_CIBApplication()
      .selectByIds(applicationIds);

    for (Application__c app : applications) {
      List<String> currentAccountsCurrencies = new List<String>();
      List<String> currentPlusAccountsCurrencies = new List<String>();

      if (app.CIB_AT_IsCurrentAccount__c) {
        currentAccountsCurrencies.addAll(
          app.CIB_AT_CurrentAccountCurrencies__c.split(';')
        );
      }
      if (app.CIB_AT_IsCurrentAccountPlus__c) {
        currentPlusAccountsCurrencies.addAll(
          app.CIB_AT_CurrentAccountPlusCurrencies__c.split(';')
        );
      }
      createOrUpdateDetails(
        app.Id,
        currentAccountsCurrencies,
        currentPlusAccountsCurrencies
      );
    }
  }

  /**
   * @description       : Private method to create or update Application_Line_Item__c records.
   * @param applicationId : Id of the Application__c record.
   * @param currencies    : List of currencies for the Application_Line_Item__c records.
   * @param currenciesPlus : List of currencies for the Application_Line_Item__c records.
   **/
  private static void createOrUpdateDetails(
    Id applicationId,
    List<String> currencies,
    List<String> currenciesPlus
  ) {
    Id recordTypeId = Schema.SObjectType.Application_Line_Item__c.getRecordTypeInfosByDeveloperName()
      .get(CIB_Constants.APPLICATION_LINE_ITEM_RECORD_TYPE_BANK_ACCOUNT)
      .getRecordTypeId();

    List<Application_Line_Item__c> existingDetails = getExistingDetails(
      applicationId,
      recordTypeId
    );

    Map<String, Application_Line_Item__c> currencyToDetail = new Map<String, Application_Line_Item__c>();
    for (Application_Line_Item__c detail : existingDetails) {
      currencyToDetail.put(
        detail.CIB_Currency__c + '|' + detail.CIB_AccountType__c,
        detail
      );
    }

    List<Application_Line_Item__c> detailsToInsert = new List<Application_Line_Item__c>();
    List<Application_Line_Item__c> detailsToUpdate = new List<Application_Line_Item__c>();
    for (String currncy : currencies) {
      String key = currncy + '|Current Account';
      Application_Line_Item__c detail = currencyToDetail.get(key);
      if (detail == null) {
        detail = createDetail(
          applicationId,
          recordTypeId,
          currncy,
          'Current Account'
        );
      } else {
        detailsToUpdate.add(detail);
      }
      detailsToInsert.add(detail);
      currencyToDetail.remove(key);
    }
    for (String currncy : currenciesPlus) {
      String key = currncy + '|Current Account Plus';
      Application_Line_Item__c detail = currencyToDetail.get(key);
      if (detail == null) {
        detail = createDetail(
          applicationId,
          recordTypeId,
          currncy,
          'Current Account Plus'
        );
      } else {
        detailsToUpdate.add(detail);
      }
      detailsToInsert.add(detail);
      currencyToDetail.remove(key);
    }

    List<Application_Line_Item__c> detailsToDelete = new List<Application_Line_Item__c>(
      currencyToDetail.values()
    );
    deleteDetails(detailsToDelete);
    insertDetails(detailsToInsert);
    updateDetails(detailsToUpdate);
  }

  /**
   * @description       : Private method to get existing Application_Line_Item__c records.
   * @param applicationId : Id of the Application__c record.
   * @param recordTypeId  : Id of the Application_Line_Item__c record type.
   * @return List<Application_Line_Item__c> : List of Application_Line_Item__c records.
   **/
  private static List<Application_Line_Item__c> getExistingDetails(
    Id applicationId,
    Id recordTypeId
  ) {
    return new SEL_CIBApplicationLineItem()
      .selectLineItemsByApplicationIdRecordType(applicationId, recordTypeId);
  }

  /**
   * @description       : Private method to create a new Application_Line_Item__c record.
   * @param applicationId : Id of the Application__c record.
   * @param recordTypeId  : Id of the Application_Line_Item__c record type.
   * @param currencyName      : Currency for the Application_Line_Item__c record.
   * @param accountType   : Account type for the Application_Line_Item__c record.
   * @return Application_Line_Item__c
   **/
  private static Application_Line_Item__c createDetail(
    Id applicationId,
    Id recordTypeId,
    String currencyName,
    String accountType
  ) {
    return new Application_Line_Item__c(
      Application__c = applicationId,
      CIB_Currency__c = currencyName,
      RecordTypeId = recordTypeId,
      CIB_AccountType__c = accountType
    );
  }

  /**
   * @description       : Private method to delete Application_Line_Item__c records.
   * @param detailsToDelete : List of Application_Line_Item__c records to delete.
   **/
  private static void deleteDetails(
    List<Application_Line_Item__c> detailsToDelete
  ) {
    if (!detailsToDelete.isEmpty()) {
      CIB_SEL_Fflib_FrameWork.deletefflibFrameWorkList(
        new List<Schema.SObjectType>{ Application_Line_Item__c.SObjectType },
        detailsToDelete
      );
    }
  }

  /**
   * @description       : Private method to insert Application_Line_Item__c records.
   * @param detailsToInsert : List of Application_Line_Item__c records to insert.
   **/
  private static void insertDetails(
    List<Application_Line_Item__c> detailsToInsert
  ) {
    if (!detailsToInsert.isEmpty()) {
      CIB_SEL_Fflib_FrameWork.insertfflibFrameWorkList(
        new List<Schema.SObjectType>{ Application_Line_Item__c.SObjectType },
        detailsToInsert
      );
    }
  }

  /**
   * @description       : Private method to update Application_Line_Item__c records.
   * @param detailsToUpdate : List of Application_Line_Item__c records to update.
   **/
  private static void updateDetails(
    List<Application_Line_Item__c> detailsToUpdate
  ) {
    if (!detailsToUpdate.isEmpty()) {
      CIB_SEL_Fflib_FrameWork.updatefflibFrameWorkList(
        new List<Schema.SObjectType>{ Application_Line_Item__c.SObjectType },
        detailsToUpdate
      );
    }
  }
}