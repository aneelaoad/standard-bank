/**
 * @description       : SFP-19834 HttpCalloutMock class to set the fake responses
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             : Cloudsmiths
 * @last modified on  : 08-01-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
 */

@isTest
public class PP_UserRegistrationSingleRequestMock implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    protected String bodyAsString;
    protected Blob bodyAsBlob;
    protected Map<String, String> responseHeaders;

    /**
     * @description       : HttpCalloutMock class to set the fake responses
     * @param             : status
     * @param             : body
     * @param             : code
     * @param             : responseHeaders
     * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
     * @group             : Cloudsmiths
     * @last modified on  : 08-01-2023
     * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
     */
    public PP_UserRegistrationSingleRequestMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
        this.bodyAsBlob = null;
        this.responseHeaders = responseHeaders;
    }

    /**
     * @description       : HttpCalloutMock class to set the fake responses
     * @param             : code
     * @param             : status
     * @param             : responseHeaders
     * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
     * @group             : Cloudsmiths
     * @last modified on  : 08-01-2023
     * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
     */
    public PP_UserRegistrationSingleRequestMock(Integer code, String status, Blob body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.bodyAsBlob = body;
        this.bodyAsString = null;
        this.responseHeaders = responseHeaders;
    }

    /**
     * @description       : HttpCalloutMock class to set the fake responses
     * @param             : req
     * @return            : HTTPResponse
     * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
     * @group             : Cloudsmiths
     * @last modified on  : 08-01-2023
     * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
     */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(code);
        resp.setStatus(status);
        if (bodyAsBlob != null) {
            resp.setBodyAsBlob(bodyAsBlob);
        } else {
            resp.setBody(bodyAsString);
        }

        if (responseHeaders != null) {
            for (String key : responseHeaders.keySet()) {
                resp.setHeader(key, responseHeaders.get(key));
            }
        }
        return resp;
    }
}