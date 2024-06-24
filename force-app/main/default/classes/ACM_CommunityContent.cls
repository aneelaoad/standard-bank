/**
 * ACM_CommunityContent class used in ACM community
 *
 * @author Swapnil Walse (swapnil.walse@tetrad.co.za)
 * @date Nov 2021
 *
 **/
public class ACM_CommunityContent {
/**
     * Redirects the user to the login page if not logged into community.
     *
     * @return PageReference
     **/
    private static final String PING_URL = '/services/auth/sso/';
    
    public boolean displayPopup {get; set;}     
    
    
    public void closePopup() {
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }

    public PageReference doRedirectToPing(){
        PageReference pageRef = new PageReference(PING_URL + ACM_PingRegistration.ACM_AUTH_PROVIDER_NAME);
        pageRef.setRedirect(true);
        return pageRef;
    }
}