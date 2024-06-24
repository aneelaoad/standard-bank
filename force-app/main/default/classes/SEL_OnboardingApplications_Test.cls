/**
* Test class for SEL_OnboardingApplications.
* @author Emmanuel Nocks (BlueSky)
* @date August 2020
*/
@IsTest(IsParallel=true)
public class SEL_OnboardingApplications_Test {
    
    @IsTest
    static void shouldSelectByApplicationId(){
        Test.startTest();
        SEL_OnboardingApplications.newInstance().selectByApplicationId(new Set<Integer>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Application_Id__c in :IdSet'));
    }
    
    @IsTest
    static void shouldSelectBySetId(){
        Test.startTest();
        SEL_OnboardingApplications.newInstance().selectById(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('id in :idSet'));
    }
    @IsTest
    static void shouldSelectByClientIdWherePending(){
        Test.startTest();
        SEL_OnboardingApplications.newInstance().selectByClientIdWherePending(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Client__c IN:clientId and Status__c =:statusPending'));
    }
    @IsTest
    static void shouldSelectByClientIdAndRequestType(){
        Test.startTest();
        SEL_OnboardingApplications.newInstance().selectByClientIdAndRequestType(null,null);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Client__c =:clientId and Status__c=:statusPending and Request_Type__c=:requestType'));
    }

    @IsTest
    static void shouldSelectByClientId(){
        Test.startTest();
        SEL_OnboardingApplications.newInstance().selectByClientId(new Set<Id>{fflib_IDGenerator.generate(Account.SObjectType)});
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Client__c IN:clientId'));
    } 
    
}