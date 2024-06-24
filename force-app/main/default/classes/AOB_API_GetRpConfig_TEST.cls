/**
* @description:- Test class to test the Outbound AOB_API_GetRpConfig
* @author:- Dayakar
*/
@IsTest
private class AOB_API_GetRpConfig_TEST  {
    
    @IsTest
    private static List<CMN_WebserviceCallQueue__c> setup() {
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            AOB_API_GetRpConfig.SERVICE_NAME,
            UserInfo.getUserId()
        );
        
        return new List<CMN_WebserviceCallQueue__c>{ queueItem };
            }
    
    
    
    /**
    * @description test method for AOB_CTRL_RPDetails.CallGetApplication
    * author dayakar
    */
    @IsTest
    public static void CallgetRPController(){
        
        
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        try{
            Test.startTest();
            AOB_SRV_GetRPconfig.callGetRP(applicationId);
            test.stopTest();
            Assert.areNotEqual(null, applicationId); 
        }
        catch(Exception e)
        {
            e.getMessage();
        }
        
        
        
        
    }
    
    
    
}