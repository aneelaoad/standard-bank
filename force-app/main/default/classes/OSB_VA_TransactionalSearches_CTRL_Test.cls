@isTest
public class OSB_VA_TransactionalSearches_CTRL_Test
{
    public class SetMockSuccess implements HttpCalloutMock
    {
        public HttpResponse respond(HttpRequest req)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"dateRange":"28-09-2021 - 28-10-2021","paymentInstructionStatuses":[{"uetr":"d4706436-ad00-42d5-9b44-68f76c8b901f","statusOriginatorBic":"SBZAZAJ0XXX","direction":"OUT","settlementAmount":826.09,"status":"In Progress","statusReason":"Unconfirmed","valueDate":"2021-10-15","timeReceived":"2021-10-15T15:15:22.176","currency":"USD","senderBic":"SBZAZAJ0XXX","receiverBic":"SBICUGK0XXX","paymentReference":"IT21288ZA0709965","orderingCustomerF50Line1":"9130002600459","beneInstitutionAccountF59Line1":"9030005676826","ccyOrInstructedAmtF33B":"USD850.0","messageType":"MT103","agentBIC":null,"serviceType":"001","beneInstitution58A":null,"sendersCorrespdnt53B":null,"chargeDetailsF71A":"BEN","cnyFrom":null,"cnyTo":null,"intermediaryInd":null,"conversionRate":null,"systemID":"AMHSAINT","systemRef":"IT21288ZA0709965","sourceSystem":"EE","targetSystem":"AMH","charges":[],"gCCTStatus":{"status":{"statusCode":"null","statusReason":"null"}},"gSRPRequest":{"field11S":null,"status":{"statusCode":"null","statusReason":"null"}},"gSRPAnswer":{"status":{"statusCode":"PDCR","statusReason":"RQDA"}},"additionalSysRef":{"referenceA":null,"referenceB":null},"remittanceInfoF70":"TESTING"},{"uetr":"d4706436-ad00-42d5-9b44-68f76c8b901f","statusOriginatorBic":"SBZAZAJ0XXX","direction":"IN","settlementAmount":826.09,"status":"In Progress","statusReason":"Unconfirmed","valueDate":"2021-10-15","timeReceived":"2021-10-15T15:15:22.176","currency":"USD","senderBic":"SBZAZAJ0XXX","receiverBic":"SBICUGK0XXX","paymentReference":"IT21288ZA0709965","orderingCustomerF50Line1":"23456789","beneInstitutionAccountF59Line1":"9030005676826","ccyOrInstructedAmtF33B":"USD850.0","messageType":"MT103","agentBIC":null,"serviceType":"001","beneInstitution58A":null,"sendersCorrespdnt53B":null,"chargeDetailsF71A":"BEN","cnyFrom":null,"cnyTo":null,"intermediaryInd":null,"conversionRate":null,"systemID":"AMHSAINT","systemRef":"IT21288ZA0709965","sourceSystem":"EE","targetSystem":"AMH","charges":[],"gCCTStatus":{"status":{"statusCode":"null","statusReason":"null"}},"gSRPRequest":{"field11S":null,"status":{"statusCode":"null","statusReason":"null"}},"gSRPAnswer":{"status":{"statusCode":"PDCR","statusReason":"RQDA"}},"additionalSysRef":{"referenceA":null,"referenceB":null},"remittanceInfoF70":"TESTING"},{"uetr":"f6b5634c-fc66-4cca-8b4f-2b0ac46378b6","statusOriginatorBic":"DEUTDEF0XXX","direction":"OUT","settlementAmount":200,"status":"On Hold","statusReason":"Cannot credit same day","valueDate":"2021-10-07","timeReceived":"2021-10-08T07:13:07","currency":"EUR","senderBic":"SBICMWM0XXX","receiverBic":"DEUTDEF0XXX","paymentReference":"OT21179MW0101041","orderingCustomerF50Line1":"MW050568NC","beneInstitutionAccountF59Line1":"23456789","ccyOrInstructedAmtF33B":"EUR200.0","messageType":"MT103","agentBIC":null,"serviceType":"001","beneInstitution58A":null,"sendersCorrespdnt53B":null,"chargeDetailsF71A":"SHA","cnyFrom":null,"cnyTo":null,"intermediaryInd":null,"conversionRate":null,"systemID":"AMHSAINT","systemRef":null,"sourceSystem":null,"targetSystem":"AMHAR_TO_ESB_TRD","charges":[],"gCCTStatus":{"status":{"statusCode":"null","statusReason":"null"}},"gSRPRequest":{"field11S":null,"status":{"statusCode":"null","statusReason":"null"}},"gSRPAnswer":{"status":{"statusCode":null,"statusReason":null}},"additionalSysRef":{"referenceA":null,"referenceB":null},"remittanceInfoF70":null},{"uetr":"447ccde2-5edd-4d70-bd75-a0236e7df0e0","statusOriginatorBic":"SBZAZAJ0XXX","direction":"OUT","settlementAmount":725,"status":"In Progress","statusReason":"Unconfirmed","valueDate":"2021-10-26","timeReceived":"2021-10-26T08:01:18","currency":"USD","senderBic":"SBICTZT0XXX","receiverBic":"SBZAZAJ0XXX","paymentReference":"OT21299TZ0171200","orderingCustomerF50Line1":"9120000341620","beneInstitutionAccountF59Line1":"23456789","ccyOrInstructedAmtF33B":"USD725.0","messageType":"MT103","agentBIC":null,"serviceType":"001","beneInstitution58A":null,"sendersCorrespdnt53B":null,"chargeDetailsF71A":"SHA","cnyFrom":null,"cnyTo":null,"intermediaryInd":null,"conversionRate":null,"systemID":"AMHSAINT","systemRef":null,"sourceSystem":null,"targetSystem":"AMHSAINT_TO_SMP_IBT","charges":[],"gCCTStatus":{"status":{"statusCode":"null","statusReason":"null"}},"gSRPRequest":{"field11S":null,"status":{"statusCode":"null","statusReason":"null"}},"gSRPAnswer":{"status":{"statusCode":null,"statusReason":null}},"additionalSysRef":{"referenceA":null,"referenceB":null},"remittanceInfoF70":"TESTING RECALL"},{"uetr":"447ccde2-5edd-4d70-bd75-a0236e7df0e0","statusOriginatorBic":"SBZAZAJ0XXX","direction":"IN","settlementAmount":725,"status":"In Progress","statusReason":"Unconfirmed","valueDate":"2021-10-26","timeReceived":"2021-10-26T08:01:18","currency":"USD","senderBic":"SBICTZT0XXX","receiverBic":"SBZAZAJ0XXX","paymentReference":"OT21299TZ0171200","orderingCustomerF50Line1":"9120000341620","beneInstitutionAccountF59Line1":"23456789","ccyOrInstructedAmtF33B":"USD725.0","messageType":"MT103","agentBIC":null,"serviceType":"001","beneInstitution58A":null,"sendersCorrespdnt53B":null,"chargeDetailsF71A":"SHA","cnyFrom":null,"cnyTo":null,"intermediaryInd":null,"conversionRate":null,"systemID":"AMHSAINT","systemRef":null,"sourceSystem":null,"targetSystem":"AMHSAINT_TO_SMP_IBT","charges":[],"gCCTStatus":{"status":{"statusCode":"null","statusReason":"null"}},"gSRPRequest":{"field11S":null,"status":{"statusCode":"null","statusReason":"null"}},"gSRPAnswer":{"status":{"statusCode":null,"statusReason":null}},"additionalSysRef":{"referenceA":null,"referenceB":null},"remittanceInfoF70":"TESTING RECALL"},{"uetr":"a6ffa526-c5d9-4549-8075-9d51609c09f9","statusOriginatorBic":"SBICUGK0","direction":"OUT","settlementAmount":595,"status":"Completed","statusReason":"Credited","valueDate":"2021-10-21","timeReceived":"2021-10-21T09:56:24","currency":"USD","senderBic":"SBICBWG0XXX","receiverBic":"SBICUGK0XXX","paymentReference":"OT21293BW0170239","orderingCustomerF50Line1":"9060002665412","beneInstitutionAccountF59Line1":"23456789","ccyOrInstructedAmtF33B":null,"messageType":"MT103","agentBIC":null,"serviceType":"001","beneInstitution58A":null,"sendersCorrespdnt53B":null,"chargeDetailsF71A":"OUR","cnyFrom":null,"cnyTo":null,"intermediaryInd":null,"conversionRate":null,"systemID":"AMHSAINT","systemRef":null,"sourceSystem":null,"targetSystem":"AMHAR_TO_ESB_TRD","charges":[],"gCCTStatus":{"status":{"statusCode":"null","statusReason":"null"}},"gSRPRequest":{"field11S":null,"status":{"statusCode":"null","statusReason":"null"}},"gSRPAnswer":{"status":{"statusCode":null,"statusReason":null}},"additionalSysRef":{"referenceA":null,"referenceB":null},"remittanceInfoF70":"TESTING CHARGES"},{"uetr":"a6ffa526-c5d9-4549-8075-9d51609c09f9","statusOriginatorBic":"SBICUGK0","direction":"IN","settlementAmount":595,"status":"Completed","statusReason":"Credited","valueDate":"2021-10-21","timeReceived":"2021-10-21T09:56:24","currency":"USD","senderBic":"SBICBWG0XXX","receiverBic":"SBICUGK0XXX","paymentReference":"OT21293BW0170239","orderingCustomerF50Line1":"9060002665412","beneInstitutionAccountF59Line1":"23456789","ccyOrInstructedAmtF33B":null,"messageType":"MT103","agentBIC":null,"serviceType":"001","beneInstitution58A":null,"sendersCorrespdnt53B":null,"chargeDetailsF71A":"OUR","cnyFrom":null,"cnyTo":null,"intermediaryInd":null,"conversionRate":null,"systemID":"AMHSAINT","systemRef":null,"sourceSystem":null,"targetSystem":"AMHAR_TO_ESB_TRD","charges":[],"gCCTStatus":{"status":{"statusCode":"null","statusReason":"null"}},"gSRPRequest":{"field11S":null,"status":{"statusCode":"null","statusReason":"null"}},"gSRPAnswer":{"status":{"statusCode":null,"statusReason":null}},"additionalSysRef":{"referenceA":null,"referenceB":null},"remittanceInfoF70":"TESTING CHARGES"},{"uetr":"d4706436-ad00-42d5-9b44-68f76c8b901f","statusOriginatorBic":"SBZAZAJ0XXX","direction":"OUT","settlementAmount":850,"status":"In Progress","statusReason":"Unconfirmed","valueDate":"2021-10-15","timeReceived":"2021-10-15T15:15:22.176","currency":"USD","senderBic":"SBICUGK0XXX","receiverBic":"SBZAZAJ0XXX","paymentReference":"OT21288UG0145855","orderingCustomerF50Line1":"9030005676826","beneInstitutionAccountF59Line1":"23456789","ccyOrInstructedAmtF33B":"USD850.0","messageType":"MT103","agentBIC":null,"serviceType":"001","beneInstitution58A":null,"sendersCorrespdnt53B":null,"chargeDetailsF71A":"SHA","cnyFrom":null,"cnyTo":null,"intermediaryInd":null,"conversionRate":null,"systemID":"AMHSAINT","systemRef":"IT21288ZA0709965","sourceSystem":"EE","targetSystem":"AMH","charges":[],"gCCTStatus":{"status":{"statusCode":"null","statusReason":"null"}},"gSRPRequest":{"field11S":null,"status":{"statusCode":"null","statusReason":"null"}},"gSRPAnswer":{"status":{"statusCode":"PDCR","statusReason":"RQDA"}},"additionalSysRef":{"referenceA":null,"referenceB":null},"remittanceInfoF70":"TESTING"},{"uetr":"d4706436-ad00-42d5-9b44-68f76c8b901f","statusOriginatorBic":"SBZAZAJ0XXX","direction":"IN","settlementAmount":850,"status":"In Progress","statusReason":"Unconfirmed","valueDate":"2021-10-15","timeReceived":"2021-10-15T15:15:22.176","currency":"USD","senderBic":"SBICUGK0XXX","receiverBic":"SBZAZAJ0XXX","paymentReference":"OT21288UG0145855","orderingCustomerF50Line1":"9030005676826","beneInstitutionAccountF59Line1":"23456789","ccyOrInstructedAmtF33B":"USD850.0","messageType":"MT103","agentBIC":null,"serviceType":"001","beneInstitution58A":null,"sendersCorrespdnt53B":null,"chargeDetailsF71A":"SHA","cnyFrom":null,"cnyTo":null,"intermediaryInd":null,"conversionRate":null,"systemID":"AMHSAINT","systemRef":"IT21288ZA0709965","sourceSystem":"EE","targetSystem":"AMH","charges":[],"gCCTStatus":{"status":{"statusCode":"null","statusReason":"null"}},"gSRPRequest":{"field11S":null,"status":{"statusCode":"null","statusReason":"null"}},"gSRPAnswer":{"status":{"statusCode":"PDCR","statusReason":"RQDA"}},"additionalSysRef":{"referenceA":null,"referenceB":null},"remittanceInfoF70":"TESTING"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class SetMockNoContent implements HttpCalloutMock
    {
        public HttpResponse respond(HttpRequest req)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('NO_CONTENT');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    public static void testSuccess()
    {
        Test.setMock(HttpCalloutMock.class, new SetMockSuccess());
        OSB_VA_TransactionalSearches_CTRL.TransactionsSearchInput tsi = new OSB_VA_TransactionalSearches_CTRL.TransactionsSearchInput();
        tsi.minAmount = '1';
        tsi.maxAmount = '1000000';
        tsi.accountNumber = '9130002600459';
        tsi.curency = 'USD';
        tsi.transactionDate = Date.newInstance(2021, 10, 14);

        test.startTest();
        List<OSB_VA_TransactionsSearchOutput> ltso = OSB_VA_TransactionalSearches_CTRL.getTransactions(new List<OSB_VA_TransactionalSearches_CTRL.TransactionsSearchInput>{tsi});
        test.stopTest();
        
        List<String> uetrs = new List<String>();
        for(OSB_VA_TransactionsSearchOutput tso : ltso)
        {
            for(OSB_VA_TransactionInfo ti : tso.transactions) uetrs.add(ti.uetr);
        }
        
        System.assert(uetrs.contains('d4706436-ad00-42d5-9b44-68f76c8b901f'));
    }
    
    @isTest
    public static void testNoContent()
    {
        Test.setMock(HttpCalloutMock.class, new SetMockNoContent());
        OSB_VA_TransactionalSearches_CTRL.TransactionsSearchInput tsi = new OSB_VA_TransactionalSearches_CTRL.TransactionsSearchInput();
        tsi.minAmount = '1';
        tsi.maxAmount = '1000000';
        tsi.accountNumber = '9130002600459';
        tsi.curency = 'USD';
        tsi.transactionDate = Date.newInstance(2021, 10, 14);

        test.startTest();
        List<OSB_VA_TransactionsSearchOutput> ltso = OSB_VA_TransactionalSearches_CTRL.getTransactions(new List<OSB_VA_TransactionalSearches_CTRL.TransactionsSearchInput>{tsi});
        test.stopTest();
        
        List<String> errorTypes = new List<String>();
        
        for(OSB_VA_TransactionsSearchOutput tso : ltso)
        {
            errorTypes.add(tso.errorType);
        }
        
        System.assert(errorTypes.contains('NoContent'));
    }
}