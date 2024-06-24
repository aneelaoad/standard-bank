/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-04-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_SEL_Fflib_FrameWork_Test {
  @isTest
  static void testUpdatefflibFrameWorkList() {
    // Create test records
    Account acc1 = new Account(Name = 'Test Account 1');
    Account acc2 = new Account(Name = 'Test Account 2');
    insert new List<Account>{ acc1, acc2 };

    // Update test records
    acc1.Name = 'Updated Test Account 1';
    acc2.Name = 'Updated Test Account 2';
    List<Sobject> sObjectList = new List<Sobject>{ acc1, acc2 };
    List<Schema.SObjectType> sObjectTypes = new List<Schema.SObjectType>{
      Account.SObjectType
    };
    List<Sobject> updatedList = CIB_SEL_Fflib_FrameWork.updatefflibFrameWorkList(
      sObjectTypes,
      sObjectList
    );

    // Verify records were updated
    Assert.areEqual(
      'Updated Test Account 1',
      ((Account) updatedList[0]).Name,
      'Record was not updated'
    );
    Assert.areEqual(
      'Updated Test Account 2',
      ((Account) updatedList[1]).Name,
      'Record was not updated'
    );
  }

  @isTest
  static void testUpdatefflibFrameWork() {
    // Create test record
    Account acc = new Account(Name = 'Test Account');
    insert acc;

    // Update test record
    acc.Name = 'Updated Test Account';
    List<Schema.SObjectType> sObjectTypes = new List<Schema.SObjectType>{
      Account.SObjectType
    };
    Sobject updatedObj = CIB_SEL_Fflib_FrameWork.updatefflibFrameWork(
      sObjectTypes,
      acc
    );

    // Verify record was updated
    Assert.areEqual(
      'Updated Test Account',
      ((Account) updatedObj).Name,
      'Record was not updated'
    );
  }

  @isTest
  static void testInsertfflibFrameWorkList() {
    // Create test records
    Account acc1 = new Account(Name = 'Test Account 1');
    Account acc2 = new Account(Name = 'Test Account 2');
    List<Sobject> sObjectList = new List<Sobject>{ acc1, acc2 };
    List<Schema.SObjectType> sObjectTypes = new List<Schema.SObjectType>{
      Account.SObjectType
    };
    List<Sobject> insertedList = CIB_SEL_Fflib_FrameWork.insertfflibFrameWorkList(
      sObjectTypes,
      sObjectList
    );

    // Verify records were inserted
    Assert.areEqual(
      'Test Account 1',
      ((Account) insertedList[0]).Name,
      'Record was not inserted'
    );
    Assert.areEqual(
      'Test Account 2',
      ((Account) insertedList[1]).Name,
      'Record was not inserted'
    );
  }

  @isTest
  static void testInsertfflibFrameWork() {
    // Create test record
    Account acc = new Account(Name = 'Test Account');
    List<Schema.SObjectType> sObjectTypes = new List<Schema.SObjectType>{
      Account.SObjectType
    };
    Sobject insertedObj = CIB_SEL_Fflib_FrameWork.insertfflibFrameWork(
      sObjectTypes,
      acc
    );

    // Verify record was inserted
    Assert.areEqual(
      'Test Account',
      ((Account) insertedObj).Name,
      'Record was not inserted'
    );
  }

  @isTest
  static void testDeletefflibFrameWorkList() {
    // Create test records
    Account acc1 = new Account(Name = 'Test Account 1');
    Account acc2 = new Account(Name = 'Test Account 2');
    insert new List<Account>{ acc1, acc2 };

    // Delete test records
    List<Sobject> sObjectList = new List<Sobject>{ acc1, acc2 };
    List<Schema.SObjectType> sObjectTypes = new List<Schema.SObjectType>{
      Account.SObjectType
    };
    CIB_SEL_Fflib_FrameWork.deletefflibFrameWorkList(sObjectTypes, sObjectList);

    // Verify records were deleted
    List<Account> deletedAccounts = [
      SELECT Id
      FROM Account
      WHERE Id IN :(new List<Id>{ acc1.Id, acc2.Id })
    ];
    Assert.areEqual(0, deletedAccounts.size(), 'Record was not deleted');
  }

  @isTest
  static void testDeletefflibFrameWork() {
    // Create test record
    Account acc = new Account(Name = 'Test Account');
    insert acc;

    // Delete test record
    List<Schema.SObjectType> sObjectTypes = new List<Schema.SObjectType>{
      Account.SObjectType
    };
    CIB_SEL_Fflib_FrameWork.deletefflibFrameWork(sObjectTypes, acc);

    // Verify record was deleted
    List<Account> deletedAccounts = [SELECT Id FROM Account WHERE Id = :acc.Id];
    Assert.isTrue(deletedAccounts.isEmpty(), 'Record was not deleted');
  }
}