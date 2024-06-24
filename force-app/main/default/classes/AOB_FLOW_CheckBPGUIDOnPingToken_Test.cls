@IsTest
public class AOB_FLOW_CheckBPGUIDOnPingToken_Test {

    /**
    * @description Test setup method to insert all Test data
    */
    @TestSetup
    public static void testSetUp(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUserPing();
        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        System.runAs(admin){
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        }  
    }

    /**
    * Test method for AOB_FLOW_CheckBPGUIDOnPingToken.isBPGUIDOnPing
    */
    @IsTest
    private static void isBPGUIDOnPingTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id, AOB_ExpiryDate__c FROM AOB_Application__c LIMIT 1];
        System.runAs(communityUser){
            Test.StartTest();
            AOB_FLOW_CheckBPGUIDOnPingToken.isBPGUIDOnPing(new List<String>{newApplication.Id});
            Test.StopTest();
        }
        Assert.areNotEqual(null, newApplication);

    }
}