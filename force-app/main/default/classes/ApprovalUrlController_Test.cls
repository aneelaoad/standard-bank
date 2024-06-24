@isTest
 private class ApprovalUrlController_Test {
    @TestSetup
    static void prepareData() {
        insert TEST_DataFactory.getEnvironmentVariable();
        insert TEST_DataFactory.getCcSettings();
        insert TEST_DataFactory.getCstTeamRankings();
    }
    @isTest
    static void testApproval() {
        User testUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            testUser  = (User) new BLD_USER().useCib().syncContact().commitWork().getRecord();
        }

        Account testAccount =  (Account) new BLD_Account().usePotential()
            .sector(DMN_Account.UNKNOWN_SECTOR)
            .subSector(DMN_Account.UNKNOWN_SUB_SECTOR)
            .clientRelationshipHierarchy(DMN_Account.REL_HIERARCHY_ULTIMATE)
            .proposedClientCoordinator(testUser)
            .commitWork()
            .getRecord();

        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();

        request.setObjectId(testAccount.Id);

        Approval.ProcessResult result = Approval.process(request);
        String url = ApprovalUrlController.createApprovalURL(testAccount.Id);
        System.assertNotEquals('', url);
    }
}