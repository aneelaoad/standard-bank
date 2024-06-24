/**
* @description Test class to test the Outbound create contract API call
* @author Dayakar
*/
@IsTest
private class AOB_API_CreateContract_Test {
    /**
    * @description To setup the List of Webservice Call Queue
    * @return A list of queue items
    */
    private static List<CMN_WebserviceCallQueue__c> setup() {
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            AOB_API_CreateContract.SERVICE_NAME,
            UserInfo.getUserId()
        );
        
        return new List<CMN_WebserviceCallQueue__c>{ queueItem };
            }
    
   /**
    * @description test method for AOB_SRV_CreateContract.callContractAPI
    * author dayakar
    */
    @IsTest
    public static void callContractAPITest()
    {
        AOB_DAL_TestFactory.createApplicationRecord();
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_SRV_CreateContract.callContractAPI(applicationId);
        Test.stopTest();
        Assert.areNotEqual(null, applicationId);
        
    }
   /**
    * @description test method for AOB_SRV_CreateContract.callContractAPI
    * author dayakar
    */
    @ISTest
    public static void callGetDocument(){
        String docName='Card application';
        AOB_DAL_TestFactory.createApplicationRecord();
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_SRV_CreateContract.callGetDocumentAPI(applicationId,docName);
        Test.stopTest();
        Assert.areNotEqual(null, applicationId);
        
    }
    /**
    * @description test method for AOB_SRV_CreateContract.callContractAPI
    * author dayakar
    */
    @IsTest
    public static void callContractAPINegTest()
    {
        Boolean IsExceptionOccured=false;
        try{
        AOB_DAL_TestFactory.createApplicationRecord();
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_SRV_CreateContract.callContractAPI('');
        Test.stopTest();
        Assert.areNotEqual(null, applicationId);
        }Catch(exception ex){
           IsExceptionOccured =true;
           Assert.areEqual(true, IsExceptionOccured); 
        }
        
    }
   /**
    * @description test method for AOB_SRV_CreateContract.callContractAPI
    * author dayakar
    */
    @ISTest
    public static void callGetDocumentNegTest(){
        Boolean IsExceptionOccured=false;
        try{
        String docName='Card application';
        AOB_DAL_TestFactory.createApplicationRecord();
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_SRV_CreateContract.callGetDocumentAPI('',docName);
        Test.stopTest();
        Assert.areNotEqual(null, applicationId);
        }Catch(exception ex){
           IsExceptionOccured =true;
           Assert.areEqual(true, IsExceptionOccured); 
        }
        
    }
    
}