/**
 * 
 * @description Apex Type for Customer Account List API
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallCustomerAccountListResponse {
    @AuraEnabled
	public List<CustomerAccountListDetails> customerAccountListDetails;
	@AuraEnabled
	public PageCtrlOut pageCtrlOut;
    
	/**
     * @description CustomerAccountListDetails
     */
	public class CustomerAccountListDetails {
		public String productId;
		@AuraEnabled
		public String productName;
		@AuraEnabled
		public String productType;
		@AuraEnabled
		public String productTypeDescription;
		@AuraEnabled
		public String accountNumber;
		public String sourceSystemId;
		public String accountStatusCode;
		public String accountStatusName;
		public String accountActivityStatusDescription;
		public String accountActivityStatusCode;
		public String accountOpenDate;
		public String accountClosedDate;
        public String accountCloseDate;
	}

	/**
     * @description PageCtrlOut
     */
	public class PageCtrlOut {
		@AuraEnabled
		public Integer totalRecordsCount;
		@AuraEnabled
		public Integer pageSize;
		@AuraEnabled
		public Integer remainRecordsCount;
		@AuraEnabled
		public Boolean remainPageInd;
	}

	/**
     * @description parse
	 * @param json String
	 * @return MallCustomerAccountListResponse
     */
	public static MallCustomerAccountListResponse parse(String json){
		return (MallCustomerAccountListResponse) System.JSON.deserialize(json, MallCustomerAccountListResponse.class);
	}
}