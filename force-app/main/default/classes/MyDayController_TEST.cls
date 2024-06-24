/**
 * Test class for MyDayController
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		December 2020
*/
@IsTest
public class MyDayController_TEST {

    private static final String ATTENDEE_USERNAME = 'attendeeUser@test.com';
    private static final String ADMIN_USERNAME = 'cdcCreationControllerSysAdmin@test.com';

    private static User attendeeUser;
    private static User sysAdminUser;

    @TestSetup
    static void setup() {

        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            attendeeUser = (User) new BLD_USER(uow)
                    .userName(ATTENDEE_USERNAME)
                    .useCib()
                    .division('Transactional Products and Services')
                    .syncContact()
                    .getRecord();
            sysAdminUser = (User) new BLD_USER(uow)
                    .lastName('SysAdmin')
                    .userName(ADMIN_USERNAME)
                    .useSysAdmin()
                    .syncContact()
                    .getRecord();
            uow.commitWork();
        }
    }

    static void getData() {
        for (User usr : [SELECT Username, Division, IsActive FROM User WHERE Username IN :new Set<String> {ATTENDEE_USERNAME, ADMIN_USERNAME}]) {
            if (usr.Username == ATTENDEE_USERNAME) {
                attendeeUser = usr;
            }
            else if (usr.Username == ADMIN_USERNAME) {
                sysAdminUser = usr;
            }
        }
    }

    @IsTest
    static void shouldGetViews() {
        MyDayController ctrl = new MyDayController();
        Integer expectedSize = 8;
        Test.startTest();
        Integer actualListSize = ctrl.getViews().size();
        Test.stopTest();
        System.assertEquals(expectedSize, actualListSize);
    }

    @IsTest
    static void shouldRefreshEventViewsToday() {
        getData();
        MyDayController ctrl = new MyDayController();
        ctrl.filterValue = 'Today';

        fflib_SObjectUnitOfWork uow;
        Call_Report__c originalEvent;
        Call_Report__c filterEvent;
        System.runAs(attendeeUser) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            originalEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('Original Event')
                    .startDate(System.now())
                    .endDate(System.now().addHours(1))
                    .addAttendee(
                            new BLD_CallReportAttendee(uow).contact(
                                    new BLD_Contact(uow).ownerId(attendeeUser.Id)
                            )
                    )
                    .getRecord();
            filterEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('Todays Event')
                    .startDate(System.now())
                    .endDate(System.now().addHours(1))
                    .assign(attendeeUser.Id)
                    .getRecord();
            uow.commitWork();

            Test.startTest();
            ctrl.refreshEventViews();
            Test.stopTest();
        }
        Map<Id, Call_Report__c> id2CreatedEvents = new Map<Id, Call_Report__c>{
                originalEvent.Id => originalEvent,
                filterEvent.Id => filterEvent
        };
        System.assertEquals(id2CreatedEvents.size(), ctrl.eventReportList.size());
        for (Call_Report__c event : ctrl.eventReportList) {
            System.assert(id2CreatedEvents.containsKey(event.Id));
        }
    }

    @IsTest
    static void shouldRefreshEventViewsAllMyEvents() {
        getData();
        MyDayController ctrl = new MyDayController();
        ctrl.filterValue = 'All My Events';

        fflib_SObjectUnitOfWork uow;
        Call_Report__c filterEvent;
        Call_Report__c originalEvent;
        System.runAs(sysAdminUser) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            originalEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('Original Event')
                    .startDate(System.now().addYears(-1).addDays(1))
                    .endDate(System.now().addYears(-1).addDays(1).addHours(1))
                    .addAttendee(
                            new BLD_CallReportAttendee(uow).contact(
                                    new BLD_Contact(uow).ownerId(sysAdminUser.Id)
                            )
                    )
                    .ownerId(attendeeUser.Id)
                    .assign(attendeeUser.Id)
                    .getRecord();
            filterEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('All My Events Event')
                    .startDate(System.now())
                    .endDate(System.now().addHours(1))
                    .assign(attendeeUser.Id)
                    .getRecord();
            uow.commitWork();

            Test.startTest();
            ctrl.refreshEventViews();
            Test.stopTest();
        }

        Map<Id, Call_Report__c> id2CreatedEvents = new Map<Id, Call_Report__c>{
                originalEvent.Id => originalEvent,
                filterEvent.Id => filterEvent
        };
        System.assertEquals(id2CreatedEvents.size(), ctrl.eventReportList.size());
        for (Call_Report__c event : ctrl.eventReportList) {
            System.assert(id2CreatedEvents.containsKey(event.Id));
        }
    }

    @IsTest
    static void shouldRefreshEventViewsAllMyEventReportsPreviousMonth() {
        getData();
        MyDayController ctrl = new MyDayController();
        ctrl.filterValue = 'My Event Reports Previous Month';

        fflib_SObjectUnitOfWork uow;
        Call_Report__c originalEvent;
        Call_Report__c filterEvent;
        Integer monthsToBeAdded = -1;

        System.runAs(attendeeUser) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            originalEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('Original Event')
                    .startDate(System.now().addMonths(monthsToBeAdded))
                    .endDate(System.now().addMonths(monthsToBeAdded).addHours(1))
                    .addAttendee(
                            new BLD_CallReportAttendee(uow).contact(
                                    new BLD_Contact(uow).ownerId(attendeeUser.Id)
                            )
                    )
                    .getRecord();

            filterEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('My Event Reports Previous Month Event')
                    .startDate(System.now().addMonths(-1))
                    .endDate(System.now().addMonths(-1).addHours(1))
                    .assign(attendeeUser.Id)
                    .getRecord();
            uow.commitWork();

            Test.startTest();
            ctrl.refreshEventViews();
            Test.stopTest();
        }
        Map<Id, Call_Report__c> id2CreatedEvents = new Map<Id, Call_Report__c>{
                originalEvent.Id => originalEvent,
                filterEvent.Id => filterEvent
        };
        System.assertEquals(id2CreatedEvents.size(), ctrl.eventReportList.size());
        for (Call_Report__c event : ctrl.eventReportList) {
            System.assert(id2CreatedEvents.containsKey(event.Id));
        }
    }

    @IsTest
    static void shouldRefreshEventViewsAllMyEventReportsThisYear() {
        getData();
        MyDayController ctrl = new MyDayController();
        ctrl.filterValue = 'My Event Reports this Year';

        fflib_SObjectUnitOfWork uow;
        Call_Report__c originalEvent;
        Call_Report__c filterEvent;
        System.runAs(sysAdminUser) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            originalEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('Original Event')
                    .startDate(System.now())
                    .endDate(System.now().addHours(1))
                    .addAttendee(
                            new BLD_CallReportAttendee(uow).contact(
                                    new BLD_Contact(uow).ownerId(sysAdminUser.Id)
                            )
                    )
                    .ownerId(attendeeUser.Id)
                    .assign(attendeeUser.Id)
                    .getRecord();
            filterEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('My Event Reports this Year Event')
                    .startDate(System.now())
                    .endDate(System.now().addHours(1))
                    .assign(sysAdminUser.Id)
                    .getRecord();
            uow.commitWork();

            Test.startTest();
            ctrl.refreshEventViews();
            Test.stopTest();
        }
        Map<Id, Call_Report__c> id2CreatedEvents = new Map<Id, Call_Report__c>{
                originalEvent.Id => originalEvent,
                filterEvent.Id => filterEvent
        };
        System.assertEquals(id2CreatedEvents.size(), ctrl.eventReportList.size());
        for (Call_Report__c event : ctrl.eventReportList) {
            System.assert(id2CreatedEvents.containsKey(event.Id));
        }
    }

    @IsTest
    static void shouldRefreshEventViewsAllMyIncompleteEventReports() {
        getData();
        MyDayController ctrl = new MyDayController();
        ctrl.filterValue = 'My Incomplete Event Reports';

        fflib_SObjectUnitOfWork uow;
        Call_Report__c originalEvent;
        Call_Report__c filterEvent;
        System.runAs(sysAdminUser) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            originalEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('Original Event')
                    .startDate(System.now().addDays(1))
                    .endDate(System.now().addDays(1).addHours(1))
                    .addAttendee(
                            new BLD_CallReportAttendee(uow).contact(
                                    new BLD_Contact(uow).ownerId(sysAdminUser.Id)
                            )
                    )
                    .ownerId(attendeeUser.Id)
                    .assign(attendeeUser.Id)
                    .getRecord();
            filterEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('My Incomplete Event Reports Event')
                    .startDate(System.now().addDays(1))
                    .endDate(System.now().addDays(1).addHours(1))
                    .linkWithParent(new BLD_Account(uow))
                    .meetingAudience(DMN_CallReport.INTERNAL)
                    .meetingPurpose(DMN_CallReport.MARKET_RESEARCH_UPDATE)
                    .assign(sysAdminUser.Id)
                    .getRecord();
            uow.commitWork();

            Test.startTest();
            ctrl.refreshEventViews();
            Test.stopTest();
        }
        Map<Id, Call_Report__c> id2CreatedEvents = new Map<Id, Call_Report__c>{
                originalEvent.Id => originalEvent,
                filterEvent.Id => filterEvent
        };
        System.assertEquals(id2CreatedEvents.size(), ctrl.eventReportList.size());
        for (Call_Report__c event : ctrl.eventReportList) {
            System.assert(id2CreatedEvents.containsKey(event.Id));
        }
    }

    @IsTest
    static void shouldRefreshEventViewsAllMyFutureEvents() {
        getData();
        MyDayController ctrl = new MyDayController();
        ctrl.filterValue = 'My Future Events';

        fflib_SObjectUnitOfWork uow;
        Call_Report__c originalEvent;
        Call_Report__c filterEvent;
        System.runAs(sysAdminUser) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            originalEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('Original Event')
                    .startDate(System.now().addDays(1))
                    .endDate(System.now().addDays(1).addHours(1))
                    .addAttendee(
                            new BLD_CallReportAttendee(uow).contact(
                                    new BLD_Contact(uow).ownerId(sysAdminUser.Id)
                            )
                    )
                    .ownerId(attendeeUser.Id)
                    .assign(attendeeUser.Id)
                    .getRecord();
            filterEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('My Future Events Event')
                    .startDate(System.now().addDays(1))
                    .endDate(System.now().addDays(1).addHours(1))
                    .linkWithParent(new BLD_Account(uow))
                    .assign(sysAdminUser.Id)
                    .getRecord();
            uow.commitWork();

            Test.startTest();
            ctrl.refreshEventViews();
            Test.stopTest();
        }
        Map<Id, Call_Report__c> id2CreatedEvents = new Map<Id, Call_Report__c>{
                originalEvent.Id => originalEvent,
                filterEvent.Id => filterEvent
        };
        System.assertEquals(id2CreatedEvents.size(), ctrl.eventReportList.size());
        for (Call_Report__c event : ctrl.eventReportList) {
            System.assert(id2CreatedEvents.containsKey(event.Id));
        }
    }

    @IsTest
    static void shouldRefreshEventViewsAllMyEventLast7Days() {
        getData();
        MyDayController ctrl = new MyDayController();
        ctrl.filterValue = 'My Event Reports for the last 7 days';

        fflib_SObjectUnitOfWork uow;
        Call_Report__c originalEvent;
        Call_Report__c filterEvent;
        System.runAs(sysAdminUser) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            originalEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('Original Event')
                    .startDate(System.now().addDays(-1))
                    .endDate(System.now().addDays(-1).addHours(1))
                    .addAttendee(
                            new BLD_CallReportAttendee(uow).contact(
                                    new BLD_Contact(uow).ownerId(sysAdminUser.Id)
                            )
                    )
                    .ownerId(attendeeUser.Id)
                    .assign(attendeeUser.Id)
                    .getRecord();
            filterEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('My Event Reports for the last 7 days Event')
                    .startDate(System.now().addDays(-1))
                    .endDate(System.now().addDays(-1).addHours(1))
                    .linkWithParent(new BLD_Account(uow))
                    .assign(sysAdminUser.Id)
                    .getRecord();
            uow.commitWork();

            Test.startTest();
            ctrl.refreshEventViews();
            Test.stopTest();
        }
        Map<Id, Call_Report__c> id2CreatedEvents = new Map<Id, Call_Report__c>{
                originalEvent.Id => originalEvent,
                filterEvent.Id => filterEvent
        };
        System.assertEquals(id2CreatedEvents.size(), ctrl.eventReportList.size());
        for (Call_Report__c event : ctrl.eventReportList) {
            System.assert(id2CreatedEvents.containsKey(event.Id));
        }
    }

    @IsTest
    static void shouldRefreshEventViewsAllMyEvenCurrentMonth() {
        getData();
        MyDayController ctrl = new MyDayController();
        ctrl.filterValue = 'My Event Reports Current Month';

        fflib_SObjectUnitOfWork uow;
        Call_Report__c originalEvent;
        Call_Report__c filterEvent;
        System.runAs(sysAdminUser) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            originalEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('Original Event')
                    .startDate(System.now())
                    .endDate(System.now().addHours(1))
                    .addAttendee(
                            new BLD_CallReportAttendee(uow).contact(
                                    new BLD_Contact(uow).ownerId(sysAdminUser.Id)
                            )
                    )
                    .ownerId(attendeeUser.Id)
                    .assign(attendeeUser.Id)
                    .getRecord();
            filterEvent = (Call_Report__c) new BLD_CallReport(uow)
                    .subject('My Event Reports Current Month Event')
                    .startDate(System.now())
                    .endDate(System.now().addHours(1))
                    .linkWithParent(new BLD_Account(uow))
                    .assign(sysAdminUser.Id)
                    .getRecord();
            uow.commitWork();

            Test.startTest();
            ctrl.refreshEventViews();
            Test.stopTest();
        }
        Map<Id, Call_Report__c> id2CreatedEvents = new Map<Id, Call_Report__c>{
                originalEvent.Id => originalEvent,
                filterEvent.Id => filterEvent
        };
        System.assertEquals(id2CreatedEvents.size(), ctrl.eventReportList.size());
        for (Call_Report__c event : ctrl.eventReportList) {
            System.assert(id2CreatedEvents.containsKey(event.Id));
        }
    }

}