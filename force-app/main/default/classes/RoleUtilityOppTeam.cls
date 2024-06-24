/*************************************************************************\
    @ Author        :     Nitish Kumar
    @ Date          :     28 Nov 2013
    @ Test File     :     
    @ Description   :      Util methods to: 
                           determine if a specified user is above a user's role in the role hierarchy (isManagerOfUser)

    @ Last Modified By  : Charles Mutsu
    @ Last Modified On  : 12 Dec 2013
    @ Last Modified Reason  : Update API version to 29

    @ Last Modified By  : Upender Sharma
    @ Last Modified On  : 1 Mar 2013
    @ Last Modified Reason  : Update code for US-1817
****************************************************************************/ 


global with sharing class RoleUtilityOppTeam {
    
    
    WebService  static boolean checkRoleutilityOppTeam (Id currentUserId , Id OpportunityId){
        
        list<OpportunityTeamMember> lstOpportunityTeamMember = [Select Id, OpportunityId, UserId From OpportunityTeamMember  Where OpportunityId =: OpportunityId and OpportunityAccessLevel = 'Edit'];
        
        List<Id> oppteamMembersIds = new List<Id>();
        
        for (OpportunityTeamMember oppTeam : lstOpportunityTeamMember){
             if (oppTeam.UserId == currentUserId){
                return true;
             }
            
             oppteamMembersIds.add(oppTeam.UserId);
        }
        
        if (oppteamMembersIds.size() > 0) {
            return RoleUtility.isManagerOfUsers(oppteamMembersIds, currentUserId );
        }
        else
         return false;
        
    }
    
    WebService  static boolean checkRoleOppTeam (Id currentUserId ,Id OpportunityId){
        
        List<Id> oppOwnerIds = new List<Id>();
        
        for (Opportunity opp : [Select Id, Name, OwnerId From Opportunity  Where Id =: OpportunityId]){
             if (opp.OwnerId == currentUserId){
                return true;
             }
            system.debug('------------UserId--'+opp.OwnerId);
            oppOwnerIds.add(opp.OwnerId);
        }
        
        if (oppOwnerIds.size() > 0) {
            system.debug('=RoleUtility.isManagerOfUsers(oppOwnerIds, currentUserId )='+RoleUtility.isManagerOfUsers(oppOwnerIds, currentUserId ));
            return RoleUtility.isManagerOfUsers(oppOwnerIds, currentUserId );
        }
        
        else
            return false;   
    }
    
    /***************************************/
    
    public static Response checkRoleOppTeamNew (Id currentUserId ,Id OpportunityId){
        
        List<Id> oppOwnerIds = new List<Id>();
        Response res = new Response();
        
        for (Opportunity opp : [Select Id, Name, OwnerId From Opportunity  Where Id =: OpportunityId]){
             if (opp.OwnerId == currentUserId){
                res.success = true;
                return res;
             }
            system.debug('------------UserId11--'+opp.OwnerId);
             oppOwnerIds.add(opp.OwnerId);
        }
        
        if (oppOwnerIds.size() > 0) {
            //system.debug('=RoleUtility.isManagerOfUsers(oppOwnerIds, currentUserId )11='+RoleUtility.isManagerOfUsers(oppOwnerIds, currentUserId ));
            boolean chkBox = RoleUtility.isManagerOfUsers(oppOwnerIds, currentUserId );
            system.debug('=chkBox='+chkBox);
            res.success = chkBox;
            return res;
            //return RoleUtility.isManagerOfUsers(oppOwnerIds, currentUserId );
        }
        
        else{
            system.debug('=E3=');
            res.success = false;
            return res; 
        }
            //return res;   
    }
    
    public Class Response{
        @AuraEnabled
        public Boolean success;
    }
    
}