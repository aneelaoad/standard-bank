/**
 * Controller class for OSBHeaderOPTL component
 * 
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date March 2020
 * 
 */
public with sharing class OSB_Header_CTRL {
    public static final String ALL_USERS = 'All Users';
    public static final String PING_DIRECTORY = 'Ping_directory';
    public static final String LOGIN_URL = '/services/auth/sso/Ping_Authentication';
    public static final String IELOGIN_URL = '/s/unsupported-internet-explorer';

    private static final String TERMS_LINK_SEL = 'OSB_T&C';
    private static final String API_MARKETPLACE = 'OSB_APImarketPlaceUrl';

    /**
     * Returns integer count for notification bell
     * 
     * @return List<object> feedItems unread
     */
    @AuraEnabled
    public static Integer getUnreadFeedItemsNumberForUser() {
        String userId=UserInfo.getUserId();
        return [SELECT COUNT() FROM Notification__c WHERE (OwnerId = :userId OR Users__c INCLUDES(:userId,:ALL_USERS)) AND Is_Unread__c = TRUE];
    }
    
    /**
     * Used to display the user name once logged in on dashboard
     * 
     * @return String FirstName of logged in User
     */ 
    @AuraEnabled(Cacheable=true)
    public static User getUserNameIfLoggedIn() {
        if(UTL_User.isLoggedInUser()) {
            return SEL_Users.newInstance().selectById(new Set<Id>{UserInfo.getUserId()})[0];
        }
        return null;
    }
    
    /**
     * Used to display team profile to the correct users
     * 
     * @return String OSB_Access_Role of logged in User
     */ 
    @AuraEnabled(Cacheable=true)
    public static String getContactAuth() {
        return SEL_Contacts.newInstance().selectByUserId(new Set<Id>{UserInfo.getUserId()})[0].OSB_Community_Access_Role__c;
    }
    
    /**
     * Return the Change Password URL of loggen in User
     * 
     * @return String URL
     */ 
    @AuraEnabled(Cacheable=true)
    public static String getChangePasswordUrlPing() {
        String userName;
        String adapterId = 'AdapterId';
        String targetResourceName = 'OSB_Ping_TargetResource';
        String pingUrlExtention = OSB_URLs__c.getValues(adapterId).Value__c;
        String targetResource = '&TargetResource=' + OSB_URLs__c.getValues(targetResourceName).Value__c;
        if (UTL_User.isLoggedInUser()) {
            userName = UserInfo.getUserEmail();
            String pingBaseUrl = [SELECT DeveloperName, Endpoint FROM NamedCredential where DeveloperName =:PING_DIRECTORY LIMIT 1].Endpoint;
            return pingBaseUrl+pingUrlExtention+username+targetResource;
        }
        return null;
    }
    
    /**
     * Return the Login URL
     * 
     * @return String URL
     */ 
    @AuraEnabled(Cacheable=true)
    public static String getLoginURL() {
        return LOGIN_URL;
    }

    /**
     * Return the Unsupported Browser Page url
     * To prevent users from logging in to OneHub using Internet Explorer as it is no longer supported.
     * @return String URL
     */ 

    @AuraEnabled(Cacheable=true)
    public static String getIELoginURL() {
        return IELOGIN_URL;

    }

    /**
    * Returns link for Terms and conditions
    * <br/>SGPRT-4230
    *
    * @return string value of T&C url
    */
    @AuraEnabled(Cacheable=true)
    public static String getTermsLink() {
        return OSB_URLs__c.getValues(TERMS_LINK_SEL).Value__c;
    } 

    /**
    * Returns link for Terms and conditions
    *
    * @return string value of API marketplace url
    */
    @AuraEnabled(Cacheable=true)
    public static String getApiLink() {
        return OSB_URLs__c.getValues(API_MARKETPLACE).Value__c;
    }
}