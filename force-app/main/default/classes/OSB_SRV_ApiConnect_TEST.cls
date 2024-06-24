/**
 * Test Class for OSB_SRV_ApiConnect
 * 
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date Feb 2020
 */
@IsTest(IsParallel=true)
private class OSB_SRV_ApiConnect_TEST {
    private static final String TEST_ACCESS_TOKEN = 'dummyaccesstoken';
    private static final String TEST_ORG_ID = '12345';
    private static final String TEST_API_TITLE = 'Test API';
    private static final String TEST_API_ID = '123';

    @IsTest
    static void testGetAPIDetails() {
        String tokenKey = 'access_token';
        String accessToken = 'dummyaccesstoken';
        String idKey = 'id';
        String orgId = '12345';
        String titleKey = 'title';
        String apiTitle = 'Test API';
        String apiId = '123';
        String pathsKey = 'paths';
        String pathsValue = 'value';


        Map<String, String> requestBody = new Map<String, String>{
                tokenKey => accessToken,
                idKey => orgId,
                titleKey => apiTitle,
                pathsKey => pathsValue
        };
        List<Map<String, String>> wrappedRequestBody = new List<Map<String, String>>{requestBody};
        String requestTextBody = JSON.serialize(requestBody);
        String requestWrappedTextBody = JSON.serialize(wrappedRequestBody);

        List<String> responses = new List<String>{requestTextBody, requestWrappedTextBody, requestTextBody};
        Test.setMock(HttpCalloutMock.class, new MockResponseWrapper(responses));
        Test.startTest();
        Map<String, Object> actualResponseMap = OSB_SRV_ApiConnect.newInstance().getAPIDetails(apiId);
        Test.stopTest();
        
        System.assertEquals(apiTitle, actualResponseMap.get(titleKey));
    }

    class MockResponseWrapper implements HttpCalloutMock {
        private Integer responseIndex;
        private List<String> responses;

        public MockResponseWrapper(List<String> responses) {
            responseIndex = 0;
            this.responses = responses;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String response = responses[responseIndex];
            res.setBody(response);
            res.setStatusCode(200);
            responseIndex++;
            return res;
        }
    }
}