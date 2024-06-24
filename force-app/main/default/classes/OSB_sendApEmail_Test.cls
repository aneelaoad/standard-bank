/**
 * Test class for the OSB_sendApEmail class
 *
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @date April 2020
 *
 **/

@IsTest
public class OSB_sendApEmail_Test {
    
    private static final String TEST_USER_NAME = 'test@test.com';
    private static final String TEST_CONTACT_FISRT_NAME = 'Test';
    private static final String TEST_CONTACT_LAST_NAME = 'Manager';
    
    @TestSetup
    static void setup() {
        List<OSB_URLs__c> osbUrls = TEST_DataFactory.getOsbUrls();
        insert osbUrls;
    }

    @isTest
    static void sendEmail(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        BLD_Account accBld = new BLD_Account().name(DMN_Account.STANDARD_BANK_EMPLOYEES);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);
        
        Contact contactFound = (Contact) new BLD_Contact()
            .account(accBld)
            .name(TEST_CONTACT_FISRT_NAME, TEST_CONTACT_LAST_NAME)
            .email(TEST_USER_NAME)
            .mock();
        
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
               
        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
        .thenReturn('https://onehub.standardbank.co.za');
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectById(new Set<Id> {contactFound.Id})).thenReturn(new List<Contact> {contactFound});
        mocks.stopStubbing();
        
        ORG_Application.selector.setMock(contactsSel);
        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(contactFound);
        OSB_sendApEmail newEmail = new OSB_sendApEmail(controller);
        PageReference result = newEmail.sendEmail();
        System.assertNotEquals(result,null);
        
		fflib_ArgumentCaptor capturedEmailArg = fflib_ArgumentCaptor.forClass(Messaging.SingleEmailMessage.class);
  		((fflib_ISObjectUnitOfWork) mocks.verify(uowMock,1)).registerEmail((Messaging.SingleEmailMessage)capturedEmailArg.capture()); 
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @isTest
    static void sendDPNPEmail(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        BLD_Account accBld = new BLD_Account().name(DMN_Account.STANDARD_BANK_EMPLOYEES);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);
        
        Contact contactFound = (Contact) new BLD_Contact()
            .account(accBld)
            .name(TEST_CONTACT_FISRT_NAME, TEST_CONTACT_LAST_NAME)
            .email(TEST_USER_NAME)
            .mock();
        
        Contact contactFoundTwo = (Contact) new BLD_Contact()
            .account(accBld)
            .name(TEST_CONTACT_FISRT_NAME, TEST_CONTACT_LAST_NAME)
            .email(TEST_USER_NAME)
            .mock();
        
        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
        .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        
        List <Contact> inviteList = new List <Contact>();
        inviteList.add(contactFound);
        inviteList.add(contactFoundTwo);
        OSB_sendApEmail.sendDPNpLink(inviteList);
        
		fflib_ArgumentCaptor capturedEmailArg = fflib_ArgumentCaptor.forClass(Messaging.SingleEmailMessage.class);
  		((fflib_ISObjectUnitOfWork) mocks.verify(uowMock,2)).registerEmail((Messaging.SingleEmailMessage)capturedEmailArg.capture()); 
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @isTest
    static void shouldSendReinviteLink(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        Contact accessManager = (Contact) new BLD_Contact()
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
                .mock();

        Contact nominatedPerson = (Contact) new BLD_Contact()
                .communityAccessManager(accessManager.Id)
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_INACTIVE)
                .mock();
        
        Contact designatedPerson = (Contact) new BLD_Contact()
                .communityAccessManager(accessManager.Id)
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_DP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_DECLINED)
                .mock();

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
                .thenReturn('https://onehub.standardbank.co.za');
        mocks.when(selectorMock.sObjectType())
                .thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        OSB_sendApEmail.sendReinviteLink(new List<Contact>{nominatedPerson, designatedPerson});
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 4))
                .registerEmail((Messaging.SingleEmailMessage) argument.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .commitWork();
    }
}