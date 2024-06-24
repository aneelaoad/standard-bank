/**
 * @description Test class for AOB_SCHED_IndustryPicklistJob
 * 
 * @author Narendra Teja
 *
 * @date April 14th 2023
 */
@IsTest(SeeAllData=false) 
public class AOB_SCHED_IndustryPicklistJob_TEST {
    
    /**
	 * @description Emulates a successful call for AOB_SCHED_IndustryPicklistJob
	 */
	@IsTest
	private static void updateReferencedDataTest()
	{ 
        try {
            Test.startTest();  
            AOB_SCHED_IndustryPicklistJob scheduler = new AOB_SCHED_IndustryPicklistJob(); 
            String sch ='0 48 * * * ?'; 
            String jobId=System.schedule('Schedule to update Referenced data', sch,scheduler);
            Test.stopTest(); 
        }catch (Exception ex) {
            Assert.areNotEqual(null, ex);
        }        
    }
}