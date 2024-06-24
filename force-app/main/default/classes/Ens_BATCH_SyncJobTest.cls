/**
 * Test class for Ens_BATCH_SyncJob
 * @author Atul
 * @date 2023-01-30
 */
@istest
public class Ens_BATCH_SyncJobTest {	    
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
            .CIF('23652')
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
			uow.commitWork();
		}
    }

    testmethod static void scheduleBatchTest(){
        Test.startTest();        
        new Ens_BATCH_SyncJob(date.today()).scheduleFirstJob();
        Test.stopTest();
    }                
}