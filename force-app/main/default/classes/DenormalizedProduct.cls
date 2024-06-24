/**
 * 
 * @description Model Class to Convert Products to Format Manage by Lightning Componenets
 * @author Maham Hasan
 * @since 
 */
public class DenormalizedProduct {

    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public Boolean isOnline;
    @AuraEnabled
    public Boolean isPublished;
    @AuraEnabled
    public DateTime publishedFrom;
    @AuraEnabled
    public DateTime publishedUntil;
    @AuraEnabled
    public String shopId;
    @AuraEnabled
    public String shopName;
    @AuraEnabled 
    public String shopImageUrl;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String text;
    @AuraEnabled
    public String offeringType;
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
    public String solutionId;
    @AuraEnabled 
    public String tagName;
    @AuraEnabled 
    public DateTime createdDate;
    

    /**
	* 
	* @description parse
	* @param json String
	* @return DenormalizedProduct
	*/
	public static DenormalizedProduct parse(String json){
		return (DenormalizedProduct) System.JSON.deserialize(json, DenormalizedProduct.class);
	}

}