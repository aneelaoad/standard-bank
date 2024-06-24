/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
*
* Test Class for AOB_LegalEntityHierarchyResource class.
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Caro Reinecke
* @version        1.0
* @created        2018-02-20
* @systemLayer    Test ( Choose from: Invocation | Service | Utility | Selector | Domain | Test )
*
* {
  "createdAt": "2018-03-08 11:14:29",
  "modifiedAt": "2018-03-08 11:15:10",
  "id": 431,
  "legalEntity": {
    "salesforceId": "0010E00000DxdsNQAR",
    "cif": "530664300",
    "typeOfEntity": "Pty Ltd",
    "tradingAs": "Power",
    "registrationNumber": "2009/011794/07                                    ",
    "registeredName": "EOH Power Systems (Pty) Ltd.",
    "telephoneNumber": "0121231234",
    "vatNumber": "1010",
    "address": {
      "registeredAddress": "EOH Business Park",
      "line2": "Gilloolys View",
      "province": "Gauteng                                           ",
      "registeredCity": "Johannesburg                                      ",
      "postalCode": "1666           ",
      "country": "SOUTH AFRICA                                      "
    },
    "relatedParties": [
      {
        "createdAt": "2018-03-08 11:14:41",
        "modifiedAt": "2018-03-08 11:14:56",
        "id": 439,
        "businessType": "Client                                  ",
        "identityNumber": null,
        "sharePercentage": 0,
        "firstName": null,
        "lastName": null,
        "registrationNumber": null,
        "registeredName": "Client:EOH Power Systems (Pty) Ltd.",
        "contactNumber": null,
        "capacity": null,
        "emailAddress": null,
        "registeredAddress": null,
        "headOfficeAddress": null,
        "physicalAddress": null,
        "supportingDocuments": []
      }
    ],
    "supportingDocuments": [
      {
        "documentType": null,
        "name": "EOH Power Systems (Pty) Ltd.",
        "verified": false,
        "documentId": "8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"
      },
      {
        "documentType": null,
        "name": "CIPC Document:EOH Power Systems (Pty) Ltd.",
        "verified": false,
        "documentId": "8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"
      },
      {
        "documentType": null,
        "name": "EOH Power Systems (Pty) Ltd.",
        "verified": false,
        "documentId": "8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"
      }
    ]
  },
  "bankAccount": {
    "createdAt": "2018-03-08 11:15:10",
    "modifiedAt": "2018-03-08 11:15:10",
    "accountType": "Business Current Account",
    "accountNumber": "2654725000",
    "branchCode": "Rosebank",
    "active": false,
    "signatories": [
      {
        "createdAt": "2018-03-08 11:15:53",
        "modifiedAt": "2018-03-08 11:15:53",
        "idNumber": "700709099083",
        "firstName": "Siya",
        "lastName": "Khanyile",
        "contactNumber": "0121231234",
        "emailAddress": "syabongak@gmail.com",
        "signingLimits": 100,
        "signingArrangements": "None",
        "address": null,
        "supportingDocuments": null
      }
    ],
    "preferences": {
      "accountName": "My Acc",
      "statementDeliveryFrequency": null,
      "statementDeliveryMethod": null,
      "deliveryDestination": "syabongak@gmail.com"
    }
  },
  "additionalProductsRequired": [],
  "acceptedTerms": [
    {
      "createdAt": "2018-03-08 11:14:29",
      "modifiedAt": "2018-03-08 11:14:29",
      "term": {
        "createdAt": "2018-01-02 12:42:25",
        "modifiedAt": "2018-01-02 12:42:25",
        "name": "Business Current Account terms.",
        "title": "Business Current Account terms.",
        "url": "http://www.standardbank.co.za/standardbank/Business/Banking/Business-account/Business-current-account"
      }
    },
    {
      "createdAt": "2018-03-08 11:14:29",
      "modifiedAt": "2018-03-08 11:14:29",
      "term": {
        "createdAt": "2018-01-02 12:42:25",
        "modifiedAt": "2018-01-02 12:42:25",
        "name": "Standard Bank General Terms and Conditions",
        "title": "Standard Bank General Terms and Conditions",
        "url": "http://www.standardbank.co.za/standardbank/About-Us/Conditions-of-access"
      }
    }
  ],
  "fieldChanges": "address, signatories",
  "product": {
    "createdAt": "2018-01-02 12:42:25",
    "modifiedAt": "2018-01-02 12:42:25",
    "id": 1,
    "name": "Business Current Account",
    "description": "Enjoy a secure means of paying and collecting funds.",
    "openingDepositCents": 50000,
    "monthlyFeeCents": 6900,
    "access": null,
    "terms": [
      {
        "createdAt": "2018-01-02 12:42:25",
        "modifiedAt": "2018-01-02 12:42:25",
        "name": "Business Current Account terms.",
        "title": "Business Current Account terms.",
        "url": "http://www.standardbank.co.za/standardbank/Business/Banking/Business-account/Business-current-account"
      },
      {
        "createdAt": "2018-01-02 12:42:25",
        "modifiedAt": "2018-01-02 12:42:25",
        "name": "Standard Bank General Terms and Conditions",
        "title": "Standard Bank General Terms and Conditions",
        "url": "http://www.standardbank.co.za/standardbank/About-Us/Conditions-of-access"
      }
    ]
  },
  "requester" : {
    "requestedBy" : "Test Authorized Person",
    "requesterNumber" : "072229999"
  },
  "confirmedEntityDetails": true,
  "confirmedAccountDetails": false
}
* @description test class for AOB_AccountApplicationResource
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@IsTest
private class AOB_AccountApplication_Test {

