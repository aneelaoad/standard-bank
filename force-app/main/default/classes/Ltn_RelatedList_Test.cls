@isTest
public class Ltn_RelatedList_Test {

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

	@IsTest
	private static void removeRecordNoID() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_NBACFinancialAnalysis bFinancial = new BLD_NBACFinancialAnalysis(uow).businessAssessment(new BLD_BusinessAssessment(uow).client(new BLD_Account(uow)));
		System.assertEquals(NBAC_INDICATOR_COUNT + NBAC_METRIC_COUNT, [SELECT id from NBAC_Financial_Analysis__c].size());
		Boolean exceptionThrown = false;
		Test.startTest();
		try {
			Ltn_RelatedList.removeRecord(bFinancial.getRecord());

		}
		catch(Ltn_RelatedList.ReletedListException e) {
			exceptionThrown = true;
		}
		Test.stopTest();

		System.assertEquals(NBAC_INDICATOR_COUNT + NBAC_METRIC_COUNT, [SELECT id from NBAC_Financial_Analysis__c].size());

	}


	@IsTest
	private static void removeRecordID() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_NBACFinancialAnalysis bFinancial = new BLD_NBACFinancialAnalysis(uow).businessAssessment(new BLD_BusinessAssessment(uow).client(new BLD_Account(uow)));
		System.assertEquals(NBAC_INDICATOR_COUNT + NBAC_METRIC_COUNT, [SELECT id from NBAC_Financial_Analysis__c].size());
		Boolean exceptionThrown = false;
		uow.commitWork();
		System.assertEquals(NBAC_INDICATOR_COUNT + NBAC_METRIC_COUNT + 1, [SELECT id from NBAC_Financial_Analysis__c].size());

		Test.startTest();
		try {
			Ltn_RelatedList.removeRecord(bFinancial.getRecord());

		}
		catch(Ltn_RelatedList.ReletedListException e) {
			exceptionThrown = true;
		}
		Test.stopTest();

		System.assertEquals(NBAC_INDICATOR_COUNT + NBAC_METRIC_COUNT, [SELECT id from NBAC_Financial_Analysis__c].size());

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
			Ltn_RelatedList.saveRecords(metric, new Map<String, String> ());
			Ltn_RelatedList.saveRecords(indicator, new Map<String, String> ());
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
			Ltn_RelatedList.saveRecords(metric, new Map<String, String> ());
			Ltn_RelatedList.saveRecords(indicator, new Map<String, String> ());
		}
		Test.stopTest();
		System.assertEquals(NBAC_INDICATOR_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_INDICATOR].size());
		System.assertEquals(NBAC_INDICATOR_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE Indicator__c = :indicatorValue].size());
		System.assertEquals(NBAC_INDICATOR_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_INDICATOR AND Indicator__c = :indicatorValue].size());
		System.assertEquals(NBAC_METRIC_COUNT + 1, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_METRIC].size());
		System.assertEquals(NBAC_METRIC_COUNT, [SELECT Id, Metric__c, RecordType.DeveloperName FROM NBAC_Financial_Analysis__c WHERE Metric__c = :metricValue].size());
		System.assertEquals(NBAC_METRIC_COUNT, [SELECT Id FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :DMN_NBACFinancialAnalysis.RT_METRIC AND Metric__c = :metricValue].size());
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
			Ltn_RelatedList.saveRecords(metric, defaultValues);
			Ltn_RelatedList.saveRecords(indicator, defaultValues);
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

	@IsTest
	private static void getDataMetric() {
		Id metricRt = UTL_RecordType.getRecordTypeId(NBAC_Financial_Analysis__c.getSobjecttype().getDescribe().getName(), DMN_NBACFinancialAnalysis.RT_METRIC);
		Ltn_RelatedList.DTO response;
		Business_Assessment__c assessment = [SELECT Id From Business_Assessment__c];
		Test.startTest();
		System.runAs(standardUser) {
			response = Ltn_RelatedList.getData(assessment.Id, 'NBAC_Financial_Analysis__r', '', Schema.SObjectType.NBAC_Financial_Analysis__c.fieldSets.NBAC_Metric.getName(), ' RecordType.Id = \'' + metricRt + '\'', '');
		}
		Test.stopTest();
		System.assertNotEquals(null, response);
		System.assertNotEquals(null, response.records);
		System.assertEquals(NBAC_METRIC_COUNT, response.records.size());
		System.assertEquals(NBAC_Financial_Analysis__c.getSobjecttype().getDescribe().getName(), response.objectName);
		System.assertEquals(NBAC_Financial_Analysis__c.getSobjecttype().getDescribe().getLabel(), response.objectLabel);
	}

	@IsTest
	private static void getDataMetricFieldAsString() {
		Id metricRt = UTL_RecordType.getRecordTypeId(NBAC_Financial_Analysis__c.getSobjecttype().getDescribe().getName(), DMN_NBACFinancialAnalysis.RT_METRIC);
		List<String> fields = new List<String> {
			NBAC_Financial_Analysis__c.Metric_Year_1__c.getDescribe().getName(),
			NBAC_Financial_Analysis__c.Metric_Year_2__c.getDescribe().getName(),
			NBAC_Financial_Analysis__c.Metric_Year_3__c.getDescribe().getName(),
			NBAC_Financial_Analysis__c.Metric_Year_4__c.getDescribe().getName(),
			NBAC_Financial_Analysis__c.Business_Assessment__c.getDescribe().getName()

		};
		Ltn_RelatedList.DTO response;
		Business_Assessment__c assessment = [SELECT Id From Business_Assessment__c];
		Test.startTest();
		System.runAs(standardUser) {
			response = Ltn_RelatedList.getData(assessment.Id, 'NBAC_Financial_Analysis__r', '', String.join(fields, ','), ' RecordType.Id = \'' + metricRt + '\'', '');
		}
		Test.stopTest();
		System.assertNotEquals(null, response);
		System.assertNotEquals(null, response.records);
		System.assertEquals(NBAC_METRIC_COUNT, response.records.size());
		System.assertEquals(NBAC_Financial_Analysis__c.getSobjecttype().getDescribe().getName(), response.objectName);
		System.assertEquals(NBAC_Financial_Analysis__c.getSobjecttype().getDescribe().getLabel(), response.objectLabel);
		System.assertEquals(fields.size(), response.fields.size());
		for (Integer i = 0; i<fields.size(); i++) {
			System.assertEquals(fields[i], response.fields[i].apiName);
		}
	}

	@IsTest
	private static void getDataNoRecords() {
		Ltn_RelatedList.DTO response;
		BLD_BusinessAssessment bAssessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment().client().commitWork();
		Test.startTest();
		System.runAs(standardUser) {
			response = Ltn_RelatedList.getData(bAssessment.getRecordId(), 'NBAC_Financial_Analysis__r', '', Schema.SObjectType.NBAC_Financial_Analysis__c.fieldSets.NBAC_Metric.getName(), '', '');
		}
		Test.stopTest();

		System.assertNotEquals(null, response);
		System.assertNotEquals(null, response.records);
		System.assertEquals(0, response.records.size());
		System.assertEquals(NBAC_Financial_Analysis__c.getSobjecttype().getDescribe().getName(), response.objectName);
		System.assertEquals(NBAC_Financial_Analysis__c.getSobjecttype().getDescribe().getLabel(), response.objectLabel);
	}

	@IsTest
	private static void getDataDefaults() {
		Ltn_RelatedList.DTO response;
		BLD_BusinessAssessment bAssessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment().client().commitWork();
		Test.startTest();
		System.runAs(standardUser) {
			response = Ltn_RelatedList.getData(bAssessment.getRecordId(), 'NBAC_Financial_Analysis__r', '', Schema.SObjectType.NBAC_Financial_Analysis__c.fieldSets.NBAC_Metric.getName(), '', 'ValueYear1__c=123');
		}
		Test.stopTest();

		System.assertNotEquals(null, response);
		System.assertNotEquals(null, response.records);
		System.assertEquals(0, response.records.size());
		System.assertEquals(NBAC_Financial_Analysis__c.getSobjecttype().getDescribe().getName(), response.objectName);
		System.assertEquals(NBAC_Financial_Analysis__c.getSobjecttype().getDescribe().getLabel(), response.objectLabel);
		System.assertEquals('123', response.defaultValues.get('ValueYear1__c'));
		System.assertEquals(bAssessment.getRecordId(), response.defaultValues.get(NBAC_Financial_Analysis__c.Business_Assessment__c.getDescribe().getName()));
	}

	@IsTest
	private static void getDataComplexRelationship() {
		Ltn_RelatedList.DTO response;
		Integer contactsCount = 20;
		Integer taskPerContactCount = 2 * 30;
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount = new BLD_Account(uow);
		List<BLD_Contact> bConts = new List<BLD_Contact> ();
		for (Integer i = 0; i<contactsCount; i++) {
			BLD_Contact bCont = new BLD_Contact(uow).account(bAccount);
			bConts.add(bCont);
			for (Integer j = 0; j<taskPerContactCount; j++) {
				new BLD_Task(uow).linkToParent(bCont);
			}
		}
		BLD_BusinessAssessment bAssessment = new BLD_BusinessAssessment(uow).client(bAccount);
		System.runAs(standardUser) {
			uow.commitWork();
		}

		Test.startTest();
		System.runAs(standardUser) {
			response = Ltn_RelatedList.getData(bAssessment.getRecordId(), 'Tasks', 'Account__c,Contacts', 'Subject', '', '');
		}
		Test.stopTest();

		System.assertNotEquals(null, response);
		System.assertNotEquals(null, response.records);
		System.assertEquals(contactsCount * taskPerContactCount, response.records.size());
		System.assertEquals(Task.getSobjecttype().getDescribe().getName(), response.objectName);
		System.assertEquals(Task.getSobjecttype().getDescribe().getLabel(), response.objectLabel);
	}
}