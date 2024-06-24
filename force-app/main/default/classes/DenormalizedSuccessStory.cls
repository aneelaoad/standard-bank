/**
 * 
 * @description Model Class to Convert success stories to Format Manage by Lightning Componenets
 * @author Maham Hasan
 * @since 
 */
public with sharing class DenormalizedSuccessStory {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String summary;
    @AuraEnabled
    public String context;
    @AuraEnabled
    public String challenge;
    @AuraEnabled
    public String solution;
    @AuraEnabled
    public String outcome;
    @AuraEnabled
    public DateTime publishedFrom;
    @AuraEnabled
    public Boolean isOnline;
    @AuraEnabled
    public String videoTestimonyUrl;
    @AuraEnabled
    public String bannerImageUrl;
    @AuraEnabled
    public List<String> galleryImages;
    @AuraEnabled
    public String tagId;
    @AuraEnabled
    public String tagName;
    @AuraEnabled 
    public String successStoryDetailURL;
    @AuraEnabled 
    public String customerFeedback;
    @AuraEnabled 
    public String customerFeedbackFullName;
    @AuraEnabled 
    public String customerImage;

    /**
	* 
	* @description parse
	* @param json String
	* @return DenormalizedSuccessStory
	*/
	public static DenormalizedSuccessStory parse(String json){
		return (DenormalizedSuccessStory) System.JSON.deserialize(json, DenormalizedSuccessStory.class);
	}
}