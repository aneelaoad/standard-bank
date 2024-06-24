/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 10/2010
    @description   : Test Class for trigger SA_CreateEventReport on
                      Event (before insert, after insert, after update, after delete)

    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 22/08/2011
    @ Modification Description : Removed isEnergyUser__c.

    @ Last Modified By: Stephen Moore
    @ Last Modified Date: 26/10/2011
    @ Description:  Case#1876: Removal for the 'CRT_Region__c' field  (Line 37)

    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 06/01/2012
    @ Modification Description : Case#548 Regression Remove redundant fields

    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Last Modified Reason  :  Case #6521- Change contact to use TestFatcory
                               API Version moved from 18 to 25

    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : Feb 2013
    @ Modification Description : EN 31 - Used TestDataUtilityClass
                                 Added Best Practices and Improved code coverage
                                 API Version moved from 25 to 27

    @ Last Modified By  : Abhishek V
    @ Last Modified On  : Oct 2016
    @ Modification Description : US: 1548 - To assign value to Report_Client_Contact__c on Event records owing to new design

******************************************************************************************************/
@isTest(SeeAllData=false)
private class SA_TEST_CreateEventReportTrigger{

    @IsTest
    static void testTrigger(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        Test.startTest();

        BLD_Account accBld = new BLD_Account(uow).useChild()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES);

        BLD_Contact conBld = new BLD_Contact(uow).useClientContact()
                .account(accBld);

        BLD_Event eventBld = new BLD_Event(uow)
                .linkToParent(accBld)
                .linkToParent(conBld)
                .reportContact(conBld)
                .startDate(System.now())
                .stopDate(System.now().addMinutes(60));

        uow.commitWork();

        new BLD_CallReport(uow)
                .internal()
                .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                .linkWithParent(accBld);
        try{
            uow.commitWork();
        }
        catch(Exception ex){
            System.debug(ex.getMessage());
            System.assert(false);
        }

        uow.registerDirty(eventBld.callReportCreated(true));
        uow.commitWork();

        uow.registerDeleted(eventBld);
        uow.commitWork();

        Test.stopTest();

    }

    @IsTest
    static void testTrigger2(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow).useChild()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES);

        BLD_Contact conBld = new BLD_Contact(uow).useClientContact()
                .account(accBld);


        BLD_Event eventBld = new BLD_Event(uow)
                .linkToParent(accBld)
                .linkToParent(conBld)
                .reportContact(conBld)
                .externalMeeting()
                .startDate(System.now())
                .durationInMinutes(1440)
                .allDayEvent(true);

        uow.commitWork();

        new BLD_CallReport(uow)
                .external()
                .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                .linkWithParent(accBld)
                .clientContact(conBld);
        try{
            uow.commitWork();
        }
        catch(Exception ex){
            System.assert(false);
        }

        Test.startTest();

        uow.registerDeleted(eventBld);
        uow.commitWork();

        Test.stopTest();

    }
}