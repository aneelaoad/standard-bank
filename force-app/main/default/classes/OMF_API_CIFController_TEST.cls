/**
* @description  Test class for OMF_API_CIFController
* @author Raja Kumar(raja.kumar@standardbank.co.za)
* @company Absyz
* @Apex Class OMF_API_CIFController
* @CreatedDate Jan 2024
*/
@isTest(SeeAllData=false)
private class OMF_API_CIFController_TEST{
    public static String bodyAsString=null;
    public static Integer code=0;
    // Define a mock class that implements the HTTPCalloutMock interface
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
            response.setStatusCode(code);
            return response; 
        }
    }        
    @TestSetup
    static void setupTestData(){
        // Set up test data
        Id amRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        Account assetManager = new Account( RecordTypeId = amRecordTypeId, Name='Test Manager', CIF__c ='34561' );
        Id fundRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fund').getRecordTypeId();
        Account fund = new Account(RecordTypeId = fundRecordTypeId, Name='Test Fund', CIF__c = '12341' );
        insert assetManager;
        insert fund;
        OMF_ManagedFund__c managedFund = new OMF_ManagedFund__c(Fund__c=fund.Id, AssetManager__c = assetManager.Id,ShortName__c = 'Test',Onboarding_Status__c='KYC',CreatedById=UserInfo.getUserId());        
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
    
    //success use case
    @isTest
    static void testsendShortNameToCIFSuccess() {
        OMF_API_CIFController.DTO_Response dtoResponse=new OMF_API_CIFController.DTO_Response();
        List<OMF_ManagedFund__c> omfRecord=[select id,Fund__r.CIF__c,AssetManager__r.CIF__c,ShortName__c from OMF_ManagedFund__c limit 1];
        dtoResponse.parentCifId=omfRecord[0].Fund__r.CIF__c;
        dtoResponse.childCifId=omfRecord[0].AssetManager__r.CIF__c;
        dtoResponse.relationshipTypeId='OBO';
        dtoResponse.relationshipShortName=omfRecord[0].ShortName__c;
        dtoResponse.requestStatusCode='In Progress';
        bodyAsString=dtoResponse.serialize();
        code=200;
        OMF_API_CIFController.ManagedFundDataFromFlow objManagedFundDataFromFlow=new OMF_API_CIFController.ManagedFundDataFromFlow();
        objManagedFundDataFromFlow.mangedFundId=omfRecord[0].Id;
        objManagedFundDataFromFlow.updatedShortName=null;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        OMF_API_CIFController.sendShortNameToCIF(new List<OMF_API_CIFController.ManagedFundDataFromFlow>{objManagedFundDataFromFlow});
        Test.stopTest();
        OMF_ManagedFund__c omfRecordUpdated=[select id,Onboarding_Status__c from OMF_ManagedFund__c where id=:omfRecord[0].Id limit 1];
        Assert.areEqual(true,omfRecordUpdated.Onboarding_Status__c=='Global CIF','status should be updated to Global CIF');
        
    }
    
    @isTest
    static void testShortNameResponseCodeError() {
        OMF_API_CIFController.DTO_Response dtoResponse=new OMF_API_CIFController.DTO_Response();
        List<OMF_ManagedFund__c> omfRecord=[select id,Fund__r.CIF__c,AssetManager__r.CIF__c,ShortName__c from OMF_ManagedFund__c limit 1];
        dtoResponse.parentCifId=omfRecord[0].Fund__r.CIF__c;
        dtoResponse.childCifId=omfRecord[0].AssetManager__r.CIF__c;
        dtoResponse.relationshipTypeId='OBO';
        dtoResponse.relationshipShortName=omfRecord[0].ShortName__c;
        dtoResponse.requestStatusCode='Relationship Short Name exists';
        bodyAsString=dtoResponse.serialize();
        code=400;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        OMF_API_CIFController.ManagedFundDataFromFlow objManagedFundDataFromFlow=new OMF_API_CIFController.ManagedFundDataFromFlow();
        objManagedFundDataFromFlow.mangedFundId=omfRecord[0].Id;
        objManagedFundDataFromFlow.updatedShortName=null;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        OMF_API_CIFController.sendShortNameToCIF(new List<OMF_API_CIFController.ManagedFundDataFromFlow>{objManagedFundDataFromFlow});
        Test.stopTest();
        OMF_ManagedFund__c omfRecordUpdated=[select id,Onboarding_Status__c,RejectionReason__c from OMF_ManagedFund__c where id=:omfRecord[0].Id limit 1];
        Assert.areEqual(true,omfRecordUpdated.Onboarding_Status__c=='Fund Details','status should be updated to Fund Details');
        Assert.areEqual(true,omfRecordUpdated.RejectionReason__c=='Relationship Short Name exists','RejectionReason__c should be updated to Relationship Short Name exists');
    }
    
    @isTest
    static void testOtherThanShortNameResponseCodeError() {
        OMF_API_CIFController.DTO_Response dtoResponse=new OMF_API_CIFController.DTO_Response();
        List<OMF_ManagedFund__c> omfRecord=[select id,Fund__r.CIF__c,AssetManager__r.CIF__c,ShortName__c from OMF_ManagedFund__c limit 1];
        dtoResponse.parentCifId=omfRecord[0].Fund__r.CIF__c;
        dtoResponse.childCifId=omfRecord[0].AssetManager__r.CIF__c;
        dtoResponse.relationshipTypeId='OBO';
        dtoResponse.relationshipShortName=omfRecord[0].ShortName__c;
        dtoResponse.requestStatusCode='Managed Fund KYC outstanding';
        bodyAsString=dtoResponse.serialize();
        code=400;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        OMF_API_CIFController.ManagedFundDataFromFlow objManagedFundDataFromFlow=new OMF_API_CIFController.ManagedFundDataFromFlow();
        objManagedFundDataFromFlow.mangedFundId=omfRecord[0].Id;
        objManagedFundDataFromFlow.updatedShortName='changed';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        OMF_API_CIFController.sendShortNameToCIF(new List<OMF_API_CIFController.ManagedFundDataFromFlow>{objManagedFundDataFromFlow});
        Test.stopTest();
        OMF_ManagedFund__c omfRecordUpdated=[select id,Onboarding_Status__c,RejectionReason__c from OMF_ManagedFund__c where id=:omfRecord[0].Id limit 1];
        Assert.areEqual(true,omfRecordUpdated.Onboarding_Status__c=='Global CIF','status should be updated to Global CIF');
        Assert.areEqual(true,omfRecordUpdated.RejectionReason__c=='Managed Fund KYC outstanding','RejectionReason__c should be updated to Managed Fund KYC outstanding');
    }
    
    // Inner class to simulate a callout exception
    private class CalloutExceptionMock implements HttpCalloutMock {
        /**
		* @description function to mock the response
		* @param req 
		* @return exception
		*/
        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('Simulated callout exception');
        }
    }
    @isTest
    static void testCalloutException() {
        boolean hasException=false;
        List<OMF_ManagedFund__c> omfRecord=[select id,Fund__r.CIF__c,AssetManager__r.CIF__c,ShortName__c from OMF_ManagedFund__c limit 1];
        Test.setMock(HttpCalloutMock.class, new CalloutExceptionMock());
        try{
            Test.startTest();
            OMF_API_CIFController obj=new OMF_API_CIFController(omfRecord[0].Id);
            obj.sendRequest();
            Test.stopTest();
        }
        catch(Exception ex){
            hasException=true;
        }
        Assert.areEqual(true,hasException,'received callout exception');
    }
    
    @isTest
    static void testcallPlatformEventForUpdateCIF(){
        OMF_ManagedFund__c omfRecord=[select id,Onboarding_Status__c from OMF_ManagedFund__c limit 1];
        OMF_ManagedFundRecordUpdate__e asyncDmlForOMF = new OMF_ManagedFundRecordUpdate__e();
        asyncDmlForOMF.ManagedFundRecordId__c = omfRecord.Id;
        asyncDmlForOMF.NewOnboardingStatus__c = 'CIF Submission Failed';
        Test.startTest();
        Database.SaveResult result=EventBus.publish(asyncDmlForOMF);
        Test.stopTest();
        OMF_ManagedFund__c omfRecordUpdated=[select id,Onboarding_Status__c from OMF_ManagedFund__c where id=:omfRecord.Id limit 1];
        Assert.areEqual(true,result.isSuccess(),'suucess event');
        Assert.areEqual(true,omfRecordUpdated.Onboarding_Status__c=='CIF Submission Failed','status should be updated to CIF Submission Failed');
    }
}