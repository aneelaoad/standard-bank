/**
 * Test class for SEL_CustomNotificationTypes
 *
 * @author Emmanuel Mulea Nocks (BlueSky)
 * @date July 2021
 */
@IsTest(IsParallel=true)
public  class SEL_CustomNotificationTypes_Test {
    @IsTest
    private static void shouldSelectByDeveloperName() {
        Test.startTest();
        SEL_CustomNotificationTypes.newInstance().selectByDeveloperName(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('DeveloperName IN :developerNames'));
    }
}