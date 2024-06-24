/*************************************************************************
    @ Author        : psvestka
    @ Date          : 24. 7. 2015
    @ Test File     : {CSTIndividualEffectivenessBatch_Test}
    @description    : Reference to the Case/SOW and description of code
    @
    @ Audit Trial           :   Repeating block for each change to the code
    @
    @ Last Modified By      :   Jiri Lahoda
    @ Last Modified On      :   10.8.2015
    @ Last Modified Reason  :   Functional repair of whole test

    @ Last Modified By      :   Petr Svestka
    @ Last Modified On      :   3.9.2015
    @ Last Modified Reason  :   divided tests into testOriginal (with test User created) and testCSTEffectivenessBatch (with UserInfo) to make sure at least one of them will pass
                                reason: was that the previous code started to fail with no obvious reason
                                
    @ Last Modified By      :   Manoj Gupta
    @ Last Modified On      :   15.06.2016
    @ Last Modified Reason  :   EN:1352,replaced Client__c with Relate_to_Client__c    

    @ Last Modified By      :   Manoj Gupta
    @ Last Modified On      :   17.06.2016
    @ Last Modified Reason  :   EN:1354,Changes related to New validation introduction. olstContact will have clientCintact Record Types and system.Test.startTest moved
    
    @ Last Modified By      :   Manoj Gupta
    @ Last Modified On      :   18.07.2016
    @ Last Modified Reason  :   EN:1465,Adjusted Test class to populate Core_Meeting field value    
    
    @ Last Modified By      :  	Jana Cechova
    @ Last Modified On      :   27.12.2016
    @ Last Modified Reason  :   Updated data for create because THIS_YEAR was not actually
****************************************************************************/

@isTest(SeeAllData=false)
private class CSTIndividualEffectivenessBatch_Test {

    //list of meeting types for external nmeetings
    private static Set<String> coreMeetingTypes = new Set<String> {
        DMN_CallReport.CLIENT_ENTERTAINMENT,
        DMN_CallReport.CLIENT_MEETING,
        DMN_CallReport.CLIENT_ROAD_SHOW,
        DMN_CallReport.MARKET_RESEARCH_UPDATE,
        DMN_CallReport.CLIENT_SERVICE_DISCUSSION
    };
    private static Set<String> dayToDayMeetingTypes = new Set<String> {
        DMN_CallReport.CLIENT_CONFERENCE_CALL,
        DMN_CallReport.CLIENT_SOCIAL,
        DMN_CallReport.CLIENT_TRAINING,
        DMN_CallReport.CLIENT_EMAIL
    };

    @IsTest
    private static void testOriginal() {
        insert TEST_DataFactory.getEnvironmentVariable();
        User testuser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            testuser = (User) new BLD_USER().useSysAdmin()
                .division(DMN_User.COMMB_DIVISION)
                .firstName('Fname')
                .lastName('Lname')
                .commitWork()
                .getRecord();
        }

        System.runAs(testuser) {

            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            BLD_Account accBuilder = new BLD_Account(uow).useCommB()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES)
                .addTask(
                    new BLD_Task(uow)
                )
                .addTask(
                    new BLD_Task(uow)
                        .status(DMN_Task.STATUS_COMPLETED)
                        .activityDate(System.today().addDays(-1))
                )
                .addCase(
                    new BLD_Case(uow).useClientCase()
                );

            new BLD_Contact(uow).useBankContact()
                .account(accBuilder)
                .addResolvedCase(
                    new BLD_Case(uow).useClientCase()
                        .close()
                        .account(accBuilder)
                );
            BLD_Contact clientContBld = new BLD_Contact(uow).useClientContact()
                .name(testuser.FirstName, testuser.LastName)
                .account(accBuilder);

