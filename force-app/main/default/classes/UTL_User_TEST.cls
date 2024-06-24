/**
 * Test class for UTL_User
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		JANUARY 2021
*/
@IsTest
private class UTL_User_TEST {
    private static final String WRONG_ID = fflib_IDGenerator.generate(Account.SObjectType);
    private static User usr;

    @TestSetup
    static void setup() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            usr = (User) new BLD_USER(uow)
                    .userName('utlUserTest@test.com')
                    .useCib()
                    .division('Transactional Products and Services')
                    .syncContact()
                    .getRecord();
            uow.commitWork();
        }
    }

    static void getData() {
        usr = [
                SELECT Id, ProfileId,
                        User_Division__c
                        FROM User
                WHERE Username = 'utlUserTest@test.com'
                LIMIT 1
        ];
    }

    @IsTest
    static void shouldThrowWrongUserIdException() {
        String errorMessage;
        Test.startTest();
        try {
            User usr = UTL_User.getCachedUser(WRONG_ID);
        } catch (UTL_User.UTL_UserException ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();
        System.assertEquals('Provided Id does not' +
                ' belong to User Object "' + WRONG_ID + '"', errorMessage);
    }

    @IsTest
    static void shouldReturnUser(){
        getData();
        System.debug(':o: ' + usr.Id);
        Test.startTest();
        UTL_User.cacheUsers(usr.Id);
        UTL_User.refreshCache();
        User resultUser = UTL_User.getCachedUser(usr.Id);
        Test.stopTest();
        System.assertEquals(usr.Id, resultUser.Id);

    }

    @IsTest
    static void shouldReturnUserFromList(){
        getData();
        List<Id> userId = new List<Id>{usr.Id};
        Test.startTest();
        UTL_User.cacheUsers((List<String>)userId);
        UTL_User.cacheUsers(new Set<Id>(userId));
        UTL_User.cacheUsers(userId);
        UTL_User.refreshCache();
        List<User> resultUser = UTL_User.getCachedUsers(userId);
        Test.stopTest();
        System.assertEquals(usr.Id, resultUser[0].Id);

    }

    @IsTest
    static void shouldBeLightningUser() {
        getData();
        System.runAs(usr) {
            Test.startTest();
            Boolean result = UTL_User.isLightnigUser();
            Test.stopTest();
            System.assert(!result);
        }
    }

    @IsTest
    static void shouldBeLoggedInUser() {
        getData();
        System.runAs(usr) {
            Test.startTest();
            Boolean result = UTL_User.isLoggedInUser();
            Test.stopTest();
            System.assert(result);
        }
    }

    @IsTest
    static void shouldNotBeCommBUser() {
        getData();
        System.runAs(usr) {
            Test.startTest();
            Boolean result = UTL_User.isCommBUser(usr.Id);
            Test.stopTest();
            System.assert(!result);
        }
    }

    @IsTest
    static void shouldN() {
        getData();
        System.runAs(usr) {
            Test.startTest();
            Boolean result = UTL_User.isAutomatedProcess();
            Test.stopTest();
            System.assert(!result);
        }
    }

    @IsTest
    static void shouldGetUserProfile() {
        getData();
        System.runAs(usr) {
            Test.startTest();
            Profile result = UTL_User.getUserProfile();
            Test.stopTest();
            System.assertEquals(usr.ProfileId, result.Id);
        }
    }

    @IsTest
    static void shouldGetUserDivision() {
        getData();
        System.runAs(usr) {
            Test.startTest();
            String result = UTL_User.getUserDivision();
            Test.stopTest();
            System.assertEquals(usr.User_Division__c, result);
        }
    }

    @IsTest
    static void shouldCheckIfExecUserReturnFalse() {
        getData();
        System.runAs(usr) {
            Test.startTest();
            Boolean result = UTL_User.checkIfExecUser();
            Test.stopTest();
            System.assert(!result);
        }
    }

    @IsTest
    static void shouldGetPbbClientsUser() {
        Test.startTest();
        User result = UTL_User.getPbbClientsUser();
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assert(result.Username.contains('pbb.clients@standardbank.co.za'));
    }
}