/**
 * @Author Lulu
 * @date April 2024
 * @description This class contains unit tests for validating the behavior of SEL_Shortcuts
 */
@isTest
private class SEL_ShortcutsTest {
    @isTest
    private static void shouldSelectRunAllQueryAndReturnTheLast() {          
        String condition = 'CreatedDate = THIS_MONTH';
        Test.startTest();
        SEL_Shortcuts.newInstance().selectByCustomFilterCondition(condition);
        Test.stopTest();  
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase(condition),'Checking the last condition');
    }
    

}