/**
 * 
 * @description CTRL_Mall_ArticleInsights
 * @author Ankit Kumar
 * @since 
 */
public with sharing class CTRL_Mall_ArticleInsights {
    /**
     * 
     * @description getInsights
     * @param country String
     * @param category String
     * @return List<Knowledge__kav>
     */
    @AuraEnabled
    public static List<Knowledge__kav> getInsights(String country, String category) {
      try {
        List<Knowledge__kav> knowledgeArticles = MallKnowledgeArticlesListingHandler.getArticles();
        List<Knowledge__kav> insightArticlesByCountry = new List<Knowledge__kav>();
        for(Knowledge__kav article: knowledgeArticles) {
          if(String.IsNotBlank(article.Categories__c) && article.Categories__c.contains(category) &&  String.IsNotBlank(article.OSB_Country__c) && article.OSB_Country__c.contains(country)) {
            insightArticlesByCountry.add(article);
          }
        }
        return insightArticlesByCountry;
      } catch (Exception e) { 
          throw MallExceptionUtil.throwAuraException('CTRL_Mall_ArticleInsights.getInsights', e);
      }
    }
  }