/*------------------------------------------------------------
Author: Khushmeet Kaur
Company: Absyz
Description: Test class
Apex Class: OMF_SendEmailWtihAttactments
------------------------------------------------------------*/
@istest
public class OMF_SendEmailWithAttactments_TEST {
    @TestSetup
    static void setupTestData(){
        String assetManagerId = TestDataFactory.createTestAssetManagerRecord();
        String fundId = TestDataFactory.createTestFundRecord();
        String managedFundID = TestDataFactory.createTestManagedFundRecord(assetManagerId,fundId);
        
        //Create kyc status record
        KYC_Status__c objKYCStatus = new KYC_Status__c();
        objKYCStatus.ManagedFundID__c = managedFundID;
        objKYCStatus.Client__c = fundId;
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
        cdl.Visibility = 'AllUsers';
        cdl.LinkedEntityId = kycRequiredDocument.Id;
        insert cdl;
    }
    
    @isTest static void sendEmailWithDocuments() {
        KYC_Status__c objKYCStatus = [SELECT Id,Name FROM KYC_Status__c WHERE ManagedFundID__r.ShortName__c = 'Test Managed Fund' LIMIT 1];
        
        OMF_SendEmailWithAttactments.EmailData emailData = new OMF_SendEmailWithAttactments.EmailData();
        emailData.strToAddress = 'test@example.com';
        emailData.strSubject = 'Test email';
        emailData.strHtmlBody = '<p>Test email body</p>';
        emailData.strKYCRecordId = objKYCStatus.Id;
        
        Test.startTest();
        OMF_SendEmailWithAttactments.sendEmailWithDocuments(new List<OMF_SendEmailWithAttactments.EmailData>{emailData});
        assert.areEqual(1, Limits.getEmailInvocations(), 'Emails should be sent');
        Test.stopTest();
    }
    
    @isTest static void sendKYCDocuments() {
        KYC_Status__c objKYCStatus = [SELECT Id,Name,ManagedFundID__c FROM KYC_Status__c WHERE ManagedFundID__r.ShortName__c = 'Test Managed Fund' LIMIT 1];
        KYC_Required_Documents__c[] listKYCRequiredDocument = [SELECT Id,Name,KYC_Review_Status__c FROM KYC_Required_Documents__c WHERE KYC_Review_Status__c =: objKYCStatus.Id];
        set<id>setCreditDocumentId = new set<id>();
        list<Id>listContentDocumentId = new list<Id>();
        set<Id>setContentDocumentId = new set<Id>();
        list<Id>listKycStatusRecordId = new list<Id>();
        set<Id>setKycStatusRecordId = new set<Id>();
        String contentDocumentId;
        
        for(KYC_Required_Documents__c objKYCRequiredDocument : listKYCRequiredDocument){
            setCreditDocumentId.add(objKYCRequiredDocument.Id);
            listKycStatusRecordId.add(objKYCRequiredDocument.KYC_Review_Status__c);
            setKycStatusRecordId.add(objKYCRequiredDocument.KYC_Review_Status__c);
        }
        for(ContentDocumentLink objContentDocumentLink : [SELECT 
                                                          ContentDocumentID, 
                                                          LinkedEntity.type, 
                                                          LinkedEntityId 
                                                          FROM
                                                          ContentDocumentLink 
                                                          WHERE 
                                                          LinkedEntityId IN: setCreditDocumentId ]){
                                                              listContentDocumentId.add(objContentDocumentLink.ContentDocumentId);
                                                              setContentDocumentId.add(objContentDocumentLink.ContentDocumentId);
                                                              contentDocumentId = objContentDocumentLink.ContentDocumentId;
                                                          }
        
        if(listContentDocumentId.size()>0){
            OMF_SendKYCDocuments.sendEmailWithAttachments(listContentDocumentId,objKYCStatus.ManagedFundID__c,'KYC');
             OMF_SendKYCDocuments.sendEmailWithAttachments(listContentDocumentId,objKYCStatus.ManagedFundID__c,'Credit');
            SEL_ContentDocumentLink.newInstance().selectByContentDocumentId(setContentDocumentId);
            SEL_ContentDocumentLink.newInstance().selectRecordByContentDocumentId(contentDocumentId);
            SEL_ContentDocumentLink.newInstance().selectByListLinkEntityId(listKycStatusRecordId);
            SEL_ContentDocumentLink.newInstance().selectByStringLinkEntityId(listKYCRequiredDocument[0].Id);
            SEL_ContentDocumentLink.newInstance().selectByLinkedEntityId(setKycStatusRecordId);
            new SEL_KYCStatuses().selectById(setKycStatusRecordId);
            assert.areEqual(2, Limits.getEmailInvocations(), 'Email should be sent twice.');
        }
    }
}