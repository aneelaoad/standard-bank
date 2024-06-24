/**
 * @description       : 
 * @author            : silva.macaneta@standardbank.co.za
 * @group             : 
 * @last modified on  : 11-07-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
**/
@isTest
public class CIB_VF_BooleanPicklist_Test {
  @isTest
  static void testSetValue() {
    CIB_VF_BooleanPicklist controller = new CIB_VF_BooleanPicklist();
    controller.iValue = true;
    Assert.isTrue(controller.iValue, 'Value should be set to true');
  }
}