public with sharing class OfferingsSelector {
    public class DenormalizedOffering {
        @AuraEnabled
        public String tagName { get; set; }
        @AuraEnabled
        public String offeringName { get; set; }
        @AuraEnabled
        public String offeringLI { get; set; }
        @AuraEnabled
        public String contentUnitTitle { get; set; }
        @AuraEnabled
        public String contentUnitText { get; set; }
        @AuraEnabled
        public String contentUnitImageUrl { get; set; }
        @AuraEnabled
         public String desktopUrl{ get; set; }
    
        public DenormalizedOffering(String tagName, String offeringName, String offeringLI, String contentUnitTitle, String contentUnitText, String contentUnitImageUrl, String desktopUrl) {
            this.tagName = tagName;
            this.offeringName = offeringName;
            this.offeringLI = offeringLI;
            this.contentUnitTitle = contentUnitTitle;
            this.contentUnitText = contentUnitText;
            this.contentUnitImageUrl = contentUnitImageUrl;
            this.desktopUrl = desktopUrl;
        }
        }
    
    
         /**
     * @description Get Offerings by Category
     * @return List<DenormalizedOffering>
     */
    @AuraEnabled(cacheable=true)
    public static List<DenormalizedOffering> getContentUnitTranslationsForOfferingsByCategory() {
        Map<String, DenormalizedOffering> denormalizedOfferingsMap = new Map<String, DenormalizedOffering>();

        // First, get the Offerings by Category
        List<Tag_Offering__c> offeringsByCategory = getOfferingsByCategory();
        Set<Id> offeringIds = new Set<Id>();
        for (Tag_Offering__c tagOffering : offeringsByCategory) {
            offeringIds.add(tagOffering.Offering__c);
        }

        // Fetch the Content Unit Translations for the Offerings
        System.debug('offeringIds: ' + offeringIds);
        if (!offeringIds.isEmpty()) {
            String query = 'SELECT Name, Title__c, Text__c, Image_Url__c, Tag__r.Name, Product__r.Name, Product__r.Link__r.Desktop_url__c, Product__c ' +
                           'FROM Content_Unit_Translation__c WHERE Product__c IN :offeringIds';
            List<Content_Unit_Translation__c> contentUnitTranslations = Database.query(query);
            System.debug(contentUnitTranslations);

            // Create the denormalized offerings list
            for (Content_Unit_Translation__c contentUnit : contentUnitTranslations) {
                for (Tag_Offering__c tagOffering : offeringsByCategory) {
                    if (contentUnit.Product__c == tagOffering.Offering__c) {
                        String offeringName = tagOffering.Offering__r.Name;
                        if (denormalizedOfferingsMap.containsKey(offeringName)) {
                            DenormalizedOffering existingOffering = denormalizedOfferingsMap.get(offeringName);
                            if (!existingOffering.tagName.contains(tagOffering.Tag__r.Name)) {
                                existingOffering.tagName += ', ' + tagOffering.Tag__r.Name;
                            }
                        } else {
                            DenormalizedOffering denormalizedOffering = new DenormalizedOffering(
                                tagOffering.Tag__r.Name,
                                offeringName,
                                tagOffering.Offering__r.Link__r.Name,
                                contentUnit.Title__c,
                                contentUnit.Text__c,
                                contentUnit.Image_Url__c,
                               contentUnit.Product__r.Link__r.Desktop_Url__c 
                            );
                            denormalizedOfferingsMap.put(offeringName, denormalizedOffering);
                        }
                    }
                }
            }
        }
        return denormalizedOfferingsMap.values();
    }

    private static List<Tag_Offering__c> getOfferingsByCategory() {
        String query = 'SELECT Tag__r.Name, Offering__r.Name, Offering__r.Link__r.Name ' +
                       'FROM Tag_Offering__c WHERE Tag__r.Parent__r.Name = \'Category\'';
        return Database.query(query);
    }
}