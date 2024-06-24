/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 11-07-2022
 * @last modified by  : TCK
**/
@isTest
private class EAP_BATCH_MatchmakingAlgorithm_TEST {
    private static final Integer NUM_DATA = 100;
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
            .businessInterests('Africa')
            .interests('Baseball');
        UOW.commitWork();

        User eventAdmin;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            eventAdmin = (User) new BLD_USER(UOW)
                .useSysAdmin()
                .firstName(TEST_ADMIN_NAME)
                .getRecord();
            new BLD_USER(UOW)
                .profile(COMMUNITY_EVENTS)
                .userName(TEST_USER_NAME)
                .email(testContact.Email)
                .firstName(TEST_CONTACT_FIRST_NAME)
                .lastName(TEST_CONTACT_LAST_NAME)
                .contactId(testContact.Id)
                .contactSyncId(testContact.Id);
        }

        BLD_EAP_AppEvent bldAppEvent = new BLD_EAP_AppEvent(UOW);

        for (Integer i = 0; i < NUM_DATA; i++) {
            new BLD_EAP_AppEventAttendee(UOW)
                .event(bldAppEvent)
                .contactId(testContact.Id)
                .tierLevel('1')
                .rolInEvent(DMN_EAP_Attendee.ROL_INVESTOR);
        }

        for (Integer i = 0; i < NUM_DATA; i++) {
            new BLD_EAP_AppEventAttendee(UOW)
                .event(bldAppEvent)
                .contactId(testContact.Id)
                .rolInEvent(DMN_EAP_Attendee.ROL_CORPORATE);
        }

        UOW.commitWork();
        List<EAP_Attendee__c> corporates = [SELECT Id, Name, EAP_AppEvent__c FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_CORPORATE];

        List<EAP_Attendee__c> attList = new List<EAP_Attendee__c>();
        for (EAP_Attendee__c corp : corporates) {
            EAP_Attendee__c att = new EAP_Attendee__c(EAP_CorporateAssociated__c = corp.Id, EAP_AppEvent__c = corp.EAP_AppEvent__c, EAP_Contact__c = testContact.Id, EAP_RoleEvent__c = DMN_EAP_Attendee.ROL_CORPORATE_ASSOCIATED);
            attList.add(att);
        }
        insert attList;

    }

    /**
    * @description  Every Investor get a meeting with a corporate
    * @author TCK | 10-28-2021 
    **/
    @isTest
    static void testMatchmakingBasic() {
        String groupName = DMN_EAP_Meeting.GROUP_PREFIX+'%';
        List<EAP_Attendance__c> resultAttendance = new List<EAP_Attendance__c>();
        List<Group> orGroups =[SELECT Id FROM Group WHERE Name LIKE :groupName];
        List<Group> groups = new List<Group>();
        List<EAP_Meeting__c> resultMeeting = new List<EAP_Meeting__c>();
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        List<EAP_Attendee__c> investors = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_INVESTOR];
        List<EAP_Attendee__c> corporates = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_CORPORATE];

        for (Integer i = 0; i < NUM_DATA; i++) {
            new BLD_EAP_Attendance(UOW)
                .attendee(investors.get(i).Id)
                .requestFrom(investors.get(i).Id)
                .targetAttendee(corporates.get(i).Id)
                .preference(1);

            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(investors.get(i).Id);

            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(corporates.get(i).Id);
        }
        UOW.commitWork();

        Test.startTest();
            EAP_BATCH_MatchmakingAlgorithm matchmaking = new EAP_BATCH_MatchmakingAlgorithm(event.Id);
            DataBase.executeBatch(matchmaking); 
        Test.stopTest();

        resultAttendance = [SELECT Id FROM EAP_Attendance__c];
        resultMeeting = [SELECT Id FROM EAP_Meeting__c WHERE EAP_AppEvent__c =: event.Id];
        groups = [SELECT Id FROM Group WHERE Name LIKE :groupName];
        if (groups.size() > 0){
            List<GroupMember> groupMembers = [SELECT Id FROM GroupMember WHERE GroupId = :groups.get(0).Id];
            System.assert(groupMembers.size() >= 0, 'Less group members size than expected');
            System.assert(groups.size() > 0, 'Less groups size than expected');
            System.assertEquals(100, groups.size()-orGroups.size(), 'Different groups size than expected. Actual: ' + (groups.size()-orGroups.size()));
        }
        System.assert(resultAttendance != null, 'The result attendance shouldn\'t be null');
        System.assertEquals((NUM_DATA*3), resultAttendance.size(), 'Different attendance size than expected');
        System.assert(resultMeeting != null, 'The result meeting shouldn\'t be null');
        System.assertEquals(NUM_DATA, resultMeeting.size(), 'Different meeting size than expected');
    }

    /**
    * @description Corporate's meeting availability is on afternoon while the investor's on morning
    * @author TCK | 10-28-2021 
    **/
    @isTest
    static void testMatchmakingDoesntMatch() {
        List<EAP_Attendance__c> resultAttendance = new List<EAP_Attendance__c>();
        List<EAP_Meeting__c> resultMeeting = new List<EAP_Meeting__c>();
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        List<EAP_Attendee__c> investors = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_INVESTOR];
        List<EAP_Attendee__c> corporates = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_CORPORATE];

        for (Integer i = 0; i < NUM_DATA; i++) {
            new BLD_EAP_Attendance(UOW)
                .attendee(investors.get(i).Id)
                .requestFrom(investors.get(i).Id)
                .targetAttendee(corporates.get(i).Id)
                .preference(1);

            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(investors.get(i).Id);

            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(corporates.get(i).Id)
                .afternoon();
        }
        UOW.commitWork();

        Test.startTest();
            EAP_BATCH_MatchmakingAlgorithm matchmaking = new EAP_BATCH_MatchmakingAlgorithm(event.Id);
            DataBase.executeBatch(matchmaking); 
        Test.stopTest();

        resultAttendance = [SELECT Id FROM EAP_Attendance__c];
        resultMeeting = [SELECT Id FROM EAP_Meeting__c WHERE EAP_AppEvent__c =: event.Id];
        System.assert(resultAttendance != null, 'Result attendance shouldn\t be null');
        System.assertEquals(NUM_DATA, resultAttendance.size(), 'Different attendance size than expected');
        System.assertEquals(0, resultMeeting.size(), 'Different meetings size than expected');
    }

    /**
    * @description Corporate has no meeting availability
    * @author TCK | 10-28-2021 
    **/
    @isTest
    static void testMatchmakingNoAvailabilityCorporate() {
        List<EAP_Attendance__c> resultAttendance = new List<EAP_Attendance__c>();
        List<EAP_Meeting__c> resultMeeting = new List<EAP_Meeting__c>();
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        List<EAP_Attendee__c> investors = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_INVESTOR];
        List<EAP_Attendee__c> corporates = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_CORPORATE];

        for (Integer i = 0; i < NUM_DATA; i++) {
            new BLD_EAP_Attendance(UOW)
                .attendee(investors.get(i).Id)
                .requestFrom(investors.get(i).Id)
                .targetAttendee(corporates.get(i).Id)
                .preference(1);

            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(investors.get(i).Id);
        }
        UOW.commitWork();

        Test.startTest();
            EAP_BATCH_MatchmakingAlgorithm matchmaking = new EAP_BATCH_MatchmakingAlgorithm(event.Id);
            DataBase.executeBatch(matchmaking); 
        Test.stopTest();

        resultAttendance = [SELECT Id FROM EAP_Attendance__c];
        resultMeeting = [SELECT Id FROM EAP_Meeting__c WHERE EAP_AppEvent__c =: event.Id];
        System.assert(resultAttendance != null, 'Result attendance shouldn\t be null');
        System.assertEquals(NUM_DATA, resultAttendance.size(), 'Different attendance size than expected');
        System.assertEquals(0, resultMeeting.size(), 'Different meetings size than expected');
    }

    /**
    * @description Investor has no meeting availability
    * @author TCK | 10-28-2021 
    **/
    @isTest
    static void testMatchmakingNoAvailabilityInvestor() {
        List<EAP_Attendance__c> resultAttendance = new List<EAP_Attendance__c>();
        List<EAP_Meeting__c> resultMeeting = new List<EAP_Meeting__c>();
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        List<EAP_Attendee__c> investors = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_INVESTOR];
        List<EAP_Attendee__c> corporates = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_CORPORATE];

        for (Integer i = 0; i < NUM_DATA; i++) {
            new BLD_EAP_Attendance(UOW)
                .attendee(investors.get(i).Id)
                .requestFrom(investors.get(i).Id)
                .targetAttendee(corporates.get(i).Id)
                .preference(1);

            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(corporates.get(i).Id);
        }
        UOW.commitWork();

        Test.startTest();
            EAP_BATCH_MatchmakingAlgorithm matchmaking = new EAP_BATCH_MatchmakingAlgorithm(event.Id);
            DataBase.executeBatch(matchmaking); 
        Test.stopTest();

        resultAttendance = [SELECT Id FROM EAP_Attendance__c];
        resultMeeting = [SELECT Id FROM EAP_Meeting__c WHERE EAP_AppEvent__c =: event.Id];
        System.assert(resultAttendance != null, 'Result attendance shouldn\t be null');
        System.assertEquals(NUM_DATA, resultAttendance.size(), 'Different attendance size than expected');
        System.assertEquals(0, resultMeeting.size(), 'Different meetings size than expected');
    }

    /**
    * @description  Many corporates with different preference
    * @author TCK | 10-28-2021 
    **/
    @isTest
    static void testMatchmakingPreference() {
        List<EAP_Attendance__c> resultAttendance = new List<EAP_Attendance__c>();
        List<EAP_Meeting__c> resultMeeting = new List<EAP_Meeting__c>();
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        List<EAP_Attendee__c> investors = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_INVESTOR LIMIT 3];
        List<EAP_Attendee__c> corporates = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_CORPORATE LIMIT 3];

        for (Integer i = 0; i < 3; i++) {
            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(investors.get(i).Id);
            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(investors.get(i).Id)
                .afternoon();

            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(corporates.get(i).Id);
            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(corporates.get(i).Id)
                .afternoon();
        }

        for (Integer i = 0; i < 3; i++) {
            for (Integer t = 0; t < 3; t++) {
                new BLD_EAP_Attendance(UOW)
                .attendee(investors.get(i).Id)
                .requestFrom(investors.get(i).Id)
                .targetAttendee(corporates.get(t).Id)
                .preference((t+1));
            }
        }
        UOW.commitWork();

        Test.startTest();
            EAP_BATCH_MatchmakingAlgorithm matchmaking = new EAP_BATCH_MatchmakingAlgorithm(event.Id);
            DataBase.executeBatch(matchmaking); 
        Test.stopTest();

        resultAttendance = [SELECT Id FROM EAP_Attendance__c];
        resultMeeting = [SELECT Id FROM EAP_Meeting__c WHERE EAP_AppEvent__c =: event.Id];
        System.assert(resultAttendance != null, 'Result attendance shouldn\t be null');
        System.assertEquals(19, resultAttendance.size(), 'Different attendance size than expected');
        System.assert(resultMeeting != null, 'Result meeting shouldn\t be null');
        System.assertEquals(5, resultMeeting.size(), 'Different meetings size than expected');
    }

    /**
    * @description  Event accepts 2 gold attendees per meeting
    * @author TCK | 10-28-2021 
    **/
    @isTest
    static void testMatchmakingGoldTier() {
        List<EAP_Attendance__c> resultAttendance = new List<EAP_Attendance__c>();
        List<EAP_Meeting__c> resultMeeting = new List<EAP_Meeting__c>();
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        List<EAP_Attendee__c> investors = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_INVESTOR LIMIT 3];
        List<EAP_Attendee__c> corporates = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_CORPORATE LIMIT 3];

        event.EAP_GoldPerMeeting__c = 2;
        update event;
        for (Integer i = 0; i < 3; i++) {
            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(investors.get(i).Id);
            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(investors.get(i).Id)
                .afternoon();

            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(corporates.get(i).Id);
            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(corporates.get(i).Id)
                .afternoon();
        }

        for (Integer i = 0; i < 3; i++) {
            for (Integer t = 0; t < 3; t++) {
                new BLD_EAP_Attendance(UOW)
                .attendee(investors.get(i).Id)
                .requestFrom(investors.get(i).Id)
                .targetAttendee(corporates.get(t).Id)
                .preference((t+1));
            }
        }
        UOW.commitWork();

        Test.startTest();
            EAP_BATCH_MatchmakingAlgorithm matchmaking = new EAP_BATCH_MatchmakingAlgorithm(event.Id);
            DataBase.executeBatch(matchmaking); 
        Test.stopTest();

        resultAttendance = [SELECT Id FROM EAP_Attendance__c];
        resultMeeting = [SELECT Id FROM EAP_Meeting__c WHERE EAP_AppEvent__c =: event.Id];
        System.assert(resultAttendance != null, 'Result attendance shouldn\t be null');
        System.assertEquals(17, resultAttendance.size(), 'Different attendance size than expected');
        System.assert(resultMeeting != null, 'Result meeting shouldn\t be null');
        System.assertEquals(4, resultMeeting.size(), 'Different meetings size than expected');
    }

    /**
    * @description  Many corporates with different preference while investors are silver tier
    * @author TCK | 10-28-2021 
    **/
    @isTest
    static void testMatchmakingSilverTier() {
        List<EAP_Attendance__c> resultAttendance = new List<EAP_Attendance__c>();
        List<EAP_Meeting__c> resultMeeting = new List<EAP_Meeting__c>();
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        List<EAP_Attendee__c> investors = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_INVESTOR LIMIT 3];
        List<EAP_Attendee__c> corporates = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_CORPORATE LIMIT 3];

        for (Integer i = 0; i < 3; i++) {
            investors.get(i).EAP_TierLevel__c = '2';

            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(investors.get(i).Id);
            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(investors.get(i).Id)
                .afternoon();

            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(corporates.get(i).Id);
            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(corporates.get(i).Id)
                .afternoon();
        }

        for (Integer i = 0; i < 3; i++) {
            for (Integer t = 0; t < 3; t++) {
                new BLD_EAP_Attendance(UOW)
                .attendee(investors.get(i).Id)
                .requestFrom(investors.get(i).Id)
                .targetAttendee(corporates.get(t).Id)
                .preference((t+1));
            }
        }
        update investors;
        update corporates;
        UOW.commitWork();

        Test.startTest();
            EAP_BATCH_MatchmakingAlgorithm matchmaking = new EAP_BATCH_MatchmakingAlgorithm(event.Id);
            DataBase.executeBatch(matchmaking); 
        Test.stopTest();

        resultAttendance = [SELECT Id FROM EAP_Attendance__c];
        resultMeeting = [SELECT Id FROM EAP_Meeting__c WHERE EAP_AppEvent__c =: event.Id];
        System.assert(resultAttendance != null, 'Result attendance shouldn\t be null');
        System.assertEquals(17, resultAttendance.size(), 'Different attendance size than expected');
        System.assert(resultMeeting != null, 'Result meeting shouldn\t be null');
        System.assertEquals(4, resultMeeting.size(), 'Different meetings size than expected');
    }

    /**
    * @description  Many corporates with different preference while investors are bronze tier
    * @author TCK | 10-28-2021 
    **/
    @isTest
    static void testMatchmakingBronzeTier() {
        List<EAP_Attendance__c> resultAttendance = new List<EAP_Attendance__c>();
        List<EAP_Meeting__c> resultMeeting = new List<EAP_Meeting__c>();
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        List<EAP_Attendee__c> investors = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_INVESTOR LIMIT 3];
        List<EAP_Attendee__c> corporates = [SELECT Id, Name FROM EAP_Attendee__c WHERE Name LIKE '%testEAP_Attendee__c%' AND EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_CORPORATE LIMIT 3];

        for (Integer i = 0; i < 3; i++) {
            investors.get(i).EAP_TierLevel__c = '3';

            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(investors.get(i).Id);
            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(investors.get(i).Id)
                .afternoon();

            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(corporates.get(i).Id);
            new BLD_EAP_MeetingAvailability(UOW)
                .attendee(corporates.get(i).Id)
                .afternoon();
        }

        for (Integer i = 0; i < 3; i++) {
            for (Integer t = 0; t < 3; t++) {
                new BLD_EAP_Attendance(UOW)
                .attendee(investors.get(i).Id)
                .requestFrom(investors.get(i).Id)
                .targetAttendee(corporates.get(t).Id)
                .preference((t+1));
            }
        }
        update investors;
        update corporates;
        UOW.commitWork();

        Test.startTest();
            EAP_BATCH_MatchmakingAlgorithm matchmaking = new EAP_BATCH_MatchmakingAlgorithm(event.Id);
            DataBase.executeBatch(matchmaking); 
        Test.stopTest();

        resultAttendance = [SELECT Id FROM EAP_Attendance__c];
        resultMeeting = [SELECT Id FROM EAP_Meeting__c WHERE EAP_AppEvent__c =: event.Id];
        System.assert(resultAttendance != null, 'Result attendance shouldn\t be null');
        System.assertEquals(13, resultAttendance.size(), 'Different attendance size than expected');
        System.assert(resultMeeting != null, 'Result meeting shouldn\t be null');
        System.assertEquals(2, resultMeeting.size(), 'Different meetings size than expected');
    }
}