/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 18/05/2012
    @description   : Test class for ContactTrigger.trigger
    @ Last Modified By  : 
    @ Last Modified On  : 
    @ Modification Description : Case#6246 
    
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Modification Description : Case #6521- Change contact to use TestFatcory
    
    @ Last Modified By  : Tracy Roberts
    @ Last Modified On  : 10 October 2012
    @ Modification Description : Case #7064 - Change Test Class to use the TestFactory and include Client, 
                                              Opportunity, Non-User Client Team, 
                                              Event Report, Event Report Attendees.
                                              
    @ Last Modified By  : Charles Mutsu
    @ Last Modified On  : 1 March 2013
    @ Modification Description : Implemented TestDataUtilityClass for generating Test Data
                                 Changed the version from 20 to 27.
                                 
    @ Last Modified By  : Nikhita Reddy
    @ Last Modified On  : 12 March 2013
    @ Modification Description : Increased coverage for BankContact_User_Sync_Future class
    
    @ Last Modified by : Nitish Kumar
    @ Last Modified on : 16/07/2013
    @ Modification Description : Improved the Code coverage
    
    @ Last Modified By  :   Charles Mutsu    
    @ Last Modified On  :   05-Aug-2013
    @ Description   :       Updated API version from 27 to 28
    
    @ Last Modified By  :   Shubham Khilauria    
    @ Last Modified On  :   24- Jan -2013
    @ Description   :       Updated API version from 28 to 29.
                            Restructured(best practices) the class to appropriately cover ContactTrigger. 
                            Separate class is created to cover BankContact_User_Sync_Future
    
    @ Last Modified By  :   Vishnu Vundavalli        
    @ Last Modified On  :   26th March 2015
    @ Last Modified Reason  : EN-661, Added test method to cover the logic written to update 
                              ERABatchUpdateRequired flag on Client on Contact update,insert or delete

    @ Last Modified By      :   Prabhanshu Agrawal        
    @ Last Modified On      :   Apr 2015
    @ Last Modified Reason  :   EN-662, Added Meeting audience and Meeting type in the test data for validation rule

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 11, 2015 
    @ Modification Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx
    
******************************************************************************************************/
@isTest
public class TestContactTrigger {

    @TestSetup
    static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getCaseConfiguration(),
            TEST_DataFactory.getEmailAddress()
        });
    }

    @IsTest
    static void testAfterInsertContactTrigger() {
        User testUser = TEST_DataFactory.sysAdmin;
        BLD_Account accBld = (BLD_Account) new BLD_Account().useChild().commitWork();

        test.startTest();
        try {
            System.runAs(TestUser) {
                new BLD_Contact().useClientContact()
                        .account(accBld)
                        .commitWork();
            }
            test.stopTest();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
    
    @IsTest
    static void testAfterUpdateContactTrigger() {
        User testUser = TEST_DataFactory.sysAdmin;
        User testOwner = (User) new BLD_USER().useSysAdmin().getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
          insert testOwner;
        }
        BLD_Account accBld = (BLD_Account) new BLD_Account().useChild().commitWork();

        try {
            test.startTest();
            System.runAs(TestUser) {
                fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

                BLD_Contact conBld1 = new BLD_Contact(uow).useClientContact()
                        .account(accBld)
                        .addTeamMember(
                                new BLD_ContactTeamMember(uow)
                                        .primaryContactPerson(false)
                                        .user(testOwner.Id)
                        );
                BLD_Contact conBld2 = new BLD_Contact(uow).useClientContact()
                        .account(accBld)
                        .addTeamMember(
                                new BLD_ContactTeamMember(uow)
                                        .primaryContactPerson(true)
                                        .user(testOwner.Id)
                        );

                uow.commitWork();

                User_BankContact_Sync_HelperClass.alreadySyncUser = false;
                uow.registerDirty(conBld1.ownerId(testOwner.Id));
                uow.registerDirty(conBld2.ownerId(testOwner.Id));
                uow.commitWork();
            }
            test.stopTest();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }

    }

    @IsTest
    static void testAfterDeleteContactTrigger() {
        User testUser = TEST_DataFactory.sysAdmin;

        BLD_Account accBld = (BLD_Account) new BLD_Account().useChild().commitWork();

        test.startTest();
        System.runAs(TestUser) {
            Contact conRec = (Contact) new BLD_Contact().useClientContact()
                .account(accBld)
                .commitWork()
                .getRecord();
                
                //Delete the records
                delete conRec;
                Integer counter = [SELECT COUNT() from Contact WHERE Id = :conRec.Id];
                system.assertEquals(counter,0);
        }
        test.stopTest();
    }
    
    @IsTest
    static void testMatchingRecTypeContactTrigger() {
        User testUser = TEST_DataFactory.sysAdmin;
        test.startTest();
        try {
            System.runAs(TestUser) {
                new BLD_Contact().useBankContact()
                        .accountId(TEST_DataFactory.stdBankEmpAcc.Id)
                        .commitWork();
            }
            test.stopTest();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

    @IsTest
    static void testContactUpdateofCategory(){
        insert TEST_DataFactory.getErrorMessages();
        insert TEST_DataFactory.getCcSettings();
        try {
            test.startTest();
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            BLD_Account accBld1 = new BLD_Account(uow).useChild();

            BLD_Contact conBld1 = new BLD_Contact(uow).useClientContact()
                    .account(accBld1);
            BLD_Contact conBld2 = new BLD_Contact(uow).useClientContact()
                    .account(accBld1);

            new BLD_CallReport(uow)
                    .internal()
                    .meetingPurpose(DMN_CallReport.DAY_TO_DAY_MEETING)
                    .linkWithParent(accBld1)
                    .addAttendee(
                    new BLD_CallReportAttendee(uow)
                            .contact(conBld1)
                            .status(DMN_CallReportAttendee.STATUS_INVITED)
            );

            new BLD_CallReport(uow)
                    .internal()
                    .meetingPurpose(DMN_CallReport.DAY_TO_DAY_MEETING)
                    .linkWithParent(accBld1)
                    .addAttendee(
                    new BLD_CallReportAttendee(uow)
                            .contact(conBld2)
                            .status(DMN_CallReportAttendee.STATUS_INVITED)
            );

            BLD_Account accBld2 = new BLD_Account(uow).useChild()
                    .addEventReport(
                            new BLD_CallReport(uow)
                                    .internal()
                                    .meetingPurpose(DMN_CallReport.DAY_TO_DAY_MEETING)
                    );

            uow.commitWork();

            test.stopTest();
            uow.registerDirty(conBld1.account(accBld2));
            uow.registerDirty(conBld2.contactCategory(DMN_Contact.CATEGORY_MANAGER));
            uow.commitWork();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
     }
}