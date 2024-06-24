/**
 * Test class for MC_EmailProof_Connector class
 *
 * @author		Michal Pesko (mpesko@deloittece.com)
 * @date		December 2020
 */
@IsTest
public with sharing class MC_EmailProof_Connector_TEST {
    public static final String TOKEN = 'gEnErAtEdToKeN123';
    private static final String USERNAME='pesko.testUserApi123@example.com';
    private static User apiUser {
        get {
            if (apiUser == null) {
                apiUser = [SELECT Id, Email FROM User WHERE Username = :USERNAME];
            }
            return apiUser;
        }
        set;
    }

    @TestSetup
    private static void setupData() {
        TEST_DataFactory.insertSettings(TEST_DataFactory.getSbParameters());
        System.runAs(new User(Id = UserInfo.getUserId())) {
            new BLD_USER(USERNAME).useAPIUser().commitWork();
        }
    }

    @IsTest
    public static void shouldGetAuthToken(){
        String mockBody = '{"access_token": "' + TOKEN + '"}';
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', mockBody, null));
        String tokenFromCallout;
        System.runAs(apiUser) {
            Test.startTest();
            tokenFromCallout = MC_EmailProof_Connector.getAuthToken();
            Test.stopTest();
        }
        System.assertEquals(TOKEN, tokenFromCallout);
    }

    @IsTest
    public static void shouldPostEmailProof(){
        String mockBody = '{"access_token": "' + TOKEN + '"}';

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', mockBody, null));
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Campaign campaign = (Campaign)new BLD_Campaign(uow).name('testCampaign').type('Client Research').getRecord();

        MC_EmailProofData mcEmailProofData = new MC_EmailProofData(campaign.Id, campaign.Type, apiUser.Email, apiUser.Id);

        System.runAs(apiUser) {
            Test.startTest();
            System.assertEquals('OK', MC_EmailProof_Connector.postEmailProof(mcEmailProofData));
            Test.stopTest();
        }
    }
}