/**
* @description  Test class for OMF_API_KYCRejection
* @author Raja
* @company Absyz
* @Apex Class OMF_API_KYCRejection and SRV_OMF_KYCStatusUpdate
* @CreatedDate March 2024
*/
@isTest
private class OMF_API_KYCRejection_TEST {
    @isTest static void testUpdateStatusOfManagedFund() {
        // Test data setup
        String strAssetManagerId = TestDataFactory.createTestAssetManagerRecord();
        String strFundRecordId = TestDataFactory.createTestFundRecord();
        String strManagedFundId = TestDataFactory.createTestManagedFundRecord(strAssetManagerId, strFundRecordId);
        // Prepare the request body for the REST call
        Map<String, Object> requestBody = new Map<String, Object>{
            'SalesforceId' => strFundRecordId,
                'RejectionReason' => 'Incomplete KYC information',
                'RejectionDetails' => 'Missing address information'
                };
                    Test.startTest();
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/kyc-reject';
        request.httpMethod = 'POST';
        requestBody.put('SalesforceId', '');
        requestBody.put('RejectionReason', '');
        requestBody.put('RejectionDetails', '');
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        OMF_API_KYCRejection.updateStatusOfManagedFund();
        Test.stopTest();
        
        // Verify results
        OMF_ManagedFund__c managedFund = [SELECT Id, RejectionReason__c, RejectionDetails__c FROM OMF_ManagedFund__c WHERE Id = :strManagedFundId];
        Assert.areEqual(null, managedFund.RejectionDetails__c, 'Expected RejectionDetails to be updated');
    }
    
    @isTest static void testUpdateStatusOfManagedFundFundDoesnotExist() {
        // Test data setup
        TestDataFactory.createTestAssetManagerRecord(); 
        String strFundRecordId = TestDataFactory.createTestFundRecord();
        // Prepare the request body for the REST call
        Map<String, Object> requestBody = new Map<String, Object>{
            'SalesforceId' => strFundRecordId,
                'RejectionReason' => 'Incomplete KYC information',
                'RejectionDetails' => 'Missing address information'
                };
                    
                    Test.startTest();
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/kyc-reject';
        request.httpMethod = 'POST';
        requestBody.put('SalesforceId', '001000000000000A90');
        requestBody.put('RejectionReason', 'Incomplete KYC information');
        requestBody.put('RejectionDetails', 'Missing address information');
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        OMF_API_KYCRejection.updateStatusOfManagedFund();
        Test.stopTest();
        // Verify results
        Assert.areEqual(400, res.statusCode, 'Expected status code to be 400');
    }
    
    @isTest static void testUpdateStatusOfManagedFundIdWrong() {
        // Test data setup
        TestDataFactory.createTestAssetManagerRecord();
        String strFundRecordId = TestDataFactory.createTestFundRecord();
        
        // Prepare the request body for the REST call
        Map<String, Object> requestBody = new Map<String, Object>{
            'SalesforceId' => strFundRecordId,
                'RejectionReason' => 'Incomplete KYC information',
                'RejectionDetails' => 'Missing address information'
                };
                    
                    Test.startTest();
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/kyc-reject';
        request.httpMethod = 'POST';
        requestBody.put('SalesforceId', strFundRecordId);
        requestBody.put('Notes', '');
        requestBody.put('Error', 'Inavlid');
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        OMF_API_KYCRejection.updateStatusOfManagedFund();
        Test.stopTest();
        // Verify that the response status code is 400 Bad Request
        Assert.areEqual(400, RestContext.response.statusCode, 'Response status code should be 400');
    }
    @isTest static void testUpdateStatusOfManagedFundId() {
        // Test data setup
        String strAssetManagerId = TestDataFactory.createTestAssetManagerRecord();
        String strFundRecordId = TestDataFactory.createTestFundRecord();
        String strManagedFundId = TestDataFactory.createTestManagedFundRecord(strAssetManagerId, strFundRecordId);
        
        // Prepare the request body for the REST call
        Map<String, Object> requestBody = new Map<String, Object>{
            'SalesforceId' => strFundRecordId,
                'RejectionReason' => 'Incomplete KYC information',
                'RejectionDetails' => 'Missing address information'
                };
         Test.startTest();
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/kyc-reject';
        request.httpMethod = 'POST';
        requestBody.put('SalesforceId', strFundRecordId);
        requestBody.put('Notes', '');
        requestBody.put('FAILURE', 'No Records Found for Managed Fund');
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        OMF_API_KYCRejection.updateStatusOfManagedFund();
        Test.stopTest();
        List<OMF_ManagedFund__c> managedFunds = [
            SELECT Id, Onboarding_Status__c
            FROM OMF_ManagedFund__c
            WHERE Id = :strManagedFundId
        ];
        Assert.areEqual('Document Upload', managedFunds[0].Onboarding_Status__c, 'Onboarding status should still be Document Upload');
        
    }
    @isTest static void testMorethanOneManagedFundRecord() {
        // Test data setup
        String strAssetManagerId = TestDataFactory.createTestAssetManagerRecord();
        String strFundRecordId = TestDataFactory.createTestFundRecord();
        String strManagedFundId = TestDataFactory.createTestManagedFundRecord(strAssetManagerId, strFundRecordId);
        TestDataFactory.createTestManagedFundRecord(strAssetManagerId, strFundRecordId);
        // Prepare the request body for the REST call
        Map<String, Object> requestBody = new Map<String, Object>{
            'SalesforceId' => strFundRecordId,
                'RejectionReason' => 'Incomplete KYC information',
                'RejectionDetails' => 'Missing address information'
                };
         Test.startTest();
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/kyc-reject';
        request.httpMethod = 'POST';
        requestBody.put('SalesforceId', strFundRecordId);
        requestBody.put('Notes', '');
        requestBody.put('FAILURE', 'No Records Found for Managed Fund');
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        OMF_API_KYCRejection.updateStatusOfManagedFund();
        Test.stopTest();
        List<OMF_ManagedFund__c> managedFunds = [
            SELECT Id, Onboarding_Status__c
            FROM OMF_ManagedFund__c
            WHERE Id = :strManagedFundId
        ];
        Assert.areEqual('KYC', managedFunds[0].Onboarding_Status__c, 'Onboarding status should still be KYC');
        
    }
  }