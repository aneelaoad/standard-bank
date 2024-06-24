/**
* This mock class for PbbSmart2ConversionalDel
*
* @author   Sandile mathe
* @date	    April 2021
*/
@IsTest	
Public class PbbSmart2ConversionalDel_Mock implements HttpCalloutMock{
    /**
    * This method is for HTTP Response for a callout Class
    * @param	req HTTPRequest for Callout
    * @return   Response object
    **/
    public HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('callout:gatewaynp/sysauth/oauth2/token', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }
}