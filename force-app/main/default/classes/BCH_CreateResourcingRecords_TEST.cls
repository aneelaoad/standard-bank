/**
 * @description Test class for BCH_CreateResourcingRecords
 *
 * @author Konrad Bruszewski
 * @date July 2021
 */
@IsTest
public with sharing class BCH_CreateResourcingRecords_TEST {

    @TestSetup
    public static void createTestData() {
        fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
        BLD_USER userBuilder = new BLD_USER('testOpTeamMember222@example.com', uow)
            .businessUnit('Corporate Finance')
            .profile(DCN_Profile.CUSTOM_STD_GENERIC);
        BLD_Opportunity oppBuilder1 = new BLD_Opportunity(uow)
            .addTeamMember(new BLD_OpportunityTeamMember(uow)
                .role('Account Manager')
                .user(userBuilder));
        BLD_Opportunity oppBuilder2 = new BLD_Opportunity(uow)
            .addTeamMember(new BLD_OpportunityTeamMember(uow)
                .role('Account Manager')
                .user(userBuilder));
        oppBuilder1.setDefaultData();
        oppBuilder2.setDefaultData();
        uow.commitWork();
    }

    @IsTest
    public static void testBatchJob() {
        User corporateFinanceUser = [SELECT Id FROM User WHERE Username = 'testOpTeamMember222@example.com'];
        List<PermissionSetAssignment> permissionSetAssignmentsMock = new List<PermissionSetAssignment> {
            new PermissionSetAssignment(AssigneeId = corporateFinanceUser.Id, PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Resourcing' LIMIT 1].Id)
        };

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert permissionSetAssignmentsMock;
        }

        fflib_ApexMocks mock = new fflib_ApexMocks();

        SEL_PermissionSetAssignments selPermissionSetAssignments = (SEL_PermissionSetAssignments) mock.mock(SEL_PermissionSetAssignments.class);

        mock.startStubbing();
        mock.when(selPermissionSetAssignments.sObjectType()).thenReturn(PermissionSetAssignment.SObjectType);
        mock.when(selPermissionSetAssignments.selectByPermissionSetNameAndAssigneeIds('Resourcing', new Set<Id> { corporateFinanceUser.Id }))
            .thenReturn(permissionSetAssignmentsMock);
        mock.when(selPermissionSetAssignments.getQueryWithCustomCondition('PermissionSet.Name = \'Resourcing\' AND Assignee.IsActive = true'))
            .thenReturn('SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSet.Name = \'Resourcing\' AND Assignee.IsActive = true');
        mock.stopStubbing();

        ORG_Application.selector.setMock(selPermissionSetAssignments);

        //given
        BCH_CreateResourcingRecords batch = new BCH_CreateResourcingRecords();
        System.assertEquals(0, [SELECT Id FROM Resourcing__c].size(), 'There should not be Resourcing records in database at this point');

        //when
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        Integer resourcingNumber = (Resourcing__c.Resourcing_Type__c.getDescribe().getPicklistValues().size() - 1) * 
            [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Resourcing' AND Assignee.IsActive = true].size();

        //then
        //2 is not random number it's the number of the resourcing records that should be created for opportunities team members.
        System.assertEquals(resourcingNumber + 2, [SELECT Id FROM Resourcing__c].size(), 'Resourcing records for users created in setup method should be created by the batch');
    }

    @IsTest
    public static void shouldNotCreateDuplicateResourcing() {
        //given
        User corporateFinanceUser = [SELECT Id FROM User WHERE Username = 'testOpTeamMember222@example.com'];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
        List<PermissionSetAssignment> permissionSetAssignmentsMock = new List<PermissionSetAssignment> {
            new PermissionSetAssignment(AssigneeId = corporateFinanceUser.Id, PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Resourcing' LIMIT 1].Id)
        };

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert permissionSetAssignmentsMock;
        }

        //batch job will try to create duplicate of this Resourcing
        BCH_CreateResourcingRecords batch = new BCH_CreateResourcingRecords();
        Resourcing__c res = (Resourcing__c) new BLD_Resourcing(uow)
            .setDefaultData(DMN_Resourcing.OPPORTUNITY_SOURCE)
            .weekEndDate(UTL_Resourcing.getLastWeekFridayDate())
            .resourceId(corporateFinanceUser.Id)
            .opportunityId(testOpportunity.Id)
            .ownerId(corporateFinanceUser.Id)
            .getRecord();

        fflib_ApexMocks mock = new fflib_ApexMocks();

        //mock selector to be able to create resourcing for other user (check out DMN_Resourcing class)
        SEL_GroupMember selGroupMember = (SEL_GroupMember) mock.mock(SEL_GroupMember.class);
        SEL_PermissionSetAssignments selPermissionSetAssignments = (SEL_PermissionSetAssignments) mock.mock(SEL_PermissionSetAssignments.class);

        mock.startStubbing();
        mock.when(selGroupMember.sObjectType()).thenReturn(GroupMember.SObjectType);
        mock.when(selGroupMember.selectByUserOrGroupIdAndGroupDeveloperName(UserInfo.getUserId(), DMN_Resourcing.CORPORATE_FINANCE_RESOURCE_MANAGEMENT_GROUP))
            .thenReturn(new List<GroupMember>{new GroupMember(UserOrGroupId=UserInfo.getUserId())});
        mock.when(selPermissionSetAssignments.sObjectType()).thenReturn(PermissionSetAssignment.SObjectType);
        mock.when(selPermissionSetAssignments.selectByPermissionSetNameAndAssigneeIds('Resourcing', new Set<Id> { corporateFinanceUser.Id }))
            .thenReturn(permissionSetAssignmentsMock);
        mock.when(selPermissionSetAssignments.getQueryWithCustomCondition('PermissionSet.Name = \'Resourcing\' AND Assignee.IsActive = true'))
            .thenReturn('SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSet.Name = \'Resourcing\' AND Assignee.IsActive = true');
        mock.stopStubbing();

        ORG_Application.selector.setMock(selGroupMember);
        ORG_Application.selector.setMock(selPermissionSetAssignments);

        uow.commitWork();
        System.assertEquals(1, [SELECT Id FROM Resourcing__c].size(), 'There should be one Resourcing record in the database before executing batch');

        //when
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        Integer resourcingNumber = ((Resourcing__c.Resourcing_Type__c.getDescribe().getPicklistValues().size() - 1) *
            [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Resourcing' AND Assignee.IsActive = true].size());

        //then
        //2 is not random number it's the number of the resourcing records that should be created for opportunities team members.
        System.assertEquals(resourcingNumber + 2, [SELECT Id FROM Resourcing__c].size(), 'One new Resourcing should be created by the batch. One record should fail due to duplicate');
    }

    @IsTest
    public static void testBatchJobWithWrongValue() {
        User corporateFinanceUser = [SELECT Id FROM User WHERE Username = 'testOpTeamMember222@example.com'];
        List<PermissionSetAssignment> permissionSetAssignmentsMock = new List<PermissionSetAssignment> {
            new PermissionSetAssignment(AssigneeId = corporateFinanceUser.Id, PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Resourcing' LIMIT 1].Id)
        };

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert permissionSetAssignmentsMock;
        }

        fflib_ApexMocks mock = new fflib_ApexMocks();

        SEL_PermissionSetAssignments selPermissionSetAssignments = (SEL_PermissionSetAssignments) mock.mock(SEL_PermissionSetAssignments.class);

        mock.startStubbing();
        mock.when(selPermissionSetAssignments.sObjectType()).thenReturn(PermissionSetAssignment.SObjectType);
        mock.when(selPermissionSetAssignments.selectByPermissionSetNameAndAssigneeIds('Resourcing', new Set<Id> { corporateFinanceUser.Id }))
            .thenReturn(permissionSetAssignmentsMock);
        mock.when(selPermissionSetAssignments.getQueryWithCustomCondition('PermissionSet.Name = \'Resourcing\' AND Assignee.IsActive = true'))
            .thenReturn('SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSet.Name = \'Resourcing\' AND Assignee.IsActive = true');
        mock.stopStubbing();

        ORG_Application.selector.setMock(selPermissionSetAssignments);

        //given
        BCH_CreateResourcingRecords batch = new BCH_CreateResourcingRecords();
        batch.resourcingTypePicklistValues.add('Test_Value_1');
        System.assertEquals(0, [SELECT Id FROM Resourcing__c].size(), 'There should not be Resourcing records in database at this point');

        //when
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        Integer resourcingNumber = (Resourcing__c.Resourcing_Type__c.getDescribe().getPicklistValues().size() - 1) * 
            [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Resourcing' AND Assignee.IsActive = true].size();

        //then
        //2 is not random number it's the number of the resourcing records that should be created for opportunities team members.
        System.assertEquals(resourcingNumber + 2, [SELECT Id FROM Resourcing__c].size(), 'Resourcing records for users created in setup method should be created by the batch');
    }
}