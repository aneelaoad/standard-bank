/**
 *@description : CTRL_MallCommunitiesLandingTest
 *@author Ankit Kumar
 */
@Istest 
public with sharing class CTRL_MallCommunitiesLandingTest {
    @IsTest
    public static void testCommunitiesLandingController() {
        User u = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];     
        System.runAs(u) {
            User testUser = MallTestDataFactory.createCommunityUser(u, System.Label.Store_Manager_Profile);
            Provider__c provider = new Provider__c();
            provider.Name = 'Provider test1';
            provider.Related_Client__c = testUser.AccountId;
            insert provider;
            System.runAs(testUser) {
                CTRL_MallCommunitiesLanding controller = new CTRL_MallCommunitiesLanding();
                CTRL_MallCommunitiesLanding.firstTimeUserLogin(testUser.id);
                Assert.areEqual(controller.isTenant, 'true', 'a tenant');
        	}
        }
    }
}