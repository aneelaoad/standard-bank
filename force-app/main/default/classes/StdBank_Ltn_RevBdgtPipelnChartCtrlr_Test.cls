@isTest
public class StdBank_Ltn_RevBdgtPipelnChartCtrlr_Test {

	private static String STD_USER_NAME = 'test923dia09er@testorg.com';
	private static Integer  revenueCurrentMonth = 1000;
	private static Integer  budgetNextYear = 3000;
	private static Integer oppProductCurrentYearFees = 20;
	private static final Integer DATA_SIZE = 8;

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
			TEST_DataFactory.getCIParameters(),
			TEST_DataFactory.getCstTeamRankings()
		});

		System.runAs(stdUser) {

			fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

	        Account ultimateGroupParent = (Account) new BLD_Account(uow).useGroupParent()
				.proposedClientCoordinator(stdUser)
				.getRecord();

			uow.commitWork();

			List<Opportunity> wonOpps = new List<Opportunity>();
	        for(Integer i = 0; i < DATA_SIZE; i++) {
	        	BLD_Account accBld = new BLD_Account(uow).usePotential()
					.proposedClientCoordinator(stdUser)
					.CIF(String.valueOf(i))
					.clientRelationshipHierarchy(DMN_Account.REL_HIERARCHY_IMMEDIATE)
					.parentId(ultimateGroupParent)
					.CIFActiveCode('A')
					.addContact(
						new BLD_Contact(uow).useClientContact()
					)
					.addOpportunity(
						new BLD_Opportunity(uow)
							.closeDate(System.today())
					)
					.addGlobalClientRevenue(
						new BLD_GlobalClientRevenue(uow).currentAndPreviousYear()
							.snapshotDate(System.today())
							.clientValueZARCurrentMonth(revenueCurrentMonth)
							.budgetZARNextYear(budgetNextYear)
					);
				wonOpps.add(
					(Opportunity) new BLD_Opportunity(uow)
						.client(accBld)
						.closeDate(System.today())
						.addProduct(
							new BLD_Product(uow)
								.currentYearMargin(0)
								.currentYearFees(oppProductCurrentYearFees)
						)
						.getRecord()
				);
	        }

			uow.commitWork();

	        for (Integer i=0;i<wonOpps.size()/2; i++) {
	        	Opportunity opp = wonOpps[i];
        		opp.StageName = OpportunityService.STAGE_CLOSED_WON;
                opp.ReasonForWinLossPickList__c = 'Pricing Competitive';
                opp.Reason_Won_Lost_Detail__c = 'Pricing Competitive';
        		opp.Reason_Won_Lost_Comments__c = 'Testing purpose';
	        }

	        update wonOpps;

	    }
	}

	@isTest static void testGetRevenueByMonth() {
		List<Decimal> actualRevenueByMonth;
		Decimal expectedLastMonthRevenue;

		System.runAs(standardUser) {
			//throw new DmlException('!!## ' + [SELECT Client__c, Snapshot_Date__c FROM Global_Client_Revenue__c]);
			/*AggregateResult[] aggrRevenues = StdBank_Ltn_ClientsStatisticsController.getAggregatedRevenues();
			expectedRevenue = StdBank_Ltn_ClientsStatisticsController.getVeluesByMonth(aggrRevenues, 'month', 'revenue', true);
*/
			Test.startTest();
				actualRevenueByMonth = StdBank_Ltn_RevBdgtPipelnChartController.getRevenueByMonth();
			Test.stopTest();
		}
		expectedLastMonthRevenue = DATA_SIZE * revenueCurrentMonth;
		System.assertEquals(System.today().month(), actualRevenueByMonth.size());
		System.assertEquals(expectedLastMonthRevenue, actualRevenueByMonth[actualRevenueByMonth.size()-1]);
	}

	@isTest static void testGetBudgetByMonth() {
		List<Decimal> actualBudgetByMonth;
		Decimal expectedLastMonthBudget;

		System.runAs(standardUser) {
			/*AggregateResult[] aggrBudgets = StdBank_Ltn_ClientsStatisticsController.getAggregatedRevenues();
			expectedBudget = StdBank_Ltn_ClientsStatisticsController.getVeluesByMonth(aggrBudgets, 'month', 'budget', false);
*/
			Test.startTest();
				actualBudgetByMonth = StdBank_Ltn_RevBdgtPipelnChartController.getBudgetByMonth();
			Test.stopTest();
		}

		expectedLastMonthBudget = DATA_SIZE * budgetNextYear;
		System.assertEquals(System.today().month(), actualBudgetByMonth.size());
		System.assertEquals(expectedLastMonthBudget, actualBudgetByMonth[actualBudgetByMonth.size()-1]);
		//System.assertEquals(expectedBudget, actualBudget);
	}

	@isTest static void testGetTotalPipeline() {
		Decimal actualPipeline;
		Decimal expectedPipeline;

		System.runAs(standardUser) {
			//expectedPipeline = StdBank_Ltn_ClientsCYPipelineController.getTotalPipeline();

			Test.startTest();
				actualPipeline = StdBank_Ltn_RevBdgtPipelnChartController.getTotalPipeline();
			Test.stopTest();	
		}
		expectedPipeline = DATA_SIZE/2 *oppProductCurrentYearFees;
		System.assertEquals(expectedPipeline, actualPipeline);
	}

	@isTest static void testGetWonOppRevenueByMonth() {
		List<Decimal> actualRevenueByMonth;
		Decimal expectedLastMonthRevenue;

		System.runAs(standardUser) {
			/*AggregateResult[] aggrWonRevenues = StdBank_Ltn_ClientsStatisticsController.getAggregatedWonRevenues();
			expectedRevenue = StdBank_Ltn_ClientsStatisticsController.getVeluesByMonth(aggrWonRevenues, 'month', 'revenue', true);
*/
			Test.startTest();
				actualRevenueByMonth = StdBank_Ltn_RevBdgtPipelnChartController.getWonOppRevenueByMonth();
			Test.stopTest();		
		}
		expectedLastMonthRevenue = DATA_SIZE/2 *oppProductCurrentYearFees;
		System.assertEquals(System.today().month(), actualRevenueByMonth.size());
		System.assertEquals(expectedLastMonthRevenue, actualRevenueByMonth[actualRevenueByMonth.size()-1]);
	}

}