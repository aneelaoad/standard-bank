/**
 * Test class for EventReport_Navigate_Lightning
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		December 2020
*/
@IsTest
public class EventReport_Navigate_Lightning_TEST {

    public static final String TEST_CIB_USERNAME = 'test.cibUser@test.com';
    public static final String DEF_ACC_NAME = 'Def Name for Acc';

    private static User cibUser;
    private static Account acc;

    @TestSetup
    private static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getEnvironmentVariable()
        });
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            cibUser = (User)new BLD_USER(uow)
                    .userName(TEST_CIB_USERNAME)
                    .useCib()
                    .syncContact()
                    .getRecord();

            uow.commitWork();
        }
        System.runAs(cibUser){
            acc = (Account) new BLD_Account(uow)
                    .name(DEF_ACC_NAME)
                    .useCib()
                    .getRecord();
            uow.commitWork();
        }
    }

    private static void getData(){
        cibUser = [
                SELECT Id
                FROM User
                WHERE UserName = :TEST_CIB_USERNAME
        ];

        acc = [
                SELECT
                        Name,
                        Primary_Relationship_Holder__c
                FROM Account
                WHERE Name = :DEF_ACC_NAME
        ];
    }

    @IsTest
    static void shouldSaveSuccessfullyTrueCoreCheck() {
        getData();
        ApexPages.StandardController stdController;
        EventReport_Navigate_Lightning cont = new EventReport_Navigate_Lightning(stdController);
        cont.eventReportRecord.Subject__c = cont.eventReportValues;
        cont.eventReportRecord.Meeting_Audience__c = DMN_CallReport.INTERNAL;
        cont.eventReportRecord.Meeting_Purpose__c = DMN_CallReport.CORE_TEAM_MEETING;
        cont.eventReportRecord.Relate_to_Client__c = acc.Id;

        System.runAs(cibUser) {
            Test.startTest();
            PageReference result = cont.Save();
            Test.stopTest();

            System.assertNotEquals(null, result);
            System.assertEquals(cont.eventReportRecord.Id, result.getParameters().get('reportid'));
            System.assertEquals(cont.eventReportValues, cont.eventReportRecord.Name);
            System.assertEquals(encodeDateTime(cont.startDate), cont.eventReportRecord.Start__c);
            System.assertEquals(encodeDateTime(cont.endDate), cont.eventReportRecord.End__c);

            List<Call_Report__c> insertedEvent = [
                    SELECT
                            Name, Start__c, End__c
                    FROM Call_Report__c
                    WHERE Subject__c = :cont.eventReportValues
            ];
            System.assertEquals(1, insertedEvent.size());
            System.assertEquals(cont.eventReportValues+'-'+DEF_ACC_NAME, insertedEvent[0].Name);
            System.assertEquals(encodeDateTime(cont.startDate), insertedEvent[0].Start__c);
            System.assertEquals(encodeDateTime(cont.endDate), insertedEvent[0].End__c);
        }
    }

    @IsTest
    static void shouldSaveSuccessfullyFalseCoreCheck() {
        getData();
        ApexPages.StandardController stdController;
        EventReport_Navigate_Lightning cont = new EventReport_Navigate_Lightning(stdController);
        cont.eventReportRecord.Subject__c = cont.eventReportValues;

        System.runAs(cibUser) {
            Test.startTest();
            PageReference result = cont.Save();
            Test.stopTest();

            System.assertNotEquals(null, result);
            System.assertEquals('/'+cont.eventReportRecord.Id, result.getUrl());
        }
    }

    @IsTest
    static void shouldSaveFailDMLException() {
        getData();
        ApexPages.StandardController stdController;
        EventReport_Navigate_Lightning cont = new EventReport_Navigate_Lightning(stdController);
        System.runAs(cibUser) {
            Test.startTest();
            PageReference result = cont.Save();
            Test.stopTest();

            List<Call_Report__c> insertedEvent = [
                    SELECT
                            Id
                    FROM Call_Report__c
                    WHERE Subject__c = :cont.eventReportValues
            ];
            System.assertEquals(null, result);
            System.assertEquals(0, insertedEvent.size());
        }
    }

    @IsTest
    static void shouldSaveAndNewSuccessfully() {
        getData();
        ApexPages.StandardController stdController;
        EventReport_Navigate_Lightning cont = new EventReport_Navigate_Lightning(stdController);
        cont.eventReportRecord.Subject__c = cont.eventReportValues;
        cont.eventReportRecord.Meeting_Audience__c = DMN_CallReport.INTERNAL;
        cont.eventReportRecord.Meeting_Purpose__c = DMN_CallReport.CORE_TEAM_MEETING;
        cont.eventReportRecord.Relate_to_Client__c = acc.Id;

            Test.startTest();
            PageReference result = cont.SaveAndNew();
            Test.stopTest();

            System.assertNotEquals(null, result);
            System.assertEquals('/apex/EventReport_New_Navigate', result.getUrl());

            List<Call_Report__c> insertedEvent = [
                    SELECT
                            Name, Start__c, End__c
                    FROM Call_Report__c
                    WHERE Subject__c = :cont.eventReportValues
            ];
            System.assertEquals(1, insertedEvent.size());
            System.assertEquals(cont.eventReportValues+'-'+DEF_ACC_NAME, insertedEvent[0].Name);
            System.assertEquals(encodeDateTime(cont.startDate), insertedEvent[0].Start__c);
            System.assertEquals(encodeDateTime(cont.endDate), insertedEvent[0].End__c);
    }

    @IsTest
    static void shouldSaveAndNewFailDMLException() {
        getData();
        ApexPages.StandardController stdController;
        EventReport_Navigate_Lightning cont = new EventReport_Navigate_Lightning(stdController);
            Test.startTest();
            PageReference result = cont.SaveAndNew();
            Test.stopTest();

            List<Call_Report__c> insertedEvent = [
                    SELECT
                            Id
                    FROM Call_Report__c
                    WHERE Subject__c = :cont.eventReportValues
            ];
            System.assertEquals(null, result);
            System.assertEquals(0, insertedEvent.size());
    }

    @IsTest
    static void shouldCancelRequest() {
        getData();
        ApexPages.StandardController stdController;
        EventReport_Navigate_Lightning cont = new EventReport_Navigate_Lightning(stdController);
            Test.startTest();
            PageReference result = cont.cancelRequest();
            Test.stopTest();

            System.assertNotEquals(null, result);
            System.assertEquals('/a0K/o', result.getUrl());
            System.assert(result.getRedirect());
    }

    private static Datetime encodeDateTime(String value) {
        DateTime dt = null;

        String datePart = value.split(' ')[0];
        String timePart = value.split(' ')[1];

        List<String> dateSplit = datePart.split('/');
        Integer year = Integer.valueOf(dateSplit[2]);
        Integer month = Integer.valueOf(dateSplit[1]);
        Integer day = Integer.valueOf(dateSplit[0]);

        List<String> times = timePart.split(':');
        Integer hours = Integer.valueOf(times[0]);
        Integer minutes = Integer.valueOf(times[1]);

        dt = DateTime.newInstance(year, month, day, hours, minutes, 0);
        
        return dt;
    }
}