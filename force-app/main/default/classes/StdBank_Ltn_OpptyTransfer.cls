public with Sharing class StdBank_Ltn_OpptyTransfer{
    @AuraEnabled
    public static boolean checkpermission(Id recordId) {
        List<Opportunity> opplst = new List<Opportunity>();
        String ProfileId = userinfo.getprofileid().substring(0,15);
        Boolean adminProfile = false;
        List<SystemAdmin_BA_profileID_task_Deletion__c> profilesIds = SystemAdmin_BA_profileID_task_Deletion__c.getall().values();
        for(SystemAdmin_BA_profileID_task_Deletion__c profId: profilesIds){
            if(ProfileId == profId.Profile_ID__c){
                adminProfile = True;
            }
        }
        if(recordId != null){
            opplst = [Select ID, IsPrivate,OwnerId from Opportunity where ID = :recordId];
        }
        Boolean hasPermission = RoleUtilityOppTeam.checkRoleOppTeam(UserInfo.getUserId(),recordId);
        if(opplst.size() > 0){
            return ((!adminProfile) && (hasPermission != true || (opplst[0].IsPrivate && opplst[0].OwnerId != UserInfo.getUserId())));
        }else{
            return true;
        }
        
    }
}