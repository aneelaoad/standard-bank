@isTest
public class StdBank_Ltn_ClientsCYWonRevenueCtrl_Test {
	private static User standardUser {
		get {
			if (standardUser == null) {

				standardUser = [SELECT id FROM User WHERE Alias like '%2TestNa%'];

			}
			return standardUser;
		}
		Set;
	}
	@TestSetup
	private static void setup() {
		//insert TestFactoryUtils.buildCSUserProfileIds();
		TEST_DataFactory.insertSettings(new List<Object> {
			new UserProfileId__c(Name = 'UserProfileId', UserProfileId__c = 'Test'),
			new UserProfileId__c(Name = 'Business Administrator', UserProfileId__c = 'Test'),
			new ClientCoordinatorSettings__c(Name = 'CC_OpportunityAccessLevel'),
			new ClientCoordinatorSettings__c(Name = 'CC_ContactAccessLevel'),
			new ClientCoordinatorSettings__c(Name = 'CC_CaseAccessLevel'),
			new ClientCoordinatorSettings__c(AccessLevel__c = 'Full Access', Name = 'CC_ClientAccessLevel'),
			TEST_DataFactory.getEnvironmentVariable()
		});
		createCommitData();
	}
	private static void createCommitData() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		String currencyIsoCode = 'ZAR';


		BLD_Account up0 = new BLD_Account(uow).CIF('0').name('up0').useGroupParent().CIFActiveCode('A');
		BLD_Account up1 = new BLD_Account(uow).CIF('1').name('up1').useGroupParent().CIFActiveCode('A');
		uow.commitWork();

		uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account ip0 = new BLD_Account(uow).CIF('2').name('i01').useImmediateParent(up0).CIFActiveCode('A');
		BLD_Account ip1 = new BLD_Account(uow).CIF('3').name('ip1').useImmediateParent(up0).CIFActiveCode('A');
		BLD_Account ip2 = new BLD_Account(uow).CIF('4').name('ip2').useImmediateParent(up1).CIFActiveCode('A');
		BLD_Account ip3 = new BLD_Account(uow).CIF('5').name('ip3').useImmediateParent(up1).CIFActiveCode('A');
		uow.commitWork();

		List<BLD_Opportunity> bOppsToBeWon = new List<BLD_Opportunity> ();

		uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account c0 = new BLD_Account(uow).CIF('6').name('c0').useChild(up0, up0).CIFActiveCode('A');
		new BLD_Product(uow).linkToOpp(
		                               new BLD_Opportunity(uow).client(c0).develop().currency(currencyIsoCode)
		).notionalValue(40).currency(currencyIsoCode);
		bOppsToBeWon.add(new BLD_Opportunity(uow).client(c0).develop().currency(currencyIsoCode));
		new BLD_Product(uow).linkToOpp(
		                               bOppsToBeWon[bOppsToBeWon.size() - 1]
		).notionalValue(20).currency(currencyIsoCode);

		BLD_Account c1 = new BLD_Account(uow).CIF('7').name('c1').useChild(ip0, up0).CIFActiveCode('A');
		bOppsToBeWon.add(new BLD_Opportunity(uow).client(c1).develop().currency(currencyIsoCode));
		new BLD_Product(uow).linkToOpp(
		                               bOppsToBeWon[bOppsToBeWon.size() - 1]
		).notionalValue(1).currency(currencyIsoCode);
		bOppsToBeWon.add(new BLD_Opportunity(uow).client(c1).develop().currency(currencyIsoCode));
		new BLD_Product(uow).linkToOpp(
		                               bOppsToBeWon[bOppsToBeWon.size() - 1]
		).notionalValue(30).currency(currencyIsoCode);
		new BLD_Product(uow).linkToOpp(
		                               new BLD_Opportunity(uow).client(c1).develop().currency(currencyIsoCode)
		).notionalValue(27).currency(currencyIsoCode);

