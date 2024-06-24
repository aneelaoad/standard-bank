/**
 * Test class for AccountApplication
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		December 2020
*/
@IsTest
public class AccountApplication_TEST {

    @IsTest
    static void shouldCreatePreferences() {
        string JSONContent = '{' +
                '"accountName": "preferencesTest Acc",' +
                '"statementDeliveryFrequency": "preferencesTest Freq",' +
                '"statementDeliveryMethod": "preferencesTest Method",' +
                '"deliveryDestination": "preferencesTest@gmail.com"' +
                '}';
        JSONParser parser = JSON.createParser(JSONContent);

        Test.startTest();
        AccountApplication.Preferences testPref = new AccountApplication.Preferences(parser);
        Test.stopTest();

        System.assertEquals('preferencesTest Acc', testPref.accountName);
        System.assertEquals('preferencesTest Freq', testPref.statementDeliveryFrequency);
        System.assertEquals('preferencesTest Method', testPref.statementDeliveryMethod);
        System.assertEquals('preferencesTest@gmail.com', testPref.deliveryDestination);
    }

    @IsTest
    static void shouldCreateSupportingDocuments() {
        string JSONContent = '{' +
                        '"documentType": "test documentType",' +
                        '"name": "EOH Power Systems (Pty) Ltd.",' +
                        '"verified": false,' +
                        '"documentId": "8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"' +
                    '}';
        JSONParser parser = JSON.createParser(JSONContent);

        Test.startTest();
        AccountApplication.SupportingDocuments testSupportingDocuments = new AccountApplication.SupportingDocuments(parser);
        Test.stopTest();

        System.assertEquals('test documentType', testSupportingDocuments.documentType);
        System.assertEquals('EOH Power Systems (Pty) Ltd.', testSupportingDocuments.name);
        System.assert(!testSupportingDocuments.verified);
        System.assertEquals('8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B', testSupportingDocuments.documentId);
    }

    @IsTest
    static void shouldCreateTerm() {
        string JSONContent = '{' +
                '"createdAt": "2018-01-02 12:42:25",' +
                '"modifiedAt": "2018-01-02 12:42:25",' +
                '"name": "Business Current Account terms.",' +
                '"title": "Business Current Account terms.",' +
                '"url": "http://www.standardbank.co.za"' +
                '}';
        JSONParser parser = JSON.createParser(JSONContent);

        Test.startTest();
        AccountApplication.Term testTerm = new AccountApplication.Term(parser);
        Test.stopTest();

        System.assertEquals('2018-01-02 12:42:25', testTerm.createdAt);
        System.assertEquals('2018-01-02 12:42:25', testTerm.modifiedAt);
        System.assertEquals('Business Current Account terms.', testTerm.name);
        System.assertEquals('Business Current Account terms.', testTerm.title);
        System.assertEquals('http://www.standardbank.co.za', testTerm.url);
    }

    @IsTest
    static void shouldCreateAdditionalProductsRequired() {
        string JSONContent = '{' +
                '"id": "20010212",' +
                '"bolProfileId": "184225",' +
                '"cashManGroupNumber": "423"' +
                '}';
        JSONParser parser = JSON.createParser(JSONContent);

        Test.startTest();
        AccountApplication.AdditionalProductsRequired testAdditionalProductsRequired = new AccountApplication.AdditionalProductsRequired(parser);
        Test.stopTest();

        System.assertEquals('20010212', testAdditionalProductsRequired.id);
        System.assertEquals('184225', testAdditionalProductsRequired.bolProfileId);
        System.assertEquals('423', testAdditionalProductsRequired.cashManGroupNumber);
    }

    @IsTest
    static void shouldCreateContactPerson() {
        string JSONContent = '{' +
                '"requestedBy": "user0001",' +
                '"requesterNumber": "c0001"' +
                '}';
        JSONParser parser = JSON.createParser(JSONContent);

        Test.startTest();
        AccountApplication.ContactPerson testContactPerson = new AccountApplication.ContactPerson(parser);
        Test.stopTest();

        System.assertEquals('user0001', testContactPerson.requestedBy);
        System.assertEquals('c0001', testContactPerson.requesterNumber);
    }
    
