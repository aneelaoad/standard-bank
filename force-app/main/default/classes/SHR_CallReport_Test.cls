/**
 * Created by tsobota on 08.01.2019.
 */
@isTest
private class SHR_CallReport_Test {

    private static final String
            TEST_USER_NAME_1 = 'test.StdBank_Ltn_Ecosystem_Test1@test.com',
            TEST_USER_NAME_2 = 'test.StdBank_Ltn_Ecosystem_Test2@test.com',
            TEST_USER_NAME_3 = 'test.StdBank_Ltn_Ecosystem_Test3@test.com',
            ACC_NAME = 'accountTest@test.com',
            OPP_NAME = 'opportunityTest@test.com',
            GROUP_NUMBER = '1234',
            TEST_USER_COUNTRY = 'TEST_COUNTRY',
            TEST_USER_DIVISION = 'Client Coverage',
            OPP_CURRENCY = 'USD',
            CALL_REPORT_SUBJECT = 'TEST',
            CALL_REPORT_DESCRIPTION = 'TEST';

    private static User sysAdmin, testUser_1, testUser_2, testUser_3;
    private static Account acc, standardBankAccount;
    private static Opportunity opp;
    private static Contact internalContact, externalContact;
    private static Custom_Client_Team__c testCustomClientTeam1, testCustomClientTeam2, testCustomClientTeam3;
    private static Call_Report__c testCallReport;
    private static Call_Report_Attendees__c internalCallReportAttendees, externalCallReportAttendees;

    @testSetup
    private static void setup() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            sysAdmin = (User) new BLD_USER(uow)
                                        .useSysAdmin()
                                        .syncContact()
                                        .getRecord();

            testUser_1 = (User) new BLD_USER(uow)
                                        .useCib()
                                        .userName(TEST_USER_NAME_1)
                                        .division(TEST_USER_DIVISION)
                                        .country(TEST_USER_COUNTRY)
                                        .setField(User.ManagerId, sysAdmin.Id)
                                        .getRecord();

            testUser_2 = (User) new BLD_USER(uow)
                                        .useCib()
                                        .userName(TEST_USER_NAME_2)
                                        .division(TEST_USER_DIVISION)
                                        .country(TEST_USER_COUNTRY)
                                        .setField(User.ManagerId, sysAdmin.Id)
                                        .getRecord();

