/**
 * @description Test class for SEL_SubscribedSolutions
 *
 * @author Ephetehe Mokgopanyane(ephetehe.mokgopanyane@tetrad.co.za)
 * @date August 2020
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-28081
 * @LastModifiedReason New test method for retrieving subscribed solutions based on contact ID
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason New Test method for retrieving subscribed solutions based on record type
 * 
 * @LastModified October 2023
 * @author Nkosilathi Ncube (nkosilathi.ncube@standardbank.co.za)
 * @UserStory SFP-SFP-20792
 * @LastModifiedReason New Test method for retrieving subscribed solutions based on contactId and solution Id
 * 
 */
@IsTest(IsParallel=true)
private class SEL_SubscribedSolutions_Test {
    @IsTest
    static void shouldSelectById() {
        Test.startTest();
        SEL_SubscribedSolutions.newInstance().selectById(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('Id IN: idSet'), 'Condition used id set.');
    }

    @IsTest
    static void shouldSelectByUserId() {
        Test.startTest();
        SEL_SubscribedSolutions.newInstance().selectByUserId(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('User__c IN: idSet'), 'Condition used user id set.');
    }
    
    @IsTest
    static void shouldSelectByTitle() {
        Test.startTest();
        SEL_SubscribedSolutions.newInstance().selectBySolutionTitle(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('Solution__r.title IN:knowledgeTitles'), 'Condition used knowledge title set.');
    }
    
    @IsTest
    static void selectByContactIdAndSolutionId() {
        Test.startTest();
        SEL_SubscribedSolutions.newInstance().selectByContactIdAndSolutionId(new Set<Id>(),new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('Contact__c IN: idSet AND Solution__r.Id IN: solutionIds'), 'Condition used id and solution id sets.');
    }

    @IsTest
    static void shouldSelectByContactId() {
        Test.startTest();
        SEL_SubscribedSolutions.newInstance().selectByContactId(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('Contact__c IN: idSet'), 'Condition used contact id set.');
    }

    @IsTest
    static void shouldSelectByContactIdWithRecordType() {
        Test.startTest();
        SEL_SubscribedSolutions.newInstance().selectByContactIdAndRecordType(new Set<Id>(), new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('Contact__c IN: idSet AND RecordTypeId IN :recordTypesIds'), 'Condition used contact id set with record type.');
    }

    @IsTest
    static void shouldSelectByUserIdAndRecordType() {
        Test.startTest();
        SEL_SubscribedSolutions.newInstance()
            .selectByUserIdAndRecordType(new Set<Id>(), new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(true, result.getCondition().containsIgnoreCase('User__c IN: idSet AND RecordTypeId IN :recordTypesIds'), 'Condition used user id set with record type.');
    }

}