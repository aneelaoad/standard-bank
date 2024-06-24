/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-02-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_CTRL_ApplicationLineItem_Test {
  @isTest
  static void testGetApplicationLineItems() {
    // Create test data
    Application__c app = new Application__c();
    insert app;
    Application_Line_Item__c lineItem = new Application_Line_Item__c(
      Application__c = app.Id,
      RecordTypeId = Schema.SObjectType.Application_Line_Item__c
        .getRecordTypeInfosByDeveloperName()
        .get(CIB_Constants.APPLICATION_LINE_ITEM_RECORD_TYPE_TAX_RESIDENCE)
        .getRecordTypeId()
    );
    insert lineItem;

    // Call the method being tested
    List<Application_Line_Item__c> result = CIB_CTRL_ApplicationLineItem.getApplicationLineItems(
      app.Id,
      CIB_Constants.APPLICATION_LINE_ITEM_RECORD_TYPE_TAX_RESIDENCE
    );

    // Verify the results
    Assert.areEqual(1, result.size(), 'Expected 1 line item');
    Assert.areEqual(
      lineItem.Id,
      result[0].Id,
      'Expected the line item to be returned'
    );
  }

  @isTest
  static void testDeleteApplicationLineItem() {
    // Create test data
    Application__c app = new Application__c();
    insert app;
    Application_Line_Item__c lineItem = new Application_Line_Item__c(
      Application__c = app.Id
    );
    insert lineItem;

    // Call the method being tested
    Test.startTest();
    CIB_CTRL_ApplicationLineItem.deleteApplicationLineItem(lineItem);
    Test.stopTest();

    List<Application_Line_Item__c> result = [
      SELECT Id
      FROM Application_Line_Item__c
      WHERE Id = :lineItem.Id
    ];
    // Verify the results
    Assert.areEqual(0, result.size(), 'Expected the line item to be deleted');
  }

  @isTest
  static void testSaveApplicationLineItems() {
    // Create test data
    Application__c app = new Application__c();
    insert app;
    Application_Line_Item__c lineItem = new Application_Line_Item__c(
      Application__c = app.Id
    );
    // Call the method being tested
    Test.startTest();
    List<Application_Line_Item__c> result = CIB_CTRL_ApplicationLineItem.saveApplicationLineItems(
      CIB_Constants.APPLICATION_LINE_ITEM_RECORD_TYPE_TAX_RESIDENCE,
      new List<Application_Line_Item__c>{ lineItem }
    );
    Test.stopTest();

    // Verify the results
    Assert.areEqual(1, result.size(), 'Expected 1 line item');
    Assert.areNotEqual(
      null,
      result[0].Id,
      'Expected the line item to be saved'
    );
  }
}