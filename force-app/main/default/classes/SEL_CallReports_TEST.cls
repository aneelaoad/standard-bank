/**
 * @description       : Tests for SEL_CallReports
 * @author            : Derek Hughes
 * @group             : Tests
 * @last modified on  : 17-05-2023
 * @last modified by  : Derek Hughes
**/
@IsTest
public with sharing class SEL_CallReports_TEST {

    private static Integer  revenueCurrentYear = 5000;
	private static Integer  budgetNextYear = 6000;

    @TestSetup
    static void testSetup() {
        insert TEST_DataFactory.getEnvironmentVariable();

        update new Account(Id = TEST_DataFactory.stdBankEmpAccProspect.Id, CIF_Client_Active_Code__c = 'A');
        
        BLD_Account bankAccBld = new BLD_Account(TEST_DataFactory.stdBankEmpAccProspect, ABS_ObjectBuilderBase.getNewUnitOfWork());

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        bankAccBld.addGlobalClientRevenue(
            new BLD_GlobalClientRevenue(uow).currentAndPreviousYear()
                .snapshotDate(System.today())
                .clientValueZarCurrentYear(revenueCurrentYear)
                .budgetZARNextYear(budgetNextYear)
        );

        List<BLD_CallReport> callReportBuilders = new List<BLD_CallReport>();
        for (Integer i = 0; i < 7; i++) {
            String attendeeStatus;
            Datetime endDate;
            if (i / 2 == 0) {
                attendeeStatus = DMN_CallReportAttendee.STATUS_ATTENDED;
                endDate = Datetime.now().addDays(-3);
            } else {
                attendeeStatus = DMN_CallReportAttendee.STATUS_INVITED;
                endDate = Datetime.now().addDays(3);
            }
            BLD_Contact conBld = new BLD_Contact(uow).useBankContact()
                .account(bankAccBld);
            callReportBuilders.add(new BLD_CallReport(uow)
                .internal()
                .assign(UserInfo.getUserId())
                .meetingAudience('Internal')
                .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                .linkWithParent(bankAccBld)
                .startDate(endDate.addDays(-1))
                .endDate(endDate)
                .addAttendee(
                    new BLD_CallReportAttendee(uow)
                        .contact(conBld)
                        .status(attendeeStatus)
                ));
        }

        uow.commitWork();
    
    }

    @IsTest 
    public static void test1() {

        List<Account> accounts = [SELECT Id, Name FROM Account];
        Set<Id> accountIds = new Set<Id>();
        for (Account account : accounts) {
            accountIds.add(account.Id);
        }

        List<Call_Report__c> callReports = [SELECT Id, EventId__c FROM Call_Report__c];
        Set<Id> eventIds = new Set<Id>();
        for (Call_Report__c callReport : callReports) {
            eventIds.add(callReport.Id);
        }

        Test.startTest();
            // test constructors
            SEL_CallReports selector1 = SEL_CallReports.newInstance();
            SEL_CallReports selector2 = new SEL_CallReports(false, false, false);
            SObjectType objectType = selector1.getSObjectType();


            // test selectors
            List<Call_Report__c> callReports1 = selector2.selectByEventIds(eventIds);

            List<Call_Report__c> callReports2 = selector2.selectThisYearEndByClientIdsAndAudience(accountIds, new Set<String>{'Internal'});

        Test.stopTest();

        Assert.areEqual(Call_Report__c.SObjectType, objectType, 'Incorrect Object Type returned.');
        Assert.areEqual(0, callReports1.size(), 'There should be no Event Reports with Event Ids');
        Assert.areEqual(7, callReports2.size(), 'Incorrect number of Event Reports for the Accounts.');

    }

}