public with sharing class CI_GemLeadController {
    public static List<CI_Gem__c> getLeadGems(String clientId) {   
        Date publicationDate = Date.today().addDays(-15);
        Integer numOfArticlesPerType = 20;
        Integer numberOfLastViewClients = 50;
        String probability = 'medium';
        Boolean isGettingClientSectorNews = false;
        Boolean sortingArticles = false;

        CI_ResponseDto newsResp = CI_NewsController.getClientNews(clientId, numOfArticlesPerType, String.valueOf(publicationDate), numberOfLastViewClients, probability, isGettingClientSectorNews, sortingArticles);

        if(!newsResp.IsSuccess)
            throw new AuraHandledException('Could not get news articles for lead gems. Error: ' + newsResp.Message);

        Map<String, List<ArticleNews__c>> newsByTypeMap = (Map<String, List<ArticleNews__c>>)newsResp.Data;

        checkAndInsertLeadGems(newsByTypeMap.get('newsByClientName'), clientId);

        List<CI_Gem__c> leadGems;
        if(clientId == null)
            leadGems = [SELECT Description__c, Dismissed__c, CreatedDate, Data__c, Deleted__c, RecordType.Name, Client__c, Client__r.Name
                                    FROM CI_Gem__c 
                                    WHERE RecordType.Name = 'News Lead' 
                                    AND User__c =: UserInfo.getUserId() 
                                    ORDER BY CreatedDate DESC];
        else
            leadGems = [SELECT Description__c, Dismissed__c, CreatedDate, Data__c, Deleted__c, RecordType.Name, Client__c, Client__r.Name
                                    FROM CI_Gem__c 
                                    WHERE RecordType.Name = 'News Lead' 
                                    AND User__c =: UserInfo.getUserId() 
                                    AND Client__c =: clientId 
                                    ORDER BY CreatedDate DESC];

        return leadGems;
    }

    public static List<CI_Gem__c> checkAndInsertLeadGems(List<ArticleNews__c> leadArticleList, String clientId) {   
        //Get existing news lead gems, regardless of client, to check for duplicates
        List<CI_Gem__c> extantNewsLeadGems = [SELECT Description__c, Dismissed__c, CreatedDate, Data__c, Deleted__c, RecordType.Name, Client__c 
                                                FROM CI_Gem__c 
                                                WHERE RecordType.Name = 'News Lead' 
                                                AND User__c =: UserInfo.getUserId()];
        
        List<ArticleNews__c> leadGemArticleList = new List<ArticleNews__c>();
        //Loop through news items
        for(ArticleNews__c newsArticle : leadArticleList) {
            system.debug(newsArticle.Pred__c + ' ' + newsArticle.Title__c);
            //check for lead
            if(newsArticle.Pred__c){
                //check if we already have the news lead as a gem
                Boolean gemFound = false;
                for(CI_Gem__c newsLeadGem : extantNewsLeadGems){
                    if(newsArticle.An__c == (String)((Map<String, Object>)JSON.deserializeUntyped(newsLeadGem.Data__c)).get('articleId'))
                        gemFound = true;
                }
                //if not then add
                if(!gemFound)
                    leadGemArticleList.add(newsArticle);
            }
        }

        //get client name if we have a client ID
        Account client = clientId == null ? null : [SELECT Name FROM Account WHERE Id =: clientId];
        
        //Create our new news lead gems
        Id newsLeadRecordTypeId = Schema.SObjectType.CI_Gem__c.getRecordTypeInfosByName().get('News Lead').getRecordTypeId();
        List<CI_Gem__c> newNewsLeadGems = new List<CI_Gem__c>();
        for(ArticleNews__c leadGemArticle : leadGemArticleList){
            JSONGenerator jsonGen = JSON.createGenerator(false);
            jsonGen.writeStartObject();
            jsonGen.writeStringField('articleId', leadGemArticle.An__c);
            jsonGen.writeStringField('articleTitle', leadGemArticle.Title__c);
            jsonGen.writeEndObject();
            
            CI_Gem__c newsLeadGem = new CI_Gem__c();
            newsLeadGem.RecordTypeId = newsLeadRecordTypeId;
            newsLeadGem.User__c = UserInfo.getUserId();
            newsLeadGem.Data__c = jsonGen.getAsString();
            newsLeadGem.Client__c = client ==  null ? null : client.Id;

            newNewsLeadGems.add(newsLeadGem);
        }
        insert newNewsLeadGems;

        return newNewsLeadGems;
    }
}