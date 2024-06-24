@isTest
    public class AOB_CTRL_SaveForLater_TEST {
    
    /**
     * @description Test setup method to insert all Test data
     */
     @TestSetup
     public static void testSetUp(){
         AOB_DAL_TestFactory.createCommunityUser();    
    }

    /**
       * @description gets the current application record Test
       *
       */
    @isTest
    public static void getApplicationNameTest() {

        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];

        AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplication(communityUser);

        Test.startTest();
        AOB_Application__c app = AOB_CTRL_SaveForLater.getApplicationName(newApplication.Id);
        Test.stopTest();
        System.assertNotEquals(null, app.Name);
    }
    
    /**
       * @description gets the current application record Test
       *
       */
    @isTest
    public static void updateApplicationToInProgressStatusTest() {
        
       User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
 
       AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplication(communityUser);

       Test.startTest();
       AOB_CTRL_SaveForLater.updateApplicationToInProgressStatus(newApplication.Id);
       Test.stopTest();
       
       AOB_Application__c appAfter = [
          SELECT Id, AOB_Status__c
          FROM AOB_Application__c
          WHERE Id = :newApplication.Id
      ];
      System.assertEquals('In Progress', appAfter.AOB_Status__c);
    
   }
}