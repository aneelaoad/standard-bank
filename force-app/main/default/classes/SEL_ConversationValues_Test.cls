/**
 * Test class for SEL_Conversations.
 *
 * @author Sandile Mathe
 * @date April 2021
 */
@isTest(IsParallel=true)
public with sharing class SEL_ConversationValues_Test {

    @IsTest
    private static void selectConversationValueByResponse() {
        Test.startTest();
        SEL_ConversationValues.newInstance().selectConversationValueByResponse(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Response__c in :resp'));
    }
    @IsTest
    private static void selectConversationValueByReason() {
        Test.startTest();
        SEL_ConversationValues.newInstance().selectConversationValueByReason(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Reason__c in :reas'));
    }
    @IsTest
    private static void selectConversationValueBySubCat() {
        Test.startTest();
        SEL_ConversationValues.newInstance().selectConversationValueBySubCat(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Sub_Category__c in :subCat'));
    }
    @IsTest
    private static void selectAllConversationValues() {
        Test.startTest();
        SEL_ConversationValues.newInstance().selectAllConversationValues();
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assertEquals(result.getLimit(),50000);
    }

}