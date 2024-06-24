@isTest
private class StdBank_Ltn_ClientQuickActions_Test {

    private static User CIBUser, CommBUser;
    private static String CIB_USERNAME = 'Cib_Test_User@testing.test',
            COMMB_USERNAME = 'CommB_Test_User@testing.test';

    private static void getData() {
        for (User usr : [
                SELECT Username, User_Division__c
                FROM User
                WHERE UserName = :CIB_USERNAME
                OR UserName = :COMMB_USERNAME
                LIMIT 3
        ]) {
            if (usr.UserName == CIB_USERNAME) {
                CIBUser = usr;
            }
            if (usr.UserName == COMMB_USERNAME) {
                CommBUser = usr;
            }
        }
    }

    @TestSetup
    private static void testSetup() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            CIBUser = (User) new BLD_USER(uow).userName(CIB_USERNAME).useCib().syncContact().getRecord();
            CommBUser = (User) new BLD_USER(uow).userName(COMMB_USERNAME).useCommB().syncContact().getRecord();
            uow.commitWork();
        }

    }

    @IsTest
    public static void shouldReturnTrueIfCIB() {
        getData();
        Boolean isCIB;
        Test.startTest();
        System.runAs(CIBUser) {
            isCIB = StdBank_Ltn_ClientQuickActions.getIsCIB();
        }
        Test.stopTest();
        System.assertEquals(true, isCIB);

    }

    @IsTest
    public static void shouldReturnFalseIfNotCIB() {
        getData();
        Boolean isNotCIB;
        Test.startTest();
        System.runAs(CommBUser) {
            isNotCIB = StdBank_Ltn_ClientQuickActions.getIsCIB();
        }
        Test.stopTest();
        System.assertEquals(false, isNotCIB);
    }

    @IsTest
    public static void shouldReturnTrueIfCommB() {
        getData();
        Boolean isCommB;
        Test.startTest();
        System.runAs(CommBUser) {
            isCommB = StdBank_Ltn_ClientQuickActions.getIsCommB();
        }
        Test.stopTest();
        System.assertEquals(true, isCommB);
    }

    @IsTest
    public static void shouldReturnCurrentUserId() {
        getData();
        Id userId;
        Test.startTest();
        System.runAs(CommBUser) {
            userId = StdBank_Ltn_ClientQuickActions.getCurrentUserId();
        }
        Test.stopTest();
        System.assertEquals(CommBUser.Id, userId);
    }

    @IsTest
    public static void shouldReturnAccount() {
        getData();
        Account acc = (Account) new BLD_Account().name('TESTACCOUNTEY').useCommB().useGroupParent().getRecord();
        Account account;
        System.runAs(CIBUser) {
            insert acc;
            Test.startTest();
            account = StdBank_Ltn_ClientQuickActions.getAccount(acc.Id);
            Test.stopTest();
        }
        System.assertEquals(acc.Name, account.Name);
    }

    @IsTest
    public static void shouldDoDevelop() {
        getData();
        Account acc = (Account) new BLD_Account().name('TESTACCOUNTEY').useCib().useGroupParent().clientCoordinator(CIBUser).getRecord();
        acc.KYC_Location__c = 'SBSA';
        acc.Client_Co_ordinator__c = CIBUser.Id;
        String result;
        System.runAs(CIBUser) {
            insert acc;
            Test.startTest();
            result = StdBank_Ltn_ClientQuickActions.doDevelop(acc);
            Test.stopTest();
        }
        StdBank_Ltn_BackendResult backendResult = (StdBank_Ltn_BackendResult) JSON.deserialize(result, StdBank_Ltn_BackendResult.class);
        System.assertEquals(true, backendResult.success);
        System.assertEquals(Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Potential Client').getRecordTypeId(),
                [SELECT RecordTypeId FROM Account WHERE Id = :acc.Id].RecordTypeId);

    }

}