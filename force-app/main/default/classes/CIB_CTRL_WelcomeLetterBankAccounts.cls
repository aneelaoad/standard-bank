/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_CTRL_WelcomeLetterBankAccounts
@ Description       : Controller class for generating welcome letters for bank accounts in the CIB application.
                      This class retrieves the bank accounts associated with the application and provides them to the view for display.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP
***************************************************************************************/
public with sharing class CIB_CTRL_WelcomeLetterBankAccounts {
  /**
   * @description : The ID of the CIB application for which to generate welcome letters.
   **/
  public String appId { get; set; }

  /**
   * @description : The list of bank accounts associated with the CIB application.
   * @return List<Application_Line_Item__c> : List of Application_Line_Item__c records.
   **/
  public List<Application_Line_Item__c> bankAccounts {
    get {
      Id recordTypeId = Schema.SObjectType.Application_Line_Item__c
        .getRecordTypeInfosByDeveloperName()
        .get(CIB_Constants.APPLICATION_LINE_ITEM_RECORD_TYPE_BANK_ACCOUNT)
        .getRecordTypeId();

      List<Application_Line_Item__c> details = new SEL_CIBApplicationLineItem()
        .selectLineItemsByApplicationIdRecordType(appId, recordTypeId);

      if (details == null || details.isEmpty()) {
        return new List<Application_Line_Item__c>();
      }

      return details;
    }
    set;
  }
}