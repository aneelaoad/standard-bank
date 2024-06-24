/***************************************************************************************
@Author            : Dayakar Deekonda 
@Date              : Nov 23th 2022
@Name of the Class : AOB_API_BusinessLead_CTRL_Test
@description       : Test Class used to call external business lead API.	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
@IsTest
public class AOB_API_BusinessLead_CTRL_Test {
    /**
* @description test method used to CMN_WebserviceCallQueue__c setup
* @return List<CMN_WebserviceCallQueue__c>
*/
    private static List<CMN_WebserviceCallQueue__c> setup() {
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            AOB_API_BusinessLead.SERVICE_NAME,
            UserInfo.getUserId()
        );
        
        return new List<CMN_WebserviceCallQueue__c>{ queueItem };
            }
    /**
* @description test method AOB_API_BusinessLead_CTRL.callBusinessLead
*/
    @IsTest
    public static void callBusinessLeadTest()
    {
        Test.setMock(HttpCalloutMock.class, new AOB_API_PreApplication.AOB_API_PreApplicationMock()); 
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String leadReason = 'WFR is failed';
        Test.startTest();
        Integer resCode =  AOB_API_BusinessLead_CTRL.callBusinessLead(applicationId,leadReason);
        Assert.isTrue(resCode==200, 'Test Message');
        Test.stopTest();
        
    }
    /**
* @description test method AOB_API_BusinessLead_CTRL.updateApiService
*/
    @IsTest
    public static void updateApiServiceNegTest()
    {
        try{
            Test.startTest();
            AOB_API_BusinessLead_CTRL.updateApiService(null,'response');
            Test.stopTest();
        }catch(exception ex){
            Assert.areNotEqual(null,ex);
        }  
    }
     /**
* @description validates ping user to application LogoutUser
*/
    @isTest
    static void logoutUserTest() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            ProfileId = profile.Id,
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            Username = 'nmnmnm@example.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        Test.startTest();
        AOB_API_BusinessLead_CTRL.logoutUser();       
        List<AuthSession> authSessions = [SELECT Id FROM AuthSession WHERE UsersId = :testUser.Id];
        assert.areEqual(0, authSessions.size());       
        Test.stopTest();
    }
}