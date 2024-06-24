/**
 * @description DMN_Profile
 * @author Unknown
 * @date Unknown
*/
public with sharing class DMN_Profile {
    public static final String CLIENT_COVERAGE_EXEC_MOBILE_USER_INSIGHTS = 'Custom Standard Lightning Client Coverage Exec Mobile User Insights'
                    , CLIENT_COVERAGE_MOBILE_USER_INSIGHTS = 'Custom Standard Lightning Client Coverage Mobile User Insights'
                    , GENERIC_BUSINESS_UNIT_MOBILE_USER = 'Custom Standard Lightning Generic Business Unit Mobile User'
                    , GENERIC_BUSINESS_UNIT_MOBILE_USER_INSIGHTS = 'Custom Standard Lightning Generic Business Unit Mobile User Insights'
                    , BUSINESS_ADMINISTRATOR = 'Business Administrator'
                    , KYC_USER = 'Custom KYC User Mobile'
                    , PERSONAL_BUSINESS_BANKING_CUSTOM_STD_USER_MOBILE = 'Personal Business Banking Custom Std User - Mobile'
                    , READ_ONLY = 'Read Only'
                    , READ_ONLY_MOBILE = 'Custom Read Only Mobile'
                    , SYSTEM_ADMINISTRATOR = 'System Administrator'
                    , API_USER = 'Api User'
        			, CLIENT_SERVICE_USER = 'Client Service User';
    public static final String ONE_HUB_COMMUNITY = 'OneHub Community User Login';
    public static final String ONE_HUB_ADMINISTRATOR = 'OneHub Administrator';
    public static final String CUSTOM_BASE_CUSTOMER_COMMUNITY_PLUS_LOGIN_USER = 'Custom Base Customer Community Plus Login User';
    public static final String COMMERCIAL_BANKING_CUSTOM_STD_USER = 'Commercial Banking Custom Std User';
    public static final String COMMERCIAL_BANKING_CUSTOM_STD_USER_MOBILE = 'Commercial Banking Custom Std User - Mobile';
    public static final String BCC_CUSTOM_STD_USER_MOBILE = 'BCC Custom Std User - Mobile';
    public static final String BCC_AR_CUSTOM_STD_USER_MOBILE = 'BCC AR Custom Std User - Mobile';
    
    public static final String EVENTS_APP_COMMUNITY = 'Events App Community User';

    /**
    * @description Checks if User Profile is Commercial Banking
    * @return Boolean result of Profile check
    */
    public static Boolean isCommBUser(){
        return UserInfo.getProfileId()  == UTL_Profile.getProfileId(COMMERCIAL_BANKING_CUSTOM_STD_USER) ||
            UserInfo.getProfileId()  == UTL_Profile.getProfileId(COMMERCIAL_BANKING_CUSTOM_STD_USER_MOBILE);
    }

    /**
    * @description checks if user is Business Banking  
    * @author Tukelo Moseamo | 07-27-2023 
    * @return Boolean 
    **/
    public static Boolean isBusinessUser() {
        return UserInfo.getProfileId()  == UTL_Profile.getProfileId(BCC_CUSTOM_STD_USER_MOBILE);
        
    }

    /**
    * @description checks is user is Enterprise USer  
    * @author Tukelo Moseamo | 07-27-2023 
    * @return Boolean 
    **/
    public static Boolean isEnterpriseUser() {
        return UserInfo.getProfileId()  == UTL_Profile.getProfileId(PERSONAL_BUSINESS_BANKING_CUSTOM_STD_USER_MOBILE);
    }
}