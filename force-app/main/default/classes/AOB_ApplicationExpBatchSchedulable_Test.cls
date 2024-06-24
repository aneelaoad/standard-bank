@istest
public class AOB_ApplicationExpBatchSchedulable_Test
{

	public static testMethod void testschedule() {
		Test.StartTest();
		AOB_ApplicationExpBatchSchedulable testsche = new AOB_ApplicationExpBatchSchedulable();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}
}