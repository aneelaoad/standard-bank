@IsTest
public class CiCcap_Controller_Test {
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
            BLD_ClientTeam clientTeam = new BLD_ClientTeam(uow);
            clientTeam.account(bAccount).user(owner.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(false).ccbm(false);

			uow.commitWork();
		}

        insert new SB_Parameters__c(
            Name = 'CIB_User_Global_Area',
            Value__c = 'CIBI;CIBSA;CIBROA;CIB Global;'
        );

        insert new Risk_App_Store_Integration__c(
            SetupOwnerId                 = UserInfo.getOrganizationId(),
            CCAP_Getting_URL__c          = '/test/get/ccap/risk-app-store/url',
            ESB_Grant_Type__c            = '/test/esb/grant/type{0}',
            ESB_Token_URL__c             = '/test/esb/auth/token/url/{0}',
            Risk_App_Store_Grant_Type__c = '/test/ras/grant/type/{0}'
        );
    }

    @IsTest
    private static void getCCAPByAccountId() {
        Account account = [SELECT Id, CIF__c, Name FROM Account WHERE Name = 'acc0' LIMIT 1];
        CiCcap_Controller.CcapWrapper ccapWrapper;

        Test.setMock(HttpCalloutMock.class, new IB_SRV_GatewayAPI_Mock(account.CIF__c, 200));
        Test.startTest();
        System.runAs(standardUser) {
            ccapWrapper = CiCcap_Controller.getCcapValue(account.Id);
        }
        Test.stopTest();

        System.assertEquals(true, ccapWrapper != null);
        System.debug('ccapWrapper: ' + ccapWrapper.errorMessage);
        System.assertEquals(true, String.isBlank(ccapWrapper.errorMessage));
        System.assertEquals(true, String.isNotBlank(ccapWrapper.accountName2Ccap.get(account.Name)));
    }

    @IsTest
    private static void getCCAPByBusinessAssesmentId() {
        Account account = [SELECT Id, CIF__c, Name FROM Account WHERE Name = 'acc0' LIMIT 1];
        Business_Assessment__c assessment = [SELECT Id, Account__c, Account__r.CIF__c From Business_Assessment__c];
        CiCcap_Controller.CcapWrapper ccapWrapper;

        Test.setMock(HttpCalloutMock.class, new IB_SRV_GatewayAPI_Mock(account.CIF__c, 200));
        Test.startTest();
        System.runAs(standardUser) {
            ccapWrapper = CiCcap_Controller.getCcapValue(assessment.Id);
        }
        Test.stopTest();

        System.assertEquals(true, ccapWrapper != null);
        System.assertEquals(true, String.isBlank(ccapWrapper.errorMessage));
        System.assertEquals(true, String.isNotBlank(ccapWrapper.accountName2Ccap.get(account.Name)));
    }

    @IsTest
    private static void getCCAPWithError() {
        Account account = [SELECT Id, CIF__c, Name FROM Account WHERE Name = 'acc0' LIMIT 1];
        CiCcap_Controller.CcapWrapper ccapWrapper;

        Test.setMock(HttpCalloutMock.class, new IB_SRV_GatewayAPI_Mock(account.CIF__c, 401));
        Test.startTest();
        System.runAs(standardUser) {
            ccapWrapper = CiCcap_Controller.getCcapValue(account.Id);
        }
        Test.stopTest();

        System.assertEquals(true, ccapWrapper != null);
        System.assertEquals(true, String.isBlank(ccapWrapper.accountName2Ccap.get(account.Name)));
        System.assertEquals(true, String.isNotBlank(ccapWrapper.errorMessage));
    }

    @IsTest
    private static void getErrorWithoutCIBUser() {
        Account account = [SELECT Id, CIF__c, Name FROM Account WHERE Name = 'acc0' LIMIT 1];
        CiCcap_Controller.CcapWrapper ccapWrapper;

        delete [SELECT Id FROM SB_Parameters__c WHERE Name = 'CIB_User_Global_Area'];

        Test.setMock(HttpCalloutMock.class, new IB_SRV_GatewayAPI_Mock(account.CIF__c, 200));
        Test.startTest();
        System.runAs(standardUser) {
            ccapWrapper = CiCcap_Controller.getCcapValue(account.Id);
        }
        Test.stopTest();

        System.assertEquals(true, ccapWrapper != null);
        System.assertEquals(true, String.isBlank(ccapWrapper.accountName2Ccap.get(account.Name)));
        System.assertEquals(true, String.isNotBlank(ccapWrapper.errorMessage));
    }
}