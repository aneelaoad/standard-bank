/**
 * 
 * @description Test class for SEL_Tasks
 * @author JP Basson (jabasson@deloitte.co.za)
 * @date March 2021
 *****************************************************************************************
 *   @ Last Modified By  :   Maham Hassan
 *   @ Last Modified On  :   08/04/2022
 *   @ Last Modified Reason  : Updated this class to update the coverage required for 
 *                              deployment
 *
 *  @ Last Modified By  :   Maksim Dzianisik
 *  @ Last Modified On  :   March 2023
 *  @ Last Modified Reason  :   Updated to increase code coverage
 *
 *****************************************************************************************
 */
@IsTest
private class SEL_Tasks_TEST {

    public static final String  ADVISOR_TASK_RECORD_TYPE = 'Advisor Task';

    @IsTest
    private static void shouldSelectBySubjectAndAccountId() {
        Test.startTest();

        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(ADVISOR_TASK_RECORD_TYPE).getRecordTypeId();

        SEL_Tasks.newInstance().selectBySubjectAndAccountId('subject', new Set<Id>());
        SEL_Tasks.newInstance().selectByAccountIds(new Set<Id>());
        SEL_Tasks.newInstance().selectByIds(new Set<Id>());
        SEL_Tasks.newInstance().selectByWhatIdsAndRecordTypeId(new Set<Id>(), recordTypeId);
        SEL_Tasks.newInstance().selectByWhatIdsAndRecordTypeIdWithoutSharing(new Set<Id>(), recordTypeId);
        
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(true, result.getCondition().containsIgnoreCase('Subject LIKE :subject AND WhatId in : accountId'));
    }

    @IsTest
    private static void shouldSelectByWhatIdWithCustomFilterAndLimit() {
        Test.startTest();

        String customCondition = 'isClosed = TRUE AND Subject = \'testSubject\'';
        Integer limitCount = 100;

        SEL_Tasks.newInstance().selectByWhatIdWithCustomFilterAndLimit(new Set<Id>(), customCondition, limitCount);

        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase(customCondition), 'Checking the last condition');
        Assert.areEqual(result.getLimit(), limitCount,'Checking the last limit');
    }
}