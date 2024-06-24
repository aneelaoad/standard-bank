/*****************************************************************************************************
    @ Author        : Petr Roubal
    @ Date          : 7 Jan 2016
    @ Test File     : None
    @ Description   : EN-0947 CST - dependency between Opp team role and user global area
                      Trigger helper class that validate user global area and opportunity team role

    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   Sep 22, 2016
    @ Last Modified Reason  : US-1534 - Replicating "CommB Product Specialist" into "CommB CSU Agent" and "CommB CSU Manager"
    
    @ Last Modified By  : Manoj Gupta
    @ Last Modified on  :  December 2016
    @ Last Modified Reason  : EN-1484 RTB - Sharing is added twice for Opportunity Team Members
    
    
******************************************************************************************************/

public with sharing class OpportunityTeamMemberHelper {

    public static void validateOpportunityTeamMemmbers(List<OpportunityTeamMember> otmLst){

        set<Id> oppIds = new set<Id>();

        for(OpportunityTeamMember otm : otmLst) {
            if(!oppIds.contains(otm.OpportunityId)){
                oppIds.add(otm.OpportunityId);
            }
        }
		List<CST_Allowed_Combinations__c> cstAllowedCombinationsList = new List<CST_Allowed_Combinations__c>();
        

       cstAllowedCombinationsList = [SELECT Id,Name,User_Global_Area__c,Opportunity_Team_Roles__c,Unique_Team_Roles__c
                                     FROM CST_Allowed_Combinations__c WHERE Name Like 'OTM CommB%'];
		Set<String> otmAllowedRoles = new Set<String>();
        Set<String> uniqueTeamRole = new Set<String>();
        List<String> userGlobalA = new List<String>();
        for(CST_Allowed_Combinations__c cst : cstAllowedCombinationsList){
            otmAllowedRoles.addAll(splitTextArea(cst.Opportunity_Team_Roles__c));
            uniqueTeamRole.addAll(splitTextArea(cst.Unique_Team_Roles__c));
            userGlobalA.add(cst.User_Global_Area__c);
        }

        // get unique roles for OTM from Custom Settings
        set<string> usedUniqueRole = getExistOppTeamRoles(oppIds, uniqueTeamRole);

        for(OpportunityTeamMember otm : otmLst){

            if(userGlobalA.contains(otm.User_CIB_Global_Area__c)){

                if(!otmAllowedRoles.contains(otm.TeamMemberRole)){
                    otm.addError(Label.OTM_CommB_Roles_Error);
                }else{
                    //check if new role has already existed
                    //
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

    private static set<string> getExistOppTeamRoles(set<Id> oppIds, set<string> uniqueRoles){
        set<string> retSetStrings = new set<string>();
        List<OpportunityTeamMember> otmLst = [select Id, OpportunityId, TeamMemberRole from OpportunityTeamMember where OpportunityId IN :oppIds and TeamMemberRole IN :uniqueRoles];
        for(OpportunityTeamMember otm : otmLst){
            retSetStrings.add(otm.TeamMemberRole+'#'+otm.OpportunityId);
        }
        return retSetStrings;
    }

    private static set<string> splitTextArea(string field){
        set<string> retSet = new set<string>();
        if(field == null)
            return retSet;
        for(string str : field.split('\n')){
            retSet.add(str.replaceAll('\r', ''));
        }
        return retset;
    }

}