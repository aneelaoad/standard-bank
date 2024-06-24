@isTest
public class ACM_UploadIcon_Test {
    public testmethod static void MethodA(){
        List<ACM_UploadIcon.uploadIconToAnypointExchangeAssetRequest> requestList = new List<ACM_UploadIcon.uploadIconToAnypointExchangeAssetRequest>();
        ACM_UploadIcon.uploadIconToAnypointExchangeAssetRequest requestObj = new ACM_UploadIcon.uploadIconToAnypointExchangeAssetRequest();
        requestObj.staticResourceName = 'Add_Button';
        requestObj.assetId = 'Test';
        requestObj.anypointGroupId = 'groupId';
        requestList.add(requestObj);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        ACM_UploadIcon.uploadIconToAnypointExchangeAsset(requestList);
        Test.stopTest();
        
    }
    // Inner class to generate mock HTTP response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        
        
        public HttpResponse respond(HttpRequest req) {
            
            // Create mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            return res;
        }
    }
}