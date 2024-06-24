/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-01-2022
 * @last modified by  : TCK
**/
@IsTest
public with sharing class SEL_Group_TEST {
    private static final String TEST_GROUP_NAME = 'Test_Group';

    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_EAP_AppEvent bldAppEvent = new BLD_EAP_AppEvent(uow)
            .startDate(date.today());
        uow.commitWork();

        new BLD_EAP_Meeting(uow).event(bldAppEvent);
        uow.commitWork();
    }

    @IsTest
    private static void shouldSelectByNameWithListId() {
        Test.startTest();
        SEL_Group.newInstance().selectByName(new List<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Name IN :names'), 'Different condition than expected');
    }

    @IsTest
    private static void shouldSelectByNameWithListString() {
        Test.startTest();
        SEL_Group.newInstance().selectByName(new List<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Name IN :names'), 'Different condition than expected');
    }

    @IsTest
    private static void shouldSelectByNameWithId() {
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        Test.startTest();
        SEL_Group.newInstance().selectByNameId(event.Id);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Name = :name'), 'Different condition than expected');
    }

     @IsTest
    private static void shouldSelectByTypeAndDeveloperName() {
        Test.startTest();
        SEL_Group.newInstance().selectByTypeAndDeveloperName('case','test');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('Type = :type AND DeveloperName = :developerName'), true);
    }

    @IsTest
    private static void shouldSelectByNameWithString() {
        EAP_Meeting__c meeting = [SELECT Id FROM EAP_Meeting__c LIMIT 1];
        Test.startTest();
        SEL_Group.newInstance().selectByName(DMN_EAP_Meeting.GROUP_PREFIX + meeting.Id);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Name LIKE :name'), 'Different condition than expected');
    }

    @IsTest
    private static void shouldSelectByType() {
        Test.startTest();
        SEL_Group.newInstance().selectByType('Regular');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Type = :type'), 'Different condition than expected');
    }
}