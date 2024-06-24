/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
*
* Test Class for AOB_LegalEntityHierarchyResource class
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Caro Reinecke
* @version        1.0
* @created        2018-02-20
* @systemLayer    Test ( Choose from: Invocation | Service | Utility | Selector | Domain | Test )
* @description TestClass for AOB_LegalHierarchyResource
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@IsTest
private class AOB_LegalEntityHierarchy_Test {

    private static final Integer HTTP_RESPONSE_CODE_OK = 200;
    private static final Integer HTTP_RESPONSE_CODE_ERROR = 500;

    private static final String
            USER_NAME           = 'henimmarrifi-1815@yopmail.com',
            DEF_ACC_NAME        = 'Def Name for Acc',
            GROUP_NUMBER        = '123456';

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

            BLD_Account parentAccount = new BLD_Account(uow).CIF('530437495').name('parent0').useGroupParent();
            BLD_Account secondParentAccount = new BLD_Account(uow).CIF('100061211').name('parent1').useGroupParent();

            parentAccount
                    .setField(Account.BillingCountry,'South Africa')
                    .setField(Account.Registration_Number__c,'2020/2020/2020');
            secondParentAccount
                    .setField(Account.BillingCountry,'South Africa')
                    .setField(Account.Registration_Number__c,'2121/2121/2121');
            new BLD_KYC_Status(uow)
                    .setField(KYC_Status__c.Entity_Code__c,'SBSA')
                    .setField(KYC_Status__c.Status__c,'y')
                    .setRelation(KYC_Status__c.Client__c,parentAccount);

            new BLD_KYC_Status(uow)
                    .setField(KYC_Status__c.Entity_Code__c,'SBSA')
                    .setField(KYC_Status__c.Status__c,'N')
                    .setRelation(KYC_Status__c.Client__c,secondParentAccount);

            uow.commitWork();

            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            BLD_Account immediateChildAccount = new BLD_Account(uow).CIF('1000666621').name('i01').useImmediateParent(parentAccount);
            BLD_Account immediateChildAccount1 = new BLD_Account(uow).CIF('1000666623').name('ip1').useImmediateParent(parentAccount);
            BLD_Account immediateChildAccount2 = new BLD_Account(uow).CIF('1000666624').name('ip2').useImmediateParent(secondParentAccount);
            BLD_Account immediateChildAccount3 = new BLD_Account(uow).CIF('1000666625').name('ip3').useImmediateParent(secondParentAccount);

            immediateChildAccount
                    .setField(Account.BillingCountry,'South Africa')
                    .setField(Account.Registration_Number__c,'2022/2022/2022');
            immediateChildAccount1
                    .setField(Account.BillingCountry,'South Africa')
                    .setField(Account.Registration_Number__c,'2023/2023/2023');
            immediateChildAccount2
                    .setField(Account.BillingCountry,'South Africa')
                    .setField(Account.Registration_Number__c,'2024/2024/2024');
            immediateChildAccount3
                    .setField(Account.BillingCountry,'South Africa')
                    .setField(Account.Registration_Number__c,'2025/2025/2025');
            uow.commitWork();

            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            BLD_Account childAccount = new BLD_Account(uow).CIF('1000666620').name('child0').useChild(immediateChildAccount, parentAccount);
            BLD_Account invalidAccount = new BLD_Account(uow).name(DEF_ACC_NAME).useCommB().useGroupParent().groupNumber(GROUP_NUMBER).cibTarget(true);
            childAccount
                    .setField(Account.BillingCountry,'South Africa')
                    .setField(Account.Registration_Number__c,'2120/2120/2120');

            new BLD_KYC_Status(uow)
                    .setField(KYC_Status__c.Entity_Code__c,'SBSA')
                    .setField(KYC_Status__c.Status__c,'y')
                    .setRelation(KYC_Status__c.Client__c,childAccount);

            uow.commitWork();

        }
    }

    @IsTest
    static void testPostMethodPositive() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='/services/apexrest/LegalEntities';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('["1000666620","100061211"]');
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        AOB_LegalEntityHierarchyResource.doPost();
        Test.stopTest();
        System.assertEquals(HTTP_RESPONSE_CODE_OK, RestContext.response.statusCode);
    }

    @IsTest
    static void testPostMethodNegative() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='/services/apexrest/LegalEntities';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('[]');
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        AOB_LegalEntityHierarchyResource.doPost();
        Test.stopTest();
        System.assertEquals(HTTP_RESPONSE_CODE_OK, RestContext.response.statusCode);
    }

    @IsTest
    static void testPostMethodNoCIF() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='/services/apexrest/LegalEntities';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        AOB_LegalEntityHierarchyResource.doPost();
        Test.stopTest();
        System.assertEquals(HTTP_RESPONSE_CODE_OK, RestContext.response.statusCode);
    }

    @IsTest
    static void testPosttMethodAccountServiceException() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='/services/apexrest/LegalEntities';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('["INVALID1"]');
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        AOB_LegalEntityHierarchyResource.doPost();
        Test.stopTest();
        System.assertEquals(HTTP_RESPONSE_CODE_OK, RestContext.response.statusCode);
    }
}