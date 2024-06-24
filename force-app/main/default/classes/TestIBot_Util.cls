/**
 * Test class for IBot_Util
 */
@IsTest
public class TestIBot_Util {

    public static List<Contact> createIndividualContacts(Integer numContacts) {
        List<Contact> results = new List<Contact>();

        for (Integer i = 0; i < numContacts; i++) {
            Contact c = (Contact) new BLD_Contact()
                    .name('Tester', 'McQueen ' + i)
                    .email('tmcqueen' + i + '@salesforce.com')
                    .phone('415-001-00' + i)
                    .mailingAddress('1 Market', 'San Francisco', 'US', '94105')
                    .getRecord();
            results.add(c);
        }
        insert results;
        return results;
    }

    public static Account createIndividualAccount(String name) {
        Id industriesIndividualRecordTypeId = UTL_RecordType.getRecordTypeId('Account', 'IndustriesIndividual');

        Account account = (Account) new BLD_Account()
                .name(name)
                .email('test@test.com')
                .phone('123456789')
                .recordTypeId(industriesIndividualRecordTypeId)
                .commitWork()
                .getRecord();

        return account;
    }

    public static Account createIndividualAccount(String name, String email, String mobile) {
        return IBot_DataUtils.createIndividualModalData(name, email, mobile);
    }

    public static Account createPersonAccount(String name, String email, String mobile) {
        return IBot_DataUtils.createPersonAccountModalData(name, email, mobile);
    }

    public static Contact createIndividualContact(String name) {
        Id industriesIndividualRecordTypeId = UTL_RecordType.getRecordTypeId('Contact', 'IndustriesIndividual');

        Contact contact = (Contact) new BLD_Contact()
                .lastName(name)
                .email(name + '@salesforce.com')
                .phone('415-001-00')
                .mobilePhone('415-001-00')
                .mailingAddress('1 Market', 'San Francisco', 'US', '94105')
                .recordTypeId(industriesIndividualRecordTypeId)
                .commitWork()
                .getRecord();

        return contact;
    }

    public static SObject createFinancialAccount(String accountId, String accountNumber, String accountType) {
        return IBot_DataUtils.createFinancialAccount(accountId, accountNumber, accountType);
    }

    public static SObject createCard(String cardName, String accountId, String financialAccountId) {
        return IBot_DataUtils.createCard(cardName, accountId, financialAccountId);
    }

    public static List<FscBot_Verification_Code__c> createTestVerificationCodes(List<Contact> contacts, String verificationMethod) {
        List<FscBot_Verification_Code__c> results = new List<FscBot_Verification_Code__c>();
        for (Contact c : contacts) {
            FscBot_Verification_Code__c newCode = new FscBot_Verification_Code__c();
            newCode.Contact__c = c.Id;
            newCode.Verification_Method__c = verificationMethod;
            newCode.Expires_On__c = DateTime.now().addMinutes(60);
            newCode.Code__c = 123123;
            results.add(newCode);
        }
        insert results;
        return results;
    }
}