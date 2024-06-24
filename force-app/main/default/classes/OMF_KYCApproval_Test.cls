/**
* @description  Test class for OMF_KYCApproval
* @author Khushmeet
* @company Absyz
* @Aoex Class OMF_KYCApproval
* @CreatedDate Nov 2022
*/
@isTest
private class OMF_KYCApproval_Test {
    
    public static String bodyAsString=null;
    public static Integer code=0;
    // Define a mock class that implements the HTTPCalloutMock interface. This is done as after recieving the approval a callout will be made to CIF system automatically
    private class MockHttpResponse implements HttpCalloutMock {
        /**
		* @description function to mock the response
		* @param req
		* @return response
		*/
        public HttpResponse respond(HttpRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(bodyAsString);
            response.setStatusCode(200);
            return response; 
        }
    }
    @isTest static void testUpdateStatusOfManagedFund() {
        String strFundRecordId = TestDataFactory.createTestFundRecord();
        String strAssetManagerId = TestDataFactory.createTestAssetManagerRecord();
        Id strManagedFundId =TestDataFactory.createTestManagedFundRecord(strAssetManagerId, strFundRecordId);
        OMF_API_CIFController.DTO_Response dtoResponse=new OMF_API_CIFController.DTO_Response();
        List<OMF_ManagedFund__c> omfRecord=[select id,Fund__r.CIF__c,AssetManager__r.CIF__c,ShortName__c from OMF_ManagedFund__c where id=:strManagedFundId limit 1];
        dtoResponse.parentCifId=omfRecord[0].Fund__r.CIF__c;
        dtoResponse.childCifId=omfRecord[0].AssetManager__r.CIF__c;
        dtoResponse.relationshipTypeId='OBO';
        dtoResponse.relationshipShortName=omfRecord[0].ShortName__c;
        dtoResponse.requestStatusCode='In Progress';
        bodyAsString=dtoResponse.serialize();
        code=200;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/cif-status-update-todelete';
        request.httpMethod = 'POST';
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('SalesforceId', strFundRecordId);
        requestBody.put('CIFID', '9090');
        List<Object> relationships = new List<Object>();
        Map<String, Object> relationshipMap = new Map<String, Object>();
        relationshipMap.put('CifRelationshipID', '123');
        relationshipMap.put('active', true);
        relationships.add(relationshipMap);
        requestBody.put('relationships', relationships);
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        OMF_KYCApproval.updateStatusOfManagedFund();
        Test.stopTest();
        // Verify the results 
        OMF_ManagedFund__c[] updatedRecords = new SEL_OMF_ManagedFunds().selectedByRecordId(strManagedFundId);
        Assert.areEqual(1, updatedRecords.size(), 'Expected one updated record');
        Assert.areEqual('Active', updatedRecords[0].Relationship_Record_State__c,'Relationship record state should be "Active"');
        Assert.areEqual(true, updatedRecords[0].KYC_Approved__c,'KYC approval status should be "true"');
        Assert.areEqual('Global CIF', updatedRecords[0].Onboarding_Status__c,'Onboarding status should be "Global CIF"');
        
    }
    @isTest static void testCIFIDNotExist() {
        String strFundRecordId = TestDataFactory.createTestFundRecord();
        String strAssetManagerId = TestDataFactory.createTestAssetManagerRecord();
        Id strManagedFundId =TestDataFactory.createTestManagedFundRecord(strAssetManagerId, strFundRecordId);
        OMF_API_CIFController.DTO_Response dtoResponse=new OMF_API_CIFController.DTO_Response();
        List<OMF_ManagedFund__c> omfRecord=[select id,Fund__r.CIF__c,AssetManager__r.CIF__c,ShortName__c from OMF_ManagedFund__c where id=:strManagedFundId limit 1];
        dtoResponse.parentCifId=omfRecord[0].Fund__r.CIF__c;
        dtoResponse.childCifId=omfRecord[0].AssetManager__r.CIF__c;
        dtoResponse.relationshipTypeId='OBO';
        dtoResponse.relationshipShortName=omfRecord[0].ShortName__c;
        dtoResponse.requestStatusCode='In Progress';
        bodyAsString=dtoResponse.serialize();
        code=200;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/cif-status-update-todelete';
        request.httpMethod = 'POST';
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('SalesforceId', strFundRecordId);
        requestBody.put('CIFID', '9090');
        List<Object> relationships = new List<Object>();
        Map<String, Object> relationshipMap = new Map<String, Object>();
        relationshipMap.put('CifRelationshipID', '9090');
        relationshipMap.put('active', true);
        relationships.add(relationshipMap);
        requestBody.put('relationships', relationships);
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        OMF_KYCApproval.updateStatusOfManagedFund();
        Test.stopTest();
        // Verify the results
        OMF_ManagedFund__c[] updatedRecords = new SEL_OMF_ManagedFunds().selectedByRecordId(strManagedFundId);
        Assert.areEqual(1, updatedRecords.size(), 'Expected one updated record');
        Assert.areEqual('InActive', updatedRecords[0].Relationship_Record_State__c,'Relationship record state should be "Inactive"');
        
    }
    
    
    @isTest static void testUpdateStatusOfManagedFundFundDoesnotExist() {
        Test.startTest();
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/cif-status-update-todelete';
        request.httpMethod = 'POST';
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('SalesforceId', '');
        requestBody.put('CIFID', '');
        List<Object> relationships = new List<Object>();
        Map<String, Object> relationshipMap = new Map<String, Object>();
        relationshipMap.put('CifRelationshipID', '123');
        relationshipMap.put('active', true);
        relationships.add(relationshipMap);
        requestBody.put('relationships', relationships);
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        OMF_KYCApproval.updateStatusOfManagedFund();
        Test.stopTest(); 
        Assert.areEqual(401, res.statusCode, 'Fund does not exist' );     
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        Assert.areEqual(null, responseBody.get('error'), 'Expected error message to be null but got "' + responseBody.get('error') + '" instead.');
        
    }
    @isTest static void testUpdateStatusOfManagedFundIdDonotExist() {
        // Test data setup
        String strAssetManagerId = TestDataFactory.createTestAssetManagerRecord();
        Test.startTest();
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/cif-status-update-todelete';
        request.httpMethod = 'POST';
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('SalesforceId', strAssetManagerId);
        requestBody.put('CIFID', '900');
        List<Object> relationships = new List<Object>();
        Map<String, Object> relationshipMap = new Map<String, Object>();
        relationshipMap.put('CifRelationshipID', '123');
        relationshipMap.put('active', true);
        relationships.add(relationshipMap);
        requestBody.put('relationships', relationships);
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        OMF_KYCApproval.updateStatusOfManagedFund();
        Test.stopTest();
        // Assert the response status code
        Assert.areEqual(400, res.statusCode,'Fund exist');
    }
    @isTest static void testUpdateStatusOfManagedFundIdWrong() {
        TestDataFactory.createTestAssetManagerRecord();
        
        Test.startTest();
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/cif-status-update-todelete';
        request.httpMethod = 'POST';
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('SalesforceId', '001000000000000A90');
        requestBody.put('CIFID', '900');
        List<Object> relationships = new List<Object>();
        Map<String, Object> relationshipMap = new Map<String, Object>();
        relationshipMap.put('CifRelationshipID', '123');
        relationshipMap.put('active', true);
        relationships.add(relationshipMap);
        requestBody.put('relationships', relationships);
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        OMF_KYCApproval.updateStatusOfManagedFund();
        Test.stopTest();
        
        // Check that the response status code is 400 Bad Request
        Assert.areEqual(400, res.statusCode,'success');
    }
    
    
    @isTest
    static void testExceptionHandler() {
        // Create a mock request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/cif-status-update-todelete';
        request.httpMethod = 'PATCH';
        RestContext.request = request;
        
        // Create a mock response
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        // Simulate an exception in the main class
        Test.startTest();
        OMF_KYCApproval.updateStatusOfManagedFund();
        Test.stopTest();
        
        // Verify the response
        Assert.areEqual(500, response.statusCode, 'Unexpected status code');
        
        
    }
}