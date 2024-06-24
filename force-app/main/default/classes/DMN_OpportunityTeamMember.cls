/**
 * @author :        Dzianisik Maksim
 * @date :          Apr. 2024
 * @description :   SFP-37889 implemented TRH and DMN classes for OpportunityTeamMember,
 *                  moved existing logic from the OpportunityTeamMemberHelper.cls (validateOpportunityTeamMemmbers method)
 *                  use OpportunityTeamMemberHelper_Test is a test class for validateOpportunityTeamMemmbers logic
 *                  implemented logic to identify "distributed" opportunity
 *
 *  @ Author        : Petr Roubal (OpportunityTeamMemberHelper)
 *  @ Date          : 7 Jan 2016
 *  @ Test File     : None
 *  @ Description   : EN-0947 CST - dependency between Opp team role and user global area
 *                    Trigger helper class that validate user global area and opportunity team role
 *
 *  @ Last Modified By  :   Petr Svestka (OpportunityTeamMemberHelper)
 *  @ Last Modified On  :   Sep 22, 2016
 *  @ Last Modified Reason  : US-1534 - Replicating "CommB Product Specialist" into "CommB CSU Agent" and "CommB CSU Manager"
 *
 *  @ Last Modified By  : Manoj Gupta (OpportunityTeamMemberHelper)
 *  @ Last Modified on  :  December 2016
 *  @ Last Modified Reason  : EN-1484 RTB - Sharing is added twice for Opportunity Team Members
 */

public with sharing class DMN_OpportunityTeamMember {

    /**
     * @param otmLst List<OpportunityTeamMember>
     * @description validateOpportunityTeamMemmbers
     */
    public static void validateOpportunityTeamMemmbers(List<OpportunityTeamMember> otmLst){

        Set<Id> oppIds = new Set<Id>();

        for(OpportunityTeamMember otm : otmLst) {
            if(!oppIds.contains(otm.OpportunityId)){
                oppIds.add(otm.OpportunityId);
            }
        }
        List<CST_Allowed_Combinations__c> cstAllowedCombinationsList = new List<CST_Allowed_Combinations__c>();


        cstAllowedCombinationsList = [SELECT Id,Name,User_Global_Area__c,Opportunity_Team_Roles__c,Unique_Team_Roles__c
        FROM CST_Allowed_Combinations__c WHERE Name LIKE 'OTM CommB%'];
        Set<String> otmAllowedRoles = new Set<String>();
        Set<String> uniqueTeamRole = new Set<String>();
        List<String> userGlobalA = new List<String>();
        for(CST_Allowed_Combinations__c cst : cstAllowedCombinationsList){
            otmAllowedRoles.addAll(splitTextArea(cst.Opportunity_Team_Roles__c));
            uniqueTeamRole.addAll(splitTextArea(cst.Unique_Team_Roles__c));
            userGlobalA.add(cst.User_Global_Area__c);
        }

        // get unique roles for OTM from Custom Settings
        Set<String> usedUniqueRole = getExistOppTeamRoles(oppIds, uniqueTeamRole);

        for(OpportunityTeamMember otm : otmLst){

            if(userGlobalA.contains(otm.User_CIB_Global_Area__c)){

                if(!otmAllowedRoles.contains(otm.TeamMemberRole)){
                    otm.addError(Label.OTM_CommB_Roles_Error);
                }else{
                    //check if new role has already existed
                    if(uniqueTeamRole.contains(otm.TeamMemberRole)){
                        //add as already used
                        if(usedUniqueRole.contains(otm.TeamMemberRole + '#' + otm.OpportunityId)){
                            otm.addError(Label.OTM_Unique_Role_Error);
                        }else{
                            usedUniqueRole.add(otm.TeamMemberRole + '#' + otm.OpportunityId);
                        }
                    }
                }

            }else{

                if(otmAllowedRoles.contains(otm.TeamMemberRole) && otm.TeamMemberRole != 'Originator - Primary'){
                    otm.addError(Label.OTM_CIB_Roles_Error);
                }

            }
        }

    }

    /**
     * @param memberRecords List<OpportunityTeamMember>
     * @description check if opportunity has a Distribution team member and has to be shared with GM Group
     */
    public static void checkIfOpportunityDistributed(List<OpportunityTeamMember> memberRecords) {

        if (Schema.SObjectType.Opportunity.fields.Is_Opportunity_Distributed__c.isAccessible()) {

            Map<Id, Boolean> oppId2Distributed = new Map<Id, Boolean>();

            for (OpportunityTeamMember member : memberRecords) {
                if (!oppId2Distributed.containsKey(member.OpportunityId)) {
                    oppId2Distributed.put(member.OpportunityId, false);
                }
            }

            List<OpportunityTeamMember> actualMembers = SEL_OpportunityTeamMembers.newInstance().selectByOpportunityIds(oppId2Distributed.keySet());

            for (OpportunityTeamMember member : actualMembers) {
                if (member.User_Business_Unit__c == DMN_User.BUSINESS_UNIT_DISTRIBUTION) {
                    oppId2Distributed.put(member.OpportunityId, true);
                }
            }

            List<Opportunity> actualOpp = SEL_Opportunities.newInstance().selectById(oppId2Distributed.keySet());
            List<Opportunity> oppToUpdate = new List<Opportunity>();

            for (Opportunity tempOpp : actualOpp) {
                if (tempOpp.Is_Opportunity_Distributed__c != oppId2Distributed.get(tempOpp.Id)) {
                    tempOpp.Is_Opportunity_Distributed__c = oppId2Distributed.get(tempOpp.Id);
                    oppToUpdate.add(tempOpp);
                }
            }

            if (oppToUpdate.size() > 0) {

                fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();

                for (Opportunity opp : oppToUpdate) {
                    uow.registerDirty(new Opportunity(
                            Id = opp.Id,
                            Is_Opportunity_Distributed__c = opp.Is_Opportunity_Distributed__c
                    ));
                }
                uow.commitWork();
            }

        }
    }

    private static Set<String> getExistOppTeamRoles(Set<Id> oppIds, Set<String> uniqueRoles){
        Set<String> retSetStrings = new Set<String>();
        List<OpportunityTeamMember> otmLst = [SELECT Id, OpportunityId, TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId IN :oppIds AND TeamMemberRole IN :uniqueRoles];
        for(OpportunityTeamMember otm : otmLst){
            retSetStrings.add(otm.TeamMemberRole+'#'+otm.OpportunityId);
        }
        return retSetStrings;
    }

    private static Set<String> splitTextArea(String field){
        Set<String> retSet = new Set<String>();
        if(field == null) {
            return retSet;
        }
        for(String str : field.split('\n')){
            retSet.add(str.replaceAll('\r', ''));
        }
        return retSet;
    }

}