/**
 * Test class for OSB_SRV_NewCase
 * <br/>
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date May 2020
 *
 **/
@IsTest(IsParallel=true)
private class OSB_SRV_NewCase_TEST {
    private static final String TEST_CASE_SUBJECT = 'Test Case';

    @IsTest
    static void shouldSaveClientCaseInUserContext() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);

        Contact communityContact = (Contact) new BLD_Contact().mock();

        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId(new Set<Id> {UserInfo.getUserId()})).thenReturn(new List<Contact> {communityContact});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(contactsSel);
        ORG_Application.unitOfWork.setMock(uowMock);

        Case newCase =new Case(Subject = TEST_CASE_SUBJECT);
        Test.startTest();
        OSB_SRV_NewCase.newInstance().saveCasesInUserContext(new List<Case>{newCase}, uowMock);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerNew((Case) argument.capture());
        Case createdCase = (Case) argument.getValue();
        System.assertEquals(createdCase.RecordTypeId, UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_CIB_CLIENT_CASE));
    }

    @IsTest
    static void shouldSaveUserCaseInUserContext() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);

        Contact communityBankContact = (Contact) new BLD_Contact()
                .useBankContact()
                .mock();

        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId(new Set<Id> {UserInfo.getUserId()})).thenReturn(new List<Contact> {communityBankContact});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(contactsSel);
        ORG_Application.unitOfWork.setMock(uowMock);
        Case newCase =new Case(Subject = TEST_CASE_SUBJECT);
        Test.startTest();
        OSB_SRV_NewCase.newInstance().saveCasesInUserContext(new List<Case>{newCase}, uowMock);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerNew((Case) argument.capture());
        Case createdCase = (Case) argument.getValue();
        System.assertEquals(createdCase.RecordTypeId, UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_USER_CASE));
    }

    @IsTest
    static void shouldSaveClientCaseInGuestContext() {
        String idNumber = 'gfs3';
        String passportNumber = 'gfs3';
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);

        Contact communityContact = (Contact) new BLD_Contact().mock();

        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByEmailIdentityPassport(
                (Set<String>) fflib_Match.anyObject(), (Set<String>) fflib_Match.anyObject(), (Set<String>) fflib_Match.anyObject()))
                .thenReturn(new List<Contact> {communityContact});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(contactsSel);
        ORG_Application.unitOfWork.setMock(uowMock);

        Case newCase =new Case(Subject = TEST_CASE_SUBJECT);
        Test.startTest();
        OSB_SRV_NewCase.newInstance().saveCaseInGuestContext(newCase, idNumber, passportNumber, uowMock);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerNew((Case) argument.capture());
        Case createdCase = (Case) argument.getValue();
        System.assertEquals(createdCase.RecordTypeId, UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_CIB_CLIENT_CASE));
    }

    @IsTest
    static void shouldSaveUserCaseInGuestContext() {
        String idNumber = 'gfs3';
        String passportNumber = 'gfs3';
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);

        Contact bankContact = (Contact) new BLD_Contact().useBankContact().mock();

        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByEmailIdentityPassport(
                (Set<String>) fflib_Match.anyObject(), (Set<String>) fflib_Match.anyObject(), (Set<String>) fflib_Match.anyObject()))
                .thenReturn(new List<Contact> {bankContact});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(contactsSel);
        ORG_Application.unitOfWork.setMock(uowMock);

        Case newCase =new Case(Subject = TEST_CASE_SUBJECT);
        Test.startTest();
        OSB_SRV_NewCase.newInstance().saveCaseInGuestContext(newCase, idNumber, passportNumber, uowMock);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerNew((Case) argument.capture());
        Case createdCase = (Case) argument.getValue();
        System.assertEquals(createdCase.RecordTypeId, UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_USER_CASE));
    }
}