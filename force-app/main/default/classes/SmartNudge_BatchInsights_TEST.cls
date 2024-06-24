/**
 * @author		: Chandrasekhar Mokkala
 * @description : Test class for SmartNudge_BatchInsightsInMyPortfolio
 * @date 		: 15th August 2022
 */
@isTest
public class SmartNudge_BatchInsights_TEST {
	/**
     * @description :  This method will test for more than 10 insights scenario
     */
    @isTest
    static void myLatestInsightsTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,User_CIB_Global_Area__c = 'Africa Regions', User_Division__c = 'Base Division', 
                           Business_Unit__c = 'Research', Country = 'South Africa',  state = 'test', City = 'south Africa', 
                           TimeZoneSidKey='America/Los_Angeles', UserName='newuser11@testorg.com');
        insert u2;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Akili_Insights_Access'];
		insert new PermissionSetAssignment(AssigneeId = u2.Id, PermissionSetId = ps.Id);
        
        Test.startTest();
        System.runAs(u2) {
            List<Schema.SObjectType> MY_SOBJECTS = new Schema.SObjectType[]{Insight__c.SObjectType};
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(MY_SOBJECTS);
    
            BLD_Insight bAccount = new BLD_Insight(uow).category('FX TIPS');
            bAccount.owner(UserInfo.getUserId());
            bAccount.snoozed(false);
            bAccount.eventDate(Date.today());
            bAccount.insight('Test Insight');
            bAccount.clientCoordinator(UserInfo.getUserId());
            uow.commitWork();
                SmartNudge_BatchInsightsInMyPortfolio sch = new SmartNudge_BatchInsightsInMyPortfolio();
                String chroneExpression = '0 0 23 * * ?'; 
                System.schedule('My latest insights', chroneExpression, sch);
            
            Test.stopTest();
            System.assert(bAccount != null, 'Was expecting to find at least one insight');
    	}	
    }
}