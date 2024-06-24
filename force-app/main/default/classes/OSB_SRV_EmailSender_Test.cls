/**
 * Test class for OSB_SRV_EmailSender
 *
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date May 2020
 *
 **/
@IsTest(IsParallel=true)
public class OSB_SRV_EmailSender_Test {
	
    private static final String TEST_COMPANY_NAME = 'StandardBank';
    private static final String TEST_CONTACT_FISRT_NAME = 'Test';
	private static final String TEST_CONTACT_LAST_NAME = 'Manager';
    private static final String TEST_ACCOUNT_NAME = 'myRandomAcc';
    
    @TestSetup
    static void setup() {
        List<OSB_URLs__c> osbUrls = TEST_DataFactory.getOsbUrls(); 
        insert osbUrls;
        
        SB_Parameters__c sbParameters = new SB_Parameters__c();
        sbParameters.Name = 'OSB_AuthentifiSolutionEmail';
        sbParameters.Value__c = 'test@testemail2312.co.za';
        insert sbParameters;
    }

    @IsTest
    static void shouldSendSignUpEmails() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        OSB_SRV_EmailBuilder emailBuilderMock = (OSB_SRV_EmailBuilder) mocks.mock(OSB_SRV_EmailBuilder.class);

        Contact accessManager = (Contact) new BLD_Contact()
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .mock();

