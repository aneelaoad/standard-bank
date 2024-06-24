/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-11-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_VF_MultiPicklistCheckbox_Test {
  @isTest
  static void testGetPicklistValues() {
    Account account = new Account(Name = 'Test Account');
    insert account;

    List<String> picklistValues = CIB_VF_MultiPicklistCheckbox.getPicklistValues(
      'Account',
      'Industry'
    );

    Assert.areNotEqual(
      0,
      picklistValues.size(),
      'Picklist values should not be empty'
    );
  }

  @isTest
  static void testOptions() {
    Account account = new Account(Name = 'Test Account');
    insert account;

    CIB_VF_MultiPicklistCheckbox multiPicklistCheckbox = new CIB_VF_MultiPicklistCheckbox();
    multiPicklistCheckbox.objectApiName = 'Account';
    multiPicklistCheckbox.fieldApiName = 'Industry';
    multiPicklistCheckbox.value = 'Banking;Insurance';

    List<CIB_VF_MultiPicklistCheckbox.SelectOption> options = multiPicklistCheckbox.options;

    Assert.areNotEqual(0, options.size(), 'Options should not be empty');

    for (CIB_VF_MultiPicklistCheckbox.SelectOption option : options) {
      if (option.label == 'Banking') {
        Assert.areEqual(
          true,
          option.value,
          'Banking option should be selected'
        );
      } else if (option.label == 'Insurance') {
        Assert.areEqual(
          true,
          option.value,
          'Insurance option should be selected'
        );
      } else {
        Assert.areEqual(
          false,
          option.value,
          option.label + ' option should not be selected'
        );
      }
    }
  }
}