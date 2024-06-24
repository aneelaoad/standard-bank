/**
* Test class for AOB_CTRL_BeforeWeBegin
* 
* 
* 
* @author Salesforce
* 
* @date Nov 3rd 2021 
*/
@IsTest
public with sharing class AOB_CTRL_BeforeWeBegin_Test {
    
    /**
    * @description Test setup method to insert all Test data
    */
    @TestSetup
    public static void testSetUp(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        System.runAs(admin){
            AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplication(communityUser);
            Product2 newProduct = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME,'ZTCC');
            AOB_ApplicationLineItem__c newApplicationLineItem = AOB_DAL_TestFactory.createApplicationLineItem(newProduct.Id, newApplication.Id);
            AOB_ProductAOContent__c newRequiredDocument = AOB_DAL_TestFactory.createAOContent(newProduct.Id, AOB_TestConstants.REQUIRED_DOC_DESCRIPTION, AOB_TestConstants.REQUIRED_DOC_HELPTEXT, AOB_TestConstants.REQUIRED_DOC_ORDER);
        }
    }
    /**
    * Test method for AOB_CTRL_BeforeWeBegin.getRelatedProducts
    */
    @IsTest 
    private static void getRelatedProductsTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT id FROM AOB_Application__c LIMIT 1];
        System.runAs(communityUser){
            Test.startTest();
            List<AOB_ProductAOContent__c> productContent = AOB_CTRL_BeforeWeBegin.getRelatedProducts(newApplication.Id);
            Test.stopTest();
            System.assertEquals(1, productContent.size());
        }  
    }
    
}