    @IsTest
    static void shouldCreateAddress() {
        string JSONContent = '{' +
                '"registeredAddress": "EOH Business Park",' +
                '"line2": "Gilloolys View",' +
                '"province": "Gauteng",' +
                '"registeredCity": "Johannesburg",' +
                '"postalCode": "1666",' +
                '"country": "SOUTH AFRICA"' +
                '}';
        JSONParser parser = JSON.createParser(JSONContent);

        Test.startTest();
        AccountApplication.Address testAddress = new AccountApplication.Address(parser);
        Test.stopTest();

        System.assertEquals('EOH Business Park', testAddress.registeredAddress);
        System.assertEquals('Gilloolys View', testAddress.line2);
        System.assertEquals('Gauteng', testAddress.province);
        System.assertEquals('Johannesburg', testAddress.registeredCity);
        System.assertEquals('1666', testAddress.postalCode);
        System.assertEquals('SOUTH AFRICA', testAddress.country);
    }
    
    @IsTest
    static void shouldCreateRelatedParties() {
        string JSONContent = '{' +
                '"createdAt": "2018-03-08 11:14:41",' +
                '"modifiedAt": "2018-03-08 11:14:56",' +
                '"goldTierId": 439,' +
                '"businessType": "Client",' +
                '"identityNumber": "001",' +
                '"sharePercentage": 0,' +
                '"firstName": "John",' +
                '"lastName": "Doe",' +
                '"registrationNumber": "c0001",' +
                '"registeredName": "Client:EOH Power Systems (Pty) Ltd.",' +
                '"contactNumber": "000000001",' +
                '"capacity": "90",' +
                '"emailAddress": "johndoe@testRelatedParties.com",' +
                '"registeredAddress": "registeredAddress test",' +
                '"headOfficeAddress": "headOfficeAddress test",' +
                '"physicalAddress": "physicalAddress test",' +
                '"supportingDocuments": [' +
                        '{' +
                            '"documentType": "documentType test",' +
                            '"name": "EOH Power Systems (Pty) Ltd.",' +
                            '"verified": false,' +
                            '"documentId": "8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"' +
                        '},' +
                        '{' +
                            '"documentType": "documentType test",' +
                            '"name": "CIPC Document:EOH Power Systems (Pty) Ltd.",' +
                            '"verified": false,' +
                            '"documentId": "8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"' +
                        '},' +
                        '{' +
                            '"documentType": "documentType test",' +
                            '"name": "EOH Power Systems (Pty) Ltd.",' +
                            '"verified": false,' +
                            '"documentId": "8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"' +
                        '}' +
                    ']' +
                '}';
        JSONParser parser = JSON.createParser(JSONContent);

        Test.startTest();
        AccountApplication.RelatedParties testParties = new AccountApplication.RelatedParties(parser);
        Test.stopTest();

        System.assertEquals('2018-03-08 11:14:41', testParties.createdAt);
        System.assertEquals('2018-03-08 11:14:56', testParties.modifiedAt);
        System.assertEquals(439, testParties.goldTierId);
        System.assertEquals('Client', testParties.businessType);
        System.assertEquals(0, testParties.sharePercentage);
        System.assertEquals('Doe', testParties.lastName);
        System.assertEquals('c0001', testParties.registrationNumber);
        System.assertEquals('Client:EOH Power Systems (Pty) Ltd.', testParties.registeredName);
        System.assertEquals('000000001', testParties.contactNumber);
        System.assertEquals('90', testParties.capacity);
        System.assertEquals('johndoe@testRelatedParties.com', testParties.emailAddress);
        System.assertEquals('registeredAddress test', testParties.registeredAddress);
        System.assertEquals('headOfficeAddress test', testParties.headOfficeAddress);
        System.assertEquals('physicalAddress test', testParties.physicalAddress);
        System.assert(testParties.supportingDocuments.size() > 0);
    }
    
