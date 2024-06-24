/**
 * 
 * @description Controller Class for MallTodaysInsight
 * @author Maham Hasan
 * @since 
 */
public with sharing class MallTodaysInsightsController {
  
  /**
   * 
   * @description getInsightsInfo
   * @param country String
   * @param category String
   * @return List<Knowledge__kav>
   */
  @AuraEnabled
  public static List<Knowledge__kav> getInsightsInfo() {
    try {
      String country = 'South Africa';
      String category = 'Insights';
      List<Knowledge__kav> knowledgeArticles = MallKnowledgeArticlesListingHandler.getArticles();
      List<Knowledge__kav> insightArticlesByCountry = new List<Knowledge__kav>();
      for(Knowledge__kav article: knowledgeArticles) {
        if(article.OSB_Country__c.contains(country) && article.Categories__c.contains(category)) {
          insightArticlesByCountry.add(article);
        }
      }
      return insightArticlesByCountry;
    } catch (Exception e) { 
        throw MallExceptionUtil.throwAuraException('MallTodaysInsightsController.getInsightsInfo', e);
    }
  }
}