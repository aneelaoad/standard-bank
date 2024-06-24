/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 11-06-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_VF_ItemList_Test {
  @isTest
  static void testOptions() {
    CIB_VF_ItemList itemList = new CIB_VF_ItemList();
    itemList.value = 'Option 1;Option 2;Option 3';

    List<String> expectedOptions = new List<String>{
      'Option 1',
      'Option 2',
      'Option 3'
    };
    List<String> actualOptions = itemList.options;

    System.assertEquals(expectedOptions, actualOptions, 'Options should match');
  }

  @isTest
  static void testOptionsWithNullValue() {
    CIB_VF_ItemList itemList = new CIB_VF_ItemList();
    itemList.value = null;

    List<String> expectedOptions = new List<String>();
    List<String> actualOptions = itemList.options;

    System.assertEquals(expectedOptions, actualOptions, 'Options should match');
  }
}