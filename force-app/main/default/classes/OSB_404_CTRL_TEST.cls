/**
* Test class for OSB_404_CTRL class
* <br/>SGPRT-3822
*
* @author Denys Yelchaninov (dyelchaninov@deloittece.com)
* @date November 2020
*/
@isTest
public with sharing class OSB_404_CTRL_TEST {
    @isTest
    public static void testLogging() {

        Test.startTest();
        OSB_404_CTRL.logPageEntry('testUrl');
        Test.stopTest();

        List<Log__c> newlyCreatedLogList = [SELECT Id, Area__c, Message__c, Source__c, Stack_trace__c, Type__c FROM Log__c];
        System.assert(newlyCreatedLogList.size() > 0);
        System.assertEquals('OSB_404_CTRL.OSB_404ReachedException: Page testUrl is not found.\nUser ' + UserInfo.getName() + ' tried to access nonexistnd page with url of testUrl', newlyCreatedLogList.get(0).Message__c);
    }
}