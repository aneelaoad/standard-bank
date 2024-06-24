/**
 * 
 * @description : MallFAQArticlesController
 * @author Maham Hasan
 * @since 
 */
public with sharing class MallFAQArticlesController {

    /**
     * 
     * @description getFAQsInfo
     * @param country String
     * @param category String
     * @return  String 
     */
    @AuraEnabled(Cacheable=true)
    public static String getFAQsInfo(String country, String category) {
        try {
            List<Knowledge__kav> knowledgeArticles = MallKnowledgeArticlesListingHandler.getArticles();
            List<Knowledge__kav> faqArticlesByCountry = new List<Knowledge__kav>();
            for(Knowledge__kav article: knowledgeArticles) {
                if(String.IsNotBlank(article.Categories__c) && article.Categories__c.contains(category) &&  String.IsNotBlank(article.OSB_Country__c) && article.OSB_Country__c.contains(country)) {
                    faqArticlesByCountry.add(article);
                }
            }
            return (!faqArticlesByCountry.IsEmpty() ? prepareData(faqArticlesByCountry) : NULL);
        } catch (Exception e) { 
            throw MallExceptionUtil.throwAuraException('MallFAQArticlesController.getFAQsInfo', e); 
        }
    }

    /**
     * 
     * @description prepareData
     * @param denormalizeContents List<DenormalizedContent>
     * @param filterTagIds `List<String>`
     * @return  String 
     */
    public static String prepareData(List<Knowledge__kav> faqArticles)
    {
        Map<String, Map<String,FAQArticle>> audienceVsHeadingVsFAQArticle=new Map<String, Map<String,FAQArticle>>();
        Map<String,List<FAQArticle>> audienceVsFAQArticles=new Map<String,List<FAQArticle>>();
        for(Knowledge__kav content : faqArticles) {
                if(!audienceVsHeadingVsFAQArticle.containsKey(content.OSB_Persona__c)){
                    Accordion acc=new Accordion();
                    acc.id = content.Id;
                    acc.title = content.Summary;
                    acc.description = content.Info__c;
                    FAQArticle faq = new FAQArticle();
                    faq.id = content.Key_Words__c;
                    faq.heading = content.Key_Words__c;
                    faq.accordionCollection = new List<Accordion>{acc};
                    audienceVsHeadingVsFAQArticle.put(content.OSB_Persona__c,new Map<String,FAQArticle>{content.Key_Words__c=>faq});
                }
                else{
                    Accordion acc=new Accordion();
                    acc.id=content.Id;
                    acc.title=content.Summary;
                    acc.description = content.Info__c;
                    FAQArticle faq = new FAQArticle();
                    faq.id = content.Key_Words__c;
                    faq.heading = content.Key_Words__c;
                    faq.accordionCollection =new List<Accordion>{acc};
                    Map<String,FAQArticle> headingVsFAQArticle=audienceVsHeadingVsFAQArticle.get(content.OSB_Persona__c);
                    if(!headingVsFAQArticle.containsKey(content.Key_Words__c)){
                        audienceVsHeadingVsFAQArticle.get(content.OSB_Persona__c).put(content.Key_Words__c,faq);
                    }
                    else{
                    audienceVsHeadingVsFAQArticle.get(content.OSB_Persona__c).get(content.Key_Words__c).accordionCollection.add(acc);
                    }
            }
        }
        for(String audience:audienceVsHeadingVsFAQArticle.keySet()){
            audienceVsFAQArticles.put(audience,(audienceVsHeadingVsFAQArticle.get(audience)).values());
        }
    return json.serialize(audienceVsFAQArticles);
    }

     /**
     * 
     * @description FAQArticle
     */
    public class FAQArticle {
        String id;
        String heading;
        Integer order;
        List<Accordion> accordionCollection;
    }

    /**
     * 
     * @description Accordion
     */
    public class Accordion {
        String id;
        String title;
        String description;
    }
}