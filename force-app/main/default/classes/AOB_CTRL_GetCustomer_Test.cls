/**
 * @description Class for API call Get Customer API Test
 * @author dayakar
 * @date jan 02 2023
 */
@IsTest
public class AOB_CTRL_GetCustomer_Test {
    /**
    * @description test method for AOB_CTRL_GetCustomer.getCustomer
    * author dayakar
    */
    @IsTest
    public static void getCustomerTest(){
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            Test.startTest();
            AOB_CTRL_GetCustomer.getCustomer(applicationId);
            Test.stopTest(); 
        }Catch(Exception e){
            Assert.areNotEqual(null, e,'Message');
        }  
    }
    
    /**
    * @description test method for AOB_CTRL_GetCustomer.getCustomer
    * author dayakar
    */
    @IsTest
    public static void getCustomerNegTest(){
        Boolean isFailing=false;
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            Test.startTest();
            AOB_CTRL_GetCustomer.getCustomer(applicationId);
            Test.stopTest(); 
        }Catch(Exception e){
            isFailing=true;
            Assert.areEqual(true, isFailing,'Message');    
        }
    }
    
    
    /**
    * @description test method for AOB_CTRL_GetCustomer.getCustomerBeforeMarketing
    * author dayakar
    */
    @IsTest
    public static void getCustomerBeforeMarketingTest(){
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            Test.startTest();
            AOB_CTRL_GetCustomer.getCustomerBeforeMarketing(applicationId);
            Test.stopTest(); 
        }Catch(Exception e){
            Assert.areNotEqual(null, e,'Message');
        }  
    }
    
    /**
    * @description test method for AOB_CTRL_GetCustomer.getCustomerBeforeMarketing
    * author dayakar
    */
    @IsTest
    public static void getCustomerBeforeMarketingNegTest(){
        Boolean isFailing=false;
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            Test.startTest();
            AOB_CTRL_GetCustomer.getCustomerBeforeMarketing(applicationId);
            Test.stopTest(); 
        }Catch(Exception e){
            isFailing=true;
            Assert.areEqual(true, isFailing,'Message');    
        }
    }
}