/**
 * Test class for SRV_Document
 * <br/>
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date May 2020
 *
 **/
@IsTest(IsParallel=true)
private class SRV_Document_TEST {

    @TestSetup
    static void makeData(){
        List<OSB_URLs__c> osbUrls = TEST_DataFactory.getOsbUrls();
        insert osbUrls;
    }

    @IsTest
    static void shouldGetDocumentLink() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Documents docSelector = (SEL_Documents) mocks.mock(SEL_Documents.class);
        Document sampleDocument = (Document) new BLD_Document().mock();

        mocks.startStubbing();
        mocks.when(docSelector.sObjectType()).thenReturn(Document.SObjectType);
        mocks.when(docSelector.selectByDeveloperName((Set<String>) fflib_Match.anyObject())).thenReturn(new List<Document> {sampleDocument});
        mocks.stopStubbing();
        ORG_Application.selector.setMock(docSelector);

        Test.startTest();
        String url = SRV_Document.newInstance().getDocumentLink('');
        Test.stopTest();
        System.assert(url.contains(sampleDocument.Id));
    }

    @IsTest
    static void shouldGetImageLink() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Documents docSelector = (SEL_Documents) mocks.mock(SEL_Documents.class);
        Document sampleDocument = (Document) new BLD_Document().mock();

        mocks.startStubbing();
        mocks.when(docSelector.sObjectType()).thenReturn(Document.SObjectType);
        mocks.when(docSelector.selectByDeveloperName((Set<String>) fflib_Match.anyObject())).thenReturn(new List<Document> {sampleDocument});
        mocks.stopStubbing();
        ORG_Application.selector.setMock(docSelector);

        Test.startTest();
        String url = SRV_Document.newInstance().getImageLink('');
        Test.stopTest();
        System.assert(url.contains(sampleDocument.Id));
    }
}