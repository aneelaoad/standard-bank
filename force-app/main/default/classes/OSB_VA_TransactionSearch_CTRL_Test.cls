/**
 *
 * @description Test class for OSB_VA_TransactionSearch_CTRL_Test
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 */
@IsTest
@SuppressWarnings('PMD.UnusedLocalVariable')
public with sharing class OSB_VA_TransactionSearch_CTRL_Test {

    private static final String TEST_USER_EMAIL = 'randomname3533@test.com';
    private static final String TEST_USER_FIRST_NAME = 'Random5';
    private static final String TEST_USER_LAST_NAME = 'Name9';
    private static final String COMPANY_NAME = 'Company1';
    private static final String USER_PROFILE = 'Client Service User';
    private static final String USER_COUNTRY = 'Mauritius';
    private static final String CONTACT_OPERATING_COUNTRY = 'Mauritius';
    private static final String DCS_PERMISSION_SET = 'DCS_Permissions_User';
    private static final String COUNTRY_PUBLIC_GROUP = 'Mauritius_CS_Group';

    @TestSetup
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
            BLD_Account accBld = new BLD_Account(uow).CIF('12345');
            BLD_Contact conBld = new BLD_Contact(uow)
                    .name(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME)
                    .email(TEST_USER_EMAIL)
                    .ownerId(UserInfo.getUserId())
                    .cifNumber('12345')
                    .communityAccessRole(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP)
                    .account(accBld)
                    .operatingCountry(CONTACT_OPERATING_COUNTRY);
            uow.commitWork();
            fflib_SObjectUnitOfWork uow2 = ABS_ObjectBuilderBase.getNewUnitOfWork(new List<SObjectType>{
                    Permissions__c.getSObjectType(),
                    Financial_Account__c.getSObjectType(), Financial_Account_Permission__c.getSObjectType()
            });
            BLD_Permissions permissionBld = new BLD_Permissions(uow2).name('Payment tracking');
            BLD_FinancialAccount financialAccountBld = new BLD_FinancialAccount(uow2)
                    .client(accBld)
                    .name('John')
                    .externalId('23131321374');
            BLD_FinancialAccountPermission finAccPermBld = new BLD_FinancialAccountPermission(uow2)
                    .financialAccount(financialAccountBld)
                    .permission(permissionBld)
                    .active(true)
                    .authorizedPerson(conBld);
            uow2.commitWork();
        }
    }

    @IsTest
    public static void testRequestError(){
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(200, 'OK', null, null);
        Test.setMock(HttpCalloutMock.class, mock);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        List<OSB_VA_TransactionSearch_CTRL.TransactionLookupInput> inputs = new List<OSB_VA_TransactionSearch_CTRL.TransactionLookupInput>();
        OSB_VA_TransactionSearch_CTRL.TransactionLookupInput input = new OSB_VA_TransactionSearch_CTRL.TransactionLookupInput();
        input.contactId = con.Id;
        input.transactionReference = '201211PN-SAINT-U-S14456366';
        inputs.add(input);
        Test.startTest();
        List<OSB_VA_TransactionLookupOutput> result =  OSB_VA_TransactionSearch_CTRL.getTransaction(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should return one message');
        System.assertEquals(System.Label.OSB_VA_PT_TechnicalErrorSingle, result.get(0).errorOutPutMessage, 'Message should indicate that payment has not been found');
    }

    @IsTest
    public static void testResponseError(){
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(404, 'Not Found', '', null);
        Test.setMock(HttpCalloutMock.class, mock);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        List<OSB_VA_TransactionSearch_CTRL.TransactionLookupInput> inputs = new List<OSB_VA_TransactionSearch_CTRL.TransactionLookupInput>();
        OSB_VA_TransactionSearch_CTRL.TransactionLookupInput input = new OSB_VA_TransactionSearch_CTRL.TransactionLookupInput();
        input.contactId = con.Id;
        input.transactionReference = '201211PN-SAINT-U-S14456366';
        inputs.add(input);
        Test.startTest();
        List<OSB_VA_TransactionLookupOutput> result = OSB_VA_TransactionSearch_CTRL.getTransaction(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should return one message');
        System.assertEquals(System.Label.OSB_VA_PT_TechnicalErrorSingle, result.get(0).errorOutPutMessage, 'Message should indicate that payment has not been found');
    }

    @IsTest
    public static void testResponseOkEmptyBody() {
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(200, 'OK', '{"test":"test"}', null);
        Test.setMock(HttpCalloutMock.class, mock);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        List<OSB_VA_TransactionSearch_CTRL.TransactionLookupInput> inputs = new List<OSB_VA_TransactionSearch_CTRL.TransactionLookupInput>();
        OSB_VA_TransactionSearch_CTRL.TransactionLookupInput input = new OSB_VA_TransactionSearch_CTRL.TransactionLookupInput();
        input.contactId = con.Id;
        input.transactionReference = '201211PN-SAINT-U-S14456366';
        inputs.add(input);
        Test.startTest();
        List<OSB_VA_TransactionLookupOutput> result = OSB_VA_TransactionSearch_CTRL.getTransaction(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should return one message');
        System.assertEquals(System.Label.OSB_VA_PT_TRInvalid, result.get(0).errorOutPutMessage, 'Expected: ' + System.Label.OSB_VA_PT_TRInvalid);
    }

    @IsTest
    public static void testResponseOkNoPermission() {
        String body = '{"messages":[{"amhAmount":121,"amhCurrency":"ZAR","orderingAccount":"/231313213741/MELCO CONVEYOR","currency":["ZAR"],"fin33Currency":["ZAR"],"fin33Amount":[121],"fin32Currency":["ZAR"],"fin57":["CITIUS30XXX"],"receiver":"CITIUS30XXX","transactionReference":"201207PN-SAINT-U-S14431378","fin50":["/231313213742"],"UETR":"b3c159e9-ecd9-4710-bcb6-f4e7c4f23760","amhAccount":"CITIUS30XXX","sender":"SBZAZAJ0XXX","mdate":1607299200000,"beneficiaryAccount":"//926378841/JUDITH A WEST","fin32Amount":[1312],"account":["/92637884"]}]}';
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(200, 'OK', body, null);
        Test.setMock(HttpCalloutMock.class, mock);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        List<OSB_VA_TransactionSearch_CTRL.TransactionLookupInput> inputs = new List<OSB_VA_TransactionSearch_CTRL.TransactionLookupInput>();
        OSB_VA_TransactionSearch_CTRL.TransactionLookupInput input = new OSB_VA_TransactionSearch_CTRL.TransactionLookupInput();
        input.contactId = con.Id;
        input.transactionReference = '201207PN-SAINT-U-S14431378';
        inputs.add(input);
        Test.startTest();
        List<OSB_VA_TransactionLookupOutput> result = OSB_VA_TransactionSearch_CTRL.getTransaction(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should return one message');
        System.assertEquals('You currently don\'t have access to this account information. Please contact your team administrator to grant you access.', result.get(0).errorOutPutMessage);
    }

    @IsTest
    public static void testResponseOkWithPermission() {
        String body = '{"messages":[{"amhAmount":121,"amhCurrency":"ZAR","orderingAccount":"/23131321374/MELCO CONVEYOR","currency":["ZAR"],"fin33Currency":["ZAR"],"fin33Amount":[121],"fin32Currency":["ZAR"],"fin57":["CITIUS30XXX"],"receiver":"CITIUS30XXX","transactionReference":"201207PN-SAINT-U-S14431378","fin50":["/23131321374"],"UETR":"b3c159e9-ecd9-4710-bcb6-f4e7c4f23760","amhAccount":"CITIUS30XXX","sender":"SBZAZAJ0XXX","mdate":1607299200000,"beneficiaryAccount":"//926378841/JUDITH A WEST","fin32Amount":[1312],"account":["/92637884"]}]}';
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(200, 'OK', body, null);
        Test.setMock(HttpCalloutMock.class, mock);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        List<OSB_VA_TransactionSearch_CTRL.TransactionLookupInput> inputs = new List<OSB_VA_TransactionSearch_CTRL.TransactionLookupInput>();
        OSB_VA_TransactionSearch_CTRL.TransactionLookupInput input = new OSB_VA_TransactionSearch_CTRL.TransactionLookupInput();
        input.contactId = con.Id;
        input.transactionReference = '201207PN-SAINT-U-S14431378';
        inputs.add(input);
        Test.startTest();
        List<OSB_VA_TransactionLookupOutput> result = OSB_VA_TransactionSearch_CTRL.getTransaction(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should return one message');
        System.assertEquals(null, result.get(0).errorOutPutMessage, 'Expected null');
    }
}