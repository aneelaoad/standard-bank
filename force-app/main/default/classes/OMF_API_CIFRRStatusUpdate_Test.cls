/**
* @description  Test class for OMF__API_CIFRRStatusUpdate
* @author Raja
* @company Absyz
* @Apex Class OMF_API_CIFRRStatusUpdate
* @CreatedDate Jan 2024
*/
@isTest(SeeAllData=false)
private class OMF_API_CIFRRStatusUpdate_Test {
    @TestSetup
    static void setupTestData(){
        // Set up test data
        Id amRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        Account assetManager = new Account( RecordTypeId = amRecordTypeId, Name='Test Manager', CIF__c ='34561' );
        Id fundRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fund').getRecordTypeId();
        Account fund = new Account(RecordTypeId = fundRecordTypeId, Name='Test Fund', CIF__c = '12341' );
        insert assetManager;
        insert fund;
        OMF_ManagedFund__c managedFund = new OMF_ManagedFund__c(Fund__c=fund.Id, AssetManager__c = assetManager.Id,ShortName__c = 'Test',CreatedById=UserInfo.getUserId());        
        insert managedFund;
        KYC_Status__c objKYCStatus = new KYC_Status__c();
        objKYCStatus.ManagedFundID__c = managedFund.ID;
        objKYCStatus.Client__c = fund.Id;
        insert objKYCStatus;
        
        KYC_Required_Documents__c kycRequiredDocument = new KYC_Required_Documents__c(
            KYC_Review_Status__c = objKYCStatus.Id,
            Master_Agreement_Name__c = 'Test Master Agreement'
        );
        insert kycRequiredDocument;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.LinkedEntityId = kycRequiredDocument.Id;
        insert cdl;
        
       
        Id kycRecordTypeId = Schema.SObjectType.OMF_ManagedFundRules__c.getRecordTypeInfosByName().get('KYC Documents').getRecordTypeId();
        OMF_ManagedFundRules__c rule = new OMF_ManagedFundRules__c(
            RecordTypeId = kycRecordTypeId,
            DocumentRequired__c = 'Investment Management Agreement'
        );
        insert rule;
    }
    
    ///test rejected
    @isTest static void testAuthRejected() {
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/cif-rr-status-update';
        request.httpMethod = 'PATCH';
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('parentCIFId', '12341');
        requestBody.put('childCIFId', '34561');
        requestBody.put('relationshipTypeId', 'OBO');
        requestBody.put('requestStatusCode', 'Auth Rejected');
        requestBody.put('authUser', 'Raja Kumar');
        requestBody.put('relationshipCIFId', '');
        requestBody.put('relationshipOSDId', '');
        requestBody.put('reltionshipShortName', 'OMF Project Team Fd');
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        OMF_API_CIFRRStatusUpdate.updateStatusOfManagedFund();
        Test.stopTest();
        String jsonResponse=RestContext.response.responseBody.toString();
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        // Verify the results
        List<OMF_ManagedFund__c> updatedRecords = [SELECT Id, Onboarding_Status__c, OSD_ID__c, 
                                                           GlobalCIFNumber__c,RejectionReason__c, AssetManager__r.CIF__c,
                                                           Fund__r.CIF__c FROM OMF_ManagedFund__c
                                                           WHERE Fund__r.CIF__c ='12341'
                                                           AND AssetManager__r.CIF__c ='34561'];
        Assert.areEqual(1, updatedRecords.size(), 'Expected one updated record');
        Assert.areEqual('Auth Rejected', updatedRecords[0].RejectionReason__c,'Expected Value is Auth Rejected');
        Assert.areEqual('Global CIF', updatedRecords[0].Onboarding_Status__c,'Onboarding status should be Global CIF');
        Assert.areEqual(True,responseData.get('SUCCESS')=='Record Updated','success message for record updated');
    }
    //test accepted
    @isTest static void testRelationshipRecordCreated() {
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/cif-rr-status-update';
        request.httpMethod = 'PATCH';
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('parentCIFId', '12341');
        requestBody.put('childCIFId', '34561');
        requestBody.put('relationshipTypeId', 'OBO');
        requestBody.put('requestStatusCode', 'Relationship Record Created');
        requestBody.put('authUser', 'Raja Kumar');
        requestBody.put('relationshipCIFId', '123098');
        requestBody.put('relationshipOSDId', '123001');
        requestBody.put('reltionshipShortName', 'OMF Project Team Fd');
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        OMF_API_CIFRRStatusUpdate.updateStatusOfManagedFund();
        Test.stopTest();
        String jsonResponse=RestContext.response.responseBody.toString();
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        // Verify the results
        List<OMF_ManagedFund__c> updatedRecords = [SELECT Id, Onboarding_Status__c, OSD_ID__c, 
                                                           GlobalCIFNumber__c,RejectionReason__c, AssetManager__r.CIF__c,
                                                           Fund__r.CIF__c FROM OMF_ManagedFund__c
                                                           WHERE Fund__r.CIF__c ='12341'
                                                           AND AssetManager__r.CIF__c ='34561'];
        
        Assert.areEqual(1, updatedRecords.size(), 'Expected one updated record');
        Assert.areEqual('123098', updatedRecords[0].GlobalCIFNumber__c,'GlobalCIFNumber__c  should be 123098');
        Assert.areEqual('Legal+Credit', updatedRecords[0].Onboarding_Status__c,'Onboarding status should be "Legal+Credit"');
        Assert.areEqual(True,responseData.get('SUCCESS')=='Record Updated','success message for record updated');
    }
    
