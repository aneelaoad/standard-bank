/**
 * Test class for EAP_CTRL_ItineraryPage
 * <br/>SFP-7066
 *
 * @author The Cocktail
 * @date August 2021
 * @description Test class for EAP_CTRL_ItineraryPage
 */
@isTest
private class EAP_CTRL_ItineraryPage_TEST {
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
        }

        BLD_EAP_AppEvent bldAppEvent = new BLD_EAP_AppEvent(uow);
        uow.commitWork();

        BLD_EAP_Meeting bldMeeting = new BLD_EAP_Meeting(uow).event(bldAppEvent);
        uow.commitWork();

        BLD_EAP_AppEventAttendee bldAttendee = new BLD_EAP_AppEventAttendee(uow)
            .event(bldAppEvent)
            .contactId(testContact.Id);
        uow.commitWork();

        new BLD_EAP_Attendance(uow)
            .meeting(bldMeeting)
            .attendee(bldAttendee);
        uow.commitWork();

        BLD_EAP_TravelInformation bldTravelInformation = new BLD_EAP_TravelInformation(uow)
            .useFlight()
            .attendee(bldAttendee);
        uow.commitWork();

        new BLD_EAP_TravelInformation(uow)
            .useShuttle()
            .attendee(bldAttendee);
        uow.commitWork();

        new BLD_EAP_TravelInformation(uow)
            .useShuttle()
            .attendee(bldAttendee);
        uow.commitWork();

        BLD_EAP_Document bldDocument = new BLD_EAP_Document(uow)
            .event(bldAppEvent)
            .travel(bldTravelInformation);
        uow.commitWork();

        new BLD_ContentVersion(uow)
            .document(bldDocument)
            .getRecord();
        uow.commitWork();

        BLD_EAP_Document bldDocumentFlightTicket = new BLD_EAP_Document(uow)
            .event(bldAppEvent)
            .travel(bldTravelInformation)
            .flightTicketDocument();
        uow.commitWork();

        new BLD_ContentVersion(uow)
            .document(bldDocumentFlightTicket)
            .getRecord();
        uow.commitWork();
    }

    /**
    * @description To test getDocuments
    * @author The Cocktail
    **/
    @isTest
    static void testItineraryPageDocuments(){
        List<EAP_Document__c> result;
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_ItineraryPage.getDocuments(event.Id);
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(1, result.size(), 'Result size is 1');
    }

    /**
    * @description To test getItinerary
    * @author The Cocktail
    **/
    @isTest
    static void testItineraryPageItinerary(){
        List<EAP_TravelInformation__c> result;
        EAP_AppEvent__c eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_ItineraryPage.getItinerary(eventList.Id);
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(3, result.size(), 'Result size is 3');
    }

    /**
    * @description To test getTravel
    * @author The Cocktail
    **/
    @isTest
    static void testItineraryPageTravel(){
        EAP_TravelInformation__c result;
        List<EAP_TravelInformation__c> travelList = [SELECT Id FROM EAP_TravelInformation__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_ItineraryPage.getTravel(travelList.get(0).Id);
        }
        Test.stopTest();
        System.assert(result != null, 'Result is not null');
    }

    /**
    * @description To test getBoardingPass
    * @author The Cocktail
    **/
    @isTest
    static void testItineraryPageBoardingPass(){
        EAP_Document__c result;
        EAP_TravelInformation__c travel = [SELECT Id FROM EAP_TravelInformation__c WHERE Name = '0testEAP_Event0' LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_ItineraryPage.getBoardingPass(travel.Id);
        }
        Test.stopTest();
        System.assert(result != null, 'Result is not null');
    }

    /**
    * @description To test getClassTravel
    * @author The Cocktail
    **/
    @isTest
    static void testItineraryPageClassTravel(){
        List<String> result;
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_ItineraryPage.getClassTravel();
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(4, result.size(), 'Result size is 4');
    }

    /**
    * @description To test getCountryPicklist
    * @author The Cocktail
    **/
    @isTest
    static void testItineraryPageCountryPicklist(){
        List<String> result;
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_ItineraryPage.getCountryPicklist();
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(209, result.size(), 'Result size is 209');
    }

    /**
    * @description To test insertTravel
    * @author The Cocktail
    **/
    @isTest
    static void testItineraryPageInsertTravel(){
        List<EAP_TravelInformation__c> result;
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        String flightToInsert = '{"TravelName":"TestFlightName","StartDate":"2021-08-18","Departure":"12:00","EndDate":"2021-08-20","Arrival":"13:45","Airline":"TestAirline","Origin":"Test Origin","Destination":"Test Destination","FlightNumber":"12345FN", "SeatNumber":"1A", "FlightClass": "Economy", "Address": "Aeropuerto Barajas", "Country": "Spain", "City": "Madrid", "OriginCountry": "Spain", "OriginCity": "Barcelona", "OriginAddress": "Aeropuerto Josep Tarradellas Barcelona-El Prat"}';
        String shuttleToInsert = '{"TravelName":"TestShuttleName","StartDate":"2021-08-18","Departure":"12:00","EndDate":"2021-08-20","Arrival":"13:45","Origin":"Test Origin","Destination":"Test Destination", "Company": "TestCompany", "Service": "Car", "Address": "Atocha", "Country": "Spain", "City": "Madrid", "OriginCountry": "Spain", "OriginCity": "Barcelona", "OriginAddress": "Estacion de Francia"}';
        Test.startTest();
        System.runAs(testUser) {
            EAP_CTRL_ItineraryPage.insertTravel(event.Id, flightToInsert);
            EAP_CTRL_ItineraryPage.insertTravel(event.Id, shuttleToInsert);
        }
        Test.stopTest();
        result = [SELECT Id FROM EAP_TravelInformation__c WHERE Name = 'TestFlightName'];
        System.assert(result != null, 'Result is not null');
        result = [SELECT Id FROM EAP_TravelInformation__c WHERE Name = 'TestShuttleName'];
        System.assert(result != null, 'Result is not null');
    }
}