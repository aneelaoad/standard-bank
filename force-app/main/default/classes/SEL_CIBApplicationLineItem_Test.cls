/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-02-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class SEL_CIBApplicationLineItem_Test {
  @testSetup
  static void setup() {
    // Create test data
    Application__c app = new Application__c();
    insert app;
    String recordTypeId = Schema.SObjectType.Application_Line_Item__c.getRecordTypeInfosByDeveloperName()
      .get('Tax_Residence')
      .getRecordTypeId();
    Application_Line_Item__c ali = new Application_Line_Item__c(
      Application__c = app.Id,
      AmountStart__c = 1000,
      AmountEnd__c = 2000,
      CIB_EntityName__c = 'Test Entity',
      CIB_HasTINNumber__c = true,
      CIB_Industry__c = 'Agriculture',
      CIB_TaxResidenceJuristiction__c = 'Test Jurisdiction',
      CIB_TIN_Number__c = '123456789',
      CIB_TurnoverPercentage__c = 10,
      CurrencyStart__c = 'ZA - ZAR',
      CurrencyEnd__c = 'ZA - ZAR',
      RecordTypeId = recordTypeId,
      YearEnd__c = 2022,
      YearStart__c = 2021,
      CIB_Sequence__c = 1
    );
    insert ali;
  }

  @isTest
  static void testSelectWithoutCondition() {
    List<Application_Line_Item__c> lineItems = new SEL_CIBApplicationLineItem()
      .selectWithoutCondition();
    Assert.areEqual(
      1,
      lineItems.size(),
      'Expected one line item to be returned'
    );
  }

  @isTest
  static void testSelectApplicationLineItemById() {
    Application_Line_Item__c ali = [
      SELECT Id
      FROM Application_Line_Item__c
      LIMIT 1
    ];
    List<Application_Line_Item__c> lineItems = new SEL_CIBApplicationLineItem()
      .selectApplicationLineItemById(ali.Id);
    Assert.areEqual(
      1,
      lineItems.size(),
      'Expected one line item to be returned'
    );
    Assert.areEqual(
      ali.Id,
      lineItems[0].Id,
      'Expected the returned line item to match the queried line item'
    );
  }

  @isTest
  static void testSelectApplicationLineItemId() {
    Application_Line_Item__c ali = [
      SELECT Id
      FROM Application_Line_Item__c
      LIMIT 1
    ];
    Application_Line_Item__c lineItem = new SEL_CIBApplicationLineItem()
      .selectApplicationLineItemId(ali.Id);
    Assert.areEqual(
      ali.Id,
      lineItem.Id,
      'Expected the line item id to be the same'
    );
  }

  @isTest
  static void testSelectApplicationLineItemBySetIds() {
    Application_Line_Item__c ali = [
      SELECT Id
      FROM Application_Line_Item__c
      LIMIT 1
    ];
    Set<Id> ids = new Set<Id>{ ali.Id };
    List<Application_Line_Item__c> lineItems = new SEL_CIBApplicationLineItem()
      .selectApplicationLineItemBySetIds(ids);
    Assert.areEqual(
      1,
      lineItems.size(),
      'Expected one line item to be returned'
    );
    Assert.areEqual(
      ali.Id,
      lineItems[0].Id,
      'Expected the returned line item to match the queried line item'
    );
  }

  @isTest
  static void testSelectLineItemByApplicationId() {
    Application_Line_Item__c ali = [
      SELECT Id, Application__c
      FROM Application_Line_Item__c
      LIMIT 1
    ];
    List<Application_Line_Item__c> lineItems = new SEL_CIBApplicationLineItem()
      .selectLineItemByApplicationId(ali.Application__c);
    Assert.areEqual(
      1,
      lineItems.size(),
      'Expected one line item to be returned'
    );
    Assert.areEqual(
      ali.Id,
      lineItems[0].Id,
      'Expected the returned line item to match the queried line item'
    );
  }

  @isTest
  static void testSelectLineItemsByApplicationIdRecordType() {
    Application_Line_Item__c ali = [
      SELECT Id, Application__c, RecordTypeId
      FROM Application_Line_Item__c
      LIMIT 1
    ];
    List<Application_Line_Item__c> lineItems = new SEL_CIBApplicationLineItem()
      .selectLineItemsByApplicationIdRecordType(
        ali.Application__c,
        ali.RecordTypeId
      );
    Assert.areEqual(
      1,
      lineItems.size(),
      'Expected one line item to be returned'
    );
    Assert.areEqual(
      ali.Id,
      lineItems[0].Id,
      'Expected the returned line item to match the queried line item'
    );
  }
}