/**
 * Test class for OSB_DocumentWrapper_CTRL class
 * @author Wojciech Kowalczyk
 * @date June 2020
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
@IsTest(IsParallel=true)
private class OSB_DocumentWrapper_CTRL_TEST {

    @IsTest
    private static void shouldGetDocumentLink() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);

        Test.startTest();
        OSB_DocumentWrapper_CTRL.getOSBDocumentURL('');
        Test.stopTest();
        ((SRV_Document) mocks.verify(serviceMock, 1))
                .getDocumentLink('');
    }
}