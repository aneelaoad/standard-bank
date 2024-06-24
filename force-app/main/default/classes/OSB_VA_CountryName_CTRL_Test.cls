@isTest
public with sharing class OSB_VA_CountryName_CTRL_Test {
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
            BLD_Account accBld1 = new BLD_Account(uow)
                    .CIF('123456')
                    .Name(COMPANY_NAME);
            BLD_Contact conBld = new BLD_Contact(uow)
                    .name(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME)
                    .email(TEST_USER_EMAIL)
                    .ownerId(UserInfo.getUserId())
                    .cifNumber('123456')
                    .communityAccessRole(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP)
                    .account(accBld1)
                    .operatingCountry(CONTACT_OPERATING_COUNTRY);
            uow.commitWork();
    
            fflib_SObjectUnitOfWork uow2 = ABS_ObjectBuilderBase.getNewUnitOfWork(new List<SObjectType>{
                    Permissions__c.getSObjectType(),
                    Financial_Account__c.getSObjectType(),
                    Financial_Account_Permission__c.getSObjectType()
            });
            
            BLD_Permissions permissionBld1 = new BLD_Permissions(uow2).name(BALANCE_INQUIRY);
            BLD_FinancialAccount financialAccountBld1 = new BLD_FinancialAccount(uow2)
                    .client(accBld1)
                    .name(COMPANY_NAME)
                    .externalId('9090000341683');
            BLD_FinancialAccountPermission finAccPermBld1 = new BLD_FinancialAccountPermission(uow2)
                    .financialAccount(financialAccountBld1)
                    .permission(permissionBld1)
                    .active(true)
                    .authorizedPerson(conBld);
            uow2.commitWork();
            }
    }

    @IsTest
    public static void testMoreThanOneAvailableCountries() { 
        OSB_VA_CountryName_CTRL.CountryNameInput countryNameInput = new OSB_VA_CountryName_CTRL.CountryNameInput();
        List<OSB_VA_CountryName_CTRL.CountryNameInput> inputs = new List<OSB_VA_CountryName_CTRL.CountryNameInput>();
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        con.OSB_Operating_Country__c = 'Zambia;Mauritius';
        upsert con;

        countryNameInput.contactId = con.Id;
        inputs.add(countryNameInput);
        Test.startTest();
        List<OSB_VA_CountryName_CTRL.CountryNameOutput> result = OSB_VA_CountryName_CTRL.getCountryName(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
    }
    @IsTest
    public static void testOneAvailableCountry() { 
        OSB_VA_CountryName_CTRL.CountryNameInput countryNameInput = new OSB_VA_CountryName_CTRL.CountryNameInput();
        List<OSB_VA_CountryName_CTRL.CountryNameInput> inputs = new List<OSB_VA_CountryName_CTRL.CountryNameInput>();
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        con.OSB_Operating_Country__c = 'Zambia;';
        upsert con;

        countryNameInput.contactId = con.Id;
        inputs.add(countryNameInput);
        Test.startTest();
        List<OSB_VA_CountryName_CTRL.CountryNameOutput> result = OSB_VA_CountryName_CTRL.getCountryName(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
    }
    @IsTest
    public static void testUnavailableCountry() { 
        OSB_VA_CountryName_CTRL.CountryNameInput countryNameInput = new OSB_VA_CountryName_CTRL.CountryNameInput();
        List<OSB_VA_CountryName_CTRL.CountryNameInput> inputs = new List<OSB_VA_CountryName_CTRL.CountryNameInput>();
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        con.OSB_Operating_Country__c = null;
        upsert con;

        countryNameInput.contactId = con.Id;
        inputs.add(countryNameInput);
        Test.startTest();
        List<OSB_VA_CountryName_CTRL.CountryNameOutput> result = OSB_VA_CountryName_CTRL.getCountryName(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
    }
}