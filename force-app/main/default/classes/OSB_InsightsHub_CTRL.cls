/**
 * OSB_InsightsHub_CTRL class for OSBInsightsHub Lightning Component
 *
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @date June 2020
 *
 **/
public with sharing class OSB_InsightsHub_CTRL {
    
    public static final String INSIGHT_URL = 'Insights_website'; 
    
    /**
     * Queriers for knowledge articles for the insights and also gets the website url from OSB_urls custom setting
     *
     * @return map<String,object> of knowledge articles and the custom website url
     **/
    @AuraEnabled(Cacheable=true)
    public static Map<String,object> getInsights() {
        Map<String,object> InsightsMap = new Map<String,object>();
        String url = OSB_URLs__c.getValues(INSIGHT_URL).Value__c;
        List<Knowledge__kav> unorderList = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdWoSharing(
                new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},
                new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_INSIGHT)},
                new Set<Id>{} );
        unorderList.sort();
        InsightsMap.put('KnowledgeList', unorderList);
        InsightsMap.put('WebUrl', url);
        return InsightsMap;
    }
}