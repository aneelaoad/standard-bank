/**
 * 
 * @description Apex Type for Document categories response from Content Domain Document API
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallDocumentCategoriesResponse {
    
    @AuraEnabled
    public List<Errors> errors;
    @AuraEnabled
    public List<String> categories;
    @AuraEnabled
    public List<Additions> additions;
    @AuraEnabled
    public Object status;
    @AuraEnabled
    public Object statusDescription;
    
    /**
     * @description Additions
     */
    public class Additions {
        @AuraEnabled
        public String categoryId;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public Object disclaimer;
    }

    /**
     * @description Errors
     */
    public class Errors {
        @AuraEnabled
        public String errorMessage; 
        @AuraEnabled
        public String errorCode; 
    }

    /**
	* 
	* @description parse
	* @param json String
	* @return MallDocumentCategoriesResponse
	*/
	public static MallDocumentCategoriesResponse parse(String json){
		return (MallDocumentCategoriesResponse) System.JSON.deserialize(json, MallDocumentCategoriesResponse.class);
	}
}