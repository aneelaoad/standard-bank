/**
 * Class to generate mock response for callout exception
 * 
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date May 2020
 */
@isTest
public class SingleRequestMock_CalloutExp implements HttpCalloutMock {
    protected String message;
    
    public SingleRequestMock_CalloutExp(String message) {
        this.message = message;
    }
    
     public HTTPResponse respond(HTTPRequest req) {
        CalloutException e = new CalloutException(message);
        throw e;
    }
}