@IsTest
public class SEL_AOBSection_Test {
	
    /**
	 * @description Test setup method to insert all Test data
	 */
    @TestSetup
    public static void testSetUp(){
        AOB_DAL_TestFactory.createCommunityUser();
    }
    
    /**
	 * Test method for SEL.AOBSection.getSObjectFieldList
	 * Check that fields are returned correctly
	 */
    @IsTest
    private static void getSObjectFieldList_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        System.runAs(communityUser){
            Test.startTest();
            SEL_AOBSection sec = new SEL_AOBSection();
            List<Schema.SObjectField> lst = sec.getSObjectFieldList();
            System.assertNotEquals(0,lst.size(),'successful-fields returned');
            Test.stopTest();
            
            
        }  
    }
    
    /**
	 * Test method for SEL.AOBSection.getSObjectType
	 * Check that an sObjectType is returned
	 */
    @IsTest
    private static void getSObjectType_Test(){      
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        System.runAs(communityUser){
            Test.startTest();
            SEL_AOBSection sec = new SEL_AOBSection();
            Schema.SObjectType typ = sec.getSObjectType();
            System.assertEquals(AOB_ScreenSection__c.sObjectType,typ);
            Test.stopTest();
            
            
        }  
    }
    
    /**
	 * Test method for SEL.AOBSection.selectWithoutCondition
	 * Check that at least one application is returned
	 */
    @IsTest
    private static void selectWithoutCondition_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> sections = AOB_DAL_TestFactory.createSection(screen[0].Id);
        
        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        System.runAs(admin){
            Test.startTest();
            SEL_AOBSection sec = new SEL_AOBSection();
            List<AOB_ScreenSection__c> lst = sec.selectWithoutCondition();
             System.assertNotEquals(0,lst.size(),'successful-section/s returned');
            Test.stopTest();
            
           
        }  
    }
   
    
    /**
	 * Test method for SEL.AOBSection.selectSectionsByScreenName
	 * Check that the screen sections are returned
	 */
    @IsTest
    private static void selectSectionsByScreenName_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> sections = AOB_DAL_TestFactory.createSection(screen[0].Id);
        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        System.runAs(admin){
            Test.startTest();
            SEL_AOBSection sec = new SEL_AOBSection();
            List<AOB_ScreenSection__c> lst = sec.selectSectionsByScreenName(screen[0].name,AOB_CONSTANTS.LANG_ENG_US);
            System.assertEquals(sections[0].id,lst[0].id);
            Test.stopTest();
            
            
        }  
    }

}