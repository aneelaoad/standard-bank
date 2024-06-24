/**
* @description Test class for Drawdown Selector Layer class.
*
* @author Wayne Solomon
* @date Feb 2021
*/
@IsTest
private class SEL_DrawdownProfiles_TEST {
    @IsTest
    static void selectByIdsAndParentProductTest() {
        SEL_DrawdownProfiles selector = new SEL_DrawdownProfiles();
        Test.startTest();
        List<Draw_Down_Profile__c> methodOneOpps = selector.selectByIdsAndParentProduct(new Set<Id>{null});
        Test.stopTest();

        System.assert(methodOneOpps.isEmpty());
    }
}