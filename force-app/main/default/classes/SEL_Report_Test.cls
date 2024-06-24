/**
* Test class for SEL_Report.
*
* @author Emmanuel Nocks (BlueSky)
* @date August 2020
*/
@IsTest(IsParallel=true)
public class SEL_Report_Test {
    @IsTest
    static void shouldSelectByDevName(){
        Test.startTest();
        SEL_Report.newInstance().selectByDevName(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('developername IN:devNames'));
    }
}