/**
    @ Author: Pradeep Jangid
    @ Date: 24th May, 2022
    @description: controller to fetch existing user details and update 
 */
public with sharing class AcmUserProfileInfoController {
    @AuraEnabled(cacheable=true)
    public static User getUserDetail(String userId){
        if(!String.isBlank(userId)) {
            List<User> usrs = [SELECT Id, FirstName, LastName, CompanyName, Title, Email, MobilePhone, CommunityNickname FROM User WHERE Id =:userId WITH SECURITY_ENFORCED  LIMIT 1];
            if(!usrs.isEmpty()) {
                return usrs[0];    
            }    
        }
        return null;
    }

    @AuraEnabled
    public static String updateUserDetail(User userDetail) {
        update userDetail;
        return 'success';
    }
}