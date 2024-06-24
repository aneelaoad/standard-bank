/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 10/2010
    @description   : Test Class for trigger SA_EventReportAttendeeUpdate on
                      Call_Report_Attendees__c (after delete, after insert, after update)

    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 22/08/2011
    @ Modification Description : Removed isEnergyUser__c.

    @ Last Modified By: Stephen Moore
    @ Last Modified Date: 26/10/2011
    @ Description:  Case#1876: Removal for the 'CRT_Region__c' field  (line 35)

    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 06/01/2012
    @ Modification Description : Case#548 Regression Remove redundant fields

    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Last Modified Reason  : Case #6251- Change contact to use TestFatcory
                               API Version moved from 20 to 25

    @ Last Modified By  : Tracy Roberts
    @ Last Modified On  : 10/07/2012
    @ Last Modified Reason  : Changed @isTest to @isTest(SeeAllData=true)
                              Changed annotation to open up data access.

    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : Feb 2013
    @ Modification Description : EN 31 - Used TestDataUtilityClass
                                 Added Best Practices
                                 API Version moved from 25 to 27

    @ Last Modified By  :   Vishnu Vundavalli
    @ Last Modified On  :   26th March 2015
    @ Last Modified Reason  : EN-661, Added test method to cover the logic written in the Event Report Attendee trigger to update
                              to update the ERA's 2 fields which are used in reporting

    @ Last Modified By  :   Jana Cechova
    @ Last Modified On  :   May 2016
    @ Last Modified Reason  : US-1316

    @ Last Modified By      :   Manoj Gupta
    @ Last Modified On      :   17.06.2016
    @ Last Modified Reason  :   EN:1354,Changes related to New validation introduction
******************************************************************************************************/
@isTest(SeeAllData=false)
private class SA_TEST_EventReportAttendeeUpdate {

    @IsTest
    static void testTrigger() {
        insert TEST_DataFactory.getEnvironmentVariable();

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account accBld = new BLD_Account(uow).useChild()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES);

        BLD_Contact clientConBld = new BLD_Contact(uow).useClientContact()
                .account(accBld);

        List<Call_Report_Attendees__c> olstCallReportAttendees = new List<Call_Report_Attendees__c>();
        for (Integer i = 0; i < 2; i++) {
            olstCallReportAttendees.add(
                    (Call_Report_Attendees__c) new BLD_CallReportAttendee(uow)
                            .status(DMN_CallReportAttendee.STATUS_INVITED)
                            .contact(clientConBld)
                            .callReport(
                                    new BLD_CallReport(uow)
                                            .linkWithParent(accBld)
                                            .clientContact(clientConBld)
                                            .external()
                                            .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                            )
                            .getRecord()
            );
        }

        uow.commitWork();

        system.Test.startTest();
        try {
            //change status to add sharing rule then delete attendee to remove sharing rule
            olstCallReportAttendees[1].Status__c = 'Attended';
            update olstCallReportAttendees[1];

            //change status back to remove sharing rule
            olstCallReportAttendees[1].Status__c = 'Invited';
            update olstCallReportAttendees[1];

            //change status to add sharing rule then delete attendee to remove sharing rule
            olstCallReportAttendees[1].Status__c = 'Attended';
            update olstCallReportAttendees[1];
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }

    }

    @IsTest
    static void testInsertERAToUpdateReportingFields(){
        TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getUserProfileIds(),
                TEST_DataFactory.getCcSettings(),
                TEST_DataFactory.getEnvironmentVariable()
        });

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow).useChild()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES);

        BLD_Contact bankConBld1 = new BLD_Contact(uow).useBankContact()
                .account(accBld);
        BLD_Contact bankConBld2 = new BLD_Contact(uow).useBankContact()
                .account(accBld);

        uow.commitWork();

        User testuser = (User) new BLD_USER(uow).useSysAdmin()
                .division(DMN_User.GM_DIVISION)
                .contactSyncId(bankConBld1.getRecordId())
                .getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        new BLD_ClientTeam()
                .account(accBld)
                .user(testuser.Id)
                .clientAccess(DMN_ClientTeam.ACCESS_READ)
                .role(DMN_ClientTeam.ROLE_CLIENT_ANALYST)
                .commitWork();

        system.Test.startTest();

        BLD_CallReportAttendee craBld = new BLD_CallReportAttendee(uow)
                .callReport(
                        new BLD_CallReport(uow)
                                .internal()
                                .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                                .linkWithParent(accBld)
                                .assign(testuser.Id)
                )
                .status(DMN_CallReportAttendee.STATUS_INVITED)
                .contact(bankConBld1);
        try {
            uow.commitWork();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }

        uow.registerDirty(craBld.contact(bankConBld2));
        uow.commitWork();

        system.Test.stopTest();
    }
}