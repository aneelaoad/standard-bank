/**
 * Test class for DMN_Contact
 *
 * @AUTHOR Omar Berraj
 * @date August 2020
 */
@IsTest (IsParallel = true)
private class DMN_Contact_Test {

    public static final String EMAIL_VALIDATION_ACCOUNT_NAME    = 'Test Account';
    @TestSetup
    private static void setup() {
        TEST_DataFactory.insertSettings(new List<Object>{
                TEST_DataFactory.getStandardBankEmailDomains()
        });
    }

    @IsTest
    public static void shouldUpdateEventReportCSuiteFlagToChecked() {

        // Create Mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_CallReportAttendees eventAttendeesSelectorMock = (SEL_CallReportAttendees) mocks.mock(SEL_CallReportAttendees.class);

        Contact testContact = (Contact) new BLD_Contact().contactCategory('CEO').mock();
        Call_Report_Attendees__c testAttendee = (Call_Report_Attendees__c) new BLD_CallReportAttendee()
                .contactId(testContact.Id)
                .callReport(new BLD_CallReport().createdDate(Datetime.now()))
                .status('Invited')
                .mock();

        Contact oldContact = (Contact) testContact.clone();
        oldContact.Contact_Category__c = 'Developer';

        // Given
        mocks.startStubbing();
        mocks.when(eventAttendeesSelectorMock.sObjectType()).thenReturn(Call_Report_Attendees__c.SObjectType);
        mocks.when(eventAttendeesSelectorMock
                .selectByContactIdAndStatus(new Set<Id> { testAttendee.Contact_id__c },
                DMN_CallReportAttendee.STATUS_INVITED,
                DMN_CallReportAttendee.STATUS_ATTENDED))
                .thenReturn(new List<Call_Report_Attendees__c> { testAttendee });
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.selector.setMock(eventAttendeesSelectorMock);

        // When
        Test.startTest();
        DMN_Contact.updateEventReportCSuiteFlag(new Contact[] { testContact }, new Map<Id, Contact> { testContact.Id => oldContact });
        Test.stopTest();

        // Then
        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(Call_Report__c.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty((Call_Report__c) argument.capture());
        Call_Report__c updatedCallReport = (Call_Report__c) argument.getValue();
        System.assertEquals(true, updatedCallReport.C_Suite_Attendance__c);
    }

    @IsTest
    public static void shouldNotRetrieveAnyEventReportForUpdate() {

        // Create Mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_CallReportAttendees eventAttendeesSelectorMock = (SEL_CallReportAttendees) mocks.mock(SEL_CallReportAttendees.class);

        Contact testContact = (Contact) new BLD_Contact().contactCategory('CEO').mock();
        Call_Report_Attendees__c testAttendee = (Call_Report_Attendees__c) new BLD_CallReportAttendee()
                .contactId(testContact.Id)
                .callReport(new BLD_CallReport().createdDate(Datetime.newInstance(2019, 9, 15)))
                .status('Invited')
                .mock();

        Contact oldContact = (Contact) testContact.clone();
        oldContact.Contact_Category__c = 'Developer';

        // Given
        mocks.startStubbing();
        mocks.when(eventAttendeesSelectorMock.sObjectType()).thenReturn(Call_Report_Attendees__c.SObjectType);
        mocks.when(eventAttendeesSelectorMock
                .selectByContactIdAndStatus(new Set<Id> { testAttendee.Contact_id__c },
                        DMN_CallReportAttendee.STATUS_INVITED,
                        DMN_CallReportAttendee.STATUS_ATTENDED))
                .thenReturn(new List<Call_Report_Attendees__c> { testAttendee });
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.selector.setMock(eventAttendeesSelectorMock);

        // When
        Test.startTest();
        DMN_Contact.updateEventReportCSuiteFlag(new Contact[] { testContact }, new Map<Id, Contact> { testContact.Id => oldContact });
        Test.stopTest();

        // Then
        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(Call_Report__c.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 0)).registerDirty((Call_Report__c) argument.capture());
        Call_Report__c updatedCallReport = (Call_Report__c) argument.getValue();
        System.assertEquals(null, updatedCallReport);
    }

