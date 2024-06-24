/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
*
* Test Class for AOB_ProductResource class.
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Caro Reinecke
* @version        1.0
* @created        2018-02-20
* @systemLayer    Test ( Choose from: Invocation | Service | Utility | Selector | Domain | Test )
* @description Test class for AOB_ProductResource
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@IsTest
private class AOB_ProductResource_Test {

    private static final String USER_NAME = 'henimmarrifi-1815@yopmail.com';
    private static User aobUser {
        get {
            if (aobUser == null) {
                aobUser = [SELECT Id FROM User WHERE UserName = :USER_NAME];
            }
            return aobUser;
        }
    }

    @TestSetup
    static void setup() {
        new BLD_USER(USER_NAME)
                .useAPIUser()
                .commitWork();
        System.runAs(aobUser) {

            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            BLD_AOB_Product testProduct = new BLD_AOB_Product(uow);

            uow.commitWork();

        }
    }

    @IsTest
    static void testBehavior() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='/services/apexrest/Product';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        List<AOB_Products__c> products = AOB_ProductResource.doGet();
        Test.stopTest();
        System.assert(!products.isEmpty());
    }
}