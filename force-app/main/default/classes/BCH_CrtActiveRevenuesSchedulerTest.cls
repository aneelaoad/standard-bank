/**
* @author vipeen Sarode
* @date   October 2022
* @description scheduler Test class of Batch class for deactivating revenues
* @US SFP-18303
******************************************************************************************************************************/
/* MODIFICATION LOG
* Version        	Developer        	  Date             	 	 Description
*------------------------------------------------------------------------------------------------------------------------------
*  1.0         	    Vipeen Sarode		 October 2022        	  Initial Creation     
******************************************************************************************************************************/
@IsTest
public class BCH_CrtActiveRevenuesSchedulerTest {
    /**
     * Test Class Method to cover BCH_CrtActiveRevenuesScheduler and its batch class 
    * @param None
    * @return None
    */
    @IsTest
    static void testExecute() {       
       
        List<Account> accList = test.loadData(Account.sObjectType,'BCH_CrtActiveRevenuesSchedulerTest_DataClient');
        List<FinServ__Revenue__c> revListNew = test.loadData(FinServ__Revenue__c.sObjectType,'BCH_CrtActiveRevenuesSchedulerTest_Data');
		
        Test.StartTest();
        String CRON_EXP = '0 0 0 15 3 ? *';               
        String jobId = System.schedule('Test rev inactivation batch class',  CRON_EXP, new BCH_CrtActiveRevenuesScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();               
    } 
}