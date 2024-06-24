/**
 * 
 * @description DenormalizedContent 
 * @author Manasi Londhe
 * @since 
 */
public class DenormalizedContent {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String text;
    @AuraEnabled
    public String richText;
    @AuraEnabled
    public String imageUrl;
    @AuraEnabled
    public DateTime publishedFrom;
    @AuraEnabled
    public DateTime createdDate;
    @AuraEnabled
    public Boolean isOnline;
    @AuraEnabled
    public Integer duration;
    @AuraEnabled
    public Integer order;
    @AuraEnabled
    public String section;
    @AuraEnabled
    public String guestUrl;
    @AuraEnabled
    public String desktopUrl;
    @AuraEnabled
    public String mobileUrl;
    @AuraEnabled
    public List<DenormalizedLink> links;
    @AuraEnabled
    public String tagId;
    @AuraEnabled
    public String tagName;
    
    /**
     * 
     * @description Constructor for Denormalized Content
     */
    public DenormalizedContent() { }
}