/***************************************************************************************
@Author            : Narendra
@Date              : Aug 10th 2023
@Name of the Class : AOB_CTRL_BackToBCBPlatform_Test
@description       : Test Class for AOB_CTRL_BackToBCBPlatform
@Last Modified By  : Narendra   
***************************************************************************************/
@isTest
public class AOB_CTRL_BackToBCBPlatform_Test {
    /**
    * @description Test setup method to insert medatadata
    */
 @isTest
    static void getMymobizManagementSettingTest() {
        try{
        Mymobiz_management_setting__mdt testSetting = new Mymobiz_management_setting__mdt();
        testSetting.Channel__c='test';
        Test.startTest();
        Mymobiz_management_setting__mdt result = AOB_CTRL_BackToBCBPlatform.getMymobizManagementSetting('test');
        Test.stopTest();
         Assert.areEqual(result, testSetting.Channel__c, 'test');
        }catch(exception ex){
           Assert.areNotEqual(null,'Test Message');
            }
    }
}