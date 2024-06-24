@isTest
public class StdBank_Ltn_ClientsRevenueYTD_Test {
	private static User standardUser {
		get {
			if (standardUser == null) {
				System.runAs(new User(Id = UserInfo.getUserId()))
				{
					standardUser = (User) new BLD_USER().useCommB().syncContact().commitWork().getRecord();
				}
			}
			return standardUser;
		}
		Set;
	}

	@TestSetup
	private static void setup() {
		insert TEST_DataFactory.getUserProfileIds();
	}

	private static void createRevenues(fflib_SObjectUnitOfWork uow, BLD_Account client, List<Decimal> values) {
		for (Decimal value : values) {
			new BLD_GlobalClientRevenue(uow).currentAndPreviousYear().clientValueZarCurrentYear(value).client(client);
		}
	}

	private static testmethod void noRevenue() {
		String expectedValue = '';
		String actualValue;
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount = new BLD_Account(uow).useCommB();
		uow.commitWork();
		Test.startTest();
		System.runAs(standardUser) {
			actualValue = StdBank_Ltn_ClientsRevenueYTD.getTotalRevenue(bAccount.getRecordId());
		}
		Test.stopTest();
		System.assertEquals(expectedValue, actualValue);
	}

	private static testmethod void oneValueRevenue() {
		String expectedValue = String.valueOf(Math.roundToLong(100000000.00));
		String actualValue;
		List<Decimal> revValues = new List<Decimal> { 100000000.00 };
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount = new BLD_Account(uow).CIF('0').useCommB();
		new BLD_ClientTeam(uow).user(standardUser.Id).account(bAccount).role(DMN_ClientTeam.ROLE_COMMB_SERVICE_MANGER);
		createRevenues(uow, bAccount, revValues);
		uow.commitWork();
		Test.startTest();
		System.runAs(standardUser) {
			actualValue = StdBank_Ltn_ClientsRevenueYTD.getTotalRevenue(bAccount.getRecordId());
		}
		Test.stopTest();
		System.assertEquals(expectedValue, actualValue);
	}

	private static testmethod void variousClientRevenueOnly() {
		String expectedValue = '';
		String actualValue;
		List<Decimal> revValues = new List<Decimal> { 100000000.00 };
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount1 = new BLD_Account(uow).CIF('1').useCommB();
		BLD_Account bAccount0 = new BLD_Account(uow).CIF('0').useCommB();

		new BLD_ClientTeam(uow).user(standardUser.Id).account(bAccount1).role(DMN_ClientTeam.ROLE_COMMB_SERVICE_MANGER);
		new BLD_ClientTeam(uow).user(standardUser.Id).account(bAccount0).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER);
		createRevenues(uow, bAccount1, revValues);
		uow.commitWork();
		Test.startTest();
		System.runAs(standardUser) {
			actualValue = StdBank_Ltn_ClientsRevenueYTD.getTotalRevenue(bAccount0.getRecordId());
		}
		Test.stopTest();
		System.assertEquals(expectedValue, actualValue);
	}
	private static testmethod void manyRevenueValues() {
		String expectedValue = String.valueOf(Math.roundToLong(83));
		String actualValue;
		List<Decimal> revValues = new List<Decimal> { 1,4,5,30,43 };
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount = new BLD_Account(uow).CIF('0').useCommB();
		new BLD_ClientTeam(uow).user(standardUser.Id).account(bAccount).role(DMN_ClientTeam.ROLE_COMMB_SERVICE_MANGER);
		createRevenues(uow, bAccount, revValues);
		uow.commitWork();
		Test.startTest();
		System.runAs(standardUser) {
			actualValue = StdBank_Ltn_ClientsRevenueYTD.getTotalRevenue(bAccount.getRecordId());
		}
		Test.stopTest();
		System.assertEquals(expectedValue, actualValue);
	}
}