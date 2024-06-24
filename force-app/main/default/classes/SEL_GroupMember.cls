/**
 * @description Selector class for GroupMember
 *
 * @author Konrad Bruszewski
 * @date June 2021
 */
public with sharing class SEL_GroupMember extends fflib_SObjectSelector {

    /**
     * Create new instance
     *
     * @return GroupMember
     */
    public static SEL_GroupMember newInstance() {
        return (SEL_GroupMember) ORG_Application.selector.newInstance(GroupMember.SObjectType);
    }

    /**
     * Get SObject field list
     *
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                GroupMember.GroupId,
                GroupMember.Id,
                GroupMember.UserOrGroupId
        };
    }

    /**
     * Get SObject type
     *
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return GroupMember.sObjectType;
    }

    /***
     * Select by User or Group Id and Group dev name
     *
     * @param userOrGroupId
     * @param groupDevName
     *
     * @return
     */
    public List<GroupMember> selectByUserOrGroupIdAndGroupDeveloperName(Id userOrGroupId, String groupDevName){
        return (List<GroupMember>) Database.query(
                newQueryFactory()
                        .setCondition('UserOrGroupId = :userOrGroupId AND Group.DeveloperName = :groupDevName')
                        .toSOQL()
        );
    }

    /***
     * Select by User or Group Id and Group dev name
     *
     * @param userOrGroupId
     *
     * @return
     */
    public List<GroupMember> selectByUserOrGroupId(List<Id> userOrGroupId){
        return (List<GroupMember>) Database.query(
                newQueryFactory()
                        .setCondition('UserOrGroupId  IN :userOrGroupId')
                        .toSOQL()
        );
    }

    /**
     * @description Select group members by the group developer name
     *
     * @param groupDevName - String
     *
     * @return group members - List<GroupMember>
     */
    public List<GroupMember> selectByGroupDeveloperName(String groupDevName){
        return (List<GroupMember>) Database.query(
                newQueryFactory()
                        .setCondition('Group.DeveloperName = :groupDevName')
                        .toSOQL()
        );
    }
}