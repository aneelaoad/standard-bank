/**
 * Test class for BCH_AttendeeReminder class
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		December 2020
 */
@IsTest
public class BCH_AttendeeReminder_TEST {
    static User attendeeUser;
    static Call_Report__c event;

    @TestSetup
    static void setup() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            attendeeUser = (User) new BLD_USER(uow).userName('attendeeUser@test.com').useCib().division('Transactional Products and Services').syncContact().getRecord();
            uow.commitWork();
        }
        System.runAs(attendeeUser) {
            event = (Call_Report__c) new BLD_CallReport(uow)
                    .startDate(System.now()-1)
                    .endDate((System.now()-1).addHours(1))
                    .subject('test AttendeeReminder')
                    .meetingFormat('Entertainment')
                    .attendeeReminderRequired('NO_NEED')
                    .addAttendee(new BLD_CallReportAttendee(uow).status('Attended'))
                    .getRecord();
            uow.commitWork();
        }

    }

    static void getData() {
        attendeeUser = [
                SELECT Username, Division, IsActive
                FROM User
                WHERE Username = 'attendeeUser@test.com'
                LIMIT 1];

        event = [
                SELECT Id, Total_Event_Costs__c,
                        Date__c, Meeting_Format__c,
                        Attendee_Reminder_Required__c,
                        (SELECT Id,
                                Status__c
                        FROM Call_Report_Attendeess__r)
                FROM Call_Report__c
                WHERE Subject__c = 'test AttendeeReminder'
                LIMIT 1
        ];
    }

    @IsTest
    static void shouldScheduleBatchJob() {
        Test.startTest();
        System.schedule('BCH_AttendeeReminder', '0 0 0 15 3 ?', new BCH_AttendeeReminder());
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name = :BCH_AttendeeReminder.class.getName() AND Status = 'Queued']);
        Test.stopTest();
    }

    @IsTest
    static void shouldUpdateReminder() {
        getData();
        System.runAs(attendeeUser) {

            System.assertEquals('NO_NEED', event.Attendee_Reminder_Required__c);

            Test.startTest();
            BCH_AttendeeReminder attendeeReminder = new BCH_AttendeeReminder();
            Database.executeBatch(attendeeReminder);
            Test.stopTest();
            Call_Report__c resultingEvent = [
                    SELECT Attendee_Reminder_Required__c
                    FROM Call_Report__c
                    WHERE Id = :event.Id
            ];
            System.assertNotEquals('NO_NEED', resultingEvent.Attendee_Reminder_Required__c);

        }
    }
}