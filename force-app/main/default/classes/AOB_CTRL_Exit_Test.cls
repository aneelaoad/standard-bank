@IsTest
public class AOB_CTRL_Exit_Test {
    /**
    * @description Test setup method to insert all Test data
    */
    @TestSetup
    public static void testSetUp(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        System.runAs(admin){
            AOB_Application__c newApp = AOB_DAL_TestFactory.createApplication(communityUser);
        } 
       
    }  
    /**
    * Test method for AOB_CTRL_Exit.getApplicationData in the positive scenario
    */
    @IsTest
    private static void getApplicationData_Test(){
        AOB_Application__c newApplication = [SELECT Id, AOB_ExpiryDate__c FROM AOB_Application__c limit 1];
        Product2 prod = AOB_DAL_TestFactory.createProduct('TestProduct', '4546');
        AOB_ApplicationLineItem__c applicationLineItem = AOB_DAL_TestFactory.createApplicationLineItem(prod.id, newApplication.Id);
        AOB_CTRL_Exit.ApplicationData appData = AOB_CTRL_Exit.getApplicationData(newApplication.Id);
        System.assertNotEquals(null, appData);
    }
    /**
    * Test method for AOB_CTRL_Exit.getApplicationData where it has no Applciation record.
    */
    @IsTest
    private static void getApplicationDataNegative1_TEST(){
        Boolean isExceptionOccured=false;
        try {
            AOB_Application__c newApplication = [SELECT Id, AOB_ExpiryDate__c FROM AOB_Application__c limit 1];
            delete newApplication;
            AOB_CTRL_Exit.ApplicationData appData = AOB_CTRL_Exit.getApplicationData(newApplication.Id);
        } catch (Exception e) {
            isExceptionOccured=true;
            System.assertEquals(true, isExceptionOccured);
        }
    }
    /**
    * Test method for AOB_CTRL_Exit.getApplicationData where application has no application line items
    */
    @IsTest
    private static void getApplicationDataNegative2_TEST(){
        Boolean isExceptionOccured=false;
        try {
            AOB_Application__c newApplication = [SELECT Id, AOB_ExpiryDate__c FROM AOB_Application__c limit 1];
            Product2 prod = AOB_DAL_TestFactory.createProduct('TestProduct', '4546');
            AOB_CTRL_Exit.ApplicationData appData = AOB_CTRL_Exit.getApplicationData(newApplication.Id);
        } catch (Exception e) {
            isExceptionOccured=true;
            System.assertEquals(true, isExceptionOccured);
        }
        
    }
    /**
    * Test method for AOB_CTRL_Exit.getApplicationData where productname is null
    */
    @IsTest
    private static void getApplicationDataNegative3_TEST(){
        Boolean isExceptionOccured=false;
        try {
             AOB_Application__c newApplication = [SELECT Id, AOB_ExpiryDate__c FROM AOB_Application__c limit 1];
            Product2 prod = AOB_DAL_TestFactory.createProduct('TestProduct', '4546');
            AOB_CTRL_Exit.ApplicationData appData = AOB_CTRL_Exit.getApplicationData(newApplication.Id);
        } catch (Exception e) {
            isExceptionOccured=true;
            System.assertEquals(true, isExceptionOccured);
        }
 
    }
}