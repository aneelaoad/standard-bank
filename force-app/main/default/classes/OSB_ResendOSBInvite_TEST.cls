/**
 * Test class for OSB_ResendOSBInvite class
 * 
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date April 2020
 * 
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
@IsTest
private class OSB_ResendOSBInvite_TEST {

    @TestSetup
    static void setup() {
        List<OSB_URLs__c> osbUrls = TEST_DataFactory.getOsbUrls();
        insert osbUrls;
    }

    @IsTest
    static void shouldReSendInviteEmails() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);
	
        Contact nominatedPerson = (Contact) new BLD_Contact()
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_PENDING_APPROVAL)
                .mock();

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
                .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);

        Test.startTest();
        OSB_ResendOSBInvite.resendInvite(new List<Contact>{nominatedPerson});
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .registerEmail((Messaging.SingleEmailMessage) argument.capture());

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .commitWork();
        ((SRV_Document) mocks.verify(serviceMock, 1))
                .getImageLink(OSB_ContactCommunication.EMAIL_BANNER_IMAGE_NAME);
        ((SRV_Document) mocks.verify(serviceMock, 1))
                .getImageLink(OSB_ContactCommunication.EMAIL_FOOTER_IMAGE_NAME);
    }
}