            testUser_3 = (User) new BLD_USER(uow)
                                        .syncContact()
                                        .useCib()
                                        .userName(TEST_USER_NAME_3)
                                        .division(TEST_USER_DIVISION)
                                        .country(TEST_USER_COUNTRY)
                                        .setField(User.ManagerId, sysAdmin.Id)
                                        .getRecord();
            uow.commitWork();
        }

        System.runAs(testUser_1) {
            acc = (Account) new BLD_Account(uow)
                                    .name(ACC_NAME)
                                    .useCommB()
                                    .useGroupParent()
                                    .groupNumber(GROUP_NUMBER)
                                    .getRecord();

            standardBankAccount = (Account) new BLD_Account(uow)
                                                    .name('Standard Bank Employees')
                                                    .useCommB()
                                                    .useGroupParent()
                                                    .groupNumber(GROUP_NUMBER)
                                                    .getRecord();

            uow.commitWork();
            opp = (Opportunity) new BLD_Opportunity(uow)
                    .linkAccountId(acc.Id)
                    .currency(OPP_CURRENCY)
                    .setField(Opportunity.Name, OPP_NAME)
                    .getRecord();

            internalContact = (Contact) new BLD_Contact(uow).useBankContact()
                    .name('test', 'test')
                    .accountId(standardBankAccount.Id)
                    .getRecord();
        }

        System.runAs(testUser_2) {
            externalContact = (Contact) new BLD_Contact(uow)
                    .name('test2', 'test2')
                    .accountId(standardBankAccount.Id)
                    .getRecord();
        }

        List<Schema.PicklistEntry> teamMemberRoles = Custom_Client_Team__c.Client_Role__c.getDescribe().getPicklistValues();
        testCustomClientTeam1 = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
                                                                .account(acc.Id)
                                                                .user(testUser_1.Id)
                                                                .role(String.valueOf(teamMemberRoles[0]))
                                                                .coordinator(true)
                                                                .ccbm(false)
                                                                .setField(Custom_Client_Team__c.Client_Access__c, DMN_ClientTeam.ACCESS_READ)
                                                                .getRecord();
        testCustomClientTeam2 = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
                                                                .account(acc.Id)
                                                                .user(testUser_2.Id)
                                                                .role(String.valueOf(teamMemberRoles[1]))
                                                                .coordinator(false)
                                                                .ccbm(false)
                                                                .setField(Custom_Client_Team__c.Client_Access__c, DMN_ClientTeam.ACCESS_EDIT)
                                                                .getRecord();
        testCustomClientTeam3 = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
                                                                .account(acc.Id)
                                                                .user(testUser_3.Id)
                                                                .role(String.valueOf(teamMemberRoles[2]))
                                                                .coordinator(false)
                                                                .ccbm(false)
                                                                .setField(Custom_Client_Team__c.Client_Access__c, DMN_ClientTeam.ACCESS_READ)
                                                                .getRecord();
        uow.commitWork();
        System.runAs(testUser_1) {
            testCallReport = (Call_Report__c) new BLD_CallReport(uow)
                    .internal()
                    .subject(CALL_REPORT_SUBJECT)
                    .description(CALL_REPORT_DESCRIPTION)
                    .linkWithParent(acc.Id)
                    .assign(testUser_1.Id)
                    .startDate(Datetime.now().addHours(1))
                    .endDate(Datetime.now().addHours(2))
                    .getRecord();
            uow.commitWork();
        }
        testUser_1.Contact_Sync_ID__c = internalContact.Id;
        testUser_2.Contact_Sync_ID__c = externalContact.Id;

        internalCallReportAttendees = new Call_Report_Attendees__c();
        externalCallReportAttendees = new Call_Report_Attendees__c();

        internalCallReportAttendees.Call_Report__c = testCallReport.Id;
        internalCallReportAttendees.Contact_id__c = testUser_1.Contact_Sync_ID__c;
        internalCallReportAttendees.Type_of_Attendee__c = 'Internal';
        internalCallReportAttendees.Status__c = 'Invited';
        internalCallReportAttendees.Send_Email__c = 'Yes';

