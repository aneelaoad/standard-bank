@IsTest
public class SEL_AOBScreen_Test {
     
    /**
	 * @description Test setup method to insert all Test data
	 */
    @TestSetup
    public static void testSetUp(){
        AOB_DAL_TestFactory.createCommunityUser();
    }
    
    /**
	 * Test method for SEL.AOBScreen.getSObjectFieldList
	 * Check that fields are returned correctly
	 */
    @IsTest
    private static void getSObjectFieldList_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        System.runAs(communityUser){
            Test.startTest();
            SEL_AOBScreen scr = new SEL_AOBScreen();
            List<Schema.SObjectField> lst = scr.getSObjectFieldList();
            Test.stopTest();
            
            System.assertNotEquals(0,lst.size(),'successful-fields returned');
        }  
    }
    
    /**
	 * Test method for SEL.AOBScreen.getSObjectType
	 * Check that an sObjectType is returned
	 */
    @IsTest
    private static void getSObjectType_Test(){      
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        System.runAs(communityUser){
            Test.startTest();
            SEL_AOBScreen scr = new SEL_AOBScreen();
            Schema.SObjectType typ = scr.getSObjectType();
            Test.stopTest();
            
            System.assertEquals(AOB_FlowScreen__c.sObjectType,typ);
        }  
    }
    
    /**
	 * Test method for SEL.AOBScreen.selectWithoutCondition
	 * Check that at least one flow screen is returned
	 */
    @IsTest
    private static void selectWithoutCondition_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        
        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true); 
        System.runAs(admin){
            Test.startTest();
            SEL_AOBScreen scr = new SEL_AOBScreen();
            List<AOB_FlowScreen__c> lst = scr.selectWithoutCondition();
            Test.stopTest();
            
            System.assertNotEquals(0,lst.size(),'successful-screen/s returned');
        }  
    }
    
    /**
	 * Test method for SEL.AOBScreen.selectFieldsByName
	 * Check that the created flow screen is returned
	 */
    @IsTest
    private static void selectFieldsByname_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true); 
        System.runAs(admin){
            Test.startTest();
            SEL_AOBScreen scr = new SEL_AOBScreen();
            List<AOB_FlowScreen__c> lst = scr.selectFieldsByName(screen[0].name,AOB_CONSTANTS.LANG_ENG_US);
            Test.stopTest();
            
            System.assertEquals(screen[0].id,lst[0].id);
        }  
    }

}