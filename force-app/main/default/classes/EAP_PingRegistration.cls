/**
 * Events App Registration Helper for Ping Authentication Provider
 * 
 * @author The Cocktail
 * @date October 2021
 */
public with sharing class EAP_PingRegistration implements Auth.RegistrationHandler {
    public class RegHandlerException extends Exception {}

    private static final String KEY_FIRST_NAME = 'First_name';
    private static final String KEY_LAST_NAME = 'Last_name';
    private static final String KEY_NETWORK = 'sfdc_networkid';
    private static final String KEY_SUB = 'sub';
    private static final String KEY_ID = 'id';
    private static final String TIME_ZONE_SID = 'Africa/Johannesburg';
    private static final String EMAIL_ENCODING = 'UTF-8';

    private static final String CONTACT_NOT_FOUND = 'Contact_not_found';
    private static final String USER_ACCESS_REMOVED = 'User_Access_Removed';
    private static final String USER_APPROVAL_DENIED = 'User_Approval_Denied';
    private static final String DATA_MISSING_MESSAGE = 'Auth.UserData was null';
    private static final String KEY_NETWORK_DATA_MISSING_MESSAGE = KEY_NETWORK + ' value not found in Auth.UserData';

    private static final String EVENT_APP_SUFFIX = '.eventsapp';

    /**
     * Prepare User Data for salesforce from the data received from Ping Auth. Provider
     * 
     * @param data User data recieved from auth provider
     * @param u User object instance created with the data
     */
    public void prepareUserData(Auth.UserData data, User u, Map<String, OSB_PingRegistrationResponse__c> pingRegistrationResponseSettingsMap) {
        if (data != null) {
            String firstName;
            String lastName;
            String alias;
            String email;

            firstName = data.attributeMap.get(pingRegistrationResponseSettingsMap.get(KEY_FIRST_NAME).Value__c);
            lastName = data.attributeMap.get(pingRegistrationResponseSettingsMap.get(KEY_LAST_NAME).Value__c);
            email = data.attributeMap.get(pingRegistrationResponseSettingsMap.get(KEY_SUB).Value__c);
            alias = firstName;
            if (alias.length() > 8) {
                alias = alias.substring(0, 8);
            }
            u.Email = email;
            u.LastName = lastName;
            u.FirstName = firstName;
            u.Alias = alias;
            u.LanguageLocaleKey = UserInfo.getLocale();
            u.LocaleSidKey = UserInfo.getLocale();
            u.EmailEncodingKey = EMAIL_ENCODING;
            u.TimeZoneSidKey = TIME_ZONE_SID;
            u.UserPreferencesDisableBookmarkEmail = true;
            u.UserPreferencesDisableAllFeedsEmail = true;
            u.UserPreferencesDisableBookmarkEmail = true;
            u.UserPreferencesDisableFollowersEmail = true;
            u.UserPreferencesDisableLaterCommentEmail = true;
            u.UserPreferencesDisableLikeEmail = true;
            u.UserPreferencesDisableMentionsPostEmail = true;
            u.UserPreferencesDisableMessageEmail = true;
            u.UserPreferencesDisableProfilePostEmail = true;
            u.UserPreferencesDisableSharePostEmail = true;
            u.UserPreferencesDisCommentAfterLikeEmail = true;
            u.UserPreferencesDisMentionsCommentEmail = true;
            u.UserPreferencesDisProfPostCommentEmail = true;
            u.UserPreferencesHideChatterOnboardingSplash = true;
        
            u.Username = UTL_User.applySuffix(data.attributeMap.get(pingRegistrationResponseSettingsMap.get(KEY_SUB).Value__c)+EVENT_APP_SUFFIX);
            u.UserPermissionsSFContentUser = true;
            u.EAP_Community_Access__c = true;
        }
    }

    /**
     * Updates the specified user’s information.
     * This method is called if the user has logged in before with the authorization provider and then logs in again.
     * 
     * @param userId Id of the existing user to update
     * @param portalId Id of the portal configured with this provider.
     * @param data User data recieved from auth provider
     */
    public void  updateUser(Id userId, Id portalId, Auth.UserData data) {
        Map<String, OSB_PingRegistrationResponse__c> pingRegistrationResponseSettingsMap = OSB_PingRegistrationResponse__c.getAll();
        try {
            if (data != null) {
				fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
				Contact foundContact = findContact(data, pingRegistrationResponseSettingsMap);
                if (foundContact == null) {
                    throw new RegHandlerException(CONTACT_NOT_FOUND);
                }
                if (foundContact.EAP_Community_Access_Status__c == DMN_Contact.EAP_COMMUNITY_ACCESS_STATUS_INACTIVE) {
					throw new RegHandlerException(USER_ACCESS_REMOVED + '&contactid=' + foundContact.Id);
				}
                if (foundContact.EAP_Community_Access_Status__c == DMN_Contact.EAP_COMMUNITY_ACCESS_STATUS_DECLINED) {
                    throw new RegHandlerException(USER_APPROVAL_DENIED + '&contactid=' + foundContact.Id);
                }

				User user = new User(Id = userId);
				user.Email = data.attributeMap.get(pingRegistrationResponseSettingsMap.get(KEY_SUB).Value__c);
				user.LastName = data.attributeMap.get(pingRegistrationResponseSettingsMap.get(KEY_LAST_NAME).Value__c);
				user.FirstName = data.attributeMap.get(pingRegistrationResponseSettingsMap.get(KEY_FIRST_NAME).Value__c);

                uow.registerDirty(user);
				uow.commitWork();
            } else {
                throw new RegHandlerException(DATA_MISSING_MESSAGE);
            }
        } catch (Exception e) {
            List<String> messages = new List<String>{'User id: ' + userId};
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_EVENTSAPP, EAP_PingRegistration.class.getName(), messages);
            throw e;
        }
    }

    /**
     * Returns a User object using the specified portal ID and user information from Ping
     * The User object corresponds to the Pings’s user information
     * 
     * @param portalId Id of the portal configured with this provider.
     * @param data User data recieved from auth provider
     * @return User record for creation
     */
    public User createUser(Id portalId, Auth.UserData data) {
        Map<String, OSB_PingRegistrationResponse__c> pingRegistrationResponseSettingsMap = OSB_PingRegistrationResponse__c.getAll();
        User u = new User();
        prepareUserData(data, u, pingRegistrationResponseSettingsMap);
        
        List<User> existingUsers = SEL_Users.newInstance().selectByUserName(new Set<String>{u.Username});
        if(existingUsers.size()>0){
            u.Id = existingUsers[0].Id;
        }
        try {
            if (data.attributeMap.containsKey(KEY_NETWORK)) {
                Contact foundContact = findContact(data,pingRegistrationResponseSettingsMap);

                if (foundContact == null) {
                    throw new RegHandlerException(CONTACT_NOT_FOUND);
                }
                if (foundContact.EAP_Community_Access_Status__c != null && foundContact.EAP_Community_Access_Status__c == DMN_Contact.EAP_COMMUNITY_ACCESS_STATUS_DECLINED) {
                    throw new RegHandlerException(USER_APPROVAL_DENIED + '&contactid=' + foundContact.Id);
                }
                if (foundContact.EAP_Community_Access_Status__c != null && foundContact.EAP_Community_Access_Status__c == DMN_Contact.EAP_COMMUNITY_ACCESS_STATUS_INACTIVE) {
                    throw new RegHandlerException(USER_ACCESS_REMOVED + '&contactid=' + foundContact.Id);
                }

                u.ProfileID = UTL_Profile.getProfileId(DMN_Profile.EVENTS_APP_COMMUNITY);
                u.ContactId = foundContact.Id;
                u.Contact_Sync_ID__c = foundContact.Id;

                return u;
            } else {
                SRV_Logger.newInstance().log(new RegHandlerException(KEY_NETWORK_DATA_MISSING_MESSAGE), DMN_Log.AREA_EVENTSAPP, EAP_PingRegistration.class.getName());
                return null;
            }
        } catch (Exception e) {
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_EVENTSAPP, EAP_PingRegistration.class.getName());
            throw e;
        }
    }

    /**
     * Returns a Contact record with the email or the pingId
     * 
     * @param data User data recieved from auth provider
     * @return Contact record
     */
    private static Contact findContact(Auth.UserData data,Map<String, OSB_PingRegistrationResponse__c> pingRegistrationResponseSettingsMap){

        Contact foundContact;

        List<Contact> lstContact = SEL_Contacts.newInstance()
                .selectByEmailOrPingId(
                        new Set<String>{data.attributeMap.get(pingRegistrationResponseSettingsMap.get(KEY_ID).Value__c)},
                        new Set<String>{data.attributeMap.get(pingRegistrationResponseSettingsMap.get(KEY_SUB).Value__c)}
                );
        if(!lstContact.isEmpty()){
            foundContact = lstContact.get(0);
        }
        return foundContact;
    }

}