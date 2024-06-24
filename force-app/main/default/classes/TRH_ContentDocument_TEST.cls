@isTest
private class TRH_ContentDocument_TEST {
    @testSetup
    private static void setup() {
        Business_Assessment__c bAssessment = new Business_Assessment__c();
        insert bAssessment;
        List<ContentVersion> cVersions = new List<ContentVersion> ();
        for(Integer i = 0; i < 2; i++) {
            Blob bBlob = Blob.valueOf('Unit Test ' + i);
            ContentVersion cv = new ContentVersion();
            cv.title = 'test file ' + i;
            cv.PathOnClient = 'test ' + i;
            cv.VersionData = bBlob;
            cVersions.add(cv);
        }

        insert cVersions;

        Set<Id> ids = new Set<Id>();
        for(Integer k = 0; k < cVersions.size(); k++) {
            ids.add(cVersions[k].Id);
        }

        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :ids];

        List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();
        for(Integer j = 0; j < contentVersions.size(); j++) {
            ContentDocumentLink cd = new ContentDocumentLink();
            cd.LinkedEntityId = bAssessment.Id;
            cd.ShareType = 'V';
            cd.ContentDocumentId = contentVersions[j].ContentDocumentId;
            contentDocLinks.add(cd);
        }

        insert contentDocLinks;
    }

    @isTest
    static void shouldUpdateHasDocumentToFalse() {
        Business_Assessment__c ba = [SELECT Id, HasDocument__c FROM Business_Assessment__c LIMIT 1];
        List<ContentDocumentLink> files = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :ba.Id];
        Set<Id> ids = new Set<Id>();
        for(ContentDocumentLink file : files) {
            ids.add(file.ContentDocumentId);
        }
        List<ContentDocument> docs = [SELECT Id FROM ContentDocument WHERE Id IN :ids];

        System.assertEquals(true, ba.HasDocument__c);

        Test.startTest();
            delete docs;
        Test.stopTest();

        Business_Assessment__c businessAssessment = [SELECT Id, HasDocument__c FROM Business_Assessment__c WHERE Id = :ba.Id];

        System.assertEquals(false, businessAssessment.HasDocument__c);

    }

    @isTest
    static void shouldNotUpdateHasDocumentField() {

        Business_Assessment__c ba = [SELECT Id, HasDocument__c FROM Business_Assessment__c LIMIT 1];
        List<ContentDocumentLink> files = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :ba.Id LIMIT 1];
        List<ContentDocument> docs = [SELECT Id FROM ContentDocument WHERE Id = :files[0].ContentDocumentId];

        System.assertEquals(true, ba.HasDocument__c);

        Test.startTest();
        delete docs;
        Test.stopTest();

        Business_Assessment__c businessAssessment = [SELECT Id, HasDocument__c FROM Business_Assessment__c WHERE Id = :ba.Id];

        System.assertEquals(true, businessAssessment.HasDocument__c);

    }

}