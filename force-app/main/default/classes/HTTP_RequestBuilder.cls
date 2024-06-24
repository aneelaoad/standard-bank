/*************************************************************************
    @ Author        : Jakub Oracki
    @ Date          : Feb 2017
    @ Description   : Generic class to build HTTP requests
    @ Enhancement   : US-1189
 *************************************************************************/

public virtual class HTTP_RequestBuilder {

	public static final String METHOD_POST = 'POST';
    public static final String METHOD_GET = 'GET';
    public static final String METHOD_PUT = 'PUT';

	protected String method;
	protected String endpoint;
	protected String body;

    public HTTP_RequestBuilder(String method, String endpoint, String body) {
    	this.method = method;
    	this.endpoint = endpoint;
        this.body = body;
  
    }

    public HttpRequest getHttpRequest() {

    	HttpRequest req = new HttpRequest();
    	req.setEndpoint(endpoint);
        req.setMethod(method);
               
        if(body != null) {
            req.setBody(body);
        }
        
        req.setTimeout(60000);
        
        return req;
    }

}