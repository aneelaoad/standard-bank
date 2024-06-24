/**
 * @description Test class for OSB_SRV_BotBalanceViewHandler
 *
 * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
@isTest
public with sharing class OSB_SRV_BotBalanceViewHandler_TEST {
    @isTest
    public static void testQueryOCHForBalanceDetails(){
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', '{}', null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        HttpResponse httpRequest = OSB_SRV_BotBalanceViewHandler.queryOCHForBalanceDetails('12345', 'accessToken1', 'Mauritius');
        Test.stopTest();
        System.assertEquals(200, httpRequest.getStatusCode(), 'Should be 200');
    }

    @isTest
    public static void testQueryOCHForAccountDetails(){
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', '{}', null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        HttpResponse httpRequest = OSB_SRV_BotBalanceViewHandler.queryOCHForAccountDetails('12345', 'accessToken1', 'Mauritius');
        Test.stopTest();
        System.assertEquals(200, httpRequest.getStatusCode(), 'Should be 200');

    }

    @isTest
    public static void testQueryOCHForAccessToken(){
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', '{}', null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        HttpResponse httpRequest = OSB_SRV_BotBalanceViewHandler.queryOCHForAccessToken('Mauritius');
        Test.stopTest();
        System.assertEquals(200, httpRequest.getStatusCode(), 'Should be 200');
    }
    
    @isTest
    public static void testQueryOCHForAccountsList(){
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', '{}', null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        HttpResponse httpRequest = OSB_SRV_BotBalanceViewHandler.queryOCHForAccountsList('12345', 'accessToken1', 'Mauritius');
        Test.stopTest();
        System.assertEquals(200, httpRequest.getStatusCode(), 'Should be 200');
    }
     
}