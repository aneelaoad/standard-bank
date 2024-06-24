/**
 * 2017-10-26
 * Rudolf Niehaus - CloudSmiths
**/
public class invCaseFlagActionsExt {
    
    @AuraEnabled
    public static void flagCase(String caseId){
        
        Case c = [Select Id, Status From Case Where Id = :caseId];
        c.Status = 'Spam';
        update c;
    }
    
         @AuraEnabled
    public static void duplicate(String caseId){
        
        Case c = [Select Id, Status From Case Where Id = :caseId];
        c.Status = 'Duplicate';
        update c;
    }
    @AuraEnabled
    public static void notOrdinary(String caseId){
        
        Case c = [Select Id, OwnerId, Status From Case Where Id = :caseId];
        //get owner's manager
        list<User> u = [Select ManagerId From User Where Id =:System.UserInfo.getUserId()];
        if(u.size() > 0){
            if(String.isNotBlank(u[0].ManagerId)){
                c.OwnerId = u[0].ManagerId;
            }
        }
        c.Status = 'Not Ordinary';
        update c;
    }
}