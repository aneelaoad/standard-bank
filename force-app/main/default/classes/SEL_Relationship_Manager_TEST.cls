/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 10-24-2022
 * @last modified by  : TCK
**/
@IsTest
private class SEL_Relationship_Manager_TEST {
    @IsTest
    static void shouldSelectByContactId() {
        Test.startTest();
        SEL_Relationship_Manager.newInstance().selectByContactId('');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('EAP_Contact__c =: contactId'), 'Is not doing the right condition');
    }

    @IsTest
    static void shouldSelectByContactSetId() {
        Test.startTest();
        SEL_Relationship_Manager.newInstance().selectByContactId(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('EAP_Contact__c IN: contactId'), 'Is not doing the right condition');
    }
}