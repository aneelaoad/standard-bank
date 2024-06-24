/**
 * @description Test class for BCH_DeleteResourcingRecords
 *
 * @author Konrad Bruszewski
 * @date July 2021
 */
@IsTest
public with sharing class BCH_DeleteResourcingRecords_TEST {

    @TestSetup
    public static void createTestData() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_GroupMember selGroupMember = (SEL_GroupMember) mocks.mock(SEL_GroupMember.class);

        mocks.startStubbing();
        mocks.when(selGroupMember.sObjectType()).thenReturn(GroupMember.SObjectType);
        mocks.when(selGroupMember.selectByUserOrGroupIdAndGroupDeveloperName(UserInfo.getUserId(), DMN_Resourcing.CORPORATE_FINANCE_RESOURCE_MANAGEMENT_GROUP))
            .thenReturn(new List<GroupMember>{ new GroupMember(UserOrGroupId = UserInfo.getUserId()) });
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selGroupMember);
        fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
        BLD_USER userBuilder1 = new BLD_USER('testOpTeamMember222@example.com', uow)
            .businessUnit('Corporate Finance')
            .profile(DCN_Profile.CUSTOM_STD_GENERIC);
        BLD_USER userBuilder2 = new BLD_USER('testNonOpTeamMember333@example.com', uow)
            .businessUnit('Corporate Finance')
            .profile(DCN_Profile.CUSTOM_STD_GENERIC);
        BLD_Opportunity oppBuilder1 = new BLD_Opportunity(uow)
            .addTeamMember(new BLD_OpportunityTeamMember(uow)
            .role('Account Manager')
            .user(userBuilder1));
        BLD_Opportunity oppBuilder2 = new BLD_Opportunity(uow)
            .addTeamMember(new BLD_OpportunityTeamMember(uow)
            .role('Account Manager')
            .user(userBuilder1));
        oppBuilder1.setDefaultData();
        oppBuilder2.setDefaultData();

        List<BLD_Resourcing> resources = new List<BLD_Resourcing>();
        Date friday = Date.today().toStartOfWeek().addDays(5);
        for (Integer i = 1 ; i < 251; i++) {
            Date weekendDate;
            if (i >= 201) {
                weekendDate = friday.addDays(7 * i);
            } else {
                weekendDate = friday.addDays(-35 * i);
            }
            System.debug('weekendDate: ' + weekendDate);
            resources.add(new BLD_Resourcing(uow).weekEndDate(weekendDate).resource(userBuilder1));
        }
        uow.commitWork();
    }

    @IsTest
    public static void testBatchJob() {
        fflib_ApexMocks mock = new fflib_ApexMocks();

        SEL_Resourcing selResourcing = (SEL_Resourcing) mock.mock(SEL_Resourcing.class);

        mock.startStubbing();
        mock.when(selResourcing.sObjectType()).thenReturn(Resourcing__c.SObjectType);
        mock.when(selResourcing.getQueryWithCustomCondition('Week_End_Date__c < LAST_N_DAYS:30'))
            .thenReturn('SELECT Id, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate FROM Resourcing__c WHERE Week_End_Date__c < LAST_N_DAYS:30');
        mock.stopStubbing();

        ORG_Application.selector.setMock(selResourcing);

        //given
        BCH_DeleteResourcingRecords batch = new BCH_DeleteResourcingRecords();
        Integer resourcingNumber = [SELECT Id FROM Resourcing__c WHERE Week_End_Date__c < LAST_N_DAYS:30].size();
        System.assertEquals(250, [SELECT Id FROM Resourcing__c].size(), 'There should not be Resourcing records in database at this point');

        //when
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        //then
        System.assertEquals(250 - resourcingNumber, [SELECT Id FROM Resourcing__c].size(), 'Resourcing records for users deleted in setup method should be deleted by the batch');
    }

    @IsTest
    public static void shouldNotDeleteUpdatedResourcing() {
        User corporateFinanceUser = [SELECT Id FROM User WHERE Username = 'testOpTeamMember222@example.com'];
        List<PermissionSetAssignment> permissionSetAssignmentsMock = new List<PermissionSetAssignment> {
            new PermissionSetAssignment(AssigneeId = corporateFinanceUser.Id, PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Resourcing' LIMIT 1].Id)
        };
    
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert permissionSetAssignmentsMock;
        }

        fflib_ApexMocks mock = new fflib_ApexMocks();

        SEL_Resourcing selResourcing = (SEL_Resourcing) mock.mock(SEL_Resourcing.class);

        mock.startStubbing();
        mock.when(selResourcing.sObjectType()).thenReturn(Resourcing__c.SObjectType);
        mock.when(selResourcing.getQueryWithCustomCondition('Week_End_Date__c < LAST_N_DAYS:30'))
            .thenReturn('SELECT Id, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate FROM Resourcing__c WHERE Week_End_Date__c < LAST_N_DAYS:30');
        mock.stopStubbing();

        ORG_Application.selector.setMock(selResourcing);

        //given
        BCH_DeleteResourcingRecords batch = new BCH_DeleteResourcingRecords();
        List<Resourcing__c> resourcings = new List<Resourcing__c>();
        List<Resourcing__c> existringResourcings = [SELECT Id FROM Resourcing__c WHERE Week_End_Date__c < LAST_N_DAYS:30 LIMIT 100];
        System.runAs(corporateFinanceUser) {
            for (Resourcing__c resourcing : existringResourcings) {
                resourcings.add(new Resourcing__c(
                    Id = resourcing.Id,
                    Time_Spent__c = 10
                ));
            }

            update resourcings;
        }

        Integer resourcingNumber = [SELECT Id FROM Resourcing__c WHERE Week_End_Date__c < LAST_N_DAYS:30].size();
        System.assertEquals(250, [SELECT Id FROM Resourcing__c].size(), 'There should not be Resourcing records in database at this point');

        //when
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        //then
        System.assertEquals(150, [SELECT Id FROM Resourcing__c].size(), 'Resourcing records for users deleted in setup method should be deleted by the batch');
    }

    @IsTest
    public static void testBatchJobWithException() {
        User corporateFinanceUser = [SELECT Id FROM User WHERE Username = 'testNonOpTeamMember333@example.com'];
        fflib_ApexMocks mock = new fflib_ApexMocks();

        SEL_Resourcing selResourcing = (SEL_Resourcing) mock.mock(SEL_Resourcing.class);

        mock.startStubbing();
        mock.when(selResourcing.sObjectType()).thenReturn(Resourcing__c.SObjectType);
        mock.when(selResourcing.getQueryWithCustomCondition('Week_End_Date__c < LAST_N_DAYS:30'))
            .thenReturn('SELECT Name, Resource__c, Resourcing_Type__c, OwnerId, Week_End_Date__c, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate FROM Resourcing__c WHERE Week_End_Date__c < LAST_N_DAYS:30');
        mock.stopStubbing();

        ORG_Application.selector.setMock(selResourcing);

        //given
        BCH_DeleteResourcingRecords batch = new BCH_DeleteResourcingRecords();
        List<Resourcing__Share> resourcingSharings = new List<Resourcing__Share>();
        System.assertEquals(250, [SELECT Id FROM Resourcing__c].size(), 'There should not be Resourcing records in database at this point');

        for (Resourcing__c resourcing : [SELECT Id FROM Resourcing__c]) {
            resourcingSharings.add(new Resourcing__Share(
                ParentId      = resourcing.Id,
                AccessLevel   = 'Read',
                UserOrGroupId = corporateFinanceUser.Id,
                RowCause      = Schema.Resourcing__Share.RowCause.Manual
            ));
        }

        insert resourcingSharings;
        //when
        System.runAs(corporateFinanceUser) {
            Test.startTest();
            Database.executeBatch(batch);
            Test.stopTest();
        }

        //then
        System.assertEquals(250, [SELECT Id FROM Resourcing__c].size(), 'Resourcing records for users deleted in setup method should be deleted by the batch');
    }
}