/**
* @description DMN Class for Knowledge sObject
*
* @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
* @date March 2020
*
* @LastModified October 2023
* @author Nkosi Ncube (nkosi.ncube@standardbank.co.za)
* @UserStory SFP-20792
* @LastModifiedReason Added new RecordType variable for Provider Spaces
*/

public with sharing class DMN_Knowledge {
    public static final String OBJ_NAME = 'Knowledge__kav';
    public static final String PUBLISH_STATUS_DRAFT = 'Draft';
    public static final String PUBLISH_STATUS_ONLINE = 'Online';
    public static final String RT_API = 'Community_Content_API_Product';
    public static final String RT_SOLUTION = 'Community_Content_Solution';
    public static final String RT_INSIGHT = 'Community_Content_Insights';
    public static final String RT_SUCESSSTORIES = 'Community_Content_Success_Stories';
    public static final String RT_FAQCUSTOM = 'Community_Content_FAQ';
    public static final String RT_ARTICLE = 'Community_Content_Article';
    public static final String RT_NEWS = 'Community_Content_News';
    public static final String RT_PROVIDER_SPACES = 'Community_Content_Provider_Spaces';
    
    /**
    * @description Updates the subscribed 
    *
    * @param knowledgeList - list of knowledge articles from TRH_Knowledge
    *
    */
    public static void updateSubSolutions(List<Knowledge__kav> knowledgeList) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        Map<String, Knowledge__kav> knowledgeTitle2Knowledge = new Map<String, Knowledge__kav>();
        Set<Id> recordTypeIdsToInclude = new Set<Id> {
            UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SOLUTION)
                };
                    for(Knowledge__kav knowledge : knowledgeList) {    
                        if(recordTypeIdsToInclude.contains(knowledge.RecordTypeId)) {
                            knowledgeTitle2Knowledge.put(knowledge.Title, knowledge);
                        }
                    }
        try {
            if(!knowledgeTitle2Knowledge.isEmpty()) {
                List<Subscribed_Solutions__c> subSolutions = SEL_SubscribedSolutions.newInstance().selectBySolutionTitle(knowledgeTitle2Knowledge.keySet());
                for(Subscribed_Solutions__c sol : subSolutions) {
                    sol.Solution__c = knowledgeTitle2Knowledge.get(sol.Solution__r.Title).Id;
                    uow.registerDirty(subSolutions);
                }
                uow.commitWork();
            }
        }
        catch(Exception e) {
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, DMN_Knowledge.class.getName());
        }
    }
    
    /**
    * @description Updates the child products linked to the parent knowledge articles
    *
    * @param knowledgeList - list of knowledge articles from TRH_Knowledge
    *
    */
    public static void updateChildrenApi(List<Knowledge__kav> knowledgeList){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        Map<Id, Knowledge__kav> knowledgeId2Knowledge = new Map<Id, Knowledge__kav>();
        Set<String> knowledgeTitles = new Set<String>();
        Set<Id> recordTypeIdsToInclude = new Set<Id> {
            UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SOLUTION),
                UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_API)
                };
                    for(Knowledge__kav knowledge : knowledgeList){
                        knowledgeTitles.add(knowledge.Title);            
                    }             
        List <Knowledge__kav> currentLiveList = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndTitleWoSharing(new Set<String> {PUBLISH_STATUS_ONLINE},knowledgeTitles);
        for(Knowledge__kav knowledge : knowledgeList){ 
            if(recordTypeIdsToInclude.contains(knowledge.RecordTypeId)){
                for(Knowledge__kav knowledgeCurrent : currentLiveList){
                    
                    if(knowledge.Title == knowledgeCurrent.Title){
                        knowledgeId2Knowledge.put(knowledgeCurrent.Id, knowledge);  
                    }
                } 
            }
        }
        if(!knowledgeId2Knowledge.isEmpty()){
            List <Child_products__c> subAPIList = SEL_ChildProducts.newInstance().selectByParentProductWoSharing(knowledgeId2Knowledge.keySet());
            for(Child_products__c childProd : subAPIList) {
                childProd.Knowledge_Parent__c = knowledgeId2Knowledge.get(childProd.Knowledge_Parent__c).Id;
                uow.registerDirty(childProd);
            }
            uow.commitWork();
        }
    }
    
}