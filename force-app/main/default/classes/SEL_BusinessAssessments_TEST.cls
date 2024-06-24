/**
 * Test class for SEL_BusinessAssessments
 *
 * @author Wayne Solomon
 * @date 2020-06-17
 */
@IsTest
private class SEL_BusinessAssessments_TEST {
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
    }

    @IsTest
    static void selectByIdsWithAssessmentOppChildrenTest() {
        Set<Id> baIds = new Set<Id>();
        for (Business_Assessment__c ba : [SELECT Id FROM Business_Assessment__c]) {
            baIds.add(ba.Id);
        }
        SEL_BusinessAssessments selector = new SEL_BusinessAssessments();
        Test.startTest();
        List<Business_Assessment__c> methodOneOpps = selector.selectByIdsWithAssessmentOppChildren(baIds);
        Test.stopTest();

        Assert.isFalse(methodOneOpps.isEmpty());
        Assert.areEqual(2, methodOneOpps.size());
    }

    @IsTest
    static void selectByIdsWithoutCrudAndFlsEnforcementTest() {
        Set<Id> baIds = new Set<Id>();
        for (Business_Assessment__c ba : [SELECT Id FROM Business_Assessment__c]) {
            baIds.add(ba.Id);
        }
        SEL_BusinessAssessments selector = new SEL_BusinessAssessments();
        Test.startTest();
        List<Business_Assessment__c> methodOneOpps = selector.selectByIdsWithoutCrudAndFlsEnforcement(baIds);
        Test.stopTest();

        Assert.isFalse(methodOneOpps.isEmpty());
        Assert.areEqual(2, methodOneOpps.size());
    }
    
    @IsTest
    static void getQueryToSelectByCreatedDateAndRecordTypeIds() {
        Set<Id> rectypeIds = new Set<Id>{Schema.SObjectType.Business_Assessment__c.getRecordTypeInfosByName().get('NBAC').getRecordTypeId()}; 
        
        SEL_BusinessAssessments selector = new SEL_BusinessAssessments();
        Test.startTest();
        String methodOneOpps = selector.getQueryToSelectByCreatedDateAndRecordTypeIds(datetime.now(), rectypeIds);
        Test.stopTest();

        Assert.areNotEqual(methodOneOpps, '', 'Success');
    }
}