/**
 * Test class for SRV_GatewayAPI_Ens
 *
 * @author Nikita
 * @date 2023-02-09
 *
 */
@IsTest
public with sharing class SRV_GatewayAPI_EnsTest {
    private static final String	 TEST_USER_NAME       = 'triggerstdBank@nbacPDF.com';
	private static final Integer NBAC_METRIC_COUNT    = 10;
	private static final Integer NBAC_INDICATOR_COUNT = 20;

	private static User standardUser {
		get {
			if (standardUser == null) {
				standardUser = [SELECT id FROM User WHERE UserName = :TEST_USER_NAME];
			}
			return standardUser;
		}
		set;
	}

    @TestSetup
    private static void createCommitData() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		User owner;
		System.runAs(new User(Id = UserInfo.getUserId())) {
			owner = (USER) new BLD_USER().userName(TEST_USER_NAME).useCib().syncContact().getRecord();
			uow.commitWork();
		}

		BLD_Account bAccount = new BLD_Account(uow)
		    .name('acc0')
		    .useGroupParent();

		BLD_BusinessAssessment bAssessment = new BLD_BusinessAssessment(uow);
		bAssessment.client(bAccount);
        BLD_BusinessAssessment bAssessment2 = new BLD_BusinessAssessment(uow);
		bAssessment2.client(bAccount);

		for (Integer i = 0; i < NBAC_INDICATOR_COUNT; i++) {
			new BLD_NBACFinancialAnalysis(uow).indicatior().businessAssessment(bAssessment);
		}
		for (Integer i = 0; i < NBAC_METRIC_COUNT; i++) {
			new BLD_NBACFinancialAnalysis(uow).metric().businessAssessment(bAssessment).metricYear1('1').metricYear2('2').metricYear3('3').metricYear4('4');
		}
        
        for (Integer i = 0; i < NBAC_INDICATOR_COUNT; i++) {
			new BLD_NBACFinancialAnalysis(uow).indicatior().businessAssessment(bAssessment2);
		}
		for (Integer i = 0; i < NBAC_METRIC_COUNT; i++) {
			new BLD_NBACFinancialAnalysis(uow).metric().businessAssessment(bAssessment2).metricYear1('1').metricYear2('2').metricYear3('3').metricYear4('4');
		}

        BLD_Opportunity oppBuilder = new BLD_Opportunity(uow);
        oppBuilder.client(bAccount).setDefaultData();

        BLD_Assessment_Opportunity aOpportunity = new BLD_Assessment_Opportunity(uow);
        aOpportunity.opportunity(oppBuilder);
        aOpportunity.businessAssessment(bAssessment);
        
        BLD_Assessment_Opportunity aOpportunity2 = new BLD_Assessment_Opportunity(uow);
        aOpportunity2.opportunity(oppBuilder);
        aOpportunity2.businessAssessment(bAssessment2);
        
        

		System.runAs(owner) {
			uow.commitWork();
		}

        insert new Azure_ENS__c(
            SetupOwnerId          = UserInfo.getOrganizationId(),
            Consumer_Key__c       = 'consumer_key',
            Consumer_Secret__c	  = 'consumer_secret',
            Grant_Type__c         = 'grant_type',
            Scopes__c             = '/test/ras/grant/type/{0}',
            Token_Endpoint_URL__c = '/test/ras/grant/token/auth/url/{0}'
        );

        insert new ENS_Integration_Info__c(
            SetupOwnerId             = UserInfo.getOrganizationId(),
            ESB_Token_URL__c         = '/test/get/esn/token/auth/url',
            ESB_Grant_Type__c        = '/test/esb/grant/type{0}',
            Ocp_Apim_Subscription__c = '63bb7f5d2f74331b2b08339f5e3294btest',
            Post_Assessment_URL__c   = '/test/esb/token/risk-app-store/{0}',
            Default_Link_To_ENS__c   = 'https://test.riskappstore.standardbank.te/es-screening-tool/dashboard'
        );
    }

    @IsTest
    private static void postAssessmentsPositive() {        
        List<Business_Assessment__c> bAssessments = [SELECT Id, Name, Account__r.CIF__c FROM Business_Assessment__c LIMIT 2];
        List<Id> baIds = new List<Id>{bAssessments[0].Id,bAssessments[1].Id};
        Map<String, String> resultMap;
        Test.setMock(HttpCalloutMock.class, new SRV_GatewayAPI_EnsMock(baIds, bAssessments.get(0).Account__r.CIF__c, 200, false));
        Test.startTest();
        System.runAs(standardUser) {
            resultMap = new SRV_GatewayAPI_Ens().postAssessmentData(bAssessments);
        }
        Test.stopTest();
        System.assertEquals(true, resultMap != null);
        System.assertEquals(true, String.isBlank(resultMap.get('error')));
    }

    @IsTest
    private static void postAssessmentsNegative() {
        List<Business_Assessment__c> bAssessments = [SELECT Id, Name, Account__r.CIF__c FROM Business_Assessment__c LIMIT 2];
        List<Id> baIds = new List<Id>{bAssessments[0].Id,bAssessments[1].Id};
        Map<String, String> resultMap;
        Test.setMock(HttpCalloutMock.class, new SRV_GatewayAPI_EnsMock(baIds, bAssessments.get(0).Account__r.CIF__c, 400, true));
        Test.startTest();
        System.runAs(standardUser) {
            resultMap = new SRV_GatewayAPI_Ens().postAssessmentData(bAssessments);
        }
        Test.stopTest();
        System.assertEquals(true, resultMap != null);
        System.assertEquals(true, String.isNotBlank(resultMap.get('error')));
    }

    @IsTest
    private static void postAssessmentsNegativeAuth() {
        List<Business_Assessment__c> bAssessments = [SELECT Id, Name, Account__r.CIF__c FROM Business_Assessment__c LIMIT 2];
        List<Id> baIds = new List<Id>{bAssessments[0].Id,bAssessments[1].Id};
        Map<String, String> resultMap;
        Test.setMock(HttpCalloutMock.class, new SRV_GatewayAPI_EnsMock(baIds, bAssessments[0].Account__r.CIF__c, 400, false));
        Test.startTest();
        System.runAs(standardUser) {
            resultMap = new SRV_GatewayAPI_Ens().postAssessmentData(bAssessments);
        }
        Test.stopTest();
        System.assertEquals(true, resultMap != null);
        System.assertEquals(true, String.isNotBlank(resultMap.get('error')));
    }

    @IsTest
    private static void prepareBodyException() {
        List<Business_Assessment__c> bAssessments = [SELECT Id FROM Business_Assessment__c LIMIT 2];
        String resultString;
        Test.startTest();
        System.runAs(standardUser) {
            resultString = new SRV_GatewayAPI_Ens().prepareBody(bAssessments);
        }
        Test.stopTest();

        System.assertEquals(true, String.isBlank(resultString));
    }
}