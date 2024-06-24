@isTest
public class CMN_API_RestBaseOutbound_Test {

    @isTest
    static void testSetHeaders() {
        CMN_API_RestBaseOutbound outbound = new CMN_API_RestBaseOutbound();
        outbound.setHeaders();
        
    }

    @isTest
    static void testHasArrayResponse() {
        CMN_API_RestBaseOutbound outbound = new CMN_API_RestBaseOutbound();
        Boolean hasArray = outbound.hasArrayResponse();
        System.assertEquals(false, hasArray);
    }

    @isTest
    static void testGetResponseBody() {
        CMN_API_RestBaseOutbound outbound = new CMN_API_RestBaseOutbound();
        outbound.getResponseBody();
        System.assertNotEquals(null, outbound.getResponseBody());
    }
    
    @isTest
    static void testGetBody() {
        CMN_API_RestBaseOutbound outbound = new CMN_API_RestBaseOutbound();
        String body = outbound.getBody();
        System.assertNotEquals(null, body);
    }
}