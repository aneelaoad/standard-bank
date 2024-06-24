/**
* @description  : Generic Knowledge Controller
* User Story : SFP-4963
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
public with sharing class CMN_KnowledgeArticleListing_CTRL {

        
    /**
    * @description | Used to get Articles from Knowledge Object
    * @author Syed Ovais Ali | 24-06-2021 
    * @param  articleType
    * @param  recordLimit
    * @return List<Knowledge__C> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getArticles(string articleType, Integer recordLimit){
        Set<Id> recordTypeIds = new Set<Id>();
        List<Knowledge__kav> articles;
        
        If(articleType == 'Success Stories'){
            recordTypeIds.add(UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SUCESSSTORIES));
        }else if(articleType == 'FAQ'){
            recordTypeIds.add(UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_FAQCUSTOM));
        }else if(articleType == 'All Articles'){
            recordTypeIds.add(UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SUCESSSTORIES));
            recordTypeIds.add(UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_ARTICLE));
            recordTypeIds.add(UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_NEWS));
        }
        
        try {
            articles = SEL_KnowledgeArticleVersions.newInstance().selectArticleByPublishStatusAndRecordType(
                new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},recordTypeIds,recordLimit);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return articles;
    }
    
    /**
    * @description | Used to get Featured Articles from Knowledge Object
    * User Story : SFP-4871
    * @param  recordLimit
    * @return List<Knowledge__C> 
    **/
    @AuraEnabled(cacheable=true)
    public static  List<Knowledge__kav> getFeaturedArticle(Integer recordLimit){
        
        List<Knowledge__kav> articles;
        
        try {
            articles = SEL_KnowledgeArticleVersions.newInstance().selectFeaturedArticles(
                new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},recordLimit);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return articles;
    }
    
}