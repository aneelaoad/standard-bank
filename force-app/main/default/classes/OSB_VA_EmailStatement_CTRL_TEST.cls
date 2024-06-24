/**
 *
 * @description Test class for OSB_VA_EmailStatement_CTRL
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 * 
 * @lastModified by Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
@IsTest
public with sharing class OSB_VA_EmailStatement_CTRL_TEST {

    private static final String TEST_USER_EMAIL = 'randomname3533@test.com';
    private static final String TEST_USER_FIRST_NAME = 'Random5';
    private static final String TEST_USER_LAST_NAME = 'Name9';
    private static final String BALANCE_INQUIRY = 'Balance inquiry';
    private static final String EMAIL_STATEMENT = 'Email statement';
    private static final String COMPANY_NAME = 'Company1';
    private static final String USER_PROFILE = 'Client Service User';
    private static final String USER_COUNTRY = 'Mauritius';
    private static final String CONTACT_OPERATING_COUNTRY = 'Mauritius';
    private static final String DCS_PERMISSION_SET = 'DCS_Permissions_User';
    private static final String COUNTRY_PUBLIC_GROUP = 'Mauritius_CS_Group';

    @TestSetup
    @SuppressWarnings('PMD.UnusedLocalVariable')
    static void setup() {
        fflib_SObjectUnitOfWork uow0 = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User userCST = (User) new BLD_USER(uow0)
                .email(TEST_USER_EMAIL)
                .profile(USER_PROFILE)
                .country(USER_COUNTRY)
                .getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow0.commitWork();
        }
        
        PermissionSet ps = [SELECT Id, Name, Label FROM PermissionSet WHERE Name = :DCS_PERMISSION_SET];
        insert new PermissionSetAssignment(AssigneeId = userCST.Id, PermissionSetId = ps.Id);
        // Assign testUser to Public Group 
        Group pg = [SELECT Id FROM Group WHERE DeveloperName = :COUNTRY_PUBLIC_GROUP];
        insert new GroupMember(UserOrGroupId = userCST.Id, GroupId = pg.Id);

        system.runAs(userCST){
                fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
                BLD_Account accBld1 = new BLD_Account(uow).CIF('12345').Name(COMPANY_NAME);
                BLD_Contact conBld = new BLD_Contact(uow)
                        .name(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME)
                        .email(TEST_USER_EMAIL)
                        .ownerId(UserInfo.getUserId())
                        .cifNumber('12345')
                        .communityAccessRole(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP)
                        .account(accBld1)
                        .operatingCountry(CONTACT_OPERATING_COUNTRY);
                uow.commitWork();
                fflib_SObjectUnitOfWork uow2 = ABS_ObjectBuilderBase.getNewUnitOfWork(new List<SObjectType>{
                        Permissions__c.getSObjectType(),
                        Financial_Account__c.getSObjectType(),
                        Financial_Account_Permission__c.getSObjectType()
                });
                BLD_Permissions permissionBld1 = new BLD_Permissions(uow2).name(EMAIL_STATEMENT);
                BLD_FinancialAccount financialAccountBld1 = new BLD_FinancialAccount(uow2)
                        .client(accBld1)
                        .name(COMPANY_NAME)
                        .externalId('9090000104428');
                BLD_FinancialAccountPermission finAccPermBld1 = new BLD_FinancialAccountPermission(uow2)
                        .financialAccount(financialAccountBld1)
                        .permission(permissionBld1)
                        .active(true)
                        .authorizedPerson(conBld);
                uow2.commitWork();
        }       
    }

    @IsTest
    public static void testSuccessScenario(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);
        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
                .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        String responseBody = '{"access_token":"B684723E8E51DD98FA6BBF83BBBEA462D5342E84","refresh_token":"19C0030231692F4744475F1B921A253EBDE1FFE3","token_type":"bearer","expires_in":20}';
        OSB_VA_EmailStatement_CTRL.EmailStatementInput input = new OSB_VA_EmailStatement_CTRL.EmailStatementInput();
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        con.OSB_Passport_Number__c = '12345678';
        upsert con;
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'I would like to choose my own date range';
        input.statementEnd = Date.today().addDays(-50);
        input.statementStart = Date.today().addDays(-10);
        List<OSB_VA_EmailStatement_CTRL.EmailStatementInput> inputs = new List<OSB_VA_EmailStatement_CTRL.EmailStatementInput>{input};
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', responseBody, null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        OSB_SRV_BotStatementHandler.doChainJob = false;
        Test.startTest();
        List<OSB_VA_EmailStatement_CTRL.EmailStatementOutput> result = OSB_VA_EmailStatement_CTRL.emailStatement(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');    
    }

    @IsTest
    public static void testSuccessScenarioWithTimePeriod30(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);
        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
                .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);

        OSB_VA_EmailStatement_CTRL.EmailStatementInput input = new OSB_VA_EmailStatement_CTRL.EmailStatementInput();
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'Last 30 days';
        input.statementEnd = null;
        input.statementStart = null;
        List<OSB_VA_EmailStatement_CTRL.EmailStatementInput> inputs = new List<OSB_VA_EmailStatement_CTRL.EmailStatementInput>{input};
        OSB_SRV_BotStatementHandler.doChainJob = false;
        Test.startTest();
        List<OSB_VA_EmailStatement_CTRL.EmailStatementOutput> result = OSB_VA_EmailStatement_CTRL.emailStatement(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');    
   }

    @IsTest
    public static void testSuccessScenarioWithTimePeriod7(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);
        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
                .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);

        OSB_VA_EmailStatement_CTRL.EmailStatementInput input = new OSB_VA_EmailStatement_CTRL.EmailStatementInput();
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'Last 7 days';
        input.statementEnd = null;
        input.statementStart = null;
        List<OSB_VA_EmailStatement_CTRL.EmailStatementInput> inputs = new List<OSB_VA_EmailStatement_CTRL.EmailStatementInput>{input};
        OSB_SRV_BotStatementHandler.doChainJob = false;
        Test.startTest();
        List<OSB_VA_EmailStatement_CTRL.EmailStatementOutput> result = OSB_VA_EmailStatement_CTRL.emailStatement(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');    
   }
}