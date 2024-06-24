public with sharing class MallStatementsResponseWrapper {
    

        public class Errors {
        }
    
        public List<Errors> errors;
        public List<ResultSet> resultSet;
    
        public class Documents {
            public String contentType;
            public String uid;
        }
    
        public class ResultSet {
            public String accountId;
            public String accountNumber;
            public String auxiliaryLabel;
            public String category;
            public String categoryId;
            public String dateFrom;
            public String dateTo;
            public String description;
            public String documentDescription;
            public List<Documents> documents;
            public String label;
            public String uid;
        }
    
        
        public static MallStatementsResponseWrapper parse(String json) {
            return (MallStatementsResponseWrapper) System.JSON.deserialize(json, MallStatementsResponseWrapper.class);
        }
    
}