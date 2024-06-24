/**
 * Test class for DMN_Assessment_Opportunity
 *
 * @author Michal Lipinski (milipinski@deloittece.com)
 */
@IsTest
private class DMN_Assessment_Opportunity_Test {
	private static final String
	TEST_USER_NAME = 'triggerstdBank@nbac.com';


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

		BLD_Account bAccount0 = new BLD_Account(uow)
		.name('acc0')
		.useGroupParent();

		BLD_Account bAccount1 = new BLD_Account(uow)
		.name('acc1');

		BLD_Account bAccount2 = new BLD_Account(uow)
		.name('acc2');

		BLD_Opportunity bOpp0 = new BLD_Opportunity(uow)
		.gccrStatus('gccr0')
		.develop()
		.client(bAccount0)
		.currency(UTL_Currency.corporateIsoCode);

		BLD_Opportunity bOpp1 = new BLD_Opportunity(uow)
		.gccrStatus('gccr1')
		.develop()
		.client(bAccount1)
		.currency(UTL_Currency.corporateIsoCode);

		BLD_Opportunity bOpp2 = new BLD_Opportunity(uow)
		.develop()
		.gccrStatus('gccr2')
		.client(bAccount2)
		.currency(UTL_Currency.corporateIsoCode);

		new BLD_Product(uow)
			.linkToOpp(bOpp0)
			.notionalValueCurrency(10)
			.bankRole('Advisor')
			.notionalValue(600000)
			.sbHold(5)
			.sbSellDown(5)
			.transactionType('Debt advisory only')
			.balanceSheetOfBooking('Uganda - Stanbic Bank Uganda Limited')
			.currency(UTL_Currency.corporateIsoCode);

		new BLD_Product(uow)
			.linkToOpp(bOpp1)
			.bankRole('Advisor')
			.notionalValue(600000)
			.sbHold(5)
			.sbSellDown(5)
			.transactionType('Debt advisory only')
			.notionalValueCurrency(10)
			.balanceSheetOfBooking('Hong Kong - Standard Bank Asia Limited')
			.currency(UTL_Currency.corporateIsoCode);

		new BLD_Product(uow)
			.linkToOpp(bOpp2)
			.notionalValueCurrency(10)
			.balanceSheetOfBooking('Zambia - Stanbic Bank Zambia Limited')
			.currency(UTL_Currency.corporateIsoCode);


		new BLD_KYC_Status(uow)
			.client(bAccount0)
			.KYC_Status_Requested()
			.entityCode('0');

		new BLD_KYC_Status(uow)
			.client(bAccount1)
			.KYC_Status_Requested()
			.entityCode('1');

		new BLD_KYC_Status(uow)
			.client(bAccount2)
			.KYC_Status_Requested()
			.entityCode('2');

