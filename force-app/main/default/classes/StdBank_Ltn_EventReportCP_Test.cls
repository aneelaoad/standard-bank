@isTest
private class StdBank_Ltn_EventReportCP_Test {

    @TestSetup
    static void prepareData() {
        Insert TEST_DataFactory.getEnvironmentVariable();
    }
    
    @isTest
    static void getRecord() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        Call_Report__c eventReport = (Call_Report__c) new BLD_CallReport(uow)
            .linkWithParent(
                new BLD_Account(uow).useGroupParent()
            )
            .internal()
            .assign(UserInfo.getUserId())
            .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
            .commitWork()
            .getRecord();

        Call_Report__c result = StdBank_Ltn_EventReportCP.getRecord(eventReport.Id);

        System.assertEquals(eventReport.Id, result.Id, 'Id not the same!');
    }

    @isTest
    static void getEmailAttributes() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_CallReport erBuilder = new BLD_CallReport(uow)
            .internal()
            .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
            .assign(UserInfo.getUserId());

        Account ugpAcc = (Account) new BLD_Account(uow).useGroupParent()
            .name(DMN_Account.STANDARD_BANK_EMPLOYEES)
            .addContact(
                new BLD_Contact(uow).useBankContact()
            )
            .addEventReport(erBuilder)
            .getRecord();

        uow.commitWork();

        Call_Report__c er = (Call_Report__c) erBuilder.getRecord();

        StdBank_Ltn_EventReportCP.EmailAttributes attributes =
                StdBank_Ltn_EventReportCP.getEmailAttributes(er.Id, ugpAcc.Id, true);

        System.assertNotEquals(null, attributes);
    }

    @isTest
    static void hasClientTeam() {
        Account ugpAcc = (Account) new BLD_Account().useGroupParent()
            .name(DMN_Account.STANDARD_BANK_EMPLOYEES)
            .commitWork()
            .getRecord();

        System.assertEquals(false, StdBank_Ltn_EventReportCP.hasClientTeam(ugpAcc.Id));
    }

    @isTest
    static void testButtonEnabled() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        Call_Report__c eventReport = (Call_Report__c) new BLD_CallReport(uow)
            .linkWithParent(
                new BLD_Account(uow).useGroupParent()
            )
            .internal()
            .assign(UserInfo.getUserId())
            .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
            .commitWork()
            .getRecord();

        Boolean isButtonEnabled = StdBank_Ltn_EventReportCP.buttonsEnabled(eventReport.Id);
        System.assert(isButtonEnabled);
    }

    @isTest
    static void testButtonEnabled2() {
        User testUser;

        System.runAs(new User(Id = UserInfo.getUserId())) {
             testUser = (User) new BLD_USER().useCib().syncContact().commitWork().getRecord();
        }

        insert TEST_DataFactory.getEnvironmentVariable();
        Call_Report__c eventReport;
        System.runAs(testUser) {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            eventReport = (Call_Report__c) new BLD_CallReport(uow)
                .linkWithParent(
                    new BLD_Account(uow).useGroupParent()
                )
                .internal()
                .assign(UserInfo.getUserId())
                .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                .commitWork()
                .getRecord();
        }

        Boolean isButtonVisible = StdBank_Ltn_EventReportCP.buttonsEnabled(eventReport.Id);
        System.assert(isButtonVisible);
    }
}