/**
 * Mock class for IB_SRV_GatewayAPI_GetCCAP
 * TBD
 *
 * @author Nikita Haruk
 * @date 2022-09-07
 *
 */
@IsTest
global with sharing class IB_SRV_GatewayAPI_Mock implements HttpCalloutMock {
    String cifNumber;
    Integer statusCode;

    global IB_SRV_GatewayAPI_Mock(String cifNumber, Integer statusCode) {
        this.cifNumber  = cifNumber;
        this.statusCode = statusCode;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        String endpoint = String.valueOf(req.getEndpoint());
        
        if (endPoint.contains('auth')) {
            if (this.statusCode != 200) {
                res.setBody('{"error_description":"some_dummy_error"');
            } else {
                res.setBody('{"access_token":"test_access_token"}');
            }
        } else if (endpoint.contains('risk-app-store')) {
            if (this.statusCode != 200) {
                res.setBody('{"moreInformation":"some_information_about_error"}');
            } else {
                res.setBody(
                    '{' +
                        '"code": 0,' +
                        '"messages": ["Operation completed successfully!"],' +
                        '"data":{' +
                            '"cifNumber": "' + this.cifNumber + '",' +
                            '"weightedRiskGrade": "ABC123",' +
                            '"weightedLGD": "12.34",' +
                            '"ccapzar": "123456789.00000000",' +
                            '"ccapusd": "123456789.00000000"' +
                        '}' +
                    '}'
                );
            }
        }

        res.setStatusCode(this.statusCode);
        return res;
    }
}