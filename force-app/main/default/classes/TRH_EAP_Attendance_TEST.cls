/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
@isTest
private class TRH_EAP_Attendance_TEST {
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
    public static final fflib_SObjectUnitOfWork UOW = ABS_ObjectBuilderBase.getNewUnitOfWork();

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

    @TestSetup
    static void setup() {
        new BLD_Contact(UOW)
            .name(TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME)
            .communityAccessManager(new BLD_Contact(UOW).communityAccessRole(TEST_CONTACT_ACCESS_ROLE))
            .email(TEST_CONTACT_EMAIL)
            .ownerId(UserInfo.getUserId())
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
            .pingId(TEST_CONTACT_PING_ID)
            .account(new BLD_Account(UOW))
            .getRecord();
        UOW.commitWork();

        User eventAdmin;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            eventAdmin = (User) new BLD_USER(UOW)
                .useSysAdmin()
                .firstName(TEST_ADMIN_NAME)
                .getRecord();
            User communityUser = (User) new BLD_USER(UOW)
                .profile(COMMUNITY_EVENTS)
                .userName(TEST_USER_NAME)
                .email(testContact.Email)
                .firstName(TEST_CONTACT_FIRST_NAME)
                .lastName(TEST_CONTACT_LAST_NAME)
                .contactId(testContact.Id)
                .contactSyncId(testContact.Id)
                .getRecord();
            UOW.commitWork();

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'EAP_EventAppCommunityPermission'];
            insert new PermissionSetAssignment(AssigneeId = communityUser.id, PermissionSetId = ps.Id);

        }

        BLD_EAP_AppEvent bldAppEvent = new BLD_EAP_AppEvent(UOW);
        UOW.commitWork();

        BLD_EAP_Meeting bldMeeting = new BLD_EAP_Meeting(UOW)
            .event(bldAppEvent);
        UOW.commitWork();

        BLD_EAP_AppEventAttendee bldAttendee = new BLD_EAP_AppEventAttendee(UOW)
            .event(bldAppEvent)
            .contactId(testContact.Id);
        UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .meeting(bldMeeting)
            .attendee(bldAttendee);
        UOW.commitWork();
    }

    @isTest
    static void testAfterInsert(){
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        EAP_Meeting__c meeting = [SELECT Id FROM EAP_Meeting__c LIMIT 1];
        String groupName = DMN_EAP_Meeting.GROUP_PREFIX + meeting.Id;
        Group eventGroup = [SELECT Id, Name, Type FROM Group WHERE Name = :groupName LIMIT 1];
        List<GroupMember> resultMembers = new List<GroupMember>();
        EAP_MeetingAvailability__c resultAvailability;
        
        Test.startTest();
            BLD_EAP_AppEventAttendee attendee = new BLD_EAP_AppEventAttendee(UOW)
                .event(event.Id)
                .contactId(testContact.Id);
            UOW.commitWork();

            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(attendee);
            UOW.commitWork();

            EAP_MeetingAvailability__c ma = [SELECT Id, EAP_StartDate__c, EAP_EndDate__c FROM EAP_MeetingAvailability__c LIMIT 1];

            BLD_EAP_Meeting bldMeeting = new BLD_EAP_Meeting(UOW)
                .event(event.Id)
                .startDate(ma.EAP_StartDate__c)
                .endDate(ma.EAP_EndDate__c);
            UOW.commitWork();

            new BLD_EAP_Attendance(UOW)
                .meeting(bldMeeting)
                .attendee(attendee);
            UOW.commitWork();
        Test.stopTest();

        resultMembers = [SELECT Id FROM GroupMember WHERE GroupId = :eventGroup.Id];
        resultAvailability = [SELECT Id, EAP_Booked__c FROM EAP_MeetingAvailability__c LIMIT 1];
        System.assert(!resultMembers.isEmpty(), 'Result is not empty');
        System.assertEquals(1, resultMembers.size(), 'Result has one member');

        System.assertEquals(false, resultAvailability.EAP_Booked__c, 'Availability is booked');
    }

    @isTest
    static void testBeforeDelete(){
        EAP_Attendance__c attendance = [SELECT Id, EAP_Meeting__c FROM EAP_Attendance__c LIMIT 1];
        String groupName = DMN_EAP_Meeting.GROUP_PREFIX + attendance.EAP_Meeting__c;
        Group meetingGroup = [SELECT Id, Name, Type FROM Group WHERE Name = :groupName LIMIT 1];
        List<GroupMember> result = new List<GroupMember>();
        result = [SELECT Id FROM GroupMember WHERE GroupId = :meetingGroup.Id];
        Test.startTest();
            delete attendance;
        Test.stopTest();
        result = [SELECT Id FROM GroupMember WHERE GroupId = :meetingGroup.Id];
        System.assert(!result.isEmpty(), 'Result is not empty');
    }
}