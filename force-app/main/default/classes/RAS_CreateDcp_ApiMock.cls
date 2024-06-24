/**
* Mock class for RAS_CreateDcp_Api
* US-4434
*
* @author Wayne Solomon
* @date 2020-01-08
*
* Cleaned up header, indentations and spacings
*
* @modified Wayne Solomon
* @date 2020-06-17
*/
@isTest
global class RAS_CreateDcp_ApiMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String endPoint = String.valueOf(req.getEndpoint());
        if (endPoint.contains('auth'))res.setBody('{"access_token":"ejuuiNZlHPz7mtWMaUTKae03r6KN"}');
        else if (endPoint.contains('content')) {
            Id i = [select Id from Business_Assessment__c limit 1].Id;
            res.setBody('[{"businessAssessmentId": "' + i + '","responseMessage": "Application was successfully staged","result": "SUCCESS"},{"businessAssessmentId": "' + i + '","responseMessage": "Application was successfully staged","result": "SUCCESS"}]');
        }
        res.setStatusCode(200);
        return res;
    }
}