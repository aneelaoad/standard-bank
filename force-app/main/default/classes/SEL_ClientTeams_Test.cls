/**
 * @description Test class for SEL_ClientTeams
 */
@IsTest
public with sharing class SEL_ClientTeams_Test {

    @IsTest
    private static void testSelectCCsAndCCBMsByAccount() {
        Test.startTest();
        SEL_ClientTeams.newInstance().selectCcAndCcbmByClientIds(new Set<Id>{fflib_IDGenerator.generate(Custom_Client_Team__c.SObjectType)});
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Account__c IN :clientIds AND (Client_Coordinator__c = true OR Client_Coordinator_BM__c = true)'));
    }

    @IsTest
    private static void testSelectByTeamMemberAndAccount() {
        Test.startTest();
        SEL_ClientTeams.newInstance().selectByTeamMemberAndAccount(UserInfo.getUserId(), fflib_IDGenerator.generate(Account.SObjectType));
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Team_Member__c = :userId AND Account__c = :clientId'));
    }

    @IsTest
    private static void testSelectById() {
        Test.startTest();
        SEL_ClientTeams.newInstance().selectById(new Set<Id>{fflib_IDGenerator.generate(Custom_Client_Team__c.SObjectType)});
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id in :idSet'));
    }

    @IsTest
    private static void testSelectByClientId() {
        Test.startTest();
        SEL_ClientTeams.newInstance().selectByClientId(new Set<Id>{fflib_IDGenerator.generate(Account.SObjectType)});
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Account__c IN :clientIds'));
    }
}