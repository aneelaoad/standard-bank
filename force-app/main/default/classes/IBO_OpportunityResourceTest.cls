/**
 * IB Online Opportunity api test class for IBO_OpportunityService
 * US-4660
 *
 * @author Wayne Solomon
 * @date 28 Apr 2020
 */
@IsTest
class IBO_OpportunityResourceTest {

    static final String
            TEST_USER_NAME          = 'stdBank@nbac.com1',
            DEF_ACC_NAME            = 'Def Name for Acc';
    static User usrOwner;
    final static String cif = '100105118';

    @TestSetup
    static void prepareData() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        System.runAs(new User(Id = UserInfo.getUserId())){
            usrOwner = (User)new BLD_USER(uow).userName(TEST_USER_NAME).useCib().syncContact().getRecord();
            uow.commitWork();
        }
        Test.startTest();Test.stopTest();
        System.runAs(usrOwner){
            BLD_Account ugpClientBld	= new BLD_Account(uow).name(DEF_ACC_NAME).useCib().useGroupParent().CIF(cif);
            BLD_Opportunity opportunityBld = new BLD_Opportunity(uow).develop().client(ugpClientBld).currency(UTL_Currency.corporateIsoCode);
            uow.commitwork();
        }
    }

    @isTest
    static void testGetOppsWithCif() {
        getUsers();
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        Test.startTest();
        System.runAs(usrOwner){
            request.requestUri = '/services/apexrest/ibo/v1/opportunities';
            request.addParameter('cif',cif);
            request.httpMethod = 'GET';
            RestContext.request = request;
            RestContext.response = response;
            IBO_OpportunityResource.doGet();
        }
        Test.stopTest();
        System.assertEquals(200,response.statusCode);
    }

    @isTest
    static void testGetOppsWithNoParam() {
        getUsers();
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        Test.startTest();
        System.runAs(usrOwner){
            request.requestUri = '/services/apexrest/ibo/v1/opportunities';
            request.httpMethod = 'GET';
            RestContext.request = request;
            RestContext.response = response;
            IBO_OpportunityResource.doGet();
        }
        Test.stopTest();
        System.assertEquals(400,response.statusCode);
    }

    static void getUsers(){
        for(User u : [  SELECT Username FROM User
        WHERE UserName in: (new String[]{TEST_USER_NAME})]){
            if(u.UserName == (TEST_USER_NAME)){
                usrOwner = u;
            }
        }
    }
}