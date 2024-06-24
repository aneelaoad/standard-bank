@isTest
private class Ltn_NBAC_FinancialAnalysis_Test {

	private static final String
	TEST_USER_NAME = 'triggerstdBank@nbac.com';

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


	@isTest
	private static void removeRecord() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_NBACFinancialAnalysis bFinancial = new BLD_NBACFinancialAnalysis(uow).businessAssessment(new BLD_BusinessAssessment(uow).client(new BLD_Account(uow)));
		uow.commitWork();
		System.assertEquals(NBAC_INDICATOR_COUNT + NBAC_METRIC_COUNT + 1, [SELECT id from NBAC_Financial_Analysis__c].size());

		Test.startTest();
		Ltn_NBAC_FinancialAnalysis.removeRecord(bFinancial.getRecord());
		Test.stopTest();

		System.assertEquals(NBAC_INDICATOR_COUNT + NBAC_METRIC_COUNT, [SELECT id from NBAC_Financial_Analysis__c].size());
	}

	@isTest
	private static void removeRecordNoId() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_NBACFinancialAnalysis bFinancial = new BLD_NBACFinancialAnalysis(uow).businessAssessment(new BLD_BusinessAssessment(uow).client(new BLD_Account(uow)));
		System.assertEquals(NBAC_INDICATOR_COUNT + NBAC_METRIC_COUNT, [SELECT id from NBAC_Financial_Analysis__c].size());
		Boolean exceptionThrown = false;
		Test.startTest();
		try {
			Ltn_NBAC_FinancialAnalysis.removeRecord(bFinancial.getRecord());

		}
		catch(Ltn_NBAC_FinancialAnalysis.LTN_NBAC_FinancialAnalysisException e) {

			exceptionThrown = true;
		}
		Test.stopTest();

		System.assertEquals(NBAC_INDICATOR_COUNT + NBAC_METRIC_COUNT, [SELECT id from NBAC_Financial_Analysis__c].size());
	}

	@isTest
	private static void initialData() {
		Ltn_NBAC_FinancialAnalysis.DTO response;

		Test.startTest();
		response = Ltn_NBAC_FinancialAnalysis.getInitialData(null, DMN_NBACFinancialAnalysis.RT_INDICATOR, DMN_NBACFinancialAnalysis.RT_METRIC);

		Test.stopTest();
		System.assertEquals(UTL_RecordType.getRecordTypeId(NBAC_Financial_Analysis__c.getSObjectType().getDescribe().getName(), DMN_NBACFinancialAnalysis.RT_INDICATOR), response.indicatorRT);
		System.assertEquals(UTL_RecordType.getRecordTypeId(NBAC_Financial_Analysis__c.getSObjectType().getDescribe().getName(), DMN_NBACFinancialAnalysis.RT_METRIC), response.metricRT);
	}

	@isTest
	private static void saveRecordsNoDefaultsOnlyUpdate() {
		String metricValue = 'abc';
		String indicatorValue = 'cde';
		List<NBAC_Financial_Analysis__c> metric = [SELECT Id, Metric__c FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_METRIC];
		List<NBAC_Financial_Analysis__c> indicator = [SELECT Id, Indicator__c FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_INDICATOR];

		for (Integer i = 0; i<metric.size(); i++) {
			metric[i].Metric__c = metricValue;
		}
		for (Integer i = 0; i<indicator.size(); i++) {
			indicator[i].Indicator__c = indicatorValue;
		}
		Test.startTest();
		System.runAs(standardUser) {
			Ltn_NBAC_FinancialAnalysis.saveRecords(metric, new Map<String, String> ());
			Ltn_NBAC_FinancialAnalysis.saveRecords(indicator, new Map<String, String> ());
		}
		Test.stopTest();
		System.assertEquals(NBAC_INDICATOR_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_INDICATOR].size());
		System.assertEquals(NBAC_INDICATOR_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE Indicator__c = :indicatorValue].size());
		System.assertEquals(NBAC_INDICATOR_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_INDICATOR AND Indicator__c = :indicatorValue].size());
		System.assertEquals(NBAC_METRIC_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_METRIC].size());
		System.assertEquals(NBAC_METRIC_COUNT, [SELECT Id, Metric__c, RecordType.DeveloperName FROM NBAC_Financial_Analysis__c WHERE Metric__c = :metricValue].size());
		System.assertEquals(NBAC_METRIC_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_METRIC AND Metric__c = :metricValue].size());
	}

	@isTest
	private static void saveRecordsNoDefaultsUpdateInsert() {
		String metricValue = 'abc';
		String indicatorValue = 'cde';
		List<NBAC_Financial_Analysis__c> metric = [SELECT Id, Metric__c FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_METRIC];
		List<NBAC_Financial_Analysis__c> indicator = [SELECT Id, Indicator__c FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_INDICATOR];

		for (Integer i = 0; i<metric.size(); i++) {
			metric[i].Metric__c = metricValue;
		}
		for (Integer i = 0; i<indicator.size(); i++) {
			indicator[i].Indicator__c = indicatorValue;
		}

		BLD_NBACFinancialAnalysis newAnalysis = new BLD_NBACFinancialAnalysis();
		newAnalysis.businessAssessment([SELECT id From Business_Assessment__c] [0]);
		newAnalysis.metric();
		metric.add((NBAC_Financial_Analysis__c) newAnalysis.getRecord());

		Test.startTest();
		System.runAs(standardUser) {
			Ltn_NBAC_FinancialAnalysis.saveRecords(metric, new Map<String, String> ());
			Ltn_NBAC_FinancialAnalysis.saveRecords(indicator, new Map<String, String> ());
		}
		Test.stopTest();
		System.assertEquals(NBAC_INDICATOR_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_INDICATOR].size());
		System.assertEquals(NBAC_INDICATOR_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE Indicator__c = :indicatorValue].size());
		System.assertEquals(NBAC_INDICATOR_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_INDICATOR AND Indicator__c = :indicatorValue].size());
		System.assertEquals(NBAC_METRIC_COUNT + 1, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_METRIC].size());
		System.assertEquals(NBAC_METRIC_COUNT, [SELECT Id, Metric__c, RecordType.DeveloperName FROM NBAC_Financial_Analysis__c WHERE Metric__c = :metricValue].size());
		System.assertEquals(NBAC_METRIC_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_METRIC AND Metric__c = :metricValue].size());
	}

	@IsTest
	private static void getDataMetric() {
		Id metricRt = UTL_RecordType.getRecordTypeId(NBAC_Financial_Analysis__c.getSobjecttype().getDescribe().getName(), DMN_NBACFinancialAnalysis.RT_METRIC);
		Ltn_RelatedList.DTO response;
		Business_Assessment__c assessment = [SELECT Id From Business_Assessment__c];
		Test.startTest();
		System.runAs(standardUser) {
			response = Ltn_NBAC_FinancialAnalysis.getData(assessment.Id, 'NBAC_Financial_Analysis__r', '', Schema.SObjectType.NBAC_Financial_Analysis__c.fieldSets.NBAC_Metric.getName(), ' RecordType.Id = \'' + metricRt + '\'', '');
		}
		Test.stopTest();
		System.assertNotEquals(null, response);
		System.assertNotEquals(null, response.records);
		System.assertEquals(NBAC_METRIC_COUNT, response.records.size());
		System.assertEquals(NBAC_Financial_Analysis__c.getSobjecttype().getDescribe().getName(), response.objectName);
		System.assertEquals(NBAC_Financial_Analysis__c.getSobjecttype().getDescribe().getLabel(), response.objectLabel);
	}

	@IsTest
	private static void columns() {
		List<Ltn_RelatedList.Field> resp = Ltn_NBAC_FinancialAnalysis.getColumns('Metric__c,Indicator__c');
		System.assertEquals(2, resp.size());
		System.assertEquals(NBAC_Financial_Analysis__c.Metric__c.getDescribe().getName(), resp[0].apiName);
		System.assertEquals(NBAC_Financial_Analysis__c.Metric__c.getDescribe().getLabel(), resp[0].label);
		System.assertEquals(NBAC_Financial_Analysis__c.Indicator__c.getDescribe().getName(), resp[1].apiName);
		System.assertEquals(NBAC_Financial_Analysis__c.Indicator__c.getDescribe().getLabel(), resp[1].label);
	}

	@IsTest
	private static void columnsError() {
		List<Ltn_RelatedList.Field> resp = Ltn_NBAC_FinancialAnalysis.getColumns('Metric_asd_c,Indicatdsaior__c');
		System.assertEquals(0, resp.size());
	}

	@IsTest
	private static void getMock() {
		String fields = 'Metric_Year_1__c,Metric_Year_2__c,Metric_Year_3__c,Metric_Year_4__c';
		NBAC_Financial_Analysis__c actual;
		Business_Assessment__c assessment = [SELECT Id From Business_Assessment__c];
		Test.startTest();
		System.runAs(standardUser) {
			actual = Ltn_NBAC_FinancialAnalysis.getMock(assessment.Id, fields);
		}
		Test.stopTest();
		System.assertNotEquals(null, actual);
		System.assertEquals('1', actual.Metric_Year_1__c);
		System.assertEquals('2', actual.Metric_Year_2__c);
		System.assertEquals('3', actual.Metric_Year_3__c);
		System.assertEquals('4', actual.Metric_Year_4__c);
	}

	@isTest
	private static void saveRecordsDefaultsUpdateInsert() {
		String metricValue = 'abc';
		String indicatorValue = 'cde';
		Map<String, String> defaultValues = new Map<String, String> { 'ValueYear1__c' => '123' };
		List<NBAC_Financial_Analysis__c> metric = [SELECT Id, Metric__c FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_METRIC];
		List<NBAC_Financial_Analysis__c> indicator = [SELECT Id, Indicator__c FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_INDICATOR];

		BLD_NBACFinancialAnalysis newAnalysis = new BLD_NBACFinancialAnalysis();
		newAnalysis.businessAssessment([SELECT id From Business_Assessment__c] [0]);
		newAnalysis.metric();
		metric.add((NBAC_Financial_Analysis__c) newAnalysis.getRecord());

		for (Integer i = 0; i<metric.size(); i++) {
			metric[i].Metric__c = metricValue;
		}
		for (Integer i = 0; i<indicator.size(); i++) {
			indicator[i].Indicator__c = indicatorValue;
		}
		Test.startTest();
		System.runAs(standardUser) {
			Ltn_NBAC_FinancialAnalysis.saveRecords(metric, defaultValues);
			Ltn_NBAC_FinancialAnalysis.saveRecords(indicator, defaultValues);
		}
		Test.stopTest();
		System.assertEquals(NBAC_INDICATOR_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_INDICATOR].size());
		System.assertEquals(NBAC_INDICATOR_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE Indicator__c = :indicatorValue].size());
		System.assertEquals(NBAC_INDICATOR_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_INDICATOR AND Indicator__c = :indicatorValue].size());
		System.assertEquals(NBAC_METRIC_COUNT + 1, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_METRIC].size());
		System.assertEquals(NBAC_METRIC_COUNT + 1, [SELECT Id, Metric__c, RecordType.DeveloperName FROM NBAC_Financial_Analysis__c WHERE Metric__c = :metricValue].size());
		System.assertEquals(NBAC_METRIC_COUNT + 1, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_METRIC AND Metric__c = :metricValue].size());
		System.assertEquals(1, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE ValueYear1__c = '123'].size(), defaultValues);

	}
}