		BLD_Account c2 = new BLD_Account(uow).CIF('8').name('c2').useChild(ip0, up1).CIFActiveCode('A');
		bOppsToBeWon.add(new BLD_Opportunity(uow).client(c2).develop().currency(currencyIsoCode));
		new BLD_Product(uow).linkToOpp(
		                               bOppsToBeWon[bOppsToBeWon.size() - 1]
		).notionalValue(3).currency(currencyIsoCode);
		new BLD_Product(uow).linkToOpp(
		                               new BLD_Opportunity(uow).client(c2).develop().currency(currencyIsoCode)
		).notionalValue(4).currency(currencyIsoCode);

		BLD_Account c3 = new BLD_Account(uow).CIF('9').name('c3').useChild(ip0, up1).CIFActiveCode('A');
		bOppsToBeWon.add(new BLD_Opportunity(uow).client(c3).develop().currency(currencyIsoCode));
		new BLD_Product(uow).linkToOpp(
		                               bOppsToBeWon[bOppsToBeWon.size() - 1]
		).notionalValue(1).currency(currencyIsoCode);
		bOppsToBeWon.add(new BLD_Opportunity(uow).client(c3).develop().currency(currencyIsoCode));
		new BLD_Product(uow).linkToOpp(
		                               bOppsToBeWon[bOppsToBeWon.size() - 1]
		).notionalValue(1).currency(currencyIsoCode);
		bOppsToBeWon.add(new BLD_Opportunity(uow).client(c3).develop().currency(currencyIsoCode));
		new BLD_Product(uow).linkToOpp(
		                               bOppsToBeWon[bOppsToBeWon.size() - 1]
		).notionalValue(1).currency(currencyIsoCode);

		BLD_Account c4 = new BLD_Account(uow).CIF('10').name('c4').useChild(ip1, up0).CIFActiveCode('A');
		bOppsToBeWon.add(new BLD_Opportunity(uow).client(c4).develop().currency(currencyIsoCode));
		new BLD_Product(uow).linkToOpp(
		                               bOppsToBeWon[bOppsToBeWon.size() - 1]
		).notionalValue(12).currency(currencyIsoCode);
		bOppsToBeWon.add(new BLD_Opportunity(uow).client(c4).develop().currency(currencyIsoCode));
		new BLD_Product(uow).linkToOpp(
		                               bOppsToBeWon[bOppsToBeWon.size() - 1]
		).notionalValue(14).currency(currencyIsoCode);

		BLD_Account c5 = new BLD_Account(uow).CIF('11').name('c5').useChild(ip1, up0).CIFActiveCode('A');

		BLD_Account c6 = new BLD_Account(uow).CIF('12').name('c6').useChild(ip3, up1).CIFActiveCode('A');
		new BLD_Product(uow).linkToOpp(
		                               new BLD_Opportunity(uow).client(c6).develop().currency(currencyIsoCode)
		).notionalValue(2).currency(currencyIsoCode);
		bOppsToBeWon.add(new BLD_Opportunity(uow).client(c6).develop().currency(currencyIsoCode));
		new BLD_Product(uow).linkToOpp(
		                               bOppsToBeWon[bOppsToBeWon.size() - 1]
		).notionalValue(3).currency(currencyIsoCode);

		BLD_Account c7 = new BLD_Account(uow).CIF('13').name('c7').useChild(ip2, up1).CIFActiveCode('A');
		new BLD_Product(uow).linkToOpp(
		                               new BLD_Opportunity(uow).client(c7).develop().currency(currencyIsoCode)
		).notionalValue(7).currency(currencyIsoCode);
		bOppsToBeWon.add(new BLD_Opportunity(uow).client(c7).develop().currency(currencyIsoCode));
		new BLD_Product(uow).linkToOpp(
		                               bOppsToBeWon[bOppsToBeWon.size() - 1]
		).notionalValue(6).currency(currencyIsoCode);

        Date lastDayOfCurrentMonth = Date.newInstance(system.Today().Year(), system.Today().Month()+1,1)-1;
        BLD_GlobalClientRevenue gcr = new BLD_GlobalClientRevenue(uow).currentAndPreviousYear()
            													.snapshotDate(lastDayOfCurrentMonth)
          														.clientValueZarCurrentYear(111)
          														.clientCIFNumber('0')
          														.client(up0);