    private static final Integer HTTP_RESPONSE_CODE_OK = 200;
    private static final Integer HTTP_RESPONSE_CODE_ERROR = 500;
    private static final String USER_NAME = 'henimmarrifi-1815@yopmail.com';
    private static User aobUser {
        get {
            if (aobUser == null) {
                aobUser = [SELECT Id FROM User WHERE UserName = :USER_NAME];
            }
            return aobUser;
        }
    }

    @TestSetup
    static void setup() {
        new BLD_USER(USER_NAME)
                .useAPIUser()
                .commitWork();
        System.runAs(aobUser) {

            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            BLD_Account testAccount = new BLD_Account(uow);
            testAccount.CIF('530437495')
                    .setField(Account.Name, 'dwadawdawdfdfewafdea')
                    .setField(Account.BillingCountry, 'South Africa')
                    .setField(Account.Industry_Code__c,'65990')
                    .setField(Account.Primary_Relationship_Holder__c, 'Commercial Banking')
                    .setField(Account.CIF_Client_Type__c, 'R');

            uow.commitWork();
        }
    }

    @IsTest
    static void testPostMethodPositiveNewAApp() {

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        List<Account> testAccounts = new SEL_Accounts().selectByCIFNumber( new Set<String>{'530437495'});
        Account testAccount = testAccounts[0];

        request.requestUri ='/services/apexrest/AccountApplication';
        request.httpMethod = 'POST';
        // new app
        request.requestBody = Blob.valueOf('{"createdAt":"2018-03-0811:14:29","modifiedAt":"2018-03-0811:15:10","id":431,' +
                '"legalEntity":{"salesforceId":"'+testAccount.Id+'","cif":"530664300","typeOfEntity":"PtyLtd","tradingAs":"Power","registrationNumber":"2009/011794/07","registeredName":"EOHPowerSystems(Pty)Ltd.","telephoneNumber":"0121231234","vatNumber":"1010",' +
                '"address":{"registeredAddress":"EOHBusinessPark","line2":"GilloolysView","province":"Gauteng","registeredCity":"Johannesburg","postalCode":"1666","country":"SOUTHAFRICA"},' +
                '"relatedParties":[{"createdAt":"2018-03-0811:14:41","modifiedAt":"2018-03-0811:14:56","id":439,"businessType":"Client","identityNumber":null,"sharePercentage":0,"firstName":null,"lastName":null,"registrationNumber":null,"registeredName":"Client:EOHPowerSystems(Pty)Ltd.","contactNumber":null,"capacity":null,"emailAddress":null,"registeredAddress":null,"headOfficeAddress":null,"physicalAddress":null,' +
                '"supportingDocuments":[{"documentType":null,"name":"EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"},{"documentType":null,"name":"CIPCDocument:EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"},{"documentType":null,"name":"EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"}]}],' +
                '"supportingDocuments":[{"documentType":null,"name":"EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"},{"documentType":null,"name":"CIPCDocument:EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"},{"documentType":null,"name":"EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"}]},' +
                '"bankAccount":{"createdAt":"2018-03-0811:15:10","modifiedAt":"2018-03-0811:15:10","accountType":"BusinessCurrentAccount","accountNumber":"2654725000","branchCode":"Rosebank","active":false,' +
                '"signatories":[{"createdAt":"2018-03-0811:15:53","modifiedAt":"2018-03-0811:15:53","idNumber":"700709099083","firstName":"Siya","lastName":"Khanyile","contactNumber":"0121231234","emailAddress":"syabongak@gmail.com","signingLimits":100,"signingArrangements":"None","address":null,' +
                '"supportingDocuments":[{"documentType":null,"name":"EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"},{"documentType":null,"name":"CIPCDocument:EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"},{"documentType":null,"name":"EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"}]}],' +
                '"preferences":{"accountName":"MyAcc","statementDeliveryFrequency":null,"statementDeliveryMethod":null,"deliveryDestination":"syabongak@gmail.com"}},' +
                '"additionalProductsRequired":[],' +
                '"acceptedTerms":[{"createdAt":"2018-03-0811:14:29","modifiedAt":"2018-03-0811:14:29","term":{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"BusinessCurrentAccountterms.","title":"BusinessCurrentAccountterms.","url":"http://www.standardbank.co.za/standardbank/Business/Banking/Business-account/Business-current-account"}},{"createdAt":"2018-03-0811:14:29","modifiedAt":"2018-03-0811:14:29","term":{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"StandardBankGeneralTermsandConditions","title":"StandardBankGeneralTermsandConditions","url":"http://www.standardbank.co.za/standardbank/About-Us/Conditions-of-access"}}],' +
                '"fieldChanges":"address,signatories",' +
                '"product":{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","id":1,"name":"BusinessCurrentAccount","description":"Enjoyasecuremeansofpayingandcollectingfunds.","openingDepositCents":50000,"monthlyFeeCents":6900,"access":null,"terms":[{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"BusinessCurrentAccountterms.","title":"BusinessCurrentAccountterms.","url":"http://www.standardbank.co.za/standardbank/Business/Banking/Business-account/Business-current-account"},{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"StandardBankGeneralTermsandConditions","title":"StandardBankGeneralTermsandConditions","url":"http://www.standardbank.co.za/standardbank/About-Us/Conditions-of-access"}]},' +
                '"requester":{"requestedBy":"Test Authorized Person","requesterNumber":"072229999"},"confirmedEntityDetails":true,"confirmedAccountDetails":false}');
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        AOB_AccountApplicationResource.doPost();
        Test.stopTest();
        System.assertEquals(HTTP_RESPONSE_CODE_OK, RestContext.response.statusCode);
    }

