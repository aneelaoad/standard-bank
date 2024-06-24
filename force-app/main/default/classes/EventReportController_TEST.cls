/**
 * Test class for EventReportController
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		Description 2020
*/
@IsTest
public class EventReportController_TEST {

    public static final String TEST_CIB_USERNAME          = 'test.cibUser@test.com';
    public static final String TEST_COMMB_USERNAME        = 'test.commbUser@test.com';
    public static final String TEST_CREDIT_CREDIT_MANAGER_USERNAME = 'test.creditcreditmanager@test.com';
    private static User cibUser;
    private static User commbUser;
    private static User creditCreditManagerUser;

    private static void getData() {
        for (User u : [
                SELECT Username
                FROM User
                WHERE UserName IN:new String[]{
                        TEST_COMMB_USERNAME, TEST_CIB_USERNAME, TEST_CREDIT_CREDIT_MANAGER_USERNAME
                }
        ]) {
            if (u.UserName == TEST_COMMB_USERNAME) {
                commbUser = u;
            }
            if(u.UserName == TEST_CIB_USERNAME){
                cibUser = u;
            }
            if(u.UserName == TEST_CREDIT_CREDIT_MANAGER_USERNAME){
                creditCreditManagerUser = u;
            }
        }
    }

    @testSetup
    static void prepareData() {

        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            cibUser = (User)new BLD_USER(uow).userName(TEST_CIB_USERNAME).useCib().syncContact().getRecord();
            commbUser = (User) new BLD_USER(uow).userName(TEST_COMMB_USERNAME).useCommB().syncContact().getRecord();
            creditCreditManagerUser = (User) new BLD_USER(uow).userName(TEST_CREDIT_CREDIT_MANAGER_USERNAME).profile('Credit Credit Manager').getRecord();
            uow.commitWork();
        }
    }

    @IsTest
    static void shouldGetReport() {
        Call_Report__c callReportTest;
        Test.startTest();
        callReportTest =  EventReportController.getCallReport();
        Test.stopTest();
        System.assertNotEquals(null, callReportTest);
    }

    @IsTest
    static void shouldBeCommBUser() {
        getData();
        Boolean isCommB = false;
        System.runAs(commbUser) {
            Test.startTest();
            isCommB = EventReportController.isCommBUser();
            Test.stopTest();
            System.assert(isCommB);
        }
    }

    @IsTest
    static void shouldNotBeCommBUser() {
        getData();
        Boolean isCommB = true;
        System.runAs(cibUser) {
            Test.startTest();
            isCommB = EventReportController.isCommBUser();
            Test.stopTest();
            System.assert(!isCommB);
        }
    }

    @IsTest
    static void shouldBeSalesforceLicenseUser() {
        getData();
        System.runAs(cibUser) {
            Test.startTest();
            Boolean result = EventReportController.isSalesforceLicenseUser();
            Test.stopTest();
            System.assert(result);
        }
    }

    @IsTest
    static void shouldNotBeSalesforceLicenseUser() {
        getData();
        System.runAs(creditCreditManagerUser) {
            Test.startTest();
            Boolean result = EventReportController.isSalesforceLicenseUser();
            Test.stopTest();
            System.assert(!result);
        }
    }
}