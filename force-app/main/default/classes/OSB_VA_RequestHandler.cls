/*
new class for handling bot requests
*/

public with sharing class OSB_VA_RequestHandler {
	private static final Http HTTP_SENDER = new Http();

	public static HttpResponse generateSwiftResponse(String uetr)
    {
        HttpRequest request = OSB_VA_RequestFactory.createSwiftGPIPaymentTrackingRequest(uetr);
        return HTTP_SENDER.send(request);
    }
    
    public static HttpResponse generateiTrackPayResponse(String query, String type)
    {
        HttpRequest request = OSB_VA_RequestFactory.createiTrackPaySearchRequest(query, type);
        return HTTP_SENDER.send(request);
    }
}