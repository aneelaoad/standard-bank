@isTest
public with sharing class SEL_AOBField_Test {
  
    /**
	 * @description Test setup method to insert all Test data
	 */
    @TestSetup
    public static void testSetUp(){
        AOB_DAL_TestFactory.createCommunityUser();
    }
    
    /**
	 * Test method for SEL.AOBField.getSObjectFieldList
	 * Check that fields are returned correctly
	 */
    @IsTest
    private static void getSObjectFieldList_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        System.runAs(communityUser){
            Test.startTest();
            SEL_AOBField fld = new SEL_AOBField();
            List<Schema.SObjectField> lst = fld.getSObjectFieldList();
            Test.stopTest();
            
            System.assertNotEquals(0,lst.size());
        }  
    }
    
    /**
	 * Test method for SEL.AOBField.getSObjectType
	 * Check that an sObjectType is returned
	 */
    @IsTest
    private static void getSObjectType_Test(){      
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        System.runAs(communityUser){
            Test.startTest();
            SEL_AOBField fld = new SEL_AOBField();
            Schema.SObjectType typ = fld.getSObjectType();
            Test.stopTest();
            
            System.assertEquals(AOB_Field__c.sObjectType,typ);
        }  
    }
    
    /**
	 * Test method for SEL.AOBField.selectWithoutCondition
	 * Check that at least one field is returned
	 */
    @IsTest
    private static void selectWithoutCondition_Test(){
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> section = AOB_DAL_TestFactory.createSection(screen[0].id);        
        list<AOB_field__c> field = AOB_DAL_TestFactory.createFields(section[0].id);
        
        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        
        System.runAs(admin){
            Test.startTest();
            SEL_AOBField fld = new SEL_AOBField();
            List<AOB_Field__c> lst = fld.selectWithoutCondition();
            System.assertNotEquals(0,lst.size());
            Test.stopTest();
            
            
        }  
    }
    
     /**
	 * Test method for SEL.AOBField.selectFieldsBySection
	 * Check that at least one field is returned
	 */
    @IsTest
    private static void selectFieldsBySection_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> section = AOB_DAL_TestFactory.createSection(screen[0].id);        
        list<AOB_field__c> field = AOB_DAL_TestFactory.createFields(section[0].id);
        
        Set<Id> ids = (new Map<id,AOB_ScreenSection__c>(section)).keySet();

        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        
        System.runAs(admin){
            Test.startTest();
            SEL_AOBField fld = new SEL_AOBField();
            List<AOB_Field__c> lst = fld.selectFieldsBySection(ids);
            Test.stopTest();
            
            System.assertNotEquals(0,lst.size());
        }  
    }
    
     /**
	 * Test method for SEL.AOBField.selectMRITables
	 * Check that MRI tables are returned
	 */
    @IsTest
    private static void selectMRITables_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> section = AOB_DAL_TestFactory.createSection(screen[0].id);        
        list<AOB_field__c> field = AOB_DAL_TestFactory.createFields(section[0].id);
        list<AOB_referencedData__c> ref = AOB_DAL_TestFactory.createRefData();
        
        Set<Id> ids = (new Map<id,AOB_ScreenSection__c>(section)).keySet();

        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        
        System.runAs(admin){
            Test.startTest();
            SEL_AOBField fld = new SEL_AOBField();
            List<AOB_Field__c> lst = fld.selectMRITables(ids);
             System.assertNotEquals(0,lst.size());
            Test.stopTest();
            
           
        }  
    }
    
    /**
	 * Test method for SEL.AOBField.selectMRITablesByLanguage
	 * Check that MRI tables are returned
	 */
    @IsTest
    private static void selectMRITablesByLanguage_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> section = AOB_DAL_TestFactory.createSection(screen[0].id);        
        list<AOB_field__c> field = AOB_DAL_TestFactory.createFields(section[0].id);
        list<AOB_referencedData__c> ref = AOB_DAL_TestFactory.createRefData();
        
        Set<Id> ids = (new Map<id,AOB_ScreenSection__c>(section)).keySet();

        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        
        System.runAs(admin){
            Test.startTest();
            SEL_AOBField fld = new SEL_AOBField();
            List<AOB_Field__c> lst = fld.selectMRITablesByLanguage(ids,AOB_CONSTANTS.LANG_ENG_US);
             System.assertNotEquals(0,lst.size());
            Test.stopTest();
            
           
        }  
    }
}