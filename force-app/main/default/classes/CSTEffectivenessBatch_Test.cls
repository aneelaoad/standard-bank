/****************************************************************************\
    @ Author        : Petr Roubal
    @ Date          : 30 Jun 2015
    @ Test File     : NA
    Function        : Contains all testing for the class CSTEffectivenessBatch
    @description Test class for CST EffectivenessBatch
******************************************************************************/
@isTest(SeeAllData=false)
private class CSTEffectivenessBatch_Test {
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

        new BLD_Opportunity(uow)
            .client(bankAccBld)
            .eventReportSource(callReportBuilders[0]);
        new BLD_Opportunity(uow)
            .client(bankAccBld)
            .eventReportSource(callReportBuilders[6]);

        new BLD_Opportunity(uow)
            .client(bankAccBld)
            .develop()
            .addProduct(
                new BLD_Product(uow)
                .useCapitalMarkets()
                .grandParentProduct(DMN_SB_Product.GPP_CASH_MANAGEMENT)
                .termTenor(9)
                .totalFees(250));

        BLD_Opportunity oppToClose = new BLD_Opportunity(uow)
            .client(bankAccBld)
            .stage(DMN_Opportunity.ST_DEVELOP)
            .addProduct(
                new BLD_Product(uow)
                .useCapitalMarkets()
                .grandParentProduct(DMN_SB_Product.GPP_CASH_MANAGEMENT)
                .termTenor(9)
                .totalFees(250));

        uow.commitWork();
        
        oppToClose.actualCloseDate(System.today());
        oppToClose.closedWon();
        oppToClose.registerDirty();
        uow.commitWork();


