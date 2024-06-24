/**
 * 
 * @description MallProductRangeItemController
 * @author Ankit Kumar
 * @since 
*/
public with sharing class MallProfileManagementController {
    /**
     * 
     * @description : getUserProfile 
     *  @param currentUserId String
     *  @return UserProfile
     */
    @AuraEnabled
    public static UserProfile getUserProfile(String currentUserId){
        try {
            List<User> users = SEL_Users.newInstance().selectUsersWithProfileByIds(new Set<Id>{(Id)currentUserId});
            User user = new User();
            if(users.size() > 0) {
                user = users[0];
            }
            UserProfile userProfile = new UserProfile();
            userProfile.user = user;
            return userProfile;
        } catch (Exception e) {       
            throw MallExceptionUtil.throwAuraException('MallProfileManagementController.getUserProfile', e);
        }
    }

    /**
     * 
     * @description : updateRecords 
     *  @param records List<sObject>
     *  @return List of sObject
     */
    @AuraEnabled
    public static List<sObject> updateRecords(List<sObject> records){
        try {
            update records;
            return records;
        } catch (Exception e) {       
             throw MallExceptionUtil.throwAuraException('MallProfileManagementController.updateRecords', e);
        }
    }

    /**
     * @description : ApexType class to maintain User Profile 
     */
    public class UserProfile {
        @AuraEnabled
        public String userId;
        @AuraEnabled
        public User user;
        @AuraEnabled
        public Account account;
        @AuraEnabled
        public Account contact;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String cellPhone;
        @AuraEnabled
        public String emailAddress;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public String language;
        @AuraEnabled
        public String userType;
        @AuraEnabled
        public String businessName;
        @AuraEnabled
        public String vatRegistrationNumber;
        @AuraEnabled
        public String cipc;
        @AuraEnabled
        public Boolean isShop;
        @AuraEnabled
        public String bank;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String accountNumber;
        @AuraEnabled
        public String accountType;
        @AuraEnabled
        public String swiftCode;
        @AuraEnabled
        public String shopUrl;
    }
}