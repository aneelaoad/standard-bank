/**
* Test class for CMN_TRG_JobSchedule
* 
* <p>DPB-1156</p> 
* 
* @author Salesforce
* 
* @date Nov 10th 2021 
*/
@IsTest
public class CMN_TRG_JobSchedule_Test {

	private static final String NO_EXCEPTION_WAS_THROWN_AS_EXPECTED = 'No exception was thrown as expected';
	private static final String ERROR_WAS_THROWN_AS_EXPECTED = 'Error was thrown as expected';
     /**
    * @description Test setup method to insert a job scheduler
    */
    @IsTest
    public static void insertJobScheduler(){
    	try
		{
			Test.startTest();

			CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.newJobScheduler(CMN_SCHED_Foobar.class.getName());
			scheduler.CMN_CronExpression__c = CMN_DAL_SObjectDomain.generateRandomName();

			insert scheduler;

			Test.stopTest();

			System.assert(false, NO_EXCEPTION_WAS_THROWN_AS_EXPECTED);
		}
		catch(Exception error)
		{
			System.assert(true, ERROR_WAS_THROWN_AS_EXPECTED);
		}
    }
}