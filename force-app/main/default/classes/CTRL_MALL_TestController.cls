public with sharing class CTRL_MALL_TestController {

    @AuraEnabled
    public static String getMyToken() {
        return MALL_AUTH_PingCustomer.getAccessToken();
    }
}