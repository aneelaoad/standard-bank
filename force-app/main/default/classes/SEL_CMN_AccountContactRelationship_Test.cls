/**
 * @description Selector test class for SEL_CMN_AccountContactRelationshipDetail
 * @author		Emmanuel Mulea(Nocks)
 * @date		March 2022
 */
@isTest
public class SEL_CMN_AccountContactRelationship_Test {
    
     @IsTest
    static void selectByAccountIds(){
        Test.startTest();
        SEL_CMN_AccountContactRelationshipDetail.newInstance().selectByAccountIds(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Client__c In :accountIds'));
        
    }
    @IsTest
    static void selectById(){
        Test.startTest();
        SEL_CMN_AccountContactRelationshipDetail.newInstance().selectByIds(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id in :conAccIds'));
        
    }
    @IsTest
    static void selectActiveByAccountIds(){
        Test.startTest();
        SEL_CMN_AccountContactRelationshipDetail.newInstance().selectActiveByAccountIds(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Client__c In :accountIds AND Status__c=:statusActive'));
        
    }

}