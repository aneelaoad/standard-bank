public with sharing class MallSolutionsController {
    @AuraEnabled(cacheable=true)
    public static List<DenormalizedSolutionLink> getSolutionLinks() {
        List<DenormalizedSolutionLink> denormalizedSolutionLinks = new List<DenormalizedSolutionLink>();
        
        for (SolutionLinks__mdt link : [SELECT Order__c,Image__c, MasterLabel, LearnMoreLink__c, Tag__c, Description__c, ApplyNowLink__c FROM SolutionLinks__mdt ORDER BY Order__c ASC]) {
            denormalizedSolutionLinks.add(new DenormalizedSolutionLink(
                link.MasterLabel,
                link.tag__c,
                link.Image__c,
               
                link.Description__c,
                link.LearnMoreLink__c,
                link.ApplyNowLink__c
            ));
        }
        
        return denormalizedSolutionLinks;
    }
    
    public class DenormalizedSolutionLink {
        @AuraEnabled public String name;
        @AuraEnabled public String tag;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public String description;
        @AuraEnabled public String learnMoreLink;
        @AuraEnabled public String applyNowLink;
        
        public DenormalizedSolutionLink(String name, String tag, String imageUrl, String description, String learnMoreLink, String applyNowLink) {
            this.name = name;
            this.tag = tag;
            this.imageUrl = imageUrl;
            this.description = description;
            this.learnMoreLink = learnMoreLink;
            this.applyNowLink = applyNowLink;
        }
    }
}