        Contact nominatedPerson = (Contact) new BLD_Contact()
            .communityAccessManager(accessManager.Id)
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_PENDING_APPROVAL)
            .mock();

        mocks.startStubbing();
        mocks.when(emailBuilderMock.createSignUpEmails(new List<Contact>{nominatedPerson})).thenReturn(dummyEmailList());
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(OSB_SRV_EmailBuilder.IService.class, emailBuilderMock);
        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        OSB_SRV_EmailSender.newInstance().sendSignUpEmails(new List<Contact>{nominatedPerson}, uowMock);
        Test.stopTest();
		
        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerEmail((Messaging.SingleEmailMessage) argument.capture());
        ((OSB_SRV_EmailBuilder) mocks.verify(emailBuilderMock, 1)).createSignUpEmails(new List<Contact>{nominatedPerson});
    }
    
    @isTest
    static void shouldSendApInviteEmail(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        OSB_SRV_EmailBuilder emailBuilderMock = (OSB_SRV_EmailBuilder) mocks.mock(OSB_SRV_EmailBuilder.class);

        Contact accessManager = (Contact) new BLD_Contact()
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .mock();
        
        mocks.startStubbing();
        mocks.when(emailBuilderMock.createCommunityEmailAP(new List<Contact>{accessManager})).thenReturn(dummyEmailList());
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(OSB_SRV_EmailBuilder.IService.class, emailBuilderMock);
        
        Test.startTest();
        OSB_SRV_EmailSender.newInstance().sendApInviteEmail(new List<Contact>{accessManager}, uowMock);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerEmail((Messaging.SingleEmailMessage) argument.capture());
        ((OSB_SRV_EmailBuilder) mocks.verify(emailBuilderMock, 1)).createCommunityEmailAP(new List<Contact>{accessManager});
    }  
    
    @isTest
    static void shouldSendDpNpInviteEmail(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        OSB_SRV_EmailBuilder emailBuilderMock = (OSB_SRV_EmailBuilder) mocks.mock(OSB_SRV_EmailBuilder.class);

        Contact accessManager = (Contact) new BLD_Contact()
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .mock();

        Contact nominatedPerson = (Contact) new BLD_Contact()
            .communityAccessManager(accessManager.Id)
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_INACTIVE)
            .mock();
		
        mocks.startStubbing();
        mocks.when(emailBuilderMock.createCommunityEmailDP_NP(new List<Contact>{nominatedPerson})).thenReturn(dummyEmailList());
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(OSB_SRV_EmailBuilder.IService.class, emailBuilderMock);
                
        Test.startTest();
        OSB_SRV_EmailSender.newInstance().sendDPNpInviteEmail(new List<Contact>{nominatedPerson}, uowMock);
        Test.stopTest();
        
        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerEmail((Messaging.SingleEmailMessage) argument.capture());
        ((OSB_SRV_EmailBuilder) mocks.verify(emailBuilderMock, 1)).createCommunityEmailDP_NP(new List<Contact>{nominatedPerson});
    }

    @isTest
    static void shouldSendReinviteEmail(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        OSB_SRV_EmailBuilder emailBuilderMock = (OSB_SRV_EmailBuilder) mocks.mock(OSB_SRV_EmailBuilder.class);

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
        mocks.when(emailBuilderMock.createCommunityReinviteEmailDP_NP(new List<Contact>{nominatedPerson,designatedPerson})).thenReturn(dummyEmailList());
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(OSB_SRV_EmailBuilder.IService.class, emailBuilderMock);
        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        OSB_SRV_EmailSender.newInstance().sendReinviteEmail(new List<Contact>{nominatedPerson, designatedPerson}, uowMock);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerEmail((Messaging.SingleEmailMessage) argument.capture());
        ((OSB_SRV_EmailBuilder) mocks.verify(emailBuilderMock, 1)).createCommunityReinviteEmailDP_NP(new List<Contact>{nominatedPerson,designatedPerson});
    }
    
    @IsTest
    static void shouldSendDpNpAccessDeclinedEmail() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        OSB_SRV_EmailBuilder emailBuilderMock = (OSB_SRV_EmailBuilder) mocks.mock(OSB_SRV_EmailBuilder.class);

        Contact accessManager = (Contact) new BLD_Contact()
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .mock();

        Contact nominatedPerson = (Contact) new BLD_Contact()
            .communityAccessManager(accessManager.Id)
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_DECLINED)
            .mock();

        mocks.startStubbing();
        mocks.when(emailBuilderMock.createDpNpAccessDeclinedEmail(new List<Contact>{nominatedPerson})).thenReturn(dummyEmailList());
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(OSB_SRV_EmailBuilder.IService.class, emailBuilderMock);
        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        OSB_SRV_EmailSender.newInstance().sendDpNpAccessDeclinedEmail(new List<Contact>{nominatedPerson}, uowMock);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerEmail((Messaging.SingleEmailMessage) argument.capture());
        ((OSB_SRV_EmailBuilder) mocks.verify(emailBuilderMock, 1)).createDpNpAccessDeclinedEmail(new List<Contact>{nominatedPerson});
    }

    @IsTest
    static void shouldSendDpNpAccessApprovedEmail() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        OSB_SRV_EmailBuilder emailBuilderMock = (OSB_SRV_EmailBuilder) mocks.mock(OSB_SRV_EmailBuilder.class);

        Contact accessManager = (Contact) new BLD_Contact()
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .mock();

        Contact nominatedPerson = (Contact) new BLD_Contact()
            .communityAccessManager(accessManager.Id)
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .mock();

        mocks.startStubbing();
        mocks.when(emailBuilderMock.createDpNpAccessApprovedEmail(new List<Contact>{nominatedPerson})).thenReturn(dummyEmailList());
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(OSB_SRV_EmailBuilder.IService.class, emailBuilderMock);
        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        OSB_SRV_EmailSender.newInstance().sendDpNpAccessApprovedEmail(new List<Contact>{nominatedPerson}, uowMock);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerEmail((Messaging.SingleEmailMessage) argument.capture());
        ((OSB_SRV_EmailBuilder) mocks.verify(emailBuilderMock, 1)).createDpNpAccessApprovedEmail(new List<Contact>{nominatedPerson});
    }

    @IsTest
    static void shouldSendDpNpReinviteAccessApprovedEmail(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        OSB_SRV_EmailBuilder emailBuilderMock = (OSB_SRV_EmailBuilder) mocks.mock(OSB_SRV_EmailBuilder.class);

        Contact accessManager = (Contact) new BLD_Contact()
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .mock();

        Contact nominatedPerson = (Contact) new BLD_Contact()
            .communityAccessManager(accessManager.Id)
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .setField(Contact.OSB_Contact_Re_invited__c, true)
            .mock();

        mocks.startStubbing();
        mocks.when(emailBuilderMock.createDpNpReinviteAccessApprovedEmail(new List<Contact>{nominatedPerson})).thenReturn(dummyEmailList());
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(OSB_SRV_EmailBuilder.IService.class, emailBuilderMock);
        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        OSB_SRV_EmailSender.newInstance().sendDpNpAccessApprovedEmail(new List<Contact>{nominatedPerson}, uowMock);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerEmail((Messaging.SingleEmailMessage) argument.capture());
        ((OSB_SRV_EmailBuilder) mocks.verify(emailBuilderMock, 1)).createDpNpReinviteAccessApprovedEmail(new List<Contact>{nominatedPerson});
    }

    @IsTest
    static void shouldSendDpNpAccessRemovedEmail() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        OSB_SRV_EmailBuilder emailBuilderMock = (OSB_SRV_EmailBuilder) mocks.mock(OSB_SRV_EmailBuilder.class);

        Contact accessManager = (Contact) new BLD_Contact()
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .mock();

        Contact nominatedPerson = (Contact) new BLD_Contact()
            .communityAccessManager(accessManager.Id)
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_INACTIVE)
            .mock();

        mocks.startStubbing();
        mocks.when(emailBuilderMock.createDpNpAccessRemovedEmail(new List<Contact>{nominatedPerson})).thenReturn(dummyEmailList());
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(OSB_SRV_EmailBuilder.IService.class, emailBuilderMock);
        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        OSB_SRV_EmailSender.newInstance().sendDpNpAccessRemovedEmail(new List<Contact>{nominatedPerson}, uowMock);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerEmail((Messaging.SingleEmailMessage) argument.capture());
        ((OSB_SRV_EmailBuilder) mocks.verify(emailBuilderMock, 1)).createDpNpAccessRemovedEmail(new List<Contact>{nominatedPerson});
    }

	@IsTest
    static void shouldSendApAccessApprovedEmail() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        OSB_SRV_EmailBuilder emailBuilderMock = (OSB_SRV_EmailBuilder) mocks.mock(OSB_SRV_EmailBuilder.class);

        Contact accessManager = (Contact) new BLD_Contact()
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .mock();

        mocks.startStubbing();
        mocks.when(emailBuilderMock.createApAccessApprovedEmail(new List<Contact>{accessManager})).thenReturn(dummyEmailList());
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(OSB_SRV_EmailBuilder.IService.class, emailBuilderMock);

		Test.startTest();
		OSB_SRV_EmailSender.newInstance().sendApAccessApprovedEmail(new List<Contact>{accessManager}, uowMock);
		Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerEmail((Messaging.SingleEmailMessage) argument.capture());
        ((OSB_SRV_EmailBuilder) mocks.verify(emailBuilderMock, 1)).createApAccessApprovedEmail(new List<Contact>{accessManager});
	}

	@IsTest
    static void shouldSendApAccessDeclinedEmail() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        OSB_SRV_EmailBuilder emailBuilderMock = (OSB_SRV_EmailBuilder) mocks.mock(OSB_SRV_EmailBuilder.class);

        Contact accessManager = (Contact) new BLD_Contact()
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_DECLINED)
            .mock();

        mocks.startStubbing();
        mocks.when(emailBuilderMock.createApAccessDeclinedEmail(new List<Contact>{accessManager})).thenReturn(dummyEmailList());
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(OSB_SRV_EmailBuilder.IService.class, emailBuilderMock);

		Test.startTest();
		OSB_SRV_EmailSender.newInstance().sendApAccessDeclinedEmail(new List<Contact>{accessManager}, uowMock);
		Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerEmail((Messaging.SingleEmailMessage) argument.capture());
        ((OSB_SRV_EmailBuilder) mocks.verify(emailBuilderMock, 1)).createApAccessDeclinedEmail(new List<Contact>{accessManager});
	}
    
    @IsTest
    static void shouldSendCommunitySolutionEmail() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        Account a = (Account) new BLD_Account().name(TEST_ACCOUNT_NAME).commitWork().getRecord();
        
        Contact accessManager = (Contact) new BLD_Contact()
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .mock();

        Contact nominatedPerson = (Contact) new BLD_Contact()
            .communityAccessManager(accessManager.Id)
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .companyName(TEST_COMPANY_NAME)
            .name(TEST_CONTACT_FISRT_NAME,TEST_CONTACT_LAST_NAME)
            .accountId(a.Id)
            .mock();
        
        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString())).thenReturn('https://onehub.standardbank.co.za');
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        OSB_SRV_EmailSender.newInstance().sendSolutionEmail(new List<Contact>{nominatedPerson},uowMock,'');
        Test.stopTest();

        ((SRV_Document) mocks.verify(serviceMock, 1)).getImageLink(OSB_SRV_EmailBuilder.OSB_EMAIL_BANNER_IMAGE_NAME);
        ((SRV_Document) mocks.verify(serviceMock, 1)).getImageLink(OSB_SRV_EmailBuilder.OSB_EMAIL_FOOTER_IMAGE_NAME);
    }
    
    private static List<Messaging.SingleEmailMessage> dummyEmailList(){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'user@acme.com'}; 
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('testemail@onehub.co.za');
        mail.setSenderDisplayName('Test Email');
        mail.setSubject('test email');
        mail.setPlainTextBody('This is a test email');
        mail.setHtmlBody('This is a test email');
        
        return new List<Messaging.SingleEmailMessage>{mail};
    }
}