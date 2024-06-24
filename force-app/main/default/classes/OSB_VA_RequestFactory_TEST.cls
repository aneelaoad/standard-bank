/* 
* @description Test class for OSB_VA_RequestFactory
*
* @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
* @date May 2022
*/
@isTest
public class OSB_VA_RequestFactory_TEST
{
    @isTest
    public static void testiTrackPayRequest()
    {
        Test.startTest();
        HttpRequest iTrackPayRequest = OSB_VA_RequestFactory.createiTrackPaySearchRequest('SOME_TRANSACTION_NUMBER', 'Transaction');
        Test.stopTest();
        System.assert(true, iTrackPayRequest.getEndpoint().contains('SOME_TRANSACTION_NUMBER'));
    }
    
    @isTest
    public static void testSwiftRequest()
    {
        Test.startTest();
        HttpRequest swiftRequest = OSB_VA_RequestFactory.createSwiftGPIPaymentTrackingRequest('THIS_IS_THE_UETR');
        Test.stopTest();
        
        System.assert(true, swiftRequest.getEndpoint().contains('THIS_IS_THE_UETR'));
    }

    @isTest
    public static void testCreateOCHBalanceInquiryRequest()
    {        
        Test.startTest();
        HttpRequest ochResponse = OSB_VA_RequestFactory.createOCHBalanceInquiryRequest('OT21270TZ0171140', 'Transaction', 'Mauritius');
        Test.stopTest();
        System.assert(true, ochResponse.getEndpoint().contains('acctId'));

    }
    
    @isTest
    public static void testCreateOCHAccountDetailsInquiryRequest()
    {        
        Test.startTest();
        HttpRequest ochResponse = OSB_VA_RequestFactory.createOCHAccountDetailsInquiryRequest('12345', '9fdde8da-0fd5-40b4-9791-0a1d67f6024e', 'Mauritius');
        Test.stopTest(); 
        System.assert(true, ochResponse.getEndpoint().contains('accountId'));

    }

    @isTest
    public static void testCreateOCHCustomerAccountInquiryRequest()
    {
        Test.startTest();
        HttpRequest ochResponse = OSB_VA_RequestFactory.createOCHCustomerAccountInquiryRequest('OT21270TZ0171140', 'Transaction', 'Mauritius');
        Test.stopTest();
        System.assert(true, ochResponse.getEndpoint().contains('custid'));
    }
    
    @isTest
    public static void testCreateAWSStatementAuthenticationRequest()
    {        
        Test.startTest();
        HttpRequest awsResponse = OSB_VA_RequestFactory.createAWSStatementAuthenticationRequest('Mauritius');
        Test.stopTest();
        System.assert(true, awsResponse.getEndpoint().contains('statements'));

    }

    @isTest
    public static void testCreateOCHAuthenticateRequest()
    {        
        Test.startTest();
        HttpRequest ochResponse = OSB_VA_RequestFactory.createOCHAuthenticateRequest('Mauritius');
        Test.stopTest();
        System.assert(true, ochResponse.getEndpoint().contains('oAuth'));

    }

    @isTest
    public static void testCreateAWSStatementRequest()
    {       
        Test.startTest();
        HttpRequest awsResponse = OSB_VA_RequestFactory.createAWSStatementRequest('OT21270TZ0171140', 'Transaction', 'Mauritius');
        Test.stopTest();
        System.assert(true, awsResponse.getEndpoint().contains('statements'));
    }
    @isTest
    public static void testCreateOCHStatementInquiryRequest()
    {        
        Test.startTest();
        HttpRequest ochResponse = OSB_VA_RequestFactory.createOCHStatementInquiryRequest('12345', '9fdde8da-0fd5-40b4-9791-0a1d67f6024e', '01-12-1997', '01-12-2012','Mauritius');
        Test.stopTest();
        System.assert(true, ochResponse.getEndpoint().contains('corp'));

    }
}