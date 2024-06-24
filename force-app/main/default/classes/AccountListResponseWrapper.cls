public with sharing class AccountListResponseWrapper {
    

        public class PageCtrlOut {
            public Integer pageSize;
            public Boolean remainPageInd;
            public Integer remainRecordsCount;
            public Integer totalRecordsCount;
        }
    
        public List<CustomerAccountListDetails> customerAccountListDetails;
        public PageCtrlOut pageCtrlOut;
    
        public class CustomerAccountListDetails {
            public String accountNumber;
            public String productName;
            public String productType;
            public String productTypeDescription;
        }
    
        
        public static AccountListResponseWrapper parse(String json) {
            return (AccountListResponseWrapper) System.JSON.deserialize(json, AccountListResponseWrapper.class);
        }
    }