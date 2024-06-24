/*
 * Test Class for EAP_CTRL_MeetingInformationPage
 * <br/>SFP-7079
 *
 * @author The Cocktail
 * @date July 2021
 */
@isTest
private class EAP_CTRL_MeetingInformationPage_TEST {
    private static final String TEST_USER_NAME = 'testsgfdgds646@test.com';
    private static final String TEST_ADMIN_NAME = 'testgfdgsd335dssfs@test.com';
    private static final String TEST_CONTACT_EMAIL = 'test@Contact.testcom';
    private static final String TEST_USER_FIRSTNAME = 'User';
    private static final String TEST_CONTACT_ACCESS_ROLE = 'Authorised Person';
    private static final String TEST_CONTACT_FIRST_NAME = 'Test';
    private static final String TEST_CONTACT_LAST_NAME = 'Manager';
    private static final String SOLUTION_URL_NAME = 'Solution';
    private static final String TEST_CONTACT_PING_ID = '123456789';

    public static final String COMMUNITY_EVENTS = DMN_Profile.EVENTS_APP_COMMUNITY;

    private static User testUser {
        get {
            if(testUser == null) {
                testUser = [SELECT Id, ContactId, Email, Phone, Name FROM User WHERE Username = :TEST_USER_NAME LIMIT 1];
            }
            return testUser;
        }
        set;
    }
    private static Contact testContact {
        get {
            if(testContact == null) {
                testContact = [SELECT Id, FirstName, LastName, Name, Email, Ping_Id__c FROM Contact WHERE Email = :TEST_CONTACT_EMAIL LIMIT 1];
            }
            return testContact;
        }
        set;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        new BLD_Contact(uow)
            .name(TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME)
            .communityAccessManager(new BLD_Contact(uow).communityAccessRole(TEST_CONTACT_ACCESS_ROLE))
            .email(TEST_CONTACT_EMAIL)
            .ownerId(UserInfo.getUserId())
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
            .pingId(TEST_CONTACT_PING_ID)
            .account(new BLD_Account(uow))
            .getRecord();
        uow.commitWork();

        User eventAdmin;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            eventAdmin = (User) new BLD_USER(uow)
                .useSysAdmin()
                .firstName(TEST_ADMIN_NAME)
                .getRecord();
            User communityUser = (User) new BLD_USER(uow)
                .profile(COMMUNITY_EVENTS)
                .userName(TEST_USER_NAME)
                .email(testContact.Email)
                .firstName(TEST_CONTACT_FIRST_NAME)
                .lastName(TEST_CONTACT_LAST_NAME)
                .contactId(testContact.Id)
                .contactSyncId(testContact.Id)
                .getRecord();
            uow.commitWork();

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'EAP_EventAppCommunityPermission'];
            insert new PermissionSetAssignment(AssigneeId = communityUser.id, PermissionSetId = ps.Id);

            BLD_EAP_AppEvent bldAppEvent = new BLD_EAP_AppEvent(uow);
            uow.commitWork();
            
            BLD_EAP_Meeting bldMeeting = new BLD_EAP_Meeting(uow).event(bldAppEvent);
            uow.commitWork();

            new BLD_EAP_Meeting(uow)
                .event(bldAppEvent)
                .meeting(bldMeeting);
            uow.commitWork();

            BLD_EAP_AppEventAttendee bldAttendee = new BLD_EAP_AppEventAttendee(uow)
                .event(bldAppEvent)
                .contactId(testContact.Id);
            uow.commitWork();

            new BLD_EAP_Attendance(uow)
                .meeting(bldMeeting)
                .attendee(bldAttendee);
            uow.commitWork();

            BLD_EAP_Document bldDocument = new BLD_EAP_Document(uow)
                .meeting(bldMeeting);
            uow.commitWork();

            new BLD_ContentVersion(uow)
                .document(bldDocument)
                .getRecord();
            uow.commitWork();

            ContentNote testContentNote = new ContentNote();
            testContentNote.Title = 'TestTitle';
            testContentNote.Content = Blob.valueOf('Testing Content');
            testContentNote.CreatedById = testUser.Id;
            insert testContentNote;

            EAP_Meeting__c meeting = [SELECT Id FROM EAP_Meeting__c WHERE EAP_Meeting__c = null LIMIT 1];
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = testContentNote.Id;
            link.LinkedEntityId = meeting.Id;
            link.ShareType = 'V';
            link.Visibility = 'AllUsers';
            insert link;

