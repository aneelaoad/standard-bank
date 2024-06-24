/**
* @description Test class to test the Outbound Complete Application API 
* @author Dayakar
*/
@isTest
public class AOB_API_CompleteApplication_TEST
{
  /**
   * @description test method for AOB_SRV_CompleteApplication.callCompleteApplicationAPI
   * author dayakar
   */ 
   @ISTEST
   public static void callCompleteApplication_Test()
   {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        String responsedata=AOB_SRV_CompleteApplication.callCompleteApplicationAPI(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, responsedata);
   }
    
   /**
   * @description test method for AOB_SRV_CompleteApplication.callCompleteApplicationAPI
   * author dayakar
   */ 
   @ISTEST
   public static void callCompleteApplicationNeg_Test()
   {
       try{
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_SRV_CompleteApplication.callCompleteApplicationAPI('');
        Test.stopTest();  
       }Catch(exception e){
           Assert.areNotEqual(null, e);
       }
       
   } 
    
}