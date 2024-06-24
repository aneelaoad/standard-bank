/**
 * @description Test class for OSB_ContactCommunication & OSB_ResendOSBInvite class
 * 
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date April 2020
 * 
 * @LastModified August 2023
 * @author litha Nosekeleza (litha.Nosekeleza@standardbank.co.za)
 * @UserStory SFP-28081
 * @LastModifiedReason added Assert a testing methods for shouldSendcreateInviteeSignUpEmail
 * 
 */
@IsTest
private class OSB_ContactCommunicationTest {

    @TestSetup
    static void setup() {
        List<OSB_URLs__c> osbUrls = TEST_DataFactory.getOsbUrls();
        insert osbUrls;
    }

    @IsTest
    static void shouldSendInviteEmails() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        Contact accessManager = (Contact) new BLD_Contact()
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
                .mock();

        Contact nominatedPerson = (Contact) new BLD_Contact()
                .communityAccessManager(accessManager.Id)
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_PENDING_APPROVAL)
                .mock();

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
                .thenReturn('https://onehub.standardbank.co.za');
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        OSB_ContactCommunication.sendOSBEmails(new List<Contact>{nominatedPerson});
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 0))
                .registerEmail((Messaging.SingleEmailMessage) argument.capture());
        
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .commitWork();
        ((SRV_Document) mocks.verify(serviceMock, 1))
                .getImageLink(OSB_ContactCommunication.EMAIL_BANNER_IMAGE_NAME);
        Assert.areNotEqual(null, nominatedPerson, 'Contact to send email to, not null');
        Assert.areNotEqual(null, accessManager, 'Contact Manager not null');
    }

    @IsTest
    static void shouldSendNPAccessDeclinedEmail() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        Contact accessManager = (Contact) new BLD_Contact()
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
                .mock();

        Contact nominatedPerson = (Contact) new BLD_Contact()
                .communityAccessManager(accessManager.Id)
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_DECLINED)
                .mock();

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
        .thenReturn('https://onehub.standardbank.co.za');
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        OSB_ContactCommunication.sendOSBEmails(new List<Contact>{nominatedPerson});
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .registerEmail((Messaging.SingleEmailMessage) argument.capture());
        
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .commitWork();
        ((SRV_Document) mocks.verify(serviceMock, 1))
                .getImageLink(OSB_ContactCommunication.EMAIL_BANNER_IMAGE_NAME);
        Assert.areNotEqual(null, nominatedPerson, 'Contact to send email to, not null');
        Assert.areNotEqual(null, accessManager, 'Contact Manager not null');
    }

    @IsTest
    static void shouldSendNPAccessApprovedEmail() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        Contact accessManager = (Contact) new BLD_Contact()
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
                .mock();

        Contact nominatedPerson = (Contact) new BLD_Contact()
                .communityAccessManager(accessManager.Id)
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
                .mock();

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
        .thenReturn('https://onehub.standardbank.co.za');
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        ORG_Application.selector.setMock(selectorMock);
        
        Test.startTest();
        OSB_ContactCommunication.sendOSBEmails(new List<Contact>{nominatedPerson});
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .registerEmail((Messaging.SingleEmailMessage) argument.capture());
        
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .commitWork();
        ((SRV_Document) mocks.verify(serviceMock, 1))
                .getImageLink(OSB_ContactCommunication.EMAIL_BANNER_IMAGE_NAME);
        Assert.areNotEqual(null, nominatedPerson, 'Contact to send email to, not null');
        Assert.areNotEqual(null, accessManager, 'Contact Manager not null');
    }

    @IsTest
    static void shouldCreateDpNpReinviteAccessApprovedEmail(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        Contact accessManager = (Contact) new BLD_Contact()
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
                .mock();

        Contact nominatedPerson = (Contact) new BLD_Contact()
                .communityAccessManager(accessManager.Id)
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
                .setField(Contact.OSB_Contact_Re_invited__c, true)
                .mock();

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
        .thenReturn('https://onehub.standardbank.co.za');
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        OSB_ContactCommunication.sendOSBEmails(new List<Contact>{nominatedPerson});
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .registerEmail((Messaging.SingleEmailMessage) argument.capture());
        
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .commitWork();
        ((SRV_Document) mocks.verify(serviceMock, 1))
                .getImageLink(OSB_ContactCommunication.EMAIL_BANNER_IMAGE_NAME);
        Assert.areNotEqual(null, nominatedPerson, 'Contact to send email to, not null');
        Assert.areNotEqual(null, accessManager, 'Contact Manager not null');
    }

    @IsTest
    static void shouldSendAccessRemovedEmail() {
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

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
        .thenReturn('https://onehub.standardbank.co.za');
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        OSB_ContactCommunication.sendOSBEmails(new List<Contact>{nominatedPerson});
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .registerEmail((Messaging.SingleEmailMessage) argument.capture());
        
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .commitWork();
        ((SRV_Document) mocks.verify(serviceMock, 1))
                .getImageLink(OSB_ContactCommunication.EMAIL_BANNER_IMAGE_NAME);
        Assert.areNotEqual(null, nominatedPerson, 'Contact to send email to, not null');
        Assert.areNotEqual(null, accessManager, 'Contact Manager not null');
    }

	@IsTest
    static void shouldSendAPAccessApprovedEmail() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        Contact accessManager = (Contact) new BLD_Contact()
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
                .mock();

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
        .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);

		Test.startTest();
		OSB_ContactCommunication.sendOSBEmails(new List<Contact>{accessManager});
		Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .registerEmail((Messaging.SingleEmailMessage) argument.capture());

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .commitWork();
        ((SRV_Document) mocks.verify(serviceMock, 1))
                .getImageLink(OSB_ContactCommunication.EMAIL_BANNER_IMAGE_NAME);
        Assert.areNotEqual(null, accessManager, 'Manager not null');
	}

	@IsTest
    static void shouldSendAPAccessDeclinedEmail() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        Contact accessManager = (Contact) new BLD_Contact()
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_DECLINED)
                .mock();

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
        .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);

		Test.startTest();
		OSB_ContactCommunication.sendOSBEmails(new List<Contact>{accessManager});
		Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .registerEmail((Messaging.SingleEmailMessage) argument.capture());
        
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .commitWork();
        ((SRV_Document) mocks.verify(serviceMock, 1))
                .getImageLink(OSB_ContactCommunication.EMAIL_BANNER_IMAGE_NAME);
        Assert.areNotEqual(null, accessManager, 'Contact Manager not null');
	}
    
    @IsTest
    static void shouldSendcreateInviteeSignUpEmail() {
    fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        Contact accessManager = (Contact) new BLD_Contact()
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
                .mock();

        Contact nominatedPerson = (Contact) new BLD_Contact()
                .communityAccessManager(accessManager.Id)
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_INVITE_SENT)
                .mock();

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
        .thenReturn('https://onehub.standardbank.co.za');
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        ORG_Application.selector.setMock(selectorMock);

       
        Test.startTest();
        OSB_ContactCommunication.sendOSBEmails(new List<Contact>{nominatedPerson});
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 0))
                .registerEmail((Messaging.SingleEmailMessage) argument.capture());
        
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
                .commitWork();
        ((SRV_Document) mocks.verify(serviceMock, 1))
                .getImageLink(OSB_ContactCommunication.EMAIL_BANNER_IMAGE_NAME);
        Assert.areNotEqual(null, nominatedPerson, 'Contact to send email to, not null');
        Assert.areNotEqual(null, accessManager, 'Contact Manager not null');
	}
}