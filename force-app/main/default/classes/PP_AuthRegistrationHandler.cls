/**
 * @description       : Auth provider registration handler for partner connect site
 * @author            : Peter Guest
 * @group             : CloudSmiths
 * @last modified on  : 02-23-2024
 * @last modified by  : Jaco de Lange
**/
@SuppressWarnings('PMD')
global with sharing class PP_AuthRegistrationHandler implements Auth.RegistrationHandler {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PP_AuthRegistrationHandler');

    public class PP_AuthRegistrationHandlerException extends Exception {}

    private final String timeZoneSid = 'Africa/Johannesburg';
    private final String emailEncoding = 'UTF-8';
    private final String communityBaseProfileName = 'Custom Base Customer Community Plus Login User';
    private final String communityProfileId = SEL_Profiles.newInstance().selectByNames(new List<String>{communityBaseProfileName})[0]?.Id;
    private final String communityPermissionSet = 'Community_Access_Partner_Portal';
    private final String pingStartValue = 'entryUUID=';
    private final String pingEndValue = ',ou=People,dc=sbsa,dc=com';
    private final String notRegisteredAsUserError = 'You are not eligible to register or access the portal.';
    private final String inProgress = 'In Progress';
    private final String approved = 'Approved';

    //auth response attribute user key map
    private final String firstNameKey = 'first_name';
    private final String lastNameKey = 'last_name';
    private final String emailKey = 'email';
    private final String cellPhoneNumberKey = 'cellphonenumber';
    private final String subKey = 'sub';
    private final String idKey = 'id';
    
/**
* @description This method is called if the user logs in for the first time.
* @param portalId 
* @param data 
**/
    global User createUser(Id portalId, Auth.UserData data) {
        User u;
        //check for existing contact by email in db
        Id conId = allowedToRegister(data);

        if (conId!=null){   
            //checks for existing user with ping uuid
            User existingUser = findExistingUser(data);

            if (existingUser != null) {
                updateUser(existingUser.Id, null, data);
                return existingUser;
            }
            else {
                u = prepareUserData(data, conId);
                insert u;

                checkPermissionSetForUser(u.id, communityPermissionSet);
                return u;
            }
        }
        else {
            throw new PP_AuthRegistrationHandlerException(notRegisteredAsUserError);
        }
    }    
/**
* @description This method is called if the user has logged in before with the authentication provider and then logs in again.
* @author Peter Guest | 22-05-2023 
* @param userId 
* @param portalId 
* @param data 
**/
    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        if(userId != null) {   
            checkPermissionSetForUser(userId, communityPermissionSet);
        }
    }
/**
* Method checks permission set for user
* @author Jaco de Lange 
* @param userid
* @param permissionsetlabel
*/
    private void checkPermissionSetForUser(Id userId, string permissionSetLabel) {
        List<User> usersList = SEL_Users.newInstance().selectById(new Set<Id>{userId});
        List<PermissionSet> permSet = SEL_PermissionSet.newInstance().selectByPermissionSetName(permissionSetLabel);

        //if user is Active
        if(usersList.size() > 0 && usersList[0].isActive) {
            if(permSet.size()>0){	
                List<PermissionSetAssignment> permissionSetAssign = SEL_PermissionSetAssignments.newInstance()
                                                                   .selectByPermissionSetNameAndAssigneeIds(communityPermissionSet, new Set<Id>{userId});                                          
                                                                    
                    if(permissionSetAssign.size() == 0){
                        assignPermissionSetToUser(userId,permSet[0].Id);
                    }                                          
            }
        }
        //if user is inActive
        if (usersList.size() > 0 && !usersList[0].IsActive){
            updateUser(userid, communityProfileId);
            removePermissionSetsFromUser(userId);
            assignPermissionSetToUser(userId,permSet[0].Id);
        }
    }
/**
* Method removes any existing permission set assignments from user
* @author Jaco de Lange 
* @param userid
*/
@TestVisible
    private static void removePermissionSetsFromUser(Id userId){
        delete[Select Id from PermissionSetAssignment where AssigneeId=:UserId
        AND PermissionSetId IN (Select Id FROM PermissionSet WHERE IsOwnedByProfile =:false)];
    }
/**
* Method assigns permission set to user
* @author Jaco de Lange 
* @param userid
* @param permissionSetId
*/
    private static void assignPermissionSetToUser(Id userId, Id permSetId){
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetId = PermSetId;
        psa.AssigneeId = userId;	
        insert psa;
    }
/**
* Method assigns the Custom Base Customer Community Plus Login User profile to the community user
* @author Jaco de Lange 
* @param userid
* @param custom_base_customer_community_plus_login_user_profileid
*/
@TestVisible
    private static void updateUser(Id userId, Id communityProfileId){
        User userobj = new User(
        Id = userId,
        ProfileId = communityProfileId,
        IsActive = true);
        update userObj;
    }
/**
* Method checks for an active partner application in the db
* @author Peter Guest | 31-10-2023 
* @return Id 
**/
    private Id allowedToRegister(Auth.UserData data) {
        List<PP_PartnerApplication__c> pAppslist = SEL_PartnerApplication.newInstance()
                                                   .selectByEmailPrimaryContactId(new Set<String>{data.attributeMap.get('email')}, inProgress, approved);
        return pAppslist[0]?.PP_PrimaryContact__c;
    }
/**
* Method checks if a user already exists in the db with a ping uuid key
* @return User info
*/    
    private User findExistingUser(Auth.UserData data) {
        String pingUUID = pingStartValue+data?.attributeMap?.get(idKey)+pingEndValue;
        List<User> users = SEL_Users.newInstance().selectByPingUUID(new Set<String>{pingUUID});
        return !users.isEmpty() ? users[0] : null;
    }
/**
* Prepare User Data for salesforce from the data received from Ping Auth. Provider
* @author Jaco de Lange 
* @param data User data recieved from auth provider
* @param contactId Contact id
* @return User user info
*/
    private User prepareUserData(Auth.UserData data, Id contactId) {
        User u = new User();
            
        if (data != null) {
            u.Ping_UUID__c = pingStartValue + data?.attributeMap?.get(idKey) + pingEndValue;
            u.Username = data?.attributeMap?.get(emailKey);
            u.Email = data?.attributeMap?.get(emailKey);
            u.FirstName = data?.attributeMap?.get(firstNameKey);
            u.LastName = data?.attributeMap?.get(lastNameKey);
            u.MobilePhone = data?.attributeMap?.get(cellPhoneNumberKey);
            u.Alias = data?.attributeMap?.get(firstNameKey)?.left(8);
            u.CommunityNickname = data?.attributeMap?.get(subKey);
            u.LanguageLocaleKey = UserInfo.getLocale();
            u.LocaleSidKey = UserInfo.getLocale();
            u.EmailEncodingKey = emailEncoding;
            u.TimeZoneSidKey = timeZoneSid;
            u.ContactId = contactId;
            u.ProfileId = communityProfileId;
        }
        return u;
    }
}