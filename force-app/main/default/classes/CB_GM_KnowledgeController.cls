/**
* @description  : OneHub - Knowledge Tab related component
* User Story : SFP-7229
*
* @author Sharath Chandra (sharath.chintalapati@standardbank.co.za)
* @date October 2021
*/
public with sharing class CB_GM_KnowledgeController {
    @AuraEnabled(cacheable=true)
/**
* Method fetches the knowledge articles to knowledge page on oneHub
* @param searchKey, articleType
* @return list of knowledge articles
*/   
    public static list<Knowledge__kav> getArticles(string searchKey, string articleType){
        String query;
        String publishedStatus = 'Online';
        list<String> countries = new list<String>();
        list<Knowledge__kav> articlesToReturn = new list<Knowledge__kav>();
        list<cbKnowledge__mdt> listKnowledge = cbKnowledge__mdt.getAll().values();
        for(cbKnowledge__mdt rec : listKnowledge){
            countries.add('\''+ rec.label + '\'');
        }
        
        try {
            if(test.isRunningTest()){
                articlesToReturn = SEL_KnowledgeArticleVersions.newInstance().searchArticles( 'Draft', countries, searchKey, articleType);
            }else{
            	articlesToReturn = SEL_KnowledgeArticleVersions.newInstance().searchArticles( publishedStatus, countries, searchKey, articleType);
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
        return articlesToReturn;
    }
}