    @IsTest
    public static void shouldSetEmailAndMobileFromAccount() {
        Account testAccount = (Account) new BLD_Account().name('testAcc').email('test@test.com').phone('123456789').getRecord();
        insert testAccount;
        Contact testContact = (Contact) new BLD_Contact().accountId(testAccount.Id).name('test', 'contact').email(null).phone(null).getRecord();
        Test.startTest();
        insert testContact;
        Test.stopTest();
        Contact createdContact = [SELECT Id, Name, Phone, Email FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(testAccount.Phone, createdContact.Phone);
        System.assertEquals(testAccount.Email_Address__c, createdContact.Email);
    }

    @IsTest
    public static void shouldKeepEmailAndMobileFromContact() {
        Account testAccount = (Account) new BLD_Account().name('testAcc').email('test@test.com').phone('123456789').getRecord();
        insert testAccount;
        Contact testContact = (Contact) new BLD_Contact().accountId(testAccount.Id).name('test', 'contact').getRecord();
        Test.startTest();
        insert testContact;
        Test.stopTest();
        Contact createdContact = [SELECT Id, Name, Phone, Email FROM Contact WHERE Id = :testContact.Id];
        System.assertNotEquals(testAccount.Phone, createdContact.Phone);
        System.assertNotEquals(testAccount.Email_Address__c, createdContact.Email);
    }

    @isTest
	public static void shouldReturnPBBExternalIDWhenCreatingContactRecordWithBPID() {
		Test.startTest();

        Account testAccount = new Account(Name = 'Test Account', BPID__c = '1');
		insert testAccount;
		Individual testIndividual = new Individual(LastName = 'Test Individual', BPID__c = '2');
		insert testIndividual;
		Contact newContact = new Contact(FirstName = 'Test', LastName = 'test', Email = 'test@test.pl', AccountId = testAccount.Id, IndividualId = testIndividual.Id);
		insert newContact;

		Test.stopTest();
		Contact testContact = [SELECT PBB_External_ID__c FROM Contact WHERE Id = :newContact.Id];
		system.assertEquals('2-1', testContact.PBB_External_ID__c);
	}

    @isTest
	public static void shouldUpdatePBBExternalIDWhenUpdatingAccountOnContact() {
		Test.startTest();

		Account testAccount = new Account(Name = 'Test Account', BPID__c = '3');
		insert testAccount;
		Individual testIndividual = new Individual(LastName = 'Test Individual', BPID__c = '4');
		insert testIndividual;
		Contact newContact = new Contact(FirstName = 'Test2', LastName = 'test2', Email = 'test@test.pl', AccountId = testAccount.Id, IndividualId = testIndividual.Id);
		insert newContact;
		Account testAccount2 = new Account(Name = '2', BPID__c = '5');
		insert testAccount2;
		newContact.AccountId = testAccount2.Id;
		upsert newContact;

		Test.stopTest();
		Contact testContact = [SELECT PBB_External_ID__c FROM Contact WHERE Id = :newContact.Id];
		system.assertEquals('4-5', testContact.PBB_External_ID__c);
	}

    @isTest
	public static void shouldRemoveOrphanedHostsAndMemberHosts() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Contact conBld = new BLD_Contact(uow)
            .account(new BLD_Account(uow));

        BLD_CampaignMemberHost bldCampaignMemberHost = new BLD_CampaignMemberHost(uow)
            .member(conBld);

        BLD_CampaignHost bldCampaignHost = new BLD_CampaignHost(uow)
            .bankContact(
                new BLD_Contact(uow).useBankContact()
                    .email('testemail@standardbank.co.za')
                    .account(
                        new BLD_Account(uow)
                            .name(DMN_Account.STANDARD_BANK_EMPLOYEES)
                    )
            )
            .memberHost(bldCampaignMemberHost);


        BLD_Campaign campBld = new BLD_Campaign(uow)
            .addMember(
                new BLD_CampaignMember(uow).contact(conBld)
            )
            .addMemberHost(bldCampaignMemberHost);
        
        uow.commitWork();
        List<Campaign_Hosts__c> orphanedHosts = [SELECT Id FROM Campaign_Hosts__c];
        List<Campaign_Member_Host__c> orphanedMemberHosts = [SELECT Id FROM Campaign_Member_Host__c];
		Test.startTest();
        DMN_Contact.removeOrphanedHostsAndMemberHosts(orphanedHosts, orphanedMemberHosts);
		Test.stopTest();

		List<Campaign_Member_Host__c> result = [SELECT Id FROM Campaign_Member_Host__c];
		system.assertEquals(0, result.size());
	}

    @isTest
	public static void shouldContactUserSyncProcess() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Contact conBld = (Contact) new BLD_Contact(uow)
            .account(new BLD_Account(uow).CIF('12345'))
            .cifNumber('12345')
            .getRecord();

        insert conBld;
        Map<Id, Contact> oldContact = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact]);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            User userBld = (User)new BLD_USER(uow).useSysAdmin().getRecord();
            new BLD_ContactTeamMember(uow).contact(conBld.Id).user(userBld.Id);
            insert userBld;

            conBld.Group_Parent_CIF_Number__c = '12345';
            update conBld;
        }

        List<Contact> newContact = [SELECT Id, AccountId FROM Contact];
		Test.startTest();
        DMN_Contact.populateCIFNumber(newContact);
        DMN_Contact.contactUserSyncProcess(newContact, oldContact, false);
		Test.stopTest();

		List<Contact> result = [SELECT Id, AccountId, CIF_Number__c FROM Contact];
		system.assertNotEquals(0, result.size());
	}

    @IsTest
    public static void shouldValidateClientContactEmailDomainNotIncludedInSBDomains() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Account parentAccount = (Account) new BLD_Account(uow)
                .name(EMAIL_VALIDATION_ACCOUNT_NAME)
                .CIFNumberProposedGroupParent('NOT SB CLIENT CIF')
                .getRecord();
        uow.commitWork();

        List<String> SBGEmails = new List<String>{'SomeUser@sbg.com', 'SomeUser@stanlib.com', 'SomeUser@standardbank.com', 'SomeUser@stanbic.com', 'SomeUser@sbg.za'};
        List<String> NonSBGEmails = new List<String>{'SomeUser@gmail.com', 'SomeUsersbg@gmail.com', 'SomeUser@gmail.za'};
        Exception ex;
        Test.startTest();
        for (String em : SBGEmails) {
            new BLD_Contact(uow)
                    .name('Test', 'SBGEmail')
                    .email(em)
                    .accountId(parentAccount.Id);
        }
        try {
            uow.commitWork();
        } catch (DmlException e) {
            ex = e;
        }

        for (String em : NonSBGEmails) {
            new BLD_Contact(uow)
                    .name('Test', 'NonSBGEmail')
                    .email(em)
                    .accountId(parentAccount.Id);
        }
        uow.commitWork();
        Test.stopTest();

        Map<Id, Contact> id2ContactsWithoutSBEmails = new Map<Id, Contact>([
                SELECT Id, Email
                FROM Contact
                WHERE FirstName = 'Test'
                AND LastName = 'NonSBGEmail'
        ]);

        System.assertEquals(NonSBGEmails.size(), id2ContactsWithoutSBEmails.size());
        System.assertNotEquals(null, ex);
    }
}