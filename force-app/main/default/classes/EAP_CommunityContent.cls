/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public with sharing class EAP_CommunityContent {
    private static String endpoint = null;
    private static final String PING_URL = '/services/auth/sso/';
    public static final String AUTH_PROVIDER_NAME = 'EAP_Ping_Authentication';

    /**
     * @description Redirects the user to the login page if not logged into community.
     * Prevents ilegal access if the user knows the URL
     *
     * @return PageReference
     **/
    public PageReference doRedirectToPing(){
        PageReference pageRef = new PageReference(PING_URL+AUTH_PROVIDER_NAME);
        pageRef.setRedirect(true);
        return pageRef;
    }
}