/**
* @description Test class to test the Outbound Personal de API call
*
* 
*
* @author Dayakar
*
* @date  
*/
@istest
private class AOB_API_UpdatePersonalDetails_TEST {
    /**
* @description To setup the List of Webservice Call Queue
*
* @return A list of queue items
*/
    private static List<CMN_WebserviceCallQueue__c> setup() {
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            AOB_API_UpdatePersonalDetails.SERVICE_NAME,
            
            UserInfo.getUserId()
        );
        
        return new List<CMN_WebserviceCallQueue__c>{ queueItem };
            }
    
    
    
   
    @istest
    public static void updatePersonalDetails()
    {
        
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.updatePersonalDetails(applicationId);
        test.stopTest();
        System.assertNotEquals(null, applicationId);

    }
  
}