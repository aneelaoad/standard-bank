/**
 * Test class for DMN_CallReportAttendee
 *
 * @author Omar Berraj
 * @Date August 2020
 *
 * @ Last Modified By  : Collen Phundulu
 * @ Last Modified On  : Thursday 18, 2024
 * @ Modification Description : SFP-32369: Added test method DMN_CallReportAttendee.isAttendeeTxB
 */
@IsTest (IsParallel = true)
private class DMN_CallReportAttendee_Test {

    @IsTest
    public static void shouldUpdateEventReportCSuiteFlagToChecked() {

        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts contactSelectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);

        Contact testContact = (Contact) new BLD_Contact().contactCategory('CEO').mock();
        Call_Report_Attendees__c testAttendee = (Call_Report_Attendees__c) new BLD_CallReportAttendee()
                .contactId(testContact.Id)
                .callReport(new BLD_CallReport())
                .mock();

        // Given
        mocks.startStubbing();
        mocks.when(contactSelectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactSelectorMock.selectById(new Set<Id> { testContact.Id })).thenReturn( new List<Contact> { testContact });
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.selector.setMock(contactSelectorMock);

        // When
        Test.startTest();
        DMN_CallReportAttendee.updateEventReportCSuiteFlag(new Call_Report_Attendees__c[] { testAttendee });
        Test.stopTest();

        // Then
        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(Call_Report__c.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty((Call_Report__c) argument.capture());
        Call_Report__c updatedCallReport = (Call_Report__c) argument.getValue();
        Assert.areEqual(true, updatedCallReport.C_Suite_Attendance__c,'Should be true');
    }

    @IsTest
    public static void shouldUpdateEventReportCSuiteFlagToUnchecked() {

        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts contactSelectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);

        Contact testContact = (Contact) new BLD_Contact().contactCategory('Develop').mock();
        Call_Report_Attendees__c testAttendee = (Call_Report_Attendees__c) new BLD_CallReportAttendee()
                .contactId(testContact.Id)
                .callReport(new BLD_CallReport())
                .mock();

        // Given
        mocks.startStubbing();
        mocks.when(contactSelectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactSelectorMock.selectById(new Set<Id> { testContact.Id })).thenReturn( new List<Contact> { testContact });
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.selector.setMock(contactSelectorMock);

        // When
        Test.startTest();
        DMN_CallReportAttendee.updateEventReportCSuiteFlag(new Call_Report_Attendees__c[] { testAttendee });
        Test.stopTest();

        // Then
        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(Call_Report__c.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 0)).registerDirty((Call_Report__c) argument.capture());
        Call_Report__c updatedCallReport = (Call_Report__c) argument.getValue();
        Assert.areEqual(null, updatedCallReport, 'Should be null');
    }
    @IsTest
    public static void shouldUpdateTxBEventReport() {

        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        SEL_Contacts contactSelectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        SEL_CallReportAttendees callReportAttendeesSelectorMock = (SEL_CallReportAttendees) mocks.mock(SEL_CallReportAttendees.class);
        SEL_Users userSelectorMock = (SEL_Users) mocks.mock(SEL_Users.class);
		
        // Create test data
        Contact testContact = (Contact) new BLD_Contact().mock();

        User testUser = (User) new BLD_User()
            .userDivision('Transactional Products and Services')
            .contactSyncId(testContact.Id).mock();

        Call_Report_Attendees__c testAttendee = (Call_Report_Attendees__c) new BLD_CallReportAttendee()
                .contactId(testUser.Contact_Sync_ID__c)
                .callReport(new BLD_CallReport())
                .mock();
	
        // Given
        mocks.startStubbing();
        
        mocks.when(userSelectorMock.sObjectType()).thenReturn(User.SObjectType);
        mocks.when(userSelectorMock.selectByContactSyncId(new Set<Id> {testContact.Id})).thenReturn( new List<User> { testUser } );
        
        mocks.stopStubbing();

        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.selector.setMock(userSelectorMock);

        // When
        Test.startTest();
        DMN_CallReportAttendee.isAttendeeTxB(new List<Call_Report_Attendees__c> { testAttendee });
        Test.stopTest();

        // Then
        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(Call_Report__c.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty((Call_Report__c) argument.capture());
        Call_Report__c updatedCallReport = (Call_Report__c) argument.getValue();
        Assert.areEqual(true, updatedCallReport.Share_With_Global_TxB_Heads__c, 'Should be true');
    }
    
   
}