/**
 * Controller class for OSBNewCaseForm component
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date March 2020
 *
 */
public without sharing class OSB_NewCaseForm_CTRL {
	private static final String USER_CONTACT_MAP_EMAIL = 'Email';
    private static final String USER_CONTACT_MAP_PHONE = 'Phone';
    private static final String USER_CONTACT_MAP_NAME = 'Name';

    /**
     * Creates Case with CIB Client Case RT from JSON string with Contact Id taken from current user
     *
     * @param caseRecord Case record to be created
     *
     * @return created Case record
     */
    @AuraEnabled
    public static Case createCaseWithContactId(Case caseRecord) {
        caseRecord.OwnerId = UTL_Queue.getQueueId(DMN_Queue.ONEHUB_QUEUE);
        return DMN_Case.createCaseWithUserContactId(caseRecord);
    }

    /**
     * Retrieves user details from Ping service
     *
     * @return Map<String, String> of user details retrieved from Ping service
     */
    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getPingUserDetails() {
        Map<String, String> userDetailMap = new Map<String, String> ();
        userDetailMap = OSB_SRV_PingIntegration.newInstance().getUserDetails();
        return userDetailMap;
    }

    /**
        * Retrieves user contact details
        *
        * @return Map<String,String> of contact details with Email and Name
        */
    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getUserContactDetails() {
        String dialingCode;
        String phoneNumber;
        List<User> users = SEL_Users.newInstance().selectById(new Set<Id>{UserInfo.getUserId()});
        if (users[0] != null) {
            Map<String, String> userContactMap = new Map<String, String>();
            userContactMap.put(USER_CONTACT_MAP_EMAIL, users[0].Email);
            userContactMap.put(USER_CONTACT_MAP_NAME, users[0].Name);
            return userContactMap;
        }
        return null;
    }

    /**
     * Checks if the current user is logged in to the community
     *
     * @return true if current user is logged in, false if it is a guest user
     */
    @AuraEnabled(Cacheable=true)
    public static Boolean isUserLoggedIn() {
        return UTL_User.isLoggedInUser();
    }
}