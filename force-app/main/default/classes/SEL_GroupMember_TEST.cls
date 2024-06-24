/**
 * @description Test class for SEL_GroupMember
 */
@IsTest
public with sharing class SEL_GroupMember_TEST {

    private static final String TEST_GROUP_NAME = 'Test_Group';

    @IsTest
    public static void testSelectByIdWithActiveTeamMembers() {
        SEL_GroupMember selector = new SEL_GroupMember();
        Id userId = fflib_IDGenerator.generate(User.SObjectType);

        Test.startTest();
        selector.selectByUserOrGroupIdAndGroupDeveloperName(userId, TEST_GROUP_NAME);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assertEquals('UserOrGroupId = :userOrGroupId AND Group.DeveloperName = :groupDevName', result.getCondition());
    }

    @IsTest
    public static void testSelectByGroupDeveloperName() {
        SEL_GroupMember selector = new SEL_GroupMember();

        Test.startTest();
        selector.selectByGroupDeveloperName(TEST_GROUP_NAME);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assertEquals('Group.DeveloperName = :groupDevName', result.getCondition());
    }
}