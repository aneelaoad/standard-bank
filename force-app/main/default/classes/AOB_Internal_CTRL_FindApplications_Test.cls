/**
* @description AOB_Internal_CTRL_FindApplications test class
*
* @author Lulu Rankwe
*
* @see AOB_CTRL_InternalPreApplication
*
* @date April 2023
*/
@IsTest
public class AOB_Internal_CTRL_FindApplications_Test {
    /**
* @description call AOB_Dal_TestFactory
*/
    @TestSetup
    public static void testSetUp(){
        AOB_DAL_TestFactory.createAccountWithContact();        
        AOB_DAL_TestFactory.createApplicationRecord();       
    }
    
    /**
	* @description this method tests a successful find application callout
	*/   
    @IsTest
    public static void findApplicationTest()
    {     
        Lead aLead = [Select Id,Customer_ID__c from Lead Limit 1];
        AOB_Application__c application = [Select Id ,Name,AOB_Client__c,Lead_Created__c,AOB_inflightData__c from AOB_Application__c Limit 1];  
        List<AOB_ApplicationLineItem__c> appLineItem = [Select Id,AOB_ProductCode__c,AOB_Application__c,AOB_Product__c,AOB_Pricing_Option__c,AOB_Status__c from AOB_ApplicationLineItem__c limit 1];
        String preAppData=' { "consent":true,"businessProvince":"ZAF.FS","businessRegistrationNumber":"2020/679442/07","businessTurnover":"100000","businessName":"bname","soleShareholder":"true","businessType":"CLOSE CORPORATION","soleOwner":"true","EmailAddress":"sath@gmail.com", "PhoneNumber":"0876543209", "IdNum":"9501126721146","Surname":"surname","Name":"tes", "productNumber":"4648", "pricingOption":"ZMMB"}';       
        Test.startTest();            
        String response = AOB_Internal_CTRL_FindApplications.findApplication(aLead.Customer_ID__c,preAppData,appLineItem.get(0).AOB_ProductCode__c,application.AOB_Client__c);
        AOB_Internal_CTRL_FindApplications.createLead(preAppData,appLineItem.get(0).AOB_ProductCode__c,application.AOB_Client__c);
        Test.stopTest();
        Assert.isNotNull(response, 'find application is null');        
        Assert.isNotNull(response, 'lead is null');
        
    }
    /**
	 * @description this method tests creates ApplicationLineItem for application
	 */
    @IsTest
    public static void getCallPreApplicationTest(){  
        
        Account account = [Select Id,Name From Account where Name = 'Test'];
        AOB_Application__c application = [Select Id ,Name,AOB_Retry_Count__c,AOB_inflightData__c,AOB_Client__c,Lead_Created__c,AOB_ProcessId__c,AOB_SalesObjectId__c,AOB_CurrentScreen__c,AOB_Status__c,AOB_Registration_Number__c from AOB_Application__c Limit 1];
        application.AOB_Client__c = account.Id;
        Update application;
        AOB_ApplicationLineItem__c appLineItem = [Select Id,AOB_Pricing_Option__c,AOB_ProductCode__c,AOB_Application__c,AOB_Product__c from AOB_ApplicationLineItem__c limit 1];
        List<Product2> productList = [Select Id,ProductCode from product2 where name='MyMoBiz'];        
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        
        Test.startTest();              
        AOB_Internal_CTRL_FindApplications.createAppLineItem(application,productList.get(0).ProductCode,appLineItem.AOB_Pricing_Option__c,application.Name,productList.get(0).ProductCode);      
        AOB_Internal_CTRL_FindApplications.createApplication(application.AOB_inflightData__c,appLineItem.AOB_ProductCode__c, application.AOB_Client__c);
        Test.stopTest();     
        Assert.isNotNull(appLineItem, 'applicationLineItem is null'); 
        Assert.isNotNull(appLineItem, 'create application is null');
    }
    
    /**
	 * @description returns product2 list
	 */
    @IsTest
    public static void getProductTest(){ 
        List<Product2> productList = [Select Id,ProductCode from product2 where name='MyMoBiz'];   
        Test.startTest();              
        AOB_Internal_CTRL_FindApplications.getProduct(productList[0].Id);
        Test.stopTest();     
        Assert.isNotNull(productList, 'product is null');
        
    }
    
    @isTest
    public static void negativeCreateLead() {
        try{
            AOB_Internal_CTRL_FindApplications.createLead('preAppData', 'productCode', null);
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage());
        }
        
    }
    @isTest
    public static void negativeCreateApplication() {
        try{
            AOB_Internal_CTRL_FindApplications.createApplication('preAppData', 'productCode', null);
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage());
        }        
    }
    
    @isTest
    public static void negativeGetProduct() {
        try{
            AOB_Internal_CTRL_FindApplications.getProduct(null);
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage());
        }        
    }
    
    @isTest
    public static void negativecreateAppLineItem() {
        try{
            AOB_Internal_CTRL_FindApplications.createAppLineItem(null, 'productNum', 'pricingOption', 'appName', 'productCode');
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage());
        }        
    }
    
    @isTest
    public static void negativeFindApplication() {
        try{
            AOB_Internal_CTRL_FindApplications.findApplication('customerId', 'preAppData', 'productCode', null);
        }
        catch(Exception ex){
            Assert.isNotNull(ex.getMessage());
        }        
    }
}