    @IsTest
    static void shouldCreateSignatories() {
        string JSONContent = '{' +
                '"createdAt": "2018-03-08 11:15:53",' +
                '"modifiedAt": "2018-03-08 11:15:53",' +
                '"idNumber": "700709099083",' +
                '"firstName": "Siya",' +
                '"lastName": "Khanyile",' +
                '"contactNumber": "0121231234",' +
                '"emailAddress": "syabongak@gmail.com",' +
                '"signingLimits": 100,' +
                '"signingArrangements": "None",' +
                '"addressRv": "addressRv test",' +
                '"supportingDocuments": [' +
                        '{' +
                            '"documentType": "documentType test",' +
                            '"name": "EOH Power Systems (Pty) Ltd.",' +
                            '"verified": false,' +
                            '"documentId": "8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"' +
                        '},' +
                        '{' +
                            '"documentType": "documentType test",' +
                            '"name": "CIPC Document:EOH Power Systems (Pty) Ltd.",' +
                            '"verified": false,' +
                            '"documentId": "8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"' +
                        '},' +
                        '{' +
                            '"documentType": "documentType test",' +
                            '"name": "EOH Power Systems (Pty) Ltd.",' +
                            '"verified": false,' +
                            '"documentId": "8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"' +
                        '}' +
                    ']' +
                '}';
        JSONParser parser = JSON.createParser(JSONContent);

        Test.startTest();
        AccountApplication.Signatories testSignatories = new AccountApplication.Signatories(parser);
        Test.stopTest();

        System.assertEquals('2018-03-08 11:15:53', testSignatories.createdAt);
        System.assertEquals('2018-03-08 11:15:53', testSignatories.modifiedAt);
        System.assertEquals('700709099083', testSignatories.idNumber);
        System.assertEquals('Siya', testSignatories.firstName);
        System.assertEquals('Khanyile', testSignatories.lastName);
        System.assertEquals('0121231234', testSignatories.contactNumber);
        System.assertEquals('syabongak@gmail.com', testSignatories.emailAddress);
        System.assertEquals(100, testSignatories.signingLimits);
        System.assertEquals('None', testSignatories.signingArrangements);
        System.assertEquals('addressRv test', testSignatories.addressRv);
        System.assert(testSignatories.supportingDocuments.size() > 0);
    }
    
    @IsTest
    static void shouldCreateBankAccount() {
        string JSONContent = '{' +
                '"createdAt": "2018-03-08 11:15:10",' +
                '"modifiedAt": "2018-03-08 11:15:10",' +
                '"accountType": "Business Current Account",' +
                '"accountNumber": "2654725000",' +
                '"branchCode": "Rosebank",' +
                '"active": false,' +
                '"signatories": [' +
                    '{' +
                        '"createdAt": "2018-03-08 11:15:53",' +
                        '"modifiedAt": "2018-03-08 11:15:53",' +
                        '"idNumber": "700709099083",' +
                        '"firstName": "Siya",' +
                        '"lastName": "Khanyile",' +
                        '"contactNumber": "0121231234",' +
                        '"emailAddress": "syabongak@gmail.com",' +
                        '"signingLimits": 100,' +
                        '"signingArrangements": "None",' +
                        '"address": null,' +
                        '"supportingDocuments": null' +
                    '}' +
                '],' +
                '"preferences": {' +
                    '"accountName": "My Acc",' +
                    '"statementDeliveryFrequency": null,' +
                    '"statementDeliveryMethod": null,' +
                    '"deliveryDestination": "syabongak@gmail.com"' +
                    '}' +
                '}';
        JSONParser parser = JSON.createParser(JSONContent);

        Test.startTest();
        AccountApplication.BankAccount testBankAccount = new AccountApplication.BankAccount(parser);
        Test.stopTest();

        System.assertEquals('2018-03-08 11:15:10', testBankAccount.createdAt);
        System.assertEquals('2018-03-08 11:15:10', testBankAccount.modifiedAt);
        System.assertEquals('Business Current Account', testBankAccount.accountType);
        System.assertEquals('2654725000', testBankAccount.accountNumber);
        System.assertEquals('Rosebank', testBankAccount.branchCode);
        System.assert(!testBankAccount.active);
        System.assert(testBankAccount.signatories.size() > 0);
        System.assertNotEquals(null, testBankAccount.preferences);
    }

