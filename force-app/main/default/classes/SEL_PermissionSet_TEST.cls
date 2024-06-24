/**
 * @description       : Test class for SEL_PermissionSet class
 * @author            : Jaco de Lange
 * @last modified on  : 02-08-2024
 * @last modified by  : Jaco de Lange
**/
@isTest(IsParallel=true)
private class SEL_PermissionSet_TEST {
    @isTest
    static void selByPermissionSetName(){
        Test.startTest();
        SEL_PermissionSet.newInstance().selectByPermissionSetName('');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Name = :permissionSetName'), 'Not expected condition');    
    }
}