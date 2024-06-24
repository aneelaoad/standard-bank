/**
 * Test class for SEL_Conversations.
 *
 * @author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @date September 2020
 */
@isTest(IsParallel=true)
public with sharing class SEL_Conversations_TEST {

    @IsTest
    private static void selectByExternalId() {
        Test.startTest();
        SEL_Conversations.newInstance().selectByExternalId(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('ExternalId__c IN :recordExternalIds'));
    }

    @IsTest
    private static void selectByExternalIdLeadKey() {
        Test.startTest();
        SEL_Conversations.newInstance().selectByExternalIdLeadKey(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('ExternalIdLeadKey__c IN :recordExternalIdLeadKeys'));
    }

    @IsTest
    private static void selectExternalIdForConversations() {
        Test.startTest();
        SEL_Conversations.newInstance().selectExternalIdForConversations(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN :recordIds'));
    }

    @IsTest
    private static void selectContextConversations() {
        Test.startTest();
        SEL_Conversations.newInstance().selectContextConversations(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN :recordIds'));
    }

    @IsTest
    private static void selectByUserToDeactivate() {
        Test.startTest();
        SEL_Conversations.newInstance().selectByOwnerToDeactivate(null, new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('OwnerId = :userId AND Id NOT IN :conversationIds AND IsActive__c = TRUE AND isClosed__c = FALSE'));
    }

    @IsTest
    private static void selectByClientToDeactivate() {
        Test.startTest();
        SEL_Conversations.newInstance().selectByAccountToDeactivate(null, new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Client__c = :accountId AND Id NOT IN :conversationIds AND IsActive__c = TRUE AND isClosed__c = FALSE'));
    }

    @IsTest
    private static void selectByUsersToDeactivate() {
        Test.startTest();
        SEL_Conversations.newInstance().selectByOwnersToDeactivate(new Set<Id>(), new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('OwnerId IN :userIds AND Id NOT IN :conversationIds AND IsActive__c = TRUE AND isClosed__c = FALSE'));
    }

    @IsTest
    private static void selectByClientsToDeactivate() {
        Test.startTest();
        SEL_Conversations.newInstance().selectByAccountsToDeactivate(new Set<Id>(), new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Client__c IN :accountIds AND Id NOT IN :conversationIds AND IsActive__c = TRUE AND isClosed__c = FALSE'));
    }
}