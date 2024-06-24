/**
 * 
 * @description Model Class to Convert Products to Format Manage by Lightning Componenets
 * @author Maham Hasan
 * @since 
 */
public class DenormalizedEvent {

    @AuraEnabled
    public String id;
    @AuraEnabled
    public DateTime startDate;
    @AuraEnabled
    public DateTime endDate;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public Boolean isOnline;
    @AuraEnabled
    public String shopId;
    @AuraEnabled
    public String offeringId;
    @AuraEnabled
    public String shopName;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String text;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public String imageUrl;
    @AuraEnabled
    public String guestUrl;
    @AuraEnabled
    public String desktopUrl;
    @AuraEnabled
    public String mobileUrl;
    @AuraEnabled 
    public String tagId;
    @AuraEnabled 
    public String tagName;
    @AuraEnabled 
    public DateTime createdDate;
    
    /**
     * 
     * @description Constructor for Denormalized Product
     */
    public DenormalizedEvent() { }

}