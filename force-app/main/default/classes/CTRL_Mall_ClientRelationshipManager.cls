public without sharing class CTRL_Mall_ClientRelationshipManager {
   
    @AuraEnabled
    public static RelationshipManagerInfo getRelationshipManagerInfo(){
        try {
            User loggedInUser = [ SELECT Id, 
                                        AccountId, 
                                        Account.OwnerId, 
                                        Account.Owner.Email, 
                                        Account.Owner.Phone, 
                                        Account.Owner.MobilePhone,
                                        Account.Owner.Name
                                        FROM USER 
                                        WHERE Id =: UserInfo.getUserId() 
                                        LIMIT 1 ];
            RelationshipManagerInfo rmInfo = new RelationshipManagerInfo();
            rmInfo.id = loggedInUser.Account.OwnerId;
            rmInfo.name = loggedInUser.Account.Owner.Name;
            rmInfo.emailId = loggedInUser.Account.Owner.Email;
            return rmInfo;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class RelationshipManagerInfo {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String emailId;
    }
}