@IsTest
public class SRV_RasCcap_Test {
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

		for (Integer i = 0; i < NBAC_INDICATOR_COUNT; i++) {
			new BLD_NBACFinancialAnalysis(uow).indicatior().businessAssessment(bAssessment);
		}

		for (Integer i = 0; i < NBAC_METRIC_COUNT; i++) {
			new BLD_NBACFinancialAnalysis(uow).metric().businessAssessment(bAssessment).metricYear1('1').metricYear2('2').metricYear3('3').metricYear4('4');
		}

        BLD_Opportunity oppBuilder = new BLD_Opportunity(uow);
        oppBuilder.client(bAccount).setDefaultData();

        BLD_Assessment_Opportunity aOpportunity = new BLD_Assessment_Opportunity(uow);
        aOpportunity.opportunity(oppBuilder);
        aOpportunity.businessAssessment(bAssessment);

		System.runAs(owner) {
			uow.commitWork();
		}

        insert new Risk_App_Store_Integration__c(
            SetupOwnerId                 = UserInfo.getOrganizationId(),
            CCAP_Getting_URL__c          = '/test/get/ccap/risk-app-store/url',
            ESB_Grant_Type__c            = '/test/esb/grant/type{0}',
            ESB_Token_URL__c             = '/test/esb/auth/token/url/{0}',
            Risk_App_Store_Grant_Type__c = '/test/ras/grant/type/{0}'
        );
    }

    @IsTest
    private static void getCCAPPositive() {
        Account account = [SELECT Id, CIF__c FROM Account WHERE Name = 'acc0' LIMIT 1];
        Map<String, String> ccapMap;

        Test.setMock(HttpCalloutMock.class, new IB_SRV_GatewayAPI_Mock(account.CIF__c, 200));
        Test.startTest();
        System.runAs(standardUser) {
            ccapMap = new SRV_RasCcap().getCcapValues(new Set<String> { account.Id });
        }
        Test.stopTest();

        System.assertEquals(true, ccapMap != null);
        System.assertEquals(true, String.isBlank(ccapMap.get('error')));
        System.assertEquals(true, String.isNotBlank(ccapMap.get(account.Id)));
    }

    @IsTest
    private static void getCCAPNegative() {
        Account account = [SELECT Id, CIF__c FROM Account WHERE Name = 'acc0' LIMIT 1];
        Map<String, String> ccapMap;

        Test.setMock(HttpCalloutMock.class, new IB_SRV_GatewayAPI_Mock(account.CIF__c, 401));
        Test.startTest();
        System.runAs(standardUser) {
            ccapMap = new SRV_RasCcap().getCcapValues(new Set<String> { account.Id });
        }
        Test.stopTest();

        System.assertEquals(true, ccapMap != null);
        System.assertEquals(true, String.isBlank(ccapMap.get(account.Id)));
        System.assertEquals(true, String.isNotBlank(ccapMap.get('error')));
    }

    @IsTest
    private static void getAccountIds() {
        Business_Assessment__c assessment = [SELECT Id, Account__c, Account__r.CIF__c From Business_Assessment__c];
        Set<Id> accountIds;

        Test.startTest();
        System.runAs(standardUser) {
            accountIds = new SRV_RasCcap().getAccountIds(assessment.Id);
        }
        Test.stopTest();

        System.assertEquals(true, accountIds != null);
        System.assertEquals(true, accountIds.contains(assessment.Account__c));
    }

    @IsTest
    private static void getCifNumbers() {
        Account account = [SELECT Id, CIF__c FROM Account WHERE Name = 'acc0' LIMIT 1];
        Map<String, String> cifNumbersMap;

        Test.startTest();
        System.runAs(standardUser) {
            cifNumbersMap = new SRV_RasCcap().getCifNumbers(new Set<Id> { account.Id });
        }
        Test.stopTest();

        System.assertEquals(true, cifNumbersMap != null);
        System.assertEquals(true, String.isBlank(cifNumbersMap.get('error')));
        System.assertEquals(account.CIF__c, cifNumbersMap.get(account.Id));
    }

    @IsTest
    private static void checkIsAllowedToViewCcap() {
        Account account = [SELECT Id, CIF__c FROM Account WHERE Name = 'acc0' LIMIT 1];
        Boolean isAllowedToViewCcap;

        Test.startTest();
        System.runAs(standardUser) {
            isAllowedToViewCcap = new SRV_RasCcap().isAllowedToViewCcap(account.Id);
        }
        Test.stopTest();

        System.assertEquals(false, isAllowedToViewCcap);
    }
}