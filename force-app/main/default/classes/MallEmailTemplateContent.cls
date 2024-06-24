/**
 * 
 * @description MallEmailTemplateContent
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallEmailTemplateContent {
    /**
     * 
     * @description rowNumber
     */
    public Integer rowNumber {get;set;}
    /**
    * 
    * @description : newContents 
    */
    public List<MallNewContent> newContents {get;set;}
    /**
    * 
    * @description : sendNotifications 
    */
    public class MallNewContent {
       /**
        * 
        * @description : name 
        */
        public String name {get;set;}
        /**
        *
        * @description : title 
        */
        public String title {get;set;}
        /**
        *
        * @description : description 
        */
        public String description {get;set;}
        /**
        *
        * @description : showTitle 
        */
        public Boolean showTitle {get;set;}
        /**
        *
        * @description : imageUrl 
        */
        public String imageUrl {get;set;}
        /**
        *
        * @description : navUrl 
        */
        public String navUrl {get;set;}
        /**
        *
        * @description : expiryDate 
        */
        public DateTime expiryDate {get;set;}
        /**
        *
        * @description : startDate 
        */
        public DateTIme startDate {get;set;}
    }
    
    /**
	* 
	* @description parse
	* @param json String
	* @return MallEmailTemplateContent
	*/
	public static MallEmailTemplateContent parse(String json){
		return (MallEmailTemplateContent) System.JSON.deserialize(json, MallEmailTemplateContent.class);
	}
}