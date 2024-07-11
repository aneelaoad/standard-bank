/**
 * 
 * @description Selector Class for Links 
 * @since 
 */
public without sharing class LinksSelector {

    /**
     * 
     * @description Find Links
     * @param whereClause String of where Clause
     * @return  List<Tag_Link__c>
     */
    public static List<Tag_Link__c> getLinksWhere(String whereClause) {
        String whereClauseString = String.isNotEmpty(whereClause) ? ' WHERE ' + whereClause : '';
        String query = 'Select id, Tag__c,  Link__c,Link__r.Name, Link__r.Guest_Url__c, Tag__r.Name, Tag__r.Parent__r.Name, Tag__r.Parent__c from Tag_Link__c' +whereClauseString;
        
        List<Tag_Link__c> results = Database.query(query);
        System.debug(results);
        return results;
    }

     /**
     * 
     * @description Get App Store Links
     * @return List<Link__c>
     */
    // @AuraEnabled(cacheable=true)
    // public static List<Tag_Link__c> getAppStoreLinks() {
    //     String whereClause = 'Tag__r.Parent__r.Name = \'App Store\'';
    //     return getLinksWhere(whereClause);
    // }
@AuraEnabled(cacheable=true)
    public static List<DenormalizedLink> getAppStoreLinks() {
        String whereClause = 'Tag__r.Parent__r.Name = \'App Store\'';
        List<Tag_Link__c> tagLinks = getLinksWhere(whereClause);

        List<DenormalizedLink> denormalizedLinks = new List<DenormalizedLink>();
        for (Tag_Link__c tagLink : tagLinks) {
            denormalizedLinks.add(new DenormalizedLink(
                tagLink.Link__c,
                tagLink.Link__r.Name,
                tagLink.Link__r.Guest_Url__c,
                tagLink.Tag__r.Name,
                tagLink.Tag__r.Parent__r.Name
            ));
        }
        return denormalizedLinks;
    }

    public class DenormalizedLink {
    @AuraEnabled
    public String linkId;
    @AuraEnabled
    public String linkName;
    @AuraEnabled
    public String guestUrl;
    @AuraEnabled
    public String tagName;
    @AuraEnabled
    public String parentTagName;

    public DenormalizedLink(String linkId, String linkName, String guestUrl, String tagName, String parentTagName) {
        this.linkId = linkId;
        this.linkName = linkName;
        this.guestUrl = guestUrl;
        this.tagName = tagName;
        this.parentTagName = parentTagName;
    }}



    /**
     * @description Get Content Unit Translations
     * @return List<Content_Unit_Translation__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<Content_Unit_Translation__c> getContentUnitTranslations() {
        String query = 'SELECT Name, Title__c,Text__c, Image_Url__c, Tag__r.Name, Product__r.Name, Product__r.Link__r.Name FROM Content_Unit_Translation__c WHERE   Product__r.Id != null';
        List<Content_Unit_Translation__c> results = Database.query(query);
        System.debug(results);



        return results;
    }

    // /**
    //  * @description Get Offerings by Category
    //  * @return List<Tag_Offering__c>
    //  */
    // @AuraEnabled(cacheable=true)
    // public static List<Tag_Offering__c> getOfferingsByCategory() {
    //     String query = 'SELECT Tag__r.Name, Offering__r.Name, Offering__r.Link__r.Name FROM Tag_Offering__c WHERE Tag__r.Parent__r.Name = \'Category\'';
    //     List<Tag_Offering__c> results = Database.query(query);


    //     List<Tag_Offering__c> t = [SELECT Tag__r.Name, Offering__r.Name, Offering__r.Link__r.Name FROM Tag_Offering__c WHERE Tag__r.Parent__r.Name = 'Category'];

    //          List<Content_Unit_Translation__c> f = [SELECT Name, Title__c,Text__c, Image_Url__c, Tag__r.Name, Product__r.Name, Product__r.Link__r.Name FROM Content_Unit_Translation__c WHERE   Product__r.Id=: offering.Id];
    //           System.debug(f );
    //     for (Tag_Offering__c offering : t) {
    //     System.debug('offering: '+offering);       
    //     }
    //     System.debug(results);

    //     return results;
    // }

     /**
     * @description Get Offerings by Category
     * @return List<Tag_Offering__c>
     */
    // @AuraEnabled(cacheable=true)
    // public static List<Tag_Offering__c> getOfferingsByCategory() {
    //     String query = 'SELECT Tag__r.Name, Offering__r.Name, Offering__r.Link__r.Name FROM Tag_Offering__c WHERE Tag__r.Parent__r.Name = \'Category\'';
    //     List<Tag_Offering__c> results = Database.query(query);
    //     return results;
    // }

    /**
     * @description Get Content Unit Translations for Offerings by Category
     * @return List<Content_Unit_Translation__c>
     */
    // @AuraEnabled(cacheable=true)
    // public static List<Content_Unit_Translation__c> getContentUnitTranslationsForOfferingsByCategory() {
    //     // First, get the Offerings by Category
    //     List<Tag_Offering__c> offeringsByCategory = getOfferingsByCategory();
    //     Set<Id> offeringIds = new Set<Id>();
    //     for (Tag_Offering__c tagOffering : offeringsByCategory) {
    //         offeringIds.add(tagOffering.Offering__c);
    //     }

    //     // Fetch the Content Unit Translations for the Offerings
    //     System.debug('offeringIds: '+offeringIds);
    //     if (!offeringIds.isEmpty()) {
    //         String query = 'SELECT Name, Title__c, Text__c, Image_Url__c, Tag__r.Name, Product__r.Name, Product__r.Link__r.Name, Product__c ' +
    //                        'FROM Content_Unit_Translation__c WHERE Product__c IN :offeringIds';
    //         List<Content_Unit_Translation__c> contentUnitTranslations = Database.query(query);
    //         System.debug(contentUnitTranslations);
    //         return contentUnitTranslations;
    //     } else {
    //         return new List<Content_Unit_Translation__c>();
    //     }
    // }




    public class DenormalizedOffering {
    @AuraEnabled
    public String tagName { get; set; }
    @AuraEnabled
    public String offeringName { get; set; }
    @AuraEnabled
    public String linkName { get; set; }
    @AuraEnabled
    public String contentUnitTitle { get; set; }
    @AuraEnabled
    public String contentUnitText { get; set; }
    @AuraEnabled
    public String contentUnitImageUrl { get; set; }

    public DenormalizedOffering(String tagName, String offeringName, String linkName, String contentUnitTitle, String contentUnitText, String contentUnitImageUrl) {
        this.tagName = tagName;
        this.offeringName = offeringName;
        this.linkName = linkName;
        this.contentUnitTitle = contentUnitTitle;
        this.contentUnitText = contentUnitText;
        this.contentUnitImageUrl = contentUnitImageUrl;
    }
    }



     private static List<Tag_Offering__c> getOfferingsByCategory() {
        String query = 'SELECT Tag__r.Name, Offering__r.Name, Offering__r.Link__r.Name ' +
                       'FROM Tag_Offering__c WHERE Tag__r.Parent__r.Name = \'Category\'';
        return Database.query(query);
    }
     /**
     * @description Get Offerings by Category
     * @return List<DenormalizedOffering>
     */
    @AuraEnabled(cacheable=true)
    public static List<DenormalizedOffering> getContentUnitTranslationsForOfferingsByCategory() {
        List<DenormalizedOffering> denormalizedOfferings = new List<DenormalizedOffering>();

        // First, get the Offerings by Category
        List<Tag_Offering__c> offeringsByCategory = getOfferingsByCategory();
        Set<Id> offeringIds = new Set<Id>();
        for (Tag_Offering__c tagOffering : offeringsByCategory) {
            offeringIds.add(tagOffering.Offering__c);
        }

        // Fetch the Content Unit Translations for the Offerings
        System.debug('offeringIds: ' + offeringIds);
        if (!offeringIds.isEmpty()) {
            String query = 'SELECT Name, Title__c, Text__c, Image_Url__c, Tag__r.Name, Product__r.Name, Product__r.Link__r.Name, Product__c ' +
                           'FROM Content_Unit_Translation__c WHERE Product__c IN :offeringIds';
            List<Content_Unit_Translation__c> contentUnitTranslations = Database.query(query);
            System.debug(contentUnitTranslations);

            // Create the denormalized offerings list
            for (Content_Unit_Translation__c contentUnit : contentUnitTranslations) {
                for (Tag_Offering__c tagOffering : offeringsByCategory) {
                    if (contentUnit.Product__c == tagOffering.Offering__c) {
                        DenormalizedOffering denormalizedOffering = new DenormalizedOffering(
                            tagOffering.Tag__r.Name,
                            tagOffering.Offering__r.Name,
                            tagOffering.Offering__r.Link__r.Name,
                            contentUnit.Title__c,
                            contentUnit.Text__c,
                            contentUnit.Image_Url__c
                        );
                        denormalizedOfferings.add(denormalizedOffering);
                    }
                }
            }
        }
        System.debug('offerings: '+ denormalizedOfferings);
        return denormalizedOfferings;
    }

}