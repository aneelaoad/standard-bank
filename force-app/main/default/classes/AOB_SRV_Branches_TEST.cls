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
public class AOB_SRV_Branches_TEST {
    
    @TestSetup
    public static void testSetUp(){
        AOB_DAL_TestFactory.createCommunityUser();
    }

    /**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void callGetBranches_Test()
	{ 
        Test.setMock(HttpCalloutMock.class, new AOB_API_GetBranches.AOB_API_GetBranchesMock());
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
           Test.startTest(); 
           List<AOB_API_GetBranches.ETdata8_Multi> branches=AOB_SRV_Branches.callGetBranches('fakeToken');
           Test.stopTest(); 
           Assert.areNotEqual(branches,null);
		}
    }
    
    /**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void insertBranches_Test()
	{ 
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
           List<AOB_API_GetBranches.ETdata8_Multi> Branches=(List<AOB_API_GetBranches.ETdata8_Multi>)JSON.deserialize('[{"ETdata8_Code":"223","ETdata8_Description":"LIBRARY GARDENS"},{"ETdata8_Code":"250","ETdata8_Description":"MIDRAND"},{"ETdata8_Code":"276","ETdata8_Description":"WOODMEAD"}]',List<AOB_API_GetBranches.ETdata8_Multi>.class);//AOB_SRV_Branches.callGetBranches('test');
           Test.startTest(); 
           AOB_SRV_Branches.insertBranches(Branches);
           Test.stopTest();
           Assert.areEqual([select id from AOB_ReferencedData__c where AOB_SAPField__c='BRANCH'].size(),3);
        }
    }
}