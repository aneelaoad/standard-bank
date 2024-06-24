@IsTest
private class LDS_InputField_Ctrlr_Test {

    private static final String
        COMMB_USERNAME      = 'commb@testersb123455672.com'
        , CIB_USERNAME      = 'cib@tester1232131421312312.com'
        , ADMIN_USERNAME    = 'admin@tester1231324732940328.com';

    static User commBUser {
        get {
            if (commBUser == null) {
                commBUser = [SELECT Id FROM User WHERE Username = :COMMB_USERNAME];
            }
            return commBUser;
        }
        set;
    }
    static User cibUser {
        get {
            if (cibUser == null) {
                cibUser = [SELECT Id FROM User WHERE Username = :CIB_USERNAME];
            }
            return cibUser;
        }
        set;
    }
    static User adminUser {
        get {
            if (adminUser == null) {
                adminUser = [SELECT Id FROM User WHERE Username = :ADMIN_USERNAME];
            }
            return adminUser;
        }
        set;
    }

    @TestSetup
    static void setupData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        new BLD_USER(uow).userName(COMMB_USERNAME).useCommB();
        new BLD_USER(uow).userName(CIB_USERNAME).useCib();
        new BLD_USER(uow).userName(ADMIN_USERNAME).useSysAdmin();

        uow.commitWork();
    }

    @IsTest
    static void shouldBeGloballyRequired() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Account();
            ctrlr.fieldName = 'Name';
            ctrlr.layoutRequired = false;
            Test.startTest();
            System.assert(ctrlr.isRequired);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldBeLayoutRequired() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Account();
            ctrlr.fieldName = 'AnnualRevenue';
            ctrlr.layoutRequired = true;
            Test.startTest();
                System.assert(ctrlr.isRequired);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldNotBeRequired() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            ctrlr.fieldName = 'Salutation';
            ctrlr.layoutRequired = false;
            Test.startTest();
                System.assert(!ctrlr.isRequired);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldBeReadOnly() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            ctrlr.fieldName = 'Name';
            Test.startTest();
                System.assert(ctrlr.isReadOnly);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldBeReadOnlyForRegularUsers() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Account();
            ctrlr.fieldName = 'CIF_Client_Type__c';
            Test.startTest();
                System.assert(ctrlr.isReadOnly);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldNotBeReadOnlyForAdmin() {

        System.runAs(adminUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Account();
            ctrlr.fieldName = 'CIF_Client_Type__c';
            ctrlr.layoutReadOnly = false;
            Test.startTest();
                System.assert(!ctrlr.isReadOnly);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldBeInput() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Account();
            ctrlr.fieldName = 'Name';
            Test.startTest();
                System.assert(ctrlr.isInput);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldNotBeInput() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            ctrlr.fieldName = 'Salutation';
            Test.startTest();
                System.assert(!ctrlr.isInput);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldRenderInputText() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new SB_Product__c();
            ctrlr.fieldName = 'Total_Other__c';
            Test.startTest();
                System.assert(ctrlr.isInput);
                System.assert(ctrlr.renderInputText);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldBeTextArea() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            ctrlr.fieldName = 'Description';
            Test.startTest();
                System.assert(ctrlr.isTextarea);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldNotBeTextArea() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            ctrlr.fieldName = 'Salutation';
            Test.startTest();
                System.assert(!ctrlr.isTextarea);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldBePicklist() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            ctrlr.fieldName = 'Salutation';
            Test.startTest();
                System.assert(ctrlr.isPicklist);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldNotBePicklist() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            ctrlr.fieldName = 'LastName';
            Test.startTest();
                System.assert(!ctrlr.isPicklist);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldBeDependentPicklist() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Account();
            ctrlr.fieldName = 'Business_Classification__c';
            Test.startTest();
                System.assert(ctrlr.isPicklist);
                System.assert(ctrlr.isDependentPicklist);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldNotBeDependentPicklist() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            ctrlr.fieldName = 'Salutation';
            Test.startTest();
                System.assert(ctrlr.isPicklist);
                System.assert(!ctrlr.isDependentPicklist);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldBeMultiPicklist() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            ctrlr.fieldName = 'Allergies__c';
            Test.startTest();
                System.assert(ctrlr.isMultiPicklist);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldNotBeMultiPicklist() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            ctrlr.fieldName = 'Salutation';
            Test.startTest();
                System.assert(!ctrlr.isMultiPicklist);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldBeCheckbox() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Opportunity();
            ctrlr.fieldName = 'IsPrivate';
            Test.startTest();
                System.assert(ctrlr.isCheckbox);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldNotBeCheckbox() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            ctrlr.fieldName = 'Salutation';
            Test.startTest();
                System.assert(!ctrlr.isCheckbox);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldBeDateTime() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Event();
            ctrlr.fieldName = 'ActivityDate';
            Test.startTest();
                System.assert(ctrlr.isDatetime);
            Test.stopTest();
        }

    }

    @IsTest
    static void dateFieldShouldBeDateTime() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Opportunity();
            ctrlr.fieldName = 'CloseDate';
            Test.startTest();
                System.assert(ctrlr.isDatetime);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldNotBeDateTime() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            ctrlr.fieldName = 'Salutation';
            Test.startTest();
                System.assert(!ctrlr.isDatetime);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldBeLookup() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            ctrlr.fieldName = 'AccountId';
            Test.startTest();
                System.assert(ctrlr.isLookup);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldNotBeLookup() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            ctrlr.fieldName = 'Salutation';
            Test.startTest();
                System.assert(!ctrlr.isLookup);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldBeAccount() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Account();
            Test.startTest();
                System.assertEquals('Account', ctrlr.objectName);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldNotBeAccount() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = new Contact();
            Test.startTest();
                System.assertNotEquals('Account', ctrlr.objectName);
            Test.stopTest();
        }

    }

    @IsTest
    static void shouldReturnEmptyString() {

        System.runAs(cibUser) {
            LDS_InputField_Ctrlr ctrlr = new LDS_InputField_Ctrlr();
            ctrlr.inputObject = null;
            Test.startTest();
                System.assertEquals('', ctrlr.objectName);
            Test.stopTest();
        }

    }

}