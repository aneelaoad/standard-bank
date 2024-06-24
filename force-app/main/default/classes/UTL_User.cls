public without sharing class UTL_User {

    private static final Map<String, User> identifier2User = new Map<String, User>();
    private static Set<String> valuesToCache = new Set<String>();
    private static Boolean isSandbox{
        get{
            if(isSandbox == null){
                isSandbox = [   SELECT isSandbox
                                FROM Organization
                                LIMIT 1].isSandbox;
            }
            return isSandbox;
        }
        set;
    }
    
    private static final String suffix{
               get{
                   if(suffix == null){
                       suffix = isSandbox ? getSandboxName() : '';
                   }
                   return suffix;
                }
                set;
            }

    private static final String sfAdministrationUsername {
        get {
            if (sfAdministrationUsername == null) {
                sfAdministrationUsername = [
                    SELECT Username
                    FROM User
                    WHERE Username LIKE 'integration@standardbank.com%'
                ].Username;
            }
            return sfAdministrationUsername;
        }
        set;
    }

    private static final String pbbClientsUsername {
        get {
            if (pbbClientsUsername == null) {
                pbbClientsUsername = [
                    SELECT Username
                    FROM User
                    WHERE Username LIKE 'pbb.clients@standardbank.co.za%'
                ].Username;
            }
            return pbbClientsUsername;
        }
        set;
    }

    public static final String
            OLD_THEME = 'Theme1',
            CLASSIC_THEME = 'Theme2',
            MODERN_THEME = 'Theme3',
            LIGHTNING_THEME = 'Theme4d',
            MOBILE_THEME = 'Theme4t',
            PORTAL_THEME = 'PortalDefault',
            APPEXCHANGE_THEME = 'Webstore',
            COMMB_DIVISION = 'Commercial Banking';

    public static Boolean isLightnigUser() {
        return UserInfo.getUiThemeDisplayed() == LIGHTNING_THEME;
    }

    public static User getSfAdministrationUser(){
        return getCachedUser(sfAdministrationUsername);
    }

    public static User getPbbClientsUser(){
        return getCachedUser(pbbClientsUsername);
    }
    
    public static void cacheUsers(String userData){
        cacheUsers(new Set<String>{userData});
    }

    public static void cacheUsers(Set<Id> userData) {
        Set<String> usrIdentifiers = new Set<String>();

        for (Id usrId : userData) {
            usrIdentifiers.add(usrId);
        }

        cacheUsers(usrIdentifiers);
    }

    public static void cacheUsers(Set<String> userData) {
        cacheUsers(new List<String>(userData));
    }

    public static void cacheUsers(Id[] userData) {
        String[] usrIdentifiers = new String[]{
        };
        for (Id usrId : userData) {
            usrIdentifiers.add(usrId);
        }
        cacheUsers(usrIdentifiers);
    }

    public static void cacheUsers(String[] userData) {

        for (String usrIdentifier : userData) {

            if (usrIdentifier == null) {
                throw new UTL_UserException('No NULL values allowed');
            } else if (usrIdentifier instanceof Id) {
                Id usrId = Id.valueOf(usrIdentifier);
                if (usrId.getSobjectType() != User.getSObjectType()) {
                    throw new UTL_UserException('Provided Id does not belong to User Object "' + usrIdentifier + '"');
                }
                valuesToCache.add(usrIdentifier);
            } else if (usrIdentifier.contains('@')) {
                String usrName = applySuffix(usrIdentifier);
                valuesToCache.add(usrName);
            } else {
                throw new UTL_UserException('Unexpected user Identifier "' + usrIdentifier + '"');
            }
        }
    }

    public static String applySuffix(String usrName) {
        if (isSandbox
                && !(usrName.substringAfterLast('.').equals(suffix))) {
            usrName += '.' + suffix;
        }
        return usrName;
    }


    public static User getCachedUser(String userData) {
        return getCachedUsers(new String[]{
                userData
        })[0];
    }

    public static User[] getCachedUsers(Id[] userData) {
        String[] usrIdentifiers = new String[]{
        };

        for (Id usrId : userData) {
            usrIdentifiers.add(usrId);
        }

        return getCachedUsers(usrIdentifiers);
    }

    public static User[] getCachedUsers(String[] userData) {
        Map<String, User> id2user = new Map<String, User>();
        String[] updatedValues = new String[]{
        };

        for (String usrIdentifier : userData) {
            if (!(usrIdentifier instanceof Id)) {
                updatedValues.add(applySuffix(usrIdentifier));
            } else {
                updatedValues.add(usrIdentifier);
            }
        }

        cacheUsers(updatedValues);

        if (!identifier2User.keySet().containsAll(valuesToCache)) {
            cache();
        }
        for (String usrIdentifier : updatedValues) {
            if (!identifier2User.containsKey(usrIdentifier)) {
                throw new UTL_UserException('No User related to "' + usrIdentifier + '"');
            }
            id2user.put(usrIdentifier, identifier2User.get(usrIdentifier));
        }
        return id2user.values();
    }

    private static void cache() {
        for (User usr : [
                SELECT Name, Contact_Sync_ID__c, User_Division__c, Username, Email, Profile.Name
                FROM User
                WHERE Id iN:valuesToCache
                OR Username IN:valuesToCache
        ]) {
            identifier2User.put(usr.Id, usr);
            identifier2User.put(usr.Username, usr);
        }
        valuesToCache.clear();
    }

    public static String getSandboxName() {
        if (!isSandbox) {
            throw new UTL_UserException('Not a Sandbox!');
        }
        return sfAdministrationUsername.substringAfterLast('.');
    }

    public static void refreshCache() {
        if (!identifier2User.isEmpty()) {
            Set<String> usrIds = identifier2User.keySet().clone();
            identifier2User.clear();
            cacheUsers(usrIds);
        }
    }

    public static Boolean isCommBUser(Id userId) {
        return getCachedUser(userId).User_Division__c == COMMB_DIVISION;
    }

    public static Boolean isAutomatedProcess(){
        return DMN_User.TYPE_AUTOMATED_PROCESS.equals(UserInfo.getUserType());
    }

    /**
     * Used to check whether current user is a guest or not
     *
     * @return true if current user is logged in, false if it is a guest user
     */
    public static Boolean isLoggedInUser() {
        return UserInfo.getUserType() != DMN_User.GUEST_USER_TYPE;
    }

    public class UTL_UserException extends Exception {
    }

    public static Profile getUserProfile() {
        return [SELECT name FROM Profile WHERE Id = :userinfo.getProfileId()].get(0);
    }

    public static String getUserDivision() {
        User user = [SELECT User_Division__c FROM User WHERE Id = :UserInfo.getUserId()];
        return user.User_Division__c;
    }

    public static Boolean checkIfExecUser(){

        Profile prof = UTL_User.getUserProfile();

        return prof.Name == DMN_Profile.CLIENT_COVERAGE_EXEC_MOBILE_USER_INSIGHTS;
    }
}