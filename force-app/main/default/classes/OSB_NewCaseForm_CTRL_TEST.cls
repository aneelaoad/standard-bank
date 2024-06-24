/**
 * Test class for OSB_NewCaseForm_CTRL
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date March 2020
 */
@IsTest(IsParallel=true)
public with sharing class OSB_NewCaseForm_CTRL_TEST {
    private static final String TEST_USER_NAME = 'testNewCase@test123.com';
    private static User testUser {
        get {
            if(testUser == null) {
                testUser = [SELECT Id, ContactId FROM User WHERE Username = :TEST_USER_NAME LIMIT 1];
            }
            return testUser;
        }
        set;
    }

    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Contact con = (Contact) new BLD_Contact(uow)
                    .ownerId(UserInfo.getUserId())
                    .account(new BLD_Account(uow))
                    .getRecord();
        
        uow.commitWork();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            User u = (User) new BLD_USER()
                    .useOneHub()
                    .userName(TEST_USER_NAME)
                    .contactId(con.Id)
                    .commitWork().getRecord();
        }
    }

    @IsTest
    static void shouldCreateCase() {
        Case c = (Case) new BLD_Case().setOSBData().getRecord();

        Test.startTest();
        System.runAs(testUser) {
            OSB_NewCaseForm_CTRL.createCaseWithContactId(c);
        }
        Test.stopTest();
        Case createdCase = [SELECT Id, ContactId FROM Case WHERE CreatedById = :testUser.Id LIMIT 1];
        System.assertEquals(testUser.ContactId, createdCase.ContactId);
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    static void shouldGetPingUserDetails() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OSB_SRV_PingIntegration serviceMock = (OSB_SRV_PingIntegration) mocks.mock(OSB_SRV_PingIntegration.class);
        ORG_Application.service.setMock(OSB_SRV_PingIntegration.IService.class, serviceMock);
        Test.startTest();
        Map<String, String> result = OSB_NewCaseForm_CTRL.getPingUserDetails();
        Test.stopTest();
        ((OSB_SRV_PingIntegration) mocks.verify(serviceMock, 1)).
            getUserDetails();
    }

    @IsTest
    static void shouldGetUserContactDetails() {
        Map<String, String> result;
        Test.startTest();
        System.runAs(testUser) {
            result = OSB_NewCaseForm_CTRL.getUserContactDetails();
        }
        Test.stopTest();
        System.assertNotEquals(null, result.get('Email'));
    }

    @IsTest
    static void shouldCheckIfUserLoggedIn() {
        Test.startTest();
        Boolean result = OSB_NewCaseForm_CTRL.isUserLoggedIn();
        Test.stopTest();
        System.assert(result);
    }
}