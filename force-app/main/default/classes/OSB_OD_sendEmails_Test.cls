/**
 * Test class for the OSB_OD_sendEmails class
 *
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 *
 */
@IsTest
public class OSB_OD_sendEmails_Test {
    private static final string PRODUCT_NAME = 'Test Product';
    private static final String TEST_USER_NAME = 'test@test.com';
    private static final String TEST_CONTACT_FISRT_NAME = 'Test';
    private static final String TEST_CONTACT_LAST_NAME = 'TestUser';

    @TestSetup
    static void setup() {
        List<OSB_URLs__c> osbUrls = TEST_DataFactory.getOsbUrls();
        insert osbUrls;
    }

    @isTest
    static void shouldSendSupportInterestedEmail() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);

        BLD_Account accBld = new BLD_Account().name(DMN_Account.STANDARD_BANK_EMPLOYEES);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        Contact oneHubUser = (Contact) new BLD_Contact()
            .account(accBld)
            .name(TEST_CONTACT_FISRT_NAME, TEST_CONTACT_LAST_NAME)
            .email(TEST_USER_NAME)
            .mock();

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString())).thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);

        Test.startTest();
        OSB_OD_sendEmails.sendSupportInterestedEmail(new List<Contact>{ oneHubUser }, PRODUCT_NAME);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, mocks.times(1).description('email constructed')))
            .registerEmail((Messaging.SingleEmailMessage) fflib_Match.anyObject());

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, mocks.times(1).description('email sent'))).commitWork();

        fflib_ArgumentCaptor capturedEmailArg = fflib_ArgumentCaptor.forClass(Messaging.SingleEmailMessage.class);

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerEmail((Messaging.SingleEmailMessage) capturedEmailArg.capture());

        Object actualEmailAsObject = capturedEmailArg.getValue();
        Messaging.SingleEmailMessage actualEmail = (Messaging.SingleEmailMessage) actualEmailAsObject;

        System.assertEquals(PRODUCT_NAME, actualEmail.getSubject(), 'The subject should be the product name');
    }

    @isTest
    static void shouldSendContactInterestedEmail() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);

        BLD_Account accBld = new BLD_Account().name(DMN_Account.STANDARD_BANK_EMPLOYEES);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        Contact oneHubUser = (Contact) new BLD_Contact()
            .account(accBld)
            .name(TEST_CONTACT_FISRT_NAME, TEST_CONTACT_LAST_NAME)
            .email(TEST_USER_NAME)
            .mock();

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString())).thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);

        Test.startTest();
        OSB_OD_sendEmails.sendContactInterestedEmail(new List<Contact>{ oneHubUser }, PRODUCT_NAME);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, mocks.times(2).description('email constructed')))
            .registerEmail((Messaging.SingleEmailMessage) fflib_Match.anyObject());

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, mocks.times(2).description('email sent'))).commitWork();

        fflib_ArgumentCaptor capturedEmailArg = fflib_ArgumentCaptor.forClass(Messaging.SingleEmailMessage.class);

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 2)).registerEmail((Messaging.SingleEmailMessage) capturedEmailArg.capture());

        Object actualEmailAsObject = capturedEmailArg.getValue();
        Messaging.SingleEmailMessage actualEmail = (Messaging.SingleEmailMessage) actualEmailAsObject;

        System.assertEquals('Thank you for your interest', actualEmail.getSubject(), 'The subject should be the product name');
    }

    @isTest
    static void shouldSendInterestedEmails() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);

        BLD_Account accBld = new BLD_Account().name(DMN_Account.STANDARD_BANK_EMPLOYEES);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        Contact oneHubUser = (Contact) new BLD_Contact()
            .account(accBld)
            .name(TEST_CONTACT_FISRT_NAME, TEST_CONTACT_LAST_NAME)
            .email(TEST_USER_NAME)
            .mock();

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString())).thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);

        Test.startTest();
        OSB_OD_sendEmails.sendInterestedEmails(new List<Contact>{ oneHubUser }, PRODUCT_NAME);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, mocks.times(2).description('email constructed')))
            .registerEmail((Messaging.SingleEmailMessage) fflib_Match.anyObject());

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, mocks.times(2).description('email sent'))).commitWork();

        fflib_ArgumentCaptor capturedEmailArg = fflib_ArgumentCaptor.forClass(Messaging.SingleEmailMessage.class);

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 2)).registerEmail((Messaging.SingleEmailMessage) capturedEmailArg.capture());

        Object actualEmailAsObject = capturedEmailArg.getValue();

        Messaging.SingleEmailMessage actualEmail = (Messaging.SingleEmailMessage) actualEmailAsObject;

        System.assertEquals('Thank you for your interest', actualEmail.getSubject(), 'The subject should be the product name');
    }
}