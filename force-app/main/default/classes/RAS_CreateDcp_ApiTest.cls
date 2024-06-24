/**
* Test class for RAS_CreateDcp_Api, RAS_CreateDcp_ApiGetTokenQ,
* RAS_CreateDcp_ApiPostNbacQ
* US-4434
*
* @author Wayne Solomon
* @date 2020-01-08
*
* Refactored to use builder classes for test data
* Cleaned up header, indentations and spacings
* Added asserts
*
* @modified Wayne Solomon
* @date 2020-06-17
*/
@IsTest
class RAS_CreateDcp_ApiTest {

    @TestSetup
    static void testSetup() {
        TEST_DataFactory.generateConfiguration();
        RasDcpApiSettings__c rasDcpApiSettings = new RasDcpApiSettings__c(
                AuthUrl__c = 'https://auth-example.com',
                DcpPostingUrl__c = 'https://content-example.com',
                client_id__c = 'myclientid',
                client_secret__c = 'myclientsecret',
                grant_type__c = 'mygranttype',
                resource__c = 'myresource'
        ); insert rasDcpApiSettings;

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account ugpClientBld	= new BLD_Account(uow).name('Acc').useCib().useGroupParent().CIF('505968788');
        BLD_Opportunity opportunityBld = new BLD_Opportunity(uow).develop().client(ugpClientBld).currency(UTL_Currency.corporateIsoCode);
        BLD_BusinessAssessment baBld = new BLD_BusinessAssessment(uow).client(ugpClientBld).guarantorName(ugpClientBld).approvalMilestoneDate(System.today());
        BLD_Assessment_Opportunity aoBld = new BLD_Assessment_Opportunity(uow).businessAssessment(baBld).opportunity(opportunityBld);
        aoBld.setField(Assessment_Opportunity__c.Total_SB_Gross_Participation__c,1000);
        uow.commitwork();
    }

    @IsTest
    static void runRAS_CreateDcp_ApiMainTests() {
        Test.setMock(HttpCalloutMock.class, new RAS_CreateDcp_ApiMock());
        Map<Id, Business_Assessment__c> mapBusinessAssessments = new Map<Id, Business_Assessment__c>([
                select Id, Account__r.CIF__c,Approval_Milestone_Date__c, (
                        select Id,Opportunity__c,Opportunity__r.Opportunity_ID__c,
                                Opportunity__r.CurrencyIsoCode, Total_SB_Gross_Participation__c
                        from Assessment_Opportunities__r
                )
                from Business_Assessment__c
        ]);
        Test.startTest();
        RAS_CreateDcp_Api.executeDcpCreation(new List<Id>(mapBusinessAssessments.keySet()));
        Test.stopTest();

        System.assertEquals(1,[select Nbac_API_Posting_Status__c from Business_Assessment__c].size());
    }

    @IsTest
    static void runRAS_CreateDcp_ApiWriteResponseStatusOvld1Test() {
        Id i = [select Id from Business_Assessment__c limit 1].Id;
        List<Object> body = (List<Object>)JSON.deserializeUntyped('[{"businessAssessmentId": "' + i + '","responseMessage": "Application was successfully staged","result": "SUCCESS"}]');
        Test.startTest();
        RAS_CreateDcp_Api.writeResponseStatus(body);
        Test.stopTest();

        System.assertEquals('SUCCESS',[select Nbac_API_Posting_Status__c from Business_Assessment__c limit 1].Nbac_API_Posting_Status__c);
    }

    @IsTest
    static void runRAS_CreateDcp_ApiWriteResponseStatusOvld2Test() {
        Map<Id, Business_Assessment__c> mapBusinessAssessments = new Map<Id, Business_Assessment__c>([
                select Id from Business_Assessment__c
        ]);
        Test.startTest();
        RAS_CreateDcp_Api.writeResponseStatus('Error occurred', new List<Id>(mapBusinessAssessments.keySet()));
        Test.stopTest();

        System.assertEquals('Error occurred',[select Nbac_API_Posting_Status__c from Business_Assessment__c limit 1].Nbac_API_Posting_Status__c);
    }

    @IsTest
    static void runRAS_CreateDcp_ApiGetTokenQTest() {
        Test.setMock(HttpCalloutMock.class, new RAS_CreateDcp_ApiMock());
        Map<Id, Business_Assessment__c> mapBusinessAssessments = new Map<Id, Business_Assessment__c>([
                select Account__r.CIF__c,Approval_Milestone_Date__c, (
                        select Id,Opportunity__c,Opportunity__r.Opportunity_ID__c,
                                Opportunity__r.CurrencyIsoCode, Total_SB_Gross_Participation__c
                        from Assessment_Opportunities__r
                )
                from Business_Assessment__c
        ]);
        List<RAS_CreateDcp_Api.DcpWrapper> dcpWrappers = RAS_CreateDcp_Api.getDCPData(new List<Id>(mapBusinessAssessments.keySet()));
        Test.startTest();
        System.enqueueJob(new RAS_CreateDcp_ApiGetTokenQ(dcpWrappers, new List<Id>(mapBusinessAssessments.keySet())));
        Test.stopTest();

        System.assertEquals('Not yet posted',[select Nbac_API_Posting_Status__c from Business_Assessment__c limit 1].Nbac_API_Posting_Status__c);
    }

    @IsTest
    static void runRAS_CreateDcp_ApiPostNbacQTest() {
        Test.setMock(HttpCalloutMock.class, new RAS_CreateDcp_ApiMock());
        Map<Id, Business_Assessment__c> mapBusinessAssessments = new Map<Id, Business_Assessment__c>([
                select Account__r.CIF__c,Approval_Milestone_Date__c, (
                        select Id,Opportunity__c,Opportunity__r.Opportunity_ID__c,
                                Opportunity__r.CurrencyIsoCode, Total_SB_Gross_Participation__c
                        from Assessment_Opportunities__r
                )
                from Business_Assessment__c
        ]);
        List<RAS_CreateDcp_Api.DcpWrapper> dcpWrappers = RAS_CreateDcp_Api.getDCPData(new List<Id>(mapBusinessAssessments.keySet()));
        Test.startTest();
        System.enqueueJob(new RAS_CreateDcp_ApiPostNbacQ('ejuuiNZlHPz7mtWMaUTKae03r6KN', dcpWrappers, new List<Id>(mapBusinessAssessments.keySet())));
        Test.stopTest();

        System.assertEquals('SUCCESS',[select Nbac_API_Posting_Status__c from Business_Assessment__c limit 1].Nbac_API_Posting_Status__c);
    }
}