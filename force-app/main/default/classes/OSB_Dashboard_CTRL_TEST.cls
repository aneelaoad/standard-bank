/**
 * @description Test class for OSB_Dashboard_CTRL
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date June 2020
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-28081
 * @LastModifiedReason Update test class to accomodate to updates to getRegisteredApplication
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason Update to test classes and new test method to accomodate flagging shortcus 
 * 
 * @LastModified October 2023
 * @author Nkosi Ncube (nkosi.ncube@standardbank.co.za)
 * @UserStory SFP-20792
 * @LastModifiedReason update to test new method to allow for retrieving solutions a user is subscribed to
 * 
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
@IsTest(IsParallel=true)
private class OSB_Dashboard_CTRL_TEST {
    
    private static final String TEST_COMMUNITY_STATUS = 'Approved';
    private static final String TEST_COMMUNITY_ROLE = 'Authorised Person';
    public static final String OBJ_NAME = 'Subscribed_Solutions__c';
    public static final String RT_APPLICATION = 'Subscribed_Applications';
    public static final String RT_SHORTCUTS = 'Subscribed_Shortcuts';
    public static final Boolean TEST_HIDE_FLAG_TRUE = true;
    public static final String SHORTCUTS_VALUE = 'Hide Shortcuts';
    public static final String MFA_VALUE = 'Hide MFA';
    
    @IsTest
    static void shouldGetOnboardingDetails() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);

        Contact testContact = (Contact) new BLD_Contact().mock();
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByUserId((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Contact> {testContact});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        Contact contacts = OSB_Dashboard_CTRL.getOnboardingDetails();
        Test.stopTest();
        
        ((SEL_Contacts) mocks.verify(selectorMock, 1))
                .selectByUserId((Set<Id>) fflib_Match.anyObject());
        Assert.areEqual(String.isNotBlank(contacts.Id), true, 'Retrieve contact details');
    }

    @IsTest
    static void shouldGetRegisteredApplication() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_SubscribedSolutions selectorMock = (SEL_SubscribedSolutions) mocks.mock(SEL_SubscribedSolutions.class);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(
            SEL_Contacts.class
        );

        Contact managerContact = (Contact) new BLD_Contact().mock();

        Contact testContact = (Contact) new BLD_Contact()
            .setOSBDefaultData(TEST_COMMUNITY_ROLE, TEST_COMMUNITY_STATUS)
            .communityAccessManager(managerContact.Id)
            .useClientContact()
            .mock();
       
        Subscribed_Solutions__c testSubscribedSolution = (Subscribed_Solutions__c) new BLD_Subscribed_Solutions()
        .setContact(testContact.Id)
        .mock();
        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId((Set<Id>) fflib_Match.anyObject()))
        .thenReturn(new List<Contact> {testContact});
        mocks.when(selectorMock.sObjectType()).thenReturn(Subscribed_Solutions__c.SObjectType);
        mocks.when(selectorMock.selectByContactId((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Subscribed_Solutions__c> {testSubscribedSolution});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);
        ORG_Application.selector.setMock(contactsSel);

        Test.startTest();
        List<Subscribed_Solutions__c> results = OSB_Dashboard_CTRL.getRegisteredApplication();
        Test.stopTest();
        ((SEL_SubscribedSolutions) mocks.verify(selectorMock, 1))
                .selectByContactId((Set<Id>) fflib_Match.anyObject());
        Assert.areEqual(1, results.size(), 'Retrieve subscribed solution');
    }
    
    @IsTest
    static void shouldGetRegisteredApplicationwithRecordtype() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_SubscribedSolutions selectorMock = (SEL_SubscribedSolutions) mocks.mock(SEL_SubscribedSolutions.class);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(
            SEL_Contacts.class
        );

        Contact managerContact = (Contact) new BLD_Contact().mock();

        Contact testContact = (Contact) new BLD_Contact()
        .setOSBDefaultData(TEST_COMMUNITY_ROLE, TEST_COMMUNITY_STATUS)
        .communityAccessManager(managerContact.Id)
        .useClientContact()
        .mock();
        
        Subscribed_Solutions__c testSubscribedSolution = (Subscribed_Solutions__c) new BLD_Subscribed_Solutions()
        .setOSBData()
        .setContact(testContact.Id)
        .setApplicationRecordType()
        .mock();

        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId((Set<Id>) fflib_Match.anyObject()))
        .thenReturn(new List<Contact> {testContact});
        mocks.when(selectorMock.sObjectType()).thenReturn(Subscribed_Solutions__c.SObjectType);
        mocks.when(selectorMock.selectByContactIdAndRecordType((Set<Id>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Subscribed_Solutions__c> {testSubscribedSolution});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);
        ORG_Application.selector.setMock(contactsSel);

        Test.startTest();
        List<Subscribed_Solutions__c> result = OSB_Dashboard_CTRL.getRegisteredApplicationwithRecordType();
        Test.stopTest();

        Assert.areEqual(result.size(), 1,  'Subscribed solution with the application record type is found');
    }
    
     @IsTest
    static void shouldGetRegisteredShortcutwithRecordtype() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_SubscribedSolutions selectorMock = (SEL_SubscribedSolutions) mocks.mock(SEL_SubscribedSolutions.class);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(
            SEL_Contacts.class
        );

        Contact managerContact = (Contact) new BLD_Contact().mock();

        Contact testContact = (Contact) new BLD_Contact()
        .setOSBDefaultData(TEST_COMMUNITY_ROLE, TEST_COMMUNITY_STATUS)
        .communityAccessManager(managerContact.Id)
        .useClientContact()
        .mock();
        
        Subscribed_Solutions__c testSubscribedSolution = (Subscribed_Solutions__c) new BLD_Subscribed_Solutions()
        .setOSBData()
        .setContact(testContact.Id)
        .setShortcutRecordType()
        .mock();
        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId((Set<Id>) fflib_Match.anyObject()))
        .thenReturn(new List<Contact> {testContact});
        mocks.when(selectorMock.sObjectType()).thenReturn(Subscribed_Solutions__c.SObjectType);
        mocks.when(selectorMock.selectByContactIdAndRecordType((Set<Id>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Subscribed_Solutions__c> {testSubscribedSolution});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);
        ORG_Application.selector.setMock(contactsSel);

        Test.startTest();
        List<Subscribed_Solutions__c> result = OSB_Dashboard_CTRL.getRegisteredShortcutwithRecordType();
        Test.stopTest();
		Assert.areEqual(result.size(), 1,  'Subscribed solution with the shortcut record type is found');
    }


    @IsTest
    static void shouldSetOnboardingDate() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();     
        OSB_SRV_OnboardingHandler serviceMock = (OSB_SRV_OnboardingHandler) mocks.mock(OSB_SRV_OnboardingHandler.class);
        ORG_Application.service.setMock(OSB_SRV_OnboardingHandler.IService.class, serviceMock);
        fflib_SObjectUnitOfWork mockUow = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
        ORG_Application.UnitOfWork.setMock(mockUow);  
        

        Contact testContact = (Contact) new BLD_Contact()
        .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
        .mock();

        Test.startTest();
        OSB_Dashboard_CTRL.setUserContactOnboardingDate(testContact.Id);
        Test.stopTest();
        ((OSB_SRV_OnboardingHandler) mocks.verify(serviceMock, 1)).setUserContactOnboardingDate((Set<Id>) fflib_Match.anyObject(), (fflib_ISObjectUnitOfWork) fflib_Match.anyObject());
        fflib_ArgumentCaptor capturedUowArg = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitofWork.class);
        fflib_ArgumentCaptor capturedUpdateContactArg = fflib_ArgumentCaptor.forClass(Set<Id>.class);
        ((OSB_SRV_OnboardingHandler) mocks.verify(serviceMock,1)).setUserContactOnboardingDate((Set<Id>)capturedUpdateContactArg.capture(), (fflib_ISobjectUnitOfWork)capturedUowArg.capture());
        Set<Id> actualUpdateContactArg = (Set<Id>) capturedUpdateContactArg.getValue();

        Assert.areEqual(true, actualUpdateContactArg.contains(testContact.Id),'The contact is being passed to be updated.');
    }

    @IsTest
    static void shouldHitCatchOnSetOnboardingDate() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OSB_SRV_OnboardingHandler serviceMock = (OSB_SRV_OnboardingHandler) mocks.mock(OSB_SRV_OnboardingHandler.class);

        Contact testContact = (Contact) new BLD_Contact()
        .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
        .mock();
        Test.startTest();
        OSB_Dashboard_CTRL.setUserContactOnboardingDate(testContact.Id);
        Test.stopTest();

        ((OSB_SRV_OnboardingHandler) mocks.verify(serviceMock, 0)).setUserContactOnboardingDate((Set<Id>) fflib_Match.anyObject(), (fflib_ISObjectUnitOfWork) fflib_Match.anyObject());
        fflib_ArgumentCaptor capturedUowArg = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitofWork.class);
        fflib_ArgumentCaptor capturedUpdateContactArg = fflib_ArgumentCaptor.forClass(Set<Id>.class);
        ((OSB_SRV_OnboardingHandler) mocks.verify(serviceMock,0)).setUserContactOnboardingDate((Set<Id>)capturedUpdateContactArg.capture(), (fflib_ISobjectUnitOfWork)capturedUowArg.capture());
        Set<Id> actualUpdateContactArg = (Set<Id>) capturedUpdateContactArg.getValue();
        Assert.areEqual(actualUpdateContactArg, null, 'No contacts update');
    }

    @isTest
    static void shouldGetDeviceDetails(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OSB_SRV_NoknokIntegration serviceMock = ( OSB_SRV_NoknokIntegration) mocks.mock(OSB_SRV_NoknokIntegration.class);
        ORG_Application.service.setMock( OSB_SRV_NoknokIntegration.IService.class, serviceMock);
        Test.startTest();	
        Map<String,Map<String, Object>> responseMap = OSB_Dashboard_CTRL.hasRegisteredDevices();
        Test.stopTest();
        Map<String,Object> resultMap = responseMap.get('statusAndIdMap');
        String result = (String)resultMap.get('responseStatusCodeString');
        Assert.areEqual('4000', result,  'Device details received');
    }

    @isTest
    static void shouldFlagShortcutsOnContact(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        ORG_Application.unitOfWork.setMock(uowMock);

        Contact testContact = (Contact) new BLD_Contact().mock();
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByUserId((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Contact> {testContact});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);        
        
        Test.startTest();
        OSB_Dashboard_CTRL.flagShortcuts(TEST_HIDE_FLAG_TRUE);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty((Contact) argument.capture());
        Contact resultContact = (Contact) argument.getValue();
        Assert.areEqual(resultContact.Manage_Site_Features__c.contains(SHORTCUTS_VALUE), true, 'Contact has shortcuts hidden');
    }

    @isTest
    static void shouldUnflagShortcutsOnContact(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        ORG_Application.unitOfWork.setMock(uowMock);

        Contact testContact = (Contact) new BLD_Contact()
        .manageSiteFeature(MFA_VALUE)
        .mock();
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByUserId((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Contact> {testContact});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);        
        
        Test.startTest();
        OSB_Dashboard_CTRL.flagShortcuts(!TEST_HIDE_FLAG_TRUE);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty((Contact) argument.capture());
        Contact resultContact = (Contact) argument.getValue();
        Assert.areEqual(resultContact.Manage_Site_Features__c.contains(SHORTCUTS_VALUE), false, 'Contact does not have shortcuts hidden');
    }

    @IsTest
    static void shouldGetApplicationByContactIdAndSolutionId() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_SubscribedSolutions selectorMock = (SEL_SubscribedSolutions) mocks.mock(SEL_SubscribedSolutions.class);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(
            SEL_Contacts.class
        );

        Contact managerContact = (Contact) new BLD_Contact().mock();

        Contact testContact = (Contact) new BLD_Contact()
            .setOSBDefaultData(TEST_COMMUNITY_ROLE, TEST_COMMUNITY_STATUS)
            .communityAccessManager(managerContact.Id)
            .useClientContact()
            .mock();
       
        Id  solutionId = fflib_IDGenerator.generate(Knowledge__kav.SObjectType);

        Subscribed_Solutions__c testSubscribedSolution = (Subscribed_Solutions__c) new BLD_Subscribed_Solutions()
        .setContact(testContact.Id)
        .mock();
        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);       
        mocks.when(contactsSel.selectByUserId((Set<Id>) fflib_Match.anyObject()))
        .thenReturn(new List<Contact> {testContact});
        mocks.when(selectorMock.sObjectType()).thenReturn(Subscribed_Solutions__c.SObjectType);        
        mocks.when(selectorMock.selectByContactIdAndSolutionId((Set<Id>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject()))
        .thenReturn(new List<Subscribed_Solutions__c> {testSubscribedSolution});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);
        ORG_Application.selector.setMock(contactsSel);

        Test.startTest();
        List<Subscribed_Solutions__c> results = OSB_Dashboard_CTRL.getApplicationByContactIdAndSolutionId(solutionId);
        Test.stopTest();
       
        Assert.areEqual(1, results.size(), 'Retrieve subscribed solution');
    }
    
}