/**
* @description:- Test class to test the Outbound AOB_API_GetRpConfig
* @author:- Dayakar
*/
@IsTest
private class AOB_API_DigitalOffers_Test {
    /**
    * @description To setup the List of Webservice Call Queue
    *
    * @return A list of queue items
    */
    private static List<CMN_WebserviceCallQueue__c> setup() {
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            AOB_API_DigitalOffers.SERVICE_NAME,
            UserInfo.getUserId()
        );
        
        return new List<CMN_WebserviceCallQueue__c>{ queueItem };
            }
    
   /**
    * @description test method for AOB_SRV_GetDigital.fetchResponse
    * author dayakar
    */
    @isTest
    public static void AOB_API_DigitalOffers_test(){
       String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_SRV_GetDigital.fetchResponse(applicationId); 
       Test.stopTest();
    }  
    
    /**
    * @description test method for AOB_SRV_GetDigital.fetchResponse
    * author dayakar
    */
    @isTest
    public static void AOB_API_DigitalOfferss_test(){
        String applicationId=AOB_DAL_TestFactory.createAppWithInflightKey();
        Test.startTest();
        AOB_SRV_GetDigital.fetchResponse(applicationId); 
       Test.stopTest();
    } 
    
}