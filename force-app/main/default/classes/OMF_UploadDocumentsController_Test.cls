/*
@Author         :   Khushmeet Kaur
@Create Date    :   05-01-2023
@Purpose        :   Test class code coverage for OMF_UploadDocumentsController
@JIRA Tickets   :   SFP-17156
*/
/*
* @Last Modified By : Aman Kumar 
* @Last Modified On : 06-05-2024
* @Modification description: SFP-Number - SFP-38048
*/
@IsTest
public class OMF_UploadDocumentsController_Test {
    @testSetup 
    static void setupTestData() {
        TestDataFactory.createKYCDocuments();
     } 
    /*------------------------------------------------------------*
    @description: Test method 
    @parameters: NULL
    @returns: NULL
    --------------------------------------------------------------*/
    @isTest static void createKYCRequiredDocumentTest(){
        
        Test.startTest();
        
        OMF_ManagedFund__c[] listManagedFund = [SELECT Id,Fund__c FROM OMF_ManagedFund__c WHERE BulkOnboarding__r.ShortName__c = 'KYC Bulk Record'];
        
        List<Id>listManagedFundId = new list<Id>();
        for(OMF_ManagedFund__c objManagedFund : listManagedFund){
            listManagedFundId.add(objManagedFund.Id);
        }
       // Id kycDocumentRecordType = Schema.SObjectType.OMF_ManagedFundRules__c.getRecordTypeInfosByName().get('KYC Documents').getRecordTypeId();
        
        OMF_UploadDocumentsController.createKYCRequiredDocument(listManagedFund[0].Id);
        
        KYC_Required_Documents__c[] listKycRequiredDocument = [SELECT Id,Name FROM KYC_Required_Documents__c];
        
        List<Id>listKycRequiredDocumentId = new list<Id>();
        for(KYC_Required_Documents__c objkycRequiredDocument: listKycRequiredDocument){
            listKycRequiredDocumentId.add(objkycRequiredDocument.Id);
        }

        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        
        OMF_UploadDocumentsController.getKYCDocuments(listManagedFundId,false,false);
        OMF_UploadDocumentsController.getKYCDocuments(listManagedFundId,true,false);
        OMF_UploadDocumentsController.getKYCDocuments(listManagedFundId,false,true);
        Boolean createContentDocumentLink = OMF_UploadDocumentsController.createContentDocumentLink(listKycRequiredDocumentId,documents[0].Id);
        OMF_UploadDocumentsController.inititateKYC(listManagedFundId);
        OMF_UploadDocumentsController.deleteContentDocumentLink(listKycRequiredDocumentId[1]);
        OMF_UploadDocumentsController.deleteDocument(documents[0].Id);
        OMF_UploadDocumentsController.getDocumentSizeError(documents[0].Id);
        
        assert.areEqual(TRUE, createContentDocumentLink, 'Passed');
        Test.stopTest();
    }
}