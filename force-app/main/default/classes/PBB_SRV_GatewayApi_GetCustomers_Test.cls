@isTest(isParallel = true)
private class PBB_SRV_GatewayApi_GetCustomers_Test {
    static final String TEST_GUID = '4554f98f-7cc5-0135-0000-00000ab6f52b';
    static final String DATA_NOT_FOUND = 'Data not found';

    @TestSetup
    private static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account bAcc = new BLD_Account(uow);
        bAcc.usePBB().guid(new Uuid().getValue());
        uow.commitWork();
    }


    private static void mockResponse(String body, Integer code) {
        HttpResponse mockedResponse = new HttpResponse();
        mockedResponse.setBody(body);
        mockedResponse.setStatusCode(code);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_HttpRequestSender mockedSender = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        mocks.startStubbing();
        mocks.when(mockedSender.send((HttpRequest) fflib_Match.anyObject())).thenReturn(mockedResponse);
        mocks.when(mockedSender.send((HttpRequest) fflib_Match.anyObject(), fflib_Match.anyInteger())).thenReturn(mockedResponse);
        mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedSender);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
    }

    @isTest
    private static void shouldThrowExceptionWhen500ForCompliance() {
        mockResponse('Error', 500);
        Id accId = [SELECT Id FROM Account LIMIT 1].id;
        PBB_SRV_GatewayApi_GetCustomers customerService = new PBB_SRV_GatewayApi_GetCustomers();
        Boolean correctExcpetionThrown = false;

        Test.startTest();
        try {
            customerService.getCustomerCompliance(accId);
        } catch (PBB_SRV_GatewayApi_GetCustomers.ApiException ex) {
            correctExcpetionThrown = true;
        }
        Test.stopTest();

        System.assert(correctExcpetionThrown);
    }

    @isTest
    private static void shouldThrowExceptionWhen500ForContacts() {
        mockResponse('Error', 500);
        Id accId = [SELECT Id FROM Account LIMIT 1].id;
        PBB_SRV_GatewayApi_GetCustomers customerService = new PBB_SRV_GatewayApi_GetCustomers();
        Boolean correctExcpetionThrown = false;

        Test.startTest();
        try {
            customerService.getCustomerContacts(accId);
        } catch (PBB_SRV_GatewayApi_GetCustomers.ApiException ex) {
            correctExcpetionThrown = true;
        }
        Test.stopTest();

        System.assert(correctExcpetionThrown);
    }

    @isTest
    private static void shouldThrowExceptionWhen500ForStatuses() {
        mockResponse('Error', 500);
        Id accId = [SELECT Id FROM Account LIMIT 1].id;
        PBB_SRV_GatewayApi_GetCustomers customerService = new PBB_SRV_GatewayApi_GetCustomers();
        Boolean correctExcpetionThrown = false;

        Test.startTest();
        try {
            customerService.getCustomerStatuses(accId);
        } catch (PBB_SRV_GatewayApi_GetCustomers.ApiException ex) {
            correctExcpetionThrown = true;
        }
        Test.stopTest();

        System.assert(correctExcpetionThrown);
    }

    @isTest
    private static void shouldThrowExceptionWhen204ForCompliance() {
        mockResponse('Error', 204);
        Id accId = [SELECT Id FROM Account LIMIT 1].id;
        PBB_SRV_GatewayApi_GetCustomers customerService = new PBB_SRV_GatewayApi_GetCustomers();

        Boolean correctExcpetionThrown = false;
        Test.startTest();
        try {
            customerService.getCustomerCompliance(accId);
        } catch (PBB_SRV_GatewayApi_GetCustomers.ApiException ex) {
            correctExcpetionThrown = true;
        }
        Test.stopTest();

        System.assert(correctExcpetionThrown);
    }

    @isTest
    private static void shouldThrowExceptionWhen204ForContacts() {
        mockResponse('Error', 204);
        Id accId = [SELECT Id FROM Account LIMIT 1].id;
        PBB_SRV_GatewayApi_GetCustomers customerService = new PBB_SRV_GatewayApi_GetCustomers();
        Boolean correctExcpetionThrown = false;

        Test.startTest();
        try {
            customerService.getCustomerContacts(accId);
        } catch (PBB_SRV_GatewayApi_GetCustomers.ApiException ex) {
            correctExcpetionThrown = true;
        }
        Test.stopTest();

        System.assert(correctExcpetionThrown);
    }

    @isTest
    private static void shouldThrowExceptionWhen204ForStatuses() {
        mockResponse('Error', 204);
        Id accId = [SELECT Id FROM Account LIMIT 1].id;
        PBB_SRV_GatewayApi_GetCustomers customerService = new PBB_SRV_GatewayApi_GetCustomers();
        Boolean correctExcpetionThrown = false;

        Test.startTest();
        try {
            customerService.getCustomerStatuses(accId);
        } catch (PBB_SRV_GatewayApi_GetCustomers.ApiException ex) {
            correctExcpetionThrown = true;
        }
        Test.stopTest();

        System.assert(correctExcpetionThrown);
    }

    @isTest
    private static void shouldReturnContactDetailListForPropperAccount() {
        PBB_SRV_GatewayApi_GetCustomers.ContactObject[] actual;
        mockResponse('[{"type":"PHONE","value":"1234567","countryCode":"ZA","extension":"","preferredInd":"false","contactPeriod":"DAYTIME","obsoleteInd":"false"},{"type":"EMAIL","value":"test@example.com","preferredInd":"true","obsoleteInd":"false"}]'
                , 200);
        Id accId = [SELECT Id FROM Account LIMIT 1].id;
        PBB_SRV_GatewayApi_GetCustomers customerService = new PBB_SRV_GatewayApi_GetCustomers();
        Boolean correctExcpetionThrown = false;

        Test.startTest();
        actual = customerService.getCustomerContacts(accId);
        Test.stopTest();

        System.assertEquals(2, actual.size());
        System.assertEquals('PHONE', actual[0].type);
        System.assertEquals('1234567', actual[0].value);
        System.assertEquals('ZA', actual[0].countryCode);
        System.assertEquals('false', actual[0].preferredInd);
        System.assertEquals('EMAIL', actual[1].type);
        System.assertEquals('test@example.com', actual[1].value);
    }


    @isTest
    private static void shouldThrowExceptionWhenEmptyBody() {
        PBB_SRV_GatewayApi_GetCustomers.ContactObject[] actual;
        mockResponse('', 200);
        Id accId = [SELECT Id FROM Account LIMIT 1].id;
        PBB_SRV_GatewayApi_GetCustomers customerService = new PBB_SRV_GatewayApi_GetCustomers();
        Boolean correctExceptionThrown = false;
        Test.startTest();
        try {
            actual = customerService.getCustomerContacts(accId);
        } catch (PBB_SRV_GatewayApi_GetCustomers.ApiException e) {
            correctExceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, correctExceptionThrown);
    }

    @isTest
    private static void shouldReturnStatusesPropperAccount() {
        PBB_SRV_GatewayApi_GetCustomers.Status[] actual;
        mockResponse('[{"status":"93","desc":"IN COLLECTIONS","effDate":"2014-11-05","expDate":"9999-12-31"}]', 200);
        Id accId = [SELECT Id FROM Account LIMIT 1].id;
        PBB_SRV_GatewayApi_GetCustomers customerService = new PBB_SRV_GatewayApi_GetCustomers();
        Boolean correctExcpetionThrown = false;
        Test.startTest();
        actual = customerService.getCustomerStatuses(accId);

        Test.stopTest();
        System.assertEquals(1, actual.size());
        System.assertEquals('IN COLLECTIONS', actual[0].description);
        System.assertEquals('93', actual[0].status);
    }

    @isTest
    private static void shouldReturnComplianceForPropperPayload() {
        PBB_SRV_GatewayApi_GetCustomers.GetCustomerValidityInfoResponseWrapper actual;
        mockResponse('{"GetCustomerValidityInfoResponse":{"ComplianceData":[{"ComplianceType":{"Desc":"KYC Requirements"},"ComplianceStatus":{"Desc":"Fulfilled"},"ComplianceInd":"true"}],"PartyValidityInfoStatus":{"PartyValidityInfoStatusCode":"001","StatusDesc":"Outstanding"}}}', 200);
        Id accId = [SELECT Id FROM Account LIMIT 1].id;
        PBB_SRV_GatewayApi_GetCustomers customerService = new PBB_SRV_GatewayApi_GetCustomers();
        Boolean correctExcpetionThrown = false;
        Test.startTest();
        actual = customerService.getCustomerCompliance(accId);

        Test.stopTest();
        System.assertEquals('KYC Requirements', actual.GetCustomerValidityInfoResponse.ComplianceData[0].ComplianceType.description);
        System.assertEquals('Fulfilled', actual.GetCustomerValidityInfoResponse.ComplianceData[0].ComplianceStatus.description);
        System.assertEquals('001', actual.GetCustomerValidityInfoResponse.PartyValidityInfoStatus.PartyValidityInfoStatusCode);
        System.assertEquals('Outstanding', actual.GetCustomerValidityInfoResponse.PartyValidityInfoStatus.StatusDesc);
    }

    private static Id generateAccountRecordWithGUID() {
        Account account = new Account(GUID__c = TEST_GUID, Name = 'test2');
        insert account;
        return account.Id;
    }

    private static void mockAuthentication() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
    }

    private static void mockAuthentication(String token) {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        HttpRequest httpRequestWithToken = new HttpRequest();
        httpRequestWithToken.setHeader('authorization', 'Bearer ' + token);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(httpRequestWithToken);
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
    }

    @isTest
    private static void getContactDetailsAnd200StatusForAccountRecordWhenCallingAPI() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        String resBody = '[{"type":"PHONE","value":"0212412308","countryCode":"ZA","extension":"","preferredInd":"true","contactPeriod":"ANYTIME"}]';
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.ContactObject[] accounts = new PBB_SRV_GatewayApi_GetCustomers().getCustomerContacts(accId);
            Test.stopTest();
        } catch (Exception ex) {
            System.assert(false, 'Should not throw an exception');
        }
    }

    @isTest
    private static void get204StatusForAccountRecordWhenCallingAPIToGetContactDetails() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(204, 'Contacts details not found', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.ContactObject[] accounts = new PBB_SRV_GatewayApi_GetCustomers().getCustomerContacts(accId);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(DATA_NOT_FOUND));
            System.assert(ex.getMessage().contains(accId));
        }
    }

    @isTest
    private static void get500StatusForAccountRecordWhenCallingForContactDetailsAndAPIIsNotWorking() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, 'Unable to connect to the API', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.ContactObject[] accounts = new PBB_SRV_GatewayApi_GetCustomers().getCustomerContacts(accId);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('Got 500 with Unable to connect to the API, body'));
        }
    }

    @isTest
    private static void getCustomerComplianceAnd200StatusForAccountRecordWhenCallingAPI() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        String resBody = '{"GetCustomerValidityInfoResponse":{"ComplianceData":[{"ComplianceType":{"Desc":"KYC Requirements"},"ComplianceStatus":{"Desc":"Fulfilled"},"ComplianceInd":"true"}]}}';
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.GetCustomerValidityInfoResponseWrapper accounts = new PBB_SRV_GatewayApi_GetCustomers().getCustomerCompliance(accId);
            Test.stopTest();
        } catch (Exception ex) {
            System.assert(false, 'Should not throw an exception');
        }
    }

    @isTest
    private static void get204StatusForAccountRecordWhenCallingAPIToGetCompliance() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(204, 'Compliance not found', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.GetCustomerValidityInfoResponseWrapper accounts = new PBB_SRV_GatewayApi_GetCustomers().getCustomerCompliance(accId);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(DATA_NOT_FOUND));
            System.assert(ex.getMessage().contains(accId));
        }
    }

    @isTest
    private static void get500StatusForAccountRecordWhenCallingforComplianceAndAPIIsNotWorking() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, 'Unable to connect to the API', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.GetCustomerValidityInfoResponseWrapper accounts = new PBB_SRV_GatewayApi_GetCustomers().getCustomerCompliance(accId);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('Got 500 with Unable to connect to the API, body'));
        }
    }

    @isTest
    private static void getCustomerStatusesAnd200StatusForAccountRecordWhenCallingAPI() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        String resBody = '[{"status":"93","desc":"IN COLLECTIONS","effDate":"2014-12-05","expDate":"9999-12-31"}]';
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.Status[] accounts = new PBB_SRV_GatewayApi_GetCustomers().getCustomerStatuses(accId);
            Test.stopTest();
        } catch (Exception ex) {
            System.assert(false, 'Should not throw an exception');
        }
    }

    @isTest
    private static void get204StatusForAccountRecordWhenCallingAPIToGetCustomerStatus() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(204, 'Statuses not found', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.Status[] accounts = new PBB_SRV_GatewayApi_GetCustomers().getCustomerStatuses(accId);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(DATA_NOT_FOUND));
            System.assert(ex.getMessage().contains(accId));
        }
    }

    @isTest
    private static void get500StatusCodeForAccountRecordWhenCallingforCustomerStatusesAndAPIIsNotWorking() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, 'Unable to connect to the API', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.Status[] accounts = new PBB_SRV_GatewayApi_GetCustomers().getCustomerStatuses(accId);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('Got 500 with Unable to connect to the API, body'));
        }
    }

    @isTest
    private static void getCustomerIdentificationsAnd200StatusForAccountRecordWhenCallingAPI() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        String testIDnumber = '2002/123459/07';
        String resBody = '[{"type":"ENTERPRISE REGISTRATION NUMBER","number":"'+ testIDnumber +'","issuingCountry":"ZA","issuedDate":"2000-07-01","expirationDate":"9999-12-31"}]';
        Map<String, String> resHeaders = new Map<String, String> ();
        List<PBB_SRV_GatewayApi_GetCustomers.Identification> identifications;
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
            Test.startTest();
            identifications = PBB_SRV_GatewayApi_GetCustomers.newInstance().getCustomerIdentifications(accId);
            Test.stopTest();
        } catch (Exception ex) {
            System.assert(false, 'Should not throw an exception');
        }
        System.assertEquals(testIDnumber, identifications[0].IDnumber);
    }

    @isTest
    private static void get204StatusForAccountRecordWhenCallingAPIToGetCustomerIdentifications() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(204, '', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.newInstance().getCustomerIdentifications(accId);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(DATA_NOT_FOUND));
            System.assert(ex.getMessage().contains(accId));
        }
    }

    @isTest
    private static void get500StatusCodeForAccountRecordWhenCallingforCustomerIdentificationsAndAPIIsNotWorking() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, 'Unable to connect to the API', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.newInstance().getCustomerIdentifications(accId);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(' 500 '));
            System.assert(ex.getMessage().contains(PBB_SRV_GatewayApi_GetCustomers.URL_ACCOUNT_IDENTIFICATIONS));
            System.assert(ex.getMessage().contains(accId));
        }
    }

    @isTest
    private static void getCustomerBaseAnd200StatusForAccountRecordWhenCallingAPI() {
        String token = 'xfaPFaT74a9KWaQm2tFKuV7WtNwdPTVhebjMMg4awLP8xVNheMkL6eueMZhpMmvWRRmNVnprnWtvjXWnDbvubxNtWHNCh99CZYUSxfaPFaT74a9KWaQm2tFKuV7WtNwdPTVhebjMMg4awLP8xVNheMkL6eueMZhpMmvWRRmNVnprnWtvjXWnDbvubxNtWHNCh99CZYUSxfaPFaT74a9KWaQm2tFKuV7WtNwdPTVhebjMMg4awLP8xVNheMkL6eueMZhpMmvWRRmNVnprnWtvjXWnDbvubxNtWHNCh99CZYUSXXXXXXXX';
        mockAuthentication(token);
        Id accId = generateAccountRecordWithGUID();
        Account account = [SELECT GUID__c FROM Account WHERE Id =: accId];
        String testBPID = '123456';
        String testLegalName = 'TESTING LTD';
        String resBody = '{\n' +
                ' "customer": {\n' +
                '  "residenceCountry": "ZA",\n' +
                '  "relManagerLink": "enim Duis",\n' +
                '  "fraudConsent": "true",\n' +
                '  "orgDetails": {\n' +
                '   "legalName": "'+ testLegalName +'",\n' +
                '   "companyName": "TESTing"\n' +
                '  },\n' +
                '  "mktgSegment": "110",\n' +
                '  "customerRole": [\n' +
                '   {\n' +
                '    "role": "ZSHHOL",\n' +
                '    "startDate": "2018-04-06",\n' +
                '    "endDate": "9999-12-31"\n' +
                '   },\n' +
                '   {\n' +
                '    "role": "BUP042",\n' +
                '    "startDate": "2018-04-06",\n' +
                '    "endDate": "9999-12-31"\n' +
                '   }\n' +
                '  ]\n' +
                ' }\n' +
                '}';
        Map<String, String> resHeaders = new Map<String, String>();
        resHeaders.put('obscuredData', encryptBPID(testBPID, token));

        PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse customerBaseResponse;
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
            Test.startTest();
            customerBaseResponse = PBB_SRV_GatewayApi_GetCustomers.newInstance().getBase(account.GUID__c);
            Test.stopTest();
        } catch (Exception ex) {
            System.assert(false, 'Should not throw an exception');
        }
        System.assertEquals(testBPID, customerBaseResponse.customer.BPID);
        System.assertEquals(testLegalName, customerBaseResponse.customer.orgDetails.legalName);
    }

    private static String encryptBPID(String bpid, String token) {
        String key = token.substring(50, 82);
        String vector = token.substring(90, 106);
        Blob encrypted =  Crypto.encrypt('AES256', Blob.valueOf(key), Blob.valueOf(vector), Blob.valueOf(bpid));
        return EncodingUtil.base64Encode(encrypted);
    }

    @isTest
    private static void get204StatusForAccountRecordWhenCallingAPIToGetCustomerBase() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        Account account = [SELECT GUID__c FROM Account WHERE Id = :accId];
        Map<String, String> resHeaders = new Map<String, String>();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(204, '', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.newInstance().getBase(account.GUID__c);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(DATA_NOT_FOUND));
            System.assert(ex.getMessage().contains(account.GUID__c));
        }
    }

    @isTest
    private static void get500StatusCodeForAccountRecordWhenCallingforCustomerBaseAndAPIIsNotWorking() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        Account account = [SELECT GUID__c FROM Account WHERE Id = :accId];
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, 'Unable to connect to the API', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.newInstance().getBase(account.GUID__c);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(' 500 '));
            System.assert(ex.getMessage().contains(PBB_SRV_GatewayApi_GetCustomers.URL_ACCOUNT));
            System.assert(ex.getMessage().contains(account.GUID__c));
        }
    }

    @isTest
    private static void getCustomerAddressesAnd200StatusForAccountRecordWhenCallingAPI() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        String testCity = 'JOHANNESBURG';
        String resBody = '[{"uuid":"' + TEST_GUID + '","type":["KYC","EFFECTIVE MANAGEMENT ADDRESS"],"line1":"","line2":"",' +
                '"line3":"15 XXX ST","line4":"","district":"MARSHALLTOWN","city":"JOHANNESBURG","province":"ZAF.GP","postalCode":"2001",' +
                '"countryCode":"ZA","plotNumber":"","POBOX":"","obsoleteReason":"","preferredInd":"","comment":"","startDate":"2011-02-08","endDate":"9999-12-31"}]';
        Map<String, String> resHeaders = new Map<String, String> ();
        List<PBB_SRV_GatewayApi_GetCustomers.Address> addresses;
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
            Test.startTest();
            addresses = PBB_SRV_GatewayApi_GetCustomers.newInstance().getAddresses(accId);
            Test.stopTest();
        } catch (Exception ex) {
            System.assert(false, 'Should not throw an exception');
        }
        System.assertEquals(testCity, addresses[0].city);
    }

    @isTest
    private static void get204StatusForAccountRecordWhenCallingAPIToGetCustomerAddresses() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(204, '', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.newInstance().getAddresses(accId);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(DATA_NOT_FOUND));
            System.assert(ex.getMessage().contains(accId));
        }
    }

    @isTest
    private static void get500StatusCodeForAccountRecordWhenCallingforCustomerAddressesAndAPIIsNotWorking() {
        mockAuthentication();
        Id accId = generateAccountRecordWithGUID();
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, 'Unable to connect to the API', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_GetCustomers.newInstance().getAddresses(accId);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(' 500 '));
            System.assert(ex.getMessage().contains(PBB_SRV_GatewayApi_GetCustomers.URL_ACCOUNT_ADDRESSES));
            System.assert(ex.getMessage().contains(accId));
        }
    }
}