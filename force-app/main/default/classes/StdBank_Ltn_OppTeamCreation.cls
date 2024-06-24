public class StdBank_Ltn_OppTeamCreation {
	
    @AuraEnabled
    public static ResponseClass checkpermission(Id recordId) {
        List<Opportunity> opplst = new List<Opportunity>();
        
        if(recordId != null){
            opplst = [Select ID, IsPrivate,OwnerId from Opportunity where ID = :recordId];
        }
        //Boolean hasPermission = RoleUtilityOppTeam.checkRoleOppTeam(UserInfo.getUserId(),recordId);
        Id usrId = UserInfo.getUserId();
        RoleUtilityOppTeam.Response hasPermission = RoleUtilityOppTeam.checkRoleOppTeamNew(usrId,recordId);
        system.debug('=hasPermission11='+hasPermission.success);
        
        ResponseClass res = new ResponseClass();
        
        if(opplst.size() > 0){
            system.debug(hasPermission.success);
            if(opplst[0].IsPrivate){
                system.debug('=Private=');
                if(UserInfo.getUserId() != opplst[0].OwnerId){
                    res.success = true;  
                    res.errorMessage = 'Please contact the Opportunity Owner.';
                }else{
                    system.debug('=Exit=');
                    res.success = true;  
                    res.errorMessage = 'Team members cannot be added to a Private Opportunity';
                }
            }
            if(opplst[0].IsPrivate == false && hasPermission.success != true){
                res.success = true;  
                res.errorMessage = 'Please contact the Opportunity Owner.';
            }
            if(opplst[0].IsPrivate == false && hasPermission.success == true){
                res.success = false;  
            }
            //return (hasPermission != true && opplst[0].IsPrivate);
        }
        system.debug('=res2='+res);
        return res;  
    }
    
    Public Class ResponseClass{
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String errorMessage;
    }
    
}