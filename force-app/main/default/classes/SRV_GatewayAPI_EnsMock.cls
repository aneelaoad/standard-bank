/**
 * Mock class for SRV_GatewayAPI_Ens
 *
 * @author Nikita
 * @date 2023-02-09
 *
 */
@IsTest
global with sharing class SRV_GatewayAPI_EnsMock implements HttpCalloutMock {
    Id[] id;
    String cifNumber;
    Integer statusCode;
    Boolean isAuthAlwaysGood;

    global SRV_GatewayAPI_EnsMock(Id[] id, String cifNumber, Integer statusCode, Boolean isAuthAlwaysGood) {
        this.id  = id;
        this.cifNumber = cifNumber;
        this.statusCode = statusCode;
        this.isAuthAlwaysGood = isAuthAlwaysGood;
    }
    

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        String endpoint = String.valueOf(req.getEndpoint());
        
        if (endPoint.contains('auth')) {
            if (isAuthAlwaysGood) {
                res.setBody('{"access_token":"test_access_token"}');
            } else {
                if (this.statusCode != 200) {
                    res.setBody('{"error_description":"some_dummy_error"}');
                } else {
                    res.setBody('{"access_token":"test_access_token"}');
                }
            }
        } else if (endpoint.contains('risk-app-store')) {
            if (this.statusCode != 200) {
                res.setBody(
                    '[' +
                        '{' +
                            '"statusCode":' + this.statusCode + ',' +
                            '"errorPayload":"Nbac process with CIF number: ' + this.cifNumber + ' and Business Assessment Id: ' + this.id[0] + ' already exist.",' + 
                            '"id":"' + this.id[0] + '",' +
                            '"cif":"' + this.cifNumber + '",' +
                            '"linkedId":1' +
                        '},' +
                    '{' +
                            '"statusCode":' + 200 + ',' +
                            '"errorPayload":'+null+',' + 
                            '"id":"' + this.id[1] + '",' + 
                            '"cif":"' + this.cifNumber + '",' +
                            '"linkedId":10' +
                        '}' +
                    ']'
                );
            } else {
                res.setBody(
                    '[' +
                        '{' +
                            '"statusCode":' + this.statusCode + ',' +
                            '"errorPayload":"",' + 
                            '"id":"' + this.id + '",' + 
                            '"cif":"' + this.cifNumber + '",' +
                            '"linkedId":0' +
                        '}' +
                    ']'
                );
            }
        }

        
        if (isAuthAlwaysGood && endPoint.contains('auth')) {
            res.setStatusCode(200);
        } else {
            res.setStatusCode(this.statusCode);
        }

        return res;
    }
}