/**
* @description       : US: SFP-11066 - Generate agenda from a button
* @author            : TCK
* @group             : 
* @last modified on  : 06-13-2022
* @last modified by  : TCK
**/
@IsTest
private class SEL_ContentDocument_TEST {
    @IsTest
    static void shouldSelectById() {
        Test.startTest();
        SEL_ContentDocument.newInstance().selectById(new Set<Id>());
        
        
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN: ids'), 'Query contains Id IN: ids');
        
    }
}