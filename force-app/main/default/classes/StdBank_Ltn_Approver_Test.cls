@isTest
private class StdBank_Ltn_Approver_Test {
    @TestSetup
    static void prepareData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getCstTeamRankings()
        });
    }
    
    static void setupApproval(Account testAccount) {
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();

        request.setObjectId(testAccount.Id);

        Approval.ProcessResult result = Approval.process(request);

        System.assert(result.isSuccess());
        System.assertEquals(
                'Pending', result.getInstanceStatus(),
                'Instance Status'+result.getInstanceStatus()
        );
    }

    @isTest
    static void testGetData() {
        User testUser;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            testUser = (User) new BLD_USER().useCib().syncContact().commitWork().getRecord();
        }

        Account testAccount = (Account) new BLD_Account().usePotential()
            .proposedClientCoordinator(testUser)
            .sector(DMN_Account.UNKNOWN_SECTOR)
            .subSector(DMN_Account.UNKNOWN_SUB_SECTOR)
            .clientRelationshipHierarchy(DMN_Account.REL_HIERARCHY_ULTIMATE)
            .commitWork()
            .getRecord();

        setupApproval(testAccount);

        Test.startTest();

        System.runAs(testUser) {
            List<ProcessInstanceWorkitem> result = StdBank_Ltn_Approver.getData();

            System.assertEquals(false, result.isEmpty(), 'Returned list is empty!');
            System.assertEquals(1, result.size(), 'Returned list should contain one item!');
        }

        Test.stopTest();
    }

    @isTest
    static void testGetUsers() {
        System.assertNotEquals(0, StdBank_Ltn_Approver.getUsers().size(), 'Method could not return empty list!');
    }

    @isTest
    static void testApprove() {
        User testUser;

        System.runAs(new User(Id = UserInfo.getUserId())) {
             testUser = (User) new BLD_USER().useCib().syncContact().commitWork().getRecord();
        }

        Account testAccount = (Account) new BLD_Account().usePotential()
            .proposedClientCoordinator(testUser)
            .sector(DMN_Account.UNKNOWN_SECTOR)
            .subSector(DMN_Account.UNKNOWN_SUB_SECTOR)
            .clientRelationshipHierarchy(DMN_Account.REL_HIERARCHY_ULTIMATE)
            .commitWork()
            .getRecord();

        setupApproval(testAccount);

        Test.startTest();

        System.runAs(testUser) {
            List<ProcessInstanceWorkitem> result = StdBank_Ltn_Approver.getData();

            System.assertEquals(false, result.isEmpty(), 'Returned list is empty!');
            System.assertEquals(1, result.size(), 'Returned list should contain one item!');

            StdBank_Ltn_Approver.approve(result.get(0).Id, 'Approval test!');
        }

        Test.stopTest();
    }
    
    @isTest
    static void testReject() {
        User testUser ;

        System.runAs(new User(Id = UserInfo.getUserId())) {
             testUser = (User) new BLD_USER().useCib().division('Client Coverage').syncContact().commitWork().getRecord();
        }

        Account testAccount = (Account) new BLD_Account().usePotential()
            .proposedClientCoordinator(testUser)
            .sector(DMN_Account.UNKNOWN_SECTOR)
            .subSector(DMN_Account.UNKNOWN_SUB_SECTOR)
            .clientRelationshipHierarchy(DMN_Account.REL_HIERARCHY_ULTIMATE)
            .commitWork()
            .getRecord();

        setupApproval(testAccount);

        Test.startTest();

        System.runAs(testUser) {
            List<ProcessInstanceWorkitem> result = StdBank_Ltn_Approver.getData();

            System.assertEquals(false, result.isEmpty(), 'Returned list is empty!');
            System.assertEquals(1, result.size(), 'Returned list should contain one item!');

            StdBank_Ltn_Approver.reject(result.get(0).Id, 'Rejection test!');
        }

        Test.stopTest();
    }

    @isTest
    static void testReassign() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User testUser = (User) new BLD_USER(uow).useCib().syncContact().getRecord();
        User testUser1 = (User) new BLD_USER(uow).useSysAdmin().syncContact().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }

        Account testAccount = (Account) new BLD_Account().usePotential()
            .proposedClientCoordinator(testUser)
            .sector(DMN_Account.UNKNOWN_SECTOR)
            .subSector(DMN_Account.UNKNOWN_SUB_SECTOR)
            .clientRelationshipHierarchy(DMN_Account.REL_HIERARCHY_ULTIMATE)
            .commitWork()
            .getRecord();

        setupApproval(testAccount);

        Test.startTest();

        System.runAs(testUser) {
            List<ProcessInstanceWorkitem> result = StdBank_Ltn_Approver.getData();

            System.assertEquals(false, result.isEmpty(), 'Returned list is empty!');
            System.assertEquals(1, result.size(), 'Returned list should contain one item!');
            StdBank_Ltn_Approver.reassign(result.get(0).Id,testUser1.Id );
        }

        Test.stopTest();
    }
}