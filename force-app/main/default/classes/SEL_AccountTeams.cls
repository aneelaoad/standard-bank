/**
 * Selector layer class for AccountTeam SObject
 *
 * @author Caro Reinecke
 * @date 2018/09/05
 */
public with sharing class SEL_AccountTeams extends fflib_SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
                AccountTeamMember.TeamMemberRole,
                AccountTeamMember.UserId,
                AccountTeamMember.AccountId
        };
    }

    public Schema.SObjectType getSObjectType() {

        return AccountTeamMember.sObjectType;
    }

    public List<AccountTeamMember> selectById(Set<ID> idSet) {

        return (List<AccountTeamMember>) selectSObjectsById(idSet);
    }

    public List<AccountTeamMember> selectByAccountIdAndTeamMemberRole(Set<Id> idSet, Set<String> roleSet){
        return (List<AccountTeamMember>) Database.query(
                newQueryFactory().
                        setCondition('AccountId in :idSet AND TeamMemberRole in :roleSet').
                        toSOQL());
    }

}