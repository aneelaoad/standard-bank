/**
 * @description Test class for OSB_VA_AvailableClients
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 */
@IsTest
@SuppressWarnings('PMD.UnusedLocalVariable')
public with sharing class OSB_VA_AvailableClients_TEST {

    private static final String TEST_USER_EMAIL = 'randomname3533@test.com';
    private static final String TEST_USER_FIRST_NAME = 'Random5';
    private static final String TEST_USER_LAST_NAME = 'Name9';
    private static final String BALANCE_INQUIRY = 'Balance inquiry';
    private static final String EMAIL_STATEMENT = 'Email statement';
    private static final String COMPANY_NAME = 'Company1';
    private static final String USER_PROFILE = 'Client Service User'; // System Administrator
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
                BLD_Account accBld1 = new BLD_Account(uow)
                        .CIF('12345')
                        .Name('Company1');
                BLD_Account accBld2 = new BLD_Account(uow)
                        .CIF('12346')
                        .Name('Company2');
                BLD_Contact conBld = new BLD_Contact(uow)
                        .name(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME)
                        .email(TEST_USER_EMAIL)
                        .ownerId(UserInfo.getUserId())
                        .cifNumber('12345')
                        .communityAccessRole(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP)
                        .account(accBld1)
                        .operatingCountry(CONTACT_OPERATING_COUNTRY);
                BLD_Contact conBld2 = new BLD_Contact(uow)
                        .name(TEST_USER_FIRST_NAME + '1', TEST_USER_LAST_NAME + '1')
                        .email(TEST_USER_EMAIL)
                        .ownerId(UserInfo.getUserId())
                        .cifNumber('12346')
                        .communityAccessRole(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP)
                        .account(accBld2)
                        .operatingCountry(CONTACT_OPERATING_COUNTRY);
                uow.commitWork();

                fflib_SObjectUnitOfWork uow2 = ABS_ObjectBuilderBase.getNewUnitOfWork(new List<SObjectType>{
                        Permissions__c.getSObjectType(),
                        Financial_Account__c.getSObjectType(),
                        Financial_Account_Permission__c.getSObjectType()
                });
                BLD_Permissions permissionBld1 = new BLD_Permissions(uow2).name(BALANCE_INQUIRY);
                BLD_Permissions permissionBld2 = new BLD_Permissions(uow2).name(EMAIL_STATEMENT);
                BLD_FinancialAccount financialAccountBld1 = new BLD_FinancialAccount(uow2)
                        .client(accBld1)
                        .name('Company1')
                        .externalId('23131321374');
                BLD_FinancialAccount financialAccountBld2 = new BLD_FinancialAccount(uow2)
                        .client(accBld2)
                        .name('Company2')
                        .externalId('23131321375');
                BLD_FinancialAccountPermission finAccPermBld1 = new BLD_FinancialAccountPermission(uow2)
                        .financialAccount(financialAccountBld1)
                        .permission(permissionBld1)
                        .active(true)
                        .authorizedPerson(conBld);
                BLD_FinancialAccountPermission finAccPermBld2 = new BLD_FinancialAccountPermission(uow2)
                        .financialAccount(financialAccountBld2)
                        .permission(permissionBld1)
                        .active(true)
                        .authorizedPerson(conBld);
                BLD_FinancialAccountPermission finAccPermBld3 = new BLD_FinancialAccountPermission(uow2)
                        .financialAccount(financialAccountBld2)
                        .permission(permissionBld2)
                        .active(true)
                        .authorizedPerson(conBld);
                uow2.commitWork();
                }
    }

    @IsTest
    public static void testPermissions() {
        OSB_VA_AvailableClients.GetClientSInput input1 = new OSB_VA_AvailableClients.GetClientSInput();
        input1.serviceType = BALANCE_INQUIRY;
        input1.contactId = [SELECT Id FROM Contact WHERE FirstName = :TEST_USER_FIRST_NAME LIMIT 1].Id;
        input1.countryName = USER_COUNTRY;
        OSB_VA_AvailableClients.GetClientSInput input2 = new OSB_VA_AvailableClients.GetClientSInput();
        input2.serviceType = BALANCE_INQUIRY;
        input2.contactId = [SELECT Id FROM Contact WHERE FirstName = :TEST_USER_FIRST_NAME + '1' LIMIT 1].Id;
        input2.countryName = USER_COUNTRY;
        List<OSB_VA_AvailableClients.GetClientSInput> inputs = new List<OSB_VA_AvailableClients.GetClientSInput>{
                input1, input2
        };
        Test.startTest();
        List<List<String>> result = OSB_VA_AvailableClients.getClients(inputs);
        Test.stopTest();
        System.assertEquals(2, result.size(), 'Expected 2');
        System.assertEquals(2, result.get(0).size(), 'Expected 2');
        System.assertEquals(0, result.get(1).size(), 'Expected 0');
    }
}