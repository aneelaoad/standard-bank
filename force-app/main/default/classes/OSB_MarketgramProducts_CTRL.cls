/**
* Controller class for MarketgramProducts component,
* shows information on knowledge articles
* <br/>
*
* @author Denys Yelchaninov (dyelchaninov@deloittece.com)
* @date January 2021
*/
public with sharing class OSB_MarketgramProducts_CTRL {
        /**
     * Provides OSBMarketgramProducts component with information required for displaying different
     * knowledge articles, comments and votes
     * 
     * @author Wojciech Kowalczyk
     * 
     * @return map of Knowledge articles,Votes, Feed items and current user's Id
     */
    @AuraEnabled
    public static Map<String, Object> getProductsAndVotes() {
        Id userId = UserInfo.getUserId();
        Contact con = SEL_Contacts.newInstance().selectByUserId(New Set<Id>{userId})[0]; 
        Set <Id> exceptionArticleIds = new Set<Id>();
        List<Knowledge__kav> finalProductsList = new List<Knowledge__kav> ();
        List<Knowledge__kav> finalarticlesWithActivitiesList = new List<Knowledge__kav> ();
        
        for(Knowledge_Entitlement_Exception__c expRecord : SEL_KnowledgeExceptions.newInstance().selectByContactIdWoSharing(new Set<Id>{con.Id})){
            exceptionArticleIds.add(expRecord.OSB_Knowledge_Article__c);
        }
        Set<String> publishStatusSet = new Set<String>{
            DMN_Knowledge.PUBLISH_STATUS_ONLINE
        };
        Set<Id> recordTypesIds = new Set<Id>{
            UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_API),
            UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_Solution)
        };  

        List<Knowledge__kav> apiArticles;
        apiArticles = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdPersonaApiWoSharing(
                    new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},
                    new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_API)},
                    con.OSB_Persona__c,
                    con.OSB_Operating_Country__c,
                    exceptionArticleIds
            );
        
        List<Knowledge__kav> solutionArticles;
        solutionArticles = SEL_KnowledgeArticleVersions.newInstance().selectByPublishStatusAndRecordTypeIdPersonaSolutionWoSharing(
                    new Set<String>{DMN_Knowledge.PUBLISH_STATUS_ONLINE},
                    new Set<Id>{UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION)},
            		new Set<Id>{},
                    con.OSB_Persona__c,
                    con.OSB_Operating_Country__c,
                    exceptionArticleIds
            );
        finalProductsList.addAll(apiArticles);
        finalProductsList.addAll(solutionArticles);
        
        Map<Id, Knowledge__ka> articlesWithActivities = new Map<Id, Knowledge__ka>(
                new SEL_KnowledgeArticles().selectWithVotesAndFeedsByVersionRecordTypePersona(
                        recordTypesIds,
                        publishStatusSet,
                    	exceptionArticleIds,
                    	con.OSB_Persona__c,
                    	con.OSB_Operating_Country__c
                )
        );
        
        Map<String, Object> name2Object = new Map<String, Object>();
        name2Object.put('products', finalProductsList);
        name2Object.put('articlesWithActivities', articlesWithActivities);
        name2Object.put('userId', userId);
        return name2Object;
    }
}