public with sharing class CTRL_MallStatements  {

    /**
    * @description getStatements
    * @return Statement 
    */    
    @AuraEnabled(Cacheable=true)
    public static List<Statement> getStatements(){
        List<Statement> statements = new List<Statement>();
        try {
              
            /*
            MallCustomerAccountListResponse accountListResponse = CTRL_MallDocumentManagement.getCustomerAccountList();
            List<String> accountNumbers = new List<String>();
            for (MallCustomerAccountListResponse.CustomerAccountListDetails accountDetail : accountListResponse.customerAccountListDetails) {
                accountNumbers.add(accountDetail.accountNumber);
            }

            System.debug('@@Account Number Detail List'+accountNumbers);
            */
            
            List<String> AccTestList = new List <String> {'0000010006185337'};
            String startDate = String.valueOf(Date.today().addMonths(-24)); //last 24 months
            String endDate = String.valueOf(Date.today());
            MallDocumentResponse response = CTRL_MallDocumentManagement.getCustomerPreviousStatementsByAccountNumbers(AccTestList, startDate, endDate);

            for (Integer i = response.resultSet.size() - 1; i >= 0; i--) {
                if (statements.size() >= 5) {
                    break; // Exit the loop if we already have 5 elements
                }
                // Get the current resultSet
                MallDocumentResponse.ResultSet resultSet = response.resultSet[i];
                
                // Log the current resultSet for debugging purposes
                System.debug('@@@ Result Set ' + resultSet);
                
                // Add a new Statement object to the statements list
                statements.add(new Statement(resultSet.description, resultSet.label, resultSet.uid));
            }
            
            return statements;

         } catch(Exception e) {
             System.debug('Exception in getCustomerAccountList: ' + e.getMessage());
             throw MallExceptionUtil.throwAuraException('MallStatementsCtrl.getStatements', e);
         }
        
    }

    /**
     * @description : MallStatementsCtrl class
     */
    public class Statement {
        @AuraEnabled
        public String title { get; set; }
       
        @AuraEnabled
        public String strDate { get; set; }
        
        @AuraEnabled
        public String uid { get; set; }
        
        public Statement(String title, String strDate, String strUid) {
            this.title = title;
            this.strDate = strDate;
            this.uid = strUid;
        }
    }

    
}