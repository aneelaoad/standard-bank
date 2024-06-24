/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-02-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_CTRL_ACPicklist_Test {
  @isTest
  static void testLoadData() {
    // Create a test account record
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    // Get the picklist values for the Account Industry field
    List<CIB_CTRL_ACPicklist.PickListWrapper> picklistValues = CIB_CTRL_ACPicklist.loadData(
      'Account',
      'Industry'
    );

    // Verify that the picklist values are correct
    Assert.areNotEqual(
      0,
      picklistValues.size(),
      'The size of the picklist values should be greater than 0'
    );
    Assert.areNotEqual(
      null,
      picklistValues[0].label,
      'The first label should not be null'
    );
    Assert.areNotEqual(
      null,
      picklistValues[0].value,
      'The first value should not be null'
    );    
  }
}