		System.runAs(owner) {
			uow.commitWork();
		}
		bAccount1.useImmediateParent(bAccount0).registerDirty();
		bAccount2.useChild(bAccount1, bAccount0).registerDirty();
		System.runAs(owner) {
			uow.commitWork();
		}

	}

	@isTest
	private static void corporateCurrency() {
		System.debug([SELECT Id, ParentId FROM Account]);
		Assessment_Opportunity__c assessmentOpportunity = new Assessment_Opportunity__c();
		DMN_Assessment_Opportunity.setCorporateCurrency(assessmentOpportunity);
		System.assertEquals(UTL_Currency.corporateIsoCode, assessmentOpportunity.CurrencyIsoCode);
	}

	@IsTest
	private static void shouldParseKycValue() {
		BLD_Account bAccount0 = new BLD_Account()
		.name('acc0')
		;
		BLD_KYC_Status bKyc0 = new BLD_KYC_Status()
		.client(bAccount0)
		.KYC_Status_Requested()
		.entityCode('0')
		;
		bKyc0.getRecord().recalculateFormulas();
		bKyc0.getRecord().putSObject(KYC_Status__c.Client__c, bAccount0.getRecord());
		String expected = ((Account) bAccount0.getRecord()).Name + ', ' + ((KYC_Status__c) bKyc0.getRecord()).KYC_Status__c + ', ' + ((KYC_Status__c) bKyc0.getRecord()).Entity_Code__c;
		String actual;
		Test.startTest();
		actual = DMN_Assessment_Opportunity.getParsedKycValue((KYC_Status__c) bKyc0.getRecord());
		Test.stopTest();
		System.debug(bKyc0.getRecord());
		System.assertEquals(expected, actual);
	}


	@IsTest
	private static void noRecords() {
		Account acc = [SELECT Id FROM Account WHERE Name = 'acc0'];
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment()
		.client(acc.Id)
		.commitWork();

		Test.startTest();

		Test.stopTest();

		bAsessment.refreshFullFromDB();
		System.assert(String.isBlank(((Business_Assessment__c) bAsessment.getRecord()).Booking_Countries__c));
		System.assert(String.isBlank(((Business_Assessment__c) bAsessment.getRecord()).GCCR_Status__c));
		System.assert(String.isBlank(((Business_Assessment__c) bAsessment.getRecord()).KYC_Status__c));

	}

	@IsTest
	private static void oneInsert() {
		Account acc = [SELECT Id, Name FROM Account WHERE Name = 'acc0'];
		KYC_Status__c kyc = [SELECT Id, KYC_Status__c, Entity_Code__c FROM KYC_Status__c where Entity_Code__c = '0'];
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
		.client(acc.Id);
		BLD_Assessment_Opportunity bAssOpp = new BLD_Assessment_Opportunity(uow);
		bAssOpp.businessAssessment(bAsessment)
		.opportunity([SELECT Id FROM Opportunity WHERE Account.Name = 'acc0' LIMIT 1]);

		Test.startTest();
		uow.commitWork();
		Test.stopTest();
		String expectedKYC = acc.Name + ', ' + kyc.KYC_Status__c + ', ' + kyc.Entity_Code__c;
		bAsessment.refreshFullFromDB();
		List<Assessment_Opportunity__c> junction = [SELECT id, Related_Opportunity_Owner__c FROM Assessment_Opportunity__c];
		System.assert(!junction.isEmpty());
		System.assertEquals(standardUser.Id, junction[0].Related_Opportunity_Owner__c);
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).Booking_Countries__c.contains('Uganda'));

		//values from product linked to opportunity bOpp0
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c > 0);
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c > 0);
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c > 0);
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c > 0);
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c == 'Debt advisory only');
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c == 'Advisor');

		System.assertEquals('gccr0', ((Business_Assessment__c) bAsessment.getRecord()).GCCR_Status__c);
		System.assertEquals(expectedKYC, ((Business_Assessment__c) bAsessment.getRecord()).KYC_Status__c);

	}

	@IsTest
	private static void deletetionManyTest() {
		Account acc = [SELECT Id, Name FROM Account WHERE Name = 'acc0'];
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
		.client(acc.Id);
		List<Opportunity> opps = [SELECT Id FROM Opportunity];
		for (Opportunity opp : opps) {
			BLD_Assessment_Opportunity bAssOpp = new BLD_Assessment_Opportunity(uow);
			bAssOpp.businessAssessment(bAsessment)
			.opportunity(opp);
		}

		uow.commitWork();
		System.assertEquals(opps.size(), [select id from Assessment_Opportunity__c].size());
		List<Assessment_Opportunity__c> junctionToRemove = [SELECT id FROM Assessment_Opportunity__c WHERE Opportunity__r.Account.Name = 'acc1' OR Opportunity__r.Account.Name = 'acc2'];

		Test.startTest();
		delete junctionToRemove;
		Test.stopTest();

		bAsessment.refreshFullFromDB();
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).Booking_Countries__c.contains('Uganda'));
		System.assert(!((Business_Assessment__c) bAsessment.getRecord()).Booking_Countries__c.contains('Hong Kong'));
		System.assert(!((Business_Assessment__c) bAsessment.getRecord()).Booking_Countries__c.contains('Zambia'));
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).GCCR_Status__c.contains('gccr0'));
		System.assert(!((Business_Assessment__c) bAsessment.getRecord()).GCCR_Status__c.contains('gccr1'));
		System.assert(!((Business_Assessment__c) bAsessment.getRecord()).GCCR_Status__c.contains('gccr2'));
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).KYC_Status__c.contains('acc0'));
		System.assert(!((Business_Assessment__c) bAsessment.getRecord()).KYC_Status__c.contains('acc1'));
		System.assert(!((Business_Assessment__c) bAsessment.getRecord()).KYC_Status__c.contains('acc2'));
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).KYC_Status__c.contains('Requested'), ((Business_Assessment__c) bAsessment.getRecord()).KYC_Status__c);
	}

	@IsTest
	private static void deletetionOneTest() {
		Account acc = [SELECT Id, Name FROM Account WHERE Name = 'acc0'];
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
		.client(acc.Id);
		List<Opportunity> opps = [SELECT Id FROM Opportunity];
		for (Opportunity opp : opps) {
			BLD_Assessment_Opportunity bAssOpp = new BLD_Assessment_Opportunity(uow);
			bAssOpp.businessAssessment(bAsessment)
			.opportunity(opp);
		}

		uow.commitWork();
		List<Assessment_Opportunity__c> junctionToRemove = [SELECT id FROM Assessment_Opportunity__c WHERE Opportunity__r.Account.Name = 'acc1'];

		Test.startTest();
		delete junctionToRemove;
		Test.stopTest();

		bAsessment.refreshFullFromDB();
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).Booking_Countries__c.contains('Uganda'));
		System.assert(!((Business_Assessment__c) bAsessment.getRecord()).Booking_Countries__c.contains('Hong Kong'));
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).Booking_Countries__c.contains('Zambia'));
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).GCCR_Status__c.contains('gccr0'));
		System.assert(!((Business_Assessment__c) bAsessment.getRecord()).GCCR_Status__c.contains('gccr1'));
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).GCCR_Status__c.contains('gccr2'));
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).KYC_Status__c.contains('acc0'));
		System.assert(!((Business_Assessment__c) bAsessment.getRecord()).KYC_Status__c.contains('acc1'));
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).KYC_Status__c.contains('acc2'));
		System.assert(((Business_Assessment__c) bAsessment.getRecord()).KYC_Status__c.contains('Requested'));
	}

	@IsTest
	private static void testUndelete(){
		Account acc = [SELECT Id, Name FROM Account WHERE Name = 'acc0'];
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
				.client(acc.Id);
		List<Opportunity> opps = [SELECT Id FROM Opportunity];
		for (Opportunity opp : opps) {
			BLD_Assessment_Opportunity bAssOpp = new BLD_Assessment_Opportunity(uow);
			bAssOpp.businessAssessment(bAsessment)
					.opportunity(opp);
		}

		uow.commitWork();
		bAsessment.refreshFullFromDB();
		Map<String, Object> beforeDeleteValues = new Map<String, Object>();
		beforeDeleteValues.put('Bank_Role', ((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c);
		beforeDeleteValues.put('SB_Gross_Participation', ((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c);
		beforeDeleteValues.put('SB_Hold', ((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c);
		beforeDeleteValues.put('SB_Sell_Down', ((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c);
		beforeDeleteValues.put('Market_Deal_Size', ((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c);
		beforeDeleteValues.put('Transaction_Type', ((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c);

		List<Assessment_Opportunity__c> junctionToRemove = [SELECT id, Business_Assessment__c, Opportunity__c FROM Assessment_Opportunity__c];

		Test.startTest();
		delete junctionToRemove;

		bAsessment.refreshFullFromDB();
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 0);
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 0);
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 0);
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 0);
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, null);
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, null);

		List<Assessment_Opportunity__c> junctionToUndelete = [SELECT id, Business_Assessment__c, Opportunity__c FROM Assessment_Opportunity__c ALL ROWS];


		undelete junctionToUndelete;
		Test.stopTest();

		bAsessment.refreshFullFromDB();
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, (Decimal)beforeDeleteValues.get('SB_Gross_Participation'));
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, (Decimal)beforeDeleteValues.get('SB_Sell_Down'));
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, (Decimal)beforeDeleteValues.get('SB_Hold'));
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, (Decimal)beforeDeleteValues.get('Market_Deal_Size'));
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, (String)beforeDeleteValues.get('Transaction_Type'));
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, (String)beforeDeleteValues.get('Bank_Role'));
	}

	@IsTest
	private static void deleteAll() {
		Account acc = [SELECT Id, Name FROM Account WHERE Name = 'acc0'];
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
		.client(acc.Id);
		List<Opportunity> opps = [SELECT Id FROM Opportunity];
		for (Opportunity opp : opps) {
			BLD_Assessment_Opportunity bAssOpp = new BLD_Assessment_Opportunity(uow);
			bAssOpp.businessAssessment(bAsessment)
			.opportunity(opp);
		}

		uow.commitWork();
		List<Assessment_Opportunity__c> junctionToRemove = [SELECT id, Business_Assessment__c, Opportunity__c FROM Assessment_Opportunity__c];

		Test.startTest();
		delete junctionToRemove;
		Test.stopTest();

		bAsessment.refreshFullFromDB();
		System.assert(String.isBlank(((Business_Assessment__c) bAsessment.getRecord()).Booking_Countries__c));
		System.assert(String.isBlank(((Business_Assessment__c) bAsessment.getRecord()).GCCR_Status__c));
		System.assertEquals(DMN_Assessment_Opportunity.TO_BE_COMPLETED,((Business_Assessment__c) bAsessment.getRecord()).KYC_Status__c);

		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).SB_Gross_Participation__c, 0);
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).SB_Sell_Down__c, 0);
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).SB_Hold__c, 0);
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).Market_Deal_Size__c, 0);
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).Transaction_Type__c, null);
		System.assertEquals(((Business_Assessment__c) bAsessment.getRecord()).Bank_Role__c, null);
	}

	@IsTest
	private static void shouldUpdateDCPOnOpportunityOnInsert(){
		Account acc = [SELECT Id FROM Account LIMIT 1];
		fflib_SObjectUnitOfWork unitOfWork = (fflib_SObjectUnitOfWork)ORG_Application.unitOfWork.newInstance();
		BLD_BusinessAssessment assessment = new BLD_BusinessAssessment(unitOfWork).client(acc.Id);
		unitOfWork.commitwork();
		Business_Assessment__c[] assessments = [
				SELECT Id, Account__c, Name
				FROM Business_Assessment__c
				limit 1
		];

		Opportunity[] opportunities = [
				SELECT Id
				FROM Opportunity
				WHERE AccountId = :assessments[0].Account__c
				LIMIT 1
		];

		List<Id> opportunitiesIds = new List<Id>(new Map<Id,SObject>(opportunities).keySet());
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		Assessment_Opportunity__c[] assessmentOpps = DMN_BusinessAssessment.assignOpportunities(assessments[0].Id, opportunitiesIds, uow);

		Test.startTest();
		uow.commitWork();
		Test.stopTest();

		Opportunity testOpp = [SELECT Id, Business_Assessment_Name__c FROM Opportunity WHERE Id = :opportunities.get(0).Id];
		System.assertEquals(assessments.get(0).Name, testOpp.Business_Assessment_Name__c);
	}

	@IsTest
	private static void shouldUpdateDCPOnOpportunityOnDelete(){
		Account acc = [SELECT Id FROM Account LIMIT 1];
		fflib_SObjectUnitOfWork unitOfWork = (fflib_SObjectUnitOfWork)ORG_Application.unitOfWork.newInstance();
		BLD_BusinessAssessment assessment = new BLD_BusinessAssessment(unitOfWork).client(acc.Id);
		unitOfWork.commitwork();
		Business_Assessment__c[] assessments = [
				SELECT Id, Account__c, Name
				FROM Business_Assessment__c
				limit 1
		];

		Opportunity[] opportunities = [
				SELECT Id
				FROM Opportunity
				WHERE AccountId = :assessments[0].Account__c
				LIMIT 1
		];

		List<Id> opportunitiesIds = new List<Id>(new Map<Id,SObject>(opportunities).keySet());
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		Assessment_Opportunity__c[] assessmentOpps = DMN_BusinessAssessment.assignOpportunities(assessments[0].Id, opportunitiesIds, uow);
		uow.commitWork();

		Opportunity testOpp = [SELECT Id, Business_Assessment_Name__c FROM Opportunity WHERE Id = :opportunities.get(0).Id];
		System.assertEquals(assessments.get(0).Name, testOpp.Business_Assessment_Name__c);
		Test.startTest();
		delete assessmentOpps;
		Test.stopTest();

		testOpp = [SELECT Id, Business_Assessment_Name__c FROM Opportunity WHERE Id = :opportunities.get(0).Id];
		System.assert(String.isEmpty(testOpp.Business_Assessment_Name__c), 'Field Business_Assessment_Name__c should get cleared when Business Assessment is deleted');
	}

	@IsTest
	private static void shouldUpdateDCPOnOpportunityOnUndelete(){
		Account acc = [SELECT Id FROM Account LIMIT 1];
		fflib_SObjectUnitOfWork unitOfWork = (fflib_SObjectUnitOfWork)ORG_Application.unitOfWork.newInstance();
		BLD_BusinessAssessment assessment = new BLD_BusinessAssessment(unitOfWork).client(acc.Id);
		unitOfWork.commitwork();
		Business_Assessment__c[] assessments = [
				SELECT Id, Account__c, Name
				FROM Business_Assessment__c
				limit 1
		];

		Opportunity[] opportunities = [
				SELECT Id
				FROM Opportunity
				WHERE AccountId = :assessments[0].Account__c
				LIMIT 1
		];

		List<Id> opportunitiesIds = new List<Id>(new Map<Id,SObject>(opportunities).keySet());
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		Assessment_Opportunity__c[] assessmentOpps = DMN_BusinessAssessment.assignOpportunities(assessments[0].Id, opportunitiesIds, uow);
		uow.commitWork();

		Opportunity testOpp = [SELECT Id, Business_Assessment_Name__c FROM Opportunity WHERE Id = :opportunities.get(0).Id];
		System.assertEquals(assessments.get(0).Name, testOpp.Business_Assessment_Name__c);
		Test.startTest();
		delete assessmentOpps;

		testOpp = [SELECT Id, Business_Assessment_Name__c FROM Opportunity WHERE Id = :opportunities.get(0).Id];
		System.assertEquals(null, testOpp.Business_Assessment_Name__c);

		undelete assessmentOpps;
		Test.stopTest();
		testOpp = [SELECT Id, Business_Assessment_Name__c FROM Opportunity WHERE Id = :opportunities.get(0).Id];
		System.assertEquals(assessments.get(0).Name, testOpp.Business_Assessment_Name__c);
	}

	@isTest
	private static void setDefaultsExceptionTest() {
		Boolean isExceptionThrown = false;
		Test.startTest();
		try {
			DMN_Assessment_Opportunity.setDefaults(null);
		} catch(DMN_Assessment_Opportunity.AssessmentOpportunityException exc) {
			isExceptionThrown = true;
		}
		Test.stopTest();
		System.assert(isExceptionThrown);
	}

	@isTest
	private static void populateMNPIOnBusinessAssessmentTest() {

		Account acc = [SELECT Id, Name FROM Account WHERE Name = 'acc0'];
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
				.client(acc.Id);
		List<Opportunity> opps = [SELECT Id FROM Opportunity];
		BLD_Assessment_Opportunity bAssOpp;
		for (Opportunity opp : opps) {
			bAssOpp = new BLD_Assessment_Opportunity(uow);
			bAssOpp.businessAssessment(bAsessment)
					.opportunity(opp);
		}

		uow.commitWork();

		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);

		Test.startTest();
		DMN_Assessment_Opportunity.populateMNPIOnBusinessAssessment(new List<Assessment_Opportunity__c>{(Assessment_Opportunity__c) bAssOpp.getRecord()},uowMock);
		Test.stopTest();

		fflib_ArgumentCaptor argCaptor = fflib_ArgumentCaptor.forClass(List<Business_Assessment__c>.class);
		((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty((List<Business_Assessment__c>) argCaptor.capture());
		List<Business_Assessment__c> updatesBAssessments = (List<Business_Assessment__c>) argCaptor.getValue();

		System.assertEquals(false, updatesBAssessments[0].MNPI__c);
	}

	@IsTest
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	private static void recalculateRiskAndDistributionShouldCallBusinessAssessmentSelectorAndDomainMethods(){
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		DMN_BusinessAssessment_Injectable baDomainMock = (DMN_BusinessAssessment_Injectable)mocks.mock(DMN_BusinessAssessment_Injectable.class);
		SEL_BusinessAssessments baSelectorMock = (SEL_BusinessAssessments)mocks.mock(SEL_BusinessAssessments.class);
		fflib_InOrder inOrder = new fflib_InOrder(mocks, new List<Object>{
				baDomainMock,
				baSelectorMock
		});
		fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
		Assessment_Opportunity__c aopRecord = (Assessment_Opportunity__c)new BLD_Assessment_Opportunity(uowMock, true).getRecord();

		mocks.startStubbing();
		mocks.when(baDomainMock.sObjectType()).thenReturn(Business_Assessment__c.SObjectType);
		mocks.when(baSelectorMock.sObjectType()).thenReturn(Business_Assessment__c.SObjectType);
		mocks.when(baSelectorMock.withCrudAssert(false)).thenReturn(baSelectorMock);
		mocks.when(baSelectorMock.withFlsEnforced(false)).thenReturn(baSelectorMock);
		mocks.when(baSelectorMock.selectByIds(new Set<Id>{aopRecord.Business_Assessment__c}, false)).thenReturn(new List<Business_Assessment__c>());
		mocks.stopStubbing();

		ORG_Application.unitOfWork.setMock(uowMock);
		ORG_Application.domain.setMock((fflib_ISObjectDomain)baDomainMock);
		ORG_Application.selector.setMock((fflib_ISObjectSelector)baSelectorMock);
		List<Assessment_Opportunity__c> aopRecords = new List<Assessment_Opportunity__c>{aopRecord};

		DMN_Assessment_Opportunity aopDomain = (DMN_Assessment_Opportunity)ORG_Application.domain.newInstance(new List<Assessment_Opportunity__c>{aopRecord});

		Test.startTest();
		aopDomain.recalculateRiskAndDistributionManagementFieldsOnBusinessAssessment(aopRecords, uowMock);
		Test.stopTest();

		fflib_ArgumentCaptor idsCaptor = fflib_ArgumentCaptor.forClass(Set<Id>.class);
		fflib_ArgumentCaptor withSharingCaptor = fflib_ArgumentCaptor.forClass(Boolean.class);
		//Asserts are in the below methods
		((SEL_BusinessAssessments)mocks.verify(baSelectorMock, 1)).selectByIds((Set<Id>)idsCaptor.capture(), (Boolean)withSharingCaptor.capture());
		((DMN_BusinessAssessment_Injectable)mocks.verify(baDomainMock)).recalculateDistributionAndRiskManagementFields(uowMock);
	}
}