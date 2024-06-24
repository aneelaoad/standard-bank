/**
 *
 * Test class mocking the http callouts made by OneHub chat bot
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 */
@IsTest
public class OSB_VA_HttpCalloutMock implements HttpCalloutMock {

    public static final String CODE_KEY = 'code';
    public static final String BODY_KEY = 'body';
    public static final String STATUS_KEY = 'status';
    public static final String SWIFT_KEY = 'SWIFT';
    public static final String INTIX_KEY = 'INTIX';

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public OSB_VA_HttpCalloutMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(responseHeaders!=null){
            for (String key : this.responseHeaders.keySet()) {
                res.setHeader(key, this.responseHeaders.get(key));
            }
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}