    @IsTest
    static void testPostMethodPositiveNewAAppNoSalesforceId() {

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        List<Account> testAccounts = new SEL_Accounts().selectByCIFNumber( new Set<String>{'530437495'});
        Account testAccount = testAccounts[0];

        request.requestUri ='/services/apexrest/AccountApplication';
        request.httpMethod = 'POST';
        // new app
        request.requestBody = Blob.valueOf('{"createdAt":"2018-03-0811:14:29","modifiedAt":"2018-03-0811:15:10","id":431,' +
                '"legalEntity":{"salesforceId":null,"cif":"'+testAccount.CIF__c+'","typeOfEntity":"PtyLtd","tradingAs":"Power","registrationNumber":"2009/011794/07","registeredName":"EOHPowerSystems(Pty)Ltd.","telephoneNumber":"0121231234","vatNumber":"1010",' +
                '"address":{"registeredAddress":"EOHBusinessPark","line2":"GilloolysView","province":"Gauteng","registeredCity":"Johannesburg","postalCode":"1666","country":"SOUTHAFRICA"},' +
                '"relatedParties":[{"createdAt":"2018-03-0811:14:41","modifiedAt":"2018-03-0811:14:56","id":439,"businessType":"Client","identityNumber":null,"sharePercentage":0,"firstName":null,"lastName":null,"registrationNumber":null,"registeredName":"Client:EOHPowerSystems(Pty)Ltd.","contactNumber":null,"capacity":null,"emailAddress":null,"registeredAddress":null,"headOfficeAddress":null,"physicalAddress":null,"supportingDocuments":[]}],' +
                '"supportingDocuments":[{"documentType":null,"name":"EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"},{"documentType":null,"name":"CIPCDocument:EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"},{"documentType":null,"name":"EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"}]},' +
                '"bankAccount":{"createdAt":"2018-03-0811:15:10","modifiedAt":"2018-03-0811:15:10","accountType":"BusinessCurrentAccount","accountNumber":"2654725000","branchCode":"Rosebank","active":false,' +
                '"signatories":[{"createdAt":"2018-03-0811:15:53","modifiedAt":"2018-03-0811:15:53","idNumber":"700709099083","firstName":"Siya","lastName":"Khanyile","contactNumber":"0121231234","emailAddress":"syabongak@gmail.com","signingLimits":100,"signingArrangements":"None","address":null,' +
                '"supportingDocuments":null}],' +
                '"preferences":{"accountName":"MyAcc","statementDeliveryFrequency":null,"statementDeliveryMethod":null,"deliveryDestination":"syabongak@gmail.com"}},' +
                '"additionalProductsRequired":[],' +
                '"acceptedTerms":[{"createdAt":"2018-03-0811:14:29","modifiedAt":"2018-03-0811:14:29","term":{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"BusinessCurrentAccountterms.","title":"BusinessCurrentAccountterms.","url":"http://www.standardbank.co.za/standardbank/Business/Banking/Business-account/Business-current-account"}},{"createdAt":"2018-03-0811:14:29","modifiedAt":"2018-03-0811:14:29","term":{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"StandardBankGeneralTermsandConditions","title":"StandardBankGeneralTermsandConditions","url":"http://www.standardbank.co.za/standardbank/About-Us/Conditions-of-access"}}],' +
                '"fieldChanges":"address,signatories",' +
                '"product":{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","id":1,"name":"BusinessCurrentAccount","description":"Enjoyasecuremeansofpayingandcollectingfunds.","openingDepositCents":50000,"monthlyFeeCents":6900,"access":null,"terms":[{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"BusinessCurrentAccountterms.","title":"BusinessCurrentAccountterms.","url":"http://www.standardbank.co.za/standardbank/Business/Banking/Business-account/Business-current-account"},{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"StandardBankGeneralTermsandConditions","title":"StandardBankGeneralTermsandConditions","url":"http://www.standardbank.co.za/standardbank/About-Us/Conditions-of-access"}]},' +
                '"requester":{"requestedBy":"Test Authorized Person","requesterNumber":"072229999"},"confirmedEntityDetails":true,"confirmedAccountDetails":false}');
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        AOB_AccountApplicationResource.doPost();
        Test.stopTest();
        System.assertEquals(HTTP_RESPONSE_CODE_OK, RestContext.response.statusCode);
    }

