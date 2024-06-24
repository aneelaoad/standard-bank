/**
 * Test class for DMN_Option_List_Item class.
 * <br/>SGPRT-3817
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date January 2021
 */
@isTest
public with sharing class DMN_Option_List_Item_Test {

    @testSetup static void setupData() {

        ProfitCentreMatrix__c[] profitCenters = TEST_DataFactory.getProfitCentersSettings();
        insert profitCenters;
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Option_List_Item(uow).companyCode(4015).name('Profit Center Test 1').proftCenterObject('Products');
        new BLD_Option_List_Item(uow).companyCode(7005).name('Profit Center Test 2').proftCenterObject('Products');
        new BLD_Option_List_Item(uow).companyCode(7008).name('Profit Center Test 3').proftCenterObject('Products');
        uow.commitWork();
    }
    @isTest
    public static void populateLegalEntityOfBookingTest(){
        SEL_Option_List_Item selOptionListItem = SEL_Option_List_Item.newInstance();
        List<Option_List_Item__c> profitCenters = selOptionListItem.selectWithoutCondition();
        Test.startTest();
        DMN_Option_List_Item.populateLegalEntityOfBooking(profitCenters);
        Test.stopTest();
        System.assertEquals('Namibia - Standard Bank Namibia Limited', profitCenters[0].Legal_Entity_of_Booking__c);
        System.assertEquals('Angola - Standard Bank de Angola S.A.', profitCenters[1].Legal_Entity_of_Booking__c);
        System.assertEquals(3, profitCenters.size());
    }

    @isTest
    public static void populateLegalEntityOfBookingNegativeTest(){
        SEL_Option_List_Item selOptionListItem = SEL_Option_List_Item.newInstance();
        List<Option_List_Item__c> profitCenters = selOptionListItem.selectByName(New Set<String>{'Profit Center Test 3'});
        Test.startTest();
        DMN_Option_List_Item.populateLegalEntityOfBooking(profitCenters);
        Test.stopTest();

        System.assertEquals(null, profitCenters[0].Legal_Entity_of_Booking__c);
        System.assertEquals(1, profitCenters.size());
    }
}