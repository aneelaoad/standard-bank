/**
 * 
 * @description Selector Class for Knowledge 
 * @author Maham Hasan
 * @since 
 */
public with sharing class KnowledgeSelector {
    /**
     * 
     * @description Find Knowledge
     * @param whereClause String of where Clause
     * @return  `List<Knowledge__kav>`
     */
    public List<Knowledge__kav> getKnowledgeWhere(String whereClause) {
        String whereClauseString=String.IsEmpty(whereClause)?'':'WHERE '+ whereClause;
        String query = 'SELECT '
        + ' Id, Title, Language, Language__c, Language__r.Name, Country__c, Country__r.Name, Question__c, Answer__c, Body__c, '
        + ' KnowledgeArticleId, UrlName, Icon__c, Related_Article__c, Description__c, Preview_Image_Insights__c '
        + ' FROM Knowledge__kav ' 
        + whereClauseString
        +   ' ORDER BY Position__c ASC ';
        List<Knowledge__kav> results = Database.query(String.valueof(query));
        return results;
    }
}