/**
* @description  : BCB Platform Lgals Controller
*
* @author Ankit Kumar
* @date April 2024
*/
public with sharing class CTRL_Mall_ArticleLegals {
   
    /**
     * 
     * @description getLegalTabsInfo
     * @return  `List<Mall_Legal_Configuration__mdt>`
     */
    @AuraEnabled(Cacheable=true)
    public static List<Mall_Legal_Configuration__mdt> getLegalTabsInfo() 
    {
        return Mall_Legal_Configuration__mdt.getAll().values(); 
    }

    /**
     * 
     * @description getLegalInfo
     * @param country String
     * @param category String
     * @return  `List<Knowledge__kav>`
     */
    @AuraEnabled
    public static List<Knowledge__kav> getLegalInfo(String country, String category) 
    {      
        try {
        List<Knowledge__kav> knowledgeArticles = MallKnowledgeArticlesListingHandler.getArticles();
        List<Knowledge__kav> legalArticlesByCountry = new List<Knowledge__kav>();
        for(Knowledge__kav article: knowledgeArticles) {
            if(String.IsNotBlank(article.Categories__c) && article.Categories__c.contains(category) &&  String.IsNotBlank(article.OSB_Country__c) && article.OSB_Country__c.contains(country)) {
                legalArticlesByCountry.add(article);
            }
        }
        return legalArticlesByCountry;
      } catch (Exception e) { 
        throw MallExceptionUtil.throwAuraException('CTRL_Mall_ArticleLegals.getLegalInfo', e);
      }
    }
}