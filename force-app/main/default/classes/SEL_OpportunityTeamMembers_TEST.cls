/**
 * @description Test class for
 *
 * @author Konrad Bruszewski
 * @date July 2021
 */
@IsTest
public with sharing class SEL_OpportunityTeamMembers_TEST {

    @IsTest
    public static void testGetQueryLocatorWithCustomCondition(){
        SEL_OpportunityTeamMembers selector = new SEL_OpportunityTeamMembers();
        String condition = 'IsActive__c = \'True\'';
        String query;

        Test.startTest();
        query = selector.getQueryWithCustomCondition(condition);
        selector.selectByOpportunityIds(new Set<Id>());
        selector.getOppTeamMembersByUserIdsOppStagesAndBusUnit(new Set<Id>(), new Set<String>(), 'testUnit');
        Test.stopTest();

        System.assert(query.containsIgnoreCase('WHERE ' + condition));
    }
}