    //test accepted but bad request
    @isTest static void testRelationshipRecordCreatedWithNoRR() {
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/cif-rr-status-update';
        request.httpMethod = 'PATCH';
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('parentCIFId', '12341');
        requestBody.put('childCIFId', '34561');
        requestBody.put('relationshipTypeId', 'OBO');
        requestBody.put('requestStatusCode', 'Relationship Record Created');
        requestBody.put('authUser', 'Raja Kumar');
        requestBody.put('relationshipCIFId', '1');
        requestBody.put('relationshipOSDId', '');
        requestBody.put('reltionshipShortName', 'OMF Project Team Fd');
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        OMF_API_CIFRRStatusUpdate.updateStatusOfManagedFund();
        Test.stopTest();
        String jsonResponse=RestContext.response.responseBody.toString();
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        // Verify the results
        Assert.areEqual(True,responseData.get('ERROR')=='BAD REQUEST','error message for bad request');
        Assert.areEqual(400,RestContext.response.statusCode,'error message code for bad request');
      
    }
    
    //test bad request, other status then given format
    @isTest static void testBadRequest() {
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/cif-rr-status-update';
        request.httpMethod = 'PATCH';
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('parentCIFId', '12341');
        requestBody.put('childCIFId', '34561');
        requestBody.put('relationshipTypeId', 'OBO');
        requestBody.put('requestStatusCode', 'Something else');
        requestBody.put('authUser', 'Raja Kumar');
        requestBody.put('relationshipCIFId', '1');
        requestBody.put('relationshipOSDId', '');
        requestBody.put('reltionshipShortName', 'OMF Project Team Fd');
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        OMF_API_CIFRRStatusUpdate.updateStatusOfManagedFund();
        Test.stopTest();
        String jsonResponse=RestContext.response.responseBody.toString();
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        // Verify the results
        Assert.areEqual(True,responseData.get('ERROR')=='BAD REQUEST','error message for bad request');
        Assert.areEqual(400,RestContext.response.statusCode,'error message code for bad request');
      
    }
    //testing record not found.
    @isTest static void testRecordNotFoundError() {
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/omf/cif-rr-status-update';
        request.httpMethod = 'PATCH';
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('parentCIFId', '123141');
        requestBody.put('childCIFId', '34325261');
        requestBody.put('relationshipTypeId', 'OBO');
        requestBody.put('requestStatusCode', 'Relationship Record Created');
        requestBody.put('authUser', 'Raja Kumar');
        requestBody.put('relationshipCIFId', '11212');
        requestBody.put('relationshipOSDId', '1231');
        requestBody.put('reltionshipShortName', 'OMF Project Team Fd');
        String serializedBody = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(serializedBody);
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        OMF_API_CIFRRStatusUpdate.updateStatusOfManagedFund();
        Test.stopTest();
        // Verify the results
         String jsonResponse=RestContext.response.responseBody.toString();
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        // Verify the results
        Assert.areEqual(True,responseData.get('ERROR')=='Managed Fund record does not exist','error message for record not found');
        Assert.areEqual(400,RestContext.response.statusCode,'error message code for bad request');
    }
}