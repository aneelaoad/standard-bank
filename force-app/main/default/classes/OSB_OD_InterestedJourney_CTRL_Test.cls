/**
 * Unit test for OSB_OD_InterestedJourney_CTRL
 * 
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022 
 */
@IsTest
public class OSB_OD_InterestedJourney_CTRL_Test {
    private static final string PRODUCT_NAME = 'Test Product';
    private static final String TEST_USER_CONTACT_EMAIL = 'test@test.com';
    private static final String TEST_CONTACT_FISRT_NAME = 'Test';
    private static final String TEST_CONTACT_LAST_NAME = 'TestUser';

    @TestSetup
    static void setup() {
        List<OSB_URLs__c> osbUrls = TEST_DataFactory.getOsbUrls();
        insert osbUrls;
    }

    @isTest
    static void shouldGenerateInterestedEmails() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        fflib_ArgumentCaptor capturedEmailArg = fflib_ArgumentCaptor.forClass(Messaging.SingleEmailMessage.class);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        BLD_Account accBld = new BLD_Account().name(DMN_Account.STANDARD_BANK_EMPLOYEES);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        Contact oneHubUser = (Contact) new BLD_Contact()
            .account(accBld)
            .name(TEST_CONTACT_FISRT_NAME, TEST_CONTACT_LAST_NAME)
            .email(TEST_USER_CONTACT_EMAIL)
            .mock();

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString())).thenReturn('https://onehub.standardbank.co.za');
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Contact>{ oneHubUser });
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.selector.setMock(contactsSel);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);

        Test.startTest();
        OSB_OD_InterestedJourney_CTRL.generateInterestedEmails(PRODUCT_NAME);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, mocks.times(2).description('email constructed')))
            .registerEmail((Messaging.SingleEmailMessage) fflib_Match.anyObject());

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, mocks.times(2).description('email sent'))).commitWork();

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 2)).registerEmail((Messaging.SingleEmailMessage) capturedEmailArg.capture());

        Object actualEmailAsObject = capturedEmailArg.getValue();
        Messaging.SingleEmailMessage actualEmail = (Messaging.SingleEmailMessage) actualEmailAsObject;

        System.assertEquals('Thank you for your interest', actualEmail.getSubject(), 'Incorrect subject');
    }
}