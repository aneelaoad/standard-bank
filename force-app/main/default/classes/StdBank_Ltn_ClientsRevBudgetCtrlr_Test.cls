@isTest
public class StdBank_Ltn_ClientsRevBudgetCtrlr_Test {

	private static String STD_USER_NAME = 'testera4waw34aw@testorg.com';
	private static Integer  revenueCurrentMonth = 1000;
	private static Integer  budgetNextYear = 3000;
	private static final Integer NUMBER_OF_RECS = 5;

	private static User standardUser {
		get {
			if (standardUser == null) {
				standardUser = [SELECT Id FROM User WHERE Username = :STD_USER_NAME LIMIT 1];
			}
			return standardUser;
		}
	}
	
	@testSetup
	static void setupData() {
		User stdUser = (User) new BLD_USER(STD_USER_NAME).useCib().getRecord();

		System.runAs(new User(Id = UserInfo.getUserId())) {
			insert stdUser;
		}

		TEST_DataFactory.insertSettings(new List<Object> {
			TEST_DataFactory.getCcSettings(),
			TEST_DataFactory.getUserProfileIds(),
			TEST_DataFactory.getCstTeamRankings()
		});

		System.runAs(stdUser) {

	        Account ultimateGroupParent = (Account) new BLD_Account().useGroupParent()
				.proposedClientCoordinator(stdUser)
				.commitWork()
				.getRecord();

			fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

	        for(Integer i = 0; i < NUMBER_OF_RECS; i++) {
				new BLD_Account(uow).usePotential()
					.proposedClientCoordinator(stdUser)
					.CIF(String.valueOf(i))
					.clientRelationshipHierarchy(DMN_Account.REL_HIERARCHY_IMMEDIATE)
					.parentId(ultimateGroupParent)
					.addGlobalClientRevenue(
						new BLD_GlobalClientRevenue(uow).currentAndPreviousYear()
							.snapshotDate(System.today())
							.clientValueZARCurrentMonth(revenueCurrentMonth)
							.budgetZARNextYear(budgetNextYear)
					);
	        }

			uow.commitWork();
	    }
	}

	@isTest static void testGetTotalRevenue() {
		Decimal actualRevenue;
		Decimal expectedReveneue;

		System.runAs(standardUser) {
			/*AggregateResult[] aggregatedRevs = StdBank_Ltn_ClientsStatisticsController.getAggregatedRevenues();
			expectedReveneue = 0;

			List<Decimal> revenueByMonth = StdBank_Ltn_ClientsStatisticsController.getVeluesByMonth(aggregatedRevs, 'month', 'revenue', false);
			if(!revenueByMonth.isEmpty())
				expectedReveneue = revenueByMonth[revenueByMonth.size()-1];*/

			Test.startTest();
				actualRevenue = StdBank_Ltn_ClientsRevBudgetController.getTotalRevenue();
			Test.stopTest();	
		}
		expectedReveneue = NUMBER_OF_RECS * revenueCurrentMonth;
		System.assertEquals(expectedReveneue, actualRevenue);
	}

	@isTest static void testGetTotalBudget() {
		Decimal actualBudget;
		Decimal expectedBudget;

		System.runAs(standardUser) {
			/*AggregateResult[] aggregatedBudgets = StdBank_Ltn_ClientsStatisticsController.getAggregatedRevenues();
			expectedBudget = 0;

			List<Decimal> budgetByMonth = StdBank_Ltn_ClientsStatisticsController.getVeluesByMonth(aggregatedBudgets, 'month', 'budget', false);
			if(!budgetByMonth.isEmpty())
				expectedBudget = budgetByMonth[budgetByMonth.size()-1];*/

			Test.startTest();
				actualBudget = StdBank_Ltn_ClientsRevBudgetController.getTotalBudget();
			Test.stopTest();	
		}
		expectedBudget = NUMBER_OF_RECS * budgetNextYear;
		System.assertEquals(expectedBudget, actualBudget);
	}

	@isTest static void testGetUserIsoCode(){
		String actualIsoCode;
		String expectedIsoCode;

		System.runAs(standardUser) {
			expectedIsoCode = UserInfo.getDefaultCurrency();

			Test.startTest();
			actualIsoCode = StdBank_Ltn_ClientsRevBudgetController.getUserIsoCode();
			Test.stopTest();
		}

		System.assertEquals(expectedIsoCode, actualIsoCode);
	}

}