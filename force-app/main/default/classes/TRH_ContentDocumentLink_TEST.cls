@isTest
private class TRH_ContentDocumentLink_TEST {
    @testSetup
    private static void setup() {
        Business_Assessment__c bAssessment = new Business_Assessment__c();
        insert bAssessment;
    }

    @isTest
    static void shouldUpdateHasDocumentToTrue() {
        Business_Assessment__c ba = [SELECT Id, HasDocument__c FROM Business_Assessment__c LIMIT 1];

        Blob bBlob = Blob.valueOf('Unit Test');
        ContentVersion cv = new ContentVersion();
        cv.title = 'test file';
        cv.PathOnClient = 'test';
        cv.VersionData = bBlob;
        insert cv;

        ContentVersion contentVer = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        ContentDocumentLink contentDocLink = new ContentDocumentLink();
        contentDocLink.LinkedEntityId = ba.Id;
        contentDocLink.ShareType = 'V';
        contentDocLink.ContentDocumentId = contentVer.ContentDocumentId;

        System.assertEquals(false, ba.HasDocument__c);

        Test.startTest();
        insert contentDocLink;
        Test.stopTest();

        Business_Assessment__c businessAssessment = [SELECT Id, HasDocument__c FROM Business_Assessment__c WHERE Id = :ba.Id];

        System.assertEquals(true, businessAssessment.HasDocument__c);
    }
}