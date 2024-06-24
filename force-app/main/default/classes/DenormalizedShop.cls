/**
 * 
 * @description Model Class to Convert Shops to Format Manage by Lightning Componenets
 * @author Maham Hasan
 * @since 
 */
public class DenormalizedShop {

    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public Boolean isOnline;
    @AuraEnabled
    public Boolean isSBGShop;
    @AuraEnabled
    public Boolean isPublished;
    @AuraEnabled
    public DateTime publishedFrom;
    @AuraEnabled
    public DateTime publishedUntil;
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
    public String iconUrl;
    @AuraEnabled
    public List<DenormalizedLink> links;
    @AuraEnabled
    public String tagId;
    @AuraEnabled
    public String parentTagId;
    @AuraEnabled
    public String tagName;
    @AuraEnabled
    public DateTime createdDate;
    @AuraEnabled
    public String shopLink;
    @AuraEnabled
    public Boolean isNew;

    /**
	* 
	* @description parse
	* @param json String
	* @return DenormalizedShop
	*/
	public static DenormalizedShop parse(String json){
		return (DenormalizedShop) System.JSON.deserialize(json, DenormalizedShop.class);
	}

}