            List<BLD_CallReport> callReportBuilders = new List<BLD_CallReport>();
            for (Integer i = 0; i < 5; i++) {
                callReportBuilders.add(new BLD_CallReport(uow)
                    .internal()
                    .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                    .assign(testuser.Id)
                    .linkWithParent(accBuilder)
                    .addAttendee(
                        new BLD_CallReportAttendee(uow)
                            .contact(clientContBld)
                            .status(DMN_CallReportAttendee.STATUS_ATTENDED)
                    ));
            }
            callReportBuilders.add(new BLD_CallReport(uow)
                .internal()
                .meetingPurpose(DMN_CallReport.DAY_TO_DAY_MEETING)
                .assign(testuser.Id)
                .linkWithParent(accBuilder)
                .addAttendee(
                    new BLD_CallReportAttendee(uow)
                        .contact(clientContBld)
                        .status(DMN_CallReportAttendee.STATUS_ATTENDED)
                ));
            for (String str : coreMeetingTypes) {
                callReportBuilders.add(new BLD_CallReport(uow)
                    .external()
                    .meetingPurpose(str)
                    .clientContact(clientContBld)
                    .assign(testuser.Id)
                    .linkWithParent(accBuilder)
                    .addAttendee(
                        new BLD_CallReportAttendee(uow)
                            .contact(clientContBld)
                            .status(DMN_CallReportAttendee.STATUS_ATTENDED)
                    ));
            }
            for (String str : dayToDayMeetingTypes) {
                callReportBuilders.add(new BLD_CallReport(uow)
                    .external()
                    .meetingPurpose(str)
                    .clientContact(clientContBld)
                    .assign(testuser.Id)
                    .linkWithParent(accBuilder)
                    .addAttendee(
                        new BLD_CallReportAttendee(uow)
                            .contact(clientContBld)
                            .status(DMN_CallReportAttendee.STATUS_ATTENDED)
                    ));
            }

            new BLD_Opportunity(uow)
                .client(accBuilder)
                .eventReportSource(callReportBuilders[3]);
            new BLD_Opportunity(uow)
                .client(accBuilder)
                .eventReportSource(callReportBuilders[6]);

            uow.commitWork();

        }

        Test.startTest();
        CSTIndividualEffectivenessBatch batch = new CSTIndividualEffectivenessBatch();
        List<User> modifiedUsers = batch.enrichUser(new Map<Id, User> { testUser.Id => testuser });
        Test.stopTest();

        Assert.areEqual(5, modifiedUsers.get(0).Internal_Core_Meetings_Attended__c, 'Found ' + modifiedUsers.get(0).Internal_Core_Meetings_Attended__c  + ' but expected 5');
        Assert.areEqual(1, modifiedUsers.get(0).Internal_Day_to_Day_Meetings_Attended__c, 'Found ' + modifiedUsers.get(0).Internal_Day_to_Day_Meetings_Attended__c  + ' but expected 1');
        Assert.areEqual(5, modifiedUsers.get(0).Total_Internal_Core_Meetings__c, 'Found ' + modifiedUsers.get(0).Total_Internal_Core_Meetings__c  + ' but expected 5'); 
        Assert.areEqual(1, modifiedUsers.get(0).Total_Internal_Day_to_Day_Meetings__c, 'Found ' + modifiedUsers.get(0).Total_Internal_Day_to_Day_Meetings__c  + ' but expected 1');
        Assert.areEqual(1, modifiedUsers.get(0).Opportunities_from_Internal_Meetings__c, 'Found ' + modifiedUsers.get(0).Opportunities_from_Internal_Meetings__c  + ' but expected 1');
        Assert.areEqual(2, modifiedUsers.get(0).External_Core_Meetings_Attended__c, 'Found ' + modifiedUsers.get(0).External_Core_Meetings_Attended__c  + ' but expected 2');
        Assert.areEqual(4, modifiedUsers.get(0).External_Day_to_Day_Meetings_Attended__c, 'Found ' + modifiedUsers.get(0).External_Day_to_Day_Meetings_Attended__c  + ' but expected 4');
        Assert.areEqual(2, modifiedUsers.get(0).Total_External_Core_Meetings__c, 'Found ' + modifiedUsers.get(0).Total_External_Core_Meetings__c  + ' but expected 2');
        Assert.areEqual(4, modifiedUsers.get(0).Total_External_Day_to_Day_Meetings__c, 'Found ' + modifiedUsers.get(0).Total_External_Day_to_Day_Meetings__c  + ' but expected 4');
        Assert.areEqual(1, modifiedUsers.get(0).Opportunities_from_External_Meetings__c, 'Found ' + modifiedUsers.get(0).Opportunities_from_External_Meetings__c  + ' but expected 1');
        Assert.areEqual(1, modifiedUsers.get(0).Closed_Client_Cases__c, 'Found ' + modifiedUsers.get(0).Closed_Client_Cases__c  + ' but expected 1'); 
        Assert.areEqual(1, modifiedUsers.get(0).Incomplete_Client_Cases__c, 'Found ' + modifiedUsers.get(0).Incomplete_Client_Cases__c  + ' but expected 1'); 
        Assert.areEqual(1, modifiedUsers.get(0).Incomplete_Tasks__c, 'Found ' + modifiedUsers.get(0).Incomplete_Tasks__c  + ' but expected 1');
        Assert.areEqual(1, modifiedUsers.get(0).Complete_Tasks__c, 'Found ' + modifiedUsers.get(0).Complete_Tasks__c  + ' but expected 1');       
    }

}