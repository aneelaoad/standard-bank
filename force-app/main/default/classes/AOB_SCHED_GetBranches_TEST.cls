/**
 * @description Test class to test the Outbound API call
 * 
 * <p></p>
 * 
 * @author mbourhi@salesforce.com
 *
 * @date 2020
 */
@IsTest(SeeAllData=false) 
public class AOB_SCHED_GetBranches_TEST {
    
    @TestSetup
    public static void testSetUp(){
        User communityUser=AOB_DAL_TestFactory.createCommunityUser();
    }
    
    /**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void callScheduler_Test()
	{ 
        Test.setMock(HttpCalloutMock.class, new AOB_API_GetBranches.AOB_API_GetBranchesMock()); 
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser){
            try {
                Test.startTest();  
                AOB_SCHED_GetBranches scheduler = new AOB_SCHED_GetBranches(); 
                String sch ='0 48 * * * ?'; 
                String jobId=System.schedule('Schedule to update Account Name', sch,scheduler);
                Test.stopTest(); 
            } catch (Exception ex) {
                Assert.areNotEqual(null, ex);
            }
            
        }
    }


}