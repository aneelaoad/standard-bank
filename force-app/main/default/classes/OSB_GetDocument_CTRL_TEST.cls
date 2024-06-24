/**
 * Test class for OSBGetDocumentVF class
 * 
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date April 2020
 * 
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
@IsTest(IsParallel=true)
public class OSB_GetDocument_CTRL_TEST {
    private static final String DOCUMENT_TYPE = 'Document';

    @IsTest
    static void shouldGetDocumentUrl() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);

        Test.startTest();
        OSB_GetDocument_CTRL documentController = new OSB_GetDocument_CTRL();
        documentController.documentName = '';
        String result = documentController.documentURL;
        Test.stopTest();
        ((SRV_Document) mocks.verify(serviceMock, 1))
                .getImageLink(fflib_Match.anyString());
    }
}