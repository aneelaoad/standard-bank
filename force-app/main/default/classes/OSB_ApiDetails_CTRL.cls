/**
 * Controller class for OSBApiDetails component
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date May 2020
 */
public with sharing class OSB_ApiDetails_CTRL {
    /**
     * Returns a list of knowledge articles for the available APIS
     *
     * @param apiId id of API in IBM API Connect
     * @return List of Knowledge_kav
     **/
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getApiDetails(String apiId) {
        Map<String, Object> apiDetails;
        try {
            apiDetails = OSB_SRV_ApiConnect.newInstance().getAPIDetails(apiId);
        } catch (Exception e) {
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e.getMessage());
        }
        return apiDetails;
    }
    
    /**
     * Returns a list of Child_products__c for the available APIS
     *
     * @param knowledgeParent id of API in IBM API Connect
     * 
     * @return List of knowledgeParent
     **/
    @AuraEnabled
    public static List<Child_products__c> getSubApis(Id knowledgeParent){
        List <Child_products__c> subAPIList = SEL_ChildProducts.newInstance().selectByParentProductWoSharing(new set<Id>{knowledgeParent});
        return subAPIList;
    }

    /**
     * Returns a list of knowledge articles for the available API
     *
     * @param apiId ID of the API
     * @return List of knowledge articles for the API
     */
    @AuraEnabled(Cacheable=true)
    public static List<Knowledge__kav> getKnowledgeDetails(Id apiId) {
        return SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusIdAndRecordTypeIdWoSharing(
                new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},
                new Set<Id>{apiId},
                new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_API)}
        );
    }
}