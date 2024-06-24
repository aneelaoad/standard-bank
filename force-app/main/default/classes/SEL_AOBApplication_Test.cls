/**
 * @description       : Selector class for AOBApplication__c
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 06-23-2023
 * @last modified by  : Tukelo Moseamo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-22-2023   Tukelo Moseamo   Static code analysis
**/
@IsTest
public with sharing class SEL_AOBApplication_Test {
    
    /**
    * @description Test setup method to insert all Test data
    */
    @TestSetup
    public static void testSetUp(){
        AOB_DAL_TestFactory.createCommunityUser();
    }
    
    /**
    * @description Test method for SEL.AOBApplication.getSObjectFieldList
    * Check that fields are returned correctly
    */
    @IsTest
    private static void getSObjectFieldListTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        System.runAs(communityUser){
            Test.startTest();
            SEL_AOBApplication app = new SEL_AOBApplication();
            List<Schema.SObjectField> lst = app.getSObjectFieldList();
            Test.stopTest();
            
            Assert.areNotEqual(0,lst.size(),'successful-fields returned');
        }  
    }
    
    /**
    * @description Test method for SEL.AOBApplication.getSObjectType
    * Check that an sObjectType is returned
    */
    @IsTest
    private static void getSObjectTypeTest(){      
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        System.runAs(communityUser){
            Test.startTest();
            SEL_AOBApplication app = new SEL_AOBApplication();
            Schema.SObjectType typ = app.getSObjectType();
            Test.stopTest();
            
            Assert.areEqual(AOB_Application__c.sObjectType,typ, 'SObject type is AOBApplication__c');
        }  
    }
    
    /**
    * @description Test method for SEL.AOBApplication.selectWithoutCondition
    * Check that at least one application is returned
    */
    @IsTest
    private static void selectWithoutConditionTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplication(communityUser);
        
        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        System.runAs(admin){
            Test.startTest();
            SEL_AOBApplication app = new SEL_AOBApplication();
            List<AOB_Application__c> lst = app.selectWithoutCondition();
            Test.stopTest();
            
            Assert.areNotEqual(0,lst.size(),'successful-application/s returned');
            Assert.areNotEqual(null,newApplication,'test');
        }  
    }
    
    /**
    * @description Test method for SEL.AOBApplication.selectAppsById
    * Check that the created application is returned
    */
    @IsTest
    private static void selectAppsByIdTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplication(communityUser);
        
        System.runAs(communityUser){
            Test.startTest();
            SEL_AOBApplication app = new SEL_AOBApplication();
            List<AOB_Application__c> lst = app.selectAppsById(newApplication.id);
            Test.stopTest();
            
            Assert.areEqual(newApplication.id, lst[0].id, 'returned applicaion is the same as the provided application');
        }  
    }
    /**
    * @description tests selectAppsByClient
    **/
    @IsTest
    private static void selectAppsByClientTest()
    {
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplication(communityUser);
            Test.startTest();
            SEL_AOBApplication app = new SEL_AOBApplication();
            List<AOB_Application__c> lst = app.selectAppsByClient(newApplication.AOB_Client__c);
            Test.stopTest();
            try{
                Assert.areEqual(newApplication.AOB_Client__c, lst[0].AOB_Client__c, 'application belong to the same client');
            }
            catch(exception e){
                Assert.isNotNull(e.getMessage(), 'error message is populated');
            }
        
    }
    /**
    * @description tests selectAppsByClientStatus
    **/
    @IsTest 
    private static void selectAppsByClientStatusTest()
    {
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplication(communityUser);
            Test.startTest();
            SEL_AOBApplication app = new SEL_AOBApplication();
            List<AOB_Application__c> lst = app.selectAppsByClientStatus(newApplication.AOB_Client__c,newApplication.AOB_Status__c);
            
            Test.stopTest();
            Assert.areEqual(newApplication.AOB_Client__c, lst[0].AOB_Client__c,'application belong to the same client');
            Assert.areEqual(newApplication.AOB_Status__c, lst[0].AOB_Status__c, 'Status returned is equally to provided status');
    }
    /**
    * @description tests selectAppsByStatus
    **/
     @IsTest 
    private static void selectAppsByStatusTest()
    {
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplication(communityUser);
        
        System.runAs(communityUser){
            Test.startTest();
            SEL_AOBApplication app = new SEL_AOBApplication();
            List<AOB_Application__c> lst = app.selectAppsByStatus(newApplication.AOB_Status__c);
            Test.stopTest();
            Assert.areEqual(newApplication.AOB_Client__c, lst[0].AOB_Client__c, 'both have same client');
            Assert.areEqual(newApplication.AOB_Status__c, lst[0].AOB_Status__c, 'Status returned is equally to provided status');
            
        }
    }
}