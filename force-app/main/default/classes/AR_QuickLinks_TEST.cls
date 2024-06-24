/**
 * @description Test Class for AR_QuickLinks_CTRL
 * @author Maham Hassan
 * @since 12-04-2022
 */
@isTest
public with sharing class AR_QuickLinks_TEST {

    /**
     * @description Test method to retrieve quick links
     */
    @isTest
    public static void testQuickLinks() {

        Test.startTest();
            List<AR_QuickLinks_CTRL.AR_QuickLinks> qLinks = AR_QuickLinks_CTRL.getQuickLinks();
        Test.stopTest();
        
        Assert.isTrue(qLinks.size() > 0, 'Quick Links items should be returned.');
    }

    /**
     * @description Test method to retrieve sector resources
     */
    @isTest
    public static void testSectorResources() {

        Test.startTest();
            List<AR_QuickLinks_CTRL.AR_QuickLinks> secResources = AR_QuickLinks_CTRL.getSectorResources();
        Test.stopTest();
        
        Assert.isTrue(secResources.size() > 0, 'Sector Resources items should be returned.');
    }

}