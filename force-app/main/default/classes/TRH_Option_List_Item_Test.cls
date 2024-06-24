/**
 * Test class for TRH_Option_List_Item class.
 * <br/>SGPRT-3817
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date January 2021
 */
@isTest
public with sharing class TRH_Option_List_Item_Test {

    @testSetup static void setupData() {


        ProfitCentreMatrix__c[] profitCenters = TEST_DataFactory.getProfitCentersSettings();
        insert profitCenters;
    }

    @isTest
    public static void handleBeforeInsertTest(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Option_List_Item(uow).companyCode(4015).name('Profit Center Test 1').proftCenterObject('Products');
        new BLD_Option_List_Item(uow).companyCode(7005).name('Profit Center Test 2').proftCenterObject('Products');
        Test.startTest();
        uow.commitWork();
        SEL_Option_List_Item selOptionListItem = SEL_Option_List_Item.newInstance();
        List<Option_List_Item__c> profitCenters = selOptionListItem.selectWithoutCondition();
        Test.stopTest();

        System.assertEquals('Namibia - Standard Bank Namibia Limited', profitCenters[0].Legal_Entity_of_Booking__c);
        System.assertEquals('Angola - Standard Bank de Angola S.A.', profitCenters[1].Legal_Entity_of_Booking__c);
        System.assertEquals(2, profitCenters.size());
    }

    @isTest
    public static void handleBeforeUpdateTest(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Option_List_Item(uow).companyCode(4015).name('Profit Center Test 1').proftCenterObject('Products');
        new BLD_Option_List_Item(uow).companyCode(7005).name('Profit Center Test 2').proftCenterObject('Products');
        uow.commitWork();
		SEL_Option_List_Item selOptionListItem = SEL_Option_List_Item.newInstance();
        List<Option_List_Item__c> profitCenters = selOptionListItem.selectWithoutCondition();
        Test.startTest();
        profitCenters[0].Company_Code__c = 7022;
        update profitCenters[0];
        SEL_Option_List_Item selOptionListItemAfterUpdate = SEL_Option_List_Item.newInstance();
        List<Option_List_Item__c> profitCentersAfterUpdate = selOptionListItemAfterUpdate.selectWithoutCondition();
        Test.stopTest();

        System.assertEquals('Mauritius - Standard Bank (Mauritius) Limited', profitCentersAfterUpdate[0].Legal_Entity_of_Booking__c);
        System.assertEquals(2, profitCenters.size());
    }

}