//        externalCallReportAttendees.Call_Report__c = testCallReport.Id;
//        externalCallReportAttendees.Contact_id__c = testUser_1.Contact_Sync_ID__c;
//        externalCallReportAttendees.Type_of_Attendee__c = 'Internal';
//        externalCallReportAttendees.Status__c = 'Invited';
//        externalCallReportAttendees.Send_Email__c = 'Yes';

        uow.registerNew(internalCallReportAttendees);
        //uow.registerNew(externalCallReportAttendees);
        uow.commitWork();

    }

    private static void getData() {
        for (User usr : [
                SELECT
                        Username,
                        ContactId
                FROM User
                WHERE UserName = :TEST_USER_NAME_1
                OR UserName = :TEST_USER_NAME_2
                OR UserName = :TEST_USER_NAME_3
                LIMIT 3
        ]) {
            if (usr.UserName == TEST_USER_NAME_1) {
                testUser_1 = usr;
                continue;

            }
            if (usr.UserName == TEST_USER_NAME_2) {
                testUser_2 = usr;
                continue;

            }
            if (usr.UserName == TEST_USER_NAME_3) {
                testUser_3 = usr;
                continue;

            }
        }

        for (Account addedAccount : [
                SELECT Name, CreatedById
                FROM Account
                WHERE Name = :ACC_NAME
                LIMIT 1
        ]) {
            if (addedAccount.Name == ACC_NAME) {
                acc = addedAccount;
            }
        }

        for (Opportunity addedOpportunity : [
                SELECT Name
                FROM Opportunity
                WHERE Name = :OPP_NAME
                LIMIT 1
        ]) {
            if (addedOpportunity.Name == OPP_NAME) {
                opp = addedOpportunity;
            }
        }

        for (Call_Report__c callReport : [
                SELECT Subject__c, CreatedById
                FROM Call_Report__c
                WHERE Subject__c = :CALL_REPORT_SUBJECT
                LIMIT 1
        ]) {
            if (callReport.Subject__c.equals(CALL_REPORT_SUBJECT)) {
                testCallReport = callReport;
            }
        }

        for (Custom_Client_Team__c customClientTeam : [
                SELECT Team_Member__c
                FROM Custom_Client_Team__c
                WHERE Name = :testUser_1.Id
                OR Team_Member__c = :testUser_2.Id
                OR Team_Member__c = :testUser_3.Id
                LIMIT 6
        ]) {
            if(customClientTeam.Team_Member__c == testUser_1.Id) {
                testCustomClientTeam1 = customClientTeam;
                continue;
            }
            if(customClientTeam.Team_Member__c == testUser_2.Id) {
                testCustomClientTeam2 = customClientTeam;
                continue;
            }
            if(customClientTeam.Team_Member__c == testUser_3.Id) {
                testCustomClientTeam3 = customClientTeam;
                continue;
            }
        }

        for (Call_Report_Attendees__c callReportAttendees : [
                SELECT Contact_id__c
                FROM Call_Report_Attendees__c
                WHERE Contact_id__c = :testUser_1.ContactId
                OR Contact_id__c = :testUser_2.ContactId
                LIMIT 2
        ]) {
            if (callReportAttendees.Contact_id__c == testUser_1.ContactId) {
                internalCallReportAttendees = callReportAttendees;
                continue;
            }
            if (callReportAttendees.Contact_id__c == testUser_2.ContactId) {
                externalCallReportAttendees = callReportAttendees;
                continue;
            }
        }
    }

    @isTest
    private static void returnTrueOnCheckingShares() {

        getData();
        Test.startTest();

        Map<Id, Map<String, String>> userId2ShareSettings = getUserSharesOnCallReport(testCallReport.Id);

        for (Id userId : userId2ShareSettings.keySet()) {
            Map<String, String> shareSettings = userId2ShareSettings.get(userId);
            System.debug(shareSettings);
            if (userId == UserInfo.getUserId()) {
                System.assertEquals('Edit', shareSettings.get('Call_Event_Attendee__c'));
                System.assertEquals('Read', shareSettings.get('Parent_Sharing__c'));
            }
            if (userId == testUser_1.Id) {
                System.assertEquals('All', shareSettings.get('Owner'));
                System.assertEquals('Edit', shareSettings.get('Parent_Sharing__c'));
            }
            if (userId == testUser_2.Id) {
                System.assertEquals('Edit', shareSettings.get('Parent_Sharing__c'));
            }
            if (userId == testUser_3.Id) {
                System.debug('user 3');
                System.assertEquals('Read', shareSettings.get('Parent_Sharing__c'));
            }
        }
        Test.stopTest();
    }

    @isTest
    private static void checkOnCallReportVisibilityChange() {
        getData();

        Test.startTest();
        testCallReport.Visible_to_Internal_Attendees_only__c = true;
        update testCallReport;
        Test.stopTest();

        Map<Id, Map<String, String>> userId2ShareSettings = getUserSharesOnCallReport(testCallReport.Id);
        System.assert(!userId2ShareSettings.containsKey(testUser_2.Id));
        System.assert(!userId2ShareSettings.containsKey(testUser_3.Id));

        for (Id userId : userId2ShareSettings.keySet()) {
            Map<String, String> shareSettings = userId2ShareSettings.get(userId);
            System.debug(shareSettings);
            if (userId == UserInfo.getUserId()) {
                System.assertEquals('Edit', shareSettings.get('Call_Event_Attendee__c'));
                System.assert(!shareSettings.containsKey('Parent_Sharing__c'));
            }
            if (userId == testUser_1.Id) {
                System.assertEquals('All', shareSettings.get('Owner'));
                System.assert(!shareSettings.containsKey('Parent_Sharing__c'));
            }
        }
    }

    private static Map<Id, Map<String, String>> getUserSharesOnCallReport(Id callReportId) {
        List<Call_Report__Share> callReportShares = [SELECT AccessLevel, RowCause, UserOrGroupId FROM Call_Report__Share WHERE ParentId = :callReportId];

        Map<Id, Map<String, String>> userId2ShareSettings = new Map<Id, Map<String, String>>();
        for (Call_Report__Share crs : callReportShares) {
            if(!userId2ShareSettings.containsKey(crs.UserOrGroupId)) {
                userId2ShareSettings.put(crs.UserOrGroupId, new Map<String, String>());
            }
            userId2ShareSettings.get(crs.UserOrGroupId).put(crs.RowCause, crs.AccessLevel);
        }
        return userId2ShareSettings;
    }
}