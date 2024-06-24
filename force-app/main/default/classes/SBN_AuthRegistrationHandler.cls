/**
 * Base Auth.RegistrationHandler implementation for Standard Bank.
 *
 * This class provides some basic standards for all projects who
 * wish to integrate with an external SSO solution.
 *
 * Use the extension points defined in this class to customize.
 */
global with sharing abstract class SBN_AuthRegistrationHandler implements Auth.RegistrationHandler {

    protected final String TIME_ZONE_SID = 'Africa/Johannesburg';
    protected final String EMAIL_ENCODING = 'UTF-8';

    @TestVisible
    private static final String KEY_NETWORK = 'sfdc_networkid';

    @TestVisible
    private Ping_Registration_Site__mdt pingRegistrationSiteTestData;

    // Error messages
    global final String CONTACT_NOT_FOUND = 'Contact_not_found';
    global final String USER_ACCESS_REMOVED = 'User_Access_Removed';
    global final String USER_APPROVAL_DENIED = 'User_Approval_Denied';
    global final String USER_APPROVAL_PENDING = 'User_Approval_Pending';
    global final String USER_NOT_REGISTERED = 'User_not_registered';

    /**
     * Returns a User object using the specified portal ID and user information from Ping
     * The User object corresponds to the Pings’s user information
     *
     * @param portalId Id of the portal configured with this provider.
     * @param data User data received from auth provider
     * @return User record for creation
     */
    public User createUser(Id portalId, Auth.UserData data) {

        UserDataWrapper userResponseWrapper = extractUserData(data);

        User user = new User();

        prepareUserData(user, userResponseWrapper);

        User existingUser = findUserByUsername(user.Username);

        if (existingUser != null) {
            user.Id = existingUser.Id;
        }

        Contact foundContact = findContactForUser(user.Id, userResponseWrapper);

        if (foundContact == null) {
            throw new Auth.AuthProviderPluginException(CONTACT_NOT_FOUND);
        }

        UserAccessCheckResult userAccessCheckResult = verifyUserAccessForCreate(foundContact, userResponseWrapper);

        if (!userAccessCheckResult.success) {
            throw new Auth.AuthProviderPluginException(userAccessCheckResult.errorMessage);
        }

        Id foundProfile = findProfileForUser(user, userResponseWrapper);

        setContactAndProfile(user, foundContact, foundProfile);

        return user;
    }

    /**
     * Updates the specified user’s information.
     * This method is called if the user has logged in before with the authorization provider and then logs in again.
     *
     * @param userId Id of the existing user to update
     * @param portalId Id of the portal configured with this provider.
     * @param data User data recieved from auth provider
     */
    public void updateUser(Id userId, Id portalId, Auth.UserData data) {
        UserDataWrapper userDataWrapper = extractUserData(data);

        Contact contact = findContactForUser(userId, userDataWrapper);

        UserAccessCheckResult userAccessCheckResult = verifyUserAccessForUpdate(contact);

        if (!userAccessCheckResult.success) {
            throw new Auth.AuthProviderPluginException(userAccessCheckResult.errorMessage);
        }

        updateUserData(userId, contact, userDataWrapper);
    }

    /**
     * @param userData User data parameter that comes from the SSO provider
     *
     * @return A wrapper object that has extracted the required fields from
     * the user data object
     */
    global virtual UserDataWrapper extractUserData(Auth.UserData userData) {
        UserDataWrapper userDataWrapper = new UserDataWrapper();
        userDataWrapper.networkId = userData.attributeMap.get(KEY_NETWORK);
        userDataWrapper.id = userData.identifier;
        userDataWrapper.firstName = userData.firstName;
        userDataWrapper.lastName = userData.lastName;
        userDataWrapper.email = userData.email;

        return userDataWrapper;
    }

    /**
     * Find a contact to attach to the user. Default implementation will simply try
     * to match be email address. There may be more than 1 contact with the same
     * email address. In this case the first one will be taken. This method can
     * be overridden in order to provide more control over this behavior.
     *
     * Note that this method will only select the contact ID. If you need additional
     * fields then re-fetch the object with the required fields or override this
     * method.
     *
     * @param userId User ID if existing user found on creation or update, this parameter
     * might be <code>null</code> and is not used by the default implementation. If planning to use this
     * then implementers should check for <code>null</code> and handle accordingly.
     * @param userDataWrapper User data extracted from the SSO provider
     */
    global virtual Contact findContactForUser(Id userId, UserDataWrapper userDataWrapper) {
        String email = userDataWrapper.email;

        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :email];

        if (!contacts.isEmpty()) {
            return contacts.get(0);
        }
        return null;
    }

    /**
     * Application specific logic to link the new user to a profile
     *
     * Default implementation will lookup custom metadata by network Id
     * found in the user data wrapper parameter. This should be sufficient
     * for most, unless a site has more than one profile and some logic
     * is required in order to determine which profile.
     *
     * @param user User object, for user creation the user might not be created
     * yet
     * @param userDataWrapper User data extracted from the SSO provider
     */
    global virtual Id findProfileForUser(User user, UserDataWrapper userDataWrapper) {
        String networkId = userDataWrapper.networkId;
        try {
            Ping_Registration_Site__mdt pingRegistrationSite = getPingRegistrationSite(networkId);
            Profile profile = [SELECT Id FROM Profile WHERE Name = :pingRegistrationSite.Profile__c];
            return profile.Id;
        } catch (QueryException e) {
            throw new Auth.AuthProviderPluginException(
                    String.format('User profile not properly configured for network {0}. Check your Ping Registration custom metadata.',
                            new Object[]{
                                    networkId
                            }));
        }
    }

    /**
     * Sets standard user data on the user object prior to creation
     *
     * @param user User object, for user creation the user might not be created
     * yet
     * @param userDataWrapper User data extracted from the SSO provider
     */
    global virtual void prepareUserData(User user, UserDataWrapper userResponseWrapper) {
        String firstName = userResponseWrapper.firstName;
        String lastName = userResponseWrapper.lastName;
        String email = userResponseWrapper.email;
        String alias = buildAlias(firstName, lastName);
        String username = buildUsername(userResponseWrapper.email);
        user.Email = email;
        user.LastName = lastName;
        user.FirstName = firstName;
        user.Username = username;
        user.Alias = alias;
        user.LanguageLocaleKey = UserInfo.getLanguage();
        user.EmailEncodingKey = EMAIL_ENCODING;
        user.LocaleSidKey = UserInfo.getLocale();
        user.TimeZoneSidKey = TIME_ZONE_SID;
        user.UserPreferencesDisableBookmarkEmail = true;
        user.UserPreferencesDisableAllFeedsEmail = true;
        user.UserPreferencesDisableBookmarkEmail = true;
        user.UserPreferencesDisableFollowersEmail = true;
        user.UserPreferencesDisableLaterCommentEmail = true;
        user.UserPreferencesDisableLikeEmail = true;
        user.UserPreferencesDisableMentionsPostEmail = true;
        user.UserPreferencesDisableMessageEmail = true;
        user.UserPreferencesDisableProfilePostEmail = true;
        user.UserPreferencesDisableSharePostEmail = true;
        user.UserPreferencesDisCommentAfterLikeEmail = true;
        user.UserPreferencesDisMentionsCommentEmail = true;
        user.UserPreferencesDisProfPostCommentEmail = true;
        user.UserPreferencesHideChatterOnboardingSplash = true;
    }

    /**
     * Sets the contact and profile on the user object. Default
     * implementation just sets ContactId and ProfileId. This
     * can be overridden if any additional actions are necessary.
     *
     * @param user User object
     * @param contact Matched contact
     * @param profile Profile to set
     */
    global virtual void setContactAndProfile(User user, Contact contact, Id profile) {
        user.ContactId = contact.Id;
        user.ProfileId = profile;
    }

    /**
     * Check if the contact has access to the given application. Do specific checks
     * to your application in here.
     *
     * @param contact Matched contact
     *
     * @return UserAccessCheckResult object with status success or fail
     */
    global abstract UserAccessCheckResult verifyUserAccessForCreate(Contact contact, UserDataWrapper userDataWrapper);

    /**
     * Check if the contact still has access to the given application after update.
     * Do specific checks to your application in here.
     *
     * @param contact Matched contact
     *
     * @return UserAccessCheckResult object with status success or fail
     */
    global abstract UserAccessCheckResult verifyUserAccessForUpdate(Contact contact);

    /**
     * Perform any additional checks/updates before updating the user record. This gets
     * called only on update user and not create user.
     *
     * @param user User object
     * @param contact Matched contact
     */
    global abstract void performAdditionalUserUpdates(User user, Contact contact);

    private String buildUsername(String email) {
        return email + lookupSuffix();
    }

    private String lookupSuffix() {
        Ping_General_Settings__mdt[] pingGeneralSettings = getPingGeneralSettings();

        if (pingGeneralSettings.isEmpty()) {
            return '';
        }

        return '.' + pingGeneralSettings[0].Username_Suffix__c;
    }

    @TestVisible
    private String buildAlias(String firstName, String lastName) {
        String alias = firstName != null ? firstName.left(1) : '';
        alias += lastName;
        return alias.left(8).toLowerCase();
    }

    private void updateUserData(Id userId, Contact contact, UserDataWrapper userDataWrapper) {

        User user = new User(Id = userId);
        user.FirstName = userDataWrapper.firstName;
        user.LastName = userDataWrapper.lastName;
        user.Email = userDataWrapper.email;

        performAdditionalUserUpdates(user, contact);

        update user;
    }

    private User findUserByUsername(String username) {
        String [] usernames = new String[]{
                username
        };
        User [] users = [
                SELECT Id, Username
                FROM User
                WHERE Username IN :usernames
        ];
        if (!users.isEmpty()) {
            return users[0];
        }
        return null;
    }

    private Ping_General_Settings__mdt[] getPingGeneralSettings() {
        if (Test.isRunningTest()) {
            return new Ping_General_Settings__mdt[] {};
        }

        return [
                SELECT Username_Suffix__c
                FROM Ping_General_Settings__mdt
                WHERE DeveloperName = 'DEFAULT'
        ];
    }

    private Ping_Registration_Site__mdt getPingRegistrationSite(String networkId) {
        if (Test.isRunningTest()) {
            return pingRegistrationSiteTestData;
        }
        return [SELECT Profile__c FROM Ping_Registration_Site__mdt WHERE Network_Id__c = :networkId];
    }

    private final static UserAccessCheckResult SUCCESS_ACCESS_CHECK = new UserAccessCheckResult();
    private final static String USER_ACCESS_CHECK_ERROR_MSG = '{0}&contactid={1}';

    /**
     * Wrapped inner class for checking user access.
     *
     * Use the protected methods below to actually  instantiate these
     */
    global class UserAccessCheckResult {
        /**
         * Was the check successful or not
         */
        global final Boolean success;
        /**
         * In case of failure provides details
         */
        global final String errorMessage;

        private UserAccessCheckResult(String errorMessage) {
            this.success = false;
            this.errorMessage = errorMessage;
        }

        private UserAccessCheckResult() {
            this.success = true;
        }
    }

    /**
     * Default success result
     *
     * @return A successful user access check result
     */
    global UserAccessCheckResult userAccessCheckSuccess() {
        return SUCCESS_ACCESS_CHECK;
    }

    /**
     * Creates a failure result with an error message
     *
     * @param message Error message
     *
     * @return A failed user access check result
     */
    global UserAccessCheckResult userAccessCheckFailure(String message) {
        return new UserAccessCheckResult(message);
    }

    /**
     * Creates a failure result with an error message and contact ID
     *
     * The message will be formatted as:
     * <code>
     *     {message}&contactid={contactId}
     * </code>
     *
     * @param message Error message
     * @param contactId Contact ID
     *
     * @return A failed user access check result
     */
    global UserAccessCheckResult userAccessCheckFailure(String message, Id contactId) {
        return new UserAccessCheckResult(String.format(USER_ACCESS_CHECK_ERROR_MSG, new Object []{
                message, contactId
        }));
    }

    global with sharing class UserDataWrapper {
        global String networkId {get;set;}
        global String email {get; set;}
        global String cellphone {get; set;}
        global String dateOfBirth {get; set;}
        global String firstName {get; set;}
        global String lastName {get; set;}
        global String id {get; set;}
    }
}