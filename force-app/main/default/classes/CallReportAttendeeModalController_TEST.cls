/**
 * @author          Dzianisik Maksim
 * @date            Dec 2022
 * @description     SFP-19087, test class for CallReportAttendeeModalController
 */
@IsTest
private class CallReportAttendeeModalController_TEST {

    private static final String USER_NAME = 'testEventReport@testuser.com';
    private static final Integer NUMBER_OF_RECORDS = 10;
    private static final String CIB_USER_L_NAME = 'test_cib_user';

    /**
    * @description gets and sets testUser
    * @return User 
    **/
    private static User testUser {
        get{
            if(testUser == null) {
                testUser = [SELECT Id FROM User WHERE Username =: USER_NAME];
            }
            return testUser;
        }
        set;
    }

    /**
    * @description creates test data
    **/
    @TestSetup
    static void setup() {

        testUser = (User) new BLD_USER().useSysAdmin().userName(USER_NAME).commitWork().getRecord();
        Contact userContact;
        Account acc;

        System.runAs(testUser) {
            TEST_DataFactory.generateConfiguration();
            acc = TEST_DataFactory.stdBankEmpAcc;

            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            for (Integer i = 0; i < NUMBER_OF_RECORDS; ++i) {
                new BLD_Contact(uow)
                        .useBankContact()
                        .accountId(acc.Id)
                        .setField(Contact.Active_User__c, true);
            }
            for (Integer i = 0; i < NUMBER_OF_RECORDS; ++i) {
                new BLD_Contact(uow)
                        .useClientContact()
                        .contactCategory(DMN_Contact.CONTACT_CATEGORIES[0])
                        .accountId(acc.Id);
            }

            userContact = (Contact) new BLD_Contact(uow).useBankContact()
                    .accountId(acc.Id).name('first', CIB_USER_L_NAME).getRecord();

            new BLD_CallReport(uow)
                    .linkWithParent(acc.Id)
                    .internal()
                    .ownerId(testUser.Id);

            uow.commitWork();
        }

        User customStandardUser = (User) new BLD_USER().useCib().getRecord();
        customStandardUser.LastName = CIB_USER_L_NAME;
        customStandardUser.Contact_Sync_ID__c = userContact.Id;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert customStandardUser;
        }
    }

    /**
    * @description main test method 
    **/
    @IsTest
    private static void testGettingInternalData() {

        System.runAs(testUser) {
            User cibUser = [SELECT Id FROM User WHERE LastName =: CIB_USER_L_NAME];

            List<Contact> testContacts = getContacts(DMN_Contact.RTD_BANK);
            Assert.areEqual(NUMBER_OF_RECORDS + 2, testContacts.size(), ' Has to have additional 2 contacts for created users');
            Id accId = testContacts[0].AccountId;

            Call_Report__c actualReport = getCallReport();

            CallReportAttendeeModalController.DataWrapper testWrapper = CallReportAttendeeModalController.getAttendeeData(actualReport.Id, true);
            Assert.areEqual(0, testWrapper.attendeeWrappers.size(), 'There has not to be any attendees');

            List<Schema.PicklistEntry> fieldResult = Call_Report_Attendees__c.Status__c.getDescribe().getPicklistValues();
            Assert.areEqual(fieldResult.size(), testWrapper.statusValues.size(), 'Checking the correct number of statuses');

            Test.startTest();
            AccountTeamMember testMember = new AccountTeamMember(
                    AccountId = accId,
                    TeamMemberRole = 'Credit Officer',
                    UserId = cibUser.Id
            );
            insert testMember;

            List<Call_Report_Attendees__c> tempAttendees = createAttendees(actualReport.Id, testContacts);
            insert tempAttendees;

            testWrapper = CallReportAttendeeModalController.getAttendeeData(actualReport.Id, true);
            Assert.areEqual(NUMBER_OF_RECORDS + 1, testWrapper.attendeeWrappers.size(), 'Checking the number of Attendees');
            Test.stopTest();
        }
    }

    /**
    * @description get external data test
    **/
    @IsTest
    private static void testGettingExternalData() {
        System.runAs(testUser) {
            Call_Report__c actualReport = getCallReport();

            List<Contact> testContacts = getContacts(DMN_Contact.RTD_CLIENT);
            Assert.areEqual(NUMBER_OF_RECORDS , testContacts.size(), 'Checking the number of Client contacts');

            CallReportAttendeeModalController.DataWrapper testWrapper = CallReportAttendeeModalController.getAttendeeData(actualReport.Id, false);
            Assert.areEqual(NUMBER_OF_RECORDS, testWrapper.attendeeWrappers.size(), 'There has to be potential attendees');

            Boolean checkAddRemove = false;
            for (CallReportAttendeeModalController.AttendeeWrapper temp : testWrapper.attendeeWrappers) {
                if (temp.addRemove) {
                    checkAddRemove = true;
                    break;
                }
            }
            Assert.isTrue(!checkAddRemove, 'All attendees have to be deselected');

            Test.startTest();
            List<Call_Report_Attendees__c> tempAttendees = createAttendees(actualReport.Id, testContacts);
            insert tempAttendees;

            testWrapper = CallReportAttendeeModalController.getAttendeeData(actualReport.Id, false);
            Assert.areEqual(NUMBER_OF_RECORDS, testWrapper.attendeeWrappers.size(), 'Checking the number of Attendees');

            checkAddRemove = true;
            for (CallReportAttendeeModalController.AttendeeWrapper temp : testWrapper.attendeeWrappers) {
                if (!temp.addRemove) {
                    checkAddRemove = false;
                    break;
                }
            }
            Assert.isTrue(checkAddRemove, 'All attendees have to be selected');
            Test.stopTest();
        }
    }

    /**
    * @description tests getContactSuggestions 
    **/
    @IsTest
    private static void testSuggestion() {
        System.runAs(testUser) {
            Map<String, List<String>> internalSuggestions = CallReportAttendeeModalController.getContactSuggestions(BLD_Contact.DEF_LAST_NAME, true);
            Assert.areEqual(NUMBER_OF_RECORDS, internalSuggestions.size(), 'Checking the number of suggestions');

            List<Contact> bankContacts = [SELECT Id, Active_User__c, RecordType.DeveloperName FROM Contact WHERE Id IN : internalSuggestions.keySet()];
            Boolean isBankContact = true;
            for (Contact temp : bankContacts) {
                if (temp.RecordType.DeveloperName != DMN_Contact.RTD_BANK || !temp.Active_User__c) {
                    isBankContact = false;
                    break;
                }
            }
            Assert.isTrue(isBankContact, 'All suggestions have to be bank contacts');

            Map<String, List<String>> externalSuggestions = CallReportAttendeeModalController.getContactSuggestions(BLD_Contact.DEF_LAST_NAME, false);
            Assert.areEqual(NUMBER_OF_RECORDS, externalSuggestions.size(), 'Checking the number of suggestions');

            List<Contact> clientContacts = [SELECT Id, Inactive__c, RecordType.DeveloperName FROM Contact WHERE Id IN : externalSuggestions.keySet()];
            isBankContact = false;
            for (Contact temp: clientContacts) {
                if (temp.RecordType.DeveloperName == DMN_Contact.RTD_BANK || temp.Inactive__c) {
                    isBankContact = true;
                    break;
                }
            }
            Assert.isTrue(!isBankContact, 'All suggestions have not to be bank contacts');
        }
    }

    /**
    * @description test internal save logic
    **/
    @IsTest
    private static void testSaveInternalLogic() {
        System.runAs(testUser) {
            List<Contact> testContacts = getContacts(DMN_Contact.RTD_BANK);
            Assert.areEqual(NUMBER_OF_RECORDS + 2, testContacts.size(), ' Has to have additional 2 contacts for created users');

            Call_Report__c actualReport = getCallReport();

            Test.startTest();
            List<Call_Report_Attendees__c> tempAttendees = createAttendees(actualReport.Id, testContacts);
            insert tempAttendees;

            Boolean isInvited = checkAttendeesStatus(DMN_CallReportAttendee.STATUS_INVITED, actualReport.Id);
            Assert.isTrue(isInvited, 'All statuses have to be Invited');

            CallReportAttendeeModalController.DataWrapper testWrapper = CallReportAttendeeModalController.getAttendeeData(actualReport.Id, true);
            for (Contact temp: testContacts) {
                if(temp.Name.contains(CIB_USER_L_NAME)) {
                    CallReportAttendeeModalController.AttendeeWrapper newRecord = new CallReportAttendeeModalController.AttendeeWrapper(true, '', temp);
                    newRecord.addRemove = true;
                    testWrapper.attendeeWrappers.add(newRecord);
                    break;
                }
            }
            Assert.areEqual(NUMBER_OF_RECORDS + 1, testWrapper.attendeeWrappers.size(), 'Has to have an additional record');

            String response = CallReportAttendeeModalController.saveAttendees(actualReport.Id, JSON.serialize(testWrapper.attendeeWrappers), true);
            Assert.areEqual('Internal core warning', response, 'Validate the save response');

            Boolean isAttended = checkAttendeesStatus(DMN_CallReportAttendee.STATUS_ATTENDED, actualReport.Id);
            Assert.isTrue(isAttended, 'All status come back as Attended');
            Test.stopTest();
        }
    }

    /**
    * @description test save external logic
    **/
    @IsTest
    private static void testSaveExternalLogic() {
        System.runAs(testUser) {
            Call_Report__c actualReport = getCallReport();
            actualReport.C_Suite_Attendance__c = true;
            update actualReport;

            List<Contact> testContacts = getContacts(DMN_Contact.RTD_CLIENT);
            Assert.areEqual(NUMBER_OF_RECORDS , testContacts.size(), 'Checking the number of Client contacts');

            Test.startTest();
            List<Call_Report_Attendees__c> tempAttendees = createAttendees(actualReport.Id, testContacts);
            insert tempAttendees;

            actualReport = getCallReport();
            Assert.isTrue(actualReport.C_Suite_Attendance__c, 'Checking that C_Suite_Attendance__c = true');

            CallReportAttendeeModalController.DataWrapper testWrapper = CallReportAttendeeModalController.getAttendeeData(actualReport.Id, false);
            Boolean isContactAdded = true;
            for (CallReportAttendeeModalController.AttendeeWrapper wrapper :  testWrapper.attendeeWrappers) {
                if (wrapper.addRemove) {
                    wrapper.addRemove = false;
                }else {
                    isContactAdded = false;
                    break;
                }
            }
            Assert.isTrue(isContactAdded, 'All contacts had to be added');

            String response = CallReportAttendeeModalController.saveAttendees(actualReport.Id, JSON.serialize(testWrapper.attendeeWrappers), false);
            Assert.areEqual('SUCCESS', response, 'Check response');

            actualReport = getCallReport();
            Assert.isTrue(!actualReport.C_Suite_Attendance__c, 'Has to be false');

            tempAttendees = getAttendees(actualReport.Id);
            Assert.areEqual(0, tempAttendees.size(), 'There has not to be any attendees');

            Test.stopTest();
        }
    }

    /**
    * @description test that 1 record was created 
    * @return Call_Report__c 
    **/
    private static Call_Report__c getCallReport() {
        List<Call_Report__c> actualReports = [SELECT Id, C_Suite_Attendance__c FROM Call_Report__c];
        Assert.areEqual(1, actualReports.size(), 'Has to be only 1 CallReport');
        return actualReports[0];
    }

    /**
    * @description gets and returns attendee status
    * @param status 
    * @param reportId 
    * @return Boolean 
    **/
    private static Boolean checkAttendeesStatus(String status, Id reportId) {
        List<Call_Report_Attendees__c> updatedAttendees = getAttendees(reportId);
        Boolean result = true;
        for (Call_Report_Attendees__c temp : updatedAttendees) {
            if (temp.Status__c != status) {
                return false;
            }
        }
        return result;
    }

    /**
    * @description returns attendee records
    * @param reportId 
    * @return List<Call_Report_Attendees__c> 
    **/
    private static List<Call_Report_Attendees__c> getAttendees(Id reportId) {
        return [SELECT Status__c FROM Call_Report_Attendees__c WHERE Call_Report__c =: reportId];
    }

    /**
    * @description  creates test attendee records
    * @param reportId 
    * @param testContacts 
    * @return List<Call_Report_Attendees__c> 
    **/
    private static List<Call_Report_Attendees__c> createAttendees(Id reportId, List<Contact> testContacts) {
        List<Call_Report_Attendees__c> tempAttendees = new List<Call_Report_Attendees__c>();
        for (Contact temp : testContacts) {
            if (temp.Name.contains(BLD_Contact.DEF_LAST_NAME)) {
                tempAttendees.add(new Call_Report_Attendees__c(
                        Call_Report__c = reportId,
                        Contact_id__c = temp.Id,
                        Status__c = DMN_CallReportAttendee.STATUS_INVITED
                ));
            }
        }
        return tempAttendees;
    }

    /**
    * @description gets contacts to test with 
    * @param recordTypeDevName 
    * @return List<Contact> 
    **/
    private static List<Contact> getContacts(String recordTypeDevName) {
        return [SELECT Id, Name, AccountId, Account.Name FROM Contact WHERE RecordType.DeveloperName =: recordTypeDevName];
    }
    
    /**
    * @description test isBCBUser
    **/
    @IsTest
    static void isBCBUser() {
       User testUsr = AOB_DAL_TestFactory.createUser('Personal Business Banking Custom Std User - Mobile', true);
        System.runAs(testUsr){
            Test.startTest();
            Boolean result = CallReportAttendeeModalController.isBCBUser();      
            Assert.isTrue(result, 'Check user');
            Test.stopTest();
           
        }    
}
    
}