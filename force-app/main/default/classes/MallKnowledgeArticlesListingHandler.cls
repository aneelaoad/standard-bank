/**
* @description  : BCB Platform Knowledge Article Handler
*
* @author Ankit Kumar
* @date April 2024
*/
public with sharing class MallKnowledgeArticlesListingHandler {

    private static final String DEFAULT_BCB_RECORDTYPE = 'Business_Commercial_Banking';
    private static final Integer DEFAULT_BCB_RECORD_LIMIT = 1000;

    /**
    * @description | Used to get Articles from Knowledge Object
    * @author Ankit Kumar 
    * @return List<Knowledge__kav> 
    **/
    public static List<Knowledge__kav> getArticles(){
        Set<Id> recordTypeIds = new Set<Id>();
        List<Knowledge__kav> articles;
        recordTypeIds.add(UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DEFAULT_BCB_RECORDTYPE));
        
        try {
            articles = SEL_KnowledgeArticleVersions.newInstance().selectArticleByPublishStatusAndRecordType(
                new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},recordTypeIds,DEFAULT_BCB_RECORD_LIMIT);
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallKnowledgeArticlesListingHandler.getArticles', e);
        }
        return articles;
    }
}