    @IsTest
    static void shouldCreateProduct() {
        string JSONContent = '{' +
                '"createdAt": "2018-01-02 12:42:25",' +
                '"modifiedAt": "2018-01-02 12:42:25",' +
                '"id": 1,' +
                '"name": "Business Current Account",' +
                '"description": "Enjoy a secure means of paying and collecting funds.",' +
                '"openingDepositCents": 50000,' +
                '"monthlyFeeCents": 6900,' +
                '"access": "granted",' +
                '"terms": [' +
                        '{' +
                            '"createdAt": "2018-01-02 12:42:25",' +
                            '"modifiedAt": "2018-01-02 12:42:25",' +
                            '"name": "Business Current Account terms.",' +
                            '"title": "Business Current Account terms.",' +
                            '"url": "http://www.standardbank.co.za"' +
                        '},' +
                        '{' +
                            '"createdAt": "2018-01-02 12:42:25",' +
                            '"modifiedAt": "2018-01-02 12:42:25",' +
                            '"name": "Standard Bank General Terms and Conditions",' +
                            '"title": "Standard Bank General Terms and Conditions",' +
                            '"url": "http://www.standardbank.co.za"' +
                        '}' +
                    ']' +
                '}';
        JSONParser parser = JSON.createParser(JSONContent);

        Test.startTest();
        AccountApplication.Product testProduct = new AccountApplication.Product(parser);
        Test.stopTest();

        System.assertEquals('2018-01-02 12:42:25', testProduct.createdAt);
        System.assertEquals('2018-01-02 12:42:25', testProduct.modifiedAt);
        System.assertEquals('1', testProduct.id);
        System.assertEquals('Business Current Account', testProduct.name);
        System.assertEquals('Enjoy a secure means of paying and collecting funds.', testProduct.description);
        System.assertEquals(50000, testProduct.openingDepositCents);
        System.assertEquals(6900, testProduct.monthlyFeeCents);
        System.assertEquals('granted', testProduct.access);
        System.assert(testProduct.terms.size() > 0);
    }

    @IsTest
    static void shouldCreateAcceptedTerms() {
        string JSONContent = '{' +
                '"createdAt": "2018-03-08 11:14:29",' +
                '"modifiedAt": "2018-03-08 11:14:29",' +
                '"term": {' +
                        '"createdAt": "2018-01-02 12:42:25",' +
                        '"modifiedAt": "2018-01-02 12:42:25",' +
                        '"name": "Business Current Account terms.",' +
                        '"title": "Business Current Account terms.",' +
                        '"url": "http://www.standardbank.co.za"' +
                    '}' +
                '}';
        JSONParser parser = JSON.createParser(JSONContent);

        Test.startTest();
        AccountApplication.AcceptedTerms testAcceptedTerms = new AccountApplication.AcceptedTerms(parser);
        Test.stopTest();

        System.assertEquals('2018-03-08 11:14:29', testAcceptedTerms.createdAt);
        System.assertEquals('2018-03-08 11:14:29', testAcceptedTerms.modifiedAt);
        System.assertNotEquals(null, testAcceptedTerms.term);
    }

    @IsTest
    static void shouldCreateLegalEntity() {
        string JSONContent = '{' +
                '"salesforceId": "0010E00000DxdsNQAR",' +
                '"cif": "530664300",' +
                '"typeOfEntity": "Pty Ltd",' +
                '"tradingAs": "Power",' +
                '"registrationNumber": "2009/011794/07",' +
                '"registeredName": "EOH Power Systems (Pty) Ltd.",' +
                '"telephoneNumber": "0121231234",' +
                '"vatNumber": "1010",' +
                '"address": {' +
                        '"registeredAddress": "EOH Business Park",' +
                        '"line2": "Gilloolys View",' +
                        '"province": "Gauteng",' +
                        '"registeredCity": "Johannesburg",' +
                        '"postalCode": "1666",' +
                        '"country": "SOUTH AFRICA"' +
                    '},' +
                '"relatedParties": [' +
                        '{' +
                            '"createdAt": "2018-03-08 11:14:41",' +
                            '"modifiedAt": "2018-03-08 11:14:56",' +
                            '"id": 439,' +
                            '"businessType": "Client",' +
                            '"identityNumber": null,' +
                            '"sharePercentage": 0,' +
                            '"firstName": null,' +
                            '"lastName": null,' +
                            '"registrationNumber": null,' +
                            '"registeredName": "Client:EOH Power Systems (Pty) Ltd.",' +
                            '"contactNumber": null,' +
                            '"capacity": null,' +
                            '"emailAddress": null,' +
                            '"registeredAddress": null,' +
                            '"headOfficeAddress": null,' +
                            '"physicalAddress": null,' +
                            '"supportingDocuments": []' +
                        '}' +
                    '],' +
                '"supportingDocuments": [' +
                        '{' +
                            '"documentType": null,' +
                            '"name": "EOH Power Systems (Pty) Ltd.",' +
                            '"verified": false,' +
                            '"documentId": "8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"' +
                        '}' +
                    '],' +
                '"annualTurnover": 100.0' +
                '}';
        JSONParser parser = JSON.createParser(JSONContent);

        Test.startTest();
        AccountApplication.LegalEntity testLegalEntity = new AccountApplication.LegalEntity(parser);
        Test.stopTest();

        System.assertEquals('0010E00000DxdsNQAR', testLegalEntity.salesforceId);
        System.assertEquals('530664300', testLegalEntity.cif);
        System.assertEquals('Power', testLegalEntity.tradingAs);
        System.assertEquals('2009/011794/07', testLegalEntity.registrationNumber);
        System.assertEquals('1010', testLegalEntity.vatNumber);
        System.assertEquals('EOH Power Systems (Pty) Ltd.', testLegalEntity.registeredName);
        System.assertEquals('0121231234', testLegalEntity.telephoneNumber);
        System.assertNotEquals(null, testLegalEntity.address);
        System.assert(testLegalEntity.relatedParties.size() > 0);
        System.assert(testLegalEntity.supportingDocuments.size() > 0);
        System.assertEquals(100.0, testLegalEntity.annualTurnover);

    }

