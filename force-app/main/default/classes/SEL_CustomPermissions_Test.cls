/**
 * @description Test class for SEL_CustomPermissions class
 *
 * @author Konrad Bruszewski
 * @date March 2022
 */
@IsTest
public with sharing class SEL_CustomPermissions_Test {

    /**
     * Test if selector method uses correct condition in WHERE clause
     */
    @IsTest
    private static void testSelectByDeveloperName() {
        SEL_CustomPermissions cpSelector = SEL_CustomPermissions.newInstance();
        Test.startTest();
        cpSelector.selectByDeveloperName('Custom_Permission_Name');
        Test.stopTest();
        System.assertEquals('DeveloperName = :devName', fflib_QueryFactory.lastQueryFactory.getCondition(), 'Selector method should use correct condition');
    }
}