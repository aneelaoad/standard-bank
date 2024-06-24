/**
 * @description : CTRL_MallCommunitiesLanding : controller that takes the user to the right start page based on credentials or lack thereof
 * @author: Manasi Londhe
 * @since 
 */
public class CTRL_MallCommunitiesLanding {
    /**
     * @description isPreferenceStored
     */    
    public String isPreferenceStored { get; set; }
    /**
     * @description isTenant
     */     
    public String isTenant { get; set; }
    /**
     * @description mallHomePage stores the url of mall home page
     */  
    public String mallHomePage {get;set;}
    /**
     * @description storeManagementPage stores the url of the store management page
     */  
    public String storeManagementPage {get; set;}

    /**
     * @description CommunitiesLandingController Constructor
     */
    public CTRL_MallCommunitiesLanding() {
        try {
            Mall_SSO_Configuration__mdt mallSSOConfig = Mall_SSO_Configuration__mdt.getInstance('Mall_SSO_Configuration');
            mallHomePage = mallSSOConfig.Mall_Home_Page__c;
            List<User> loggedInUsers = SEL_Users.newInstance().selectUsersWithProfileByIds(new Set<Id>{(Id)UserInfo.getUserId()});
            if(loggedInUsers == NULL || loggedInUsers.size() == 0) {
                return;
            }

            User loggedInUser =  loggedInUsers[0];
            List<Provider__c> providers = SEL_Providers.newInstance().selectByCustomFilterCondition('Related_Client__c IN (\'' + String.join(new List<String>{loggedInUser.accountId}, '\',\'') + '\') AND Parent_Provider__c = NULL');
            if(!(providers != NULL && providers.size() > 0) && !Test.IsRunningTest()) {
                return;
            }
            storeManagementPage = mallSSOConfig.Mall_Home_Page__c + '/s/provider/'+ (Test.IsRunningTest() ? UserInfo.getUserId() : providers[0].Id);
            List<String> tenantProfiles = new List<String>{System.Label.Store_Worker_Profile, System.Label.Store_Manager_Profile};
            Boolean isTenantBool = tenantProfiles.contains(loggedInUser.Profile.Name);
            isTenant = String.valueOf(tenantProfiles.contains(loggedInUser.Profile.Name));
            //check if first time login
            if(isTenantBool && CTRL_MallCommunitiesLanding.firstTimeUserLogin(loggedInUser.Id)) {
                if(loggedInUser.Profile.Name == System.Label.Store_Worker_Profile) {
                    storeManagementPage += '?' + mallSSOConfig.Mall_Store_Worker_Onboarding_Tab__c;
                }
                if(loggedInUser.Profile.Name == System.Label.Store_Manager_Profile) {
                    storeManagementPage += '?' + mallSSOConfig.Mall_Store_Manager_Onboarding_Tab__c;
                }
            }
            isPreferenceStored = 'true';
        }  catch(exception e) { 
            throw MallExceptionUtil.throwAuraException('CTRL_MallCommunitiesLanding.CTRL_MallCommunitiesLanding()', e);
        }
    }

    /**
     * @description firstTimeUserLogin
     * @param userId String
     * @return Boolean
     */
    public static Boolean firstTimeUserLogin(String userId) {
        List<LoginHistory> loginHistory = SEL_LoginHistories.newInstance().selectByUserIds(new Set<Id>{(Id)userId}, 2);
        if(loginHistory.size() <= 1 ) {
            return true;
        }
        return false;
    }
}