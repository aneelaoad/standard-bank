/**
 * @description Test class for SEL_PermissionSetAssignments
 *
 * @author Konrad Bruszewski
 * @date October 2021
 */
@IsTest
public with sharing class SEL_PermissionSetAssignments_TEST {

    @IsTest
    private static void testSelectByPermissionSetNameAndAssigneeIds() {
        SEL_PermissionSetAssignments selector = new SEL_PermissionSetAssignments();
        Set<Id> userIds = new Set<Id> {
            fflib_IDGenerator.generate(User.SObjectType)
        };

        Test.startTest();
        selector.selectByPermissionSetNameAndAssigneeIds(UTL_Resourcing.RESOURCING_PERMISSION_SET, userIds);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assertEquals('PermissionSet.Name = :permissionSetName AND AssigneeId IN :assigneeIds', result.getCondition());
    }

    @IsTest
    private static void testSelectByPermissionSetName() {
        SEL_PermissionSetAssignments selector = new SEL_PermissionSetAssignments();
        Set<Id> userIds = new Set<Id> {
            fflib_IDGenerator.generate(User.SObjectType)
        };

        Test.startTest();
        selector.selectByPermissionSetName(UTL_Resourcing.RESOURCING_PERMISSION_SET);
        selector.getQueryWithCustomCondition('PermissionSet.Name = :permissionSetName AND Assignee.IsActive = true');
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assertEquals('PermissionSet.Name = :permissionSetName AND Assignee.IsActive = true', result.getCondition());
    }
}