/**
 * @description       : SFP-19834 HttpCalloutMock class to create fake responses for Ping
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             :
 * @last modified on  : 08-01-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
 */

@isTest(seeAllData=false)
public class PP_UserRegistrationMockHttpResponse implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;

    /**
     * @description       : HttpCalloutMock class to create fake responses for Ping
     * @param             : requests
     * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
     * @group             : Cloudsmiths
     * @last modified on  : 08-01-2023
     * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
     */
    public PP_UserRegistrationMockHttpResponse(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    /**
     * @description       : HttpCalloutMock class to create fake responses for Ping
     * @param             : req
     * @return            : HTTPResponse
     * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
     * @group             : Cloudsmiths
     * @last modified on  : 08-01-2023
     * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
     */
    public HTTPResponse respond(HTTPRequest req) {

        List<String> splittedURL = new List<String>();
        HttpCalloutMock mock;
        
        if(req.getEndpoint().containsIgnoreCase('authorization')){

            splittedURL = req.getEndpoint().split('&');
            
            mock = requests.get(splittedURL.get(0));
        }else{
            mock = requests.get(req.getEndpoint());
        }
        
        if (mock != null) {
            return mock.respond(req);
        } else {
            throw new CustomException('HTTP callout not supported for test methods');
        }
    }

    private class CustomException extends Exception {
    }
}