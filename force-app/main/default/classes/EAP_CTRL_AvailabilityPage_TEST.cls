/**
 * Test class for EAP_CTRL_AvailabilityPage
 * <br/>SFP-7976
 *
 * @author The Cocktail
 * @date October 2021
 * @description Test class for EAP_CTRL_AvailabilityPage
 */
@isTest
private with sharing class EAP_CTRL_AvailabilityPage_TEST {
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
     * @author TCK
     * @description Test setup
     */    
    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        Contact eventUserContact = (Contact) new BLD_Contact(uow)
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

            BLD_EAP_AppEventAttendee bldAttendee = new BLD_EAP_AppEventAttendee(uow)
                .event(bldAppEvent)
                .contactId(testContact.Id)
                .rolInEvent('Investor');
            uow.commitWork();

            new BLD_EAP_AppEventAttendee(uow)
                .event(bldAppEvent)
                .contactId(eventUserContact.Id)
                .rolInEvent('Corporate');
            uow.commitWork();

            new BLD_EAP_MeetingAvailability(uow)
                .attendee(bldAttendee);
            uow.commitWork();
        }
    }

    /**
    * @description To test saveAvailability with availability being 'morning'
    * @author The Cocktail
    **/
    @isTest
    static void testAvailabilityPageSaveMorning(){
        List<EAP_MeetingAvailability__c> resultAvailability;
        List<EAP_Attendance__c> resultAttendance;
        List<EAP_AppEvent__c> eventList = [SELECT Id, EAP_StartMeetingTime__c FROM EAP_AppEvent__c LIMIT 1];
        List<EAP_Attendee__c> corporateList = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c =: 'Corporate' LIMIT 1];
        Long availabilityDate = eventList.get(0).EAP_StartMeetingTime__c.getTime();

        //Testing on morning
        String availabilityToInsert = '[{"DateToInsert":"' + availabilityDate + '","Availability":"morning"}]';
        String attendanceToInsert = '[{"id":"' + corporateList.get(0).Id + '","name":"TestCorporate","clientName":"TestClient", "isSelected":true, "preference":"1"}]';

        Test.startTest();
        System.runAs(testUser) {
            EAP_CTRL_AvailabilityPage.saveAvailability(eventList.get(0).Id, availabilityToInsert, attendanceToInsert);
        }
        Test.stopTest();
        resultAvailability = [SELECT Id, EAP_StartDate__c FROM EAP_MeetingAvailability__c];
        System.assert(!resultAvailability.isEmpty(), 'Availability is not empty');
        System.assertEquals(3, resultAvailability.size(), 'Availability size is 3');
        System.assertEquals(eventList.get(0).EAP_StartMeetingTime__c, resultAvailability.get(0).EAP_StartDate__c, 'Availability date is correct');

        resultAttendance = [SELECT Id, EAP_TargetAttendee__c FROM EAP_Attendance__c];
        System.assert(!resultAttendance.isEmpty(), 'Attendance is not empty');
        System.assertEquals(1, resultAttendance.size(), 'Attendance is not empty');
        System.assertEquals(corporateList.get(0).Id, resultAttendance.get(0).EAP_TargetAttendee__c, 'Attendance is correct');
    }

    /**
    * @description To test saveAvailability with availability being 'afternoon'
    * @author The Cocktail
    **/
    @isTest
    static void testAvailabilityPageSaveAfternoon(){
        List<EAP_MeetingAvailability__c> resultAvailability;
        List<EAP_AppEvent__c> eventList = [SELECT Id, EAP_StartMeetingTime__c, LastModifiedById FROM EAP_AppEvent__c LIMIT 1];
        List<EAP_Attendee__c> corporateList = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c =: 'Corporate' LIMIT 1];
        User eventUserModifier = SEL_Users.newInstance().selectWithContactSyncFieldById(eventList.get(0).LastModifiedById);
        TimeZone eventUserModifierTimeZone = TimeZone.getTimezone(eventUserModifier.TimeZoneSidKey);
        Integer offsetEvent = eventUserModifierTimeZone.getOffset(eventList.get(0).EAP_StartMeetingTime__c)/(1000*60*60);
        Integer noon = 12 - offsetEvent;
        Long availabilityDate = eventList.get(0).EAP_StartMeetingTime__c.getTime();

        //Testing on morning
        String availabilityToInsert = '[{"DateToInsert":"' + availabilityDate + '","Availability":"afternoon"}]';
        String attendanceToInsert = '[{"id":"' + corporateList.get(0).Id + '","name":"TestCorporate","clientName":"TestClient", "isSelected":true, "preference":"1"}]';

        Test.startTest();
        System.runAs(testUser) {
            EAP_CTRL_AvailabilityPage.saveAvailability(eventList.get(0).Id, availabilityToInsert, attendanceToInsert);
        }
        Test.stopTest();
        resultAvailability = [SELECT Id, EAP_StartDate__c FROM EAP_MeetingAvailability__c];
        System.assert(!resultAvailability.isEmpty() ,'Availability is not empty');
        System.assertEquals(4, resultAvailability.size() ,'Availability should have 4 records');
        System.assertEquals(noon, resultAvailability.get(0).EAP_StartDate__c.hourGMT(), 'Availability should be at noon');
    }

    /**
    * @description To test saveAvailability with availability being 'all day'
    * @author The Cocktail
    **/
    @isTest
    static void testAvailabilityPageSaveAllDay(){
        List<EAP_MeetingAvailability__c> resultAvailability;
        List<EAP_AppEvent__c> eventList = [SELECT Id, EAP_StartMeetingTime__c FROM EAP_AppEvent__c LIMIT 1];
        List<EAP_Attendee__c> corporateList = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c =: 'Corporate' LIMIT 1];
        Long availabilityDate = eventList.get(0).EAP_StartMeetingTime__c.getTime();

        //Testing on morning
        String availabilityToInsert = '[{"DateToInsert":"' + availabilityDate + '","Availability":"allDay"}]';
        String attendanceToInsert = '[{"id":"' + corporateList.get(0).Id + '","name":"TestCorporate","clientName":"TestClient", "isSelected":true, "preference":"1"}]';

        Test.startTest();
        System.runAs(testUser) {
            EAP_CTRL_AvailabilityPage.saveAvailability(eventList.get(0).Id, availabilityToInsert, attendanceToInsert);
        }
        Test.stopTest();
        resultAvailability = [SELECT Id, EAP_StartDate__c FROM EAP_MeetingAvailability__c];
        System.assert(!resultAvailability.isEmpty() ,'Availability is not empty');
        System.assertEquals(7, resultAvailability.size() ,'Availability should have 7 records');
        System.assertEquals(eventList.get(0).EAP_StartMeetingTime__c, resultAvailability.get(0).EAP_StartDate__c , 'Start meeting time should be the same as start date time');
    }

    /**
    * @description To test getAvailability
    * @author The Cocktail
    **/
    @isTest
    static void testAvailabilityPageAvailability(){
        Map<Datetime, EAP_CTRL_AvailabilityPage.AvailabilityWrapper> result;
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_AvailabilityPage.getAvailability(eventList.get(0).Id);
        }
        Test.stopTest();
        System.assert(result != null, 'Availability is not null');
    }

    /**
    * @description To test getRoleEvent
    * @author The Cocktail
    **/
    @isTest
    static void testAvailabilityPageRoleEvent(){
        String result;
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_AvailabilityPage.getRoleEvent(eventList.get(0).Id);
        }
        Test.stopTest();
        System.assert(result != null, 'Role event is not null');
        System.assertEquals('Investor', result, 'Role event should be Investor');

    }

    /**
    * @description To test getCorporates
    * @author The Cocktail
    **/
    @isTest
    static void testAvailabilityPageCorporates(){
        List<EAP_CTRL_AvailabilityPage.CorporatesWrapper> result;
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_AvailabilityPage.getCorporates(eventList.get(0).Id);
        }
        Test.stopTest();
        System.assert(result != null, 'Corporates is not null');
        System.assertEquals(1, result.size(), 'Corporates should have 1 record');
    }
    
}