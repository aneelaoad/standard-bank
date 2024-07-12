/**
 * 
 * @description Selector Class for Links 
 * @since July/2024
 */
public without sharing class SEL_Mall_Links {

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



   



   

}