        insert new CSTTeamRoleRanking__c(
            AccountFieldName__c = 'IB_Champion__c',
            CSTTeamRoleRanking__c = '1',
            Name = 'IB Champion'
        );

    }
    @IsTest
    static void testCSTEffectivenessBatchWithExternalMeetings() {
        Test.startTest();
        
        Contact cons = [SELECT Id, RecordtypeId FROM Contact LIMIT 1];
        cons.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Contact.OBJ_NAME, DMN_Contact.RTD_CLIENT);
        update cons;
        List<Call_Report__c> lstCallRep = [SELECT Id, Meeting_Audience__c, Meeting_Purpose__c, Contact__c FROM Call_Report__c];
        lstCallRep[0].Meeting_Audience__c = 'External';
        lstCallRep[0].Meeting_Purpose__c = 'Market Research Update';
        lstCallRep[0].Report_Client_Contact__c  = cons.Id;
        lstCallRep[4].Meeting_Audience__c = 'External';
        lstCallRep[4].Meeting_Purpose__c = 'Market Research Update';
        lstCallRep[4].Report_Client_Contact__c  = cons.Id;
        update lstCallRep;

        List<Call_Report_Attendees__c> lstCallRepAtt = [SELECT Id, Client_Team_Role__c FROM Call_Report_Attendees__c];
        for (Call_Report_Attendees__c att : lstCallRepAtt) {
            att.Client_Team_Role__c = 'IB Champion';
        }

        update lstCallRepAtt;
        
        Database.executeBatch(new CSTEffectivenessBatch());
        Test.stopTest();
        List<Account> accounts = [
            SELECT Id,
                Actual_CY_Revenue__c,
                Client_Summary_Last_Updated__c,
                Core_Team_Members_on_External_Meetings__c,
                Core_Team_Members_on_Internal_Meetings__c,
                External_Meetings_Completed__c,
                External_Meetings_Scheduled__c,
                Internal_Meetings_Completed__c,
                Internal_Meetings_Scheduled__c,
                Number_of_Pipeline_Opportunities__c,
                Number_of_Won_Opportunities__c,
                Opportunities_from_External_Meetings__c,
                Opportunities_from_Internal_Meetings__c,
                Pipeline_Opportunities_CY_Revenue__c,
                Won_Opportunities_CY_Revenue__c
            FROM Account
        ];

        Assert.areEqual(accounts.isEmpty(), false, 'Found accounts list should not be empty');
        Assert.areNotEqual(0, accounts.size(), 'Found accounts list should not be empty');
        Assert.areEqual(DateTime.now().day(), accounts.get(0).Client_Summary_Last_Updated__c.day(), 'Found ' + accounts.get(0).Client_Summary_Last_Updated__c.day()  + ' but expected ' + DateTime.now().day());
        Assert.areEqual(1, accounts.get(0).Core_Team_Members_on_External_Meetings__c, 'Found ' + accounts.get(0).Core_Team_Members_on_External_Meetings__c  + ' but expected 1');
        Assert.areEqual(1, accounts.get(0).Core_Team_Members_on_Internal_Meetings__c, 'Found ' + accounts.get(0).Core_Team_Members_on_Internal_Meetings__c  + ' but expected 1');
        Assert.areEqual(1, accounts.get(0).External_Meetings_Completed__c, 'Found ' + accounts.get(0).External_Meetings_Completed__c  + ' but expected 1');
        Assert.areEqual(1, accounts.get(0).External_Meetings_Scheduled__c, 'Found ' + accounts.get(0).External_Meetings_Scheduled__c  + ' but expected 1');
        Assert.areEqual(1, accounts.get(0).Internal_Meetings_Completed__c, 'Found ' + accounts.get(0).Internal_Meetings_Completed__c  + ' but expected 1');
        Assert.areEqual(4, accounts.get(0).Internal_Meetings_Scheduled__c, 'Found ' + accounts.get(0).Internal_Meetings_Scheduled__c  + ' but expected 4');
        Assert.areEqual(3, accounts.get(0).Number_of_Pipeline_Opportunities__c, 'Found ' + accounts.get(0).Number_of_Pipeline_Opportunities__c  + ' but expected 3');
        Assert.areEqual(1, accounts.get(0).Number_of_Won_Opportunities__c, 'Found ' + accounts.get(0).Number_of_Won_Opportunities__c  + ' but expected 1');
        Assert.areEqual(1, accounts.get(0).Opportunities_from_External_Meetings__c, 'Found ' + accounts.get(0).Opportunities_from_External_Meetings__c  + ' but expected 1');
        Assert.areEqual(1, accounts.get(0).Opportunities_from_Internal_Meetings__c, 'Found ' + accounts.get(0).Opportunities_from_Internal_Meetings__c  + ' but expected 1');
        Assert.areEqual(272.00, accounts.get(0).Pipeline_Opportunities_CY_Revenue__c, 'Found ' + accounts.get(0).Pipeline_Opportunities_CY_Revenue__c  + ' but expected 272.00');
        Assert.areEqual(272.00, accounts.get(0).Won_Opportunities_CY_Revenue__c, 'Found ' + accounts.get(0).Won_Opportunities_CY_Revenue__c  + ' but expected 272.00');
    }

    @IsTest
    static void testCSTEffectivenessBatch() {
       Map<String,Double> mapRate = new Map<String,Double>();
        mapRate.put('50',33);
        mapRate.put('89',45);
        CSTEffectivenessBatch.currencyConverter ss = new  CSTEffectivenessBatch.currencyConverter();
        Test.startTest();
        ss.convert(33, '50', mapRate, '89');
        List<CronTrigger> jobIds = new List<CronTrigger>();
        jobIds = [SELECT CronJobDetail.Name,Id FROM CronTrigger];
        for (CronTrigger job : jobIds) {
            if (job.CronJobDetail.Name == 'CSTEffectivenessBatch') {
            	System.abortJob(job.id);
        	}
        }
        Database.executeBatch(new CSTEffectivenessBatch());

        Test.stopTest();

        List<Account> accounts = [
            SELECT Id,
                Actual_CY_Revenue__c,
                Client_Summary_Last_Updated__c,
                Core_Team_Members_on_External_Meetings__c,
                Core_Team_Members_on_Internal_Meetings__c,
                External_Meetings_Completed__c,
                External_Meetings_Scheduled__c,
                Internal_Meetings_Completed__c,
                Internal_Meetings_Scheduled__c,
                Number_of_Pipeline_Opportunities__c,
                Number_of_Won_Opportunities__c,
                Opportunities_from_External_Meetings__c,
                Opportunities_from_Internal_Meetings__c,
                Pipeline_Opportunities_CY_Revenue__c,
                Won_Opportunities_CY_Revenue__c
            FROM Account
        ];

        AsyncApexJob asyncjb = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob Limit 1];

        CSTEffectivenessBatch.sendemail(asyncjb);

        Assert.areEqual(accounts.isEmpty(), false, 'Found accounts list should not be empty');
        Assert.areNotEqual(0, accounts.size(), 'Found accounts list should not be empty');
        Assert.areEqual(DateTime.now().day(), accounts.get(0).Client_Summary_Last_Updated__c.day(), 'Found ' + accounts.get(0).Client_Summary_Last_Updated__c.day()  + ' but expected ' + DateTime.now().day());
        Assert.areEqual(0, accounts.get(0).Core_Team_Members_on_External_Meetings__c, 'Found ' + accounts.get(0).Core_Team_Members_on_External_Meetings__c  + ' but expected 0');
        Assert.areEqual(0, accounts.get(0).Core_Team_Members_on_Internal_Meetings__c, 'Found ' + accounts.get(0).Core_Team_Members_on_Internal_Meetings__c  + ' but expected 0');
        Assert.areEqual(0, accounts.get(0).External_Meetings_Completed__c, 'Found ' + accounts.get(0).External_Meetings_Completed__c  + ' but expected 0');
        Assert.areEqual(0, accounts.get(0).External_Meetings_Scheduled__c, 'Found ' + accounts.get(0).External_Meetings_Scheduled__c  + ' but expected 0');
        Assert.areEqual(2, accounts.get(0).Internal_Meetings_Completed__c, 'Found ' + accounts.get(0).Internal_Meetings_Completed__c  + ' but expected 2');
        Assert.areEqual(5, accounts.get(0).Internal_Meetings_Scheduled__c, 'Found ' + accounts.get(0).Internal_Meetings_Scheduled__c  + ' but expected 5');
        Assert.areEqual(3, accounts.get(0).Number_of_Pipeline_Opportunities__c, 'Found ' + accounts.get(0).Number_of_Pipeline_Opportunities__c  + ' but expected 3');
        Assert.areEqual(1, accounts.get(0).Number_of_Won_Opportunities__c, 'Found ' + accounts.get(0).Number_of_Won_Opportunities__c  + ' but expected 1');
        Assert.areEqual(0, accounts.get(0).Opportunities_from_External_Meetings__c, 'Found ' + accounts.get(0).Opportunities_from_External_Meetings__c  + ' but expected 0');
        Assert.areEqual(2, accounts.get(0).Opportunities_from_Internal_Meetings__c, 'Found ' + accounts.get(0).Opportunities_from_Internal_Meetings__c  + ' but expected 2');
        Assert.areEqual(272.00, accounts.get(0).Pipeline_Opportunities_CY_Revenue__c, 'Found ' + accounts.get(0).Pipeline_Opportunities_CY_Revenue__c  + ' but expected 272.00');
        Assert.areEqual(272.00, accounts.get(0).Won_Opportunities_CY_Revenue__c, 'Found ' + accounts.get(0).Won_Opportunities_CY_Revenue__c  + ' but expected 272.00');
    }
}