		uow.commitWork();

		for (BLD_Opportunity op : bOppsToBeWon) {
			op.actualCloseDate(System.today());
			op.closedWon();
			op.registerDirty();
		}

		uow.commitWork();
		User stdUser;
		System.runAs(new User(Id = UserInfo.getUserId()))
		{
			stdUser = (User) new BLD_USER().useCommB().syncContact().commitWork().getRecord();
		}

		


	}
	@IsTest
	public static void noPermsToRead() {
		Decimal actualResult;
		Decimal expectedResult = 0.0;

		System.runAs(standardUser) {
			Test.startTest();
			actualResult = StdBank_Ltn_ClientsCYWonRevenueCtrl.getTotalWonRevenue(null);
			Test.stopTest();
		}
		System.assertEquals(expectedResult, actualResult);
	}

	@IsTest
	public static void fullPermsToRead() {
		Decimal actualResult;
		Decimal expectedResult = 2200;

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		for (Account acc :[SELECT id FROM Account]) {
			BLD_ClientTeam bCt = new BLD_ClientTeam(uow);
			bCt.account(acc.Id).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		}
		uow.commitWork();

		System.runAs(standardUser) {
			Test.startTest();
			actualResult = StdBank_Ltn_ClientsCYWonRevenueCtrl.getTotalWonRevenue(null);
			Test.stopTest();
		}
		System.assertEquals(expectedResult, actualResult);
	}

	@IsTest
	public static void permsOneAcc() {
		Decimal actualResult;
		Decimal expectedResult = 200;

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		for (Account acc :[SELECT id FROM Account WHERE Name = 'ip3']) {
		BLD_ClientTeam bCt = new BLD_ClientTeam(uow);
		bCt.account(acc.Id).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		}
		uow.commitWork();

		System.runAs(standardUser) {
			Test.startTest();
			actualResult = StdBank_Ltn_ClientsCYWonRevenueCtrl.getTotalWonRevenue(null);
			Test.stopTest();
		}
		System.assertEquals(expectedResult, actualResult);
	}

	@IsTest
	public static void permsOneAccWithId() {
		Decimal actualResult;
		Decimal expectedResult = 400;

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		Account acc = [SELECT id FROM Account WHERE Name = 'up1'];
		BLD_ClientTeam bCt = new BLD_ClientTeam(uow);
		bCt.account(acc.Id).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);

		uow.commitWork();

		System.runAs(standardUser) {
			Test.startTest();
			actualResult = StdBank_Ltn_ClientsCYWonRevenueCtrl.getTotalWonRevenue(acc.Id);
			Test.stopTest();
		}
		System.assertEquals(expectedResult, actualResult);
	}

	@IsTest
	public static void randomPerms() {
		Decimal actualResult;
		Decimal expectedResult = 1400;

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		for (Account acc :[SELECT id FROM Account WHERE Name = 'up1' or Name = 'c3' or Name = 'ip1']) {
			BLD_ClientTeam bCt = new BLD_ClientTeam(uow);
			bCt.account(acc.Id).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		}
		uow.commitWork();

		System.runAs(standardUser) {
			Test.startTest();
			actualResult = StdBank_Ltn_ClientsCYWonRevenueCtrl.getTotalWonRevenue(null);
			Test.stopTest();
		}
		System.assertEquals(expectedResult, actualResult);
	}

	@IsTest
	public static void randomPermsContextClient() {
		Decimal actualResult;
		Decimal expectedResult = 400;

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		Id accId;
		for (Account acc : [SELECT Name FROM Account WHERE Name IN ('up2', 'c3', 'ip1', 'c4')]) {
			if (acc.Name == 'c4') {
				accId = acc.Id;
			}
			BLD_ClientTeam bCt = new BLD_ClientTeam(uow);
			bCt.account(acc.Id).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		}
		uow.commitWork();

		System.runAs(standardUser) {
			Test.startTest();
			actualResult = StdBank_Ltn_ClientsCYWonRevenueCtrl.getTotalWonRevenue(accId);
			Test.stopTest();
		}
		System.assertEquals(expectedResult, actualResult);
	}
}