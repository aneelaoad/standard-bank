@isTest
public class ACM_ExchangeAssets_Test {
    public static HttpRequest lastRequest;
    public static HttpResponse lastResponse;
    public static testmethod void publishAssetToAnypointExchange(){
        // Create test data
        List<ACM_ExchangeAssets.publishAssetToAnypointExchangeRequest> assetList = new List<ACM_ExchangeAssets.publishAssetToAnypointExchangeRequest>();
        
        ACM_ExchangeAssets.publishAssetToAnypointExchangeRequest asset = new ACM_ExchangeAssets.publishAssetToAnypointExchangeRequest();
        asset.fileBody = 'Test File Body';
        asset.fileName = 'TestFile.txt';
        asset.assetName = 'Test Asset';
        asset.description = 'Test Description';
        asset.assetId = 'Asset123';
        asset.assetType = 'Type1';
        asset.fileUploadType = 'File';
        asset.contentType = 'text/plain';
        asset.apiVersion = '1.0';
        asset.apiVersionGroup = 'Group1';
        asset.requestEndpoint = 'Endpoint1';
        asset.authToken = 'Token123';
        asset.anypointOrgId = 'Org123';
        asset.anypointGroupId = 'Group123';
        asset.contactName = 'John Doe';
        asset.contactEmail = 'john.doe@example.com';
        asset.categories = new List<String>{'Category1=Value1', 'Category2=Value2'};
            asset.customFields = new List<String>{'Field1=Value1', 'Field2=Value2'};
                asset.keywords = 'Keyword1,Keyword2';
        asset.tags = 'Tag1,Tag2';
        asset.status = 'Active';
        
        assetList.add(asset);
        
        // Set up mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the method under test
        Test.startTest();
        ACM_ExchangeAssets.publishAssetToAnypointExchange(assetList);
        Test.stopTest();
        
        // Verify the HTTP request
        HttpRequest req = lastRequest;
        Assert.areEqual('POST', req.getMethod());
         Assert.areEqual('callout:Anypoint/exchange/api/v2/organizations/Org123/assets/Group123/Asset123/1.0', req.getEndpoint());
         Assert.areEqual('multipart/form-data; charset="UTF-8"; boundary=------------------------------741e90d31eff', req.getHeader('Content-Type'));
         Assert.areEqual('true', req.getHeader('x-sync-publication'));
        
        // Verify the HTTP response (mocked)
        HttpResponse res = lastResponse;
         Assert.areEqual(201, res.getStatusCode());
        
        // Verify any additional assertions as needed
    }
    
    // Inner class to generate mock HTTP response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        
        
        public HttpResponse respond(HttpRequest req) {
            lastRequest = req;
            
            // Create mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            
            lastResponse = res;
            return res;
        }
    }
}