/**
 * Test Class for OSB_RetreiveCommunityUrl
 * <br/>US-3970
 * 
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date Mar 2020
 */
@isTest
public with sharing class OSB_RetrieveCommunityUrlTest {
    static testMethod void testGetCommunityUrl() {
        List<OSB_URLs__c> osbUrls = TEST_DataFactory.getOsbUrls();
    	insert osbUrls;
        List<Object> output = new List<Object>();
        Test.startTest();
        output = OSB_RetrieveCommunityUrl.getCommunityUrl();
        Test.stopTest();
        System.assertEquals(false, output[0] instanceof String);
        System.assert(String.valueOf(output[0]).contains(OSB_URLs__c.getAll().get(OSB_RetrieveCommunityUrl.KEY_BASE_URL).Value__c));
    }
}