/**
 * @description Test class for DMN_Resourcing
 *
 * @author Konrad Bruszewski
 * @date June 2021
 */
@IsTest
public with sharing class DMN_Resourcing_TEST {

    private static List<Resourcing__c> testVariable;
    private static Resourcing__c oppResourcing1 = (Resourcing__c) new BLD_Resourcing().setDefaultData('Opportunity').getRecord();
    private static Resourcing__c oppResourcing2 = (Resourcing__c) new BLD_Resourcing().setDefaultData('Opportunity').ownerId(fflib_IDGenerator.generate(User.SObjectType)).getRecord();
    private static Resourcing__c oppResourcing3 = (Resourcing__c) new BLD_Resourcing().setDefaultData('Opportunity').resourceId(null).getRecord();
    private static Resourcing__c oppResourcing4;
    private static Resourcing__c oppResourcing5;
    private static Resourcing__c oppResourcing6;
    private static Resourcing__c oppResourcing7 = (Resourcing__c) new BLD_Resourcing().setDefaultData('Opportunity').resourceId(fflib_IDGenerator.generate(User.SObjectType)).getRecord();
    private static Resourcing__c initiativeResourcing1 = (Resourcing__c) new BLD_Resourcing().setDefaultData('Other').getRecord();
    private static Opportunity oppRecord;
    private static OpportunityTeamMember oppTeamMember;
    private static fflib_SObjectUnitOfWork uow = (fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();

    @TestSetup
    private static void createData() {
        Id resourceId = fflib_IDGenerator.generate(User.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        oppResourcing4 = (Resourcing__c) new BLD_Resourcing().setDefaultData('Opportunity').resourceId(resourceId).opportunityId(opportunityId).getRecord();

        oppResourcing5 = (Resourcing__c)JSON.deserialize('{"attributes":{"type":"Resourcing__c","url":"/services/data/v53.0/sobjects/Resourcing__c/a0q3O00000MUR8iQAH"},"Id":"a0q3O00000MUR8iQAH"}', Resourcing__c.class);
        oppResourcing5.Week_End_Date__c = oppResourcing4.Week_End_Date__c.addDays(-7);
        oppResourcing5.Opportunity__c = oppResourcing4.Opportunity__c;
        oppResourcing5.Resource__c = oppResourcing4.Resource__c;
        oppResourcing5.Resourcing_Type__c = 'Opportunity';

        BLD_Opportunity opp = new BLD_Opportunity(uow).id(fflib_IDGenerator.generate(Opportunity.SObjectType));
        opp.setDefaultData();
        oppRecord = (Opportunity) opp.getRecord();
        BLD_OpportunityTeamMember bldOppTeamMember = new BLD_OpportunityTeamMember(uow).userId(fflib_IDGenerator.generate(User.SObjectType)).opportunityId(oppRecord.Id);
        oppRecord.OpportunityTeamMembers.add((OpportunityTeamMember) bldOppTeamMember.getRecord());
        oppResourcing6 = (Resourcing__c) new BLD_Resourcing().setDefaultData('Opportunity').opportunity(opp).getRecord();
        oppTeamMember = (OpportunityTeamMember) bldOppTeamMember.getRecord();
    }

    @IsTest
    public static void testPopulateCompoundKey() {
        //given
        List<Resourcing__c> records = new List<Resourcing__c>();
        records.add(oppResourcing1);
        records.add(initiativeResourcing1);
        DMN_Resourcing resourcingDomain = (DMN_Resourcing) new DMN_Resourcing.Constructor().construct(records);
        //when
        Test.startTest();
        resourcingDomain.populateCompoundKeys();
        Test.stopTest();
        //then
        System.assertEquals('' + oppResourcing1.Opportunity__c + oppResourcing1.Resource__c + String.valueOf(oppResourcing1.Week_End_Date__c) + oppResourcing1.Resourcing_Type__c + '', records.get(0).Compound_Key__c, 'Should create compound key correctly for opportunity Resourcing');
        System.assertEquals('' + initiativeResourcing1.Opportunity__c + initiativeResourcing1.Resource__c + String.valueOf(initiativeResourcing1.Week_End_Date__c) + initiativeResourcing1.Resourcing_Type__c, records.get(1).Compound_Key__c, 'Should create compound key correctly for initiative resourcing');
    }

    @IsTest
    public static void testSetResourcingOwner() {
        //given
        List<Resourcing__c> records = new List<Resourcing__c>();
        records.add(oppResourcing2);
        DMN_Resourcing resourcingDomain = (DMN_Resourcing) new DMN_Resourcing.Constructor().construct(records);
        System.assertNotEquals(oppResourcing2.Resource__c, oppResourcing2.OwnerId, 'Owner and Resource should be different before running domain method');
        //when
        Test.startTest();
        resourcingDomain.setOwner();
        Test.stopTest();
        //then
        System.assertEquals(oppResourcing2.Resource__c, oppResourcing2.OwnerId, 'Owner and Resource should be the same after running domain method');
    }

    @IsTest
    public static void shouldSetResource() {
        //given
        List<Resourcing__c> records = new List<Resourcing__c>();
        records.add(oppResourcing3);
        DMN_Resourcing resourcingDomain = (DMN_Resourcing) new DMN_Resourcing.Constructor().construct(records);
        System.assertEquals(oppResourcing3.Resource__c, null, 'Resource should be null before running domain method');
        //when
        Test.startTest();
        resourcingDomain.setResource();
        Test.stopTest();
        //then
        System.assertEquals(oppResourcing3.Resource__c, UserInfo.getUserId(), 'Resource should be running user after running domain method');
    }

    @IsTest
    public static void shouldSetPreviousWeekResourcing() {
        createData();
        List<Resourcing__c> records = new List<Resourcing__c>();

        records.add(oppResourcing4);
        DMN_Resourcing resourcingDomain = (DMN_Resourcing) new DMN_Resourcing.Constructor().construct(records);
        List<Resourcing__c> oldRecords = new List<Resourcing__c>();
        oldRecords.add(oppResourcing5);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Resourcing selResourcing = (SEL_Resourcing) mocks.mock(SEL_Resourcing.class);

        mocks.startStubbing();
        mocks.when(selResourcing.sObjectType()).thenReturn(Resourcing__c.SObjectType);
        mocks.when(selResourcing.selectByOpportunityAndInitiativeAndResourceAndWeekEndDate(new Set<Id> { oppResourcing4.Opportunity__c }, new Set<String> { oppResourcing4.Resourcing_Type__c }, new Set<Id>{ oppResourcing4.Resource__c }, new Set<Date>{ oppResourcing5.Week_End_Date__c }))
            .thenReturn(oldRecords);
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selResourcing);

        Test.startTest();
        resourcingDomain.setPreviousWeekResourcing();
        Test.stopTest();

        System.assert(oppResourcing4.Previous_Week_Resourcing__c != null);
        System.assert(oppResourcing4.Previous_Week_Resourcing__c == oppResourcing5.Id);
    }

    @IsTest
    public static void shouldAddErrorIfResourceIsNotOppTeamMember() {
        //given
        createData();
        List<Resourcing__c> records = new List<Resourcing__c>();
        List<Opportunity> opps = new List<Opportunity> {
            oppRecord
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Opportunities selOppMock = (SEL_Opportunities) mocks.mock(SEL_Opportunities.class);

        records.add(oppResourcing6);
        DMN_Resourcing resourcingDomain = (DMN_Resourcing) new DMN_Resourcing.Constructor().construct(records);
        Set<Id> oppIds = new Set<Id> {
            oppRecord.Id
        };

        List<Opportunity> finalOpps = (List<Opportunity>) fflib_ApexMocksUtils.makeRelationship(List<Opportunity>.class, opps, OpportunityTeamMember.OpportunityId, new List<List<OpportunityTeamMember>> {
            new List<OpportunityTeamMember> {
                oppTeamMember
            }
        });

        mocks.startStubbing();
        mocks.when(selOppMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(selOppMock.selectByIdWithActiveTeamMembers(oppIds)).thenReturn(finalOpps);
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selOppMock);

        //when
        Test.startTest();
        resourcingDomain.checkIfResourceIsTeamMember();
        Test.stopTest();
        //then
        List<String> errorMessages = new List<String>();
        for (Database.Error error : records.get(0).getErrors()) {
            errorMessages.add(error.getMessage());
        }
        System.assert(errorMessages.contains(System.Label.Resourcing_NotOppTeamMember));
    }

    @IsTest
    public static void shouldAddErrorIfUserIsNotPartOfManagementGroup() {
        //given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_GroupMember selGroupMember = (SEL_GroupMember) mocks.mock(SEL_GroupMember.class);
        List<Resourcing__c> records = new List<Resourcing__c>();
        records.add(oppResourcing7);
        DMN_Resourcing resourcingDomain = (DMN_Resourcing) new DMN_Resourcing.Constructor().construct(records);

        mocks.startStubbing();
        mocks.when(selGroupMember.sObjectType()).thenReturn(GroupMember.SObjectType);
        mocks.when(selGroupMember.selectByUserOrGroupIdAndGroupDeveloperName(UserInfo.getUserId(), DMN_Resourcing.CORPORATE_FINANCE_RESOURCE_MANAGEMENT_GROUP)).thenReturn(new List<GroupMember>());
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selGroupMember);
        //when
        Test.startTest();
        resourcingDomain.checkIfUserCanAssignRecordsToOtherUsers();
        Test.stopTest();
        //then
        List<String> errorMessages = new List<String>();
        for (Database.Error error : records.get(0).getErrors()) {
            errorMessages.add(error.getMessage());
        }
        System.assert(errorMessages.contains(System.Label.Resourcing_NotManagementMember));
    }

    @IsTest
    public static void shouldNotAddErrorIfUserIsMemberOfManagementGroup(){
        //given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_GroupMember selGroupMember = (SEL_GroupMember) mocks.mock(SEL_GroupMember.class);
        List<Resourcing__c> records = new List<Resourcing__c>();
        records.add(oppResourcing7);
        DMN_Resourcing resourcingDomain = (DMN_Resourcing) new DMN_Resourcing.Constructor().construct(records);
        mocks.startStubbing();
        mocks.when(selGroupMember.sObjectType()).thenReturn(GroupMember.SObjectType);
        mocks.when(selGroupMember.selectByUserOrGroupIdAndGroupDeveloperName(UserInfo.getUserId(), DMN_Resourcing.CORPORATE_FINANCE_RESOURCE_MANAGEMENT_GROUP))
            .thenReturn(new List<GroupMember>{ new GroupMember(UserOrGroupId = UserInfo.getUserId()) });
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selGroupMember);
        //when
        Test.startTest();
        resourcingDomain.checkIfUserCanAssignRecordsToOtherUsers();
        Test.stopTest();
        //then
        System.assertEquals(0, records.get(0).getErrors().size());
    }
}