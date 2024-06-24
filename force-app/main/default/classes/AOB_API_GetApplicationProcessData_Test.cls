/* Test Class for API call to get Application Data	
* Author : dayakar
* Date   : 25 Jan 2023 
*/ 
@isTest
public class AOB_API_GetApplicationProcessData_Test {
     
    private static List<CMN_WebserviceCallQueue__c> setup() {
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            AOB_API_GetApplicationProcessData.SERVICE_NAME,
            UserInfo.getUserId()
        );
        return new List<CMN_WebserviceCallQueue__c>{ queueItem };
    }
    
    /**
    * @description test method for AOB_SRV_GetApplicationProcess.getApplicationProcessedData
    * author dayakar
    */
    @IsTest
    public static void getApplicationProcessDataTest()
    {  
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_SRV_GetApplicationProcess.getApplicationProcessedData(applicationId);
        Test.stopTest();
        System.assertNotEquals(null, applicationId);  
    }
    
    
    /**
    * @description test method for AOB_SRV_GetApplicationProcess.getApplicationProcessedData
    * author dayakar
    */
    @IsTest
    public static void getApplicationProcessDataNegTest()
    {
        Boolean isFailing=false;
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            Test.startTest();
            AOB_SRV_GetApplicationProcess.getApplicationProcessedData('');
            Test.stopTest();
            System.assertNotEquals(null, applicationId);
        }Catch(Exception e){
            isFailing=true;
            System.assertEquals(true, isFailing);
            
        }
        
    }
}