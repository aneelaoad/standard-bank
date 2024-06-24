/***
@ Func Area     	:  Contact
@ Author        	:  Youssef Ibrahim
@ Date          	:  11/03/2020
@ Description 	    :  A test class for the TRH Contact class.
***/
@IsTest
public without sharing class TRH_Contact_Test {

    public static final String EMAIL_VALIDATION_ACCOUNT_NAME    = 'Test Account';
    @TestSetup
    private static void setup() {
        TEST_DataFactory.insertSettings(new List<Object>{
                TEST_DataFactory.getStandardBankEmailDomains()
        });
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

	private static Contact generateContactsAndAccountsWithoutBPID() {
		Account testAccount = new Account(Name = 'Test Account');
		insert testAccount;
		Individual testIndividual = new Individual(LastName = 'Test');
		insert testIndividual;
		Contact newContact = new Contact(FirstName = 'Test', LastName = 'test', Email = 'test@test.pl', AccountId = testAccount.Id, IndividualId = testIndividual.Id);
		insert newContact;
		return newContact;
	}
	private static Contact generateContactsAndAccountsWithBPID() {
		Account testAccount = new Account(Name = 'Test Account', BPID__c = '1');
		insert testAccount;
		Individual testIndividual = new Individual(LastName = 'Test Individual', BPID__c = '2');
		insert testIndividual;
		Contact newContact = new Contact(FirstName = 'Test', LastName = 'test', Email = 'test@test.pl', AccountId = testAccount.Id, IndividualId = testIndividual.Id);
		insert newContact;
		return newContact;
	}
	private static Contact generateContactAndUpdateAccountWithBPID() {
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
		return newContact;
	}
	@isTest
	public static void shouldNotReturnPBBExternalIDWhenCreatingContactRecordWithoutBPID() {
		Test.startTest();
		Contact contact = generateContactsAndAccountsWithoutBPID();
		Test.stopTest();
		Contact testContact = [SELECT PBB_External_ID__c FROM Contact WHERE Id = :contact.Id];
		system.assertEquals(NULL, testContact.PBB_External_ID__c);
	}
	@isTest
	public static void shouldReturnPBBExternalIDWhenCreatingContactRecordWithBPID() {
		Test.startTest();
		Contact contact = generateContactsAndAccountsWithBPID();
		Test.stopTest();
		Contact testContact = [SELECT PBB_External_ID__c FROM Contact WHERE Id = :contact.Id];
		system.assertEquals('2-1', testContact.PBB_External_ID__c);
	}
	@isTest
	public static void shouldUpdatePBBExternalIDWhenUpdatingAccountOnContact() {
		Test.startTest();
		Contact contact = generateContactAndUpdateAccountWithBPID();
		Test.stopTest();
		Contact testContact = [SELECT PBB_External_ID__c FROM Contact WHERE Id = :contact.Id];
		system.assertEquals('4-5', testContact.PBB_External_ID__c);
	}

}