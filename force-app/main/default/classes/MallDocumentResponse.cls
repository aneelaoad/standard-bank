/**
 * 
 * @description Apex Type for Document List from Content domain document API
 * @author Ankit Kumar
 * @since 
 */
public class MallDocumentResponse {
	
	/**
     * 
     * @description hasErrors
     */
	@AuraEnabled
	public boolean hasErrors;
	/**
     * 
     * @description errors
     */
	@AuraEnabled
	public Errors[] errors;
	/**
     * 
     * @description resultSet
     */
	@AuraEnabled
	public ResultSet[] resultSet;
	
	/**
     * 
     * @description Errors
     */
	class Errors {
		public Ex ex;
		public String message;	
	}

	/**
     * 
     * @description Ex
     */
	class Ex {
		public String localizedMessage;	
		public Cause cause;
		public SuppressedExceptions[] suppressedExceptions;
		public Suppressed[] suppressed;
		public String detailMessage;	
		public StackTrace[] stackTrace;
		public String message;	
	}

	/**
     * 
     * @description Cause
     */
	class Cause {
		public String localizedMessage;	
		public String detailMessage;	
		public StackTrace[] stackTrace;
		public String message;	
	}

	/**
     * 
     * @description StackTrace
     */
	class StackTrace {
		public String fileName;	
		public boolean nativeMethod;
		public String methodName;	
		public String className;	
		public Integer lineNumber;	
		public String declaringClass;	
	}

	/**
     * 
     * @description SuppressedExceptions
     */
	class SuppressedExceptions {
		public String localizedMessage;	
		public Cause cause;
		public String detailMessage;	
		public StackTrace[] stackTrace;
		public String message;
	}

	/**
	* 
	* @description Suppressed
	*/
	class Suppressed {
		public String localizedMessage;
		public Cause cause;
		public String detailMessage;
		public StackTrace[] stackTrace;
		public String message;
	}

	/**
	* 
	* @description ResultSet
	*/
	public class  ResultSet {
		@AuraEnabled
		public String documentUploadedDate;	
		@AuraEnabled
		public String documentDescription;
		@AuraEnabled	
		public String accountName;
		@AuraEnabled
		public Documents[] documents;
		@AuraEnabled
		public String description;	
		@AuraEnabled
		public DocumentDownload documentDownload;
		@AuraEnabled
		public String label;	
		@AuraEnabled
		public String accountNumber;	
		@AuraEnabled
		public String dateFrom;	
		@AuraEnabled
		public String feeType;	
		@AuraEnabled
		public String feeTsandCs;
		@AuraEnabled	
		public String accountId;
		@AuraEnabled	
		public String uid;	
		@AuraEnabled
		public String feeDescription;	
		@AuraEnabled
		public String auxiliaryLabel;	
		@AuraEnabled
		public String feeRangeStart;
		@AuraEnabled	
		public String feeRangeFinish;
		@AuraEnabled
		public String feeCode;	
		@AuraEnabled
		public String dateTo;	
		@AuraEnabled
		public String feeValue;	
		@AuraEnabled
		public String category;	
		@AuraEnabled
		public String categoryId;	
	}

	/**
	* 
	* @description Documents
	*/
	public class Documents {
		@AuraEnabled
		public String uid;	
		@AuraEnabled
		public String contentType;
		@AuraEnabled	
		public String url;	
	}

	/**
	* 
	* @description DocumentDownload
	*/
	class DocumentDownload {
		public String uid;	
		public String fileName;
		public boolean hasErrors;
		public String contentType;	
		public Errors[] errors;
		public String url;	
		public String content;	
	}

	/**
	* 
	* @description parse
	* @param json String
	* @return MallDocumentResponse
	*/
	public static MallDocumentResponse parse(String json){
		return (MallDocumentResponse) System.JSON.deserialize(json, MallDocumentResponse.class);
	}
}