    @IsTest
    static void shouldCreateAOBApplication() {
        string JSONContent = '{' +
                '"createdAt": "2018-03-08 11:14:29",' +
                '"modifiedAt": "2018-03-08 11:15:10",' +
                '"id": 431,' +
                '"legalEntity": {' +
                        '"salesforceId": "0010E00000DxdsNQAR",' +
                        '"cif": "530664300",' +
                        '"typeOfEntity": "Pty Ltd",' +
                        '"tradingAs": "Power",' +
                        '"registrationNumber": "2009/011794/07",' +
                        '"registeredName": "EOH Power Systems (Pty) Ltd.",' +
                        '"telephoneNumber": "0121231234",' +
                        '"address": {},' +
                        '"relatedParties": [],' +
                        '"supportingDocuments": []' +
                    '},' +
                '"bankAccount": {' +
                        '"createdAt": "2018-03-08 11:15:10",' +
                        '"modifiedAt": "2018-03-08 11:15:10",' +
                        '"accountType": "Business Current Account",' +
                        '"accountNumber": "2654725000",' +
                        '"branchCode": "Rosebank",' +
                        '"active": false,' +
                        '"signatories": [],' +
                        '"preferences": null' +
                    '},' +
                '"additionalProductsRequired": [' +
                        '{' +
                            '"id": "20010212",' +
                            '"bolProfileId": "184225",' +
                            '"cashManGroupNumber": "423"' +
                        '}' +
                    '],' +
                '"acceptedTerms": [' +
                        '{' +
                            '"createdAt": "2018-03-08 11:14:29",' +
                            '"modifiedAt": "2018-03-08 11:14:29",' +
                            '"term": {' +
                                    '"createdAt": "2018-01-02 12:42:25",' +
                                    '"modifiedAt": "2018-01-02 12:42:25",' +
                                    '"name": "Business Current Account terms.",' +
                                    '"title": "Business Current Account terms.",' +
                                    '"url": "http://www.standardbank.co.za"' +
                                '}' +
                        '}' +
                    '],' +
                '"fieldChanges": "address, signatories",' +
                '"product": {' +
                        '"createdAt": "2018-01-02 12:42:25",' +
                        '"modifiedAt": "2018-01-02 12:42:25",' +
                        '"id": 1,' +
                        '"name": "Business Current Account",' +
                        '"description": "Enjoy a secure means of paying and collecting funds.",' +
                        '"openingDepositCents": 50000,' +
                        '"monthlyFeeCents": 6900,' +
                        '"access": null,' +
                        '"terms": []' +
                    '},' +
                '"confirmedEntityDetails": true,' +
                '"confirmedAccountDetails": false' +
                '}';

        Test.startTest();
        AccountApplication.AOBApplication testAobApplication =
                AccountApplication.AOBApplication.parse(JSONContent);
        Test.stopTest();

        System.assertEquals('2018-03-08 11:14:29', testAobApplication.createdAt);
        System.assertEquals('2018-03-08 11:15:10', testAobApplication.modifiedAt);
        System.assertEquals('address, signatories', testAobApplication.fieldChanges);
        System.assertEquals(431, testAobApplication.id);
        System.assertNotEquals(null, testAobApplication.legalEntity);
        System.assertNotEquals(null, testAobApplication.bankAccount);
        System.assertNotEquals(null, testAobApplication.product);
        System.assert(testAobApplication.additionalProductsRequired.size() > 0);
        System.assert(testAobApplication.acceptedTerms.size() > 0);
        System.assert(testAobApplication.confirmedEntityDetails);
        System.assert(!testAobApplication.confirmedAccountDetails);

    }

}