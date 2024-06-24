@IsTest
private class NBACPdfFromController_Test {
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
    private static void testPDFQuery() {
        NBACPdfFromController nbacPDF;

        nbacPDF = new NBACPdfFromController();

        Test.startTest();
        System.runAs(standardUser) {
            try {
                nbacPDF.getOpportunityTeam();
                nbacPDF.getTeam();
                nbacPDF.getActionItems();
            }
            catch(Exception ex) {
                System.assert(false);
            }
        }
        Test.stopTest();
    }
}