/**
 * Controller class for OSBHeaderDropdown component
 * 
 * @author Denys Yelchaninov (dyelchaninov@deloittece.com)
 * @date October 2020
 * 
 */
public with sharing class OSB_HeaderDropdown_CTRL {
    /**
     * Returns integer count for notification bell
     * 
     * @return List<object> feedItems unread
     */
    @AuraEnabled
    public static Integer getUnreadFeedItemsNumberForUser() {
        String userId=UserInfo.getUserId();
        return [SELECT COUNT() FROM Notification__c WHERE (OwnerId = :userId OR Users__c INCLUDES(:userId,:OSB_Header_CTRL.ALL_USERS)) AND Is_Unread__c = TRUE];
    } 

    /**
    * Return the Login URL
    * 
    * @return String URL
    */ 
    @AuraEnabled(Cacheable=true)
    public static String getLoginURL() {
        return OSB_Header_CTRL.LOGIN_URL;
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
        String pingUrlExtention = OSB_URLs__c.getValues(adapterId).Value__c;
        if (UTL_User.isLoggedInUser()) {
            userName = UserInfo.getUserEmail();
            String pingBaseUrl = [SELECT DeveloperName, Endpoint FROM NamedCredential where DeveloperName =:OSB_Header_CTRL.PING_DIRECTORY LIMIT 1].Endpoint;
            return pingBaseUrl+pingUrlExtention+username;
        }
        return null;
    }
    
    /**
     * Queriers for knowledge articles for the insights and also gets the website url from OSB_urls custom setting
     *
     * @return map<String,object> of knowledge articles and the custom website url
     **/
    @AuraEnabled(Cacheable=true)
    public static Map<String,object> getInsights() {
        Map<String,object> insightsMap = new Map<String,object>();
        String url = OSB_URLs__c.getValues(OSB_InsightsHub_CTRL.INSIGHT_URL).Value__c;
        List<Knowledge__kav> unorderList = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdWoSharing(
                new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},
                new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_INSIGHT)},
                new Set<Id>{} );
        unorderList.sort();
        insightsMap.put('KnowledgeList', unorderList);
        insightsMap.put('WebUrl', url);
        return insightsMap;
    }
}