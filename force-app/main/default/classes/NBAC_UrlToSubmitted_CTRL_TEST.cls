@isTest
private class NBAC_UrlToSubmitted_CTRL_TEST {
    @testSetup
    private static void setup() {
        Business_Assessment__c bAssessment = new Business_Assessment__c();
        insert bAssessment;
    }

    @isTest
    static void shouldReturnUrlToContentDocument() {

        Business_Assessment__c ba = [SELECT Id FROM Business_Assessment__c];

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

        insert contentDocLink;

        String expectedUrl = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/lightning/cmp/c__NBAC_FileOpener?c__recId=' + contentDocLink.ContentDocumentId;

        Test.startTest();
            NBAC_UrlToSubmitted_CTRL nbac_url = new NBAC_UrlToSubmitted_CTRL();
        	nbac_url.recID =ba.Id;
            String url = nbac_url.urlToPdf;
        Test.stopTest();

        System.assertEquals(expectedUrl, url);


    }

    @isTest
    static void shouldReturnUrlToAttachment() {

        Business_Assessment__c ba = [SELECT Id FROM Business_Assessment__c];

        Blob bBlob = Blob.valueOf('Unit Test');
        Attachment newAttachment = new Attachment(parentId = ba.Id, Name = 'test attachment', body = bBlob);

        insert newAttachment;

        String expectedUrl = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/servlet/servlet.FileDownload?file=' + newAttachment.Id;

        Test.startTest();
            NBAC_UrlToSubmitted_CTRL nbac_url = new NBAC_UrlToSubmitted_CTRL();
        	nbac_url.recID =ba.Id;
            String url = nbac_url.urlToPdf;
        Test.stopTest();

        System.assertEquals(expectedUrl, url);


    }

    @isTest
    static void shouldNotReturnUrlToAnyFile() {
        Business_Assessment__c ba = [SELECT Id FROM Business_Assessment__c];
        String expectedUrl = 'https://' + System.URL.getSalesforceBaseUrl().getHost();

        Test.startTest();
        String url = NBAC_UrlToSubmitted_CTRL.createURL(ba.Id);
        Test.stopTest();

        System.assertEquals(expectedUrl, url);
    }
}