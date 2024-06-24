/**
 * 
 * @description Model Class to Convert Promotion to Format Manage by Lightning Components
 * @author Ankit Kumar
 * @since 
 */
public with sharing class DenormalizedPromotion {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String imagePath;
    @AuraEnabled
    public String imagePathTablet;
    @AuraEnabled
    public String imagePathDesktop;
    @AuraEnabled
    public Boolean isOnline;
    @AuraEnabled
    public String heading;
    @AuraEnabled
    public String subText;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public String buttonLabel;
    @AuraEnabled
    public String buttonTitle;
    @AuraEnabled
    public String destinationUrl;
    @AuraEnabled
    public String action;
    @AuraEnabled
    public String variant;
    @AuraEnabled
    public String wClass;
    @AuraEnabled
    public Boolean disabled;
    @AuraEnabled
    public Boolean showButton;
    @AuraEnabled
    public Boolean isCarousel;
    @AuraEnabled
    public Boolean customBannerStyles;
    @AuraEnabled
    public Boolean applyColourContrastInversion;
    @AuraEnabled
    public String customBackgroundColour;
    @AuraEnabled
    public String shopId;
    @AuraEnabled
    public String shopName;
    @AuraEnabled
    public Integer rank;
    @AuraEnabled
    public String tagId;
    @AuraEnabled
    public String tagName;
    @AuraEnabled
    public String promotionType;
    @AuraEnabled
    public Boolean isDefaultCategoryBanner;
    
    /**
	* 
	* @description parse
	* @param json String
	* @return DenormalizedPromotion
	*/
	public static DenormalizedPromotion parse(String json){
		return (DenormalizedPromotion) System.JSON.deserialize(json, DenormalizedPromotion.class);
	}
}