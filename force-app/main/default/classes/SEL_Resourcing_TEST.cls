/**
 * @description Test class for SEL_Resourcing
 *
 * @author Konrad Bruszewski
 * @date July 2021
 */
@IsTest
public with sharing class SEL_Resourcing_TEST {

    @IsTest
    public static void testSelectByOpportunityAndWeekEndDateLastWeek() {
        SEL_Resourcing selector = new SEL_Resourcing();
        Set<Id> oppIds = new Set<Id> {
            fflib_IDGenerator.generate(Opportunity.SObjectType)
        };

        Test.startTest();
        selector.selectByOpportunityAndInitiativeAndResourceAndWeekEndDate(oppIds, new Set<String>(), new Set<Id>(), new Set<Date>());
        selector.selectByWeekEndDateAndRolesGroupByResource(Date.today(), new Set<String>());
        selector.selectByOpportunityAndWeekEndDate(oppIds, Date.today());
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assertEquals('Opportunity__c IN :oppIds AND Week_End_Date__c = :weekEnd', result.getCondition());
    }
}