/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-05-2022
 * @last modified by  : TCK
**/
@IsTest
private  class SEL_EAP_AppEvent_TEST {
    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_EAP_AppEvent(uow)
            .startDate(date.today());
        uow.commitWork();
    }

    @IsTest
    static void selectById() {
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        SEL_EAP_AppEvent selector = new SEL_EAP_AppEvent();
        Test.startTest();
        selector.selectById(event.Id);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id =: eventId'), 'Query contains Id =: eventId');
    }

    @IsTest
    static void selectByCampaign() {
        SEL_EAP_AppEvent selector = new SEL_EAP_AppEvent();
        Test.startTest();
        selector.selectByCampaign(new List<Id>());
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('EAP_Campaign__c IN: campaignIdList'), 'Query contains EAP_Campaign__c =: campaignIdList');
    }

    @IsTest
    static void selectByIdWithMeetingInfo() {
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        SEL_EAP_AppEvent selector = new SEL_EAP_AppEvent();
        Test.startTest();
        selector.selectByIdWithMeetingInfo(event.Id);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id =: eventId'), 'Query contains Id =: eventId');
    }

    @IsTest
    static void selectByIdWithTierLevelInfo() {
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        SEL_EAP_AppEvent selector = new SEL_EAP_AppEvent();
        Test.startTest();
        selector.selectByIdWithTierLevelInfo(event.Id);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id =: eventId'), 'Query contains Id =: eventId');
    }

    @IsTest
    static void selectByIdWithEapDocuments() {
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        SEL_EAP_AppEvent selector = new SEL_EAP_AppEvent();
        Test.startTest();
        selector.selectByIdWithEapDocuments(new List<String>{event.Id});
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN: eventsId'), 'Query contains Id IN: eventsId');
    }

    @IsTest
    static void selectByIdWithEndDateWithEapDocuments() {
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        SEL_EAP_AppEvent selector = new SEL_EAP_AppEvent();
        Test.startTest();
        selector.selectByIdWithEndDateWithEapDocuments(datetime.now(), new List<String>{event.Id});
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN: eventsId AND EAP_EndDate__c >: nowDatetime'), 'Query contains Id IN: eventsId AND EAP_EndDate__c >: nowDatetime');
    }

    @IsTest
    static void selectCurrentWithEapDocuments() {
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        SEL_EAP_AppEvent selector = new SEL_EAP_AppEvent();
        Test.startTest();
        selector.selectCurrentWithEapDocuments(datetime.now(), new List<String>{event.Id});
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN: eventsId AND EAP_EndDate__c >=: nowDatetime AND EAP_StartDate__c <=: nowDatetime'), 'Query contains Id IN: eventsId AND EAP_EndDate__c >=: nowDatetime AND EAP_StartDate__c <=: nowDatetime');
    }

    @IsTest
    static void selectPastByIdWithEndDateWithEapDocuments() {
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        SEL_EAP_AppEvent selector = new SEL_EAP_AppEvent();
        Test.startTest();
        selector.selectPastByIdWithEndDateWithEapDocuments(datetime.now(), new List<String>{event.Id});
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN: eventsId AND EAP_EndDate__c <=: nowDatetime'), 'Query contains Id IN: eventsId AND EAP_EndDate__c <=: nowDatetime');
    }

    @IsTest
    static void selectByIdWithCoorporates() {
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        SEL_EAP_AppEvent selector = new SEL_EAP_AppEvent();
        Test.startTest();
        selector.selectByIdWithCoorporates(event.Id);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id =: eventId'), 'Query contains Id =: eventId');
    }
}