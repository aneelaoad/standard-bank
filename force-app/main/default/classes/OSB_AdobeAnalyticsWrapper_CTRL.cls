/**
 * Controller class for OSBAdobeAnalyticsWrapper aura component
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date April 2020
 *
 */
public with sharing class OSB_AdobeAnalyticsWrapper_CTRL {
    public static final String PAGE_DETAILS_KEY = 'pageDetails';
    public static final String LOGIN_STATUS_KEY = 'loginStatus';
    public static final String LOGGED_IN_STATUS = 'Logged in';

    @AuraEnabled
    public static Map<String, Object> getPageData(String pageUrl, Boolean isSinglePageApp) {
        String landingPage = 'Landing Page';
        List<OSB_AdobeAnalyticsData__mdt> adobeData;
        String loginStatus = UserInfo.getUserType() == DMN_User.GUEST_USER_TYPE ? DMN_User.GUEST_USER_TYPE : LOGGED_IN_STATUS;
        Map<String, Object> dataLayer = new Map<String, Object>{
                LOGIN_STATUS_KEY => loginStatus
        };
        if (UTL_User.isLoggedInUser() == false && String.isBlank(pageUrl)) {
            adobeData = new List<OSB_AdobeAnalyticsData__mdt>{
                    new OSB_AdobeAnalyticsData__mdt(
                            Page_Name__c = landingPage,
                            Page_Section__c = landingPage,
                            Sub_Section_1__c = landingPage)
            };
        } else if(isSinglePageApp) {
            adobeData = SEL_AdobeAnalyticsData.newInstance().selectByPageSection(new Set<String>{pageUrl});
        } else {
            adobeData = SEL_AdobeAnalyticsData.newInstance().selectByPageUrl(new Set<String>{pageUrl});
        }
        System.debug(adobeData);
        if(!adobeData.isEmpty()) {
            dataLayer.put(PAGE_DETAILS_KEY, adobeData[0]);
        }
        return dataLayer;
    }
}