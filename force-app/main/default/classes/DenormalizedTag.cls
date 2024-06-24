/**
 * 
 * @description Model Class to Convert Tags to Format Manage by Lightning Componenets
 * @author Maham Hasan
 * @since 
 */
public  class DenormalizedTag {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public Boolean isRootTag;
    @AuraEnabled
    public Boolean isOnline;
    @AuraEnabled
    public String parentId;
    @AuraEnabled
    public String parentName;
    @AuraEnabled
    public Boolean isPublished;
    @AuraEnabled
    public DateTime publishedFrom;
    @AuraEnabled
    public DateTime publishedUntil; 
    @AuraEnabled
    public String iconUrl;
    @AuraEnabled 
    public String title;
    @AuraEnabled 
    public String text;
    @AuraEnabled 
    public String description;
    @AuraEnabled 
    public String imageUrl;
    @AuraEnabled 
    public Integer position;
    
    /**
	* 
	* @description parse
	* @param json String
	* @return DenormalizedTag
	*/
	public static DenormalizedTag parse(String json){
		return (DenormalizedTag) System.JSON.deserialize(json, DenormalizedTag.class);
	}
}