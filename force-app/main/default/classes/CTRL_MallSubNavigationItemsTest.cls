@isTest
public with sharing class CTRL_MallSubNavigationItemsTest {
    @testSetup
    static void setupTestData() {
        List<Mall_Sub_Navigation_Item__mdt> lstOfMetadata=new List<Mall_Sub_Navigation_Item__mdt>();
        Mall_Sub_Navigation_Item__mdt subNavItem1 = new Mall_Sub_Navigation_Item__mdt(
            Label = 'Test Item 1',
            Available_In_Main_Navigation__c = true,
            Available_In_Solution_Page__c = true,
            Is_Main__c = true,
            Order_Number__c = 1,
            Set_As_Active__c = true,
            URL_Link__c = 'http://example.com/1',
            Icon__c = 'icon1',
            Tagline__c = 'Tagline 1'
        );

        Mall_Sub_Navigation_Item__mdt subNavItem2 = new Mall_Sub_Navigation_Item__mdt(
            Label = 'Test Item 2',
            Available_In_Main_Navigation__c = false,
            Available_In_Solution_Page__c = true,
            Is_Main__c = false,
            Order_Number__c = 2,
            Set_As_Active__c = false,
            URL_Link__c = 'http://example.com/2',
            Icon__c = 'icon2',
            Tagline__c = 'Tagline 2'
        );
        lstOfMetadata.add(subNavItem1);
        lstOfMetadata.add(subNavItem2);
    	//insert lstOfMetadata;
    }

    @isTest
    static void testGetMallSubNavigationItems() {
        Test.startTest();
        List<CTRL_MallSubNavigationItems.SubNavigationItemWrapper> items = CTRL_MallSubNavigationItems.getMallSubNavigationItems();
        Test.stopTest();

      
    }

    @isTest
    static void testGetSolutionPageMainCategories() {
        Test.startTest();
        List<CTRL_MallSubNavigationItems.SubNavigationItemWrapper> items = CTRL_MallSubNavigationItems.getSolutionPageMainCategories();
        Test.stopTest();

       
    }

  
}