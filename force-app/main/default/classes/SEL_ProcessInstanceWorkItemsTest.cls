/**
 * @Author Emmanuel Mulea Nocks
 * @date April 2024
 * @description This class contains unit tests for validating the behavior of SEL_ProcessInstanceWorkItems
 */
@isTest
private class SEL_ProcessInstanceWorkItemsTest {

    @IsTest
    private static void shouldSelectRunAllQueryAndReturnTheLast() {

        String processWhereClause = 'CreatedDate = THIS_MONTH';
        Test.startTest();
        SEL_ProcessInstanceWorkItems.newInstance().selectByCustomFilterCondition(processWhereClause);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase(processWhereClause),'Checking the last condition');
    }
}