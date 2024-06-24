/**
 * @description Selector test class for SEL_AccountContactRelation
 * @author		Emmanuel Mulea(Nocks)
 * @date		March 2022
 */
@isTest
public class SEL_AccountContactRelation_Test {
    @IsTest
    static void selectByContactId(){
        Test.startTest();
        SEL_AccountContactRelation.newInstance().selectByContactId(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('ContactId IN: idSet'));
        
    }
    @IsTest
    static void selectByClientId(){
        Test.startTest();
        SEL_AccountContactRelation.newInstance().selectByClientId(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areNotEqual(result, null);
        
    }
@IsTest
    static void selectByIndirectContactIdTest(){
        Test.startTest();
        SEL_AccountContactRelation.newInstance().selectByIndirectContactId(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('ContactId IN: idSet AND IsDirect = false'));
        
    }

}