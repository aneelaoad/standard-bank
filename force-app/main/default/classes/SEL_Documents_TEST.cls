/**
 * Test class for SEL_Documents
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date June 2020
 */
@IsTest(IsParallel=true)
private class SEL_Documents_TEST {
    @IsTest
    private static void shouldSelectByDeveloperName() {
        Test.startTest();
        SEL_Documents.newInstance().selectByDeveloperName(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('DeveloperName IN :developerNames'));
    }
}