/**
 * Test class for SEL_CurrencyTypes
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		March 2021
*/
@IsTest(IsParallel=true)
private class SEL_CurrencyTypes_TEST {
    @IsTest
    private static void shouldSelectByIsoCodes() {
        Test.startTest();
        SEL_CurrencyTypes.newInstance().selectByIsoCodes(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('IsoCode IN :isoSet'));
    }
}