            ContentNote testContentNote2 = new ContentNote();
            testContentNote2.Title = 'TestTitle';
            testContentNote2.Content = Blob.valueOf('Testing Content');
            insert testContentNote2;

            ContentDocumentLink link2 = new ContentDocumentLink();
            link2.ContentDocumentId = testContentNote2.Id;
            link2.LinkedEntityId = meeting.Id;
            link2.ShareType = 'V';
            link2.Visibility = 'AllUsers';
            insert link2;

        }
    }

    /**
    * @description To test getMeetingOverview
    * @author TCK | 11-11-2021 
    **/
    @isTest
    static void testMeetingInfoPageOverview(){
        EAP_CTRL_MeetingInformationPage.Dates_Wrapper result;
        EAP_Meeting__c meeting = [SELECT Id FROM EAP_Meeting__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_MeetingInformationPage.getMeetingOverview(meeting.Id);
        }
        Test.stopTest();
        System.assert(result != null, 'Result is not null');
    }

    /**
    * @description To test getAttendance
    * @author TCK | 11-11-2021 
    **/
    @isTest
    static void testMeetingInfoPageAttendance(){
        List<EAP_CTRL_MeetingInformationPage.Attendees_Wrapper> result;
        EAP_Meeting__c meeting = [SELECT Id FROM EAP_Meeting__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_MeetingInformationPage.getAttendance(meeting.Id);
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(1, result.size(), 'Result size is 1');
    }

    /**
    * @description To test getAgenda
    * @author TCK | 11-11-2021 
    **/
    @isTest
    static void testMeetingInfoPageAgenda(){
        List<EAP_CTRL_MeetingInformationPage.Dates_Wrapper> result;
        EAP_Meeting__c meeting = [SELECT Id FROM EAP_Meeting__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_MeetingInformationPage.getAgenda(meeting.Id);
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(1, result.size(), 'Result size is 1');
    }

    /**
    * @description To test getDocuments
    * @author The Cocktail 
    **/
    @isTest
    static void testMeetingInfoPageDocuments(){
        List<EAP_Document__c> result;
        EAP_Meeting__c meeting = [SELECT Id FROM EAP_Meeting__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_MeetingInformationPage.getDocuments(meeting.Id);
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(1, result.size(), 'Result size is 1');
    }

    /**
    * @description To test insertNote
    * @author The Cocktail 
    **/
    @isTest
    static void testMeetingInfoInsertNotes(){
        ContentNote result;
        EAP_Meeting__c meeting = [SELECT Id FROM EAP_Meeting__c LIMIT 1];
        Test.startTest();
            //This should work with community User but error appears:
            /*
            System.DmlException: Insert failed. First exception on row 0; first error: INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY, You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.: [NetworkId]
            */
            EAP_CTRL_MeetingInformationPage.insertNote(meeting.Id, 'ClassTestTitle', 'Class Test Body Content');
        Test.stopTest();
        result = [SELECT Id, Content FROM ContentNote WHERE Title = 'ClassTestTitle' LIMIT 1];
        System.assert(result != null, 'Result is not null');
    }

    /**
    * @description To test getNotes
    * @author The Cocktail 
    **/
    @isTest
    static void testMeetingInfoPageGetNotes(){
        List<EAP_CTRL_MeetingInformationPage.Note_Wrapper> result;
        EAP_Meeting__c meeting = [SELECT Id FROM EAP_Meeting__c LIMIT 1];
        Test.startTest();
        result = EAP_CTRL_MeetingInformationPage.getNotes(meeting.Id);
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(1, result.size(), 'Result size is 1');
    }

    /**
    * @description To test updateNote
    * @author The Cocktail 
    **/
    @isTest
    static void testMeetingInfoPageUpdateNote(){
        ContentNote result;
        ContentNote note = [SELECT Id FROM ContentNote WHERE Title = 'TestTitle' LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            EAP_CTRL_MeetingInformationPage.updateNote(note.Id, 'TestTitleUpdate', 'Testing Content');
        }
        Test.stopTest();
        result = [SELECT Id, Title FROM ContentNote WHERE Id = :note.Id];
        System.assert(result != null, 'Result is not null');
        System.assertEquals('TestTitleUpdate', result.Title, 'Title is TestTitleUpdate');
    }
}