    @IsTest
    static void testPostMethodPositiveUpdatedApp() {

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        List<Account> testAccounts = new SEL_Accounts().selectByCIFNumber( new Set<String>{'530437495'});
        Account testAccount = testAccounts[0];

        request.requestUri ='/services/apexrest/AccountApplication';
        request.httpMethod = 'POST';
        // new app
        request.requestBody = Blob.valueOf('{"createdAt":"2018-03-0811:14:29","modifiedAt":"2018-03-0811:15:10","id":431,' +
                '"legalEntity":{"salesforceId":"'+testAccount.Id+'","cif":"530664300","typeOfEntity":"PtyLtd","tradingAs":"Power","registrationNumber":"2009/011794/07","registeredName":"EOHPowerSystems(Pty)Ltd.","telephoneNumber":"0121231234","vatNumber":"1010",' +
                '"address":{"registeredAddress":"EOHBusinessPark","line2":"GilloolysView","province":"Gauteng","registeredCity":"Johannesburg","postalCode":"1666","country":"SOUTHAFRICA"},' +
                '"relatedParties":[{"createdAt":"2018-03-0811:14:41","modifiedAt":"2018-03-0811:14:56","id":439,"businessType":"Client","identityNumber":null,"sharePercentage":0,"firstName":null,"lastName":null,"registrationNumber":null,"registeredName":"Client:EOHPowerSystems(Pty)Ltd.","contactNumber":null,"capacity":null,"emailAddress":null,"registeredAddress":null,"headOfficeAddress":null,"physicalAddress":null,"supportingDocuments":[]}],' +
                '"supportingDocuments":[{"documentType":null,"name":"EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"},{"documentType":null,"name":"CIPCDocument:EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"},{"documentType":null,"name":"EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"}]},' +
                '"bankAccount":{"createdAt":"2018-03-0811:15:10","modifiedAt":"2018-03-0811:15:10","accountType":"BusinessCurrentAccount","accountNumber":"2654725000","branchCode":"Rosebank","active":false,' +
                '"signatories":[{"createdAt":"2018-03-0811:15:53","modifiedAt":"2018-03-0811:15:53","idNumber":"700709099083","firstName":"Siya","lastName":"Khanyile","contactNumber":"0121231234","emailAddress":"syabongak@gmail.com","signingLimits":100,"signingArrangements":"None","address":null,' +
                '"supportingDocuments":null}],"preferences":{"accountName":"MyAcc","statementDeliveryFrequency":null,"statementDeliveryMethod":null,"deliveryDestination":"syabongak@gmail.com"}},' +
                '"additionalProductsRequired":[],' +
                '"acceptedTerms":[{"createdAt":"2018-03-0811:14:29","modifiedAt":"2018-03-0811:14:29","term":{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"BusinessCurrentAccountterms.","title":"BusinessCurrentAccountterms.","url":"http://www.standardbank.co.za/standardbank/Business/Banking/Business-account/Business-current-account"}},{"createdAt":"2018-03-0811:14:29","modifiedAt":"2018-03-0811:14:29","term":{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"StandardBankGeneralTermsandConditions","title":"StandardBankGeneralTermsandConditions","url":"http://www.standardbank.co.za/standardbank/About-Us/Conditions-of-access"}}],' +
                '"fieldChanges":"address,signatories",' +
                '"product":{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","id":1,"name":"BusinessCurrentAccount","description":"Enjoyasecuremeansofpayingandcollectingfunds.","openingDepositCents":50000,"monthlyFeeCents":6900,"access":null,"terms":[{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"BusinessCurrentAccountterms.","title":"BusinessCurrentAccountterms.","url":"http://www.standardbank.co.za/standardbank/Business/Banking/Business-account/Business-current-account"},{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"StandardBankGeneralTermsandConditions","title":"StandardBankGeneralTermsandConditions","url":"http://www.standardbank.co.za/standardbank/About-Us/Conditions-of-access"}]},' +
                '"requester":{"requestedBy":"Test Authorized Person","requesterNumber":"072229999"},"confirmedEntityDetails":true,"confirmedAccountDetails":false}');
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        AOB_AccountApplicationResource.doPost();
        request.requestBody = Blob.valueOf('{"createdAt":"2018-03-0811:14:29","modifiedAt":"2018-03-0811:15:10","id":431,"legalEntity":{"salesforceId":"'+testAccount.Id+'","cif":"530664300","typeOfEntity":"PtyLtd","tradingAs":"Power","registrationNumber":"2009/011794/07","registeredName":"EOHPowerSystems(Pty)Ltd.","telephoneNumber":"0121231234","vatNumber":"1010","address":{"registeredAddress":"EOH Business Park","line2":"GilloolysView","province":"Gauteng","registeredCity":"Johannesburg","postalCode":"1666","country":"SOUTHAFRICA"},"relatedParties":[{"createdAt":"2018-03-0811:14:41","modifiedAt":"2018-03-0811:14:56","id":439,"businessType":"Client","identityNumber":null,"sharePercentage":0,"firstName":null,"lastName":null,"registrationNumber":null,"registeredName":"Client:EOHPowerSystems(Pty)Ltd.","contactNumber":null,"capacity":null,"emailAddress":null,"registeredAddress":null,"headOfficeAddress":null,"physicalAddress":null,"supportingDocuments":[]}],"supportingDocuments":[{"documentType":null,"name":"EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"},{"documentType":null,"name":"CIPCDocument:EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"},{"documentType":null,"name":"EOHPowerSystems(Pty)Ltd.","verified":false,"documentId":"8B4B9B4A-3E47-46AC-871A-3C40A5F72E3B"}]},"bankAccount":{"createdAt":"2018-03-0811:15:10","modifiedAt":"2018-03-0811:15:10","accountType":"BusinessCurrentAccount","accountNumber":"2654725000","branchCode":"Rosebank","active":false,"signatories":[{"createdAt":"2018-03-0811:15:53","modifiedAt":"2018-03-0811:15:53","idNumber":"700709099083","firstName":"Siya","lastName":"Khanyile","contactNumber":"0121231234","emailAddress":"syabongak@gmail.com","signingLimits":100,"signingArrangements":"None","address":null,"supportingDocuments":null}],"preferences":{"accountName":"MyAcc","statementDeliveryFrequency":null,"statementDeliveryMethod":null,"deliveryDestination":"syabongak@gmail.com"}},"additionalProductsRequired":[],"acceptedTerms":[{"createdAt":"2018-03-0811:14:29","modifiedAt":"2018-03-0811:14:29","term":{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"BusinessCurrentAccountterms.","title":"BusinessCurrentAccountterms.","url":"http://www.standardbank.co.za/standardbank/Business/Banking/Business-account/Business-current-account"}},{"createdAt":"2018-03-0811:14:29","modifiedAt":"2018-03-0811:14:29","term":{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"StandardBankGeneralTermsandConditions","title":"StandardBankGeneralTermsandConditions","url":"http://www.standardbank.co.za/standardbank/About-Us/Conditions-of-access"}}],"fieldChanges":"address,signatories","product":{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","id":1,"name":"BusinessCurrentAccount","description":"Enjoyasecuremeansofpayingandcollectingfunds.","openingDepositCents":50000,"monthlyFeeCents":6900,"access":null,"terms":[{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"BusinessCurrentAccountterms.","title":"BusinessCurrentAccountterms.","url":"http://www.standardbank.co.za/standardbank/Business/Banking/Business-account/Business-current-account"},{"createdAt":"2018-01-0212:42:25","modifiedAt":"2018-01-0212:42:25","name":"StandardBankGeneralTermsandConditions","title":"StandardBankGeneralTermsandConditions","url":"http://www.standardbank.co.za/standardbank/About-Us/Conditions-of-access"}]},"confirmedEntityDetails":true,"requester":{"requestedBy":"Test Authorized Person","requesterNumber":"072229999"},"confirmedAccountDetails":false}');
        AOB_AccountApplicationResource.doPost();
        Test.stopTest();
        System.assertEquals(HTTP_RESPONSE_CODE_OK, RestContext.response.statusCode);
    }

    @IsTest
    static void testPosttMethodAccountApplicationServiceException() {

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri ='/services/apexrest/AccountApplication';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('["INVALID1"]');
        RestContext.request = request;
        RestContext.response = response;

        AOB_AccountApplicationResource.doPost();

        System.assertEquals(HTTP_RESPONSE_CODE_ERROR, RestContext.response.statusCode);
    }

    @IsTest
    static void testPosttMethodNoBody() {

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri ='/services/apexrest/AccountApplication';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;
        RestContext.response = response;

        AOB_AccountApplicationResource.doPost();
        System.assertEquals(HTTP_RESPONSE_CODE_OK, RestContext.response.statusCode);
    }
}