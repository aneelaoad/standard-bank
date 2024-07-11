/***
  	@ Func Area     	:  IB
  	@ Author        	:  Wayne Solomon
  	@ Modified Date    	:  28 Sept 2022
  	@ User Story    	:  US-4493 -- DM NBAC: SPV New PDF format linked to JV record type
  	@description 	    :  Updated test class for nbacPdfExtension
***/
@SuppressWarnings('PMD.ClassNamingConventions')
@IsTest
private class nbacPdfExtension_Test {
private static final String
	TEST_USER_NAME = 'triggerstdBank@nbacPDF.com';

	private static final Integer NBAC_METRIC_COUNT = 10;
	private static final Integer NBAC_INDICATOR_COUNT = 20;

	private static User standardUser {
		get {
			if (standardUser == null) {

				standardUser = [SELECT id FROM User WHERE UserName = :TEST_USER_NAME];

			}
			return standardUser;
		}
		Set;
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
		.useGroupParent()
		;

		BLD_BusinessAssessment bAssessment = new BLD_BusinessAssessment(uow);
		bAssessment.client(bAccount);

		for (Integer i = 0; i<NBAC_INDICATOR_COUNT; i++) {
			new BLD_NBACFinancialAnalysis(uow).indicatior().businessAssessment(bAssessment);
		}

		for (Integer i = 0; i<NBAC_METRIC_COUNT; i++) {
			new BLD_NBACFinancialAnalysis(uow).metric().businessAssessment(bAssessment).metricYear1('1').metricYear2('2').metricYear3('3').metricYear4('4');
		}

		System.runAs(owner) {
			uow.commitWork();
		}

	}

	@IsTest
	private static void testPDFQueryPositive() {
        Business_Assessment__c assessment = [SELECT Account__c, Account__r.CIF__c From Business_Assessment__c];
        ApexPages.StandardController controller;
        nbacPdfExtension nbacPDF;
            
        controller = new ApexPages.StandardController(assessment);
        nbacPDF = new nbacPdfExtension(controller);

		Test.setMock(HttpCalloutMock.class, new IB_SRV_GatewayAPI_Mock(assessment.Account__r.CIF__c, 200));
        Test.startTest(); 
		System.runAs(standardUser) {
            try {
                nbacPDF.getOpportunityTeam();
                nbacPDF.getTeam();
                nbacPDF.getActionItems();
				nbacPDF.getCCAPMap();
                System.assertNotEquals(null, nbacPDF.firstMetric);
            }
            catch(Exception ex) {
                System.assert(false, ex.getMessage());
            }
        }
        Test.stopTest();
    }
    
    @IsTest
	private static void testPDFREF() {
        Business_Assessment__c assessment = [SELECT Account__c, Account__r.CIF__c From Business_Assessment__c];
        ApexPages.StandardController controller;
        nbacPdfExtension nbacPDF;
            
        controller = new ApexPages.StandardController(assessment);
        nbacPDF = new nbacPdfExtension(controller);

		Test.setMock(HttpCalloutMock.class, new IB_SRV_GatewayAPI_Mock(assessment.Account__r.CIF__c, 200));
        Test.startTest(); 
		List<NBAC_Real_Estate_Finance__c> refFields = nbacPDF.getNbacRealEstateFinanceFields(); 
        Assert.areEqual(refFields.size(), 0, 'No Ref fields returned'); 
        List<SB_Product__c> ancillary = nbacPDF.getAncillaryOpportunities(); 
        Assert.areEqual(ancillary.size(), 0, 'No Ancillary Opportunity Products returned');  
        Test.stopTest();
    }

	@IsTest
	private static void testPDFQueryNegative() {
        Business_Assessment__c assessment = [SELECT Account__c, Account__r.CIF__c From Business_Assessment__c];
        ApexPages.StandardController controller;
        nbacPdfExtension nbacPDF;
            
        controller = new ApexPages.StandardController(assessment);
        nbacPDF = new nbacPdfExtension(controller);

		Test.setMock(HttpCalloutMock.class, new IB_SRV_GatewayAPI_Mock(assessment.Account__r.CIF__c, 401));
        Test.startTest(); 
		System.runAs(standardUser) {
            try {
                nbacPDF.getOpportunityTeam();
                nbacPDF.getTeam();
                nbacPDF.getActionItems();
				nbacPDF.getCCAPMap();
                System.assertNotEquals(null, nbacPDF.firstMetric);
            }
            catch(Exception ex) {
                System.assert(false, ex.getMessage());
            }
        }
		System.assertEquals(1, Limits.getEmailInvocations());
        Test.stopTest();
    }
}