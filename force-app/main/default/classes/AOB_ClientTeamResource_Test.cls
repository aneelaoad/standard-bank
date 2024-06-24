/**
 * Created by Caro on 2019-03-29.
 */

@IsTest
private class AOB_ClientTeamResource_Test {

    private static final String

            CC_CIB_USER_NAME        = 'h6enimmarrifi-1816@yopmail.com',
            TB_CIB_USER_NAME        = 'h7enimmarrifi-1817@yopmail.com',
            DEF_ACC_NAME            = 'Def Name for CIB Acc',
            CIF_NUMBER              = '654321';

    @TestVisible
    private static User
            sysAdmin
            ,topParentTB
            ,topParentCC;

    private static ABS_ObjectBuilderBase
            topParentTBM,
            topParentCCM;

    @TestSetup
    static void prepareData() {

        TEST_DataFactory.generateConfiguration();

        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            sysAdmin = (User) new BLD_USER(uow).useSysAdmin().syncContact().getRecord();
            topParentCC = (User) new BLD_USER(uow).userName(CC_CIB_USER_NAME).useCib().syncContact().getRecord();
            topParentTB = (user) new BLD_USER(uow).userName(TB_CIB_USER_NAME).useCib().syncContact().getRecord();
            uow.commitWork();

        }

        System.runAs(topParentCC) {

            BLD_Account existingTopParentCIBAccount =  (BLD_Account) new BLD_Account(uow)
                    .name(DEF_ACC_NAME)
                    .CIF(CIF_NUMBER)
                    .useCib()
                    .useGroupParent()
                    .setField(Account.CIF_Client_Active_Code__c,'Active')
                    .setField(Account.CRT_Parent_Child__c,'TP')
                    .setField(Account.Onboarded_in_SFDC__c,true)
                    .setField(Account.OwnerId, topParentCC.Id)
                    .setField(Account.BillingCountry, 'South Africa')
                    .setField(Account.Industry_Code__c,'65990')
                    .setField(Account.Primary_Relationship_Holder__c, 'Corporate and Investment Banking')
                    .setField(Account.CIF_Client_Type__c, 'W');

            topParentTBM   = new BLD_ClientTeam(uow)
                    .account(existingTopParentCIBAccount)
                    .role(DMN_ClientTeam.ROLE_TRANSACTIONAL_BANKER)
                    .user(topParentTB.Id);


            topParentCCM   = new BLD_ClientTeam(uow)
                    .account(existingTopParentCIBAccount)
                    .role(DMN_ClientTeam.ROLE_MANAGER_CLIENT_COVERAGE)
                    .user(topParentCC.Id);

            uow.commitWork();
        }
    }

    @IsTest
    static void testGetPositiveGetTransactionalBanker() {

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        Test.startTest();
        request.requestURI = '/services/apexrest/ClientTeam';
        request.httpMethod = 'GET';
        request.addParameter('cif', CIF_NUMBER);
        request.addParameter('role', DMN_ClientTeam.ROLE_TRANSACTIONAL_BANKER);
        RestContext.request = request;
        RestContext.response = response;
        ClientTeam testResultClientTeam = AOB_ClientTeamResource.doGet();
        response.addHeader('Content-Type', 'application/json');
        response.responseBody = Blob.valueOf('{"Mock Response":"Mock Values"}');
        Test.stopTest();
        System.assertEquals(1,testResultClientTeam.customClientTeamMembers.totalSize);
        System.assertEquals(DMN_ClientTeam.ROLE_TRANSACTIONAL_BANKER,testResultClientTeam.customClientTeamMembers.records[0].role);
    }

    @IsTest
    static void testGetPositiveGetAllMembers() {

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        Test.startTest();
        request.requestURI = '/services/apexrest/ClientTeam';
        request.httpMethod = 'GET';
        request.addParameter('cif', CIF_NUMBER);
        RestContext.request = request;
        RestContext.response = response;
        ClientTeam testResultClientTeam = AOB_ClientTeamResource.doGet();
        response.addHeader('Content-Type', 'application/json');
        response.responseBody = Blob.valueOf('{"Mock Response":"Mock Values"}');
        Test.stopTest();
        System.assertEquals(2,testResultClientTeam.customClientTeamMembers.totalSize);

    }

}