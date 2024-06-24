/**
 * @description Test the MALL_AUTH_PingCustomer methods
 * <p/>
 *
 * @see MALL_AUTH_PingCustomerTest
 *
 * @author Ankit Kumar
 *
 * @date October 2023
 */

 @IsTest
 public with sharing class MALL_AUTH_PingCustomerTest {
     @IsTest
     private static void getUserAccessToken()
     {
         Test.startTest();
 
         MALL_OAuth_Util.ignoreTestMode = false;
 
         String token = MALL_AUTH_PingCustomer.getAccessToken();
 
         Test.stopTest();
 
         Assert.isTrue(token != NULL, 'expected a mock token to be returned');
     }
 }