/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-12-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_VF_checkbox_Test {
  @isTest
  static void testCIB_VF_checkbox() {
    CIB_VF_checkbox checkbox = new CIB_VF_checkbox();

    checkbox.iLabel = 'Checkbox Label';
    checkbox.iValue = true;

    Assert.areEqual(
      'Checkbox Label',
      checkbox.iLabel,
      'Label not set correctly'
    );
    Assert.areEqual(true, checkbox.iValue, 'Value not set correctly');
  }
}